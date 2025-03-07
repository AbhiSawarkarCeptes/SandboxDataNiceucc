global class BrokerAccountMissingDocsReminderBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private Map<String,Contact> contacts;
    private EmailTemplate chrmManagerEmailTemplate;
    private EmailTemplate chrmHeadEmailTemplate;
    private EmailTemplate vpEmailTemplate;
    private Broker_Registration_Settings__mdt settings;
    
    global BrokerAccountMissingDocsReminderBatch() {
        contacts = new Map<String,Contact>();

        // CHRMMgrReminder1_brokerReg
        list<EmailTemplate> templateList = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'AccountCHRMMgrReminder1' OR DeveloperName = 'AccountCHRMMgrReminder2' OR DeveloperName = 'Account_VP_Reminder_3'];
        for(EmailTemplate et : templateList) {
            if(et.DeveloperName == 'AccountCHRMMgrReminder1') {
                chrmManagerEmailTemplate = et;
            }
            if(et.DeveloperName == 'AccountCHRMMgrReminder2') {
                chrmHeadEmailTemplate = et;
            }
            if(et.DeveloperName == 'Account_VP_Reminder_3') {
                vpEmailTemplate = et;
            }
        }
        settings = [
            SELECT Missing_Docs_Reminder_1st__c, Missing_Docs_Reminder_2nd__c, Missing_Docs_Reminder_3rd__c, 
                Missing_Docs_Reminder_4th__c, Missing_Docs_Reminder_5th__c, Missing_Docs_Reminder_6th__c, 
                Missing_Docs_Reminder_7th__c
            FROM Broker_Registration_Settings__mdt
            WHERE DeveloperName = 'Broker_Account_Congif'
            LIMIT 1
        ];
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BrokerAccountMissingDocsReminderBatch());
    }
    
    public static void run(){
        System.schedule(Test.isRunningTest() ? 'Test BrokerAccountMissingDocsReminderBatch' : 'BrokerAccountMissingDocsReminderBatch', '0 0 4 * * ?', new BrokerAccountMissingDocsReminderBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, Days_since_Agreement_shared__c, Channel_Relationship_Manager__r.Email, '+
                        'Channel_Relationship_Head__r.Email, Channel_Relationship_Manager__r.FirstName, Channel_Relationship_Manager__r.LastName, '+
                        'Channel_Relationship_Head__r.FirstName, Channel_Relationship_Head__r.LastName, Channel_Relationship_Manager__r.Manager.Email '+
                        'FROM Account WHERE Days_since_Agreement_shared__c >= 3' ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        Map<String,Contact> newContacts = new Map<String,Contact>();
        Map<Account, String> pendingBrokerToRecipients = new Map<Account,String>();
        Map<Account, List<String>> pendingBrokerToCCs = new Map<Account,List<String>>();
        Map<Account, EmailTemplate> pendingBrokerToTemplate = new Map<Account,EmailTemplate>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (Account registration : scope) {
            Integer daysSinceSent = Integer.valueOf(registration.Days_since_Agreement_shared__c);
            String recipient = registration.Channel_Relationship_Manager__r?.Email;
            Contact recipientRecord = new Contact(
                FirstName = registration.Channel_Relationship_Manager__r?.FirstName, 
                LastName = registration.Channel_Relationship_Manager__r?.LastName, 
                Email = 'test'+recipient+'check',
                Alternate_Email_ID__c = recipient
            );
            EmailTemplate template = null;
            List<String> cc = new List<String>();
            
            if (daysSinceSent == settings.Missing_Docs_Reminder_1st__c || daysSinceSent == settings.Missing_Docs_Reminder_2nd__c || daysSinceSent == settings.Missing_Docs_Reminder_3rd__c) {
                // Send email reminder to CHRM Manager
                template = chrmManagerEmailTemplate;
            } else if (daysSinceSent == settings.Missing_Docs_Reminder_4th__c || daysSinceSent == settings.Missing_Docs_Reminder_5th__c || daysSinceSent == settings.Missing_Docs_Reminder_6th__c) {
                // Send email reminder to CHRM Head
                cc.add(registration.Channel_Relationship_Manager__r.Manager?.Email);
                template = chrmHeadEmailTemplate;
            } else if (daysSinceSent >= settings.Missing_Docs_Reminder_7th__c && Math.mod((daysSinceSent - Integer.valueOf(settings.Missing_Docs_Reminder_7th__c)), Integer.valueOf(settings.Missing_Docs_Reminder_1st__c)) == 0) {
                // Send email reminder to VP every 3 days after 20th day
                cc.add(System.Label.VP_Email);
                cc.add(registration.Channel_Relationship_Manager__r.Manager?.Email);
                //template = vpEmailTemplate;
                template = chrmHeadEmailTemplate;
            }

            if( template == null ) continue;

            if( !contacts.containsKey(recipient) ) {
                if( !newContacts.containsKey(recipient) ) 
                    newContacts.put(recipient, recipientRecord);

                pendingBrokerToRecipients.put(registration, recipient);
                pendingBrokerToTemplate.put(registration, template);
                pendingBrokerToCCs.put(registration, cc);
            } else {
                emailList.add( createEmailMessage( registration, contacts.get( recipient ), template, cc) );
            }
        }

        insert newContacts.values();

        contacts.putAll( newContacts );

        for(Account registration : pendingBrokerToRecipients.keySet()) {
            String recipient = pendingBrokerToRecipients.get( registration );
            EmailTemplate template = pendingBrokerToTemplate.get( registration );
            List<String> cc = pendingBrokerToCCs.get( registration );
            emailList.add( createEmailMessage( registration, contacts.get( recipient ), template, cc) );
        }
        
        // Send email reminders
        if (!emailList.isEmpty()) {
            try{
            Messaging.sendEmail(emailList);
            }catch(exception e){
                
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Perform any post-processing tasks if needed
        delete contacts.values();
    }
    
    private Messaging.SingleEmailMessage createEmailMessage(Account registration, Contact recipient, EmailTemplate template, List<String> cc) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { recipient.Alternate_Email_ID__c });
        email.setCCAddresses(cc);
        email.setTemplateId(template.Id);
        email.setWhatId(registration.Id);
        email.setTargetObjectId(recipient.Id);
        return email;
    }
}