/***************************************************************************
Class      : Nice_Lead_EmailValidationBatchTest
Purpose    : NICE - Test class for Nice_Lead_EmailValidationBatch
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_Lead_EmailValidationBatchTest {
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
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 1; i++) {
            leads.add(new Lead(
                LastName = 'Test' +i,
                Email = 'tests@example.com' + i,
                Is_ValidEmail__c = false
            ));
        }
        insert leads;
    }
    
    @isTest
    static void testStandValidEmails() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(true,false));
        Nice_Lead_EmailValidationBatch batchJob = new Nice_Lead_EmailValidationBatch();
        Database.executeBatch(batchJob, 1);
        Test.stopTest();
        List<Lead> updatedLeads = [SELECT Id,Is_ValidEmail__c FROM Lead];
        for (Lead lead : updatedLeads) {
            System.assertEquals(true, lead.Is_ValidEmail__c, 'Email validation failed for: ' + lead.Id);
        }
    }
    
    @isTest
    static void testStandInvalidEmails() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(false,false));
        Nice_Lead_EmailValidationBatch batchJob = new Nice_Lead_EmailValidationBatch();
        Database.executeBatch(batchJob, 1);
        Test.stopTest();
        List<Lead> updatedLeads = [SELECT Id,Is_ValidEmail__c FROM Lead];
        for (Lead lead : updatedLeads) {
            System.assertEquals(false, lead.Is_ValidEmail__c, 'Email validation failed for: ' + lead.Id);
        }
    }
}