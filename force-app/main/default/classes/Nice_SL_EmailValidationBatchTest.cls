/***************************************************************************
Class      : Nice_SL_EmailValidationBatchTest
Purpose    : NICE - Test class for Nice_SL_EmailValidationBatch 
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_SL_EmailValidationBatchTest {

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
                Email__c = 'tests@example.com' + i,
                is_deliverable__c = false
            ));
        }
        insert leads;
    }
    
    @isTest
    static void testStandValidEmails() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(true,false));
        Nice_SL_EmailValidationBatch batchJob = new Nice_SL_EmailValidationBatch();
        Database.executeBatch(batchJob, 1);
        Test.stopTest();
        List<Stand_Lead__c> updatedLeads = [SELECT Id, is_deliverable__c FROM Stand_Lead__c];
        for (Stand_Lead__c lead : updatedLeads) {
            System.assertEquals(true, lead.is_deliverable__c, 'Email number validation failed for: ' + lead.Id);
        }
    }
    
    @isTest
    static void testStandInvalidEmails() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(true,false));
        Nice_SL_EmailValidationBatch batchJob = new Nice_SL_EmailValidationBatch();
        Database.executeBatch(batchJob, 1);
        Test.stopTest();
        List<Stand_Lead__c> updatedStandLeads = [SELECT Id, is_deliverable__c FROM Stand_Lead__c];
        for (Stand_Lead__c lead : updatedStandLeads) {
            System.assertEquals(false, lead.is_deliverable__c, 'Email number validation failed for: ' + lead.Id);
        }
    }
}