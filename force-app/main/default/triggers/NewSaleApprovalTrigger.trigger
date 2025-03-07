trigger NewSaleApprovalTrigger on unit_hold_request__c (before insert,after insert, before update, after update) {

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_All_Triggers__c){
        return;
    }
    if(trigger.isBefore && trigger.isInsert){
        NewSaleApprovalTriggerHandler.beforeInsert(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        NewSaleApprovalTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
        HandlerNewSaleApprovalTrigger.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate){
        NewSaleApprovalTriggerHandler.afterUpdate(trigger.new,trigger.oldMap);
        HandlerNewSaleApprovalTrigger.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}