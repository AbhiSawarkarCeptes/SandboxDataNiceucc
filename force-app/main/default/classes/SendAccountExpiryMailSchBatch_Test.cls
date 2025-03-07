@isTest
public class SendAccountExpiryMailSchBatch_Test {
	 @TestSetup static void setup(){
          Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        acc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Expiry_Date__c =  Date.Today().addDays(15);
        insert acc;
     }
    @isTest
    public static void SendAccountExpiryMailSchBatchTest() {
        SendAccountExpiryMailSchBatch sb = new SendAccountExpiryMailSchBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test', sch, sb); 
    }
}