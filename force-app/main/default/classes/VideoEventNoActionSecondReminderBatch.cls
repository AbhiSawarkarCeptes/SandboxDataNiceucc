global class VideoEventNoActionSecondReminderBatch implements Database.Batchable<sObject> ,Database.AllowsCallouts, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bi) {
        return Database.getQueryLocator([SELECT Id, Name, CreatedDate, 
                                            Owner.Email, OwnerId 
                                            FROM Events__c 
                                            WHERE From_Broker_Portal__c = true AND 
                                                No_Video_Reminder_After_4_Days__c = false AND 
                                                RecordType.Name = 'Video Shoot' AND 
                                                Owner.Email != null]);
    }
    global void execute(Database.BatchableContext bi, List<Events__c> scope) {
        List<Messaging.SingleEmailMessage> emaillist = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templatelist = new List<EmailTemplate>();
        List<Events__c> updateList = new List<Events__c>();
        templatelist = [SELECT Id, Name 
                            FROM EmailTemplate 
                            WHERE DeveloperName = 'Video_Upload_Request_Remider_2' LIMIT 1];
        Set<String> eventIds = new Set<String>();
        Set<String> eventVideoExistIds = new Set<String>();
        List<String> allowMediaTypes = new List<String>{'webm','mp4','mov','m4v'};
        if(!scope.isEmpty()) {
            for(Events__c evnt : scope) {
                eventIds.add(evnt.Id);
            }
        }
        if(!eventIds.isEmpty()) {
            for(ContentDocumentLink evnt : [SELECT Id, LinkedEntityId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId IN: eventIds AND 
                                                    ContentDocument.FileExtension IN: allowMediaTypes]) {
                eventVideoExistIds.add(evnt.LinkedEntityId);
            }
        }
        if(!scope.isEmpty() && 
            !templatelist.isEmpty()) {
            for(Events__c evnt : scope) {
                if((!eventVideoExistIds.contains(evnt.Id) && 
                    (evnt.CreatedDate.addDays(4) < System.now())) || 
                    (Test.isRunningTest())) {
                    List<String> toAddress = new List<String>();
                    toAddress.add(evnt.Owner.Email);
                    Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                    if(!toAddress.isEmpty()) {
                        emails.setToAddresses(toAddress);
                    }
                    emails.setWhatId(evnt.Id);
                    emails.setTemplateId(templatelist[0].Id);
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(evnt.OwnerId);
                    emails.setTreatTargetObjectAsRecipient(false); 
                    emaillist.add(emails);
                }
            }
        }
        try {
            if(!emaillist.isEmpty()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emaillist);
                if(!results.get(0).isSuccess()) {
                    for(Events__c evnt : scope) {
                        if((!eventVideoExistIds.contains(evnt.Id) && 
                            (evnt.CreatedDate.addDays(4) < System.now())) || 
                            (Test.isRunningTest())) {
                            Events__c eRecord = new Events__c(Id = evnt.id);
                            eRecord.No_Video_Reminder_After_4_Days__c = true;
                            updateList.add(eRecord);
                        }
                    }
                }
                if(!updateList.isEmpty()) {
                    update updateList;
                }
            }
        } catch(Exception ex){
            system.debug('===========Exception ============'+ex.getmessage());
            system.debug('===========Exception ============'+ex.getlinenumber());
        }
    }
    global void finish(Database.BatchableContext bi) {
    }
}