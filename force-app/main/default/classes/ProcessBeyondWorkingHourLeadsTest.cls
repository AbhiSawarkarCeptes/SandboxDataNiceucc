@isTest
public class ProcessBeyondWorkingHourLeadsTest {
	@isTest
    static void test1() {
        Lead l = TestDataFactory.createLeadTemplate('test','test@gmail.com','12345678765',true);
        l.Beyond_Working_Hours__c = true;
        update l;
        ProcessBeyondWorkingHourLeadsSchedulable ob = new ProcessBeyondWorkingHourLeadsSchedulable();
        ob.execute(null);
    }
}