/* Bypass Framework Enabled */
trigger LeadCaptureTrigger on Lead_Capture__c (before insert, before update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadCaptureTriggerHandler.onBeforeInsertUpdate(Trigger.new);
        }
    }
}