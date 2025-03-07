/* Bypass Framework Enabled */
trigger RequesterTrigger on Requester__c (after insert, after update, before update, before insert) {

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    if(Trigger.isupdate && Trigger.isbefore){
        RequesterTriggerHandler.beforeupdate(Trigger.new,Trigger.oldMap);
    }
}