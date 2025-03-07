/* Bypass Framework Enabled */
trigger TowerTrigger on Tower__c (after insert, after update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    //if(trigger.isAfter && trigger.isInsert && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
    if(trigger.isAfter && trigger.isInsert && !System.IsBatch() && !System.isFuture()){
        TowerTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),null);
    }
    //if(trigger.isAfter && trigger.isUpdate && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
    if(trigger.isAfter && trigger.isUpdate && !System.IsBatch() && !System.isFuture()){
        system.debug('In trigger');
        TowerTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),JSON.serialize(Trigger.oldMap));
    }
    
    if(Trigger.isInsert && Trigger.isAfter){//added for SOB-1944
        X_XSD_Util.processInit(Trigger.oldMap,Trigger.newMap);
    }
}