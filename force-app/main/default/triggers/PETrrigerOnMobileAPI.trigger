/* Bypass Framework Enabled */
trigger PETrrigerOnMobileAPI on eventToTriggerMobileAPI__e (after Insert) {

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    for (eventToTriggerMobileAPI__e  event : Trigger.New) {
        if(event.Object_Name__c=='Booking__c'){
            BookingTriggerHandler.sendToMobileAPI(event.Object_New_Data__c,event.Object_Old_Data__c,Boolean.valueOf(event.isInsert__c));
        }
        if(event.Object_Name__c=='Unit__c'){
            UnitTriggerHandler.sendToMobileAPI(event.Object_New_Data__c,event.Object_Old_Data__c);
        }
    }

}