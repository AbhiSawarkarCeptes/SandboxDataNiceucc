public class CallRecordTriggerHelper {
    //Create a Task under Enquiry in case of Inbound or Create Task under Contact in case of Outbound
    public static void createTaskOnEnquiry(List<VCC1__Call_Record__c> newCallRecordList) {
        Set<String> callIds = new Set<String>();
        Set<String> conIds = new Set<String>();
        Map<String, PropStrength__Request__c> callIdToEnqMap = new Map<String, PropStrength__Request__c>();
        Map<String, String> contactIdToOwnerId = new Map<String, String>();
        List<Task> tasRecordList = new List<Task>();
        Set<Id> requestIds = new Set<Id>();
        List<Attempt_Tracking__c> requestList = new List<Attempt_Tracking__c>();
        for(VCC1__Call_Record__c callRecord : newCallRecordList) {
            if(callRecord.VCC1__Call_Type__c == 'Inbound' && 
                !String.isBlank(callRecord.VCC1__Call_Id__c) && 
                !String.isBlank(callRecord.VCC1__Status__c)) {
                callIds.add(callRecord.VCC1__Call_Id__c);
            } else if(callRecord.VCC1__Call_Type__c == 'Outbound' && 
                callRecord.VCC1__Contact__c != null) {
                conIds.add(callRecord.VCC1__Contact__c);
            }
        }
        if(!callIds.isEmpty()) {
            for(PropStrength__Request__c enq : [SELECT Id, Call_Id__c, OwnerId 
                                                FROM PropStrength__Request__c 
                                                WHERE Call_Id__c IN: callIds 
                                                    ORDER BY CreatedDate LIMIT 49999]) {
                callIdToEnqMap.put(enq.Call_Id__c, enq);
            }
        }
        if(!conIds.isEmpty()) {
            for(Contact conRecord : [SELECT Id, OwnerId FROM Contact WHERE Id IN: conIds LIMIT 49999]) {
                contactIdToOwnerId.put(conRecord.Id, conRecord.OwnerId);
            }
        }
        for(VCC1__Call_Record__c callRec : newCallRecordList) {
            if(!String.isBlank(callRec.VCC1__Call_Id__c) && 
                !String.isBlank(callRec.VCC1__Status__c)) {
                DateTime gmtDateTime = System.now();
                TimeZone currentTimeZone = UserInfo.getTimeZone();
                String currentDateTimeString = gmtDateTime.format('dd-MM-yyyy hh:mm:ss') + ' (' + currentTimeZone.toString() + ')';
                if(callRec.VCC1__Call_Type__c == 'Inbound') {
                    Task tasRecord = new Task();
                    tasRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales and Sales').getRecordTypeId();
                    tasRecord.Task_type__c = 'Presales Call';
                    tasRecord.Subject = 'Inbound ' + callRec.VCC1__Status__c + ' Call ' + currentDateTimeString;
                    tasRecord.WhoId = callRec.VCC1__Contact__c != null ? callRec.VCC1__Contact__c : null;
                    tasRecord.WhatId = (callIdToEnqMap.containskey(callRec.VCC1__Call_Id__c) ? callIdToEnqMap.get(callRec.VCC1__Call_Id__c).Id : null);
                    tasRecord.Call_Record__c = callRec.Id;
                    tasRecord.CallObject = callRec.VCC1__Call_Id__c;
                    tasRecord.ActivityDate = System.today();
                    tasRecord.Communication_type__c = 'Inbound Call';
                    tasRecord.CallType = 'Inbound';
                    tasRecord.OwnerId = (callIdToEnqMap.containskey(callRec.VCC1__Call_Id__c) && callIdToEnqMap.get(callRec.VCC1__Call_Id__c).OwnerId != null ? callIdToEnqMap.get(callRec.VCC1__Call_Id__c).OwnerId : callRec.OwnerId);
                    tasRecordList.add(tasRecord);
                } else if(callRec.VCC1__Call_Type__c == 'Outbound' && 
                    callRec.VCC1__Contact__c != null && 
                    !String.isBlank(callRec.VCC1__Call_Initiate_Record_Id__c)) {
                    Id initiateId = Id.valueOf(callRec.VCC1__Call_Initiate_Record_Id__c);
                    System.debug('===> initiateId ' + initiateId);
                    String objAPIName = initiateId.getSObjectType().getDescribe().getName();
                    System.debug('===> objAPIName ' + objAPIName);
                    Task taskRecord = new Task();
                    taskRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales and Sales').getRecordTypeId();
                    taskRecord.Task_type__c = 'Presales Call';
                    taskRecord.Subject = 'Outbound ' + callRec.VCC1__Status__c + ' Call ' + currentDateTimeString;
                    taskRecord.WhoId = callRec.VCC1__Contact__c;
                    taskRecord.WhatId = ((objAPIName == 'PropStrength__Request__c' || objAPIName == 'PropStrength__Application_Booking__c' ) ? callRec.VCC1__Call_Initiate_Record_Id__c : null);
                    taskRecord.Call_Record__c = callRec.Id;
                    taskRecord.CallObject = callRec.VCC1__Call_Id__c;
                    taskRecord.ActivityDate = System.today();
                    taskRecord.Communication_type__c = 'Outbound Call';
                    taskRecord.CallType = 'Outbound';
                    taskRecord.OwnerId = contactIdToOwnerId.containskey(callRec.VCC1__Contact__c) ? contactIdToOwnerId.get(callRec.VCC1__Contact__c) : callRec.OwnerId;
                    tasRecordList.add(taskRecord);
                    if(callRec.VCC1__Status__c == 'Missed' && objAPIName == 'PropStrength__Request__c') {
                        requestIds.add(callRec.VCC1__Call_Initiate_Record_Id__c);
                    }
                }
            }
        }
        if(!requestIds.isEmpty()) {
            for(Attempt_Tracking__c attempt : [SELECT Id FROM Attempt_Tracking__c 
                                                WHERE Day_Tracking__r.Enquiry__c IN: requestIds AND 
                                                    Status__c = null AND 
                                                    Name = 'Sobha Landline' 
                                                    ORDER BY CreatedDate DESC LIMIT 49999]) {
                attempt.Status__c = 'No Contact - Follow-up';
                requestList.add(attempt);
            }
        }
        if(!tasRecordList.isEmpty()) {
            Database.SaveResult[] saveTaskResult = Database.insert(tasRecordList, false);
            for(Database.SaveResult srTask : saveTaskResult) {
                if(srTask.isSuccess()) {
                    System.debug('===> Task Id: ' + srTask.getId());
                } else {
                    for(Database.Error errTask : srTask.getErrors()) {
                        System.debug('===> Exception: ' + errTask.getMessage());
                    }
                }
            }
        }
        if(!requestList.isEmpty()) {
            Database.SaveResult[] saveUpdateResult = Database.update(requestList, false);
            for(Database.SaveResult srUpdate : saveUpdateResult) {
                if(srUpdate.isSuccess()) {
                    System.debug('===> Attempt Id: ' + srUpdate.getId());
                } else {
                    for(Database.Error errUpdate : srUpdate.getErrors()) {
                        System.debug('===> Exception: ' + errUpdate.getMessage());
                    }
                }
            }
        }
    }

    //Added by Nishank Manwani on 29'Aug 2024 to send mail for Non-Contactable to applicants
    public static void sendMailForNonContact(List<VCC1__Call_Record__c> callRecList, Map<Id, VCC1__Call_Record__c> oldCallRecMap) {
        Set<Id> bookId = new Set<Id>();
        for(VCC1__Call_Record__c callRec : callRecList) {
            if(callRec.VCC1__Status__c == 'Missed' && callRec.Application_Booking__c != null && oldCallRecMap.get(callRec.Id).Application_Booking__c != callRec.Application_Booking__c) {
                bookId.add(callRec.Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookingList = [SELECT Id,PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,
                        (SELECT ID, PropStrength__Applicant_Email__c, PropStrength__Applicant_Acc__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Applicant_Email__c != null AND PropStrength__Active__c = true)
                        FROM PropStrength__Application_Booking__c 
                        WHERE Id IN : bookId AND PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c = true];

            if(!bookingList.isEmpty()) {
                StaticResource staticRes = [SELECT Body FROM StaticResource WHERE Name = 'CUIF_Siniya'];
                Blob pdfBlob = staticRes.Body;
                
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();

                if( !test.isrunningtest()) {
                    owea = [SELECT id, DisplayName from OrgWideEmailAddress WHERE DisplayName =: System.Label.Siniya_Contact_From_Address_Email limit 1]; 
                }
                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                    FROM EmailTemplate 
                                    WHERE (DeveloperName =: 'Non_Contactable_Call_Records_Siniya')];


                String tempId = !emailTemplate.isEmpty() ? emailTemplate[0].Id : '';

                for(PropStrength__Application_Booking__c book : bookingList) {
                    for(PropStrength__Applicant_Detail__c appDet : book.PropStrength__Applicant_Details__r) {
                        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
                        List<String> sendTo = new List<String>();
                        sendTo.add(appDet.PropStrength__Applicant_Email__c);

                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(sendTo);
                        email.setWhatId(appDet.Id);
                        email.setTargetObjectId(appDet.PropStrength__Applicant_Acc__c);
                        email.setTreatTargetObjectAsRecipient(False);
                        email.setSaveAsActivity(true); 
                        email.setTemplateId(tempId);
                        if (!owea.isEmpty()) {
                            email.setOrgWideEmailAddressId(owea[0].Id);
                        }
                        if(pdfBlob != null) {
                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                            efa.setFileName('CUIF Siniya 2.pdf');
                            efa.setBody(pdfBlob);
                            efalst.add(efa);
                        }
                        if(!efalst.isEmpty()) {
                            email.setFileAttachments(efalst);
                        }
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
    }
}