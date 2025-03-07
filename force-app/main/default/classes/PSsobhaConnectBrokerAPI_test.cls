@isTest
public class PSsobhaConnectBrokerAPI_test {
    @testSetup
    public static void makeData(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Sobha Connect';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
    }
    
    @isTest
    public static void testGetPSsobhaConnectBrokerAPI(){
        PSsobhaConnectBrokerAPI.GetPSsobhaConnectBrokerAPI();
    }
}