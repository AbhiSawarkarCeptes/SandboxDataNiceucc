/***************************************************************************
Class      : Nice_ApplicantDetailsMobileUpdateBatch
Test Class  : Nice_ApplicantDetailsMobileUpdateBatchTest
Purpose    : NICE - Test class Code coverage 78% 
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_AppDetailsMobUpdateBatchTest {
    @isTest
    static void testBatchExecution() {
        List<Applicant_Details__c> testRecords = new List<Applicant_Details__c>();
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(new Applicant_Details__c(
                Mobile_Number__c = '987654321' + i,
                Mobile_Country_With_Code__c = '+91',
                Secondary_Mobile_Number__c = '87654321' + i,
                Alternate_Mobile_Country_with_Code__c = '+91',
                Landline_Number__c = '123456' + i,
                Landline_Number_Country_Code__c = '+91',
                Secondary_Contact_Number__c = '23456789' + i,
                Secondary_Contact_Country_Code__c = '+91',
                POA_Contact_Number__c = '34567890' + i,
                POA_Contact_Country_Code__c = '+91',
                POA_2_Contact_Number__c = '45678901' + i,
                POA2_Contact_Country_Code__c = '+91',
                Organization_Phone_numbers__c = '56789012' + i,
                Office_Country_Code__c = '+91'
            ));
        }
        insert testRecords;
        
        List<Id> recordIds = new List<Id>();
        for (Applicant_Details__c rec : testRecords) {
            recordIds.add(rec.Id);
        }
        Test.startTest();
        Nice_ApplicantDetailsMobileUpdateBatch batchJob = new Nice_ApplicantDetailsMobileUpdateBatch(recordIds);
        Database.executeBatch(batchJob);
        Test.stopTest();
        List<Applicant_Details__c> updatedRecords = [SELECT Id, Primary_Mobile_Number__c, Alternate_Mobile_Number__c, Landline_Number_wcc__c, Secondary_Contact_Number_wcc__c, Authorized_Signatory2_Phone__c, Authorized_Signatory3_Phone__c, Office_Phoner_Number_wcc__c FROM Applicant_Details__c WHERE Id IN :recordIds];
        for (Applicant_Details__c rec : updatedRecords) {
            System.assertNotEquals(null, rec.Primary_Mobile_Number__c, 'Primary Mobile should be updated');
            System.assertNotEquals(null, rec.Alternate_Mobile_Number__c, 'Alternate Mobile should be updated');
            System.assertNotEquals(null, rec.Landline_Number_wcc__c, 'Landline Number should be updated');
            System.assertNotEquals(null, rec.Secondary_Contact_Number_wcc__c, 'Secondary Contact should be updated');
            System.assertNotEquals(null, rec.Authorized_Signatory2_Phone__c, 'POA Contact should be updated');
            System.assertNotEquals(null, rec.Authorized_Signatory3_Phone__c, 'POA2 Contact should be updated');
            System.assertNotEquals(null, rec.Office_Phoner_Number_wcc__c, 'Office Phone should be updated');
        }
    }
}