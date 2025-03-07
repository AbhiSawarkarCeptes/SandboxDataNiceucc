/***************************************************************************
Class      : Nice_BR_EmailValidationBatchTest
Purpose    : NICE - Test class for Nice_BR_EmailValidationBatch
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_BR_EmailValidationBatchTest {

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
                Email__c = 'Test'+i+'@gmail.com',
                Alternate_Email__c = 'Test@gmail.com',
                Account_Email__c = 'Test.S@gmail.com',
                Is_ValidAccountEmail__c = false,
                Is_ValidEmail__c = false,
                Is_ValidOwnerEmail__c = false
                
            ));
        }
        insert brokers;
    }
    
    @isTest
    static void testBrokerValidEmails() {
        
        List<Broker_Registration__c> beforeBatch = [SELECT Id, Is_ValidEmail__c FROM Broker_Registration__c WHERE Is_ValidEmail__c = false];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(true,false));

        Nice_BR_EmailValidationBatch batchJob = new Nice_BR_EmailValidationBatch();
        Database.executeBatch(batchJob, beforeBatch.size());

        Test.stopTest();

        List<Broker_Registration__c> updatedBrokers = [SELECT Id, Is_ValidEmail__c, Is_ValidOwnerEmail__c, Is_ValidAccountEmail__c FROM Broker_Registration__c];

        for (Broker_Registration__c broker : updatedBrokers) {
            System.assertEquals(true, broker.Is_ValidEmail__c, 'Valid Email validation failed for: ' + broker.Id);
            System.assertEquals(true, broker.Is_ValidOwnerEmail__c, 'Valid Owner Email validation failed for: ' + broker.Id);
            System.assertEquals(true, broker.Is_ValidAccountEmail__c, 'Valid Account Email validation failed for: ' + broker.Id);
        }
    }
    
    @isTest
    static void testBrokerInvalidEmails() {
        List<Broker_Registration__c> beforeBatch = [SELECT Id, Is_ValidEmail__c FROM Broker_Registration__c WHERE Is_ValidEmail__c = false];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(false,false));

        Nice_BR_EmailValidationBatch batchJob = new Nice_BR_EmailValidationBatch();
        Database.executeBatch(batchJob, beforeBatch.size());

        Test.stopTest();

        List<Broker_Registration__c> updatedBrokers = [SELECT Id, Is_ValidEmail__c, Is_ValidOwnerEmail__c, Is_ValidAccountEmail__c FROM Broker_Registration__c];

        for (Broker_Registration__c broker : updatedBrokers) {
            System.assertEquals(false, broker.Is_ValidEmail__c, 'Valid Email validation failed for: ' + broker.Id);
            System.assertEquals(false, broker.Is_ValidOwnerEmail__c, 'Valid Owner Email validation failed for: ' + broker.Id);
            System.assertEquals(false, broker.Is_ValidAccountEmail__c, 'Valid Account Email validation failed for: ' + broker.Id);
        }
    }
}