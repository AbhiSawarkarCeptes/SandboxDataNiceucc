public class UnitHoldTriggerHelper{
    @TestVisible public static Boolean run = true;
    Public static Map<Id,User> userMap = new Map<Id,User>([Select id,name FROM User]);
    
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    public static void setUnitHoldFieldsOnbeforeInsert(List<Unit_Hold__c> unitHoldList) {
        
        for(Unit_Hold__c unitHold :  unitHoldList) {
            if(userMap.containskey(unitHold.Sales_Manager__c))
            unitHold.Reason__c = 'Requested by Sales Manager/Director - ' + userMap.get(unitHold.Sales_Manager__c).Name;
        }
    }
    
    public static void approverValidationOnAfterUpdate(List<Unit_Hold__c> unitHoldList, Map<Id, Unit_Hold__c> unitHoldOldMap) {
         Set<Id> propertyId = new Set<Id>();
        for(Unit_Hold__c rec : unitHoldList) {
            propertyId.add(rec.Unit_No__c);
        } 
        Map<Id, PropStrength__Property__c> propertyList = new Map<Id, PropStrength__Property__c>([SELECT Id, (SELECT Id,Status__c FROM Payment_Requests__r WHERE Status__c  LIKE '%Pending%' OR Status__c LIKE '%Approved%' OR Status__c = null) FROM PropStrength__Property__c WHERE Id In : propertyId]);
        System.debug('propertyList-->'+propertyList);
        System.debug('unitHoldOldMap-->'+unitHoldOldMap);
        
        for(Unit_Hold__c u : unitHoldList) {
            System.debug('u.Unit_Hold_Approval_Status__c-->'+u.Unit_Hold_Approval_Status__c);
            System.debug('unitHoldOldMap.get(u.id).Unit_Hold_Approval_Status__c-->'+unitHoldOldMap.get(u.id).Unit_Hold_Approval_Status__c);
            if(!propertyList.isEmpty() && !unitHoldOldMap.isEmpty() && String.isNotBlank(u.Unit_Hold_Approval_Status__c) && u.Unit_Hold_Approval_Status__c != unitHoldOldMap.get(u.id).Unit_Hold_Approval_Status__c && (u.Unit_Hold_Approval_Status__c.contains('Approved') || u.Unit_Hold_Approval_Status__c.contains('Pending')) && String.isNotBlank(unitHoldOldMap.get(u.id).Unit_Hold_Approval_Status__c) && unitHoldOldMap.get(u.id).Unit_Hold_Approval_Status__c.contains('Pending') ) {
                if(!propertyList.isEmpty() && propertyList.containsKey(u.Unit_No__c) && propertyList.get(u.Unit_No__c).Payment_Requests__r.size() > 0) {
                    u.addError('Unit Chosen has been already placed on hold due to PR being Approved');
                }
            }
            
        }
        
    }
    
      public static void setAllocatedSM(List<Unit_Hold__c> unitAllocatedNew, Map<Id,Unit_Hold__c> oldUnitHoldMap ){
        System.debug('setAllocatedSM-->');
        //List<Unit_Hold__c> unitAllocatedSM = [Select id ,Unit_No__c , Sales_Manager__c ,Unit_Hold_Approval_Status__c, Sales_Manager__r.Name, Reason__c from Unit_Hold__c where Id IN: unitAllocatedNew ];
       // system.debug('unitAllocatedSM-->' + unitAllocatedSM);
        Map<Id,sObject> updatableProp = new Map<Id,sObject>();
          for(Unit_Hold__c unitHold :  unitAllocatedNew) {
            if(unitHold.Sales_Manager__c != null && userMap.containskey(unitHold.Sales_Manager__c))
            	unitHold.Reason__c = 'Requested by Sales Manager/Director - ' + userMap.get(unitHold.Sales_Manager__c).Name;
        }
          /*for(Unit_Hold__c unitHold :  unitAllocatedNew) {
              if(unitHold.Sales_Manager__c != null) {
                  recordIds.add(unitHold.Id);
              }  
          }
          if(!recordIds.isEmpty()) {
              for(Unit_Hold__c unitHold :  [SELECT Id,Sales_Manager__c,Sales_Manager__r.Name FROM Unit_Hold__c WHERE Id IN: recordIds]) {
                  unitHoldMap.put(unitHold.Sales_Manager__c,unitHold);
              }
              for(Unit_Hold__c unitHold :  unitAllocatedNew) {
                  if(unitHoldMap.containsKey(unitHold.Sales_Manager__c)) {
                      unitHold.Reason__c = 'Requested by Sales Manager/Director - ' + unitHoldMap.get(unitHold.Sales_Manager__c).Sales_Manager__r.Name;
                  }
              }
          }*/
          
        for(Unit_Hold__c singleUnitHold : unitAllocatedNew){
         /*   if(singleUnitHold.Sales_Manager__c != null && oldUnitHoldMap.get(singleUnitHold.id).Sales_Manager__c != singleUnitHold.Sales_Manager__c) {
                singleUnitHold.Reason__c = 'Requested by Sales Manager/Director - ' + singleUnitHold.Sales_Manager__r.Name;
                updatableProp.put(singleUnitHold.Id,singleUnitHold);
                SYstem.debug(' singleUnitHold.Reason__c-->' +   singleUnitHold.Reason__c);
            }
        */
            System.debug('singleUnitHold.Sales_Manager__c-->'+singleUnitHold.Sales_Manager__c);
            System.debug('oldUnitHoldMap.get(singleUnitHold.id).Unit_Hold_Approval_Status__c-->'+oldUnitHoldMap.get(singleUnitHold.id).Unit_Hold_Approval_Status__c);
            System.debug('singleUnitHold.Unit_Hold_Approval_Status__c '+singleUnitHold.Unit_Hold_Approval_Status__c );
            if(singleUnitHold.Sales_Manager__c != null && oldUnitHoldMap.get(singleUnitHold.id).Unit_Hold_Approval_Status__c != singleUnitHold.Unit_Hold_Approval_Status__c && singleUnitHold.Unit_Hold_Approval_Status__c == 'Approved') {
                updatableProp.put(singleUnitHold.Unit_No__c,new PropStrength__Property__c(Id=singleUnitHold.Unit_No__c,
                                                                                          Allocated_SM__c = singleUnitHold.Sales_Manager__c,
                                                                                          Hold_Classification__c = 'Requested by Sales Manager/Director - ' + userMap.get(singleUnitHold.Sales_Manager__c).Name ));
            }
            
        }
        System.debug('updatableProp--->' + updatableProp);
        if(!updatableProp.isEmpty()){
            update updatableProp.values(); 
        }
        
    }
    
    
    public static void statusFieldUpdate(List<Unit_Hold__c> unitHoldList, Map<Id, Unit_Hold__c> unitHoldOldMap) { 
        System.debug('statusFieldUpdate-->');
        List<Unit_Hold__c> unitholdRecToUpdate = new List<Unit_Hold__c>();
        List<PropStrength__Property__c> propertyToUpdate = new List<PropStrength__Property__c>();
        Map<Id, Unit_Hold__c> propertyToUnitIdMap = new Map<Id, Unit_Hold__c>();
        for(Unit_Hold__c rec : unitHoldList) {
            if((rec.Unit_Hold_Approval_Status__c !=  unitHoldOldMap.get(rec.Id).Unit_Hold_Approval_Status__c) && rec.Unit_Hold_Approval_Status__c == 'Approved' && rec.Unit_No__c != null) {
                propertyToUnitIdMap.put(rec.Unit_No__c, rec);
            }
        }
        Set<Id> unitHoldToReject = new Set<Id>();
        List<PropStrength__Property__c> propertyList = [SELECT Id, PropStrength__Property_on_hold_for_Reallocation__c, Unit_Hold_Validity__c, (SELECT Id, Unit_Hold_Approval_Status__c, Request_Time__c FROM Unit_Hold__r) FROM PropStrength__Property__c WHERE Id IN: propertyToUnitIdMap.keySet()];
        for(PropStrength__Property__c rec : propertyList) {
            rec.PropStrength__Property_on_hold_for_Reallocation__c = true;
            rec.Hold_Classification__c = 'Classification 1';
            Datetime dateInstance = System.now();
            if(propertyToUnitIdMap.get(rec.Id).Request_Time__c.contains('hour')) {
                Datetime newDateInstance =  dateInstance.addHours(Integer.valueOf(propertyToUnitIdMap.get(rec.Id).Request_Time__c.split(' ')[0]));
                rec.Unit_Hold_Validity__c = newDateInstance;
            }
            else if(propertyToUnitIdMap.get(rec.Id).Request_Time__c.contains('Day') || propertyToUnitIdMap.get(rec.Id).Request_Time__c.contains('Days')) {
                Datetime newDateInstance =  dateInstance.addDays(Integer.valueOf(propertyToUnitIdMap.get(rec.Id).Request_Time__c.split(' ')[0]));
                rec.Unit_Hold_Validity__c = newDateInstance;
            }
            rec.Hold_Requester__c = UserInfo.getUserId();
            propertyToUpdate.add(rec);
            for(Unit_Hold__c unitRec : rec.Unit_Hold__r) {
                if(unitRec.Id != propertyToUnitIdMap.get(rec.Id).Id) {
                    unitHoldToReject.add(unitRec.Id);
                    unitRec.Unit_Hold_Approval_Status__c = 'Rejected';
                    unitRec.Status__c = 'Inactive';
                    unitHoldRecToUpdate.add(unitRec);
                }
            }
        }
        Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId in :unitHoldToReject])).keySet();
        Set<Id> pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();
        
        List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>(); 
        for (Id pInstanceWorkitemsId:pInstanceWorkitems){
            system.debug(pInstanceWorkitemsId);
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('mRequest.');
            req2.setAction('Reject');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req2.setWorkitemId(pInstanceWorkitemsId);
            allReq.add(req2);
        }
        Approval.ProcessResult[] result2 =  Approval.process(allReq);
        if(!propertyToUpdate.isEmpty()) {
            update propertyToUpdate;
        }
        if(!unitHoldRecToUpdate.isEmpty()) {
            update unitHoldRecToUpdate;
        }
        
    }
    
    
    
    public static void sendForApproverProceess(List<Unit_Hold__c> unitHoldList) {
        
        for(Unit_Hold__c rec : unitHoldList) {
            if(rec.Sales_VP__c != null) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(rec.id);
                req1.setSubmitterId(UserInfo.getUserId());
                req1.setProcessDefinitionNameOrId('Unit_Hold_Approval_Request');
                req1.setSkipEntryCriteria(false);  
                Approval.ProcessResult result = Approval.process(req1);
            }
        }
        
    }
    public static void approverValidation(List<Unit_Hold__c> unitList) {
        
        Set<Id> propertyId = new Set<Id>();
        for(Unit_Hold__c rec : unitList) {
            propertyId.add(rec.Unit_No__c);
        } 
        Map<Id, PropStrength__Property__c> propertyList = new Map<Id, PropStrength__Property__c>([SELECT Id, (SELECT Id,Status__c FROM Payment_Requests__r WHERE Status__c  LIKE '%Pending%' OR Status__c LIKE '%Approved%' OR Status__c = null) FROM PropStrength__Property__c WHERE Id In : propertyId]);
        for(Unit_Hold__c u : unitList) {
            if(u.Unit_Hold_Approval_Status__c != null && u.Unit_Hold_Approval_Status__c != '' && u.Unit_Hold_Approval_Status__c.contains('Approved')) {
                if(propertyList.containsKey(u.Unit_No__c) && propertyList.get(u.Unit_No__c).Payment_Requests__r.size() > 0) {
                    u.addError('Unit Chosen has been already placed on hold due to PR being Approved');
                }
            }
        }
        
    }
}