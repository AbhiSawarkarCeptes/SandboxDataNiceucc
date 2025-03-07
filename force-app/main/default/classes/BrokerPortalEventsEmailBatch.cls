global class BrokerPortalEventsEmailBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    // List to store events that need their email_flag__c updated
    private List<Events__c> eventsToUpdate = new List<Events__c>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query for Events__c records created today where email_flag__c is false
        String query = 'SELECT Id,Date_Of_Event__c,End_Date_Of_Event__c, OwnerId,RecordType.Name, Owner.Email,channel_partner__r.Channel_Relationship_Manager__r.Email FROM Events__c WHERE CreatedDate = TODAY AND email_flag__c = false AND From_Broker_Portal__c=true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        // Process each Events__c record and prepare emails
        for (SObject sObj : scope) {
            Events__c event = (Events__c) sObj;
            String chrmEmail = (String)event.getSObject('channel_partner__r').getSObject('Channel_Relationship_Manager__r').get('Email');
          
            System.debug('Email is '+chrmEmail);
            if (chrmEmail != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { chrmEmail });
                mail.setSubject('New Event Created');
                mail.setPlainTextBody('A new Event record has been created and assigned to you. \nEvent start date : '+event.Date_Of_Event__c+ '\nEvent end date: '+event.End_Date_Of_Event__c+'\nEvent record type: '+event.recordType.Name+'\nEvent record link: '+URL.getOrgDomainURL().toExternalForm()+'/'+event.Id);
                emailsToSend.add(mail);

                // Mark email_flag__c to true
                event.email_flag__c = true;
                eventsToUpdate.add(event);
            }
        }

        // Send all emails in bulk
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Update records with email_flag__c = true in bulk
        if (!eventsToUpdate.isEmpty()) {
            update eventsToUpdate;
        }

        // Log batch completion or send summary emails if necessary
    }
    global void execute(SchedulableContext sc){
        BrokerPortalEventsEmailBatch emBatch= new BrokerPortalEventsEmailBatch();
        Database.executeBatch(emBatch);

    }
}