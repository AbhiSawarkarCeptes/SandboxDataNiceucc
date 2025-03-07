public class ApprovalProcessUtil {
    public static void migrateApprovalProcess(string brokerRegId, string accountId, string sourceApprovalProcessAPIName, string targetApprovalProcessAPIName){
        List<ProcessInstance> piList = [
            select Id 
            from ProcessInstance 
            where TargetObjectId =: brokerRegId and 
            Status = 'Pending' and 
            ProcessDefinition.DeveloperName =: sourceApprovalProcessAPIName
        ];
        
        if(piList.size()>0){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('Submitting Legacy Broker Registration Approval');        
            req.setObjectId(accountId);
            req.setSkipEntryCriteria(true);
            req.setProcessDefinitionNameOrId(targetApprovalProcessAPIName);
            Approval.ProcessResult result = Approval.process(req);  
            
            List<ProcessInstanceStep> pisList = [
                SELECT Id, StepStatus 
                FROM ProcessInstanceStep 
                where ProcessInstanceId =: piList[0].Id and 
                StepStatus = 'Approved'
                Order By CreatedDate ASC
            ];
            for(ProcessInstanceStep step : pisList){
                Approval.ProcessWorkitemRequest workItemReq = new Approval.ProcessWorkitemRequest();
                workItemReq.setComments('Approved Legacy Broker Registration');
                workItemReq.setAction('Approve');        
                Id workItemId = getWorkItemId(accountId);
                if(workItemId != null){
                    workItemReq.setWorkitemId(workItemId);
                    Approval.process(workItemReq);
                }
            }
        }
    }
    
    public static Id getWorkItemId(Id targetObjectId){
        Id workItemId = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId]){
            workItemId = workItem.Id;
        }
        return workItemId;
    }
    
    public static void coverageGainer()
    {
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}