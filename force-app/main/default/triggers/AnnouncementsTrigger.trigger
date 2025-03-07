/* Bypass Framework Enabled */
trigger AnnouncementsTrigger on Announcements__c (after insert) {
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    if(trigger.isInsert && trigger.isAfter){
        list<BrokerPortalNotificationController.NotificationWrapper> wrapList = new list<BrokerPortalNotificationController.NotificationWrapper>();
        for(Announcements__c a : trigger.new){
            if(a.IsActive__c){
                BrokerPortalNotificationController.NotificationWrapper wrap = new BrokerPortalNotificationController.NotificationWrapper('Announcement',a.Announcement_Title__c,a.Announcement_Description__c,'');
                wrapList.add(wrap);
            }
        }
        if(wrapList.size()>0){
            BrokerPortalNotificationController.createNotification(wrapList);
        }
    }
}