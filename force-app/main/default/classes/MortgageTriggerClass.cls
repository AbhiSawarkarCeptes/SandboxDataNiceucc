public class MortgageTriggerClass {
	
    @future
    public static void updateComments(List<Id> mIds, List<Id> mIdsToCheck){
        List<Mortgage__c> lpWaiverList = New List <Mortgage__c>();
        List<ProcessInstance> instances = [SELECT Id, Status, CreatedDate, CompletedDate, TargetObjectId, 
                                                (SELECT Id, StepStatus, Actor.Name, ElapsedTimeInDays, ElapsedTimeInMinutes, 
                                                CreatedDate, ProcessNodeId, ProcessNode.Name, Comments 
                                                FROM StepsAndWorkitems order by CreatedDate) from ProcessInstance 
                                                Where TargetObjectId in : mIds order by CreatedDate];
        Map<Id,Id> mProcessMap = new Map<Id,Id>();
        Map<Id,String> mProcessStepNameMap = new Map<Id,String>();
        mIds = new List<Id>();
        for(ProcessInstance pi : instances){
            mProcessMap.put(pi.TargetObjectId,pi.Id); 
            mIds.add(pi.Id);
        }
        
        List<ProcessInstanceStep> instancesSteps = [select Comments,ProcessInstanceId,CreatedDate from ProcessInstanceStep where ProcessInstanceId in : mIds order by createddate asc];
        system.debug('VVK: '+instancesSteps.size());
        Map<Id,String> mProcessStepMap = new Map<Id,String>();
        for(ProcessInstanceStep pis:instancesSteps){
            string comment = pis.CreatedDate + ' -- ' + pis.Comments;
            mProcessStepMap.put(pis.ProcessInstanceId, comment); 
        }
        
        list<Mortgage__c> mToUpdate = new list<Mortgage__c>();
        for(Mortgage__c l : [select Id,Description__c,Accounts_Approved_Documents__c ,Audit_Approved_Documents__c  from Mortgage__c where Id IN: mIdsToCheck]){
            
            if(mProcessStepMap.get(mProcessMap.get(l.Id)) != null){
                string descrip = l.Description__c;
                if (descrip == null) {
                    l.Description__c = mProcessStepMap.get(mProcessMap.get(l.Id));
                }
                else if(!descrip.contains(mProcessStepMap.get(mProcessMap.get(l.Id)))){
                    l.Description__c = l.Description__c + ' \n' + mProcessStepMap.get(mProcessMap.get(l.Id));
                }
                mToUpdate.add(l);
            }
        } 
        if(mToUpdate.size() > 0){
            update mToUpdate;
        }
    }
    
    public static void checkApprovalValidation(List<Mortgage__c> mToCheck){
        List<Id> mIdsToCheck = new List<Id>();
        for (Mortgage__c m:mToCheck) {
            mIdsToCheck.add(m.Id);
        }
        List<Mortgage__c> lpWaiverList = New List <Mortgage__c>();
        List<ProcessInstance> instances = [SELECT Id, Status, CreatedDate, CompletedDate, TargetObjectId, 
                                                (SELECT Id, StepStatus, Actor.Name, ElapsedTimeInDays, ElapsedTimeInMinutes, 
                                                CreatedDate, ProcessNodeId, ProcessNode.Name, Comments 
                                                FROM StepsAndWorkitems order by CreatedDate) from ProcessInstance 
                                                Where TargetObjectId in : mIdsToCheck order by CreatedDate desc];
        Map<Id,Id> mProcessMap = new Map<Id,Id>();
        Map<Id,String> mProcessStepNameMap = new Map<Id,String>();
        List<Id> mIds = new List<Id>();
        for(ProcessInstance pi : instances){
            mProcessMap.put(pi.TargetObjectId,pi.Id); 
            mIds.add(pi.Id);
            List<ProcessInstanceHistory> steps = pi.StepsAndWorkitems;
            for (ProcessInstanceHistory sp:steps) {
                if (sp.StepStatus == 'Pending') {
                    mProcessStepNameMap.put(pi.TargetObjectId,sp.ProcessNode.Name);
                }
            }
            System.debug('mProcessStepNameMap :: '+mProcessStepNameMap);
        }
        
        List<ProcessInstanceStep> instancesSteps = [select Comments,ProcessInstanceId,CreatedDate from ProcessInstanceStep where ProcessInstanceId in : mIds order by createddate asc];
        system.debug('VVK: '+instancesSteps.size());
        Map<Id,String> mProcessStepMap = new Map<Id,String>();
        for(ProcessInstanceStep pis:instancesSteps){
            string comment = pis.CreatedDate + ' -- ' + pis.Comments;
            mProcessStepMap.put(pis.ProcessInstanceId, comment); 
        }
        
        list<Mortgage__c> mToUpdate = new list<Mortgage__c>();
        for(Mortgage__c l : mToCheck){
            
            /*if ((mProcessStepNameMap.get(l.id) == 'Accounts Approval' || mProcessStepNameMap.get(l.id) == 'Accounts Resubmission Approval') 
                && l.Status__c == 'Pending for Audit Approval'
                && l.Accounts_Approved_Documents__c == null) {
                    l.addError('Please select at least one Account Approval Document before approving.');
                } 
            else */if ((mProcessStepNameMap.get(l.id) == 'Audit Approval Step' || mProcessStepNameMap.get(l.id) == 'Audit Resubmission Approval') 
                && l.Status__c == 'Approved by Audit'
                && l.Audit_Approved_Documents__c == null) {
                    l.addError('Please select at least one Audit Approval Document before approving.');
                    
            }
        }
    }
}