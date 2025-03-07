@isTest
public class BrokerAccountRenewalController_Test {
    @isTest
    public static void methodAccountRenew() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Broker_Renewal__c br = TestDataFactorySobha.createBrokerRenewal(null);
        insert br;
        List<Account> accList = [SELECT ID , Name FROM Account Where Id =: acc.Id];
        
        Test.startTest();
        BrokerAccountRenewalController.createRenewalRecord(accList);
        Test.stopTest();
    }
}