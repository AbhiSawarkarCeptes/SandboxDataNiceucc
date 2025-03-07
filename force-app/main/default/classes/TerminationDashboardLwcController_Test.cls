@isTest
public class TerminationDashboardLwcController_Test {
    @TestSetup static void setup(){
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5), PropStrength__Active__c = true,T_link_Demand_Days__c = 1, Grace_Days_Time_Linked__c = 5, Grace_Days__c = 5);
        insert proj;
    }
    @isTest
    Public  static void getProjectTest(){
       	List<PropStrength__Projects__c> projList = TerminationDashboardLwcController.getProjects();
        System.assertEquals(true, projList.size() > 0, 'Getting project List');
    }
}