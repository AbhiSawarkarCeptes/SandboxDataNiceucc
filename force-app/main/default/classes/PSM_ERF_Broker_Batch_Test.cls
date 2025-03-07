@isTest
public class PSM_ERF_Broker_Batch_Test {

    @isTest
    static void testBatchExecution() {
        // Step 1: Set up test data
       
            
        Profile prof = [select id from profile where name = 'System Administrator'];
        
        User testUserc = new User(
            Alias = 'standard', Email='standarduse1111r@testorg.com',  
            EmailEncodingKey='UTF-8', LastName='Testing11343', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = prof.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testUser11343@testorganise.com'); 
        insert testUserc;    

        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = testUserc.Id;
        sc.Channel_Relationship_Manager__c = testUserc.Id;
        insert sc;
        
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner 12321';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = testUserc.Id;
        chPartner.Email_ID_1__c='test12321@test.com';
        insert chPartner;
        
        // Create test Broker_Registration__c records
        Broker_Registration__c br1 = new Broker_Registration__c(SCID__c = sc.Id, CPID__c = null,Skip_Broker_Email_Notification__c = True,Registration_Number__c = '987987',Broker_Category__c = 'Broker - RERA',Email__c = 'existing987@example.com',Last_Name__c = 'Broker987',Mobile__c = '9879879879');
        Broker_Registration__c br2 = new Broker_Registration__c(SCID__c = null, CPID__c = chPartner.Id,Skip_Broker_Email_Notification__c = True,Registration_Number__c = '654654',Broker_Category__c = 'Broker - RERA',Email__c = 'existing654@example.com',Last_Name__c = 'Broker654',Mobile__c = '9879879879');
        insert new List<Broker_Registration__c>{br1,br2};

        // Create test Account records
        Account acc1 = new Account(Name = 'Broker Account 1', RecordTypeId = getBrokerRecordTypeId(), Legacy_Broker_Id__c = br1.Id);
        Account acc2 = new Account(Name = 'Broker Account 2', RecordTypeId = getBrokerRecordTypeId(), Legacy_Broker_Id__c = br2.Id);
        insert new List<Account>{acc1, acc2};
        // Create test Events__c records
        Events__c event1 = new Events__c(Name = 'Event 1', Channel_Partner__c = chPartner.Id , Sobha_Connect__c = null, date_of_event__c = System.today() +5);
        Events__c event2 = new Events__c(Name = 'Event 2', Channel_Partner__c = null, Sobha_Connect__c = sc.Id, date_of_event__c = System.today() +5);
        insert new List<Events__c>{event1, event2};

        Test.startTest();
        // Execute the batch
        PSM_ERF_Broker_Batch batch = new PSM_ERF_Broker_Batch();
        Database.executeBatch(batch);
        
        // Execute the batch
        String query = 'SELECT Id, name,Channel_Partner__c, Sobha_Connect__c,Broker_Account__c from events__c where Broker_Account__c = null';
        PSM_ERF_Broker_Batch batch1 = new PSM_ERF_Broker_Batch(query);
        Database.executeBatch(batch1);
        
        // Execute the batch
        PSM_ERF_Broker_Batch batch2 = new PSM_ERF_Broker_Batch(new List<Id>{event1.Id,event2.Id});
        Database.executeBatch(batch2);
        
        Test.stopTest();

        // Step 2: Verify results
        // Retrieve the updated Events__c records
        Events__c updatedEvent1 = [SELECT Broker_Account__c FROM Events__c WHERE Id = :event1.Id LIMIT 1];
        Events__c updatedEvent2 = [SELECT Broker_Account__c FROM Events__c WHERE Id = :event2.Id LIMIT 1];

        // Assertions
        System.assertNotEquals(null, updatedEvent1.Broker_Account__c, 'Broker Account should be updated for Event 1');
        System.assertEquals(acc1.Id, updatedEvent1.Broker_Account__c, 'Broker Account ID should match Account 2 for Event 1');

     }

    // Helper method to get the RecordTypeId for 'broker' RecordType
    private static Id getBrokerRecordTypeId() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'broker' AND SObjectType = 'Account' LIMIT 1];
        return rt.Id;
    }
}