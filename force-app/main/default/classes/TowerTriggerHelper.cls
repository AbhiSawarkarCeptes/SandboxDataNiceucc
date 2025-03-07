public class TowerTriggerHelper {
    public static void sendToMobile(List<PropStrength__Tower__c> newList,map<Id,PropStrength__Tower__c> oldMap) {
        set<Id> towerIds = new Set<Id>();
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        boolean trgFlg = mobile_appmdt.Tower_Trigger__c;
        if(trgFlg || test.isRunningTest()) {
            for(PropStrength__Tower__c tw : newList) {
                if(trigger.isInsert) {
                    if(tw.Name != null ||
                       tw.Completion_Percentage__c != null ||
                       tw.Under_Construction__c != null ||
                       tw.PropStrength__Project_Name__c != null) {
                           towerIds.add(tw.Id);
                       } 
                } else if(trigger.isUpdate) {
                    if(tw.PropStrength__Tower_Name__c != oldMap.get(tw.Id).PropStrength__Tower_Name__c ||
                       tw.Completion_Percentage__c != oldMap.get(tw.Id).Completion_Percentage__c ||
                       tw.Under_Construction__c != oldMap.get(tw.Id).Under_Construction__c ||
                       tw.PropStrength__Project_Name__c != oldMap.get(tw.Id).PropStrength__Project_Name__c) {
                           towerIds.add(tw.Id);
                       }
                }
            }
            system.debug('towerIds::'+towerIds);
            if(!towerIds.isEmpty() && !System.IsBatch() && !System.isFuture()) {
                TowerTriggerHelper.sendToMobileAPI(towerIds);
            }
        }
    }
    
    @future(callOut=true)
    Public static void sendToMobileAPI(set<Id> towerIds) {
        system.debug('towerIds::'+towerIds);
        if(!towerIds.isEmpty()) {
            List<Mobile_App_Log__c> insertList = new List<Mobile_App_Log__c>();
            List<PropStrength__Tower__c> towerList = [SELECT Id,Name,PropStrength__Project_Name__c,PropStrength__Project_Name__r.Master_Project__c,
                                                      Under_Construction__c,Completion_Percentage__c,PropStrength__Tower_Name__c,
                                                      (SELECT Id,Name,Type__c,Project_PS__c,Tower_PS__c FROM Aminities__r),
                                                      (SELECT Id,Name,Attraction_Type__c,Project_PS__c,Tower_PS__c FROM Attractions__r)
                                                      FROM PropStrength__Tower__c
                                                      WHERE Id IN: towerIds];
            if(!towerList.isEmpty()) {
                Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
                String endPointURL = mobile_appmdt.Tower_Endpoint__c;
                List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
                try {
                    for(PropStrength__Tower__c tw : towerList) {
                        requestBodyWrapper wrap = new requestBodyWrapper();
                        wrap.name = tw.PropStrength__Tower_Name__c;
                        wrap.completionPercentage = (tw.Completion_Percentage__c != null ? tw.Completion_Percentage__c : 0);
                        wrap.isUnderConstruction = (tw.Under_Construction__c ? tw.Under_Construction__c : false);
                        wrap.sfTowerId = tw.Id;
                        wrap.sfMasterCommunityId = (tw.PropStrength__Project_Name__r.Master_Project__c != null ? tw.PropStrength__Project_Name__r.Master_Project__c : null);
                        wrap.sfCommunityId = (tw.PropStrength__Project_Name__c != null ? tw.PropStrength__Project_Name__c : null);
                        if(tw.Aminities__r.size() > 0){
                            for(Amenity__c ame : tw.Aminities__r) {
                                amenities amenitywrap = new amenities();
                                amenitywrap.sfAmenityId = ame.Id;
                                amenitywrap.Name = ame.Name;
                                amenitywrap.type = (ame.Type__c != null && ame.Type__c != '' ? ame.Type__c : '');
                                wrap.amenities.add(amenitywrap);
                            }
                        }
                        if(tw.Attractions__r.size() > 0){
                            for(Attractions__c attract  : tw.Attractions__r) {
                                attractions attractwrap = new attractions();
                                attractwrap.sfAttractionId = attract.Id;
                                attractwrap.Name = attract.Name;
                                attractwrap.type = (attract.Attraction_Type__c != null && attract.Attraction_Type__c != '' ? attract.Attraction_Type__c : '');
                                wrap.attractions.add(attractwrap);
                            }
                        }
                        wraplst.add(wrap);
                    }
                    system.debug('towerIds::'+JSON.serialize(wraplst[0]));
                    if(wraplst != null){
                        String response = MobileIntegrationCallOutsAPI_PS.callMobileApp(endPointURL,'POST',JSON.serialize(wraplst[0]));
                        system.debug('response::'+response);
                        if(!String.isBlank(response)) {
                            for(PropStrength__Tower__c tw : towerList) {
                                Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                appLog.Tower__c = tw.Id;
                                if(response.contains('Success')){
                                    appLog.Status__c = 'Success';
                                }else
                                    appLog.Status__c = 'Error';
                                appLog.API_Name__c = endPointURL;
                                appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                                appLog.Response_Body__c = response;
                                insertList.add(appLog);
                            }
                            if(!insertList.isEmpty()) {
                                insert insertList;
                            }
                        }
                    }
                } catch(Exception e) {
                    for(PropStrength__Tower__c tw : towerList) {
                        Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                        appLog.Tower__c = tw.Id;
                        appLog.Status__c = 'Exception';
                        appLog.API_Name__c = endPointURL;
                        appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                        appLog.Response_Body__c = String.valueOf(e.getMessage());
                        insertList.add(appLog);
                    }
                    if(!insertList.isEmpty()) {
                        insert insertList;
                    }
                    system.debug('getMessage::'+e.getMessage());
                }
            }
        }
    }
    
    
    class requestBodyWrapper{
        string name;
        Decimal completionPercentage;
        boolean isUnderConstruction;
        string sfMasterCommunityId;
        string sfCommunityId;
        string sfTowerId;
        
        List<amenities> amenities = new List<amenities>();
        List<attractions> attractions = new List<attractions>();
    }
    
    class amenities{
        String sfAmenityId;
        String name;
        String type;
    }
    
    class attractions{
        String sfAttractionId;
        String name;
        String type;
    }
    
    //Added by Nishank Manwani on 10-June-2024 to send mail to applicant when completion certificate date is not null
    public static void sendMailForCompletionCertificate(List<PropStrength__Tower__c> towerList, Map<Id, PropStrength__Tower__c> towerMap) {
        Set<Id> towerId = new Set<Id>();
        
        for(PropStrength__Tower__c tower : towerList) {
            if(tower.PropStrength__Completion_Certificate_Date__c != null && tower.PropStrength__Completion_Certificate_Date__c != towerMap.get(tower.Id).PropStrength__Completion_Certificate_Date__c) {
                towerId.add(tower.Id);
            }
        }
        
        if(!towerId.isEmpty()) {
            List<PropStrength__Tower__c> towList = [SELECT Id, (SELECT Id FROM PropStrength__Properties__r) FROM PropStrength__Tower__c WHERE Id IN :towerId];
            
            Set<Id> propId = new Set<Id>();
            
            for(PropStrength__Tower__c tower : towList) {
                if(!tower.PropStrength__Properties__r.isEmpty()) {
                    for(PropStrength__Property__c prop : tower.PropStrength__Properties__r) {
                        propId.add(prop.Id);
                    }
                }
            }
            
            List<PropStrength__Property__c> propList = [SELECT Id, 
                                                        (SELECT Id FROM PropStrength__Application_Booking__r 
                                                         WHERE PropStrength__Active__c = TRUE ORDER BY CreatedDate DESC) 
                                                        FROM PropStrength__Property__c WHERE Id IN :propId];
            
            if(!propList.isEmpty()) {
                List<Id> bookId = new List<Id>();
                
                for(PropStrength__Property__c property : propList) {
                    if(!property.PropStrength__Application_Booking__r.isEmpty()) {
                        bookId.add(property.PropStrength__Application_Booking__r[0].Id);
                    }
                }
                
                if(!bookId.isEmpty()) {
                    sendMailToApplicantCC(bookId);
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 10-June-2024 to send mail to applicant for completion certificate
    @Future(Callout=true)
    public static void sendMailToApplicantCC(List<Id> bookId) {
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                             FROM EmailTemplate 
                                             WHERE DeveloperName =: 'Notification_Receive_CC'];
        
        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        List<PropStrength__Application_Booking__c> bookList = [SELECT Id, PropStrength__Primary_Customer__c, 
                                                               (SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r 
                                                                WHERE PropStrength__Active__c = TRUE AND PropStrength__Applicant_Acc__c != null) 
                                                               FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];
        
        for(PropStrength__Application_Booking__c book : bookList) {
            if(!book.PropStrength__Applicant_Details__r.isEmpty()) {
                List<String> sendTo = new List<String>();
                
                for(PropStrength__Applicant_Detail__c apDet : book.PropStrength__Applicant_Details__r) {
                    if(apDet.PropStrength__Applicant_Email__c != null) {
                        sendTo.add(apDet.PropStrength__Applicant_Email__c);
                    }
                }
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(sendTo);
                email.setWhatId(book.Id);
                email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.setSaveAsActivity(true); 
                email.setTemplateId(tempId);
                mails.add(email);
            }
        }
        
        try {
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
        } Catch(Exception e){
            System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
            System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
        }
    }
}