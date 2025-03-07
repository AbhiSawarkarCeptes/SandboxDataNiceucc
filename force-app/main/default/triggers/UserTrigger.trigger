/* Bypass Framework Enabled */
trigger UserTrigger on User (after update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        UserTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}