@isTest
public class BrokerAccountFieldUpdateReqCont_test {
    
    @testsetup
    public static void createData() {
        
List<Account> accList = new List<Account>();
        List<Account> accList2 = new List<Account>();
        Account acc1 = TestDataFactorySobha.createAccount(null);
        acc1.PropStrength__Broker_Type__c ='Sobha Connect';
        acc1.Broker_Category__c = 'Individual';
        acc1.Name = 'Test 1';
        acc1.Field_Update_Request_Status__c = 'Pending With CHRM OPS Manager';
        acc1.PropStrength__Broker_Approval_Status__c  = 'Executed Agreement Sent to Broker';
        
        accList.add(acc1);
        Account acc3 = TestDataFactorySobha.createAccount(null);
        acc3.PropStrength__Broker_Type__c ='Sobha Connect';
        acc3.Broker_Category__c = 'Individual';
        acc3.Name = 'Test 2';
        accList2.add(acc3);
        Account acc2 = TestDataFactorySobha.createAccount(null);
        acc2.PropStrength__Broker_Type__c ='Standard';
        acc2.Broker_Category__c = 'Individual';
        acc2.Name = 'Test 3';
        acc2.Field_Update_Request_Status__c = 'Pending With CHRM OPS Manager';
        acc2.PropStrength__Broker_Approval_Status__c  = 'Executed Agreement Sent to Broker';
        accList.add(acc2);
        Account acc4 = TestDataFactorySobha.createAccount(null);
        acc4.PropStrength__Broker_Type__c ='Standard';
        acc4.Broker_Category__c = 'Individual';
        acc4.Name = 'Test 4';
        accList2.add(acc4);
        insert accList;
        Test.startTest();
        insert accList2;
        Broker_Account_Approval_History__c rec = new Broker_Account_Approval_History__c();
        rec.Broker_Account__c = acc2.Id;
        rec.Status__c = 'Pending with Audit';
        insert rec;
        Broker_Account_Approval_History__c rec2 = new Broker_Account_Approval_History__c();
        rec2.Broker_Account__c = acc1.Id;
        rec2.Status__c = 'Pending with Audit';
        insert rec2;
        List<Account> updateList = new List<Account>();
        acc2.Email_Id_1__c = 'Test@Test.com';
        acc2.Send_Policy_Mandate_Letter__c = true;
        acc2.Field_Update_Request_Status__c = 'Pending With CHRM OPS Manager';
        acc1.Email_Id_1__c = 'Test@Test.com';
        acc1.Send_Policy_Mandate_Letter__c = true;
        acc1.PropStrength__Broker_Approval_Status__c = 'Broker Registration Done';
        updateList.add(acc1);
        updateList.add(acc2);
        update updateList;
    }
    
    @isTest
    public static void testGetCustomeMetadatConfig(){
        BrokerAccountFieldUpdateReqController.getCustomeMetadatConfig('Other');
    }
    
	@isTest
    public static void testInsertRequestData(){
        List<Broker_Account_Approval_History__c> insertList = new List<Broker_Account_Approval_History__c>();
        for(Broker_Account_Approval_History__c baah : [select id, Broker_Account__c, Field_Update_Type__c from Broker_Account_Approval_History__c]){
            insertList.add(baah.clone(false, false, false, false));
        }    
        BrokerAccountFieldUpdateReqController.insertRequestData(insertList);              
    }
}