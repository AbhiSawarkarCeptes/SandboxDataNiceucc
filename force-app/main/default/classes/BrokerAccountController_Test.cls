@isTest
public class BrokerAccountController_Test {
    @isTest
    static void testGetUserManagerDetails() {
        
        User manager = TestDataFactorySobha.createUser(null);        
        insert manager;
        
        User user = TestDataFactorySobha.createUser(null);        
        insert user;
        
        Test.startTest();
        List<User> result = BrokerAccountController.getUserManagerDetails(String.valueOf(user.Id));
        Test.stopTest();
    }

    @isTest
    static void testCreateRecord() {        
        Account acc = TestDataFactorySobha.createAccount(null);
        
        Test.startTest();
        Account result = BrokerAccountController.createRecord(acc);
        Test.stopTest();        
    }

    @isTest
    static void testIsDuplicate() {
        
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.Name_as_per_trade_license__c = 'testing';
        insert acc;       
        Account duplicateAcc = new Account(
            Name = 'Duplicate Account',
            Email__c = 'duplicate@example.com',
            Mobile__c = '1111111111',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(),
            Name_as_per_trade_license__c = 'TradeLicense456'
        );
        insert duplicateAcc;        
        Test.startTest();
        Boolean isDuplicate = BrokerAccountController.isDuplicate(duplicateAcc);
        Test.stopTest();        
    }

    @isTest
    static void testValidateRegistrationNo() {
        
        Channel_Partner__c cp = new Channel_Partner__c(
            Passport_No__c = 'Passport123',
            RERA_Registration_No__c = 'RERA123',
            OwnerId = UserInfo.getUserId(),
            Emergency_Created_ID__c = true
        );
        insert cp;

        Sobha_Connect__c sc = new Sobha_Connect__c(
            Registration__c = 'Reg123',
            RERA_Number__c = 'RERA456',
            OwnerId = UserInfo.getUserId(),
            Emergency_Created_ID__c = true
        );
        insert sc;

        
        Test.startTest();
        Integer brokerCount = BrokerAccountController.validateRegistrationNo('Passport123', 'Broker');
        Integer sobhaCount = BrokerAccountController.validateRegistrationNo('Reg123', 'Sobha Connect');
        Test.stopTest();
    }

    @isTest
    static void testGetReportingManger() {
        
         User manager = TestDataFactorySobha.createUser(null);        
        insert manager;
        
        User user = TestDataFactorySobha.createUser(null);        
        insert user;

        
        Test.startTest();
        Id reportingManagerId = BrokerAccountController.getReportingManger(String.valueOf(user.Id));
        Test.stopTest();
    }
}