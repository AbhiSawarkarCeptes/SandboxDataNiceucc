@isTest
Class SetAutoDial_After_3_Hours_Test {
    Private Static TestMethod Void callBack() {
        Lead leadRecord = new Lead();
        leadRecord.LastName = 'Test';
        leadRecord.MobilePhone = '8987898765';
        leadRecord.Last_Call_Attempt_Status__c = 'New';
        insert leadRecord;
        Test.StartTest();
            List<task> t = new List<task>{ new task(
            WhoID = leadRecord.id,
            Subject='Donni',
            Status='Completed',
            Priority='Normal',
            Call_Attempt_Status__c = 'No Contact')};
            insert t;
        Test.StopTest();
    }
    Private Static TestMethod Void callBack2() {
        Lead leadRecord = new Lead();
        leadRecord.LastName = 'Test';
        leadRecord.MobilePhone = '8987898765';
        leadRecord.Last_Call_Attempt_Status__c = 'New';
        insert leadRecord;
        Test.StartTest();
            List<task> t = new List<task>{ new task(
            WhoID = leadRecord.id,
            Subject='',
            Status='Completed',
            Priority='Normal',
            Call_Attempt_Status__c = 'No Contact',
            Next_Action_Date__c = System.Now().addHours(3))};
            insert t;
        Test.StopTest();
    }
}