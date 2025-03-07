/* Dual Bypass Framework Enabled */
trigger LeadTrigger on Lead(after insert, after update, before insert, before update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
    if( bypassSettingInstance.Bypass_Backend_Automations__c || bypassSettingInstance.Bypass_Lead_Trigger__c || ApexBypassUtility.bypass_Lead_Trigger){
        return;
    }
    
    if (Trigger.IsInsert) {
        if (Trigger.isBefore) {     
            LeadTriggerHandler.beforeInsert();
            Map<Id, Lead> oldMap = Trigger.isUpdate ? Trigger.oldMap : null;
            
            /******************************************************************************************************************
            Method  : processLeadFieldsBeforeSave
            Purpose : NICE - Apex class handler method for before insert, encrypts mobile numbers & emails if they are provided.
            Author  : Artee Varma
            ******************************************************************************************************************/
            
            LeadTriggerHandler.processLeadFieldsBeforeSave(Trigger.new);
        }
        if (Trigger.isAfter) {
            LeadTriggerHandler.afterInsert();
        }
    }
    
    
    if (Trigger.isUpdate) {
        if(Trigger.isBefore){
            LeadTriggerHandler.beforeUpdate();
            Map<Id, Lead> oldMap = Trigger.isUpdate ? Trigger.oldMap : null;
            
            /******************************************************************************************************************
            Method  : processLeadFieldsBeforeUpdate
            Purpose : NICE - Apex class handler method for before update, encrypts mobile numbers & emails if they are provided.
            Author  : Artee Varma
            ******************************************************************************************************************/
            
            LeadTriggerHandler.processLeadFieldsBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if (Trigger.isAfter) {
            LeadTriggerHandler.afterUpdate();
        }
    }
}