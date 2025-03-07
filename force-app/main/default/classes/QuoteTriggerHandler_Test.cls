@isTest
public class QuoteTriggerHandler_Test {
    @isTest
    static void testMethod1() { 
        List<Quote__c> quoteList = new List<Quote__c>(); 
        PropStrength__Projects__c proStrProj = TestDataFactorySobha.createProject(null);
        insert proStrProj;
        PropStrength__Payment_Plan__c proPStrPayPlan = TestDataFactorySobha.createPaymentPlan(null);   
        insert proPStrPayPlan;                  

        Quote__c q = new Quote__c(Basic_Sale_Price_Original__c = 10000, Basic_Sale_Price_Modified__c = 9000, Discount_Amount__c = 1000, Total_Discount__c = 1000,Quote_for_Multi_Properties__c = true,Payment_Plan__c =proPStrPayPlan.Id,Discount_Type__c = 'Discount');
        system.debug('quote here'+q);
        insert q; 
        Quote__c qt = [select id,Total_Discount__c from quote__c where id=:q.id];
        system.debug('quote here 2'+qt.Total_Discount__c);
        quoteList.add(q);
    }
}