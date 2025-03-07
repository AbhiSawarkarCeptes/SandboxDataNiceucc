@isTest
public class BrokerRegistrationControllerTest {

    @isTest
    static void testCreateRecord() {
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
        
        // Set up mock DML operations
        Test.startTest();        
        // Test createRecord method
        try {
            Broker_Registration__c result = BrokerRegistrationController.createRecord(testRecord);
        } catch (Exception e) {
        }
        
        Test.stopTest();
    }

    @isTest
    static void testIsDuplicate() {
        // Create test data
        Broker_Registration__c existingRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Skip_Broker_Email_Notification__c = true
        );
        insert existingRecord;

        Broker_Registration__c testRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA'
        );

        // Test isDuplicate method
        Test.startTest();
        try {
            Broker_Registration__c result = BrokerRegistrationController.createRecord(testRecord);
            
        } catch (Exception e) {
        }
       BrokerRegistrationController.isDuplicate(testRecord);
        BrokerRegistrationController.validateRegistrationNo('1234','1234');
        BrokerRegistrationController.getReportingManger(userinfo.getUserId());
        Test.stopTest();
    }
    
    @isTest
    static void testValidation() {
        List<User> usr = BrokerRegistrationController.getUserManagerDetails(UserInfo.getUserId());
        // Create test data
        Broker_Registration__c testRecord = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Broker',
            Email__c = 'test@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Skip_Broker_Email_Notification__c = true
        );
        insert testRecord;
        
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        sc.registration__c = 'A12345';
        insert sc;
        
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        chPartner.Passport_No__c = 'A12345';
        insert chPartner;
        
        Test.StartTest();
        BrokerRegistrationController.validateRegistrationNo('A12345','Broker');
        BrokerRegistrationController.validateRegistrationNo('A12345','SC');
        Test.StopTest();
        
    }

}