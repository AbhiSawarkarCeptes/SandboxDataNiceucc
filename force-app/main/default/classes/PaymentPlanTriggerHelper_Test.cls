@isTest
public class PaymentPlanTriggerHelper_Test {
    @isTest
    static void testMethod1() { 
            PropStrength__Projects__c propStrProj = TestDataFactorySobha.createProject(null);
            insert propStrProj;
    
            List<PropStrength__Payment_Plan__c> prolist = new List<PropStrength__Payment_Plan__c>();
            PropStrength__Payment_Plan__c pspp = TestDataFactorySobha.createPaymentPlan(null);
            insert pspp;
            prolist.add(pspp);
            PaymentPlanTriggerHelper.fillCheckValidTill(prolist);
        }
}