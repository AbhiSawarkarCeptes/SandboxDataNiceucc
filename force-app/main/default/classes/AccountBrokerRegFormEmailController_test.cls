@isTest
public class AccountBrokerRegFormEmailController_test {
    
    @IsTest
    static void testGenerate1() {
        Account acc = new Account();
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.Channel_Relationship_Manager__c = Userinfo.getUserId();
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
         Broker_Renewal__c testRecord = TestDataFactorySobha.createBrokerRenewal(null);
        insert testRecord; 
        AccountBrokerRegFormEmailController.currentId = acc.Id;
        AccountBrokerRegFormEmailController.getrelatedTo();
        AccountBrokerRegFormEmailController.currentId = testRecord.Id;
        AccountBrokerRegFormEmailController.getrelatedRecordTo();
        AccountBrokerRegFormEmailController.emailToCRMExpiryNotification(new List<Account>{acc});
        AccountBrokerRegFormEmailController.sendEmail(new Set<Id>{acc.Id});
    }
}