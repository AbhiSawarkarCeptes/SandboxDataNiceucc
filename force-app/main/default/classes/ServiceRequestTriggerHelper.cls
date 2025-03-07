/*********************************************************************
* Class Name  :   ServiceRequestTriggerHelper
* Description :   Helper class of ServiceRequestTrigger
* Created Date:   25/01/2024
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Nishank Manwani
Last Modified By :   Nishank Manwani 25/01/2024
*********************************************************************/
public class ServiceRequestTriggerHelper {
    public static Boolean isRun = true;
    
    //Added by Nishank Manwani on 25/01/2024 to update owner if mail is receive from Collection@sobharealty.com
    //Modified by Nishank Manwani on 14-05-2024 to update assignment groups
    public static void updateOwner(List<PropStrength__Service_Request__c> srList) {
        Set<Id> bookingId = new Set<Id>();
        Map<String, PropStrength__Assignment_Group_Name__c> assGrpMap = new Map<String, PropStrength__Assignment_Group_Name__c>();
        List<PropStrength__Assignment_Group_Name__c> grpList = [SELECT Id, Name, (SELECT Id, PropStrength__User__c, PropStrength__Order__c, PropStrength__Last_Assigned__c FROM PropStrength__Group_Members__r WHERE PropStrength__Active__c = 'TRUE' ORDER BY PropStrength__Order__c) FROM PropStrength__Assignment_Group_Name__c WHERE PropStrength__Active__c = TRUE AND PropStrength__Type__c = 'Service Request'];
        List<PropStrength__Group_Member__c> updateGrpMem = new List<PropStrength__Group_Member__c>();
        
        if(!grpList.isEmpty()) {
            for(PropStrength__Assignment_Group_Name__c grp: grpList) {
                if(grp.Name == 'Collections Queue') {
                    assGrpMap.put('collections@sobharealty.com', grp);
                } else if(grp.Name == 'Main Queue') {
                    assGrpMap.put('Main Queue', grp);
                } else if(grp.Name == 'Siniya Island SR Assignment Group') {
                    assGrpMap.put('customercare@SobhaSiniyaIsland.com', grp);
                }
            }  
        }
        System.debug('assGrpMap::'+assGrpMap);
        
        for(PropStrength__Service_Request__c sr : srList) {
            if(sr.PropStrength__Origin__c == 'Email' && sr.To_Email_Address__c == 'customercare@SobhaSiniyaIsland.com' && assGrpMap.containsKey(sr.To_Email_Address__c) && !assGrpMap.get(sr.To_Email_Address__c).PropStrength__Group_Members__r.isEmpty()) {
                List<PropStrength__Group_Member__c> userInfo = assGrpMap.get(sr.To_Email_Address__c).PropStrength__Group_Members__r;
                Id userId;
                for(Integer i=0 ; i < userInfo.size(); i++) {
                    if(userInfo[i].PropStrength__Last_Assigned__c) {
                        if(i == userInfo.size()-1) {updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[0].Id, PropStrength__Last_Assigned__c = true)); updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i].Id, PropStrength__Last_Assigned__c = false)); userId = userInfo[0].PropStrength__User__c;
                        } else {
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i+1].Id, PropStrength__Last_Assigned__c = true));
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i].Id, PropStrength__Last_Assigned__c = false));
                            userId = userInfo[i+1].PropStrength__User__c;
                        }
                    }
                }
                System.debug('userId: ' + userId);
                if(userId == null) {userId = userInfo[0].PropStrength__User__c; updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[0].Id, PropStrength__Last_Assigned__c = true));
                }
                sr.OwnerId = userId;
                sr.PropStrength__Status__c = 'New'; 
                sr.SR_Assigned_Date__c = System.now();
            } else if(sr.PropStrength__Origin__c == 'Email' && sr.To_Email_Address__c == 'collections@sobharealty.com' && sr.PropStrength__Application_Booking__c != null) {
                bookingId.add(sr.PropStrength__Application_Booking__c);
            } else if(sr.PropStrength__Origin__c == 'Email' && sr.To_Email_Address__c == 'collections@sobharealty.com' && assGrpMap.containsKey(sr.To_Email_Address__c) && !assGrpMap.get(sr.To_Email_Address__c).PropStrength__Group_Members__r.isEmpty()) {
                List<PropStrength__Group_Member__c> userInfo = assGrpMap.get(sr.To_Email_Address__c).PropStrength__Group_Members__r;
                Id userId;
                for(Integer i=0 ; i < userInfo.size(); i++) {
                    if(userInfo[i].PropStrength__Last_Assigned__c) {
                        if(i == userInfo.size()-1) {
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[0].Id, PropStrength__Last_Assigned__c = true));
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i].Id, PropStrength__Last_Assigned__c = false));
                            userId = userInfo[0].PropStrength__User__c;
                        } else {
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i+1].Id, PropStrength__Last_Assigned__c = true));
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i].Id, PropStrength__Last_Assigned__c = false));
                            userId = userInfo[i+1].PropStrength__User__c;
                        }
                    }
                }
                System.debug('userId: ' + userId);
                if(userId == null) {userId = userInfo[0].PropStrength__User__c; updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[0].Id, PropStrength__Last_Assigned__c = true));
                }
                sr.OwnerId = userId;
                sr.PropStrength__Status__c = 'New'; 
                sr.SR_Assigned_Date__c = System.now();
            } else if(sr.PropStrength__Origin__c == 'Email' && sr.To_Email_Address__c != null && assGrpMap.containsKey('Main Queue') && !assGrpMap.get('Main Queue').PropStrength__Group_Members__r.isEmpty()) {
                List<PropStrength__Group_Member__c> userInfo = assGrpMap.get('Main Queue').PropStrength__Group_Members__r;
                Id userId;
                for(Integer i=0 ; i < userInfo.size(); i++) {
                    if(userInfo[i].PropStrength__Last_Assigned__c) {
                        if(i == userInfo.size()-1) {updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[0].Id, PropStrength__Last_Assigned__c = true)); updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i].Id, PropStrength__Last_Assigned__c = false)); userId = userInfo[0].PropStrength__User__c;
                        } else {
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i+1].Id, PropStrength__Last_Assigned__c = true));
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i].Id, PropStrength__Last_Assigned__c = false));
                            userId = userInfo[i+1].PropStrength__User__c;
                        }
                    }
                }
                System.debug('userId: ' + userId);
                if(userId == null) {
                    userId = userInfo[0].PropStrength__User__c;
                    updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[0].Id, PropStrength__Last_Assigned__c = true));
                }
                sr.OwnerId = userId;
                sr.PropStrength__Status__c = 'New'; 
                sr.SR_Assigned_Date__c = System.now();
            }
            
            /*if(sr.PropStrength__Origin__c == 'Email' && sr.To_Email_Address__c == 'support@sobharealty.com' && assGrpMap.containsKey(sr.To_Email_Address__c) && !assGrpMap.get(sr.To_Email_Address__c).PropStrength__Group_Members__r.isEmpty()) {
                List<PropStrength__Group_Member__c> userInfo = assGrpMap.get(sr.To_Email_Address__c).PropStrength__Group_Members__r;
                Id userId;
                for(Integer i=0 ; i < userInfo.size(); i++) {
                    if(userInfo[i].PropStrength__Last_Assigned__c) {
                        if(i == userInfo.size()-1) {
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[0].Id, PropStrength__Last_Assigned__c = true));
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i].Id, PropStrength__Last_Assigned__c = false));
                            userId = userInfo[0].PropStrength__User__c;
                        } else {
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i+1].Id, PropStrength__Last_Assigned__c = true));
                            updateGrpMem.add(new PropStrength__Group_Member__c(Id = userInfo[i].Id, PropStrength__Last_Assigned__c = false));
                            userId = userInfo[i+1].PropStrength__User__c;
                        }
                    }
                }
                System.debug('userId: ' + userId);
                sr.OwnerId = userId;
            }*/
        }
        
        System.debug('updateGrpMem: ');
        System.debug(updateGrpMem);
        
        if(!updateGrpMem.isEmpty()) {
            update updateGrpMem;
        }
        
        if(!bookingId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id,  
                                                                                                                       PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__c FROM PropStrength__Application_Booking__c 
                                                                                                                       WHERE Id IN :bookingId]);
            
            for(PropStrength__Service_Request__c sr : srList) {
                if(sr.PropStrength__Origin__c == 'Email' && sr.To_Email_Address__c == 'collections@sobharealty.com' && sr.PropStrength__Application_Booking__c != null) {
                    sr.OwnerId = bookMap.get(sr.PropStrength__Application_Booking__c).PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__c;
                    sr.PropStrength__Status__c = 'New'; 
                    sr.SR_Assigned_Date__c = System.now();
                }
            }
        }
    }
    
    public static void pushProfileCase(List<PropStrength__Service_Request__c> srList,Map<Id,PropStrength__Service_Request__c> oldMap) {
        Set<Id> srIds = new Set<Id>();
        for(PropStrength__Service_Request__c sr : srList) {
            if(sr.PropStrength__Request_Origin__c == 'Mobile App' &&
               !String.isBlank(sr.PropStrength__Status__c) &&
               sr.PropStrength__Status__c == 'Closed' &&
               sr.PropStrength__Status__c != oldMap.get(sr.Id).PropStrength__Status__c) {
                   srIds.add(sr.Id);
               }
        }
        System.debug('srIds*---'+srIds);
        if(!srIds.isEmpty() && !System.IsBatch() && !System.isFuture()) {
            ServiceRequestTriggerHelper.pushProfileCaseAPI(srIds);
        }
    }
    
    @Future(Callout=True)
    public static void pushProfileCaseAPI(Set<Id> srIds) {
        if(!srIds.isEmpty()) {
            Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
            String sftoken = mobile_appmdt.sf_Token__c;
            String Subscription_Key = mobile_appmdt.Subscription_Key__c;
            String endPointURL = mobile_appmdt.Profile_Case_Endpoint__c;
            List<Mobile_App_Log__c> insertList = new List<Mobile_App_Log__c>();
            List<PropStrength__Service_Request__c> newList = [SELECT Id,PropStrength__Status__c,PropStrength__Description__c
                                                              FROM PropStrength__Service_Request__c
                                                              WHERE Id IN: srIds];
            if(!newList.isEmpty()) {
                requestBodyWrapper wrap = new requestBodyWrapper();
                try {
                    for(PropStrength__Service_Request__c bk : newList) {
                        wrap.status = (bk.PropStrength__Status__c != null && bk.PropStrength__Status__c == 'Closed') ? 'Approved' : '';
                        wrap.sfCaseId = bk.Id;
                        wrap.remarks = (bk.PropStrength__Description__c != null && bk.PropStrength__Description__c != '') ? bk.PropStrength__Description__c : null;
                    }
                    if(wrap != null) {
                        string serializedJSON = JSON.serialize(wrap);
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
                            if(response.getStatusCode() == 200) {
                                for(PropStrength__Service_Request__c bk : newList) {
                                    Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                    appLog.Service_Request__c = bk.Id;
                                    appLog.Request_Body__c = serializedJSON;
                                    appLog.Status__c = 'Success';
                                    appLog.API_Name__c = endPointURL;
                                    appLog.Response_Body__c = response.getBody();
                                    insertList.add(appLog);
                                }
                                system.debug('Success:::'+response.getBody());
                                if(!insertList.isEmpty()) {
                                    insert insertList;
                                }
                            } else {
                                for(PropStrength__Service_Request__c bk : newList) {
                                    Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                    appLog.Service_Request__c = bk.Id;
                                    appLog.Status__c = 'Error';
                                    appLog.API_Name__c = endPointURL;
                                    appLog.Request_Body__c = serializedJSON;
                                    appLog.Response_Body__c = response.getBody();
                                    insertList.add(appLog);
                                }
                                system.debug('Error:::'+response.getBody());
                                if(!insertList.isEmpty()) {
                                    insert insertList;
                                }
                            }
                        }
                    }
                } catch(Exception e) {
                    for(PropStrength__Service_Request__c bk : newList) {
                        Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                        appLog.Service_Request__c = bk.Id;
                        appLog.Status__c = 'Exception';
                        appLog.API_Name__c = endPointURL;
                        appLog.Request_Body__c = JSON.serialize(wrap);
                        appLog.Response_Body__c = String.valueOf(e.getStackTraceString());
                        insertList.add(appLog);
                    }
                    if(!insertList.isEmpty()) {
                        insert insertList;
                    }
                    system.debug('~~~~~Error: '+e.getStackTraceString());
                }
            }
        }
    }
    
    public class requestBodyWrapper{
        String status;
        String sfCaseId;
        String remarks;
    }
    
    public static boolean runOnce(){
        if(isRun) {
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }


    //Added by Nishank Manwani on 08-05-2024 to send mail to the customer on creation of SR
    public static void sendAutoMailToCustomer(List<PropStrength__Service_Request__c> srList) {
        Set<Id> srId = new Set<Id>();
        for(PropStrength__Service_Request__c sr : srList) {
            if(sr.PropStrength__Origin__c == 'Email' && sr.To_Email_Address__c != 'customercare@SobhaSiniyaIsland.com') {
                srId.add(sr.Id);
            }
        }

        if(!srId.isEmpty()) {
            List<PropStrength__Service_Request__c> srNewList = [SELECT Id, Contact__c, Contact__r.Email FROM PropStrength__Service_Request__c WHERE Id IN :srId];

            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String tempId = '';
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                    FROM EmailTemplate 
                                                    WHERE DeveloperName =: 'SR_Send_Auto_Mail'];
            tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'helpdesk@sobharealty.com' AND IsVerified = true LIMIT 1];  

            for(PropStrength__Service_Request__c sr : srNewList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(sr.Contact__r.Email != null) {
                    email.setToAddresses(new List<String>{sr.Contact__r.Email});
                    email.setWhatId(sr.id);
                    email.setTargetObjectId(sr.Contact__c);
                    if(!owea.isEmpty()) {
                        email.setOrgWideEmailAddressId(owea[0].Id);
                    }
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
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }

    //Added by Nishank Manwani on 16-May-2024 to update Service Request Priority field as per SR Category and SR Sub-Category
    public static void updatePriority(List<PropStrength__Service_Request__c> srList, Map<Id, PropStrength__Service_Request__c> oldMap) {
        List<Service_Request_SLA__c> slaRecordList = [SELECT Id, SLA_in_days__c, Priority__c, SR_Sub_Category__c, Category__c FROM Service_Request_SLA__c];

        Map<String, Service_Request_SLA__c> catSubCatSLAMap = new Map<String, Service_Request_SLA__c>();

        for(Service_Request_SLA__c sla : slaRecordList) {
            if(sla.Category__c != null && sla.SR_Sub_Category__c != null) {
                String key = sla.Category__c + '##' + sla.SR_Sub_Category__c;
                if(!catSubCatSLAMap.containsKey(key)) {
                    catSubCatSLAMap.put(key, sla);
                }
            }
        }

        System.debug('catSubCatSLAMap *****');
        System.debug(catSubCatSLAMap);

        List<BusinessHours> bHourList = [SELECT Id, SundayStartTime, MondayStartTime, TuesdayStartTime, WednesdayStartTime,  
                                ThursdayStartTime, FridayStartTime, SaturdayStartTime 
                                FROM BusinessHours WHERE Name = 'Escalation Rule Business Hours'];
        BusinessHours bHour = new BusinessHours();
        if(!bHourList.isEmpty()) {
            bHour = bHourList[0];
        }

        for(PropStrength__Service_Request__c srRec : srList) {
            if(srRec.SR_Category__c != null && srRec.SR_Sub_Category__c != null) {
                if(oldMap != null) {
                    if(srRec.SR_Category__c != oldMap.get(srRec.Id).SR_Category__c || srRec.SR_Sub_Category__c != oldMap.get(srRec.Id).SR_Sub_Category__c) {
                        String key = srRec.SR_Category__c + '##' + srRec.SR_Sub_Category__c;
                        if(catSubCatSLAMap.containsKey(key)) {
                            Decimal priority = catSubCatSLAMap.get(key).Priority__c;
                            if(priority == 1) {
                                srRec.PropStrength__Priority__c = 'High';
                            } else if(priority == 2) {
                                srRec.PropStrength__Priority__c = 'Medium';
                            } else if(priority == 3) {
                                srRec.PropStrength__Priority__c = 'Low';
                            }

                            srRec.Service_Request_SLA__c = catSubCatSLAMap.get(key).Id;
                            
                            Integer holidayCount = 0;

                            if(bHour != null && bHour.Id != null) {
                                if(bHour.SundayStartTime == null) {
                                    holidayCount += 1;
                                } else if(bHour.MondayStartTime == null) {
                                    holidayCount += 1;
                                } else if(bHour.TuesdayStartTime == null) {
                                    holidayCount += 1;
                                } else if(bHour.WednesdayStartTime == null) {
                                    holidayCount += 1;
                                } else if(bHour.ThursdayStartTime == null) {
                                    holidayCount += 1;
                                } else if(bHour.FridayStartTime == null) {
                                    holidayCount += 1;
                                } else if(bHour.SaturdayStartTime == null) {
                                    holidayCount += 1;
                                }
                            }

                            Integer addDayCount = Integer.valueOf(catSubCatSLAMap.get(key).SLA_in_days__c) + holidayCount;

                            srRec.Check_SLA_Breach_Date__c = System.Today().addDays(addDayCount);
                        }
                    }
                } else {
                    String key = srRec.SR_Category__c + '##' + srRec.SR_Sub_Category__c;
                    if(catSubCatSLAMap.containsKey(key)) {
                        Decimal priority = catSubCatSLAMap.get(key).Priority__c;
                        if(priority == 1) {
                            srRec.PropStrength__Priority__c = 'High';
                        } else if(priority == 2) {
                            srRec.PropStrength__Priority__c = 'Medium';
                        } else if(priority == 3) {
                            srRec.PropStrength__Priority__c = 'Low';
                        }

                        srRec.Service_Request_SLA__c = catSubCatSLAMap.get(key).Id;

                        Integer holidayCount = 0;

                        if(bHour != null && bHour.Id != null) {
                            if(bHour.SundayStartTime == null) {
                                holidayCount += 1;
                            } else if(bHour.MondayStartTime == null) {
                                holidayCount += 1;
                            } else if(bHour.TuesdayStartTime == null) {
                                holidayCount += 1;
                            } else if(bHour.WednesdayStartTime == null) {
                                holidayCount += 1;
                            } else if(bHour.ThursdayStartTime == null) {
                                holidayCount += 1;
                            } else if(bHour.FridayStartTime == null) {
                                holidayCount += 1;
                            } else if(bHour.SaturdayStartTime == null) {
                                holidayCount += 1;
                            }
                        }

                        Integer addDayCount = Integer.valueOf(catSubCatSLAMap.get(key).SLA_in_days__c) + holidayCount;

                        srRec.Check_SLA_Breach_Date__c = System.Today().addDays(addDayCount);
                    }
                }
            }
        }
    }

    //Added by Nishank Manwani on 16-May-2024 to update SR Closed Date when SR status is closed
    public static void updateSrClosedDate(List<PropStrength__Service_Request__c> srList, Map<Id, PropStrength__Service_Request__c> oldSrMap) {
        for(PropStrength__Service_Request__c sr : srList) {
            if(sr.PropStrength__Status__c == 'Closed' && sr.PropStrength__Status__c != oldSrMap.get(sr.Id).PropStrength__Status__c) {
                sr.SR_Closed_Date__c = System.now();
            } else if(sr.OwnerId != null && sr.OwnerId != oldSrMap.get(sr.Id).OwnerId) {
                sr.SR_Re_Assigned_Date__c = System.now();
            } else if(sr.PropStrength__Status__c == 'Reopened' && sr.PropStrength__Status__c != oldSrMap.get(sr.Id).PropStrength__Status__c) {
                sr.Re_Opened_Timestamp__c = System.now();
            }
        }
    }
}