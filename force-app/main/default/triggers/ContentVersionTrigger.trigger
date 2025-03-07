/* Bypass Framework Enabled */
trigger ContentVersionTrigger on ContentVersion (after insert) {
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    if( Trigger.isAfter && Trigger.isInsert )
        ContentVersionTriggerHandler.afterInsert(Trigger.new);
}