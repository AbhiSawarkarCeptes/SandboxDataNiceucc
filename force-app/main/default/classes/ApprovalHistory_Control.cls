public class ApprovalHistory_Control {
    
    public static List<EventWrap>  ApprovalHistoryRecords(String eventID,String type){
        List<String> processInstanceIds = new List<String>();
        List<eventWrap> approvalList = new List<eventWrap>();
        List<ProcessInstance> processInstanceList = new List<ProcessInstance>();
        String currentStatus ;
        String rejectioncomments ;
        for (Events__c a : [SELECT Id,rejection_comments__c,(SELECT ID FROM ProcessInstances  ORDER BY CreatedDate DESC),Event_Approval_Status__C FROM Events__c WHERE ID  =:eventID]){
            processInstanceList.addAll(a.ProcessInstances);
            currentStatus = a.Event_Approval_Status__C;
            rejectioncomments = a.rejection_comments__c;
        }
        
        for(ProcessInstance pi :processInstanceList){
            processInstanceIds.add(pi.Id);
        }
        

        for (ProcessInstance pi : [SELECT TargetObjectId,LastActorId,LastActor.Name,Status,
        (SELECT Id,StepStatus, ActorId,OriginalActor.Name,Comments,CreatedDate,ProcessNode.Name, ProcessInstanceId FROM StepsAndWorkitems   Order BY ID DESC), 
        (SELECT Id, StepStatus, Comments,CreatedDate,OriginalActor.Name  FROM Steps ORDER BY CreatedDate  )
                                FROM ProcessInstance WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC])
        {
            system.debug('pi.steps===='+pi.steps);
            
            if (pi.StepsAndWorkitems.size() > 0){
                for(ProcessInstanceHistory pih :pi.StepsAndWorkitems){ 
                    String stepStatus = pih.stepStatus;
                    String stepName = pih.ProcessNode.Name;
                    String stepComments = pih.Comments;
                    
                    if(pih.stepStatus == 'Pending'){
                        stepStatus = type;
                        stepComments = rejectioncomments;
                    }               
                    if(stepStatus == 'Started'){
                        stepName = 'Approval Request Submitted';
                    }
                    approvalList.add(new eventWrap(pih.OriginalActor.Name,stepStatus,stepComments,pih.CreatedDate,stepName));
                    system.debug('approvalList111' + approvalList);
                }
            }else{
                //approvalList.add(new eventWrap(pi.LastActor.Name,'','','',''));pih.OriginalActor.Name
                system.debug('approvalList' + approvalList);
            }
          
            
        }
       /*List<ProcessInstanceStep> pISList = [SELECT StepStatus,OriginalActor.Name,Comments,CreatedDate FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId =:eventID ORDER BY SystemModStamp DESC limit 10];
        for(ProcessInstanceStep pis : pISList){
            approvalList.add(new eventWrap(pis.OriginalActor.Name,pis.StepStatus,pis.Comments,pis.CreatedDate,''));
                   
        }*/

        approvalList.sort();
        return approvalList;
    }
    public class eventWrap implements Comparable{
        public String Name{get;set;}
        public String  status{get;set;}
        public String  comments{get;set;}
        public String  statusType{get;set;}
        public String  stepName{get;set;}
        public DateTime createdDate{get;set;}
        public eventWrap currentObj;
        public eventWrap(String nameTemp,String statusTemp,String CommentTemp,DateTime createdDateTemp,String stepName){
            this.Name =nameTemp;
            this.status=statusTemp; 
            this.comments = CommentTemp;
            //this.statusType = StatusTypeTemp;
            this.createdDate = createdDateTemp;
            this.stepName = stepName;

        }
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            eventWrap obj = (eventWrap)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (obj.createdDate > createdDate) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (obj.createdDate < createdDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }

            return returnValue;       
        }
    }
}