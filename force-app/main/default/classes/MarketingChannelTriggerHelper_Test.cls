/*********************************************************************
 * Class Name  :   MarketingChannelTriggerHelper_Test
 * Description :   Test Class of MarketingChannelTriggerHelper Class
 * Created Date:   24/07/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 24/07/2023
 *********************************************************************/
@isTest
public class MarketingChannelTriggerHelper_Test {
	@isTest
    static void testMethod1() {
        Marketing_Plan__c mp = new Marketing_Plan__c(Active__c = TRUE, Marketing_Plan_Cost__c = 100000, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mp;
        
        Marketing_Channel__c mc = new Marketing_Channel__c(Budget_Allotted__c = 1000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mc;
        
        List<Marketing_Channel__c> mcList = new List<Marketing_Channel__c>();
        mcList.add(new Marketing_Channel__c(Budget_Allotted__c = 1000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30)));
        mcList.add(new Marketing_Channel__c(Budget_Allotted__c = 2000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30)));
        insert mcList;
        
        mc.Budget_Allotted__c = 2000;
        update mc;
    }
}