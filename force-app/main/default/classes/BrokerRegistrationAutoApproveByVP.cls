public without sharing class BrokerRegistrationAutoApproveByVP {
    @InvocableMethod
            public static void approveRecordByAshish(List<String> recordId){
                List<Approval.ProcessWorkitemRequest> reqs = new list<Approval.ProcessWorkitemRequest>();
                system.debug('recordId[0]==='+recordId[0]);
                /*for(ProcessInstanceWorkitem workItem  : [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectID =: recordId[0]]){
                    system.debug('workItem---'+workItem);
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments('NOC & Agreement Signed by Ashish Parakh');
                    req.setAction('Approve');
                    
                    req.setWorkitemId(workItem.Id);
                    req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                    reqs.add(req);
                    
                }
                
                Approval.ProcessResult[] result =  Approval.process(reqs);*/
                Broker_Registration__c br = new Broker_Registration__c();
                br.id = recordId[0];
                br.status__c = 'Executed Agreement sent to CRHM';
                upsert br;
                
               // Approval.UnlockResult[] urList = Approval.unlock(new List<Broker_Registration__c>{(new Broker_Registration__c(id= recordId[0]))}, false);
            }
}