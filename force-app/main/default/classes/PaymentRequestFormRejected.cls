public class PaymentRequestFormRejected {
    @InvocableMethod (label='Rejected Payment Requests')
    public static void rejectedPaymentRequests (List<Id> prList){
        
        list<Id> rejectedWrapperIds = new list<Id>();
        list<Payment_Request__c> prRecords = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where Id IN: prList];
        for(Payment_Request__c pr : prRecords){ rejectedWrapperIds.add(pr.Payment_Request_Wrapper__c); }
        list<string> rejectStatusToConsider = new list<string>();
        rejectStatusToConsider.add('Pending for Accounts Approval');
        rejectStatusToConsider.add('Pending for Sales Ops Approval');
        rejectStatusToConsider.add('Payment Link sent to Customer');
        rejectStatusToConsider.add('Partially Approved');
        list<Payment_Request__c> prToReject = [select Id from Payment_Request__c where Id NOT IN: prList and Payment_Request_Wrapper__c IN: rejectedWrapperIds and Status__c IN: rejectStatusToConsider and Booking__c = null];
        if(prToReject.size()>0){
            List<ProcessInstance> pendingAprrovalProcessList = [Select Id, TargetObjectId, Status From ProcessInstance Where Status='Pending' and TargetObjectId IN : prToReject];
            List<Id> processInstanceIDs = new List<Id>();
            for(ProcessInstance processIns : pendingAprrovalProcessList){ processInstanceIDs.add(processIns.Id); }
            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId  FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN :processInstanceIDs ];
            List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>(); 
            for(ProcessInstanceWorkitem work : workItems){ Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest(); req.setComments('Rejected by System'); req.setAction('Reject'); req.setWorkitemId(work.id); allReq.add(req);}
            Approval.ProcessResult[] result =  Approval.process(allReq);
            for(Payment_Request__c p : prToReject){ p.Status__c = 'Rejected by System'; }
            update prToReject;
        }
    }
}