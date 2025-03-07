public without sharing class RequesterTriggerHandler {
    public static void beforeupdate(List<Requester__c> reqList, Map<Id,Requester__c> oldReqMap){
        system.debug('beforeupdate');
        for(Requester__c req: reqList){
            if(req.Status_New__c =='Rejected' && req.Status_New__c!=oldReqMap.get(req.Id).Status_New__c ){
                req.Rejection_Date__c = System.now();
                List<ProcessInstance> instances =[SELECT Id,(SELECT Id, StepStatus, Comments FROM Steps) FROM ProcessInstance Where TargetObjectId =:req.Id Order by lastmodifieddate desc limit 1];
                if(!Test.isRunningTest()){
                    for(ProcessInstanceStep  step : instances[0].Steps){
                        if(step.StepStatus=='Rejected'){req.Reject_Comments__c = step.Comments;
                        }
                    }
                }
            }
            if(req.Status_New__c =='Approved' && req.Status_New__c!=oldReqMap.get(req.Id).Status_New__c ){
                req.Approval_Date__c = System.now();
            }
        }
    }

}