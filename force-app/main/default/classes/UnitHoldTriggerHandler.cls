public without sharing class UnitHoldTriggerHandler {
    public static void beforeInsert(List<Unit_Hold__c> newList){
        User currentUser = [select id,firstname,lastname,managerId,manager.managerid,manager.manager.managerid,userrole.name from user where id =: userinfo.getUserId()];
         for(Unit_Hold__c uh : newList){
            if(uh.Unit_Hold_Requested__c == true ){
                uh.status__c='inactive';
                if(currentUser.userrole.name != null 
                && currentUser.userrole.name.containsIgnoreCase('Sales Manager')){
                    uh.sales_manager__c = currentUser.id;
                    uh.sales_Director__c = currentUser.managerid;
                    uh.sales_vp__c = currentUser.manager.managerid;
                    uh.SVP__c = currentUser.manager.manager.managerid;
                }else if(currentUser.userrole.name != null 
                && currentUser.userrole.name.containsIgnoreCase('Sales Head')){
                    uh.sales_Director__c = currentUser.id;
                    uh.sales_vp__c = currentUser.managerid;
                    uh.SVP__c = currentUser.manager.managerid;
                }
                uh.Reason__c = 'Requested by Sales Manager/Director - '+currentUser.FirstName +' '+currentUser.lastName;
                uh.Unit_Hold_Approval_Status__c = 'Submitted';
            }
        }
        
    }
    public static void afterInsert(List<Unit_Hold__c> newList){
        /*List<unit_hold__Share> shareRecordToInsert = new List<unit_hold__Share>();
        for(Unit_Hold__c u : newList){
            if(u.Unit_Hold_Requested__c == true ){
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for unit hold approval');
                req1.setObjectId(u.id);
                // Submit on behalf of a specific submitter
                req1.setSubmitterId(userinfo.getuserid()); 
                if(test.isRunningTest()){
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
                }
                
            }
        }*/
        //insert shareRecordToInsert;
    }
    public static void updateStatusToActive(List<Unit_Hold__c> newList,Map<Id,Unit_Hold__c> oldMap){
        for(Unit_Hold__c uh : newList){
            if(uh.Unit_Hold_Approval_Status__c == 'Approved' && uh.Unit_Hold_Approval_Status__c != oldMap.get(uh.id).Unit_Hold_Approval_Status__c){
               uh.status__c = 'Active';
            }
        }
    }
    public static void validateApproval(List<Unit_Hold__c> newList,Map<Id,Unit_Hold__c> oldMap){
        List<Id> unitsToQuery = new List<Id>();
        List<Unit_Hold__c> unitHoldToValidate = new List<Unit_Hold__c>();
        for(Unit_Hold__c uh : newList){
            if(uh.Unit_Hold_Approval_Status__c != null 
            && uh.Unit_Hold_Approval_Status__c != oldMap.get(uh.id).Unit_Hold_Approval_Status__c
            && (uh.Unit_Hold_Approval_Status__c.contains('Approved')
        || uh.Unit_Hold_Approval_Status__c.contains('Pending'))){
                unitsToQuery.add(uh.unit__c);
                unitHoldToValidate.add(uh);
            }
        }
        if(!unitsToQuery.isEmpty()){
            Map<Id,Unit__c> mapOfUnit = new Map<Id,Unit__c>([SELECT ID,unit_status__c FROM Unit__c WHERE ID IN: unitsToQuery]);
            List<Payment_Request__c> prList = [SELECT ID,unit__c,Status__c FROM Payment_Request__c
            WHERE ((Mode__c != 'Website' )
            OR (Mode__c ='Website' AND Payment_Request_Wrapper__r.Payment_Link_Expiry__c >: System.now()))
            AND (Not (Status__c Like '%Rejected%'))
            AND Status__c != 'PR was Approved- Booking is cancelled'
                and unit__c IN: unitsToQuery
                and status__c != null];
            Map<Id,List<Payment_Request__c>> mapUnitToPaymentRequest =  new Map<Id,List<Payment_Request__c>>();
            for(Payment_Request__c pr : prList){
                if(!mapUnitToPaymentRequest.containsKey(pr.unit__C)){
                    mapUnitToPaymentRequest.put(pr.unit__C,new List<Payment_Request__c>());
                }
                mapUnitToPaymentRequest.get(pr.unit__C).add(pr);
            }
            for(Unit_Hold__c uh : unitHoldToValidate){
                if(mapOfUnit.containsKey(uh.unit__c) && (mapOfUnit.get(uh.unit__c).unit_status__c != 'Available'
                || (mapUnitToPaymentRequest.get(uh.unit__C)!= null && mapUnitToPaymentRequest.get(uh.unit__C).size() > 0))
                ){
                    if(mapUnitToPaymentRequest.get(uh.unit__C)!= null && mapUnitToPaymentRequest.get(uh.unit__C).size() > 0){
                    for(Payment_Request__c pr : mapUnitToPaymentRequest.get(uh.unit__C)){
                        if(pr.status__c.contains('Approved') ){
                            uh.addError('Unit chosen has been already placed on hold due to PR being approved.');
                        }else{
                            uh.addError('This request cannot be submitted as PR has been already submitted for this unit');
                        }
                        
                    }
                }
                    
                }
            }
        }
    }
    public static void updateSmSdOnUnit(List<Unit_Hold__c> newList,Map<Id,Unit_Hold__c> oldMap){
        List<Unit__c> unitToUpdate = new List<Unit__c>();
        List<Unit_Hold__c> unitHoldToUpdate = new List<Unit_Hold__c>();
        for(Unit_Hold__c uh : newList){
            if(uh.Unit_Hold_Approval_Status__c == 'Approved' && uh.Unit_Hold_Approval_Status__c != oldMap.get(uh.id).Unit_Hold_Approval_Status__c){
                Integer numberOfHours = 0;
                if(uh.Request_Time__c.containsIgnoreCase('Hour')){
                    numberOfHours = Integer.valueOf(uh.Request_Time__c.split(' ')[0]);
                }else{
                    numberOfHours =  Integer.valueOf(uh.Request_Time__c.split(' ')[0])*24;
                }
                unitToUpdate.add(new unit__c(id = uh.unit__c, 
                allocated_sm__c = uh.createdbyid,
                SM_Allocation_DateTime__c = system.now(),
                SM_Allocation_reset_hours__c = numberOfHours,
                unit_status__c = 'Hold',
                Time_To_Validate_PR__c = system.now().addHours(numberOfHours),
                Unit_Hold__c = uh.id
                ));
                unitHoldToUpdate.add(new Unit_Hold__C (id = uh.id , Time_To_Validate_PR__c = system.now().addHours(numberOfHours)));
            }
        }
        if(!unitToUpdate.isEmpty()){
            update unitToUpdate;
             //get all remaining unit hold and mark them rejected
            Set<Id> unitHoldIds = (new Map<Id, Unit_Hold__c>([SELECT Id FROM Unit_Hold__c where unit__c in : unitToUpdate 
            and Unit_Hold_Approval_Status__c like '%Pending%' and id not in: newList])).keySet();
            Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId in :unitHoldIds])).keySet();
            Set<Id> pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();
            for(Id uhId : unitHoldIds){
                unitHoldToUpdate.add(new Unit_Hold__C(id = uhId, rejection_reason__c = 'Rejected because '+newList[0].Name + 'has been approved'));
            }
            update unitHoldToUpdate;
           
            List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>(); 
            for (Id pInstanceWorkitemsId:pInstanceWorkitems){
                system.debug(pInstanceWorkitemsId);
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('Automated Rejection -  '+newList[0].name +' has been approved for '+newList[0].request_time__c);
                    req2.setAction('Reject'); //to approve use 'Approve'
                    req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});

                    // Use the ID from the newly created item to specify the item to be worked
                    req2.setWorkitemId(pInstanceWorkitemsId);

                    // Add the request for approval
                    allReq.add(req2);
            }
            Approval.ProcessResult[] result2 =  Approval.process(allReq);
        }
       
    }
    public static void unitHoldRejectionValidation(List<Unit_Hold__c> newList , Map<Id,Unit_Hold__c> oldMap){
        for(Unit_Hold__c uh : newList){
        
            /*if(uh.Unit_Hold_Approval_Status__c != null 
            && uh.Unit_Hold_Approval_Status__c.contains('Rejected')
            && String.isblank(uh.rejection_reason__c)
            && uh.Unit_Hold_Approval_Status__c != oldMap.get(uh.id).Unit_Hold_Approval_Status__c){
                uh.addError('Please update rejection comments on unit hold record before and try again');
            }*/
            if(uh.Unit_Hold_Approval_Status__c != oldMap.get(uh.id).Unit_Hold_Approval_Status__c 
            && uh.Unit_Hold_Approval_Status__c != Null
            && !uh.Unit_Hold_Approval_Status__c.containsignorecase('Rejected')
            && uh.rejection_reason__c != null){
                uh.rejection_reason__c = null;
            }
            
        }

    }
    @future
    public static void updateComments(String triggerData, String triggerOldData){
        List<Unit_Hold__c> newRecords = (List<Unit_Hold__c>)Json.deserialize(triggerData,List<Unit_Hold__c>.class);
        Map<Id, Unit_Hold__c> oldMap = (Map<Id,Unit_Hold__c>)Json.deserialize(triggerOldData, Map<Id,Unit_Hold__c>.class);
        
        
        Set<Id> updatedRecordIds = new Set<Id>();
        
        for (Unit_Hold__c record : newRecords) {
            Unit_Hold__c oldRecord = oldMap.get(record.Id);
            if (record.Unit_Hold_Approval_Status__c != oldRecord.Unit_Hold_Approval_Status__c
            && record.Unit_Hold_Approval_Status__c != Null
            && record.Unit_Hold_Approval_Status__c.containsignorecase('Rejected')
           ) {
                updatedRecordIds.add(record.Id);
            }
        }
        
        if (!updatedRecordIds.isEmpty()) {
            list<Unit_Hold__c> recordsTUpdate = new list<Unit_Hold__c>();
            
            for (Id record : updatedRecordIds) {
                // Replace this with your logic to retrieve latest approval comment from related object
                String latestApprovalComment = getLatestApprovalComment(record);
                
                if (latestApprovalComment != null) {
                    recordsTUpdate.add(new Unit_Hold__c(id = record,rejection_reason__c=latestApprovalComment));
                }
            }
             
            if(recordsTUpdate.size()>0){
                system.debug('~~~ToUpdate: '+recordsTUpdate);
                update recordsTUpdate;
            }
            
            
            
        }
    }
    public static String getLatestApprovalComment(String registrationId) {
        List<String> latestApprovalComments = new List<String>();

   // Query ProcessInstance and ProcessInstanceStep records for the given recordId
   List<ProcessInstance> processInstances = [SELECT Id, TargetObjectId 
                                             FROM ProcessInstance 
                                             WHERE TargetObjectId = :registrationId];
   String returnString;
   if (processInstances.isEmpty() && !test.isRunningTest()) {
       return returnString; // No approval process for the given recordId
   }
   
   Map<Id, List<ProcessInstanceStep>> stepsMap = new Map<Id, List<ProcessInstanceStep>>();

   List<ProcessInstanceStep> steps = [SELECT Id, StepStatus, Comments, CreatedDate, ProcessInstanceId
                                      FROM ProcessInstanceStep 
                                      WHERE ProcessInstanceId IN :processInstances
                                      ORDER BY CreatedDate DESC LIMIT 1];

   // Group ProcessInstanceSteps by ProcessInstanceId
   for (ProcessInstanceStep step : steps) {
       if (!stepsMap.containsKey(step.ProcessInstanceId)) {
           stepsMap.put(step.ProcessInstanceId, new List<ProcessInstanceStep>());
       }
       stepsMap.get(step.ProcessInstanceId).add(step);
   }
   
   // Loop through ProcessInstance records and retrieve the latest comment from stepsMap
   for (ProcessInstance processInstance : processInstances) {
       if (stepsMap.containsKey(processInstance.Id)) {
           List<ProcessInstanceStep> instanceSteps = stepsMap.get(processInstance.Id);
           if (!instanceSteps.isEmpty()) {
               ProcessInstanceStep latestStep = instanceSteps[0]; // The first entry is the latest one due to the sorting
               latestApprovalComments.add(latestStep.Comments);
               returnString=latestStep.Comments;
           }
       }
   }

   return returnString;
   }
}