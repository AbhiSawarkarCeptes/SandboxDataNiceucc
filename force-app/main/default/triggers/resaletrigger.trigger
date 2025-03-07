/* Bypass Framework Enabled */
trigger resaletrigger on Resale_Process__c (before insert, after insert, before update, after update) {

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
     if(trigger.isbefore){
         if(trigger.isupdate){
             resaletriggerHandler.onBeforeUpdate(trigger.new, trigger.oldmap);
         }
         if(trigger.isinsert){
             resaletriggerHandler.onBeforeInsert(trigger.new); 
         }   
     }
     if(trigger.isafter){
         if(trigger.isupdate){
             resaletriggerHandler.onAfterUpdate(trigger.newmap, trigger.oldmap);
         }
         if(trigger.isinsert){
             resaletriggerHandler.onAfterInsert(trigger.new);
         }
     }
}