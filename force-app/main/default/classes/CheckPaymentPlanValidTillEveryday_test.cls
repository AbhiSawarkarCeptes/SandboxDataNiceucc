@isTest
public class CheckPaymentPlanValidTillEveryday_test {
    @testSetup
    public static void makeData(){
        PropStrength__Projects__c psp = TestDataFactorySobha.createProject(null);
        insert psp;
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = psp.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan', Valid_Till__c = System.today().addDays(5));
        insert ppd;
        PropStrength__Payment_Plan__c ppd2 = new PropStrength__Payment_Plan__c(PropStrength__Project__c = psp.Id, PropStrength__Payment_Plan_Code__c ='Test Plan1234', PropStrength__Active__c = true, Name = 'Test Plan 1', Valid_Till__c = System.today().addDays(-3));
        insert ppd2;
    }
    
    @isTest
    public static void testUpdateActiveCheckboxOnPP(){
        for(PropStrength__Payment_Plan__c psp : [select id from PropStrength__Payment_Plan__c]){
            CheckPaymentPlanValidTillEveryday.updateActiveCheckboxOnPP(new List<PropStrength__Payment_Plan__c>{psp});
        }
        
    }
}