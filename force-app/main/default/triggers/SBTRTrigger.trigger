/* Bypass Framework Enabled */
trigger SBTRTrigger on SBTR__c (after update, before update, before insert) {
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    if(Trigger.isAfter && trigger.isUpdate) {
        if(Trigger.isUpdate || !SBTRTriggerHandler.hasFiredParentTrigger) {
            SBTRTriggerHandler.afterUpdate(Trigger.new);
        } 
    }
    if(trigger.isBefore && trigger.isUpdate){
        SBTRTriggerHandler.beforeUpdate(trigger.new,trigger.oldMap);
    }
    if(trigger.isBefore && trigger.isInsert){
        SBTRTriggerHandler.beforeInsert(trigger.new);
    }
}