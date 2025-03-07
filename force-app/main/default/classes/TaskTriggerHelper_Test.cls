@isTest
public class TaskTriggerHelper_Test {
    @isTest
    static void testMethod1(){
        Test.StartTest();
        
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.Birthdate = System.Today();
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        Task tsk =  new task(
            WhatId = enq.id,
            Subject='Donni',
            Status='Completed',
            Priority='Normal',
            Call_Attempt_Status__c = 'Test');
            insert tsk;
            tsk.Call_Attempt_Status__c = 'New';
            Update tsk;
            
            TaskTriggerHelper.run = true;
            Task tsk2 =  new task(
            WhoId = cont.id,
            Subject='Donni',
            Status='Completed',
            Priority='Normal',
            Call_Attempt_Status__c = 'Test New');
            insert tsk2;
            tsk2.Call_Attempt_Status__c = 'New Run';
        Test.StopTest();
    }
}