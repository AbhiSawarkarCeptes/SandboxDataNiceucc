public class InitiateApprvalProcessForCurrentRecord {
    
    @InvocableMethod
    public static void initiateApprovalProcess(List<String> recordId){
        String approvalProcessName = 'Advance_Payment_Approval_process_v1';
        Advance_Payment_Rebate__c apr = [Select Id, Audit_Resubmitted_To__c from Advance_Payment_Rebate__c Where Id =: recordId[0]];
        if(apr.Audit_Resubmitted_to__c == 'Resubmit to accounts'){
            approvalProcessName = 'Advance_Payment_Rejection';
        }
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(recordId[0]);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 
        req1.skipentrycriteria = true;
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId(approvalProcessName);
        System.debug('req1 : ' + req1);
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
    }

}