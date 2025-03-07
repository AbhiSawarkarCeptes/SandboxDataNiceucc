/***************************************************************************
Class Name     : Nice_CustomerVerificationTest
Covers         : Nice_CustomerVerificationController
Author         : Ashok Kumar M
*****************************************************************************/
@isTest
private with sharing class Nice_CustomerVerificationTest {
    
    @testSetup
    private static void setup() {
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email__c = 'ashok.kumar@ceptes.com';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        insert acc;
        
        Task__c tsk = new Task__c();
        tsk.Account__c = acc.Id;
        insert tsk;
        
    }
    
    @isTest
    private static void testwithAccount() {
        
        Test.startTest();
        Account acc = [SELECT Id, Name, Email__c FROM Account LIMIT 1];
        
        Map<String, String> quesAnsList = Nice_CustomerVerificationController.fetchQuestionsAndAnswers(acc.Id);
        Integer questionCount = Integer.valueOf(System.Label.Customer_Verification_Question_Count);
        Assert.areEqual(questionCount, quesAnsList.size(), 'Should Match');
        
        String cvLogs = generateCVLogs();
        Nice_CustomerVerificationController.createCustomerVerificationLog(cvLogs, acc.Id, 'Success');
        List<Customer_Verification__c> cvRecords = [SELECT Id, Name FROM Customer_Verification__c];
        Assert.areEqual(1, cvRecords.size());
        
        try{
            Nice_CustomerVerificationController.fetchQuestionsAndAnswers('InvalidId');
        } Catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage());
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void testWithTask() {
        
        Test.startTest();
        Task__c tsk = [SELECT Id FROM Task__c LIMIT 1];
        
        Map<String, String> quesAnsList = Nice_CustomerVerificationController.fetchQuestionsAndAnswers(tsk.Id);
        Integer questionCount = Integer.valueOf(System.Label.Customer_Verification_Question_Count);
        Assert.areEqual(questionCount, quesAnsList.size(), 'Should Match');
        
        String cvLogs = generateCVLogs();
        Nice_CustomerVerificationController.createCustomerVerificationLog(cvLogs, tsk.Id, 'Success');
        List<Customer_Verification_Log__c> cvlRecords = [SELECT Id, Name FROM Customer_Verification_Log__c];
        Assert.areEqual(1, cvlRecords.size());
        
        try{
            Nice_CustomerVerificationController.createCustomerVerificationLog(cvLogs, 'Invalid', 'Success');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage());
        }
        Test.stopTest();
        
    }
    
    private static string generateCVLogs() {
        
        List<Map<String, Object>> logData = new List<Map<String, Object>>();
        logData.add(new Map<String, Object>{
            'question' => 'What is your favorite color?',
            'expectedAnswer' => 'Blue',
            'actualAnswer' => 'Blue',
            'isValidAnswer' => 'Yes'
             });
        return JSON.serialize(logData);
        
    }
    
}