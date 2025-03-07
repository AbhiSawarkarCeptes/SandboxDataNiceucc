/*********************************************************************
* Class Name  :   EnquiryTriggerHelper
* Description :   Helper Class of EnquiryTrigger
* Created Date:   24/07/2023
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 24/07/2023
Gourav Gour 28/02/2024
*********************************************************************/
public class EnquiryTriggerHelper {
    public static boolean dontRun = false;
    public static boolean runOnce = false;
    
    public static void updateEnquiryType(List<PropStrength__Request__c> newList,Map<Id, PropStrength__Request__c> oldEnquiryMap) {
        for(PropStrength__Request__c req : newList) {
            if(oldEnquiryMap == null || (oldEnquiryMap != null && req.Type_Of_Enquiry__c != oldEnquiryMap.get(req.Id).Type_Of_Enquiry__c))
            req.PropStrength__Enquiry_Type__c = req.Type_Of_Enquiry__c == 'Direct' ? 'Direct' : req.Type_Of_Enquiry__c == 'Indirect' ? 'Partner' : '';
        }
    }
    
    
    public static void validateBrokerAccount(List<PropStrength__Request__c> newList) {
        Set<Id> accId = new Set<Id>();        
        for(PropStrength__Request__c req : newList) {
            accId.add(req.PropStrength__Broker_Account__c);
        }
        if(accId.size() > 0){
            Map<Id,Account> mapOfAccountRec = new Map<Id,Account>([SELECT id from Account where ID IN:accId AND PropStrength__Active__c = 'Yes' ]);
            for(PropStrength__Request__c req : newList) {
                if(!mapOfAccountRec.containskey(req.PropStrength__Broker_Account__c)){
                    req.addError('Please select Active Broker Account ');
                }
            }
        }
        
    }
    
    public static void sendMail(List<PropStrength__Request__c> newList,Map<Id, PropStrength__Request__c> oldEnquiryMap) {
        Set<Id> tsaId = new Set<Id>();
        Set<Id> salesManagerId = new Set<Id>();
        for(PropStrength__Request__c req : newList) {
            if(Trigger.isInsert) {
                if(req.OwnerId != null) {
                    tsaId.add(req.Id);
                } else if(req.Sales_Manager__c != null) {salesManagerId.add(req.Id);}
            } else if(Trigger.isUpdate) {
                if(req.OwnerId != oldEnquiryMap.get(req.Id).OwnerId) {
                    tsaId.add(req.Id);
                } else if(req.Sales_Manager__c != oldEnquiryMap.get(req.Id).Sales_Manager__c) {
                    salesManagerId.add(req.Id);
                }
            }
            system.debug('tsaId::'+tsaId);
            system.debug('salesManagerId::'+salesManagerId);
            if(!tsaId.isEmpty()) {
                EnquiryTriggerHelper.sendEmailToOwner(tsaId);
            }
            if(!salesManagerId.isEmpty()) {
                EnquiryTriggerHelper.sendEmailToSalesManager(salesManagerId);
            }
        }
    }
    
