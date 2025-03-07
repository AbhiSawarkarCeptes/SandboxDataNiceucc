/* Bypass Framework Enabled */
trigger ProjectTrigger on Project__c (after insert, after update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
    boolean trgFlg = mobile_appmdt.Project_Trigger__c;
    if(trgFlg){
        //if(trigger.isAfter && trigger.isInsert && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
        if(trigger.isAfter && trigger.isInsert && !System.IsBatch() && !System.isFuture()){
            ProjectTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),null);
        }
        if(trigger.isAfter && trigger.isUpdate && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
            system.debug('In trigger');
            ProjectTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),JSON.serialize(Trigger.oldMap));
        }
    }
    
}