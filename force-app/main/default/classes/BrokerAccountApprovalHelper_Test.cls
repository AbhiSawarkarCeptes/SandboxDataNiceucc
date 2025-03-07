@isTest
public class BrokerAccountApprovalHelper_Test {
	@isTest 
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        List <Broker_Account_Approval_History__c> approvalList = new List<Broker_Account_Approval_History__c>();
        approvalList.add(new Broker_Account_Approval_History__c(Broker_Account__c= acc.Id, API_Name__c = 'Name', New_Value__c = 'test 1'));
        approvalList.add(new Broker_Account_Approval_History__c(Broker_Account__c= acc.Id, API_Name__c = 'Name_as_per_passport__c', New_Value__c = 'Passport 1'));
        insert approvalList;
        List<Broker_Account_Approval_History__c> updateList = new List<Broker_Account_Approval_History__c>();
        updateList.add(new Broker_Account_Approval_History__c(Id = approvalList[0].Id, Status__c = 'Completed'));
        updateList.add(new Broker_Account_Approval_History__c(Id = approvalList[1].Id, Status__c = 'Completed'));
        update updateList;
    }
}