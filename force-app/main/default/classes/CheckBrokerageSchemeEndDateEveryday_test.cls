@isTest
public class CheckBrokerageSchemeEndDateEveryday_test {
    @testSetup
    public static void makeData(){
        PropStrength__Brokerage_Scheme__c pbc = TestDataFactorySobha.createBrokerageScheme(null);
        pbc.PropStrength__End_Date__c = System.today();
        insert pbc;
    }
    @isTest
    public static void testUpdateActiveCheckboxOnBS(){
        List<PropStrength__Brokerage_Scheme__c> pbcList = [select id from PropStrength__Brokerage_Scheme__c];
        CheckBrokerageSchemeEndDateEveryday.updateActiveCheckboxOnBS(pbcList);
    }
}