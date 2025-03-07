@isTest
public class BrokerRegFieldUpdateReqControllerTest {
    
    @isTest
    static void testMethod1() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        List<Broker_Registration_Approval_Request__c> insertList = new List<Broker_Registration_Approval_Request__c>();
        
        Broker_Registration_Approval_Request__c testApp = new Broker_Registration_Approval_Request__c(
            Broker_Account__c = acc.Id,
            Label__c = 'Mobile',
            API_Name__c = 'Mobile__c',
            Old_Value__c = '2345',
            New_Value__c = '1111',
            Status__c = 'Pending with CHRM OPS Manager',
            Field_Update_Type__c = 'Other'

        );
        insertList.add(testApp);
        insert insertList;
        Test.startTest();
        BrokerRegFieldUpdateReqController.getCustomeMetadatConfig('test');
                BrokerRegFieldUpdateReqController.getCustomeMetadatConfigAcc('test');

        testApp.Status__c = 'Completed';
        update testApp;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Broker_Registration_Approval_Request__c testApp = new Broker_Registration_Approval_Request__c(
            Label__c = 'Mobile',
            API_Name__c = 'Mobile__c',
            Old_Value__c = '2345',
            New_Value__c = '1111',
            Status__c = 'Pending with CHRM OPS Manager',
            Field_Update_Type__c = 'Other',
            Broker_Account__c = acc.Id
        );
        insert testApp;
        
        Test.startTest();
        testApp.Status__c = 'Completed';
        update testApp;
        Test.stopTest();
    }

      @isTest
    static void testMethod3() {
           Broker_Registration__c testbroker = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',Registration_Link_Expiry_Date_Time__c=System.now(),
            Broker_Category__c = 'Broker - RERA',
            Status__c = 'CP/SC ID in Process',
            Mandatory_Documents_Missing__c = true,
            Agreement_Created_Sent_Date__c = Date.today().addDays(-3),
            CHRM_Manager__c = userinfo.getuserId()
        );
        insert testbroker;
                BrokerRegFieldUpdateReqController.getAccountId(testBroker.id);

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        List<Broker_Registration_Approval_Request__c> lst = new List<Broker_Registration_Approval_Request__c>();
        Broker_Registration_Approval_Request__c testApp = new Broker_Registration_Approval_Request__c(
            Label__c = 'Mobile',
            API_Name__c = 'Mobile__c',
            Old_Value__c = '2345',
            New_Value__c = '1111',
            Status__c = 'Pending with CHRM OPS Manager',
            Field_Update_Type__c = 'Other',
            Broker_Account__c = acc.Id
        );
        lst.add(testApp);
        Test.startTest();
        try {
       BrokerRegFieldUpdateReqController.insertRequestData(lst);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}