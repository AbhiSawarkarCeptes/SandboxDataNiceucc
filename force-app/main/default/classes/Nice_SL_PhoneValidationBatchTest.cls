/******************************************************
Class : Nice_SL_PhoneValidationBatchTest
Purpose : Test class for Nice_SL_PhoneValidationBatch
Author : Ayaz Anis
*******************************************************/
@isTest
public class Nice_SL_PhoneValidationBatchTest {
    
    @testSetup
    static void setupTestData() {
        
       Account acc = new Account(); 
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;     
       Project__C prj = new Project__C();
       prj.Name = 'Sobha Hartland';
       prj.Project_Code__c = '442';
       insert prj;
        
        List<Stand_Lead__c> leads = new List<Stand_Lead__c>();

        for (Integer i = 0; i < 1; i++) {
            leads.add(new Stand_Lead__c(
                Last_Name__c = 'Test' +i,
                Contact_Number__c = '123456789' + i,
                Country_Code__c = '+1',
                Syntax_Valid__c = false
            ));
        }
        insert leads;
    }

    @isTest
    static void testValidPhoneNumbers() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(true, false));

        // Run the batch job
        Nice_SL_PhoneValidationBatch batchJob = new Nice_SL_PhoneValidationBatch();
        Database.executeBatch(batchJob, 1);

        Test.stopTest();

        // Validate that phone numbers are marked as valid
        List<Stand_Lead__c> updatedLeads = [SELECT Id, Syntax_Valid__c FROM Stand_Lead__c];

        for (Stand_Lead__c lead : updatedLeads) {
            System.assertEquals(true, lead.Syntax_Valid__c, 'Phone number validation failed for: ' + lead.Id);
        }
    }

    @isTest
    static void testInvalidPhoneNumbers() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(false, false));

        // Run the batch job
        Nice_SL_PhoneValidationBatch batchJob = new Nice_SL_PhoneValidationBatch();
        Database.executeBatch(batchJob, 1);

        Test.stopTest();

        // Validate that phone numbers are marked as invalid
        List<Stand_Lead__c> updatedLeads = [SELECT Id, Syntax_Valid__c FROM Stand_Lead__c];

        for (Stand_Lead__c lead : updatedLeads) {
            System.assertEquals(false, lead.Syntax_Valid__c, 'Phone number validation failed for: ' + lead.Id);
        }
    }
}