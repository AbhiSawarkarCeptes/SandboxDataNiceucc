/* Bypass Framework Enabled */
trigger UnitHoldTrigger on Unit_Hold__c (before insert,after insert,before update, after update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    if(trigger.isInsert){
        if(trigger.isBefore){
            UnitHoldTriggerHandler.beforeInsert(trigger.new);
        }
        if(trigger.isAfter){
            UnitHoldTriggerHandler.afterInsert(trigger.new);
        }
    }
    if(trigger.isUpdate){
        if(trigger.isBefore){ 
            UnitHoldTriggerHandler.validateApproval(trigger.new,trigger.oldMap);
            
            UnitHoldTriggerHandler.unitHoldRejectionValidation(trigger.new,trigger.oldMap);
            UnitHoldTriggerHandler.updateStatusToActive(trigger.new,trigger.oldMap);
        }
        if(trigger.isAfter){
            UnitHoldTriggerHandler.updateSmSdOnUnit(trigger.new,trigger.oldMap);
            if(!System.isFuture()){
                UnitHoldTriggerHandler.updateComments(JSON.serialize(Trigger.new), JSON.serialize(Trigger.oldMap));
            }
        }
    }
}