global class BrokerFormMissingDocsReminderBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private Map<String,Contact> contacts;
    private EmailTemplate chrmManagerEmailTemplate;
    private EmailTemplate chrmHeadEmailTemplate;
    private EmailTemplate vpEmailTemplate;
    private Broker_Registration_Settings__mdt settings;
    
    global BrokerFormMissingDocsReminderBatch() {
        contacts = new Map<String,Contact>();

        // CHRMMgrReminder1_brokerReg
        chrmManagerEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CHRMMgrReminder1_brokerReg'];
        chrmHeadEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CHRMMgrReminder2_brokerReg'];
        // VPReminder3_brokerReg 
        vpEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'VPReminder3_brokerReg_Vc'];
        settings = [
            SELECT Missing_Docs_Reminder_1st__c, Missing_Docs_Reminder_2nd__c, Missing_Docs_Reminder_3rd__c, 
                Missing_Docs_Reminder_4th__c, Missing_Docs_Reminder_5th__c, Missing_Docs_Reminder_6th__c, 
                Missing_Docs_Reminder_7th__c
            FROM Broker_Registration_Settings__mdt
            WHERE DeveloperName = 'Config'
            LIMIT 1
        ];
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BrokerFormMissingDocsReminderBatch());
    }
    
    public static void run(){
        System.schedule(Test.isRunningTest() ? 'Test BrokerFormMissingDocsReminderBatch' : 'BrokerFormMissingDocsReminderBatch', '0 0 4 * * ?', new BrokerFormMissingDocsReminderBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query records where status = 'Agreement created and sent for signature'
        // and Missing Mandatory Documents checkbox is checked
        /* String query = 'SELECT Id, Name, Days_since_Agreement_shared__c, CHRM_Manager__r.Email, CHRM_ManagerHead__r.Email, ' +
            'CHRM_Manager__r.FirstName, CHRM_Manager__r.LastName, CHRM_ManagerHead__r.FirstName, CHRM_ManagerHead__r.LastName ' +
            'FROM Broker_Registration__c ' +
            'WHERE Status__c = \'CP/SC ID in Process\' ' +
            'AND Mandatory_Documents_Missing__c = true ' +
            'AND Days_since_Agreement_shared__c >= 3'; */
        String query = 'SELECT Id, Name, Days_since_Agreement_shared__c, CHRM_Manager__r.Email, CHRM_ManagerHead__r.Email, ' +
            'CHRM_Manager__r.FirstName, CHRM_Manager__r.LastName, CHRM_ManagerHead__r.FirstName, CHRM_ManagerHead__r.LastName, CHRM_Manager__r.Manager.Email ' +
            'FROM Broker_Registration__c ' +
            'WHERE Status__c = \'CP/SC ID in Process\' ' +
            'AND Days_since_Agreement_shared__c >= 3';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Broker_Registration__c> scope) {
        Map<String,Contact> newContacts = new Map<String,Contact>();
        Map<Broker_Registration__c,String> pendingBrokerToRecipients = new Map<Broker_Registration__c,String>();
        Map<Broker_Registration__c,List<String>> pendingBrokerToCCs = new Map<Broker_Registration__c,List<String>>();
        Map<Broker_Registration__c,EmailTemplate> pendingBrokerToTemplate = new Map<Broker_Registration__c,EmailTemplate>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (Broker_Registration__c registration : scope) {
            Integer daysSinceSent = Integer.valueOf(registration.Days_since_Agreement_shared__c);
            String recipient = registration.CHRM_Manager__r?.Email;
            Contact recipientRecord = new Contact(
                FirstName = registration.CHRM_Manager__r?.FirstName, 
                LastName = registration.CHRM_Manager__r?.LastName, 
                Email = recipient
            );
            EmailTemplate template = null;
            List<String> cc = new List<String>();
            
            if (daysSinceSent == settings.Missing_Docs_Reminder_1st__c || daysSinceSent == settings.Missing_Docs_Reminder_2nd__c || daysSinceSent == settings.Missing_Docs_Reminder_3rd__c) {
                // Send email reminder to CHRM Manager
                template = chrmManagerEmailTemplate;
            } else if (daysSinceSent == settings.Missing_Docs_Reminder_4th__c || daysSinceSent == settings.Missing_Docs_Reminder_5th__c || daysSinceSent == settings.Missing_Docs_Reminder_6th__c) {
                // Send email reminder to CHRM Head
                cc.add(registration.CHRM_Manager__r.Manager?.Email);
                template = chrmHeadEmailTemplate;
            } else if (daysSinceSent >= settings.Missing_Docs_Reminder_7th__c && Math.mod((daysSinceSent - Integer.valueOf(settings.Missing_Docs_Reminder_7th__c)), Integer.valueOf(settings.Missing_Docs_Reminder_1st__c)) == 0) {
                // Send email reminder to VP every 3 days after 20th day
                cc.add(System.Label.VP_Email);
                cc.add(registration.CHRM_Manager__r.Manager?.Email);
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

        for(Broker_Registration__c registration : pendingBrokerToRecipients.keySet()) {
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
    
    private Messaging.SingleEmailMessage createEmailMessage(Broker_Registration__c registration, Contact recipient, EmailTemplate template, List<String> cc) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { recipient.email });
        email.setCCAddresses(cc);
        email.setBccAddresses(new String[] { 'sfnotifications@sobharealty.com' });
        email.setTemplateId(template.Id);
        email.setWhatId(registration.Id);
        email.setTargetObjectId(recipient.Id);
        return email;
    }
}
// global class BrokerFormMissingDocsReminderBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

//     private Map<String,Contact> contacts;
//     private EmailTemplate chrmManagerEmailTemplate;
//     private EmailTemplate chrmHeadEmailTemplate;
//     private EmailTemplate vpEmailTemplate;
//     private Broker_Registration_Settings__mdt settings;
    
//     global BrokerFormMissingDocsReminderBatch() {
//         contacts = new Map<String,Contact>();

//         chrmManagerEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CHRMMgrReminder1_brokerReg'];
//         chrmHeadEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CHRMMgrReminder2_brokerReg'];
//         vpEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'VPReminder3_brokerReg'];
//         settings = [
//             SELECT Missing_Docs_Reminder_1st__c, Missing_Docs_Reminder_2nd__c, Missing_Docs_Reminder_3rd__c, 
//                 Missing_Docs_Reminder_4th__c, Missing_Docs_Reminder_5th__c, Missing_Docs_Reminder_6th__c, 
//                 Missing_Docs_Reminder_7th__c
//             FROM Broker_Registration_Settings__mdt
//             WHERE DeveloperName = 'Config'
//             LIMIT 1
//         ];
//     }

//     public void execute(SchedulableContext sc) {
//         Database.executeBatch(new BrokerFormMissingDocsReminderBatch());
//     }
    
//     public static void run(){
//         System.schedule('BrokerFormMissingDocsReminderBatch', '0 0 4 * * ?', new BrokerFormMissingDocsReminderBatch());
//     }

//     global Database.QueryLocator start(Database.BatchableContext BC) {
//         // Query records where status = 'Agreement created and sent for signature'
//         // and Missing Mandatory Documents checkbox is checked
//         String query = 'SELECT Id, Name, Days_since_Agreement_shared__c, CHRM_Manager__r.Email, CHRM_ManagerHead__r.Email, ' +
//             'CHRM_Manager__r.FirstName, CHRM_Manager__r.LastName, CHRM_ManagerHead__r.FirstName, CHRM_ManagerHead__r.LastName ' +
//             'FROM Broker_Registration__c ' +
//             'WHERE Status__c = \'Agreement created and sent for signature\' ' +
//             'AND Mandatory_Documents_Missing__c = true ' +
//             'AND Days_since_Agreement_shared__c >= 3';
//         return Database.getQueryLocator(query);
//     }
    
//     global void execute(Database.BatchableContext BC, List<Broker_Registration__c> scope) {
//         Map<String,Contact> newContacts = new Map<String,Contact>();
//         Map<Broker_Registration__c,String> pendingBrokerToRecipients = new Map<Broker_Registration__c,String>();
//         Map<Broker_Registration__c,EmailTemplate> pendingBrokerToTemplate = new Map<Broker_Registration__c,EmailTemplate>();
//         List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

//         for (Broker_Registration__c registration : scope) {
//             Integer daysSinceSent = Integer.valueOf(registration.Days_since_Agreement_shared__c);
//             String recipient = null;
//             Contact recipientRecord;
//             EmailTemplate template = null;
            
//             if (daysSinceSent == settings.Missing_Docs_Reminder_1st__c || daysSinceSent == settings.Missing_Docs_Reminder_2nd__c || daysSinceSent == settings.Missing_Docs_Reminder_3rd__c) {
//                 // Send email reminder to CHRM Manager
//                 recipient = registration.CHRM_Manager__r?.Email;
//                 recipientRecord = new Contact(
//                     FirstName = registration.CHRM_Manager__r?.FirstName, 
//                     LastName = registration.CHRM_Manager__r?.LastName, 
//                     Email = recipient
//                 );
//                 template = chrmManagerEmailTemplate;
//             } else if (daysSinceSent == settings.Missing_Docs_Reminder_4th__c || daysSinceSent == settings.Missing_Docs_Reminder_5th__c || daysSinceSent == settings.Missing_Docs_Reminder_6th__c) {
//                 // Send email reminder to CHRM Head
//                 recipient = registration.CHRM_ManagerHead__r?.Email;
//                 recipientRecord = new Contact(
//                     FirstName = registration.CHRM_ManagerHead__r?.FirstName, 
//                     LastName = registration.CHRM_ManagerHead__r?.LastName, 
//                     Email = recipient
//                 );
//                 template = chrmHeadEmailTemplate;
//             } else if (daysSinceSent >= settings.Missing_Docs_Reminder_7th__c && Math.mod((daysSinceSent - Integer.valueOf(settings.Missing_Docs_Reminder_7th__c)), Integer.valueOf(settings.Missing_Docs_Reminder_1st__c)) == 0) {
//                 // Send email reminder to VP every 3 days after 20th day
//                 recipient = System.Label.VP_Email;
//                 recipientRecord = new Contact(
//                     FirstName = System.Label.VP_First_Name, 
//                     LastName = System.Label.VP_Last_Name, 
//                     Email = recipient
//                 );
//                 template = vpEmailTemplate;
//             }

//             if( String.isBlank( recipient) ) continue;

//             if( !contacts.containsKey(recipient) ) {
//                 if( !newContacts.containsKey(recipient) ) 
//                     newContacts.put(recipient, recipientRecord);

//                 pendingBrokerToRecipients.put(registration, recipient);
//                 pendingBrokerToTemplate.put(registration, template);
//             } else {
//                 emailList.add( createEmailMessage( registration, contacts.get( recipient ), template) );
//             }
//         }

//         insert newContacts.values();

//         contacts.putAll( newContacts );

//         for(Broker_Registration__c registration : pendingBrokerToRecipients.keySet()) {
//             String recipient = pendingBrokerToRecipients.get( registration );
//             EmailTemplate template = pendingBrokerToTemplate.get( registration );
//             emailList.add( createEmailMessage( registration, contacts.get( recipient ), template) );
//         }
        
//         // Send email reminders
//         if (!emailList.isEmpty()) {
//             Messaging.sendEmail(emailList);
//         }
//     }
    
//     global void finish(Database.BatchableContext BC) {
//         // Perform any post-processing tasks if needed
//         delete contacts.values();
//     }
    
//     private Messaging.SingleEmailMessage createEmailMessage(Broker_Registration__c registration, Contact recipient, EmailTemplate template) {
//         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//         email.setToAddresses(new String[] { recipient.email });
//         email.setTemplateId(template.Id);
//         email.setWhatId(registration.Id);
//         email.setTargetObjectId(recipient.Id);
        
//         return email;
//     }
// }