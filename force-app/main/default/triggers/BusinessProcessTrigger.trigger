/* Bypass Framework Enabled */
trigger BusinessProcessTrigger on Business_Process__c (before insert,after update,before update) {

    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    If(trigger.isUpdate && trigger.isAfter){
        BusinessProcessTriggerHandler.sendEmailOnCompletion(trigger.new, trigger.oldMap);
    }
    if(trigger.isBefore && trigger.isUpdate){
        BusinessProcessTriggerHandler.updateTAT(trigger.new, trigger.oldMap);
        BusinessProcessTriggerHandler.updateAgeing(trigger.new, trigger.oldMap);
    }
}