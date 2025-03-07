/*********************************************************************
 * Class Name  :   AdvertisementTriggerHelper_Test
 * Description :   Test Class For AdvertisementTriggerHelper
 * Created Date:   24/07/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 24/07/2023
 *********************************************************************/
@isTest
public class AdvertisementTriggerHelper_Test {
	@isTest
    static void testMethod1() {
        Marketing_Plan__c mp = new Marketing_Plan__c(Active__c = TRUE, Marketing_Plan_Cost__c = 1000000, Start_Date__c = System.Today().addDays(-2), End_Date__c = System.Today().addDays(60));
        insert mp;
        
        Marketing_Channel__c mc = new Marketing_Channel__c(Budget_Allotted__c = 100000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mc;
        
        PropStrength__Advertisement__c advt = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000);
        insert advt;
        
        List<PropStrength__Advertisement__c> advList = new List<PropStrength__Advertisement__c>();
        advList.add(new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000));
        advList.add(new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000));
        insert advList;
        
        Marketing_Channel__c mc1 = new Marketing_Channel__c(Budget_Allotted__c = 100000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mc1;
        
        List<PropStrength__Advertisement__c> advListUpd = new List<PropStrength__Advertisement__c>();
        advListUpd.add(new PropStrength__Advertisement__c(Id = advt.Id, PropStrength__Budgeted_Cost__c = 2000, Marketing_Channel__c = mc1.Id));
        advListUpd.add(new PropStrength__Advertisement__c(Id = advList[0].Id, Marketing_Channel__c = mc1.Id, Total_Booking_Count__c = 1, Total_Offer_Count__c = 1, Total_Enquiry_Count__c = 1));
        advListUpd.add(new PropStrength__Advertisement__c(Id = advList[1].Id, Marketing_Channel__c = mc1.Id, PropStrength__Budgeted_Cost__c = 2000));
        update advListUpd;
        
        advListUpd.remove(0);
        delete advListUpd;
    }
}