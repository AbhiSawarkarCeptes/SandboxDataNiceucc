@isTest
public class GetPSBrokers_Test {
    @isTest
    static void testGetPSBrokersData(){
        User userId = TestDataFactorySobha.createUser(null);
        insert userId;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        Test.startTest();
        GetPSBrokers.GetPSBrokersData();
        Test.stopTest();
    }
}