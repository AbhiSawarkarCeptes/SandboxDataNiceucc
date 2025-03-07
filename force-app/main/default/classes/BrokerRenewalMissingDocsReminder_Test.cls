@isTest
public class BrokerRenewalMissingDocsReminder_Test {

    @TestSetup
    static void setup() {     
        List<Broker_Renewal__c> renewList = new List<Broker_Renewal__c>();
        Broker_Renewal__c renew = new Broker_Renewal__c();
        renew.Generate_Agreement_Date__c = Date.today().addDays(-3);
        renew.Broker_Type__c = 'Channel Partner';
        renew.Broker_Sub_Type__c = 'Broker International';
        renew.Channel_Relationship_Manager__c = userinfo.getuserId();
        renewList.add(renew);

        insert renewList;
    }
    @isTest static void testBatchExecution() {

        Test.startTest();
        Database.executeBatch(new BrokerRenewalMissingDocsReminderBatch());
        Test.stopTest();
    }
}