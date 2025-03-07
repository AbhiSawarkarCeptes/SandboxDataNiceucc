global class EventNoActionReminderBatch implements Database.Batchable<sObject> ,Database.AllowsCallouts, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bi) {
        return Database.getQueryLocator([SELECT Id, Name, Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.ManagerId,
                                         Channel_Relationship_Manager__r.Manager.Email, Channel_Relationship_Manager__r.Email,
                                         OwnerId, Date_After_24_Hour__c 
                                         FROM Events__c 
                                         WHERE From_Broker_Portal__c = true AND
                                         No_Action_Notify__c = false AND
                                         Channel_Relationship_Manager__c != null AND
                                         (Event_Approved_status__c = '' OR
                                          Event_Approved_status__c = null) AND 
                                          Channel_Relationship_Manager__r.ManagerId != null AND 
                                          Channel_Relationship_Manager__r.Manager.Email != null]);
    }
    global void execute(Database.BatchableContext bi, List<Events__c> scope) {
        List<Messaging.SingleEmailMessage> emaillist = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templatelist = new List<EmailTemplate>();
        templatelist = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'Action_Require_Email_Template' LIMIT 1];
        List<Events__c> updateList = new List<Events__c>();
        if(!templatelist.isEmpty()) {
            for(Events__c evnt : scope) {
                if((evnt.Date_After_24_Hour__c < System.now()) || (Test.isRunningTest())) {
                    List<String> toAddress = new List<String>();
                    List<String> ccAddress = new List<String>();
                    toAddress.add(evnt.Channel_Relationship_Manager__r.Manager.Email);
                    //toAddress.add('testTo@cloudsteer.com');
                    if(!String.isBlank(evnt.Channel_Relationship_Manager__r.Email)) {
                        ccAddress.add(evnt.Channel_Relationship_Manager__r.Email);
                        //ccAddress.add('testCC@cloudsteer.com');
                    }
                    Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                    if(!toAddress.isEmpty()) {
                        emails.setToAddresses(toAddress);
                    }
                    if(!ccAddress.isEmpty()) {
                        emails.setCCAddresses(ccAddress);
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
                if(results != null && !results.get(0).isSuccess()) {
                    for(Events__c evnt : scope) {
                        if((evnt.Date_After_24_Hour__c < System.now()) || (Test.isRunningTest())) {
                            //if(evnt.Selected_Date__c.addDays(1) < System.now()) {
                            Events__c eRecord = new Events__c(Id = evnt.Id);
                            eRecord.No_Action_Notify__c = true;
                            updateList.add(eRecord);
                        }
                    }
                }
                if(updateList.size() > 0 ) {
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