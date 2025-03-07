@isTest
public class BrokerageSchemeTriggerHelper_Test {
    @isTest
    static void testMethod1() { 
            List<PropStrength__Brokerage_Scheme__c> prolist = new List<PropStrength__Brokerage_Scheme__c>();
            PropStrength__Brokerage_Scheme__c propStrBroSch = TestDataFactorySobha.createBrokerageScheme(null);
            insert propStrBroSch;
            prolist.add(propStrBroSch);
        
            BrokerageSchemeTriggerHelper.fillCheckEndDate(prolist);
        }
}