/******************************************************
Class : Nice_AD_PhoneValidationBatchTest
Purpose : NICE - Test class for Nice_AD_PhoneValidationBatch
Author : Ayaz Anis 
*******************************************************/
@isTest
public class Nice_AD_PhoneValidationBatchTest {

    @testSetup
    static void setupTestData() {
        List<Applicant_Details__c> applicants = new List<Applicant_Details__c>();

        // Create test records with different phone numbers
        for (Integer i = 0; i < 5; i++) {
            Applicant_Details__c app = new Applicant_Details__c();
            app.Mobile_Number__c = '123456789' + i;
            app.Mobile_Country_With_Code__c = '+1';
            app.Is_ValidMobileNumber__c = false;
            app.Secondary_Mobile_Number__c = '987654321' + i;
            app.Alternate_Mobile_Country_with_Code__c = '+1';
            app.Is_ValidAlternateMobileNumber__c = false;
            app.Landline_Number__c = '111222333' + i;
            app.Landline_Number_Country_Code__c = '+1';
            app.Is_ValidLandlineNumber__c = false;
            app.Secondary_Contact_Number__c = '444555666' + i;
            app.Secondary_Contact_Country_Code__c = '+1';
            app.Is_ValidSecondaryContactNumber__c = false;
            app.POA_Contact_Number__c = '777888999' + i;
            app.POA_Contact_Country_Code__c = '+1';
            app.Is_ValidPOAContactNumber__c = false;
            app.POA_2_Contact_Number__c = '123123123' + i;
            app.POA2_Contact_Country_Code__c = '+1';
            app.Is_ValidPOA2ContactNumber__c = false;
            app.Organization_Phone_numbers__c = '555666777' + i;
            app.Office_Country_Code__c = '+1';
            app.Is_ValidOfficeNumber__c = false;
            applicants.add(app);
        }
        insert applicants;
    }

    @isTest
    static void testBatchExecution() {
        // Fetch records before batch execution
        List<Applicant_Details__c> beforeBatch = [SELECT Id, Is_ValidMobileNumber__c FROM Applicant_Details__c WHERE Is_ValidMobileNumber__c = false];
        System.assertEquals(5, beforeBatch.size(), 'Before batch execution, all records should have Is_ValidMobileNumber__c as false.');

        // Create and execute the batch
        Test.startTest();
         // Mocking API Callout Responses
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(true, false));
        
        Nice_AD_PhoneValidationBatch batchJob = new Nice_AD_PhoneValidationBatch();
        Database.executeBatch(batchJob, beforeBatch.size());
        Test.stopTest();

         // Verify results
        List<Applicant_Details__c> updatedApplicants = [SELECT Id, Is_ValidMobileNumber__c FROM Applicant_Details__c];
        for (Applicant_Details__c app : updatedApplicants) {
            System.assertEquals(true, app.Is_ValidMobileNumber__c, 'Phone number should be validated');
        }
    }

    @isTest
    static void testBatchHandlesInvalidNumbers() {
        // Insert an applicant with an invalid phone number
        Applicant_Details__c invalidApp = new Applicant_Details__c();
        invalidApp.Mobile_Number__c = 'INVALID_PHONE';
        invalidApp.Mobile_Country_With_Code__c = '+1';
        invalidApp.Is_ValidMobileNumber__c = false;
        insert invalidApp;
        
        List<Applicant_Details__c> beforeBatch = [SELECT Id, Is_ValidMobileNumber__c FROM Applicant_Details__c WHERE Is_ValidMobileNumber__c = false];

        // Run the batch job
        Test.startTest();
        
         // Mocking API Callout Responses for invalid numbers
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(false, false));
        
        Nice_AD_PhoneValidationBatch batchJob = new Nice_AD_PhoneValidationBatch();
        Database.executeBatch(batchJob, beforeBatch.size());
        Test.stopTest();

        // Verify that the invalid record remains unchanged
        Applicant_Details__c afterBatch = [SELECT Id, Is_ValidMobileNumber__c FROM Applicant_Details__c WHERE Id = :invalidApp.Id];
        System.assertEquals(false, afterBatch.Is_ValidMobileNumber__c, 'Invalid phone numbers should not be marked as valid.');
    }
}