@isTest
private class RenewalBrokerRegistrationBatchTest {
    
    @testSetup
    static void setup() {
        // Create test Broker_Registration__c records
        List<Broker_Registration__c> brokerRegistrations = new List<Broker_Registration__c>();
        for (Integer i = 1; i < 5; i++) {
            brokerRegistrations.add(new Broker_Registration__c(
                Last_Name__c = 'LastName' + i,
                Name_as_per_trade_license__c = 'TradeLicense' + i,
                Name_as_per_passport__c = 'Passport' + i,
                Email__c = 'test' + i + '@example.com',
                Mobile__c = '1234567890',
                Broker_Category__c = 'Broker - RERA',
                OwnerId = UserInfo.getUserId(),
                Registration_Number__c = 'RegNum' + i,
                RERA_Number__c = 'RERANum' + i,
                CHRM_Manager_Email__c = 'chrm' + i + '@example.com',
                Telephone__c = '0987654321',
                Agreement_Created_Sent_Date__c = Date.today(),
                Is_Batch_Loaded__c = false,
                Skip_Broker_Email_Notification__c = false,
                Villa_Building_name__c = 'Building' + i,
                Alternate_Email__c = 'alternate' + i + '@example.com',
                City_Province__c = 'City' + i
            ));
        }
        insert brokerRegistrations;

        // Create Contacts corresponding to Alternate Emails
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i < 5; i++) {
            contacts.add(new Contact(
                LastName = 'LastName' + i,
                Email = 'alternate' + i + '@example.com'
            ));
        }
        insert contacts;

      /*  // Create Email Template
        EmailTemplate et = new EmailTemplate(
            DeveloperName = 'Broker_Registration_Renewal_link_email',
            Body = 'Test Body',
            Subject = 'Test Subject',
            HtmlValue = '<html><body>Test Body</body></html>',
            TemplateType = 'text',
            IsActive = true
        );
        insert et;*/
    }
    
    @isTest
    static void testBatchExecution() {
        // Query the test Broker_Registration__c records
        List<Broker_Registration__c> brokerRegistrations = [SELECT Id FROM Broker_Registration__c];
        List<Id> brokerIds = new List<Id>();
        for (Broker_Registration__c br : brokerRegistrations) {
            brokerIds.add(br.Id);
        }

        // Create an instance of the batch class
        
        // Execute the batch
        Test.startTest();
        RenewalBrokerRegistrationBatch batch = new RenewalBrokerRegistrationBatch(brokerIds);
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify that the new Broker_Registration__c records were inserted with the correct RecordType
        List<Broker_Registration__c> insertedBrokerRegistrations = [SELECT Id, RecordType.Name FROM Broker_Registration__c WHERE RecordType.Name = 'Renewal'];
        System.assertEquals(4, insertedBrokerRegistrations.size());
    
    }
}