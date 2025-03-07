public class PaymentRequestForm {
    @InvocableMethod (label='Reject Payment Requests')
    public static void rejectPaymentRequests (List<Id> prList){
        list<Id> unitIds = new list<Id>();
        list<string> websiteParentIds = new list<string>();
        list<string> parentPRIds = new list<string>();
        
        list<Payment_Request__c> prRecords = [select Id, Unit__c, Payment_Request__c from Payment_Request__c where Id IN: prList];
        for(Payment_Request__c pr : prRecords){ 
            unitIds.add(pr.Unit__c); 
            parentPRIds.add(pr.Payment_Request__c);
        }
        
        list<Id> prIds = new list<Id>();
        
        list<string> rejectStatusToConsider = new list<string>();
        rejectStatusToConsider.add('Pending for Accounts Approval');
        rejectStatusToConsider.add('Pending for Sales Ops Approval');
        rejectStatusToConsider.add('Payment Link sent to Customer');
        rejectStatusToConsider.add('Partially Approved');
        
        
        list<Payment_Request__c> prToReject = [select Id, Mode__c, Payment_Request_Wrapper__c from Payment_Request__c where Unit__c IN: unitIds and Booking__c = null and Status__c IN: rejectStatusToConsider and Id NOT IN: prList and Id NOT IN: parentPRIds];
        for(Payment_Request__c p : prToReject){
            if(p.Mode__c == 'Website'){ websiteParentIds.add(p.Payment_Request_Wrapper__c); }
            else { prIds.add(p.Id); }
        }
        
        prToReject = [select Id, Status__c from Payment_Request__c where Id IN: prIds and Id NOT IN: prList];
        
        PaymentRequestFormController.rejectWebsiteRequests(websiteParentIds);
        
        if(prToReject.size()>0){
            List<ProcessInstance> pendingAprrovalProcessList = [Select Id, TargetObjectId, Status From ProcessInstance Where Status='Pending' and TargetObjectId IN : prToReject];
            List<Id> processInstanceIDs = new List<Id>();
            for(ProcessInstance processIns : pendingAprrovalProcessList){
                processInstanceIDs.add(processIns.Id);
            }
            
            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId  FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN :processInstanceIDs ];
            List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>(); 
            for(ProcessInstanceWorkitem work : workItems){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('Rejected by System'); 
                req.setAction('Reject');
                req.setWorkitemId(work.id);
                allReq.add(req);
            }
            Approval.ProcessResult[] result =  Approval.process(allReq);
            for(Payment_Request__c p : prToReject){
                p.Status__c = 'Rejected by System';
            }
            update prToReject;
        }
    }
    
    public static void unlockRecords(){
        list<Payment_Request__c> approvedPRs = [select Id from Payment_Request__c where Status__c = 'Approved'];
        list<Id> recordsToUnlock = new list<Id>();
        for(Payment_Request__c pr : approvedPRs){
            if(Approval.isLocked(pr.Id)){
                recordsToUnlock.add(pr.Id);
            }
        }
        system.debug('recordsToUnlock size: '+recordsToUnlock.size());
        if(recordsToUnlock.size()>0){
            Approval.unlock(recordsToUnlock);
        }
    }
}