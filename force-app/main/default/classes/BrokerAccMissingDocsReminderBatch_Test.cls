@isTest
public class BrokerAccMissingDocsReminderBatch_Test {

    @TestSetup
    static void setup() {     
        List<Account> accList = new List<Account>();
        
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Name = 'Test';
        acc.Agreement_Generated_Date__c = Date.today().addDays(-3);
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        acc.Channel_Relationship_Manager__c = userinfo.getuserId();
        accList.add(acc);

        insert accList;
    }
    @isTest static void testBatchExecution() {
        Test.startTest();
        Database.executeBatch(new BrokerAccountMissingDocsReminderBatch());
        Test.stopTest();
    }
}