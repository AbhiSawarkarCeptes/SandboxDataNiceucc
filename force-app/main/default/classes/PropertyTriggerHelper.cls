public class PropertyTriggerHelper {
    public static Boolean isRun = true;
    
    public static void updateDLDDate(List<PropStrength__Property__c> newRecList, Map<Id, PropStrength__Property__c> oldMap) {
        map<Id,PropStrength__Property__c> propertyMap = new map<Id,PropStrength__Property__c>();
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Property__c ut : newRecList) {
            if(trigger.isInsert) {
                if(ut.DLP_Start_Date__c != null ||
                   ut.DLP_End_Date__c != null) {
                       propertyMap.put(ut.id,ut);
                   }
            } else if(trigger.isUpdate) {
                if(ut.DLP_Start_Date__c != oldMap.get(ut.Id).DLP_Start_Date__c ||
                   ut.DLP_End_Date__c != oldMap.get(ut.Id).DLP_End_Date__c) {
                       propertyMap.put(ut.id,ut);
                   }
            }
        } 
        if(!propertyMap.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookingList = [SELECT Id,Name,PropStrength__Property__c
                                                                      FROM PropStrength__Application_Booking__c
                                                                      WHERE PropStrength__Property__c IN: propertyMap.keySet() AND
                                                                      PropStrength__Active__c =: true];
            if(!bookingList.isEmpty()) {
                for(PropStrength__Application_Booking__c book : bookingList) {
                    if(propertyMap.containsKey(book.PropStrength__Property__c)) {
                        PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c();
                        b.Id = book.Id;
                        b.DLP_Start_Date__c = propertyMap.containsKey(book.PropStrength__Property__c) ? propertyMap.get(book.PropStrength__Property__c).DLP_Start_Date__c : null;
                        b.DLP_End_Date__c = propertyMap.containsKey(book.PropStrength__Property__c) ? propertyMap.get(book.PropStrength__Property__c).DLP_End_Date__c : null;
                        updateList.add(b);
                    }
                }
            }
            system.debug('updateList::'+updateList);
            if(!updateList.isEmpty()) {
                update updateList;
            }
        }
    }
    
    //Added by Mitesh on 12/02/2024 to to Send in unit API
    public static void sendToMobile(List<PropStrength__Property__c> newRecList, Map<Id, PropStrength__Property__c> oldMap) { 
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        boolean trgFlg = mobile_appmdt.Property_Trigger__c;
        set<Id> prIds = new set<Id>();
        if(trgFlg) {
            for(PropStrength__Property__c ut : newRecList) {
                if(trigger.isInsert) {
                    if(ut.name != null || ut.PropStrength__Plot_Number__c != null || ut.PropStrength__Floor_Number__c != null || ut.PropStrength__Unit_Type__c != null || ut.Purchase_Price__c != null || ut.DLD_Unit_No__c != null || ut.Not_Available_for_Sales__c != null || ut.PropStrength__Unit_Status__c != null || ut.Car_Park_Count_1__c != null || ut.Permitted_Use__c != null || ut.PropStrength__Category__c != null || ut.Car_Park_Type_1__c != null || ut.Plot_Area__c != null || ut.PropStrength__Super_Area__c != null || ut.Parking_Bay_Allocation_No__c   != null || ut.PropStrength__House_Unit_No__c != null || ut.PropStrength__Tower__c != null || ut.PropStrength__Project_Name__c != null || ut.View_Type__c != null || ut.PropStrength__Floor__c != null || ut.PropStrength__Property_Name__c != null) {
                           prIds.add(ut.Id);
                       }
                } else if(trigger.isUpdate) {
                    if(ut.name != oldMap.get(ut.Id).name || ut.PropStrength__Plot_Number__c != oldMap.get(ut.Id).PropStrength__Plot_Number__c || ut.PropStrength__Property_Name__c != oldMap.get(ut.Id).PropStrength__Property_Name__c ||  ut.PropStrength__Floor_Number__c != oldMap.get(ut.Id).PropStrength__Floor_Number__c || ut.PropStrength__Unit_Type__c != oldMap.get(ut.Id).PropStrength__Unit_Type__c || ut.Purchase_Price__c != oldMap.get(ut.Id).Purchase_Price__c || ut.DLD_Unit_No__c != oldMap.get(ut.Id).DLD_Unit_No__c || ut.Not_Available_for_Sales__c != oldMap.get(ut.Id).Not_Available_for_Sales__c || ut.PropStrength__Unit_Status__c  != oldMap.get(ut.Id).PropStrength__Unit_Status__c || ut.PropStrength__tower__c != oldMap.get(ut.Id).PropStrength__tower__c || ut.PropStrength__Floor__c != oldMap.get(ut.Id).PropStrength__Floor__c || ut.Permitted_Use__c != oldMap.get(ut.Id).Permitted_Use__c || ut.PropStrength__Category__c != oldMap.get(ut.Id).PropStrength__Category__c || ut.Car_Park_Count_1__c != oldMap.get(ut.Id).Car_Park_Count_1__c || ut.Car_Park_Type_1__c != oldMap.get(ut.Id).Car_Park_Type_1__c || ut.PropStrength__Super_Area__c != oldMap.get(ut.Id).PropStrength__Super_Area__c || ut.Plot_Area__c != oldMap.get(ut.Id).Plot_Area__c || ut.Parking_Bay_Allocation_No__c   != oldMap.get(ut.Id).Parking_Bay_Allocation_No__c || ut.PropStrength__House_Unit_No__c != oldMap.get(ut.Id).PropStrength__House_Unit_No__c || ut.View_Type__c != oldMap.get(ut.Id).View_Type__c || ut.PropStrength__Project_Name__c != oldMap.get(ut.Id).PropStrength__Project_Name__c) {
                           prIds.add(ut.Id);
                       }
                }
            }
            system.debug('prIds::'+prIds);
            if(!prIds.isEmpty() && !System.IsBatch() && !System.isFuture()){
                PropertyTriggerHelper.sendToMobileAPI(prIds);
            } 
        }
    }
    
    @future(callOut=true)
    Public static void sendToMobileAPI(set<Id> prIds) { 
        if(!prIds.isEmpty()) {
            List<Mobile_App_Log__c> insertList = new List<Mobile_App_Log__c>();
            Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
            String endPointURL = mobile_appmdt.Unit_Endpoint__c;
            List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
            List<PropStrength__Property__c> newList = [SELECT Id,Name,PropStrength__Plot_Number__c,PropStrength__Floor_Number__c,PropStrength__Unit_Type__c,PropStrength__Total_Sales_Consideration__c,DLD_Unit_No__c,
                                                       Not_Available_for_Sales__c,PropStrength__Unit_Status__c,PropStrength__Tower__r.DLD_Building_Number__c,
                                                       Permitted_Use__c,PropStrength__Category__c,Car_Park_Count_1__c,Car_Park_Type_1__c,PropStrength__Super_Area__c,
                                                       Plot_Area__c,Parking_Bay_Allocation_No__c,PropStrength__House_Unit_No__c,PropStrength__Tower__c,View_Type__c,
                                                       PropStrength__Project_Name__c,PropStrength__Project_Name__r.Master_Project__c,PropStrength__tower__r.Tower_Type__c,
                                                       PropStrength__Property_Name__c,PropStrength__Floor__r.PropStrength__Floor_Number__c
                                                       FROM PropStrength__Property__c
                                                       WHERE Id IN: prIds];
            if(!newList.isEmpty()) {
                try {
                    for(PropStrength__Property__c ut :newList) {
                        requestBodyWrapper wrap = new requestBodyWrapper();
                        wrap.unitName = (ut.PropStrength__Property_Name__c != null ? ut.PropStrength__Property_Name__c : '');
                        wrap.floorNumber = (ut.PropStrength__Floor_Number__c != null ? String.valueOf(ut.PropStrength__Floor_Number__c) : '0');
                        wrap.unitType = (ut.PropStrength__Unit_Type__c != null ? ut.PropStrength__Unit_Type__c : '');
                        wrap.unitPrice  = (ut.PropStrength__Total_Sales_Consideration__c != null ? ut.PropStrength__Total_Sales_Consideration__c : null);
                        wrap.unitNumber = (ut.PropStrength__House_Unit_No__c != null ? ut.PropStrength__House_Unit_No__c : '');
                        wrap.isNotAvailableForSale = (ut.Not_Available_for_Sales__c ? ut.Not_Available_for_Sales__c : false);
                        wrap.availabilityStatus = (ut.PropStrength__Unit_Status__c != null ? ut.PropStrength__Unit_Status__c : '');
                        wrap.DLDBuildingNumber = (ut.PropStrength__Tower__r.DLD_Building_Number__c != null ? String.valueOf(ut.PropStrength__Tower__r.DLD_Building_Number__c) : '');
                        wrap.noOfBedrooms = (ut.PropStrength__Floor__r.PropStrength__Floor_Number__c != null ? ut.PropStrength__Floor__r.PropStrength__Floor_Number__c : 0);
                        wrap.permittedUse = (ut.Permitted_Use__c != null ? ut.Permitted_Use__c : '');
                        wrap.projectPropertyType = (ut.PropStrength__Category__c != null ? ut.PropStrength__Category__c : '');
                        wrap.noOfParkings = (ut.Car_Park_Count_1__c != null ? ut.Car_Park_Count_1__c : null);
                        wrap.parkingType = (ut.Car_Park_Type_1__c != null ? ut.Car_Park_Type_1__c : '');
                        wrap.totalArea = (ut.PropStrength__Super_Area__c != null ? ut.PropStrength__Super_Area__c : null);
                        wrap.saleableArea = (ut.PropStrength__Super_Area__c != null ? ut.PropStrength__Super_Area__c : null);
                        wrap.plotArea = (ut.Plot_Area__c != null ? ut.Plot_Area__c : null);
                        wrap.RERAApplicableArea = (ut.PropStrength__Super_Area__c != null ? ut.PropStrength__Super_Area__c : null);
                        wrap.parkingBays = (ut.Parking_Bay_Allocation_No__c != null ? ut.Parking_Bay_Allocation_No__c : '');
                        wrap.plotNumber = (ut.PropStrength__Plot_Number__c != null ? ut.PropStrength__Plot_Number__c : '');
                        wrap.sfUnitId = ut.Id;
                        wrap.sfTowerId = (ut.PropStrength__Tower__c != null ? ut.PropStrength__Tower__c : null);
                        wrap.views = (ut.View_Type__c != null ? ut.View_Type__c : '');
                        wrap.sfMasterCommunityId = (ut.PropStrength__Project_Name__c != null ? ut.PropStrength__Project_Name__r.Master_Project__c : null);
                        wrap.propertyType = (ut.PropStrength__tower__r.Tower_Type__c != null ? ut.PropStrength__tower__r.Tower_Type__c : null);
                        wrap.sfCommunityId = ut.PropStrength__Project_Name__c;
                        wraplst.add(wrap);
                    }
                    system.debug('wraplst::'+JSON.serialize(wraplst[0]));
                    if(wraplst != null) {
                        String response = MobileIntegrationCallOutsAPI_PS.callMobileApp(endPointURL,'POST',JSON.serialize(wraplst[0]));
                        system.debug('response::'+response);
                        if(!String.isBlank(response)) {
                            for(PropStrength__Property__c ut :newList) {
                                Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                appLog.Property__c = ut.Id;
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
                    for(PropStrength__Property__c ut :newList) {Mobile_App_Log__c appLog = new Mobile_App_Log__c();appLog.Property__c = ut.Id;appLog.Status__c = 'Exception';
                        appLog.API_Name__c = endPointURL;appLog.Request_Body__c = JSON.serialize(wraplst[0]);appLog.Response_Body__c = String.valueOf(e.getMessage());
                        insertList.add(appLog);
                    }
                    if(!insertList.isEmpty()) {insert insertList;}
                    system.debug('getMessage::'+e.getMessage());
                }
            }
        }
    }
  
    public static void SendRevisedBookingform(List<PropStrength__Property__c> newList,map<Id,PropStrength__Property__c> oldMap) {
        set<Id> propertyIds = new set<Id>();
        for(PropStrength__Property__c prop : newList) {
            if(prop.Area_Change_Approved_by_Audit__c != null && 
               prop.Area_Change_Approved_by_Audit__c != oldMap.get(prop.Id).Area_Change_Approved_by_Audit__c) {
                   //propertyIds.add(prop.id);
               }
        }
       /* if(!propertyIds.isEmpty()) {
            if(System.IsBatch() == false && System.isFuture() == false) { 
                //TransactionRequestEmailSend.sendEmailRevisedBookingform(propertyIds);
            }
        }*/
    }
    /*public static void bookingLocked(List<PropStrength__Property__c> newList,map<Id,PropStrength__Property__c> oldMap) {
List<PropStrength__Application_Booking__c> listBookingLocked = new List<PropStrength__Application_Booking__c>();
List<PropStrength__Application_Booking__c> listBookingUnlocked = new List<PropStrength__Application_Booking__c>();
set<Id> lockIds = new set<Id>();
set<Id> unlockIds = new set<Id>();
for(PropStrength__Property__c prop : newList) {
if(prop.Booking_Locked__c && prop.Booking_Locked__c != oldMap.get(prop.Id).Booking_Locked__c) {
lockIds.add(prop.id);
} else if(prop.Booking_Locked__c == false && prop.Booking_Locked__c != oldMap.get(prop.Id).Booking_Locked__c) {
unlockIds.add(prop.id);
}
}
system.debug('lockIds::'+lockIds);
system.debug('unlockIds::'+unlockIds);
if(!lockIds.isEmpty()) {
for(PropStrength__Application_Booking__c book : [SELECT Id FROM PropStrength__Application_Booking__c WHERE PropStrength__Property__c IN: lockIds]) {
listBookingLocked.add(book);
}
system.debug('listBookingLocked::'+listBookingLocked);
if(!listBookingLocked.isEmpty()) {
List<Approval.lockResult> lrList1 = Approval.lock(listBookingLocked, false);
system.debug('lrList1::'+lrList1);
}
} else if(!unlockIds.isEmpty()) {
for(PropStrength__Application_Booking__c book : [SELECT Id FROM PropStrength__Application_Booking__c WHERE PropStrength__Property__c IN: unlockIds]) {
listBookingUnlocked.add(book);
}
system.debug('listBookingUnlocked::'+listBookingUnlocked);
if(!listBookingUnlocked.isEmpty()) {
List<Approval.UnlockResult> ulrList = Approval.unlock(listBookingUnlocked, false);
system.debug('ulrList::'+ulrList);
}
}
}*/
    
    public static boolean runOnce(){
        if(isRun) {
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }
    
    //Added by Deepak Sharma on 26/05/2023 to update Basic Sales Price value on Property
    public static void BasicSalePrice(List<PropStrength__Property__c> newRecList, Map<Id, PropStrength__Property__c> oldMapRecs) {
        if(!newRecList.isEmpty()) {
            Map<Id, Id> propPtMap = new Map<Id, Id>();
            
            for(PropStrength__Property__c recPr : newRecList) {
                propPtMap.put(recPr.Id, recPr.PropStrength__Property_Type__c);
            }
            
            if(!propPtMap.isEmpty()) {
                Map<Id, PropStrength__Property_Type__c> getPtRec = new Map<Id, PropStrength__Property_Type__c>([SELECT Id, Current_Rate_Per_Unit_Area__c FROM PropStrength__Property_Type__c WHERE Id IN :propPtMap.values()]);
                
                for(PropStrength__Property__c recPr : newRecList) {
                    System.debug(recPr);
                    if(recPr.PropStrength__Active__c && !recPr.PropStrength__Allotted__c && oldMapRecs.get(recPr.Id).PropStrength__Allotted__c && !getPtRec.isEmpty() && !propPtMap.isEmpty() && propPtMap.containsKey(recPr.Id) && getPtRec.containsKey(propPtMap.get(recPr.Id)) && getPtRec.get(propPtMap.get(recPr.Id)).Current_Rate_Per_Unit_Area__c != null) {
                        recPr.PropStrength__Rate_per_unit_area__c = getPtRec.get(propPtMap.get(recPr.Id)).Current_Rate_Per_Unit_Area__c;
                    }
                }
            }
        }
    }
    
    //Added by Deepak Sharma on 22/85/2023 to show error on new super area on Property
    public static void showErrorOnNewSA(List<PropStrength__Property__c> newRecList, Map<Id, PropStrength__Property__c> oldMapRecs) {
        Set<Id> propId = new Set<Id>();
        for(PropStrength__Property__c prop : newRecList) {
            if(prop.PropStrength__Allotted__c && prop.New_Super_Area__c != oldMapRecs.get(prop.Id).New_Super_Area__c ) {
                propId.add(prop.Id);
            }
        }
        
        if(!propId.isEmpty()) {
            Map<Id, PropStrength__Property__c> propMap = new Map<Id, PropStrength__Property__c>([SELECT Id, PropStrength__Allotted__c, New_Super_Area__c, (SELECT Id, PropStrength__Active__c, SPA_Executed__c FROM PropStrength__Application_Booking__r WHERE PropStrength__Active__c = TRUE) FROM PropStrength__Property__c WHERE Id IN :propId]);
            for(PropStrength__Property__c prop : newRecList) {
                if(prop.PropStrength__Allotted__c && prop.New_Super_Area__c != oldMapRecs.get(prop.Id).New_Super_Area__c && propMap.get(prop.Id).PropStrength__Application_Booking__r.isEmpty() == FALSE) {
                    Boolean flag = FALSE;
                    for(PropStrength__Application_Booking__c book : propMap.get(prop.Id).PropStrength__Application_Booking__r) {
                        if(book.PropStrength__Active__c && book.SPA_Executed__c) {
                            flag = TRUE;
                            break;
                        }
                    }
                    if(flag) {
                        prop.New_Super_Area__c.addError('SPA on the booking is executed hence area can not be changed'); 
                    }
                }
            }
        }
    }
    
    //Added by Deepak Sharma on 22/85/2023 to lock booking on Property
    public static void lockAllBookings(List<PropStrength__Property__c> newRecList, Map<Id, PropStrength__Property__c> oldMapRecs) {
        Set<Id> propId = new Set<Id>();
        for(PropStrength__Property__c prop : newRecList) {
            if(prop.PropStrength__Allotted__c && prop.Area_Change_Submitted_to_Audit__c && prop.Area_Change_Submitted_to_Audit__c != oldMapRecs.get(prop.Id).Area_Change_Submitted_to_Audit__c) {
                propId.add(prop.Id);
            }
        }
        
        if(!propId.isEmpty()) {
            List<PropStrength__Property__c> propList = [SELECT Id, Area_Change_Submitted_to_Audit__c, (SELECT Id FROM PropStrength__Application_Booking__r) FROM PropStrength__Property__c WHERE Id IN :propId];
            for(PropStrength__Property__c prop : propList) {
                if(prop.Area_Change_Submitted_to_Audit__c && prop.PropStrength__Application_Booking__r.isEmpty() == FALSE) {
                    for(PropStrength__Application_Booking__c book : prop.PropStrength__Application_Booking__r) {
                        Approval.lock(book.id);   
                    }
                }
            }
            PropertyTriggerHelper.sendMailPendingAuditApproval(propId);
        }
    }
    
    //Added by Deepak Sharma on 22/8/2023 to unlock booking on Property
    public static void unLockAllBookings(List<PropStrength__Property__c> newRecList, Map<Id, PropStrength__Property__c> oldMapRecs) {
        Set<Id> propId = new Set<Id>();
        Set<Id> sndPropId = new Set<Id>();
        for(PropStrength__Property__c prop : newRecList) {
            if(prop.PropStrength__Allotted__c && (prop.Area_Change_Approved_by_Audit__c != null && prop.Area_Change_Approved_by_Audit__c != oldMapRecs.get(prop.Id).Area_Change_Approved_by_Audit__c) || (prop.Area_Change_Rejected_by_Audit__c && prop.Area_Change_Rejected_by_Audit__c != oldMapRecs.get(prop.Id).Area_Change_Rejected_by_Audit__c) ) {
                propId.add(prop.Id);
            }
            
            if(prop.Area_Change_Approved_by_Audit__c != null && prop.Area_Change_Approved_by_Audit__c != oldMapRecs.get(prop.Id).Area_Change_Approved_by_Audit__c) {
                sndPropId.add(prop.Id);
            }
        }
        
        if(!propId.isEmpty()) {
            List<PropStrength__Property__c> propList = [SELECT Id, Area_Change_Approved_by_Audit__c, Area_Change_Rejected_by_Audit__c, (SELECT Id FROM PropStrength__Application_Booking__r) FROM PropStrength__Property__c WHERE Id IN :propId];
            for(PropStrength__Property__c prop : propList) {
                if((prop.Area_Change_Approved_by_Audit__c != null || prop.Area_Change_Rejected_by_Audit__c) && prop.PropStrength__Application_Booking__r.isEmpty() == FALSE) {
                    for(PropStrength__Application_Booking__c book : prop.PropStrength__Application_Booking__r) {
                        Approval.unlock(book.id);   
                    }
                }
            }
        }
        
        if(!sndPropId.isEmpty()) {
            PropertyTriggerHelper.sendMailAuditApproval(sndPropId);
        }
    }
    
    //Added by Deepak sharma to send Mail to CRM team on Aug'21 2023
    @Future(Callout=True)
    public static void sendMailPendingAuditApproval(Set<Id> propId) {
        system.debug('finish::'+propId);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>(); 
        if(!propId.isEmpty()) {
            List<PropStrength__Property__c> propList = [SELECT Id,PropStrength__Project_Name__r.Sales_Ops_Executive__c,
                                                        PropStrength__Tower__r.CRM_Executive__c
                                                        FROM PropStrength__Property__c
                                                        WHERE Id IN: propId];
            if(!propList.isEmpty()) {
                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     FROM EmailTemplate 
                                                     WHERE DeveloperName =: 'Submit_for_Audit_Property'];
                String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                for(PropStrength__Property__c prop : propList) {
                    if(prop.PropStrength__Project_Name__r.Sales_Ops_Executive__c != null) {
                        sendTo.add(prop.PropStrength__Project_Name__r.Sales_Ops_Executive__c);
                    }
                    if(prop.PropStrength__Tower__r.CRM_Executive__c != null) {
                        sendTo.add(prop.PropStrength__Tower__r.CRM_Executive__c);
                    }
                }
                for(PropStrength__Property__c prop : propList) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(!sendTo.isEmpty()) {
                        email.setToAddresses(sendTo);
                    }
                    email.setWhatId(prop.id);
                    email.setTargetObjectId(prop.PropStrength__Tower__r.CRM_Executive__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.saveAsActivity = true;
                    email.setTemplateId(tempId);
                    mails.add(email); 
                }
                try {
                    if(!mails.isEmpty()){
                        Messaging.sendEmail(mails);
                    }
                } catch(Exception e){
                    System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                    System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                }
            }
        }
    }    
    
    //Added by Deepak sharma to send Mail to CRM team on Aug'21 2023
    @Future(Callout=True)
    public static void sendMailAuditApproval(Set<Id> propId) {
        system.debug('finish::'+propId);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>(); 
        if(!propId.isEmpty()) {
            List<PropStrength__Property__c> propList = [SELECT Id,PropStrength__Project_Name__r.Sales_Ops_Executive__c,
                                                        PropStrength__Tower__r.CRM_Executive__c, 
                                                            (SELECT Id, SPA_Executed__c, PropStrength__Active__c 
                                                            FROM PropStrength__Application_Booking__r 
                                                            WHERE PropStrength__Active__c = true 
                                                            ORDER BY CreatedDate DESC LIMIT 1)
                                                        FROM PropStrength__Property__c
                                                        WHERE Id IN: propId];
            if(!propList.isEmpty()) {
                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     FROM EmailTemplate 
                                                     WHERE DeveloperName =: 'Approve_for_Audit_Property'];
                String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                for(PropStrength__Property__c prop : propList) {
                    if(prop.PropStrength__Project_Name__r.Sales_Ops_Executive__c != null) {
                        sendTo.add(prop.PropStrength__Project_Name__r.Sales_Ops_Executive__c);
                    }
                    if(prop.PropStrength__Tower__r.CRM_Executive__c != null) {
                        sendTo.add(prop.PropStrength__Tower__r.CRM_Executive__c);
                    }
                    // Added By Gourav Gour 16/06/2024
                    if(!prop.PropStrength__Application_Booking__r.isEmpty() && prop.PropStrength__Application_Booking__r[0].SPA_Executed__c) {
                        sendTo.add('crmops@sobharealty.com');
                    }
                }
                for(PropStrength__Property__c prop : propList) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(!sendTo.isEmpty()) {
                        email.setToAddresses(sendTo);
                    }
                    email.setWhatId(prop.id);
                    email.setTargetObjectId(prop.PropStrength__Tower__r.CRM_Executive__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.saveAsActivity = true;
                    email.setTemplateId(tempId);
                    mails.add(email); 
                }
                try {
                    if(!mails.isEmpty()){
                        Messaging.sendEmail(mails);
                    }
                } catch(Exception e){
                    System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                    System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                }
            }
        }
    } 
    
    //Added by Deepak Sharma on 23-Aug-23 to call approval process on the basis of alloted checkbox
    public static void runapprovalProcessOnAllotedCB(List<PropStrength__Property__c> newRecList, Map<Id, PropStrength__Property__c> oldMapRecs) {
        for(PropStrength__Property__c prop : newRecList) {
            if(prop.PropStrength__Allotted__c && prop.New_Super_Area__c != oldMapRecs.get(prop.Id).New_Super_Area__c) {
                if(prop.PropStrength__Active__c && prop.New_Super_Area__c!= null && prop.PropStrength__Super_Area__c != null && !prop.Area_Change_Submitted_to_Audit__c) {
                    Decimal diffPercent;
                    if(prop.PropStrength__Super_Area__c < prop.New_Super_Area__c) {
                        Decimal absoluteDifference = Math.abs(prop.New_Super_Area__c - prop.PropStrength__Super_Area__c);
                        diffPercent = (absoluteDifference / prop.PropStrength__Super_Area__c) * 100;
                    } else if(prop.PropStrength__Super_Area__c > prop.New_Super_Area__c) {
                        Decimal absoluteDifference = Math.abs(prop.PropStrength__Super_Area__c - prop.New_Super_Area__c);
                        diffPercent = (absoluteDifference / prop.New_Super_Area__c) * 100;
                    }

                    System.debug('diffPercent***');
                    System.debug(diffPercent);

                    if(diffPercent > 5) {
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setComments('Submitting request for approval.');
                        req1.setObjectId(prop.id);
                        
                        // Submit on behalf of a specific submitter
                        req1.setSubmitterId(UserInfo.getUserId()); 
                        
                        // Submit the record to specific process and skip the criteria evaluation
                        req1.setProcessDefinitionNameOrId('Area_Change_Allotted_Property');
                        req1.setSkipEntryCriteria(true);
                        
                        // Submit the approval request for the account
                        Approval.ProcessResult result = Approval.process(req1);
                    }
                }
            } else if(!prop.PropStrength__Allotted__c && prop.New_Super_Area__c != oldMapRecs.get(prop.Id).New_Super_Area__c) {
                if(!prop.PropStrength__Property_on_hold_for_Reallocation__c  && prop.PropStrength__Active__c && !prop.Area_Change_Submitted_to_Audit__c) {
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(prop.id);
                    
                    // Submit on behalf of a specific submitter
                    req1.setSubmitterId(UserInfo.getUserId()); 
                    
                    // Submit the record to specific process and skip the criteria evaluation
                    req1.setProcessDefinitionNameOrId('Area_Change_Unsold_Property');
                    req1.setSkipEntryCriteria(true);
                    
                    // Submit the approval request for the account
                    Approval.ProcessResult result = Approval.process(req1);
                }
            }
        }
    }
    
    //Added by Deepak Sharma on 31'Oct 2023 for SendEmailToCRMExecutiveSPABatch, SendEmailToCRMExecutiveMOUBatch, sendEmailToCrmExecutiveDSPA Class
    public static void sendEmailToCrmExecutiveSPA(List<PropStrength__Property__c> propList, Map<Id, PropStrength__Property__c> oldPropMap) {
        Set<Id> propId = new Set<Id>();
        Set<Id> mouPropId = new Set<Id>();
        Set<Id> dspPropId = new Set<Id>();
        for(PropStrength__Property__c prop: propList) {
            if(prop.Area_confirmation_Date_Time__c != null && prop.Area_Confirmation_by_Sales_Ops_Date__c != null && prop.Material_Specification_Uploaded__c != null && prop.District_Plan_Uploaded__c != null && prop.Floor_Plan_Uploaded__c != null && prop.Unit_Plan_Uploaded__c != null && (prop.Area_confirmation_Date_Time__c != oldPropMap.get(prop.Id).Area_confirmation_Date_Time__c || prop.Floor_Plan_Uploaded__c != oldPropMap.get(prop.Id).Floor_Plan_Uploaded__c || prop.Area_Confirmation_by_Sales_Ops_Date__c != oldPropMap.get(prop.Id).Area_Confirmation_by_Sales_Ops_Date__c || prop.Material_Specification_Uploaded__c != oldPropMap.get(prop.Id).Material_Specification_Uploaded__c || prop.District_Plan_Uploaded__c != oldPropMap.get(prop.Id).District_Plan_Uploaded__c || prop.Unit_Plan_Uploaded__c != oldPropMap.get(prop.Id).Unit_Plan_Uploaded__c)) {
                propId.add(prop.Id);
            }
            
            if(prop.Annexure_Document_Uploaded__c != null && prop.Annexure_Document_Uploaded__c != oldPropMap.get(prop.Id).Annexure_Document_Uploaded__c) {
                mouPropId.add(prop.Id);
            }
            
            if(prop.Plot_Location_Plan_Uploaded__c != null && prop.Annexure_Document_Uploaded__c != null && (prop.Plot_Location_Plan_Uploaded__c != oldPropMap.get(prop.Id).Plot_Location_Plan_Uploaded__c || prop.Annexure_Document_Uploaded__c != oldPropMap.get(prop.Id).Annexure_Document_Uploaded__c)) {
                dspPropId.add(prop.Id);
            }
        }
        
        if(!propId.isEmpty()) {
            List<PropStrength__Property__c> propBookRecs = [SELECT Id, (SELECT Id FROM PropStrength__Application_Booking__r WHERE Notification_to_CRM_Executive_for_SPA__c = FALSE AND PropStrength__Active__c = TRUE AND ( (SPA_Transaction_Exception__c = TRUE) OR (Qualification_Date__c != null)) ORDER By CreatedDate DESC LIMIT 1) FROM PropStrength__Property__c WHERE Id IN :propId];
            System.debug('propBookRecs SPA***'+propBookRecs);
            if(!propBookRecs.isEmpty()) {
                Set<Id> bookId = new Set<Id>();
                for(PropStrength__Property__c prop: propBookRecs) {
                    if(!prop.PropStrength__Application_Booking__r.isEmpty()){
                        bookId.add(prop.PropStrength__Application_Booking__r[0].Id);
                    }
                }
                if(!bookId.isEmpty() && !System.isBatch()) {
                    BookingTriggerHelper.sendMailToSPAExecCRM(bookId);
                }
            }
        }
        
        if(!mouPropId.isEmpty()) {
            List<PropStrength__Property__c> propBookRecs = [SELECT Id, (SELECT Id FROM PropStrength__Application_Booking__r WHERE Notification_to_CRM_Executive_for_MOU__c = FALSE AND (MOU_Transaction_Exception__c = TRUE OR (PropStrength__Status__c = 'Audit Approved' AND Notification_Sent_Date_to_CRM_for_MOU__c = null AND PropStrength__Total_Paid_Percent__c >= 9.5)) AND PropStrength__Active__c = TRUE ORDER By CreatedDate DESC LIMIT 1) FROM PropStrength__Property__c WHERE Id IN :mouPropId];
            System.debug('propBookRecs MOU***'+propBookRecs);
            if(!propBookRecs.isEmpty()) {
                Set<Id> bookId = new Set<Id>();
                for(PropStrength__Property__c prop: propBookRecs) {
                    if(!prop.PropStrength__Application_Booking__r.isEmpty()){
                        bookId.add(prop.PropStrength__Application_Booking__r[0].Id);
                    }
                }
                if(!bookId.isEmpty() && !System.isBatch()) {
                    BookingTriggerHelper.sendMailToMOUExecCRM(bookId);
                }
            }
        }
        
        if(!dspPropId.isEmpty()) {
            List<PropStrength__Property__c> propBookRecs = [SELECT Id, (SELECT Id FROM PropStrength__Application_Booking__r WHERE (DSPA_Transaction_Exception__c = TRUE OR MOU_Executed__c = TRUE) AND Notification_to_CRM_Executive_for_DSPA__c = FALSE AND PropStrength__Active__c = TRUE ORDER By CreatedDate DESC LIMIT 1) FROM PropStrength__Property__c WHERE Id IN :dspPropId];
            System.debug('propBookRecs DSP***'+propBookRecs);
            if(!propBookRecs.isEmpty()) {
                Set<Id> bookId = new Set<Id>();
                for(PropStrength__Property__c prop: propBookRecs) {
                    if(!prop.PropStrength__Application_Booking__r.isEmpty()){
                        bookId.add(prop.PropStrength__Application_Booking__r[0].Id);
                    }
                }
                if(!bookId.isEmpty() && !System.isBatch()) {
                    BookingTriggerHelper.sendMailToDSPAExecCRM(bookId);
                }
            }
        }
    }
    
    //Added by Nishank Manwani to send mail to CRM Executive and Applicants when we receive field in Ready For Inspection Date field on 22 December 2023
    public static void sendEmailToCrmExecutiveReadyForInspection(List<PropStrength__Property__c> propList, Map<Id, PropStrength__Property__c> oldPropMap) {
        Set<Id> propId = new Set<Id>();
        
        for(PropStrength__Property__c prop : propList) {
            if(prop.Ready_For_Inspection__c != null && oldPropMap.get(prop.Id).Ready_For_Inspection__c != prop.Ready_For_Inspection__c) {
                propId.add(prop.Id);
            }
        }
        
        if(!propId.isEmpty()) {
            PropertyTriggerHelper.sendMailForPropertyInspection(propId);
        }
    }
    
    //Added by Nishank Manwani to send mail to CRM Executive and Applicants when we receive field in Ready For Inspection Date field on 22 December 2023
    @Future(Callout=True)
    public static void sendMailForPropertyInspection(Set<Id> propIds) {
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> sendToCC = new List<String>(); 
        String tempId = '';
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        List<PropStrength__Property__c> prop = [SELECT Id, (SELECT Id FROM PropStrength__Application_Booking__r WHERE PropStrength__Active__c = TRUE ORDER BY CreatedDate DESC LIMIT 1) FROM PropStrength__Property__c WHERE Id IN :propIds];
        Set<Id> bookId = new Set<Id>();
        if(!prop.isEmpty()) {
            for(PropStrength__Property__c p : prop) {
                if(!p.PropStrength__Application_Booking__r.isEmpty()) {
                    bookId.add(p.PropStrength__Application_Booking__r[0].Id);
                }
            }
        }
        List<PropStrength__Application_Booking__c> bookRecs = [SELECT Id, PropStrength__Property__c, CRM_Executive_Email__c, CRM_Executive__c, (SELECT Id, PropStrength__Applicant_Email__c, PropStrength__Customer_Name__c, PropStrength__Applicant_Acc__c FROM PropStrength__Applicant_Details__r ORDER BY PropStrength__Type__c) 
                                                               FROM PropStrength__Application_Booking__c
                                                               WHERE Id IN :bookId AND PropStrength__Active__c = true ORDER BY CreatedDate DESC];
        
        
        
        if(!bookRecs.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Property_Ready_For_Inspection'];
            tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            
            for(PropStrength__Application_Booking__c book : bookRecs) {
                if(book.CRM_Executive_Email__c != null) {
                    sendToCC.add(book.CRM_Executive_Email__c); 
                }
                if(!book.PropStrength__Applicant_Details__r.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appDet : book.PropStrength__Applicant_Details__r) {
                        if(appDet.PropStrength__Applicant_Email__c != null) {
                            sendTo.add(appDet.PropStrength__Applicant_Email__c);
                        }
                    }
                }
            }
            
            for(PropStrength__Application_Booking__c book : bookRecs) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                if(!sendToCC.isEmpty()) {
                    email.setCcAddresses(sendToCC);
                }
                email.setWhatId(book.PropStrength__Property__c);
                email.setTargetObjectId(book.CRM_Executive__c);
                email.setTreatTargetObjectAsRecipient(False);
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                system.debug('sendTo::'+sendTo);
                system.debug('book.CRM_Executive_Email__c::'+book.CRM_Executive_Email__c);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    
    public static void createTRrecordOnNewSuperArea(List<PropStrength__Property__c> propList, Map<Id, PropStrength__Property__c> oldPropMap) {
        Map<String,Decimal> mapOFpropIdAndValue = new Map<String,Decimal>();
        Set<Id> propId = new Set<Id>();
        
        for(PropStrength__Property__c prop : propList) {
            if(prop.PropStrength__Super_Area__c != null && prop.New_Super_Area__c != null && 
            (oldPropMap.get(prop.Id).PropStrength__Super_Area__c != prop.PropStrength__Super_Area__c || oldPropMap.get(prop.Id).New_Super_Area__c != prop.New_Super_Area__c) 
            && prop.PropStrength__Allotted__c) {
                Decimal diffPercent = 0.0;
                if(prop.PropStrength__Super_Area__c < prop.New_Super_Area__c) {
                    Decimal absoluteDifference = Math.abs(prop.New_Super_Area__c - prop.PropStrength__Super_Area__c);
                    diffPercent = (absoluteDifference / prop.PropStrength__Super_Area__c) * 100;
                } else if(prop.PropStrength__Super_Area__c > prop.New_Super_Area__c) {
                    Decimal absoluteDifference = Math.abs(prop.PropStrength__Super_Area__c - prop.New_Super_Area__c);
                    diffPercent = (absoluteDifference / prop.New_Super_Area__c) * 100;
                }

                System.debug('diffPercent***');
                System.debug(diffPercent);

                if(oldPropMap.get(prop.Id).PropStrength__Super_Area__c != prop.PropStrength__Super_Area__c) {
                    mapOFpropIdAndValue.put(prop.Id, prop.PropStrength__Super_Area__c);
                }
                
                if(diffPercent < 5) {
                    propId.add(prop.Id);
                }
            }
        }
        
        if(mapOFpropIdAndValue.size() > 0){ 
            list<PropStrength__Transaction_Requests__c> listOfTrRec = new list<PropStrength__Transaction_Requests__c>();           
            
            for(PropStrength__Application_Booking__c bookRec : [SELECT Id,PropStrength__Property__c from PropStrength__Application_Booking__c Where PropStrength__Property__c IN:mapOFpropIdAndValue.keySet() AND PropStrength__Active__c = true]){
                PropStrength__Transaction_Requests__c trRec = new PropStrength__Transaction_Requests__c();
                trRec.PropStrength__Application_Booking__c = bookRec.Id;
                listOfTrRec.add(trRec);
            }

            if(listOfTrRec.size() > 0) {
                insert listOfTrRec;
            }
        }
        
        if(!propId.isEmpty()) {
            List<PropStrength__Property__c> propertyList = [SELECT Id, 
                                                            (SELECT Id, PropStrength__Project__r.Master_Project__r.Inventory_Team_Email__c, 
                                                            CRM_Executive__c 
                                                            FROM PropStrength__Application_Booking__r 
                                                            WHERE PropStrength__Active__c = TRUE AND SPA_Executed__c = TRUE ORDER BY CreatedDate DESC) 
                                                            FROM PropStrength__Property__c WHERE Id IN :propId];

            String TempId;
            String searchTxt = 'SaleableAreaChangeMailTemplate';
            List<EmailTemplate> templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }

            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();

            for(PropStrength__Property__c prop : propertyList) {
                if(!prop.PropStrength__Application_Booking__r.isEmpty()) {
                    PropStrength__Application_Booking__c booking = prop.PropStrength__Application_Booking__r[0];

                    if(booking.PropStrength__Project__r.Master_Project__r.Inventory_Team_Email__c != null) {
                        List<String> toAddList = new List<String>();
                        toAddList.add(booking.PropStrength__Project__r.Master_Project__r.Inventory_Team_Email__c);

                        Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();

                        if(!toAddList.isEmpty()) {
                            emails.setWhatId(prop.Id);
                            emails.setToAddresses(toAddList); 
                            emails.setTemplateId(TempId);
                            emails.setSaveAsActivity(true); 
                            emails.setTargetObjectId(booking.CRM_Executive__c);
                            emails.setTreatTargetObjectAsRecipient(false); 
                            emaillist.add(emails);
                        }
                    }
                }
            }

            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
    
    public class requestBodyWrapper{
        String floorNumber;
        string unitType;
        string unitName;
        Decimal unitPrice;
        String unitNumber;
        boolean isNotAvailableForSale;
        String availabilityStatus;
        String DLDBuildingNumber;
        Decimal noOfBedrooms;
        String permittedUse;
        String projectPropertyType;
        Decimal noOfParkings;
        String propertyType;
        String parkingType;
        Decimal totalArea;
        Decimal saleableArea;
        Decimal plotArea;
        Decimal RERAApplicableArea;
        String plotNumber;
        String sfUnitId;
        String sfCommunityId;
        String sfTowerId;
        String sfMasterCommunityId;
        String views;
        String parkingBays;
    }

    //Added by Nishank Manwani on 30-04-2024 to send mail when Saleable Area field's value is changed
    public static void sendMailOnSaleableChange(List<PropStrength__Property__c> propList, Map<Id, PropStrength__Property__c> oldPropMap) {
        Set<Id> propId = new Set<Id>();
        
        for(PropStrength__Property__c prop : propList) {
            if(prop.PropStrength__Super_Area__c != null && prop.PropStrength__Super_Area__c != oldPropMap.get(prop.Id).PropStrength__Super_Area__c) {
                propId.add(prop.Id);
            }
        }

        if(!propId.isEmpty()) {
            List<PropStrength__Property__c> propertyList = [SELECT Id, 
                                                            (SELECT Id, CRM_Executive__c, SPA_Executed__c, 
                                                            PropStrength__Project__r.Master_Project__r.Inventory_Team_Email__c,
                                                            Docusign_Sales_Ops_Email__c, CRM_Executive_Email__c 
                                                            FROM PropStrength__Application_Booking__r 
                                                            WHERE PropStrength__Active__c = TRUE ORDER BY CreatedDate DESC) 
                                                            FROM PropStrength__Property__c WHERE Id IN :propId];

            String TempId;
            String searchTxt = 'SaleableAreaChangeMailTemplate';
            List<EmailTemplate> templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }

            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();

            for(PropStrength__Property__c prop : propertyList) {
                if(!prop.PropStrength__Application_Booking__r.isEmpty()) {
                    PropStrength__Application_Booking__c booking = prop.PropStrength__Application_Booking__r[0];

                    if(booking.Docusign_Sales_Ops_Email__c != null && booking.CRM_Executive_Email__c != null) {
                        List<String> toAddList = new List<String>();
                        toAddList.add(booking.Docusign_Sales_Ops_Email__c);
                        toAddList.add(booking.CRM_Executive_Email__c); 
                        if(booking.PropStrength__Project__r.Master_Project__r.Inventory_Team_Email__c != null) {
                            toAddList.add(booking.PropStrength__Project__r.Master_Project__r.Inventory_Team_Email__c);                       
                        }

                        Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();

                        if(!toAddList.isEmpty()) {
                            emails.setWhatId(prop.Id);
                            emails.setToAddresses(toAddList); 
                            emails.setTemplateId(TempId);
                            emails.setSaveAsActivity(true); 
                            emails.setTargetObjectId(booking.CRM_Executive__c);
                            emails.setTreatTargetObjectAsRecipient(false); 
                            emaillist.add(emails);
                        }
                    }
                }
            }

            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
}