    public static void sendEmailToSalesManager(set<Id> enqIds) {
        if(!enqIds.isEmpty()) {
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Enquiry is assigned to Sales Manager' limit 1];
            List<String> emailAddress = new List<String>();
            List<String> ccList = new List<String>(); 
            List<PropStrength__Request__c> existinList = [SELECT Id,Sales_Manager__c,Owner.Email,Re_Enquiry__c,Sales_Manager__r.Email
                                                          FROM PropStrength__Request__c
                                                          WHERE Id IN: enqIds];
            if(!existinList.isEmpty()) {
                for(PropStrength__Request__c req : existinList) {
                    ccList.add(req.Owner.Email);
                    emailAddress.add(req.Sales_Manager__r.Email);
                    Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                    emails.setWhatId(req.Id);
                    if(!emailAddress.isEmpty()) {
                        emails.setToAddresses(emailAddress);
                    }
                    if(!ccList.isEmpty()) {
                        emails.setCcAddresses(ccList);
                    }
                    emails.setTemplateId(templatelist[0].Id);
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(req.Sales_Manager__c);
                    emails.setTreatTargetObjectAsRecipient(false); 
                    emaillist.add(emails);
                }
                try {
                    if(emaillist != null && emaillist.size()>0 ) {
                        Messaging.sendEmail(emaillist);
                    }
                } catch(Exception ex) {
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
        }
    }
    
    public static void sendEmailToOwner(set<Id> enqIds) {
        if(!enqIds.isEmpty()) {
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            Id TempId;
            List<String> emailAddress = new List<String>();
            Map<Id,Id> templateId = new Map<Id,Id>();
            Boolean reEnquiry = false;
            
            List<Contact> updateContactOwnerList = new List<Contact>();
            List<PropStrength__Request__c> existinList = [SELECT Id,OwnerId,Re_Enquiry__c,Owner.Email, PropStrength__Primary_Contact__c, 
                                                          (SELECT Id FROM Visitor_Registrations__r), 
                                                          (SELECT Id FROM Site_Visit_Forms__r) 
                                                          FROM PropStrength__Request__c
                                                          WHERE Id IN: enqIds];
            if(!existinList.isEmpty()) {
                for(PropStrength__Request__c req : existinList) {
                    emailAddress.add(req.Owner.Email);
                    if(req.Re_Enquiry__c) {
                        reEnquiry = true;
                    } else {
                        reEnquiry = false;
                    }
                    if(req.Visitor_Registrations__r.isEmpty() && req.Site_Visit_Forms__r.isEmpty() && req.PropStrength__Primary_Contact__c != null) {
                        updateContactOwnerList.add(new Contact(Id=req.PropStrength__Primary_Contact__c, OwnerId = req.OwnerId));
                    }
                }
                
                if(!updateContactOwnerList.isEmpty()) {
                    update updateContactOwnerList;
                }
                
                if(reEnquiry) {
                    List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate WHERE Name = 'TSA when Re Enquiry' LIMIT 1];                    
                    if(!existinList.isEmpty()) {
                        TempId = templatelist[0].Id;
                    }
                } else {
                    List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate WHERE Name = 'TSA when fresh Enquiry' LIMIT 1];
                    if(!existinList.isEmpty()) {
                        TempId = templatelist[0].Id;
                    }
                }
                for(PropStrength__Request__c req : existinList) {
                    Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                    emails.setWhatId(req.Id);
                    emails.setToAddresses(emailAddress);
                    emails.setTemplateId(TempId);
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(req.OwnerId);
                    emails.setTreatTargetObjectAsRecipient(false); 
                    emaillist.add(emails);
                }
                try {
                    if(emaillist != null && emaillist.size()>0 ) {
                        Messaging.sendEmail(emaillist);
                    }
                } catch(Exception ex) {
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
        }
    }
    
    public static void sendToMobile(List<PropStrength__Request__c> newList,map<Id,PropStrength__Request__c> oldMap) { 
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        boolean trgFlg = mobile_appmdt.Enquiry_Trigger__c;
        set<Id> enqIds = new Set<Id>();
        if(trgFlg) {
            for(PropStrength__Request__c pr : newList) {
                if(trigger.isInsert) {
                    if(pr.PropStrength__Primary_Contact__c != null) {
                        enqIds.add(pr.Id);
                    }
                } else if(trigger.isUpdate) {
                    if(pr.PropStrength__Primary_Contact__c != oldMap.get(pr.Id).PropStrength__Primary_Contact__c) {
                        enqIds.add(pr.Id);
                    }
                }
            }
            system.debug('enqIds::'+enqIds);
            if(!enqIds.isEmpty() && !System.IsBatch() && !System.isFuture()) {
                EnquiryTriggerHelper.sendToMobileAPI(enqIds);
            }
        }
    }
    
    @future(callOut=true)
    public static void sendToMobileAPI(set<Id> enqIds) {
        List<PropStrength__Request__c> existingList = [SELECT Id,PropStrength__Primary_Contact__r.FirstName,PropStrength__Primary_Contact__r.LastName,
                                                       PropStrength__Primary_Contact__r.Email,PropStrength__Primary_Contact__r.MobilePhone
                                                       FROM PropStrength__Request__c 
                                                       WHERE Id IN: enqIds];
        List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
        if(!existingList.isEmpty()) {
            try {
                Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
                String endPointURL = mobile_appmdt.End_Point__c;
                String sftoken = mobile_appmdt.sf_Token__c;
                String Subscription_Key = mobile_appmdt.Subscription_Key__c;
                System.debug('endPointURL : '+endPointURL);
                //String endPointURL = endpoint+'/sruser/v1/user';
                for(PropStrength__Request__c u : existingList) {
                    requestBodyWrapper wrap = new requestBodyWrapper();
                    wrap.firstName = (!String.isBlank(u.PropStrength__Primary_Contact__r.FirstName) ? u.PropStrength__Primary_Contact__r.FirstName : '');
                    wrap.lastName = (!String.isBlank(u.PropStrength__Primary_Contact__r.LastName) ? u.PropStrength__Primary_Contact__r.LastName : '');
                    wrap.email = (!String.isBlank(u.PropStrength__Primary_Contact__r.Email) ? u.PropStrength__Primary_Contact__r.Email : '');
                    wrap.mobile = (!String.isBlank(u.PropStrength__Primary_Contact__r.MobilePhone) ? u.PropStrength__Primary_Contact__r.MobilePhone : '');
                    wrap.password = 'G345345';//Password__c
                    wrap.source = 'salesForce';
                    wrap.dialCode = '0';
                    wraplst.add(wrap);
                }
                if(wraplst != null) {
                    system.debug('wraplst::'+wraplst);
                    String serializedJSON = JSON.serialize(wraplst);
                    System.debug('serializedJSON::'+serializedJSON);
                    if(!String.isBlank(serializedJSON)) {
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(endPointURL);
                        request.setMethod('POST');
                        request.setHeader('Ocp-Apim-Subscription-Key', Subscription_Key);
                        request.setHeader('Content-Type','application/json');
                        request.setHeader('x-integration-key', 'salesforce');
                        request.setHeader('x-sf-token',sftoken);
                        request.setBody(serializedJSON);
                        HttpResponse response = http.send(request);
                        system.debug('getBody:::'+ response.getBody());
                        if (response.getStatusCode() == 200) {
                            system.debug('sucess:::'+response.getBody());
                        } else {
                            system.debug('Error:::'+response.getBody());
                        }
                    }
                }
            } catch(Exception e){
                system.debug('~~~~~Error: '+e.getStackTraceString());
            }
        }
    }
    
    //Added by deepak sharma to update count of enquiry on Advertisement object on 21 Jun 2023
    public static void updateCountOnAdvtMarket(List<PropStrength__Request__c> newEnquiryList, Map<Id, PropStrength__Request__c> newEnquiryMap, String eventOccur) {
        List<PropStrength__Request__c> enquiryList = [SELECT Id, PropStrength__Advertisement__c, PropStrength__Advertisement__r.Marketing_Channel__c, PropStrength__Advertisement__r.Total_Enquiry_Count__c, PropStrength__Advertisement__r.Marketing_Channel__r.Total_Enquiry_Count__c FROM PropStrength__Request__c WHERE Id IN :newEnquiryMap.keySet()];
        
        if(eventOccur == 'Insert') {
            Set<Id> advtIds = new Set<Id>();
            Map<Id, PropStrength__Advertisement__c> updAdvertisement = new Map<Id, PropStrength__Advertisement__c>();
            
            for(PropStrength__Request__c enq : newEnquiryList) {
                if(enq.PropStrength__Advertisement__c != null) {
                    advtIds.add(enq.PropStrength__Advertisement__c);
                }
            }
            
            if(!advtIds.isEmpty()) {
                Map<Id, PropStrength__Advertisement__c> advtMap = new Map<Id, PropStrength__Advertisement__c>([SELECT Id, (SELECT Id FROM PropStrength__Enquiry__r) FROM PropStrength__Advertisement__c WHERE Id IN :advtIds]);
                if(!advtMap.isEmpty()) {
                    for(PropStrength__Request__c enquiry : enquiryList) {
                        if(enquiry.PropStrength__Advertisement__c != null && advtMap.containsKey(enquiry.PropStrength__Advertisement__c)) {
                            if(!updAdvertisement.containsKey(enquiry.PropStrength__Advertisement__c)) {
                                updAdvertisement.put(enquiry.PropStrength__Advertisement__c, new PropStrength__Advertisement__c(Id = enquiry.PropStrength__Advertisement__c, Total_Enquiry_Count__c = advtMap.get(enquiry.PropStrength__Advertisement__c).PropStrength__Enquiry__r.size()));
                            } 
                        }
                    }
                    if(!updAdvertisement.values().isEmpty()) {
                        update updAdvertisement.values();
                    } 
                }
            }           
        }
        
        if(eventOccur == 'Delete') {
            Map<Id, Decimal> updAdvt = new Map<Id, Decimal>();
            for(PropStrength__Request__c enquiry : enquiryList) {
                if(enquiry.PropStrength__Advertisement__c != null) {
                    Decimal advtCount = (enquiry.PropStrength__Advertisement__r.Total_Enquiry_Count__c != null ? enquiry.PropStrength__Advertisement__r.Total_Enquiry_Count__c - 1 : null);
                    if(updAdvt.containsKey(enquiry.PropStrength__Advertisement__c)) {
                        advtCount = updAdvt.get(enquiry.PropStrength__Advertisement__c) - 1;updAdvt.remove(enquiry.PropStrength__Advertisement__c);
                    } 
                    if(enquiry.PropStrength__Advertisement__c != null) {
                        updAdvt.put(enquiry.PropStrength__Advertisement__c, advtCount);
                    }
                } 
            }
            
            if(!updAdvt.isEmpty()) {
                Map<Id, PropStrength__Advertisement__c> advtMap = new Map<Id, PropStrength__Advertisement__c>([SELECT Id, (SELECT Id FROM PropStrength__Enquiry__r) FROM PropStrength__Advertisement__c WHERE Id IN :updAdvt.keySet()]);
                Map<Id, Decimal> totOfferCnt = new Map<Id, Decimal>();
                Map<Id, Decimal> totBookCnt = new Map<Id, Decimal>();
                
                Set<Id> enqIds = new Set<Id>();
                for(PropStrength__Advertisement__c advt : advtMap.values()) {
                    if(!advt.PropStrength__Enquiry__r.isEmpty()) {
                        for(PropStrength__Request__c en : advt.PropStrength__Enquiry__r) {
                            enqIds.add(en.Id);
                        }
                    }
                }
                if(!enqIds.isEmpty()) {
                    Map<Id, PropStrength__Request__c> enqMap = new Map<Id, PropStrength__Request__c>([SELECT Id, PropStrength__Advertisement__c, (SELECT Id FROM PropStrength__Offers__r) FROM PropStrength__Request__c WHERE Id IN :enqIds]);
                    if(!enqMap.isEmpty()) {
                        Set<Id> offIds = new Set<Id>();
                        for(PropStrength__Request__c enq : enqMap.values()) {
                            if(!newEnquiryMap.containsKey(enq.Id)) {
                                Decimal count = enq.PropStrength__Offers__r.size();
                                if(enq.PropStrength__Advertisement__c != null && totOfferCnt.containsKey(enq.PropStrength__Advertisement__c)) {
                                    count += totOfferCnt.get(enq.PropStrength__Advertisement__c);totOfferCnt.remove(enq.PropStrength__Advertisement__c);
                                }
                                
                                totOfferCnt.put(enq.PropStrength__Advertisement__c, count);
                                if(!enq.PropStrength__Offers__r.isEmpty()) {for(PropStrength__Offer__c offer : enq.PropStrength__Offers__r) {offIds.add(offer.Id);
                                                                                                                                            }
                                                                           }
                            }
                        }
                        if(!offIds.isEmpty()) {
                            Map<Id, PropStrength__Offer__c> offMaps = new Map<Id, PropStrength__Offer__c>([SELECT Id, PropStrength__Request__c, PropStrength__Request__r.PropStrength__Advertisement__c, (SELECT Id FROM PropStrength__Applications_Bookings__r) FROM PropStrength__Offer__c WHERE Id IN :offIds]);
                            if(!offMaps.isEmpty()) {
                                for(PropStrength__Offer__c ofer : offMaps.values()) {
                                    Decimal count = ofer.PropStrength__Applications_Bookings__r.size();
                                    if(ofer.PropStrength__Request__c != null && ofer.PropStrength__Request__r.PropStrength__Advertisement__c != null && totBookCnt.containsKey(ofer.PropStrength__Request__r.PropStrength__Advertisement__c)) {
                                        count += totBookCnt.get(ofer.PropStrength__Request__r.PropStrength__Advertisement__c);
                                        totBookCnt.remove(ofer.PropStrength__Request__r.PropStrength__Advertisement__c);
                                    }
                                    totBookCnt.put(ofer.PropStrength__Request__r.PropStrength__Advertisement__c, count);
                                }
                            }
                        }
                    }
                }
                
                System.debug('totOfferCnt**'+totOfferCnt);
                System.debug('totBookCnt**'+totBookCnt);
                System.debug('advtMap**'+advtMap);
                System.debug('updAdvt.keySet()**'+updAdvt.keySet());
                
                List<PropStrength__Advertisement__c> updateAdvertisement = new List<PropStrength__Advertisement__c>();
                for(Id advtId : updAdvt.keySet()) {
                    PropStrength__Advertisement__c tempAdvt = new PropStrength__Advertisement__c(Id = advtId);
                    Boolean flag = FALSE;
                    if(advtMap.containsKey(advtId)) {
                        tempAdvt.Total_enquiry_Count__c = updAdvt.get(advtId);
                        flag = TRUE;
                    }
                    if(totOfferCnt.containsKey(advtId)) {
                        tempAdvt.Total_Offer_Count__c = totOfferCnt.get(advtId);
                        flag = TRUE;
                    }
                    if(totBookCnt.containsKey(advtId)) {
                        tempAdvt.Total_Booking_Count__c = totBookCnt.get(advtId);
                        flag = TRUE;
                    }
                    if(flag) {
                        updateAdvertisement.add(tempAdvt);
                    }
                }
                
                System.debug('updateAdvertisement**'+updateAdvertisement);
                
                if(!updateAdvertisement.isEmpty()) {
                    update updateAdvertisement;
                }
            }
        }
    }
    
    //Added by deepak sharma to update count of Enquiry on Advertisement object on 21 Jun 2023
    public static void updateCountOnAdvtMarketOnUp(List<PropStrength__Request__c> newEnquiryList, Map<Id, PropStrength__Request__c> oldEnquiryMap) {
        Set<Id> advtIds = new Set<Id>();
        List<PropStrength__Advertisement__c> updateAdvtList = new List<PropStrength__Advertisement__c>();
        
        for(PropStrength__Request__c enquiry : newEnquiryList) {
            if(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c != enquiry.PropStrength__Advertisement__c) {
                if(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c != null) {
                    advtIds.add(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c);
                }
                if(enquiry.PropStrength__Advertisement__c != null) {
                    advtIds.add(enquiry.PropStrength__Advertisement__c);
                }
            }
        }
        
        System.debug('advtIds---'+advtIds);
        
        if(!advtIds.isEmpty()) {
            Map<Id, PropStrength__Advertisement__c> advtMap = new Map<Id, PropStrength__Advertisement__c>([SELECT Id, (SELECT Id FROM PropStrength__Enquiry__r) FROM PropStrength__Advertisement__c WHERE Id IN :advtIds]);
            Map<Id, Decimal> totOfferCnt = new Map<Id, Decimal>();
            Map<Id, Decimal> totBookCnt = new Map<Id, Decimal>();
            
            Set<Id> enqIds = new Set<Id>();
            for(PropStrength__Advertisement__c advt : advtMap.values()) {
                if(!advt.PropStrength__Enquiry__r.isEmpty()) {
                    for(PropStrength__Request__c en : advt.PropStrength__Enquiry__r) {
                        enqIds.add(en.Id);
                    }
                }
            }
            if(!enqIds.isEmpty()) {
                Map<Id, PropStrength__Request__c> enqMap = new Map<Id, PropStrength__Request__c>([SELECT Id, PropStrength__Advertisement__c, (SELECT Id FROM PropStrength__Offers__r) FROM PropStrength__Request__c WHERE Id IN :enqIds]);
                if(!enqMap.isEmpty()) {
                    Set<Id> offIds = new Set<Id>();
                    for(PropStrength__Request__c enq : enqMap.values()) {
                        Decimal count = enq.PropStrength__Offers__r.size();
                        if(enq.PropStrength__Advertisement__c != null && totOfferCnt.containsKey(enq.PropStrength__Advertisement__c)) {
                            count += totOfferCnt.get(enq.PropStrength__Advertisement__c);
                            totOfferCnt.remove(enq.PropStrength__Advertisement__c);
                        }
                        totOfferCnt.put(enq.PropStrength__Advertisement__c, count);
                        if(!enq.PropStrength__Offers__r.isEmpty()) {
                            for(PropStrength__Offer__c offer : enq.PropStrength__Offers__r) {
                                offIds.add(offer.Id);
                            }
                        }
                    }
                    if(!offIds.isEmpty()) {
                        Map<Id, PropStrength__Offer__c> offMaps = new Map<Id, PropStrength__Offer__c>([SELECT Id, PropStrength__Request__c, PropStrength__Request__r.PropStrength__Advertisement__c, (SELECT Id FROM PropStrength__Applications_Bookings__r) FROM PropStrength__Offer__c WHERE Id IN :offIds]);
                        if(!offMaps.isEmpty()) {
                            for(PropStrength__Offer__c ofer : offMaps.values()) {
                                Decimal count = ofer.PropStrength__Applications_Bookings__r.size();
                                if(ofer.PropStrength__Request__c != null && ofer.PropStrength__Request__r.PropStrength__Advertisement__c != null && totBookCnt.containsKey(ofer.PropStrength__Request__r.PropStrength__Advertisement__c)) {
                                    count += totBookCnt.get(ofer.PropStrength__Request__r.PropStrength__Advertisement__c);
                                    totBookCnt.remove(ofer.PropStrength__Request__r.PropStrength__Advertisement__c);
                                }
                                totBookCnt.put(ofer.PropStrength__Request__r.PropStrength__Advertisement__c, count);
                            }
                        }
                    }
                }
            }
            
            for(PropStrength__Request__c enquiry : newEnquiryList) {
                if(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c != enquiry.PropStrength__Advertisement__c) {
                    if(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c != null) {
                        PropStrength__Advertisement__c tempAdvt = new PropStrength__Advertisement__c(Id = advtMap.get(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c).Id);
                        Boolean flag = FALSE;
                        if(advtMap.containsKey(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c)) {
                            tempAdvt.Total_enquiry_Count__c = advtMap.get(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c).PropStrength__Enquiry__r.size();
                            flag = TRUE;
                        }
                        if(totOfferCnt.containsKey(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c)) {
                            tempAdvt.Total_Offer_Count__c = totOfferCnt.get(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c);
                            flag = TRUE;
                        }
                        if(totBookCnt.containsKey(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c)) {
                            tempAdvt.Total_Booking_Count__c = totBookCnt.get(oldEnquiryMap.get(enquiry.Id).PropStrength__Advertisement__c);
                            flag = TRUE;
                        }
                        if(flag) {
                            updateAdvtList.add(tempAdvt);
                        }
                    }
                    if(enquiry.PropStrength__Advertisement__c != null) {
                        PropStrength__Advertisement__c tempAdvt = new PropStrength__Advertisement__c(Id = advtMap.get(enquiry.PropStrength__Advertisement__c).Id);
                        Boolean flag = FALSE;
                        if(advtMap.containsKey(enquiry.PropStrength__Advertisement__c)) {
                            tempAdvt.Total_enquiry_Count__c = advtMap.get(enquiry.PropStrength__Advertisement__c).PropStrength__Enquiry__r.size();
                        }
                        if(totOfferCnt.containsKey(enquiry.PropStrength__Advertisement__c)) {
                            tempAdvt.Total_Offer_Count__c = totOfferCnt.get(enquiry.PropStrength__Advertisement__c);
                            flag = TRUE;
                        }
                        if(totBookCnt.containsKey(enquiry.PropStrength__Advertisement__c)) {
                            tempAdvt.Total_Booking_Count__c = totBookCnt.get(enquiry.PropStrength__Advertisement__c);
                            flag = TRUE;
                        }
                        if(flag) {
                            updateAdvtList.add(tempAdvt);
                        }
                    }
                }
            }
            System.debug('updateAdvtList---'+updateAdvtList);
            if(!updateAdvtList.isEmpty()) {
                update updateAdvtList;
            }
        }
    }
    
    //Added by deepak sharma to update Enquiry_Owner_Batch_Update__c field on 27 Jul 2023
    public static void updateBatchTime(List<PropStrength__Request__c> newList) 
    {
        for(PropStrength__Request__c enq : newList) {
            enq.Enquiry_Owner_Batch_Update__c = System.Now();
        }
    }
    //Added by Amrit Sharma to send eMail to owner on 10 Aug 2023
    /*public static void sendMailToOwner(List<PropStrength__Request__c> newList,Map<Id, PropStrength__Request__c> oldEnquiryMap){
Set<Id> userId = new Set<Id>();
Set<Id> enqId = new Set<Id>();
Map<ID, User> userMap = new Map<ID, User>();
List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
for(PropStrength__Request__c req : newList){
if(req.OwnerId != oldEnquiryMap.get(req.Id).OwnerId){
userId.add(req.OwnerId);
enqId.add(req.Id);
}
}
if(userId.size() > 0){
userMap = new Map<ID, User>([SELECT Id, Name, Email,FirstName FROM User WHERE Id=:userId ]);
}
for(PropStrength__Request__c enq : [SELECT Id,Name, OwnerId, PropStrength__Advertisement__r.Name, PropStrength__Primary_Contact__r.Name, PropStrength__Primary_Contact__r.PropStrength__Nationality__c  FROM PropStrength__Request__c WHERE Id=:enqId]){
if(enq.OwnerId != null && userMap.containsKey(enq.OwnerId)) {
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
email.setToAddresses(new list<String>{userMap.get(enq.OwnerId).Email});
email.setSubject('Enquiry Assign');
String currentLink=URL.getSalesforceBaseUrl().toExternalForm();
String link=currentLink+'/'+enq.Id;
String body='Hi '+userMap.get(enq.OwnerId).FirstName+', \n \nThe following enquiry has been assigned to you. Please follow up within 20 minutes to avoid re-allocation of the enquiry. \n \n'+enq.Name+' :- '+link+' \nName :- '+enq.PropStrength__Primary_Contact__r.Name+' \nNationality :- '+ (enq.PropStrength__Primary_Contact__r.PropStrength__Nationality__c != null && enq.PropStrength__Primary_Contact__r.PropStrength__Nationality__c != '' ? enq.PropStrength__Primary_Contact__r.PropStrength__Nationality__c : '' )+'\nAdvertisement Name :- '+ (enq.PropStrength__Advertisement__r.Name != null ? enq.PropStrength__Advertisement__r.Name : '') +'\n\nThank you';
email.setPlainTextBody(body);
mails.add(email);
}
}
if(mails.size() > 0){
List<Messaging.SendEmailResult> mrs= Messaging.sendEmail(mails);
}
}*/
    
    //Added by Anil Bhati to prevent mulitple enquiry creation in insert on same day (11/08/2023)
    public static void preventDupEnqOnSameDay(List<PropStrength__Request__c> reqList){
        Set<Id> ids = new Set<Id>();
        for(PropStrength__Request__c enq : reqList){
            ids.add(enq.PropStrength__Primary_Contact__c);
        }
        
        List<PropStrength__Request__c> enqList = [Select Id, PropStrength__Primary_Contact__c from PropStrength__Request__c where PropStrength__Primary_Contact__c In :Ids and CreatedDate = Today];
        
        Map<Id, PropStrength__Request__c> enqMapWithContact = new Map<Id, PropStrength__Request__c>();
        
        for(PropStrength__Request__c enq : enqList){
            enqMapWithContact.put(enq.PropStrength__Primary_Contact__c, enq);
        }
        
        for(PropStrength__Request__c enq : reqList){
            if(enqMapWithContact.containsKey(enq.PropStrength__Primary_Contact__c))
            {
                // enq.addError('You cannot create more than one enquiry on the same contact in the same day');
            }
        }
    }
    
    //Added by Anil Bhati to update Status and prevent mulitple enquiry creation in Update Scenario on same day (16/08/2023)
    public static void updateStatusAndDupCheck(List<PropStrength__Request__c> reqList, Map<Id, PropStrength__Request__c> oldEnquiryMap){
        Set<Id> ids = new Set<Id>();
        for(PropStrength__Request__c enq : reqList){
            ids.add(enq.PropStrength__Primary_Contact__c);
        }
        
        List<PropStrength__Request__c> enqList = [Select Id, PropStrength__Primary_Contact__c from PropStrength__Request__c where PropStrength__Primary_Contact__c In :Ids and CreatedDate = Today];
        
        Map<Id, PropStrength__Request__c> enqMapWithContact = new Map<Id, PropStrength__Request__c>();
        
        for(PropStrength__Request__c enq : enqList){
            enqMapWithContact.put(enq.PropStrength__Primary_Contact__c, enq);
        }
        
        for(PropStrength__Request__c enq : reqList ){
            if(enq.PropStrength__Primary_Contact__c != oldEnquiryMap.get(enq.Id).PropStrength__Primary_Contact__c){
                if(enqMapWithContact.containsKey(enq.PropStrength__Primary_Contact__c))
                {
                    enq.addError('You cannot create more than one enquiry on the same contact in the same day');
                }
            }
            if(enq.Enquiry_Close__c){
                //enq.PropStrength__Request_Status__c = 'Closed/Lost';
            }
        }
        
    }
    
    //Added by Deepak sharma on 01 Dec 2023 to map Sales Manager and Secondary Sales Manager as per Sales head and secondary sales head respectively
    // Make changes by Gourav Gour on 28 Feb 2024.
    public static void mapSalesManagers(List<PropStrength__Request__c> enqList, Map<Id, PropStrength__Request__c> oldEnqMap, String actionType) {
        Set<Id> userId = new Set<Id>();
        
        for(PropStrength__Request__c enq : enqList) {
            if(actionType == 'Insert') {
                if(enq.Sales_Manager__c != null) {
                    userId.add(enq.Sales_Manager__c);
                }
                if(enq.Secondary_Sales_Manager__c != null) {
                    userId.add(enq.Secondary_Sales_Manager__c);
                }
            }
            if(actionType == 'Update') {
                if(enq.Sales_Manager__c != null && enq.Sales_Manager__c != oldEnqMap.get(enq.Id).Sales_Manager__c) {
                    userId.add(enq.Sales_Manager__c);
                }
                if(enq.Secondary_Sales_Manager__c != null && enq.Secondary_Sales_Manager__c != oldEnqMap.get(enq.Id).Secondary_Sales_Manager__c) {
                    userId.add(enq.Secondary_Sales_Manager__c);
                }
            }
        }
        
        if(!userId.isEmpty()) {
            Map<Id, User> userMap = new Map<id, User>([SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId FROM User WHERE Id IN :userId]);
            for(PropStrength__Request__c enq : enqList) {
                if(actionType == 'Insert') {
                    if(enq.Sales_Manager__c != null && !userMap.isEmpty() && userMap.containsKey(enq.Sales_Manager__c)) {
                        if(userMap.get(enq.Sales_Manager__c).ManagerId != null) {
                            enq.Sales_Head__c = userMap.get(enq.Sales_Manager__c).ManagerId;
                        }
                        if(userMap.get(enq.Sales_Manager__c).ManagerId != null && userMap.get(enq.Sales_Manager__c).Manager.ManagerId != null) {
                            enq.Sales_VP__c = userMap.get(enq.Sales_Manager__c).Manager.ManagerId;
                        }
                        if(userMap.get(enq.Sales_Manager__c).ManagerId != null && userMap.get(enq.Sales_Manager__c).Manager.ManagerId != null && userMap.get(enq.Sales_Manager__c).Manager.Manager.ManagerId != null ) {
                            enq.Sales_SVP__c = userMap.get(enq.Sales_Manager__c).Manager.Manager.ManagerId;
                        }
                    }
                    if(enq.Secondary_Sales_Manager__c != null && !userMap.isEmpty() && userMap.containsKey(enq.Secondary_Sales_Manager__c)) {
                        if(userMap.get(enq.Secondary_Sales_Manager__c).ManagerId != null) {
                            enq.Secondary_Sales_Head__c = userMap.get(enq.Secondary_Sales_Manager__c).ManagerId;
                        }
                        if(userMap.get(enq.Secondary_Sales_Manager__c).ManagerId != null && userMap.get(enq.Secondary_Sales_Manager__c).Manager.ManagerId != null) {
                            enq.Secondary_Sales_VP__c = userMap.get(enq.Secondary_Sales_Manager__c).Manager.ManagerId;
                        }
                        if(userMap.get(enq.Secondary_Sales_Manager__c).ManagerId != null && userMap.get(enq.Secondary_Sales_Manager__c).Manager.ManagerId != null && userMap.get(enq.Secondary_Sales_Manager__c).Manager.Manager.ManagerId != null ) {
                            enq.Secondary_Sales_SVP__c = userMap.get(enq.Secondary_Sales_Manager__c).Manager.Manager.ManagerId;
                        }
                    }
                    
                }
                if(actionType == 'Update') {
                    if(enq.Sales_Manager__c != null && enq.Sales_Manager__c != oldEnqMap.get(enq.Id).Sales_Manager__c && !userMap.isEmpty() && userMap.containsKey(enq.Sales_Manager__c)) {
                        if(userMap.get(enq.Sales_Manager__c).ManagerId != null) {
                            enq.Sales_Head__c = userMap.get(enq.Sales_Manager__c).ManagerId;
                        }
                        if(userMap.get(enq.Sales_Manager__c).ManagerId != null && userMap.get(enq.Sales_Manager__c).Manager.ManagerId != null) {
                            enq.Sales_VP__c = userMap.get(enq.Sales_Manager__c).Manager.ManagerId;
                        }
                        if(userMap.get(enq.Sales_Manager__c).ManagerId != null && userMap.get(enq.Sales_Manager__c).Manager.ManagerId != null && userMap.get(enq.Sales_Manager__c).Manager.Manager.ManagerId != null ) {
                            enq.Sales_SVP__c = userMap.get(enq.Sales_Manager__c).Manager.Manager.ManagerId;
                        }
                    }
                    if(enq.Secondary_Sales_Manager__c != null && enq.Secondary_Sales_Manager__c != oldEnqMap.get(enq.Id).Secondary_Sales_Manager__c && !userMap.isEmpty() && userMap.containsKey(enq.Secondary_Sales_Manager__c)) {
                        if(userMap.get(enq.Secondary_Sales_Manager__c).ManagerId != null) {
                            enq.Secondary_Sales_Head__c = userMap.get(enq.Secondary_Sales_Manager__c).ManagerId;
                        }
                        if(userMap.get(enq.Secondary_Sales_Manager__c).ManagerId != null && userMap.get(enq.Secondary_Sales_Manager__c).Manager.ManagerId != null) {
                            enq.Secondary_Sales_VP__c = userMap.get(enq.Secondary_Sales_Manager__c).Manager.ManagerId;
                        }
                        if(userMap.get(enq.Secondary_Sales_Manager__c).ManagerId != null && userMap.get(enq.Secondary_Sales_Manager__c).Manager.ManagerId != null && userMap.get(enq.Secondary_Sales_Manager__c).Manager.Manager.ManagerId != null ) {
                            enq.Secondary_Sales_SVP__c = userMap.get(enq.Secondary_Sales_Manager__c).Manager.Manager.ManagerId;
                        }
                    }
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 27 Dec 2023 to check enquiry's primary contact already has an enquiry then update the owner
    // modification Gourav 29/04/2024 status check , changes made by Gourav 13/05/2024
    // Bypass this if record is created from Enquiry Creation page.
    public static void  updateEnquiryOwner(List<PropStrength__Request__c> enqList, Map<Id, PropStrength__Request__c> oldEnqMap) {
        dontRun = true;
        Set<Id> conId = new Set<Id>();
        
        for(PropStrength__Request__c req : enqList) {
            if(!req.Enquiry_Created_From_Form__c && req.PropStrength__Primary_Contact__c != null && req.PropStrength__Request_Status__c != 'Site Visit Done' /*&& req.PropStrength__Request_Source__c != 'Stand Leads'*/ && req.Willing_to_meet_this_week__c != 'Assign RM on Stand') {
                conId.add(req.PropStrength__Primary_Contact__c);
            }
        }
        
        if(!conId.isEmpty()) {
            Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, (SELECT Id, OwnerId, Owner.IsActive, Assignment_Group__c FROM PropStrength__Requests__r WHERE PropStrength__Request_Status__c != 'Closed/ Lost' AND PropStrength__Request_Status__c != 'Converted to Offer' AND Id NOT IN :oldEnqMap.keySet() ORDER BY CreatedDate DESC) FROM Contact WHERE Id IN :conId]);
            List<PropStrength__Request__c> updateEnqList = new List<PropStrength__Request__c>();
            
            for(PropStrength__Request__c req : enqList) {
                if(!req.Enquiry_Created_From_Form__c && req.PropStrength__Primary_Contact__c != null && !contMap.isEmpty() && contMap.containsKey(req.PropStrength__Primary_Contact__c) && !contMap.get(req.PropStrength__Primary_Contact__c).PropStrength__Requests__r.isEmpty() && contMap.get(req.PropStrength__Primary_Contact__c).PropStrength__Requests__r[0].Owner.IsActive && req.Assignment_Group__c == contMap.get(req.PropStrength__Primary_Contact__c).PropStrength__Requests__r[0].Assignment_Group__c && req.Willing_to_meet_this_week__c != 'Assign RM on Stand' ) {
                    updateEnqList.add(new PropStrength__Request__c(Id = req.Id, OwnerId = contMap.get(req.PropStrength__Primary_Contact__c).PropStrength__Requests__r[0].OwnerId));
                }   
                else if(!req.Enquiry_Created_From_Form__c && req.PropStrength__Primary_Contact__c != null && !contMap.isEmpty() && contMap.containsKey(req.PropStrength__Primary_Contact__c) && !contMap.get(req.PropStrength__Primary_Contact__c).PropStrength__Requests__r.isEmpty() && contMap.get(req.PropStrength__Primary_Contact__c).PropStrength__Requests__r[0].Owner.IsActive && req.Willing_to_meet_this_week__c != 'Assign RM on Stand') {
                    updateEnqList.add(new PropStrength__Request__c(Id = req.Id, OwnerId = contMap.get(req.PropStrength__Primary_Contact__c).PropStrength__Requests__r[0].OwnerId));
                }
            }
            
            System.debug('updateEnqList****');
            System.debug(updateEnqList);
            
            if(!updateEnqList.isEmpty()) {
                update updateEnqList;
            }
        }
    }
    
    //Added by Nishank Manwani on 27-December-2023 to check if enquiry already exists with the same primary contact and project then check the Re-Enquiry checkbox
    public static void checkIfEnquiryAlreadyExistWithProjectAndPC(List<PropStrength__Request__c> enqList) {
        Set<Id> contId = new Set<Id>();
        Set<Id> projectId = new Set<Id>();
        
        for(PropStrength__Request__c enq : enqList) {
            if(enq.PropStrength__Primary_Contact__c != null /*&& enq.PropStrength__Project__c != null*/) {
                contId.add(enq.PropStrength__Primary_Contact__c);
                // projectId.add(enq.PropStrength__Project__c);
            }
        }
        
        if(!contId.isEmpty() /*&& !projectId.isEmpty()*/) {
            Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, (SELECT Id, OwnerId, Owner.IsActive, Assignment_Group__c FROM PropStrength__Requests__r ORDER BY CreatedDate DESC) FROM Contact WHERE Id IN :contId]);
            
            // List<PropStrength__Request__c> enqListExist = [SELECT Id, PropStrength__Primary_Contact__c, PropStrength__Project__c FROM PropStrength__Request__c WHERE PropStrength__Primary_Contact__c IN :contId /*AND PropStrength__Project__c IN :projectId*/];
            
            if(!contMap.isEmpty()) {
                // Map<Id, List<PropStrength__Request__c>> contEnqMap = new Map<Id, List<PropStrength__Request__c>>();
                // Map<Id, List<PropStrength__Request__c>> projectEnqMap = new Map<Id, List<PropStrength__Request__c>>();
                
                /* for(PropStrength__Request__c enq : enqListExist) {
if(contEnqMap.containsKey(enq.PropStrength__Primary_Contact__c)) {
contEnqMap.get(enq.PropStrength__Primary_Contact__c).add(enq);
} else { 
contEnqMap.put(enq.PropStrength__Primary_Contact__c, new List<PropStrength__Request__c>{enq});
}

if(projectEnqMap.containsKey(enq.PropStrength__Project__c)) {
projectEnqMap.get(enq.PropStrength__Project__c).add(enq);
} else {
projectEnqMap.put(enq.PropStrength__Project__c, new List<PropStrength__Request__c>{enq});
}
}*/
                
                // System.debug('contEnqMap*****');
                // System.debug(contEnqMap);
                // System.debug('projectEnqMap****');
                // System.debug(projectEnqMap);
                
                for(PropStrength__Request__c enq : enqList) {
                    if(enq.PropStrength__Primary_Contact__c != null /*&& enq.PropStrength__Project__c != null*/) {
                        // project condition commented by gourav 14/5/2024
                        // if(contEnqMap.keySet().contains(enq.PropStrength__Primary_Contact__c) && contEnqMap.get(enq.PropStrength__Primary_Contact__c).size() > 0 /*&& projectEnqMap.get(enq.PropStrength__Project__c).size() > 0*/) {
                        //     enq.Re_Enquiry__c = true;
                        // }
                        if(contMap.containskey(enq.PropStrength__Primary_Contact__c) && contMap.get(enq.PropStrength__Primary_Contact__c).PropStrength__Requests__r.size() > 0 /*&& projectEnqMap.get(enq.PropStrength__Project__c).size() > 0*/) {
                            enq.Re_Enquiry__c = true;
                        }
                        if(contMap.containskey(enq.PropStrength__Primary_Contact__c) && contMap.get(enq.PropStrength__Primary_Contact__c).PropStrength__Requests__r.size() > 0 
                           && !contMap.get(enq.PropStrength__Primary_Contact__c).PropStrength__Requests__r[0].Owner.IsActive) {
                               enq.Inactive_Owner_Previous_Enquiry__c = true;
                           }
                    }
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 15-Jan-2024 to check the Broker Account is Blacklisted or not
    /* public static void checkBlacklisted (List<PropStrength__Request__c> enquiryList) {
List<Blacklisted__c> blackListRec = [SELECT Id, RecordType.Name,Channel_Partner__c, From_Date__c, To_Date__c, Customer__c, Unit__c 
FROM Blacklisted__c WHERE Blacklisted__c = TRUE];
if(!blackListRec.isEmpty()) {
for(PropStrength__Request__c enq : enquiryList) {
for(Blacklisted__c bl : blackListRec) {
if(bl.From_Date__c != null && bl.To_Date__c != null && EnquiryTriggerHelper.isTodayWithinRange(bl.From_Date__c, bl.To_Date__c)) {
if(bl.RecordType.Name == 'Broker') {
if(enq.PropStrength__Broker_Account__c != null && enq.PropStrength__Broker_Account__c == bl.Channel_Partner__c) {
enq.addError('Enquiry can\'t create for given Broker Account because it is blacklisted');
break;
}
}
}
}
}
}
}
*/
    //Added by Nishank Manwani on 15-Jan-2024 to check the Primary Customer is Blacklisted or not
    // modification by Deepak on 06-02-2024 
    public static void checkBlacklistedForCustomer (List<PropStrength__Request__c> enquiryList, Map<Id, PropStrength__Request__c> oldEnqMap) {
        Set<Id> brokerAccountId = new Set<Id>();
        Set<Id> primaryContactId = new Set<Id>();
        Set<String> blockIds = new Set<String>();
        List<PropStrength__Request__c> enquiryhaveToCheck  = new List<PropStrength__Request__c>();
        if(oldEnqMap != null) {
            for(PropStrength__Request__c rec : enquiryList) {
                if( rec.PropStrength__Broker_Account__c != oldEnqMap.get(rec.Id).PropStrength__Broker_Account__c 
                   || rec.PropStrength__Primary_Contact__c != oldEnqMap.get(rec.Id).PropStrength__Primary_Contact__c
                   || rec.PropStrength__Selected_Property_Ids__c != oldEnqMap.get(rec.Id).PropStrength__Selected_Property_Ids__c) {
                       enquiryhaveToCheck.add(rec);
                   }
            }
        }
        else {
            enquiryhaveToCheck.addAll(enquiryList);
        }
        if(!enquiryhaveToCheck.isEmpty()) {
            for(PropStrength__Request__c offerRec : enquiryhaveToCheck) {
                if(offerRec.PropStrength__Broker_Account__c != null) {
                    brokerAccountId.add(offerRec.PropStrength__Broker_Account__c);
                }
                if(offerRec.PropStrength__Primary_Contact__c != null) {
                    primaryContactId.add(offerRec.PropStrength__Primary_Contact__c);
                }
            }
            
            
            List<Blacklisted__c> blackList = [SELECT Id, Channel_Partner__c, Customer__c, Unit__c, From_Date__c, To_Date__c,  RecordType.name 
                                              FROM Blacklisted__c 
                                              WHERE Blacklisted__c = true AND ((From_Date__c = null OR From_Date__c <= TODAY) AND (To_Date__c >= TODAY OR To_Date__c = null)) AND (Channel_Partner__c IN :brokerAccountId OR Customer__c IN: primaryContactId)];
            for(Blacklisted__c rec : blackList) { if(rec.RecordType.name  == 'Broker') { blockIds.add(rec.Channel_Partner__c+'');
                                                                                       }
                                                 if(rec.RecordType.name == 'Customer') {
                                                     if(rec.Unit__c != null) {
                                                         blockIds.add(rec.Customer__c + '_' + rec.Unit__c);
                                                     }
                                                     else {
                                                         blockIds.add(rec.Customer__c + '_');
                                                     }
                                                     
                                                 }
                                                }
            
            for(PropStrength__Request__c offerRec : enquiryList) {
                if(blockIds.contains(offerRec.PropStrength__Broker_Account__c+'')) {
                    offerRec.addError('This broker can not be selected on enquiry as it is blacklisted');
                    continue;
                }
                if(offerRec.PropStrength__Selected_Property_Ids__c != null) {
                    for(String Ids : offerRec.PropStrength__Selected_Property_Ids__c.split(',')) {
                        if(blockIds.contains(offerRec.PropStrength__Primary_Contact__c+'_'+Ids) || blockIds.contains(offerRec.PropStrength__Primary_Contact__c+'_')) {
                            offerRec.addError('Enquiry can not be created on this property for the selected contact as the contact is blacklisted.');
                        }
                    }
                }
            }
        }
        // List<Blacklisted__c> blackListRec = [SELECT Id, RecordType.Name,Channel_Partner__c, From_Date__c, To_Date__c, Customer__c, Unit__c, Unit__r.PropStrength__Property_Name__c  
        //                                         FROM Blacklisted__c WHERE Blacklisted__c = TRUE];
        // if(!blackListRec.isEmpty()) {
        //     for(PropStrength__Request__c enq : enquiryList) {
        //         if(enq.PropStrength__Selected_Property_Ids__c != null && enq.PropStrength__Selected_Property_Ids__c != oldEnqMap.get(enq.Id).PropStrength__Selected_Property_Ids__c) {
        //             for(Blacklisted__c bl : blackListRec) {
        //                 if(bl.From_Date__c != null && bl.To_Date__c != null && EnquiryTriggerHelper.isTodayWithinRange(bl.From_Date__c, bl.To_Date__c)) {
        //                     if(bl.RecordType.Name == 'Customer') {
        //                         if(enq.PropStrength__Primary_Contact__c != null && enq.PropStrength__Primary_Contact__c == bl.Customer__c && bl.Unit__c != null && enq.PropStrength__Selected_Property_Ids__c.contains(bl.Unit__c)) {
        //                             enq.addError('This Selected Property : '+ bl.Unit__r.PropStrength__Property_Name__c +' is not available, because it is blacklisted');
        //                             break;
        //                         }
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }
    }
    
    //Added by Nishank Manwani on 15-Jan-2024 to check if the current date lies between two given dates. 
    public static Boolean isTodayWithinRange(Date startDate, Date endDate) {
        Date today = System.Today();
        
        if (today >= startDate && today <= endDate) {
            return true;
        } else {
            return false;
        }
    }
    
    
    public static void handleHasValues(List<PropStrength__Request__c> newEnquiryList, Map<Id, PropStrength__Request__c> oldEnqMap, boolean isUpdate) {
        List<PropStrength__Request__c> enqueryToUpdate = new List<PropStrength__Request__c>();
        List<PropStrength__Request__c> enqueryList = [SELECT Id,PropStrength__Email_Address__c,  PropStrength__Advertisement__c, PropStrength__Advertisement__r.Name, Advertisement_HasValue__c,
                                                      Nationality__c, Gender__c, Name, PropStrength__Primary_Contact__c, PropStrength__Primary_Contact__r.Name, Gender_HashValue__c, LeadId_HashValue__c,
                                                      Name_HashValue__c, Nationality_HashValue__c
                                                      FROM PropStrength__Request__c WHERE Id IN :newEnquiryList];
        map<string,string> fieldMapping = new map<string,string>();
        list<Offer_Attribution_Modelling__mdt> mappingList = [Select Offer_Source_Field__c,Offer_Hash_Field__c from Offer_Attribution_Modelling__mdt];
        for(Offer_Attribution_Modelling__mdt mapping : mappingList){
            if(mapping.Offer_Source_Field__c!=null && mapping.Offer_Hash_Field__c!=null){
                fieldMapping.put(mapping.Offer_Source_Field__c,mapping.Offer_Hash_Field__c);
            }
        }
        Set < String > fields = new Set < String >();
        for ( Schema.SObjectField objField : Schema.SObjectType.PropStrength__Request__c.fields.getMap().values() ) {
            fields.add( objField.getDescribe().getName());
        }
        if(fieldMapping.size()>0){
            set<string> attributionFieldList = fieldMapping.keySet();
            for(PropStrength__Request__c rec : enqueryList) {
                if(!isUpdate || (isUpdate && (rec.PropStrength__Advertisement__c !=  oldEnqMap.get(rec.Id).PropStrength__Advertisement__c  || rec.Nationality__c !=  oldEnqMap.get(rec.Id).Nationality__c || rec.Gender__c !=  oldEnqMap.get(rec.Id).Gender__c || rec.Name !=  oldEnqMap.get(rec.Id).Name || rec.PropStrength__Primary_Contact__c !=  oldEnqMap.get(rec.Id).PropStrength__Primary_Contact__c))) {
                    for(string aField : attributionFieldList){
                        if(fields.contains(aField) && aField == 'PropStrength__Advertisement__c') {
                            aField = aField.trim();
                            if(rec.get(aField) != null && rec.get(aField) != ''){
                                rec.put(fieldMapping.get(aField),OfferTriggerHelper.getSha256(string.valueOf(rec.getSobject('PropStrength__Advertisement__r').get('Name'))));
                            }
                            else {
                                rec.put(fieldMapping.get(aField), '');
                            }
                        }
                        else if(fields.contains(aField) && aField == 'PropStrength__Primary_Contact__c') {
                            aField = aField.trim();
                            if(rec.get(aField) != null && rec.get(aField) != ''){
                                rec.put(fieldMapping.get(aField),OfferTriggerHelper.getSha256(string.valueOf(rec.getSobject('PropStrength__Primary_Contact__r').get('Name'))));
                            }
                            else {
                                rec.put(fieldMapping.get(aField), '');
                            }
                        }
                        else if(fields.contains(aField) && (aField == 'Nationality__c' || aField == 'Gender__c' || aField == 'Name')) {
                            aField = aField.trim();
                            if(rec.get(aField) != null && rec.get(aField) != ''){
                                rec.put(fieldMapping.get(aField),OfferTriggerHelper.getSha256(string.valueOf(rec.get(aField))));
                            }
                            else {
                                rec.put(fieldMapping.get(aField), '');
                            }
                        }
                    }
                    enqueryToUpdate.add(rec);
                }
            }
        }
        
        if(enqueryToUpdate.size() > 0) {
            Database.SaveResult[] offerCommission_Result = Database.update(enqueryToUpdate, false);
            for(Database.SaveResult str : offerCommission_Result) {
                if(!str.isSuccess()) { for(Database.Error err : str.getErrors()) {
                    System.debug(err.getStatusCode() + ' ===> Enquiry handleHasValues Status Code Message ' + err.getMessage());
                }
                                     }
            }
        }
    }
    
    //Added by nishank manwani on 19 Mar 2024 to update status to close lost after 21 days idle enquiry
    public static void updateCloseLostAfter21Days(List<PropStrength__Request__c> newEnquiryList, Map<Id, PropStrength__Request__c> oldEnqMap) {
        Set<Id> conId = new Set<Id>();
        
        for(PropStrength__Request__c req : newEnquiryList) {
            if(req.PropStrength__Primary_Contact__c != null) {
                conId.add(req.PropStrength__Primary_Contact__c);
            }
        }
        
        Map<Id, PropStrength__Assignment_Group_Name__c> assGrpMap = new Map<Id, PropStrength__Assignment_Group_Name__c>([SELECT Id, Name, (SELECT Id, PropStrength__User__c, PropStrength__Order__c FROM PropStrength__Group_Members__r WHERE PropStrength__Active__c = 'TRUE' ORDER BY PropStrength__Order__c), 
                                                                                                                         (SELECT Id, PropStrength__Criteria__c FROM PropStrength__Assignment_Rule_entries__r ORDER BY PropStrength__Order__c)
                                                                                                                         FROM PropStrength__Assignment_Group_Name__c WHERE PropStrength__Active__c = TRUE]);
        
        Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, (SELECT Id, Assignment_Group__c, Assignment_Group__r.Name, OwnerId FROM PropStrength__Requests__r WHERE PropStrength__Request_Status__c != 'Closed/ Lost' AND PropStrength__Request_Status__c != 'Converted to Offer' AND Id NOT IN :oldEnqMap.keySet() ORDER BY CreatedDate DESC) FROM Contact WHERE Id IN :conId]);
        List<PropStrength__Request__c> updateEnqList = new List<PropStrength__Request__c>();
        
        
        for(PropStrength__Request__c enq : newEnquiryList) {
            if(enq.PropStrength__Request_Status__c == 'Open' && enq.Enquiry_Idle_Days__c >= 21 && enq.Enquiry_Idle_Days__c != oldEnqMap.get(enq.Id).Enquiry_Idle_Days__c) {
                enq.PropStrength__Request_Status__c = 'Closed/ Lost';
                
                if(enq.PropStrength__Primary_Contact__c != null && !contMap.isEmpty() && contMap.containsKey(enq.PropStrength__Primary_Contact__c) && !contMap.get(enq.PropStrength__Primary_Contact__c).PropStrength__Requests__r.isEmpty()) {
                    for(PropStrength__Request__c req : contMap.get(enq.PropStrength__Primary_Contact__c).PropStrength__Requests__r) {
                        Id userId = null;
                        List<PropStrength__Group_Member__c> usersInfo = new List<PropStrength__Group_Member__c>();
                        if( req.Assignment_Group__c != null && assGrpMap.containsKey(req.Assignment_Group__c)) {
                            usersInfo = assGrpMap.get(req.Assignment_Group__c).PropStrength__Group_Members__r;
                        }
                        
                        System.debug('usersInfo::'+usersInfo);
                        if(!usersInfo.isEmpty()) {
                            Integer cnt = 1;
                            for(Integer i = 0; i < usersInfo.size(); i++) {
                                if(usersInfo[i].PropStrength__User__c == req.OwnerId && usersInfo.size() > cnt) {
                                    userId = usersInfo[i+1].PropStrength__User__c;
                                } else if(usersInfo[i].PropStrength__User__c == req.OwnerId && usersInfo.size() == cnt) {
                                    userId = usersInfo[0].PropStrength__User__c;
                                }
                                cnt++;
                            }
                            System.debug('userId::'+userId);
                            if(userId != null) {
                                updateEnqList.add(new PropStrength__Request__c(Id = req.Id, Enquiry_Owner_Batch_Update__c = System.now(), OwnerId = userId, Last_Processing_DateTime__c = null));   
                            }
                        }
                    }
                }
            }
        }
        
        System.debug('updateEnqList****');
        System.debug(updateEnqList);
        
        if(!updateEnqList.isEmpty()) {
            update updateEnqList;
        }
    }
    
    //Added by Nishank Manwani on 22 Mar 2024 to update Recent Property Purchase Price Field
    public static void updatePurchasePrice(List<PropStrength__Request__c> newEnquiryList, Map<Id, PropStrength__Request__c> oldEnqMap) {
        Set<Id> recentPropId = new Set<Id>();
        
        for(PropStrength__Request__c enq : newEnquiryList) {
            if(enq.PropStrength__Selected_Property_Ids__c != oldEnqMap.get(enq.Id).PropStrength__Selected_Property_Ids__c || 
               enq.Input_Value__c != oldEnqMap.get(enq.Id).Input_Value__c ||
               enq.Calculated_Value__c != oldEnqMap.get(enq.Id).Calculated_Value__c ||
               enq.Proforma_Invoice_Type__c != oldEnqMap.get(enq.Id).Proforma_Invoice_Type__c ||
               enq.Proforma_Invoice_Sub_Type__c != oldEnqMap.get(enq.Id).Proforma_Invoice_Sub_Type__c) {
                   if(enq.PropStrength__Selected_Property_Ids__c != null) {
                       if(!enq.PropStrength__Selected_Property_Ids__c.contains(',')) {
                           recentPropId.add(enq.PropStrength__Selected_Property_Ids__c);
                       } else {
                           List<Id> propId = enq.PropStrength__Selected_Property_Ids__c.split(',');
                           recentPropId.add(propId[propId.size()-1]);
                       }
                   } else {
                       enq.Recent_Property_Purchase_Price__c = 0;  enq.Oqood_Fee__c = 0;  enq.VAT_amount_applicable_AED__c = 0;
                   }
               }
        }
        
        if(!recentPropId.isEmpty()) {
            Map<Id, Decimal> recentPurchasePrice = new Map<Id, Decimal>();
            Map <Id, PropStrength__Property__c> propMap = new Map <Id, PropStrength__Property__c>([SELECT Id, RecordType.Name, PropStrength__Total_Sales_Consideration__c, PropStrength__Super_Area__c, 
                                                                                                   (SELECT Id, PropStrength__Fixed_Charge__c, PropStrength__Rate_per_unit_Area__c FROM PropStrength__Property_Charges__r) 
                                                                                                   FROM PropStrength__Property__c WHERE Id IN :recentPropId]);
            
            for(PropStrength__Property__c prop : propMap.values()) {
                if(prop.PropStrength__Total_Sales_Consideration__c != null) {
                    recentPurchasePrice.put(prop.Id, prop.PropStrength__Total_Sales_Consideration__c);
                }
                
                if(!prop.PropStrength__Property_Charges__r.isEmpty()) {
                    Decimal total = 0;
                    for(PropStrength__Property_Charges__c prOth : prop.PropStrength__Property_Charges__r) {
                        if(prOth.PropStrength__Rate_per_unit_Area__c != null) {
                            total += (prOth.PropStrength__Rate_per_unit_Area__c * prop.PropStrength__Super_Area__c);
                        } else if(prOth.PropStrength__Fixed_Charge__c != null) {
                            total += prOth.PropStrength__Fixed_Charge__c;
                        }
                    }
                    Decimal alreadyTot = 0;
                    
                    if(recentPurchasePrice.containsKey(prop.Id)) {
                        alreadyTot = recentPurchasePrice.get(prop.Id);
                    }
                    
                    recentPurchasePrice.put(prop.Id, (total + alreadyTot));
                }
            }
            
            System.debug('recentPurchasePrice*****');
            System.debug(recentPurchasePrice);
            
            for(PropStrength__Request__c enq : newEnquiryList) {
                if(enq.PropStrength__Selected_Property_Ids__c != oldEnqMap.get(enq.Id).PropStrength__Selected_Property_Ids__c || enq.Input_Value__c != oldEnqMap.get(enq.Id).Input_Value__c ||  enq.Calculated_Value__c != oldEnqMap.get(enq.Id).Calculated_Value__c ||  enq.Proforma_Invoice_Type__c != oldEnqMap.get(enq.Id).Proforma_Invoice_Type__c || enq.Proforma_Invoice_Sub_Type__c != oldEnqMap.get(enq.Id).Proforma_Invoice_Sub_Type__c) {
                    if(enq.PropStrength__Selected_Property_Ids__c != null) {
                        if(!enq.PropStrength__Selected_Property_Ids__c.contains(',') && recentPurchasePrice.containsKey(enq.PropStrength__Selected_Property_Ids__c)) {
                            enq.Recent_Property_Purchase_Price__c = recentPurchasePrice.get(enq.PropStrength__Selected_Property_Ids__c);
                            enq.Oqood_Fee__c = recentPurchasePrice.get(enq.PropStrength__Selected_Property_Ids__c) - propMap.get(enq.PropStrength__Selected_Property_Ids__c).PropStrength__Total_Sales_Consideration__c;
                            
                            if(enq.Proforma_Invoice_Type__c == 'Unit Price' && enq.Proforma_Invoice_Sub_Type__c == 'Percentage') {
                                if(propMap.get(enq.PropStrength__Selected_Property_Ids__c).RecordType.Name == 'Commercial - Units') {
                                    enq.VAT_amount_applicable_AED__c = enq.Calculated_Value__c * 0.05;
                                }
                            } else if(enq.Proforma_Invoice_Type__c == 'Unit Price' && enq.Proforma_Invoice_Sub_Type__c == 'Amount') {
                                if(propMap.get(enq.PropStrength__Selected_Property_Ids__c).RecordType.Name == 'Commercial - Units') {
                                    enq.VAT_amount_applicable_AED__c = enq.Input_Value__c * 0.05;
                                }
                            } else if(enq.Proforma_Invoice_Type__c == 'Unit Price') {
                                if(propMap.get(enq.PropStrength__Selected_Property_Ids__c).RecordType.Name != 'Commercial - Units') {   enq.VAT_amount_applicable_AED__c = 0;
                                                                                                                                    }
                            } else if(enq.Proforma_Invoice_Type__c == 'DLD Amount') {
                                enq.VAT_amount_applicable_AED__c = 0;
                            } else {
                                enq.VAT_amount_applicable_AED__c = null;
                            }
                        } else {
                            List<Id> propId = enq.PropStrength__Selected_Property_Ids__c.split(',');
                            Id pId = propId[propId.size()-1];
                            
                            if(recentPurchasePrice.containsKey(pId)) {
                                enq.Recent_Property_Purchase_Price__c = recentPurchasePrice.get(pId);
                                enq.Oqood_Fee__c = recentPurchasePrice.get(pId) - propMap.get(pId).PropStrength__Total_Sales_Consideration__c;
                            }
                            
                            if(enq.Proforma_Invoice_Type__c == 'Unit Price' && enq.Proforma_Invoice_Sub_Type__c == 'Percentage') { if(propMap.get(pId).RecordType.Name == 'Commercial - Units') {
                                enq.VAT_amount_applicable_AED__c = enq.Calculated_Value__c * 0.05;
                            }
                                                                                                                                 } else if(enq.Proforma_Invoice_Type__c == 'Unit Price' && enq.Proforma_Invoice_Sub_Type__c == 'Amount') { if(propMap.get(pId).RecordType.Name == 'Commercial - Units') {
                                                                                                                                     enq.VAT_amount_applicable_AED__c = enq.Input_Value__c * 0.05;
                                                                                                                                 }
                                                                                                                                                                                                                                         } else if(enq.Proforma_Invoice_Type__c == 'Unit Price') { if(propMap.get(pId).RecordType.Name != 'Commercial - Units') {
                                                                                                                                                                                                                                             enq.VAT_amount_applicable_AED__c = 0;
                                                                                                                                                                                                                                         }
                                                                                                                                                                                                                                                                                                 } else if(enq.Proforma_Invoice_Type__c == 'DLD Amount') {  enq.VAT_amount_applicable_AED__c = 0;
                                                                                                                                                                                                                                                                                                                                                         } else {
                                                                                                                                                                                                                                                                                                                                                             enq.VAT_amount_applicable_AED__c = null;
                                                                                                                                                                                                                                                                                                                                                         }
                        }
                    }
                }
            }
        }
    }
    
    // 03-04-2024 - Create Day One Tracking and Attampt Tracking when Enquiry Creation
    public static void createDayOneTrack(List<PropStrength__Request__c> newEnquiryList) {
        List<Day_Tracking__c> dayTrackList = new List<Day_Tracking__c>();
        Map<String, String> reqIdToOwnerId = new Map<String, String>();
        Map<String, String> recordTypeNameToId = new Map<String, String>();
        List<Attempt_Tracking__c> attemptTrackingList = new List<Attempt_Tracking__c>();
        Set<String> dayTrackIds = new Set<String>();
        String dayOneAttempt = '';
        List<Lead_Nurturing__mdt> dayOneList = [SELECT Value__c FROM Lead_Nurturing__mdt 
                                                WHERE DeveloperName = 'Day_1' AND Value__c != null LIMIT 1];
        if(dayOneList != null && dayOneList.size() > 0) {
            dayOneAttempt = dayOneList[0].Value__c;
            if(dayOneAttempt.contains(',')) {
                dayOneAttempt = dayOneAttempt.split(',')[0];
            }
        }
        for(RecordType recType : [SELECT Id, Name FROM RecordType 
                                  WHERE sObjectType = 'Attempt_Tracking__c' LIMIT 99]) {
                                      recordTypeNameToId.put(recType.name, recType.id);
                                  }
        for(PropStrength__Request__c req : newEnquiryList) { 
            Day_Tracking__c dayTrack = new Day_Tracking__c();
            dayTrack.Name = 'Day 1';
            dayTrack.Enquiry__c = req.Id;
            dayTrackList.add(dayTrack);
            reqIdToOwnerId.put(req.Id, req.OwnerId);
        }
        if(!dayTrackList.isEmpty()) {
            try {
                Database.SaveResult[] saveDayTrackResult = Database.insert(dayTrackList, false);
                for(Database.SaveResult srDayTrack : saveDayTrackResult) {
                    if(srDayTrack.isSuccess()) {
                        System.debug('===> Task Id: ' + srDayTrack.getId());
                        dayTrackIds.add(String.valueof(srDayTrack.getId()));
                    } else {
                        for(Database.Error errTask : srDayTrack.getErrors()) {
                            System.debug('===> Exception: ' + errTask.getMessage());
                        }
                    }
                }
                if(!dayTrackIds.isEmpty()) {
                    for(Day_Tracking__c dayTR : [SELECT Id, Enquiry__c FROM Day_Tracking__c 
                                                 WHERE Id IN: dayTrackIds]) {
                                                     if(reqIdToOwnerId.containskey(dayTR.Enquiry__c) && 
                                                        !String.isBlank(dayOneAttempt) && 
                                                        recordTypeNameToId.containskey(dayOneAttempt)) {
                                                            String leadOwnerId = reqIdToOwnerId.get(dayTR.Enquiry__c);
                                                            Attempt_Tracking__c attempTR = new Attempt_Tracking__c();
                                                            attempTR.Day_Tracking__c = dayTR.Id;
                                                            attempTR.Name = dayOneAttempt;
                                                            attempTR.RecordTypeId = recordTypeNameToId.get(dayOneAttempt);
                                                            attempTR.Attempt_Sequence__c = '1';
                                                            attempTR.Attempted_By__c = (leadOwnerId != null) ? leadOwnerId : null;
                                                            attemptTrackingList.add(attempTR);
                                                        }
                                                 }
                }
                if(!attemptTrackingList.isEmpty()) {
                    Database.SaveResult[] saveAttemptTrackResult = Database.insert(attemptTrackingList, false);
                    for(Database.SaveResult srAttemptTrack : saveAttemptTrackResult) {
                        if(srAttemptTrack.isSuccess()) {
                            System.debug('===> Attempt Id: ' + srAttemptTrack.getId());
                        } else {
                            for(Database.Error errTR : srAttemptTrack.getErrors()) {
                                System.debug('===> Exception: ' + errTR.getMessage());
                            }
                        }
                    }
                }
            } catch(Exception e) {
                System.debug('===> Exception: ' + e.getMessage());
            }
        }
    }
    
    //Added by Nishank Manwani on 22/04/24 to update Assignment Group field on enquiry
    public static void updateAssignmentGrp(List<PropStrength__Request__c> enqList) {
        List<PropStrength__Assignment_Group_Name__c> grpList = [SELECT Id, Name, 
                                                                (SELECT Id, PropStrength__Criteria__c FROM PropStrength__Assignment_Rule_entries__r) 
                                                                FROM PropStrength__Assignment_Group_Name__c WHERE PropStrength__Active__c = TRUE AND PropStrength__Type__c = 'Enquiry'];
        
        List<PropStrength__Request__c> updEnqList = new List<PropStrength__Request__c>();
        
        for(PropStrength__Request__c enq : enqList) {
            for(PropStrength__Assignment_Group_Name__c grpName : grpList) {
                if(!grpName.PropStrength__Assignment_Rule_entries__r.isEmpty()) {
                    Boolean success = false;
                    for(PropStrength__Assignment_Rule_Entry__c re : grpName.PropStrength__Assignment_Rule_entries__r) {
                        String tempFld = re.PropStrength__Criteria__c;
                        if(!tempFld.contains('AND')) {
                            String temp = tempFld;
                            List<String> words = temp.split('\\s+');
                            String fieldName = words[1].trim();
                            String condition = '';
                            String checkValue = '';
                            
                            if(temp.contains('Equals')) {
                                condition = 'Equals';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                String fldVal = String.valueOf(enq.get(fieldName));
                                
                                if(checkValue.contains(', ')) {
                                    for(String cv : checkValue.split(', ')) {
                                        if(fldVal != null 
                                           && fldVal == cv) {
                                               enq.Assignment_Group__c = grpName.Id;
                                               success = true;
                                               break;
                                           }
                                    }
                                } else {
                                    if(fldVal != null && fldVal == checkValue) { enq.Assignment_Group__c = grpName.Id; success = true;
                                                                                break;
                                                                               }
                                }
                            } else if(temp.contains('Not Equal To')) {
                                condition = 'Not Equal To';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                String fldVal = String.valueOf(enq.get(fieldName));
                                
                                if(checkValue.contains(', ')) {
                                    for(String cv : checkValue.split(', ')) {
                                        if(fldVal != null 
                                           && fldVal != cv) {
                                               enq.Assignment_Group__c = grpName.Id;
                                               success = true;
                                               break;
                                           }
                                    }
                                } else {
                                    if(fldVal != null 
                                       && fldVal != checkValue) {
                                           enq.Assignment_Group__c = grpName.Id;
                                           success = true;
                                           break;
                                       }
                                }
                            } else if(temp.contains('Starts With')) {
                                condition = 'Starts With';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                String fldVal = String.valueOf(enq.get(fieldName));
                                
                                if(checkValue.contains(', ')) {
                                    for(String cv : checkValue.split(', ')) {
                                        if(fldVal != null && fldVal.startsWith(cv)) {
                                            enq.Assignment_Group__c = grpName.Id;
                                            success = true;
                                            break;
                                        }
                                    }
                                } else {
                                    if(fldVal != null && fldVal.startsWith(checkValue)) { enq.Assignment_Group__c = grpName.Id; success = true;
                                                                                         break;
                                                                                        }
                                }
                            } else if(temp.contains('Contains')) {
                                condition = 'Contains';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                String fldVal = String.valueOf(enq.get(fieldName));
                                
                                if(checkValue.contains(', ')) {
                                    for(String cv : checkValue.split(', ')) {
                                        if(fldVal != null && fldVal.contains(cv)) {
                                            enq.Assignment_Group__c = grpName.Id;
                                            success = true;
                                            break;
                                        }
                                    }
                                } else {
                                    if(fldVal != null && fldVal.contains(checkValue)) { enq.Assignment_Group__c = grpName.Id; success = true;
                                                                                       break;
                                                                                      }
                                }
                            } else if(temp.contains('Does Not Contains')) {
                                condition = 'Does Not Contains';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                String fldVal = String.valueOf(enq.get(fieldName));
                                
                                if(checkValue.contains(', ')) { for(String cv : checkValue.split(', ')) {  if(fldVal != null && !fldVal.contains(cv)) {
                                    enq.Assignment_Group__c = grpName.Id;  success = true;
                                    break;
                                }
                                                                                                        }
                                                              } else {
                                                                  if(fldVal != null && !fldVal.contains(checkValue)) { enq.Assignment_Group__c = grpName.Id; success = true;
                                                                                                                      break;
                                                                                                                     }
                                                              }
                            } else if(temp.contains('Less Than')) {
                                condition = 'Less Than';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                if(checkValue != null) {
                                    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PropStrength__Request__c').getDescribe().fields.getMap();
                                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                                    String datatypeOfFld = fieldDescribe.getType().name();
                                    if(!datatypeOfFld.contains('DATE')) {
                                        Decimal fldVal = Decimal.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {
                                            for(String cv : checkValue.split(', ')) {
                                                if(fldVal != null 
                                                   && fldVal < Decimal.valueOf(cv)) {
                                                       enq.Assignment_Group__c = grpName.Id;
                                                       success = true;
                                                       break;
                                                   }
                                            }
                                        } else {
                                            Decimal check = Decimal.valueOf(checkValue);
                                            if(fldVal != null 
                                               && fldVal < check) {
                                                   enq.Assignment_Group__c = grpName.Id;
                                                   success = true;
                                                   break;
                                               }
                                        }
                                    } else if(datatypeOfFld == 'DATE') {
                                        Date fldVal = Date.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {
                                            for(String cv : checkValue.split(', ')) {  if(fldVal != null && fldVal < Date.valueOf(cv)) { enq.Assignment_Group__c = grpName.Id;
                                                                                                                                        success = true;
                                                                                                                                        break;
                                                                                                                                       }
                                                                                    }
                                        } else {
                                            Date check = Date.valueOf(checkValue);
                                            if(fldVal != null && fldVal < check) {
                                                enq.Assignment_Group__c = grpName.Id;
                                                success = true;
                                                break;
                                            }
                                        }
                                    } else if(datatypeOfFld == 'DATETIME') {  DateTime fldVal = DateTime.valueOf(String.valueOf(enq.get(fieldName)));
                                                                            
                                                                            if(checkValue.contains(', ')) {  for(String cv : checkValue.split(', ')) {  if(fldVal != null && fldVal < DateTime.valueOf(cv)) {
                                                                                enq.Assignment_Group__c = grpName.Id;  success = true;
                                                                                break;
                                                                            }
                                                                                                                                                     }
                                                                                                          } else {
                                                                                                              DateTime check = DateTime.valueOf(checkValue);
                                                                                                              if(fldVal != null && fldVal < check) {  enq.Assignment_Group__c = grpName.Id; success = true;
                                                                                                                                                    break;
                                                                                                                                                   }
                                                                                                          }
                                                                           }
                                }
                            } else if(temp.contains('Greater Than')) {
                                condition = 'Greater Than';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                if(checkValue != null) {
                                    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PropStrength__Request__c').getDescribe().fields.getMap();
                                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                                    String datatypeOfFld = fieldDescribe.getType().name();
                                    if(!datatypeOfFld.contains('DATE')) {
                                        Decimal fldVal = Decimal.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {
                                            for(String cv : checkValue.split(', ')) {
                                                if(fldVal != null && fldVal > Decimal.valueOf(cv)) {
                                                    enq.Assignment_Group__c = grpName.Id;  success = true;
                                                    break;
                                                }
                                            }
                                        } else {
                                            Decimal check = Decimal.valueOf(checkValue);
                                            if(fldVal != null && fldVal > check) {
                                                enq.Assignment_Group__c = grpName.Id; success = true;
                                                break;
                                            }
                                        }
                                    } else if(datatypeOfFld == 'DATE') {
                                        Date fldVal = Date.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {  for(String cv : checkValue.split(', ')) {  if(fldVal != null && fldVal > Date.valueOf(cv)) {
                                            enq.Assignment_Group__c = grpName.Id; success = true;
                                            break;
                                        }
                                                                                                                 }
                                                                      } else {
                                                                          Date check = Date.valueOf(checkValue);
                                                                          if(fldVal != null && fldVal > check) {
                                                                              enq.Assignment_Group__c = grpName.Id;
                                                                              success = true;
                                                                              break;
                                                                          }
                                                                      }
                                    } else if(datatypeOfFld == 'DATETIME') {  DateTime fldVal = DateTime.valueOf(String.valueOf(enq.get(fieldName)));
                                                                            
                                                                            if(checkValue.contains(', ')) {
                                                                                for(String cv : checkValue.split(', ')) { if(fldVal != null && fldVal > DateTime.valueOf(cv)) {
                                                                                    enq.Assignment_Group__c = grpName.Id; success = true;
                                                                                    break;
                                                                                }
                                                                                                                        }
                                                                            } else {
                                                                                DateTime check = DateTime.valueOf(checkValue);
                                                                                if(fldVal != null && fldVal > check) { enq.Assignment_Group__c = grpName.Id; success = true;
                                                                                                                      break;
                                                                                                                     }
                                                                            }
                                                                           }
                                }
                            } else if(temp.contains('Less Or Equal')) {
                                condition = 'Less Or Equal';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                if(checkValue != null) {
                                    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PropStrength__Request__c').getDescribe().fields.getMap();
                                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                                    String datatypeOfFld = fieldDescribe.getType().name();
                                    if(!datatypeOfFld.contains('DATE')) {
                                        Decimal fldVal = Decimal.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {
                                            for(String cv : checkValue.split(', ')) {
                                                if(fldVal != null 
                                                   && fldVal <= Decimal.valueOf(cv)) {
                                                       enq.Assignment_Group__c = grpName.Id;
                                                       success = true;
                                                       break;
                                                   }
                                            }
                                        } else {
                                            Decimal check = Decimal.valueOf(checkValue);
                                            if(fldVal != null 
                                               && fldVal <= check) {
                                                   enq.Assignment_Group__c = grpName.Id;
                                                   success = true;
                                                   break;
                                               }
                                        }
                                    } else if(datatypeOfFld == 'DATE') {
                                        Date fldVal = Date.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {
                                            for(String cv : checkValue.split(', ')) {
                                                if(fldVal != null && fldVal <= Date.valueOf(cv)) { enq.Assignment_Group__c = grpName.Id;
                                                                                                  success = true;
                                                                                                  break;
                                                                                                 }
                                            }
                                        } else {
                                            Date check = Date.valueOf(checkValue);
                                            if(fldVal != null && fldVal <= check) {
                                                enq.Assignment_Group__c = grpName.Id;
                                                success = true;
                                                break;
                                            }
                                        }
                                    } else if(datatypeOfFld == 'DATETIME') {
                                        DateTime fldVal = DateTime.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {
                                            for(String cv : checkValue.split(', ')) { if(fldVal != null && fldVal <= DateTime.valueOf(cv)) {
                                                enq.Assignment_Group__c = grpName.Id; success = true;
                                                break;
                                            }
                                                                                    }
                                        } else {
                                            DateTime check = DateTime.valueOf(checkValue);
                                            if(fldVal != null && fldVal <= check) { enq.Assignment_Group__c = grpName.Id;  success = true;
                                                                                   break;
                                                                                  }
                                        }
                                    }
                                }
                            } else if(temp.contains('Greater Or Equal')) {
                                condition = 'Greater Or Equal';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                if(checkValue != null) {
                                    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PropStrength__Request__c').getDescribe().fields.getMap();
                                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                                    String datatypeOfFld = fieldDescribe.getType().name();
                                    if(!datatypeOfFld.contains('DATE')) {
                                        Decimal fldVal = Decimal.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {
                                            for(String cv : checkValue.split(', ')) {
                                                if(fldVal != null && fldVal >= Decimal.valueOf(cv)) {
                                                    enq.Assignment_Group__c = grpName.Id;  success = true;
                                                    break;
                                                }
                                            }
                                        } else {
                                            Decimal check = Decimal.valueOf(checkValue);
                                            if(fldVal != null && fldVal >= check) {
                                                enq.Assignment_Group__c = grpName.Id; success = true;
                                                break;
                                            }
                                        }
                                    } else if(datatypeOfFld == 'DATE') {
                                        Date fldVal = Date.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {
                                            for(String cv : checkValue.split(', ')) {  if(fldVal != null && fldVal >= Date.valueOf(cv)) {  enq.Assignment_Group__c = grpName.Id;
                                                                                                                                         success = true;
                                                                                                                                         break;
                                                                                                                                        }
                                                                                    }
                                        } else {
                                            Date check = Date.valueOf(checkValue);
                                            if(fldVal != null && fldVal >= check) {
                                                enq.Assignment_Group__c = grpName.Id;
                                                success = true;
                                                break;
                                            }
                                        }
                                    } else if(datatypeOfFld == 'DATETIME') {
                                        DateTime fldVal = DateTime.valueOf(String.valueOf(enq.get(fieldName)));
                                        
                                        if(checkValue.contains(', ')) {   for(String cv : checkValue.split(', ')) {  if(fldVal != null && fldVal >= Datetime.valueOf(cv)) {
                                            enq.Assignment_Group__c = grpName.Id; success = true;
                                            break;
                                        }
                                                                                                                  }
                                                                      } else {
                                                                          DateTime check = DateTime.valueOf(checkValue);
                                                                          if(fldVal != null && fldVal >= check) { enq.Assignment_Group__c = grpName.Id; success = true;
                                                                                                                 break;
                                                                                                                }
                                                                      }
                                    }
                                }
                            }  else if(temp.contains('Includes')) {
                                condition = 'Includes';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                String fldVal = String.valueOf(enq.get(fieldName));
                                
                                if(checkValue.contains(', ')) { for(String cv : checkValue.split(', ')) { if(fldVal != null && fldVal.contains(cv)) {
                                    enq.Assignment_Group__c = grpName.Id;
                                    success = true;
                                    break;
                                }
                                                                                                        }
                                                              } else {
                                                                  if(fldVal != null && checkValue != null && fldVal.contains(checkValue)) {
                                                                      enq.Assignment_Group__c = grpName.Id;
                                                                      success = true;
                                                                      break;
                                                                  }
                                                              }
                            }  else if(temp.contains('Excludes')) {
                                condition = 'Excludes';
                                checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                
                                String fldVal = String.valueOf(enq.get(fieldName));
                                
                                if(checkValue.contains(', ')) {
                                    for(String cv : checkValue.split(', ')) {
                                        if(fldVal != null && !fldVal.contains(cv)) {
                                            enq.Assignment_Group__c = grpName.Id;
                                            success = true;
                                            break;
                                        }
                                    }
                                } else {
                                    if(fldVal != null && checkValue != null && !fldVal.contains(checkValue)) { enq.Assignment_Group__c = grpName.Id; success = true;
                                                                                                              break;
                                                                                                             }
                                }
                            }
                        } else if(tempFld.contains('AND')) {
                            List<String> conditions = tempFld.split(' AND ');
                            System.debug('conditions****');
                            System.debug(conditions);
                            Integer allCondTrue = 0;
                            for(String temp : conditions) {
                                temp = temp.trim();
                                List<String> words = temp.split('\\s+');
                                String fieldName = words[1].trim();
                                String condition = '';
                                String checkValue = '';
                                
                                if(temp.contains('Equals')) {
                                    condition = 'Equals';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    String fldVal = String.valueOf(enq.get(fieldName));
                                    
                                    if(checkValue.contains(', ')) { for(String cv : checkValue.split(', ')) { if(fldVal != null && fldVal == cv) {
                                        allCondTrue++;
                                        break;
                                    }
                                                                                                            }
                                                                  } else {
                                                                      if(fldVal != null && fldVal == checkValue) {
                                                                          allCondTrue++;
                                                                      }
                                                                  }
                                } else if(temp.contains('Not Equal To')) {
                                    condition = 'Not Equal To';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    String fldVal = String.valueOf(enq.get(fieldName));
                                    
                                    if(checkValue.contains(', ')) {
                                        for(String cv : checkValue.split(', ')) {
                                            if(fldVal != null && fldVal != cv) {
                                                allCondTrue++;
                                                break;
                                            }
                                        }
                                    } else {
                                        if(fldVal != null && fldVal != checkValue) {
                                            allCondTrue++;
                                        }
                                    }
                                } else if(temp.contains('Starts With')) {
                                    condition = 'Starts With';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    String fldVal = String.valueOf(enq.get(fieldName));
                                    
                                    if(checkValue.contains(', ')) {
                                        for(String cv : checkValue.split(', ')) {
                                            if(fldVal != null && fldVal.startsWith(cv)) {
                                                allCondTrue++;
                                                break;
                                            }
                                        }
                                    } else {
                                        if(fldVal != null && fldVal.startsWith(checkValue)) {
                                            allCondTrue++;
                                        }
                                    }
                                } else if(temp.contains('Contains')) {
                                    condition = 'Contains';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    String fldVal = String.valueOf(enq.get(fieldName));
                                    
                                    if(checkValue.contains(', ')) {
                                        for(String cv : checkValue.split(', ')) {
                                            if(fldVal != null && fldVal.contains(cv)) {
                                                allCondTrue++;
                                                break;
                                            }
                                        }
                                    } else {
                                        if(fldVal != null && fldVal.contains(checkValue)) {
                                            allCondTrue++;
                                        }
                                    }
                                } else if(temp.contains('Does Not Contains')) {
                                    condition = 'Does Not Contains';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    String fldVal = String.valueOf(enq.get(fieldName));
                                    
                                    if(checkValue.contains(', ')) {
                                        for(String cv : checkValue.split(', ')) {
                                            if(fldVal != null && !fldVal.contains(cv)) {
                                                allCondTrue++;
                                                break;
                                            }
                                        }
                                    } else {
                                        if(fldVal != null && !fldVal.contains(checkValue)) {
                                            allCondTrue++;
                                        }
                                    }
                                } else if(temp.contains('Less Than')) {
                                    condition = 'Less Than';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    if(checkValue != null) {
                                        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PropStrength__Request__c').getDescribe().fields.getMap();
                                        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                                        String datatypeOfFld = fieldDescribe.getType().name();
                                        if(!datatypeOfFld.contains('DATE')) {
                                            Decimal fldVal = Decimal.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) { for(String cv : checkValue.split(', ')) { if(fldVal != null && fldVal < Decimal.valueOf(cv)) {
                                                allCondTrue++;
                                                break;
                                            }
                                                                                                                    }
                                                                          } else {
                                                                              Decimal check = Decimal.valueOf(checkValue);
                                                                              if(fldVal != null && fldVal < check) {
                                                                                  allCondTrue++;
                                                                              }
                                                                          }
                                        } else if(datatypeOfFld == 'DATE') {
                                            Date fldVal = Date.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null && fldVal < Date.valueOf(cv)) {
                                                        allCondTrue++;
                                                        break;
                                                    }
                                                }
                                            } else {
                                                Date check = Date.valueOf(checkValue);
                                                if(fldVal != null && fldVal < check) {
                                                    allCondTrue++;
                                                }
                                            }
                                        } else if(datatypeOfFld == 'DATETIME') {
                                            DateTime fldVal = DateTime.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null && fldVal < DateTime.valueOf(cv)) {
                                                        allCondTrue++;
                                                        break;
                                                    }
                                                }
                                            } else {
                                                DateTime check = DateTime.valueOf(checkValue);
                                                if(fldVal != null && fldVal < check) {
                                                    allCondTrue++;
                                                }
                                            }
                                        }
                                    }
                                } else if(temp.contains('Greater Than')) {
                                    condition = 'Greater Than';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    if(checkValue != null) {
                                        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PropStrength__Request__c').getDescribe().fields.getMap();
                                        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                                        String datatypeOfFld = fieldDescribe.getType().name();
                                        if(!datatypeOfFld.contains('DATE')) {
                                            Decimal fldVal = Decimal.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null && fldVal > Decimal.valueOf(cv)) {
                                                        allCondTrue++;
                                                        break;
                                                    }
                                                }
                                            } else {
                                                Decimal check = Decimal.valueOf(checkValue);
                                                if(fldVal != null && fldVal > check) {
                                                    allCondTrue++;
                                                }
                                            }
                                        } else if(datatypeOfFld == 'DATE') {
                                            Date fldVal = Date.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null && fldVal > Date.valueOf(cv)) {
                                                        allCondTrue++;
                                                        break;
                                                    }
                                                }
                                            } else {
                                                Date check = Date.valueOf(checkValue);
                                                if(fldVal != null && fldVal > check) {
                                                    allCondTrue++;
                                                }
                                            }
                                        } else if(datatypeOfFld == 'DATETIME') {
                                            DateTime fldVal = DateTime.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null && fldVal > DateTime.valueOf(cv)) {
                                                        allCondTrue++;
                                                        break;
                                                    }
                                                }
                                            } else {
                                                DateTime check = DateTime.valueOf(checkValue);
                                                if(fldVal != null && fldVal > check) {
                                                    allCondTrue++;
                                                }
                                            }
                                        }
                                    }
                                } else if(temp.contains('Less Or Equal')) {
                                    condition = 'Less Or Equal';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    if(checkValue != null) {
                                        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PropStrength__Request__c').getDescribe().fields.getMap();
                                        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                                        String datatypeOfFld = fieldDescribe.getType().name();
                                        if(!datatypeOfFld.contains('DATE')) {
                                            Decimal fldVal = Decimal.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null && fldVal <= Decimal.valueOf(cv)) {
                                                        allCondTrue++;
                                                        break;
                                                    }
                                                }
                                            } else {
                                                Decimal check = Decimal.valueOf(checkValue);
                                                if(fldVal != null && fldVal <= check) {
                                                    allCondTrue++;
                                                }
                                            }
                                        } else if(datatypeOfFld == 'DATE') {
                                            Date fldVal = Date.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null && fldVal <= Date.valueOf(cv)) {
                                                        allCondTrue++;
                                                        break;
                                                    }
                                                }
                                            } else {
                                                Date check = Date.valueOf(checkValue);
                                                if(fldVal != null && fldVal <= check) {
                                                    allCondTrue++;
                                                }
                                            }
                                        } else if(datatypeOfFld == 'DATETIME') {
                                            DateTime fldVal = DateTime.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null && fldVal <= DateTime.valueOf(cv)) {
                                                        allCondTrue++;
                                                        break;
                                                    }
                                                }
                                            } else {
                                                DateTime check = DateTime.valueOf(checkValue);
                                                if(fldVal != null && fldVal <= check) {
                                                    allCondTrue++;
                                                }
                                            }
                                        }
                                    }
                                } else if(temp.contains('Greater Or Equal')) {
                                    condition = 'Greater Or Equal';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    if(checkValue != null) {
                                        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PropStrength__Request__c').getDescribe().fields.getMap();
                                        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                                        String datatypeOfFld = fieldDescribe.getType().name();
                                        if(!datatypeOfFld.contains('DATE')) {
                                            Decimal fldVal = Decimal.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null && fldVal >= Decimal.valueOf(cv)) {
                                                        allCondTrue++; 
                                                        break;
                                                    }
                                                }
                                            } else {
                                                Decimal check = Decimal.valueOf(checkValue);
                                                if(fldVal != null && fldVal >= check) {
                                                    allCondTrue++;
                                                }
                                            }
                                        } else if(datatypeOfFld == 'DATE') {
                                            Date fldVal = Date.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null 
                                                       && fldVal >= Date.valueOf(cv)) {
                                                           allCondTrue++;
                                                           break;
                                                       }
                                                }
                                            } else {
                                                Date check = Date.valueOf(checkValue);
                                                if(fldVal != null 
                                                   && fldVal >= check) {
                                                       allCondTrue++;
                                                   }
                                            }
                                        } else if(datatypeOfFld == 'DATETIME') {
                                            DateTime fldVal = DateTime.valueOf(String.valueOf(enq.get(fieldName)));
                                            
                                            if(checkValue.contains(', ')) {
                                                for(String cv : checkValue.split(', ')) {
                                                    if(fldVal != null 
                                                       && fldVal >= Datetime.valueOf(cv)) {
                                                           allCondTrue++;
                                                           break;
                                                       }
                                                }
                                            } else {
                                                DateTime check = DateTime.valueOf(checkValue);
                                                if(fldVal != null 
                                                   && fldVal >= check) {
                                                       allCondTrue++;
                                                   }
                                            }
                                        }
                                    }
                                }  else if(temp.contains('Includes')) {
                                    condition = 'Includes';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    String fldVal = String.valueOf(enq.get(fieldName));
                                    
                                    if(checkValue.contains(', ')) {
                                        for(String cv : checkValue.split(', ')) {
                                            if(fldVal != null 
                                               && fldVal.contains(cv)) {
                                                   allCondTrue++;
                                                   break;
                                               }
                                        }
                                    } else {
                                        if(fldVal != null && checkValue != null && fldVal.contains(checkValue)) {
                                            allCondTrue++;
                                        }
                                    }
                                }  else if(temp.contains('Excludes')) {
                                    condition = 'Excludes';
                                    checkValue = temp.substring(temp.indexOf(condition)+condition.length(), temp.length()-1).trim();
                                    
                                    String fldVal = String.valueOf(enq.get(fieldName));
                                    
                                    if(checkValue.contains(', ')) {
                                        for(String cv : checkValue.split(', ')) {
                                            if(fldVal != null && !fldVal.contains(cv)) { allCondTrue++;
                                                                                        break;
                                                                                       }
                                        }
                                    } else { if(fldVal != null && checkValue != null && !fldVal.contains(checkValue)) {
                                        allCondTrue++;
                                    }
                                           }
                                }
                            }
                            
                            System.debug('allCondTrue****');
                            System.debug(allCondTrue);
                            
                            if(allCondTrue == conditions.size()) { enq.Assignment_Group__c = grpName.Id; success = true;
                                                                  break;
                                                                 }
                        }
                    }
                    if(success) {
                        break;
                    }
                }
            }
        }
    }
    
    // Gourav Gour 29/04/2024 Send Email For Duplicate Enquiry
    public static void sendMailForDuplicateEnq(List<PropStrength__Request__c> newList, Map<Id, PropStrength__Request__c> newEnqMap){
        Set<Id> conId = new Set<Id>();
        Set<Id> enqId = new Set<Id>();
        Map<ID, User> userMap = new Map<ID, User>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(PropStrength__Request__c req : newList){
            if(req.PropStrength__Request_Status__c == 'Site Visit Done' && req.PropStrength__Primary_Contact__c != null){
                conId.add(req.PropStrength__Primary_Contact__c);
            }
        }
        if(!conId.isEmpty()) {
            Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, (SELECT Id, OwnerId, Assignment_Group__c FROM PropStrength__Requests__r WHERE PropStrength__Request_Status__c = 'Site Visit Done' AND Id NOT IN :newEnqMap.keySet() ORDER BY CreatedDate DESC) FROM Contact WHERE Id IN :conId]);
            for(PropStrength__Request__c req : newList) {
                if(req.PropStrength__Primary_Contact__c != null && !contMap.isEmpty() && contMap.containsKey(req.PropStrength__Primary_Contact__c) && !contMap.get(req.PropStrength__Primary_Contact__c).PropStrength__Requests__r.isEmpty()) {
                    enqId.add(req.Id);
                }   
            }
        }
        for(PropStrength__Request__c enq : [SELECT Id, PropStrength__Primary_Contact__r.Name, Name, PropStrength__Request_Source__c FROM PropStrength__Request__c WHERE Id=:enqId]){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new list<String>{'sfc.aravindan@sobharealty.com'});
            String sub = 'Duplicate Enquiry Alert: '+ enq.PropStrength__Primary_Contact__r.Name; email.setSubject(sub);
            String body='Dear User, \n \nThis is to inform you that a duplicate enquiry has been created in the system under the contact ('+enq.PropStrength__Primary_Contact__r.Name+'), details are a below.\n \nContact Name : '+enq.PropStrength__Primary_Contact__r.Name +'\nEnquiry ID : '+ enq.name+'\nEnquiry Source : '+ enq.PropStrength__Request_Source__c+'\n\nThank you,\nSobha';
            email.setPlainTextBody(body);
            mails.add(email);
        }
        if(mails.size() > 0){ List<Messaging.SendEmailResult> mrs= Messaging.sendEmail(mails);
                            }
    }
    public static void updateNewEnquirySource(List<PropStrength__Request__c> newList, Map<Id, PropStrength__Request__c> oldEnqMap) {
        Set<Id> enqForApproval = new Set<Id>();
        for(PropStrength__Request__c enq : newList) {
            if(enq.PropStrength__Enquiry_Type__c != oldEnqMap.get(enq.Id).PropStrength__Enquiry_Type__c || enq.Broker_Type__c != oldEnqMap.get(enq.Id).Broker_Type__c || enq.PropStrength__Request_Source__c != oldEnqMap.get(enq.Id).PropStrength__Request_Source__c || enq.Enquiry_Sub_Source__c != oldEnqMap.get(enq.Id).Enquiry_Sub_Source__c) {
                String newEnqSource = '';
                if(enq.PropStrength__Enquiry_Type__c != null || enq.PropStrength__Enquiry_Type__c != '') {
                    newEnqSource = newEnqSource+ 'EnquiryType:'+enq.PropStrength__Enquiry_Type__c+';';
                }
                else {
                    newEnqSource = newEnqSource+ 'EnquiryType:;';
                }
                if(enq.Broker_Type__c != null || enq.Broker_Type__c != '') {
                    newEnqSource = newEnqSource+ 'BrokerType:'+enq.Broker_Type__c+';';
                }
                else { newEnqSource = newEnqSource+ 'BrokerType:;';
                     }
                if(enq.PropStrength__Request_Source__c != null || enq.PropStrength__Request_Source__c != '') {
                    newEnqSource = newEnqSource+ 'EnquirySource:'+enq.PropStrength__Request_Source__c+';';
                }
                else {newEnqSource = newEnqSource+ 'EnquirySource:;';
                     }
                if(enq.Enquiry_Sub_Source__c != null || enq.Enquiry_Sub_Source__c != '') {
                    newEnqSource = newEnqSource+ 'EnquirySubSource:'+enq.Enquiry_Sub_Source__c+';';
                }
                else {
                    newEnqSource = newEnqSource+ 'EnquirySubSource:;';
                }
                enq.New_Enquiry_Source_Values__c = newEnqSource;
                enqForApproval.add(enq.Id);
                enq.Update_New_Enquiry_Source__c = false;
                enq.PropStrength__Enquiry_Type__c = oldEnqMap.get(enq.Id).PropStrength__Enquiry_Type__c;
                enq.Broker_Type__c = oldEnqMap.get(enq.Id).Broker_Type__c;
                enq.PropStrength__Request_Source__c = oldEnqMap.get(enq.Id).PropStrength__Request_Source__c;
                enq.Enquiry_Sub_Source__c = oldEnqMap.get(enq.Id).Enquiry_Sub_Source__c;
            }
        }
        if(!enqForApproval.isEmpty()) {
            /*for(Id enqId : enqForApproval) {
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Submitting Enquiry for Enquiry Source Update.');
req1.setObjectId(enqId);
req1.setProcessDefinitionNameOrId('Enquiry_Source_Change');
req1.setSkipEntryCriteria(true);  
Approval.ProcessResult result = Approval.process(req1);
}*/
        }
    }
    public static void updateEnquirySourceAfterApproval(List<PropStrength__Request__c> newList, Map<Id, PropStrength__Request__c> oldEnqMap) {
        List<PropStrength__Request__c> enqSourceToUpdate = new List<PropStrength__Request__c>();
        for(PropStrength__Request__c enq : newList) {
            if(enq.Update_New_Enquiry_Source__c && !oldEnqMap.get(enq.Id).Update_New_Enquiry_Source__c && enq.New_Enquiry_Source_Values__c != null) {
                enq.PropStrength__Enquiry_Type__c = enq.New_Enquiry_Source_Values__c.split(';')[0].split(':')[1] != 'null' ? enq.New_Enquiry_Source_Values__c.split(';')[0].split(':')[1] : '';
                enq.Broker_Type__c = enq.New_Enquiry_Source_Values__c.split(';')[1].split(':')[1] != 'null' ? enq.New_Enquiry_Source_Values__c.split(';')[1].split(':')[1] : '';
                enq.PropStrength__Request_Source__c = enq.New_Enquiry_Source_Values__c.split(';')[2].split(':')[1] != 'null' ? enq.New_Enquiry_Source_Values__c.split(';')[2].split(':')[1] : '';
                enq.Enquiry_Sub_Source__c = enq.New_Enquiry_Source_Values__c.split(';')[3].split(':')[1] != 'null' ? enq.New_Enquiry_Source_Values__c.split(';')[3].split(':')[1] : '';
                enq.New_Enquiry_Source_Values__c = null;
            }
        }
    }
    
    //Added by Nishank Manwani on 08-Jul-2024 to give contact's edit permission
    /*public static void contactPermission(List<PropStrength__Request__c> enqList, Map<Id, PropStrength__Request__c> enqOldMap) {
Map<Id, List<Id>> contOwnerIdMap = new Map<Id, List<Id>>();
Set<Id> contactId = new Set<Id>();

for(PropStrength__Request__c enq : enqList) {
if(enqOldMap != null) {
if(enqOldMap.get(enq.Id).OwnerId != enq.OwnerId || enqOldMap.get(enq.Id).PropStrength__Primary_Contact__c != enq.PropStrength__Primary_Contact__c) {
if(!contOwnerIdMap.containsKey(enq.OwnerId)) {
contOwnerIdMap.put(enq.OwnerId, new List<Id>{enq.PropStrength__Primary_Contact__c});
} else {
contOwnerIdMap.get(enq.OwnerId).add(enq.PropStrength__Primary_Contact__c);
}
contactId.add(enq.PropStrength__Primary_Contact__c);
}
} else if(enq.PropStrength__Primary_Contact__c != null) {
if(!contOwnerIdMap.containsKey(enq.OwnerId)) {
contOwnerIdMap.put(enq.OwnerId, new List<Id>{enq.PropStrength__Primary_Contact__c});
} else {
contOwnerIdMap.get(enq.OwnerId).add(enq.PropStrength__Primary_Contact__c);
}
contactId.add(enq.PropStrength__Primary_Contact__c);
}
}

if(!contOwnerIdMap.isEmpty() && !contactId.isEmpty()) {
List<AccountShare> shareContRec = new List<AccountShare>();

for(Contact cont : [SELECT Id, AccountId FROM Contact WHERE Id IN :contactId]) {
for(Id userId : contOwnerIdMap.keySet()) {
if(contOwnerIdMap.get(userId).contains(cont.Id) && cont.AccountId != null) {
shareContRec.add(new AccountShare(AccountId = cont.AccountId, UserOrGroupId = userId, ContactAccessLevel='Edit', OpportunityAccessLevel='Read', AccountAccessLevel = 'Edit'));
break;
}
}
} 

if(!shareContRec.isEmpty()) {
insert shareContRec;
}
}
}*/
    
    //Added by Nishank Manwani on 09-Jul-2024 to update owner of contact as per enquiry owner
    public static void updateContactOwner(List<PropStrength__Request__c> enqList, Map<Id, PropStrength__Request__c> newMapEnq) {
        List<Contact> updateContactOwnerList = new List<Contact>();
        
        Map<Id, PropStrength__Request__c> enqMap = new Map<Id, PropStrength__Request__c>([SELECT Id, 
                                                                                          (SELECT Id FROM Visitor_Registrations__r), 
                                                                                          (SELECT Id FROM Site_Visit_Forms__r) 
                                                                                          FROM PropStrength__Request__c WHERE Id IN :newMapEnq.keySet()]);
        
        for(PropStrength__Request__c enq : enqList) {
            if(enq.PropStrength__Primary_Contact__c != null && enqMap.get(enq.Id).Visitor_Registrations__r.isEmpty() && enqMap.get(enq.Id).Site_Visit_Forms__r.isEmpty()) {
                updateContactOwnerList.add(new Contact(Id=enq.PropStrength__Primary_Contact__c, OwnerId = enq.OwnerId));
            }
        }
        
        if(!updateContactOwnerList.isEmpty()) {
            update updateContactOwnerList;
        }
    }
    
    public class requestBodyWrapper{
        String firstName;
        String lastName;
        String email;
        String dialCode;
        String mobile;
        String source;
        String password;
    }
    
    public static void addBrokerAccount(List<PropStrength__Request__c> newList, Map<id,PropStrength__Request__c> oldMap){
        Set<id> accountIds = new Set<Id>();
        // insert
        if(oldMap == null){
            for(PropStrength__Request__c req : newList) {
                if(req.PropStrength__Broker_Account__c != null){ accountIds.add(req.PropStrength__Broker_Account__c);
                                                               }
            }
            
            Map<Id,String> accountMap = new Map<Id,String>();
            List<Account> accList = [select id,PropStrength__Active__c from Account where id in:accountIds];
            for(Account acc : accList ){ accountMap.put(acc.Id,acc.PropStrength__Active__c);               
                                       }
            
            for(PropStrength__Request__c req : newList) {
                if(req.PropStrength__Broker_Account__c != null){ if(!(accountMap.get(req.PropStrength__Broker_Account__c)=='Yes')){ req.addError('Please select active Broker Account');
                                                                                                                                  }
                                                               }
            }
        }
        // update
        else{
            List<PropStrength__Request__c> newlist2 = new List<PropStrength__Request__c>();
            for(PropStrength__Request__c req : newList) { 
                if(oldMap.get(req.id).PropStrength__Broker_Account__c != req.PropStrength__Broker_Account__c && req.PropStrength__Broker_Account__c != null){
                    newlist2.add(req);   
                }
            }
            
            for(PropStrength__Request__c req : newlist2) { if(req.PropStrength__Broker_Account__c != null){ accountIds.add(req.PropStrength__Broker_Account__c);
                                                                                                          }
                                                         }
            
            Map<Id,String> accountMap = new Map<Id,String>();
            List<Account> accList = [select id,PropStrength__Active__c from Account where id in:accountIds];
            for(Account acc : accList ){ accountMap.put(acc.Id,acc.PropStrength__Active__c);               
                                       }
            
            for(PropStrength__Request__c req : newlist2) {
                if(req.PropStrength__Broker_Account__c != null){
                    if(!(accountMap.get(req.PropStrength__Broker_Account__c)=='Yes')){ req.addError('Please select active Broker Account');
                                                                                     }
                }
            }
        }
    }
    public static void SendDataForWebEngageService(List<PropStrength__Request__c> enqList, Map<Id, PropStrength__Request__c> oldEnqMap) {
        Set<Id> enqIds = new Set<Id>();
        Map<Id, String> forLeadApiEnquiry = new Map<Id, String>();
        Map<Id, String> forEventApiEnquiry = new Map<Id, String>();
        Schema.FieldSet fieldSet = Schema.SObjectType.PropStrength__Request__c.FieldSets.Web_Engage;
        Set<String> fieldSetFields = new Set<String>();
        for (Schema.FieldSetMember field : fieldSet.getFields()) {
            fieldSetFields.add(field.getFieldPath());
            System.debug('=====>' + fieldSetFields);
        }
        
        for(PropStrength__Request__c enq : enqList) {
            if(oldEnqMap == null && !enq.Re_Enquiry__c ) {
                enqIds.add(enq.Id);
                forLeadApiEnquiry.put(enq.Id, 'New');
                forEventApiEnquiry.put(enq.Id, 'Lead Created');
            }
            else if(oldEnqMap == null && enq.Re_Enquiry__c) {
                enqIds.add(enq.Id);
                forEventApiEnquiry.put(enq.Id, 'Re-enquiry');
            }
            else if(oldEnqMap != null) {
                PropStrength__Request__c oldEnq = oldEnqMap.get(enq.Id);
                for (String field : fieldSetFields) {
                    if (enq.get(field) != oldEnq.get(field)) {
                        enqIds.add(enq.Id);forLeadApiEnquiry.put(enq.Id, 'Enqury Update');
                        break;
                    }
                }
                if (enq.PropStrength__Request_Status__c != oldEnq.PropStrength__Request_Status__c && (enq.PropStrength__Request_Status__c == 'Qualified' || enq.PropStrength__Request_Status__c == 'Unqualified' || enq.PropStrength__Request_Status__c == 'Closed/ Lost' )){
                    String eventName =  enq.PropStrength__Request_Status__c == 'Qualified' ? 'Lead Qualified' : (enq.PropStrength__Request_Status__c == 'Unqualified' || enq.PropStrength__Request_Status__c == 'Closed/ Lost' ) ? 'Lead Lost' : 'Lead Disposition';
                    forEventApiEnquiry.put(enq.Id, eventName); enqIds.add(enq.Id);               
                }
                
                else if (enq.PropStrength__Request_Status__c != oldEnq.PropStrength__Request_Status__c){
                    forEventApiEnquiry.put(enq.Id, 'Lead Disposition'); enqIds.add(enq.Id);
                }
            }
        }
        if(!enqIds.isEmpty()) {
            Map<Id, PropStrength__Request__c> enqLatestMap = new Map<Id, PropStrength__Request__c>(
                [SELECT Id, is_Opportunity__c, Timezone__c, IP_Address__c, GCLID__c, Re_Enquiry__c, Facebook_Adset_Name__c, Platform__c, Facebook_Page_Name__c, Gender__c, Preferred_Method_of_Contact__c, 
                 Reason_For_Purchase__c, Primary_City__c, How_Many_Bedroomspicklist__c, How_Many_Bedrooms__c, Client_Type__c, Preferred_City_of_Interestpicklist__c, Preferred_City_of_Interest__c, 
                 Lead_Rating__c, Mortage_Required__c, Interested_In__c, Possession_Requirement__c, Financing_Details__c, Qualified_Not_Qualified__c,Presentation_Done__c, Lead_Month__c, Lead_Id__c, 
                 Contacted__c, Last_Call_Attempt_Status__c, Enquiry_Source__c, Project_Type__c, Website_Language__c, Reason_For_Lost__c, First_Call_Attempt_Status__c, UTM_Content__c, Adgroup__c, 
                 Placement__c, Leadgen_Form_ID__c, Stand_Lead_Location__c, Are_you_looking_for__c, Facebook_Ad_ID__c, Budgett__c, Leadgen_Page_ID__c, Specific_Location_in_the_City__c, Opportunity_Value__c, 
                 FOLLOW_UP_1st__c, FOLLOW_UP_2nd__c, Willing_to_meet_this_week__c, Estimated_Timeline_for_Purchase__c, When_you_re_looking_to_buy__c, Re_Enquiry_Count__c, Time_of_Visit__c, UTM_Language__c, 
                 UTM_Country__c, UTM_Company__c, PropStrength__Request_Status__c, Type_Investment_Or_Self_Use__c, Level_Warm_Or_Hot__c, FOLLOW_UP_3rd__c, Would_you_like_to_invest_in_Dubai_Real_E__c, 
                 Meeting_Type__c, PropStrength__Primary_Contact__c, PropStrength__Primary_Contact__r.FirstName, PropStrength__Primary_Contact__r.Email, PropStrength__Primary_Contact__r.Phone, 
                 PropStrength__Primary_Contact__r.Country__c, PropStrength__Primary_Contact__r.City__c, PropStrength__Primary_Contact__r.PropStrength__Nationality__c, PropStrength__Primary_Contact__r.PropStrength__Languages__c, 
                 PropStrength__Primary_Contact__r.Salutation, PropStrength__Primary_Contact__r.PropStrength__Resident_Status__c, PropStrength__Primary_Contact__r.PropStrength__Profession__c, PropStrength__Primary_Contact__r.mobilePhone, Legacy_ID__c,
                 PropStrength__Primary_Contact__r.Legacy_ID__c,PropStrength__Primary_Contact__r.MailingCity, PropStrength__Primary_Contact__r.MailingCountry, PropStrength__Primary_Contact__r.LastName, 
                 Owner_Profile__c, Purchased_in_the_preferred_City__c
                 FROM PropStrength__Request__c
                 WHERE Id IN :enqIds]);
            if(!System.isBatch() && !System.isFuture() && !System.isQueueable()) {
                for(Id enqId : forLeadApiEnquiry.keySet()) {
                    if(enqLatestMap.containsKey(enqId)) {
                        WebEngageServiceEnquiryContactHandler.userPostAPI(JSON.serialize(enqLatestMap.get(enqId)));
                    }
                }
                for(Id enqId : forEventApiEnquiry.keySet()) {
                    if(enqLatestMap.containsKey(enqId)) {
                        WebEngageServiceEnquiryContactHandler.enquiryPostAPI(JSON.serialize(enqLatestMap.get(enqId)), forEventApiEnquiry.get(enqId));
                    }
                }
            } 
            
        }
    }
    
    public static void changeOwnerToMallStandManager(List<PropStrength__Request__c> enqList){
        system.debug('inside changeOwnerToMallStandManager ');
        runOnce = true;
        Set<Id> contactIds = new Set<Id>();
        
        for(PropStrength__Request__c enq : enqList){            
            contactIds.add(enq.PropStrength__Primary_Contact__c);            
        }
        system.debug('contactIds ++'+contactIds);
        Set<Id> conIds2 = new Set<Id>();
        if(!contactIds.isEmpty()) {
            Map<Id, Contact> contMap = new Map<Id, Contact>([SELECT Id, (SELECT Id, OwnerId, Owner.IsActive, Assignment_Group__c FROM PropStrength__Requests__r where PropStrength__Request_Source__c = 'Stand Leads' limit 1) FROM Contact WHERE Id IN :contactIds]);
            List<PropStrength__Request__c> updateEnqList = new List<PropStrength__Request__c>();     
            system.debug('conifs++'+ conIds2);
            List<PropStrength__Assignment_Group_Name__c> grps =  [select id, (Select id,PropStrength__User__c  from PropStrength__Group_Members__r) from  PropStrength__Assignment_Group_Name__c where Name = 'Mall Stand Manager'];
            if(grps.size() > 0){
                PropStrength__Assignment_Group_Name__c grp = grps[0];
                if(grp != null && grp.PropStrength__Group_Members__r != null){
                    Id usrid = grp.PropStrength__Group_Members__r[0].PropStrength__User__c;
                    for(PropStrength__Request__c enq : enqList){                
                        if(contMap.containsKey(enq.PropStrength__Primary_Contact__c) && contMap.get(enq.PropStrength__Primary_Contact__c).PropStrength__Requests__r.size() > 0){
                            updateEnqList.add(new PropStrength__Request__c(Id = enq.Id, OwnerId = usrid));
                        }           
                    }            
                    system.debug('conhgvhifs++'+ updateEnqList);
                    if(!updateEnqList.isEmpty()) {
                        update updateEnqList;
                    }
                }
                
            }
            
            
            
        }
    }
    public static void giveAccessOfRecord(List<PropStrength__Request__c> enqList, Map< id, PropStrength__Request__c> oldMap){
        Map<Id, Id> enqSalesManagerMap = new Map<Id,Id>();
        Set<Id> enqIdsSet = new Set<Id>();
        for(PropStrength__Request__c enq : enqList){
            if(oldMap == null && enq.Sales_Manager__c != null || (oldmap != null &&  enq.Sales_Manager__c != null && oldMap.get(enq.id).Sales_Manager__c != enq.Sales_Manager__c)){
                enqSalesManagerMap.put(enq.id, enq.Sales_Manager__c);
            }
            
            if(oldmap != null &&  oldMap.get(enq.id).Sales_Manager__c != null && oldMap.get(enq.id).Sales_Manager__c != enq.Sales_Manager__c){
                
                enqIdsSet.add(enq.id);
                
            }
        }
        
        if(enqIdsSet.size()>0){
            List<PropStrength__Request__Share> recordsToDelete = [SELECT Id 
                                                                  FROM PropStrength__Request__Share 
                                                                  WHERE ParentId IN :enqIdsSet ];
            
            if(!recordsToDelete.isEmpty()){
                try{
                    Database.Delete(recordsToDelete, false);
                }
                catch(Exception e ){
                    system.debug(' exception here');
                }
            }
        }
        
        if(enqSalesManagerMap.size()>0){
            List<PropStrength__Request__Share> jobList = new List<PropStrength__Request__Share>();
            for(Id enqid : enqSalesManagerMap.keyset()){
                PropStrength__Request__Share jobShr  = new PropStrength__Request__Share();
                jobShr.ParentId = enqid;
                
                jobShr.UserOrGroupId = enqSalesManagerMap.get(enqid);
                
                jobShr.AccessLevel = 'Read';
                
                jobShr.AccessLevel = 'Edit';
                
                jobList.add(jobShr);
                
                
            }
            if(jobList.size()>0){
                try{
                    Database.SaveResult[] lsr = Database.insert(jobList,false);
                }
                catch(Exception e ){
                    system.debug(' exception here');
                }
                
            }
            
        }
        
        
        
    }

    //Added by Nishank Manwani on 12-Sept-2024 to dont update specific fields for sale profile
    public static void validationSalesProfile(List<PropStrength__Request__c> enqList, Map<Id, PropStrength__Request__c> oldEnqMap) {
        List<String> profileNameList = new List<String>();

        if(System.Label.Enquiry_Validation_For_Sales_Profile.contains(',')) {
            profileNameList.addAll(System.Label.Enquiry_Validation_For_Sales_Profile.split(','));
        } else {
            profileNameList.add(System.Label.Enquiry_Validation_For_Sales_Profile);
        }

        Boolean flag = false;
        for(PropStrength__Request__c enq : enqList) {
            if((oldEnqMap.get(enq.Id).Broker_Type__c != enq.Broker_Type__c && oldEnqMap.get(enq.Id).Broker_Type__c != null) ||
               (oldEnqMap.get(enq.Id).Type_Of_Enquiry__c != enq.Type_Of_Enquiry__c && oldEnqMap.get(enq.Id).Type_Of_Enquiry__c != null) || 
               (oldEnqMap.get(enq.Id).PropStrength__Request_Source__c != enq.PropStrength__Request_Source__c && oldEnqMap.get(enq.Id).PropStrength__Request_Source__c != null) ||
               (oldEnqMap.get(enq.Id).PropStrength__Broker_Account__c != enq.PropStrength__Broker_Account__c && oldEnqMap.get(enq.Id).PropStrength__Broker_Account__c != null) ||
               (oldEnqMap.get(enq.Id).PropStrength__Broker_Contact__c != enq.PropStrength__Broker_Contact__c && oldEnqMap.get(enq.Id).PropStrength__Broker_Contact__c != null)) {
                   flag = true;
                   break;
               } 
        }

        if(flag) {
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Profile.Name IN :profileNameList]);
            Id currentUserId = UserInfo.getUserId();
            
            for(PropStrength__Request__c enq : enqList) {
                if(userMap.containsKey(currentUserId)) {
                    if(oldEnqMap.get(enq.Id).Broker_Type__c != enq.Broker_Type__c && oldEnqMap.get(enq.Id).Broker_Type__c != null) {
                        enq.Broker_Type__c.addError('You can not make any changes in this field');
                    } else if(oldEnqMap.get(enq.Id).Type_Of_Enquiry__c != enq.Type_Of_Enquiry__c && oldEnqMap.get(enq.Id).Type_Of_Enquiry__c != null) {
                        enq.Type_Of_Enquiry__c.addError('You can not make any changes in this field');
                    } else if(oldEnqMap.get(enq.Id).PropStrength__Request_Source__c != enq.PropStrength__Request_Source__c && oldEnqMap.get(enq.Id).PropStrength__Request_Source__c != null) {
                        enq.PropStrength__Request_Source__c.addError('You can not make any changes in this field');
                    } else if(oldEnqMap.get(enq.Id).PropStrength__Broker_Account__c != enq.PropStrength__Broker_Account__c && oldEnqMap.get(enq.Id).PropStrength__Broker_Account__c != null) {
                        enq.PropStrength__Broker_Account__c.addError('You can not make any changes in this field');
                    } else if(oldEnqMap.get(enq.Id).PropStrength__Broker_Contact__c != enq.PropStrength__Broker_Contact__c && oldEnqMap.get(enq.Id).PropStrength__Broker_Contact__c != null) {
                        enq.PropStrength__Broker_Contact__c.addError('You can not make any changes in this field');
                    }
                }
            }
        }
    }
}