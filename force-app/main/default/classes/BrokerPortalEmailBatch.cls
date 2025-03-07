global class BrokerPortalEmailBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query records with new attachments (last 24 hours)
        String query = 'SELECT Id, CPID__r.Channel_Relationship_Manager__r.Email, ' +
        '(SELECT Id FROM BR_Document_Histories__r WHERE New_File_Uploaded__c = true) ' +
        'FROM Broker_Registration__c ' +
        'WHERE Id IN (SELECT Broker_Registration__c ' +
                     'FROM BR_Document_History__c ' +
                     'WHERE New_File_Uploaded__c = true) ' +
        'AND CPID__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
       // Collect emails to send
       List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

       // Iterate over each record and create an email
       for (SObject record : scope) {
           // Get the Channel Relationship Manager's email
           String emailAddr = (String) record.getSObject('CPID__r').getSObject('Channel_Relationship_Manager__r').get('Email');
           String recordId = (String) record.get('Id');

           // Create the email
           Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
           email.setToAddresses(new String[] { emailAddr });
           email.setSubject('New Attachment Added');
           email.setPlainTextBody('A new attachment has been added to the record with ID: ' + recordId);
           emails.add(email);
       }

       // Send all emails
       if (!emails.isEmpty()) {
           Messaging.sendEmail(emails);
           system.debug('The mail is '+emails);
       }
    }

    global void finish(Database.BatchableContext bc) {
        // Query all relevant BR_Document_History__c records and update New_File_Uploaded__c to false
        List<BR_Document_History__c> historiesToUpdate = [SELECT Id FROM BR_Document_History__c WHERE New_File_Uploaded__c=true];
        
        // Update the checkbox
        for (BR_Document_History__c history : historiesToUpdate) {
            history.New_File_Uploaded__c = false;
        }
        
        if (!historiesToUpdate.isEmpty()) {
            update historiesToUpdate;
        }
    }
}