@isTest
public class RefundDashboardLWCController_test {
	
    @isTest
    static void testgetProjects()
    {
       PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.PropStrength__Country_Name__c ='India';
        insert proj;
        List<PropStrength__Projects__c> projs = RefundDashboardLWCController.getProjects();
        System.assertEquals(projs.size(), 1);
    }
}