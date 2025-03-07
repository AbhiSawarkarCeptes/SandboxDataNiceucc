/* Bypass Framework Enabled */
trigger CustomerOfferTrigger on Customer_Offers__c (after insert) {
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    if(trigger.isInsert && trigger.isAfter){
        list<BrokerPortalNotificationController.NotificationWrapper> wrapList = new list<BrokerPortalNotificationController.NotificationWrapper>();
        for(Customer_Offers__c co : trigger.new){
            if(co.IsActive__c){
                BrokerPortalNotificationController.NotificationWrapper wrap = new BrokerPortalNotificationController.NotificationWrapper('Customer Offer',co.Offer_Name__c,co.Offer_Description__c,'');
                wrapList.add(wrap);
            }
        }
        if(wrapList.size()>0){
            BrokerPortalNotificationController.createNotification(wrapList);
        }
    }
}