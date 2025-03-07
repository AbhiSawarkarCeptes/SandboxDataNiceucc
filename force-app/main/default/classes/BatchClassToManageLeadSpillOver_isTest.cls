@isTest
public class BatchClassToManageLeadSpillOver_isTest {
    @IsTest
    static void methodName(){
        
        Test.startTest();
        Lead l = new Lead();
        l.Email = 'pritam.polley@smaartt.com';
        l.Primary_Number__c = '0545549067'; 
        l.LastName = 'Pritam Polley';
        l.Last_Call_Attempt_Status__c = 'Visit Confirmed';
        insert l;
        Database.executeBatch(new BatchClassToManageLeadSpillOver());
        Test.stopTest();
        String sch = '0 0 23 * * ?';
        System.schedule('test',sch,new LeadSpilloverSchedule());
        BatchClassToManageLeadSpillOver ob = new BatchClassToManageLeadSpillOver();
        ob.execute(null, new list<Lead>{l});
    }
   
}