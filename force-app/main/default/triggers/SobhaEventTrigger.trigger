/* Bypass Framework Enabled */
trigger SobhaEventTrigger on Sobha_Event__c (after insert) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    if(trigger.isInsert && trigger.isAfter){
        list<BrokerPortalNotificationController.NotificationWrapper> wrapList = new list<BrokerPortalNotificationController.NotificationWrapper>();
        for(Sobha_Event__c se : trigger.new){
            if(se.IsActive__c){
                BrokerPortalNotificationController.NotificationWrapper wrap = new BrokerPortalNotificationController.NotificationWrapper('Gallery',se.Name,se.Event_Description__c,'');
                wrapList.add(wrap);
            }
        }
        if(wrapList.size()>0){
            BrokerPortalNotificationController.createNotification(wrapList);
        }
    }
}