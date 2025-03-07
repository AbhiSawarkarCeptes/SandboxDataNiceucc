/* Bypass Framework Enabled */
trigger ClusterTrigger on Cluster__c (after insert, after update) {
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
    boolean trgFlg = mobile_appmdt.cluster_Trigger__c;
    if(trgFlg){
        //if(trigger.isAfter && trigger.isInsert && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
        if(trigger.isAfter && trigger.isInsert && !System.IsBatch() && !System.isFuture()){
            clusTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),null);
        }
        //if(trigger.isAfter && trigger.isUpdate && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
        if(trigger.isAfter && trigger.isUpdate && !System.IsBatch() && !System.isFuture()){
            clusTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),null);
        }
        //if(trigger.isAfter && trigger.isUpdate && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
        if(trigger.isAfter && trigger.isUpdate && !System.IsBatch() && !System.isFuture()){
            system.debug('In trigger');
            clusTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),JSON.serialize(Trigger.oldMap));
        }
    }
}