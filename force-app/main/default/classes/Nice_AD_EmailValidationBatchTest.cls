/***************************************************************************
Class      : Nice_AD_EmailValidationBatchTest
Purpose    : NICE - Test class for Nice_AD_EmailValidationBatch
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_AD_EmailValidationBatchTest {
	@testSetup
    static void setupTestData() {
        List<Applicant_Details__c> applicants = new List<Applicant_Details__c>();

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
            app.Email_Address__c = 'Test'+i+'@gmail.com';
            app.POA_Email_Id__c = 'Test.s@gmail.com';
            app.POA_2_Email_Id__c = 'testt@gmail.com'; 
            app.Is_ValidEmail__c = false; 
            app.Is_ValidPOA_Email__c =false; 
            app.Is_ValidPOA_2_Email__c = false;
            applicants.add(app);
        }
        insert applicants;
    }

    @isTest
    static void testBatchExecution() {
        List<Applicant_Details__c> beforeBatch = [SELECT Id, Is_ValidEmail__c FROM Applicant_Details__c WHERE Is_ValidEmail__c = false];
        System.assertEquals(5, beforeBatch.size(), 'Before batch execution, all records should have Is_ValidEmail__c as false.');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(true,false));
        
        Nice_AD_EmailValidationBatch batchJob = new Nice_AD_EmailValidationBatch();
        Database.executeBatch(batchJob, beforeBatch.size());
        Test.stopTest();
        List<Applicant_Details__c> updatedApplicants = [SELECT Id, Is_ValidEmail__c FROM Applicant_Details__c];
        for (Applicant_Details__c app : updatedApplicants) {
            System.assertEquals(true, app.Is_ValidEmail__c, 'Applicant Email should be validated');
        }
    }

    @isTest
    static void testBatchHandlesInvalidEmails() {
        Applicant_Details__c invalidApp = new Applicant_Details__c();
        invalidApp.Email_Address__c = 'invalid.email@example.com';
            invalidApp.POA_Email_Id__c = 'invalid_poa@example.com';
            invalidApp.POA_2_Email_Id__c = 'invalid_poa2@example.com';
            invalidApp.Is_ValidEmail__c = false;
        insert invalidApp;
        
        List<Applicant_Details__c> beforeBatch = [SELECT Id, Is_ValidEmail__c FROM Applicant_Details__c WHERE Is_ValidEmail__c = false];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(false,false));
        Nice_AD_EmailValidationBatch batchJob = new Nice_AD_EmailValidationBatch();
        Database.executeBatch(batchJob, beforeBatch.size());
        Test.stopTest();
        Applicant_Details__c afterBatch = [SELECT Id, Is_ValidEmail__c FROM Applicant_Details__c WHERE Id = :invalidApp.Id];
        System.assertEquals(false, afterBatch.Is_ValidEmail__c, 'Invalid Email should not be marked as valid.');
    }
}