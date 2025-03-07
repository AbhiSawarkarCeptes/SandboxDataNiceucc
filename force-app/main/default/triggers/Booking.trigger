/* Bypass Framework Enabled */
trigger Booking on Booking__c (after insert, after update) { 
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    public static Boolean hasFired = false;
    Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
    boolean trgFlg = mobile_appmdt.Booking_Trigger__c;
    if(trgFlg){
        if(trigger.isAfter && trigger.isInsert  && !System.IsBatch() && !System.isFuture()){
            BookingTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),null,true);
        } 
        if(trigger.isAfter && trigger.isUpdate  && !System.IsBatch() && !System.isFuture()){
            BookingTriggerHandler.sendToMobileAPI(JSON.serialize(trigger.new),JSON.serialize(Trigger.oldMap),false);
        }
        if( (trigger.isInsert || trigger.isUpdate) && (System.IsBatch() || System.isFuture()) ){
            triggerPlatformEventForMobileAPI.getTriggeredData(trigger.isInsert, JSON.serialize(trigger.new), JSON.serialize(trigger.oldMap), 'Booking__c');
        }
    }
    
    if (Trigger.isAfter && !BookingTriggerHandlerCtr.firstcall) {
        if (Trigger.isInsert){
              hasFired = true;
             BookingTriggerHandlerCtr.afterInsert(Trigger.new);
        }
        else if(Trigger.isUpdate) {
             BookingTriggerHandlerCtr.afterUpdate(Trigger.new, Trigger.oldMap);
        } 
    } 
}