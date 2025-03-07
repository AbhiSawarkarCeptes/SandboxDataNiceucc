/***************************************************************************
Class      : Nice_Lead_PhoneValidationBatchTest
Purpose    : NICE - Test class for Nice_Lead_PhoneValidationBatch 
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_Lead_PhoneValidationBatchTest {

    @testSetup
    static void setupTestData() {
       Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;     
        Project__C prj = new Project__C();
        prj.Name = 'Sobha Heartland';
        prj.Project_Code__c = '442';
        insert prj;
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 1; i++) {
            leads.add(new Lead(
                LastName = 'TestLead' +i,
                MobilePhone = '123456789' + i,
                Is_ValidPhone__c = false
            ));
        }
        insert leads;
    }
    
    @isTest
    static void testLeadValidPhoneNumbers() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(true, false));
        Nice_Lead_PhoneValidationBatch batchJob = new Nice_Lead_PhoneValidationBatch();
        Database.executeBatch(batchJob, 1);
        Test.stopTest();
        List<Lead> UpdateLeadData = [SELECT Id, MobilePhone, Is_ValidPhone__c FROM Lead];
        for (Lead lead : UpdateLeadData) {
            System.assert.areEqual(true, lead.Is_ValidPhone__c, 'Phone number validation failed for: ' + lead.Id);
        }
    }
    
    @isTest
    static void testLeadInvalidPhoneNumbers() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(false, false));
        Nice_Lead_PhoneValidationBatch batchJob = new Nice_Lead_PhoneValidationBatch();
        Database.executeBatch(batchJob, 1);
        Test.stopTest();
        List<Lead> UpdateLeadData = [SELECT Id, MobilePhone, Is_ValidPhone__c FROM Lead];
        for (Lead lead : UpdateLeadData) {
            System.assertEquals(false, lead.Is_ValidPhone__c, 'Phone number validation failed for: ' + lead.Id);
        }
    }
}