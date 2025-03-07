public class triggerPlatformEventForMobileAPI {
	
    public static void getTriggeredData(Boolean isInsert, String triggeredNewData, String triggeredOldData, String objectName ){
        system.debug('~~~isInsert: '+isInsert);
        system.debug('~~~triggeredNewData: '+triggeredNewData);
        system.debug('~~~triggeredOldData: '+triggeredOldData);
        system.debug('~~~objectName: '+objectName);
        eventToTriggerMobileAPI__e eventData = new eventToTriggerMobileAPI__e(
        	isInsert__c = String.valueOf(isInsert), Object_Name__c = objectName, 
            Object_New_Data__c = triggeredNewData, Object_Old_Data__c = triggeredOldData );
        Database.SaveResult sr = EventBus.publish(eventData);
        
    }
    
}