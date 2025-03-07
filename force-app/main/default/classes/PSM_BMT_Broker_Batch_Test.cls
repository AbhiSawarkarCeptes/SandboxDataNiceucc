@isTest
public class PSM_BMT_Broker_Batch_Test {
    @isTest
    static void testPSMBMTBrokerBatch() {
       // User u = [select id from user where userrole.name like '%Sales Manager%' limit 1];
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
      //  chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        
        Broker_Meeting_Tracker__c bmt = new Broker_Meeting_Tracker__c(Meeting_Date__c = system.today(),Broker_Name__c = 'bTest',
                                                                      Meeting_organized_by__c = 'CRM',
                                                                      Person_met__c = 'Test',Plan_of_Meeting__c= 'Introduction',
                                                                      Channel_Partner__c = chPartner.Id);  

        Insert bmt;
         Broker_Registration__c brReg = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
             CPID__c = chPartner.Id
        );
       // insert brReg;
       //Account acc = TestDataFactorySobha.createAccount(null);
       
          RecordType brokerRecordType = [SELECT Id FROM RecordType WHERE Name = 'broker' AND SObjectType = 'Account' LIMIT 1];
         Account acc = new Account();
        acc.Name = 'Test Broker Account';
        
        acc.RecordTypeId = brokerRecordType.Id;
         acc.Legacy_Broker_Id__c = chPartner.Id;
        insert acc;
       
        
        Test.startTest();
        PSM_BMT_Broker_Batch batch = new PSM_BMT_Broker_Batch();
        Database.executeBatch(batch);
        Broker_Meeting_Tracker__c bmtrec = [SELECT Id from Broker_Meeting_Tracker__c LIMIT 1];
        List<Id> recordIds=  new List<Id>{bmtrec.Id};
        PSM_BMT_Broker_Batch batch1 = new PSM_BMT_Broker_Batch(recordIds);
        Database.executeBatch(batch1);
        String inputQuery = 'SELECT Id, Channel_Partner__c, SC_ID__c FROM Broker_Meeting_Tracker__c WHERE Broker_Account__c = NULL';
        PSM_BMT_Broker_Batch batch2 = new PSM_BMT_Broker_Batch(inputQuery);
        Database.executeBatch(batch2);
        
        Test.StopTest();
    }
}