/******************************************************
Class : Nice_BR_PhoneValidationBatchTest
Purpose : NICE - Test class for Nice_BR_PhoneValidationBatch
Author : Ayaz Anis
*******************************************************/
@isTest
public class Nice_BR_PhoneValidationBatchTest {
 
    @testSetup
    static void setupTestData() {
        List<Broker_Registration__c> brokers = new List<Broker_Registration__c>();

        for (Integer i = 0; i < 5; i++) {
            brokers.add(new Broker_Registration__c(
                Mobile__c = '123456789' + i,
                Mobile_Country_Code__c = '+1',
                Telephone__c = '987654321' + i,
                Telephone_Country_Code__c = '+1',
                Is_ValidMobileNumber__c = false,
                Is_ValidTelephone__c = false,
                Broker_Category__c = 'Broker - RERA',
                Email__c = 'Test'+i+'@gmail.com'
            ));
        }
        insert brokers;
    }

    @isTest
    static void testValidPhoneNumbers() {
        
        List<Broker_Registration__c> beforeBatch = [SELECT Id, Is_ValidMobileNumber__c FROM Broker_Registration__c WHERE Is_ValidMobileNumber__c = false];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(true, false));

        // Run the batch job
        Nice_BR_PhoneValidationBatch batchJob = new Nice_BR_PhoneValidationBatch();
        Database.executeBatch(batchJob, beforeBatch.size());

        Test.stopTest();

        // Validate that phone numbers are marked as valid
        List<Broker_Registration__c> updatedBrokers = [SELECT Id, Is_ValidMobileNumber__c, Is_ValidTelephone__c FROM Broker_Registration__c];

        for (Broker_Registration__c broker : updatedBrokers) {
            System.assertEquals(true, broker.Is_ValidMobileNumber__c, 'Mobile number validation failed for: ' + broker.Id);
            System.assertEquals(true, broker.Is_ValidTelephone__c, 'Telephone number validation failed for: ' + broker.Id);
        }
    }

    @isTest
    static void testInvalidPhoneNumbers() {
        List<Broker_Registration__c> beforeBatch = [SELECT Id, Is_ValidMobileNumber__c FROM Broker_Registration__c WHERE Is_ValidMobileNumber__c = false];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(false, false));

        // Run the batch job
        Nice_BR_PhoneValidationBatch batchJob = new Nice_BR_PhoneValidationBatch();
        Database.executeBatch(batchJob, beforeBatch.size());

        Test.stopTest();

        // Validate that phone numbers are marked as invalid
        List<Broker_Registration__c> updatedBrokers = [SELECT Id, Is_ValidMobileNumber__c, Is_ValidTelephone__c FROM Broker_Registration__c];

        for (Broker_Registration__c broker : updatedBrokers) {
            System.assertEquals(false, broker.Is_ValidMobileNumber__c, 'Mobile number validation failed for: ' + broker.Id);
            System.assertEquals(false, broker.Is_ValidTelephone__c, 'Telephone number validation failed for: ' + broker.Id);
        }
    }
}