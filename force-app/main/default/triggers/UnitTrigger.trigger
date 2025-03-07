/* Bypass Framework Enabled */
trigger UnitTrigger on Unit__c (before update,after insert, after update) {

    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
    if(bypassSettingInstance.Bypass_All__c || bypassSettingInstance.Bypass_All_Triggers__c || bypassSettingInstance.Bypass_Unit_Trigger__c){ 
        System.debug('Inside ByPass Setting Triggered ->'+bypassSettingInstance); 
        return; 
    }
    
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
 	/*if(trigger.isAfter && trigger.isInsert && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
         UnitTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),null);
    }
    if(trigger.isAfter && trigger.isUpdate && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
        system.debug('In trigger');
         UnitTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),JSON.serialize(Trigger.oldMap));
    }
    if(trigger.isAfter && trigger.isUpdate ){
        UnitTriggerHandler.invalidateUnit_Hold_Request(Trigger.new, Trigger.oldMap);
    }*/
    Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
    boolean trgFlg = mobile_appmdt.Unit_Trigger__c;
    if(trgFlg){
        if(trigger.isAfter && trigger.isInsert && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
             UnitTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),null);
        }
        if(trigger.isAfter && trigger.isUpdate && !Test.isRunningTest() && !System.IsBatch() && !System.isFuture()){
            system.debug('In trigger');
             UnitTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),JSON.serialize(Trigger.oldMap));
        }
        system.debug('~~~Unit Trigger: '+System.IsBatch()+'__'+system.isScheduled());
        //if( trigger.isUpdate && (System.IsBatch() || System.isFuture()) ){
        if( trigger.isUpdate && (System.IsBatch() || System.isFuture() || Test.isRunningTest()) ){
            triggerPlatformEventForMobileAPI.getTriggeredData(trigger.isInsert, JSON.serialize(trigger.new), JSON.serialize(trigger.oldMap), 'Unit__c');
        }
        if(trigger.isAfter && trigger.isUpdate ){
            UnitTriggerHandler.invalidateUnit_Hold_Request(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isInsert && Trigger.isAfter){//added for SOB-1944
        X_XSD_Util.processInit(Trigger.oldMap,Trigger.newMap);
    }
   
}