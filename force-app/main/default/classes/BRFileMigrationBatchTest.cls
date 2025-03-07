@isTest
public class BRFileMigrationBatchTest  {
    
    @testSetup
    static void setup() {
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        
        List<User> usr = BrokerRegistrationController.getUserManagerDetails(UserInfo.getUserId());
        // Create test data
        Broker_Registration__c testRecord = new Broker_Registration__c(
            FIrst_Name__c = 'Test',
            Last_Name__c = 'Broker',
            Email__c = 'test@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Skip_Broker_Email_Notification__c = true
        );
        insert testRecord;
        
        Account acc1 = new Account();
        acc1.name = 'Test account 1';
        acc1.RecordTypeId = RecordTypeIdAccount;
        acc1.PropStrength__Broker_Type__c ='Standard';
        acc1.Broker_Category__c = 'Individual';
        acc1.Name_as_per_passport__c = 'passportName';
        acc1.All_Documents_Updated__c = false;
        acc1.Emergency_CP_SC_ID__c = false;
        acc1.Registration_Passport_Number__c = '123';
        acc1.TRN_Number__c ='456';
        acc1.Channel_Relationship_Manager__c = Userinfo.getUserId();
        acc1.Sales_Manager_User__c = Userinfo.getUserId();
        acc1.PropStrength__Broker_Approval_Status__c = 'All Missing Documents Uploaded';
        acc1.legacy_Broker_Id__c = testRecord.Id;
        insert acc1;
        
    }
    
    @isTest
    static void testBatchExecution() {
        // Instantiate the batch class
        BRFileMigrationBatch batch = new BRFileMigrationBatch(1);
        
        // Execute the batch
        Test.startTest();
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
        
    }
}