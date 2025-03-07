@isTest
public with sharing class ResolveApprovalRequestsTest {
    // Create New Request and Test Error Response
    @isTest
    public static void executeTest() {
        // Get Current User Id
        String userId = UserInfo.getUserId();
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(PropStrength__Project_Code__c = '12345', Name = 'Test Project', T_link_Demand_Days__c = 10);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';        
        cont.PropStrength__Resident_Status__c = 'Resident Citizen';
        cont.Emirates_ID__c = '784-1234-1111111-1';
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123');
        insert mileSt;
        
        PropStrength__Payment_Plan_Line_Items__c ppli = new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = mileSt.Id, PropStrength__Order__c = 1, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI');
        insert ppli;
        Test.startTest();
        PropStrength__Offer__c res = TestDataFactorySobha.createOffer(null);
        res.Hold_Amount__c = 100;
        insert res;
        
        res.Total_Pre_Payment_Received__c = res.Hold_Amount__c + 100000;
        update res;
        
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.Channel_Relationship_Head__c = UserInfo.getUserId();
        insert acc;
        
        List<ResolveApprovalRequest.Requests> requests = new List<ResolveApprovalRequest.Requests>();
        ResolveApprovalRequest.Requests req = new ResolveApprovalRequest.Requests();
        req.action = 'Reject';
        req.comments = 'Test Comments';
        req.recordId = acc.Id;
        req.approvalRequestId = acc.Id;
        req.objName = 'Account';
        req.nextApproverIds = new List<String>{userId};
            
            // Add req to requests
            requests.add(req);
        
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting for approval');
        req1.setObjectId(acc.Id);
        req1.setProcessDefinitionNameOrId('Broker_Reg_Approval_Process');
        req1.setSkipEntryCriteria(true);
        
        //ResolveApprovalRequest r = new ResolveApprovalRequest();
        try{
            Approval.ProcessResult result = Approval.process(req1);
        ResolveApprovalRequest.execute(requests);
        }catch(exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}