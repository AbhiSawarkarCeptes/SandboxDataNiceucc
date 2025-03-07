/* Bypass Framework Enabled */
trigger ChannelPartnerOfferTrigger on Channel_Partner_Offers__c (after insert) {
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    if(trigger.isInsert && trigger.isAfter){
        list<BrokerPortalNotificationController.NotificationWrapper> wrapList = new list<BrokerPortalNotificationController.NotificationWrapper>();
        for(Channel_Partner_Offers__c cpo : trigger.new){
            if(cpo.IsActive__c){
                BrokerPortalNotificationController.NotificationWrapper wrap = new BrokerPortalNotificationController.NotificationWrapper('Channel Partner Offer',cpo.Offer_Name__c,cpo.Offer_Description__c,'');
                wrapList.add(wrap);
            }
        }
        if(wrapList.size()>0){
            BrokerPortalNotificationController.createNotification(wrapList);
        }
    }
}