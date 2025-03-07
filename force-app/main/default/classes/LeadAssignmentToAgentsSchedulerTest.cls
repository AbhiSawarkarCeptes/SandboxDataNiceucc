@istest
public class LeadAssignmentToAgentsSchedulerTest {
    
    @isTest
    static void testMethod1() {
        Test.startTest();
        LeadAssignmentToAgentsScheduler.scheduleMe('0 0 0/1 1/1 * ? *');
        Test.stopTest();
    }

}