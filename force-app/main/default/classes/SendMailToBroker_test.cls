@isTest
public class SendMailToBroker_test {
    @isTest
    static void SendMailToBrokerMethod() {
        List<Id> accIds = new List<Id>();
        Account acc1 = TestDataFactorySobha.createAccount(null);
        acc1.PropStrength__Broker_Type__c ='Sobha Connect';
        acc1.Broker_Category__c = 'Individual';
        acc1.Name = 'Test 1';
        acc1.Email_Id_1__c = 'Test@Test.com';
        insert acc1;
        accIds.add(acc1.Id);
        Test.startTest();
        SendMailToBroker.sendEmail(accIds);
        Test.stopTest();
    }
}