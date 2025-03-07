/* Bypass Framework Enabled */
trigger LatePaymentWaiverTrigger on LP_Waiver__c (before update, After Update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    if(trigger.isUpdate && Trigger.isBefore){
        for(LP_Waiver__c lp :trigger.new){
            if(lp.Status__c == 'Approved by MDO/CMO' && lp.Status__c != trigger.OldMap.get(lp.Id).Status__c && lp.Approved_Amount__c == null){
                lp.addError('Please fill Approved Amount.');
            }else if(lp.LP_Amount_To_Be_Waived__c != null && lp.Approved_Amount__c != null && (lp.Approved_Amount__c-1) > lp.LP_Amount_To_Be_Waived__c){
                lp.addError('Approved amount should not be graeter then LP Amount To Be Waived '+lp.LP_Amount_To_Be_Waived__c);
            }
        }
    }
    List<LP_Waiver__c> lpWaiverList = New List <LP_Waiver__c>();
    List<Id> lpIds = new List<Id>();
    List<Id> lpIdsToCheck = new List<Id>();
    for(LP_Waiver__c l : trigger.new){
        if(trigger.oldmap.get(l.Id).Status__c != l.Status__c){
            lpIds.add(l.Id);
            lpIdsToCheck.add(l.Id);
        }
    }
    if(!System.isFuture() && !System.isBatch()){
        LatePaymentWaiverController.updateComments(lpIds, lpIdsToCheck);
    } 
    
    if(Trigger.isAfter && Trigger.isUpdate){
        Map<Id, Decimal> mapWaiverPrice = new Map<Id, Decimal>();
        Map<Id, Decimal> mapWaiverPrice1 = new Map<Id, Decimal>();
        List<Id> dList = new List<Id>(); 
        for(LP_Waiver__c l : [SELECT ID,demand__c,LP_Amount_To_Be_Waived__c,Approved_Amount__c,demand__r.Waiver_Amount__c,status__c FROM LP_Waiver__c WHERE ID IN: trigger.new]){
            LP_Waiver__c olp = Trigger.oldMap.get(l.ID);
            if(l.status__c !=olp.status__c && l.Status__c == 'Approved by MDO/CMO'){ 
                dlist.add(l.Demand__c);             
            }            
        }
        if(dlist != null && dlist.size()>0){
            List<LP_Waiver__c> lpList = [SELECT ID,demand__c,Approved_Amount__c,LP_Amount_To_Be_Waived__c,status__c FROM LP_Waiver__c WHERE demand__c IN : dList];
            if(lplist != null && lplist.size()>0){
                for(LP_Waiver__c lw : lpList){
                    Decimal waiverAmount = 0;
                    Decimal totalAmount = 0;
                    if(mapWaiverPrice.containskey(lw.Demand__c)) {
                        waiverAmount = mapWaiverPrice.get(lw.Demand__c);
                        totalAmount = waiverAmount +  ((lw.Approved_Amount__c != null && lw.Approved_Amount__c >0 ) ? lw.Approved_Amount__c : lw.LP_Amount_To_Be_Waived__c);
                        mapWaiverPrice.put(lw.Demand__c,totalAmount);
                    }else
                        mapWaiverPrice.put(lw.Demand__c,((lw.Approved_Amount__c != null && lw.Approved_Amount__c >0 ) ? lw.Approved_Amount__c : lw.LP_Amount_To_Be_Waived__c));
                }
                if(mapWaiverPrice != null){
                    List<Demand__c> DemandsToUpdate = new List<Demand__c>();
                    for (Id demandId : mapWaiverPrice.keySet()) {
                        Demand__c demand = new Demand__c();
                        demand.Id = demandId;
                        demand.Waiver_Amount__c = mapWaiverPrice.get(demandId);
                        DemandsToUpdate.add(demand);
                    }
                    update DemandsToUpdate;
                }               
            }
        }
    }
    if(Trigger.isBefore && Trigger.isupdate){
        for(LP_Waiver__c lp : Trigger.new){
            LP_Waiver__c oldlp = Trigger.oldMap.get(lp.ID); 
            if(lp.ApproverID__c != oldlp.ApproverID__c){
                string createdby = lp.CreatedById;
                String ownerId = createdby.substring(0,15);
                if(lp.ApproverID__c == ownerId){
                    lp.addError('Only Assigned approvers are allowed to Approve / Reject this record');
                }
            }
        }
    }
}