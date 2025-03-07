@isTest
public class BrokerRegistrationRenewalControllerTest {
    
    @isTest
    static void testCreateRenewalRecord() {
        // Create test data
        Broker_Registration__c testBrokerRecord = new Broker_Registration__c(
            // Populate fields required for the test
        );
        testBrokerRecord.Mobile__c = '9876543210';
        testBrokerRecord.Email__c = 'test@gmail.com';
        testBrokerRecord.Broker_Category__c = 'Broker - UAE';
        testBrokerRecord.Last_Name__c = 'Test';
        testBrokerRecord.CHRM_Manager_Email__c = 'test@gmail.com';
        insert testBrokerRecord;

        List<Broker_Registration__c> testBrokerRecords = new List<Broker_Registration__c>{testBrokerRecord};

        // Call the method to be tested
        Test.startTest();
        List<ID> resultIds = BrokerRegistrationRenewalController.createRenewalRecord(testBrokerRecords);
        List<ID> resultIds2 = BrokerRegistrationRenewalController.createRenewalRecordFromPortal(testBrokerRecords);
        List<Broker_Registration__c> tet = BrokerRegistrationRenewalController.getBRlist(testBrokerRecord.Id);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(1, resultIds.size(), 'One renewal record should be created');

        // You can add more assertions based on your specific requirements

    }
}