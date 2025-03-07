/******************************************************
Class : Nice_Acc_PhoneValidationBatchTest
Purpose : NICE - Test class for Nice_Acc_PhoneValidationBatch
Author : Ayaz Anis 
*******************************************************/
@isTest
private class Nice_Acc_PhoneValidationBatchTest {
    
    // Test setup to insert test Accounts
    @testSetup
    static void setupTestData() {
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account 1', Primary_Mobile_Number__c = '919876543210', Is_Phone_validated__c = false),
            new Account(Name = 'Test Account 2', Primary_Mobile_Number__c = '919812345678', Is_Phone_validated__c = false),
            new Account(Name = 'Test Account 3', Secondary_Mobile_Number__c = '918765432109', Is_Secondary_Validated__c = false)
        }; 
        insert testAccounts;
    }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        
        // Mocking API Callout Responses
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(true, false));

        // Run batch
        Nice_Acc_PhoneValidationBatch batchJob = new Nice_Acc_PhoneValidationBatch();
        Database.ExecuteBatch(batchJob);

        Test.stopTest();

        // Fetch updated accounts
        List<Account> updatedAccounts = [SELECT Id, Is_Phone_validated__c,Primary_Mobile_Number__c, Primary_Mobile__c, Primary_Mobile_Country_Code__c,
                                                 Is_Secondary_Validated__c,Secondary_Mobile_Number__c, Secondary_Mobile__c, Secondary_Mobile_Country_Code__c
                                          FROM Account];

        // Validate the updated fields
        for (Account acc : updatedAccounts) {
            if (acc.Primary_Mobile_Number__c != null) {
                System.assertEquals(true, acc.Is_Phone_validated__c, 'Primary phone should be validated');
                System.assertNotEquals(null, acc.Primary_Mobile__c, 'Primary_Mobile__c should be set');
                System.assertNotEquals(null, acc.Primary_Mobile_Country_Code__c, 'Primary_Mobile_Country_Code__c should be set');
            }

            if (acc.Secondary_Mobile_Number__c != null) {
                System.assertEquals(true, acc.Is_Secondary_Validated__c, 'Secondary phone should be validated');
                System.assertNotEquals(null, acc.Secondary_Mobile__c, 'Secondary_Mobile__c should be set');
                System.assertNotEquals(null, acc.Secondary_Mobile_Country_Code__c, 'Secondary_Mobile_Country_Code__c should be set');
            }
        }
    }

    @isTest
    static void testBatchWithInvalidNumbers() {
        Test.startTest();
        
        // Mocking API Callout Responses for invalid numbers
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(false, false));

        // Run batch
        Nice_Acc_PhoneValidationBatch batchJob = new Nice_Acc_PhoneValidationBatch();
        Database.ExecuteBatch(batchJob);

        Test.stopTest();

        // Fetch updated accounts
        List<Account> updatedAccounts = [SELECT Id, Primary_Mobile_Number__c,Secondary_Mobile_Number__c,Is_Phone_validated__c, Is_Secondary_Validated__c FROM Account];

        // Validate the invalid phone records are marked as not validated
        for (Account acc : updatedAccounts) {
            if (acc.Primary_Mobile_Number__c != null) {
                System.assertEquals(false, acc.Is_Phone_validated__c, 'Primary phone should be marked as invalid');
            }
            if (acc.Secondary_Mobile_Number__c != null) {
                System.assertEquals(false, acc.Is_Secondary_Validated__c, 'Secondary phone should be marked as invalid');
            }
        }
    }
}