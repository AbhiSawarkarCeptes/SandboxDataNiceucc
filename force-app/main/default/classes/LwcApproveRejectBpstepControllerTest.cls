@isTest
private class LwcApproveRejectBpstepControllerTest {

    @isTest
    static void testGetSteps() {
        // Test data setup
        contact con = new contact();
        con.FirstName = 'For';
        con.LastName = 'TAT Emails';
        insert con;
        Business_Process__c bp = new Business_Process__c(/* add necessary fields */);
        bp.name = 'test';
        insert bp;

        Business_Process_Step__c bps = new Business_Process_Step__c(
            Business_Process__c = bp.Id

        );
        bps.name = 'test';
        bps.Business_Process_Steps_Name_Custom__c = 'test';
        bps.Sequence__c = 1;
        bps.Accepted_Time__c = system.now();
        bps.Assigned_Time__c = system.now();
        bps.Completed_Time__c = system.now();
        bps.Final_Accepted_Time__c = system.now();
        bps.Final_Assigned_Time__c = system.now();
        bps.Final_Completed_Time__c = system.now();
        Id queueId = ([SELECT Id, Name, DeveloperName FROM Group WHere DeveloperName like '%Business_Process%' limit 1]).Id;
        bps.Original_Queue_Id__c = queueId;
        insert bps;

        // Test the getSteps method
        Test.startTest();
        String result = LwcApproveRejectBpstepController.getSteps(bps.Id);
        String result1 = LwcApproveRejectBpstepController.approveStep(bps.Id, 'Test Comment', 'Test BR Number');
LwcApproveRejectBpstepController.rejectStep(bps.Id, 'Test Comment', 'Test BR Number');
LwcApproveRejectBpstepController.requestForMoreInfo(bps.Id, bps.Id, 'Test Comment', 'Test BR Number');
LwcApproveRejectBpstepController.getBusinessProcessStepFields(bps.Id);
LwcApproveRejectBpstepController.validateOnLoad(bps.Id);
        Test.stopTest();

        // Add assertions as needed based on the expected result
    }

    
}