public without sharing class ChannelPartnerOfferTriggerHelper {
    public static Boolean run = true;
    public static void updateNotification(List<Channel_Partner_Offers__c> newList, Map<Id, Channel_Partner_Offers__c> oldMap) {
        List<Notification__c> updateNotifyList = new List<Notification__c>();
        Map<Id, Channel_Partner_Offers__c> updatedChannelMap = new Map<Id, Channel_Partner_Offers__c>();
        for(Channel_Partner_Offers__c cpo : newList) {
            if(cpo.IsActive__c != oldMap.get(cpo.Id).IsActive__c || 
                cpo.Offer_Name__c != oldMap.get(cpo.Id).Offer_Name__c || 
                cpo.Offer_Description__c != oldMap.get(cpo.Id).Offer_Description__c) {
                updatedChannelMap.put(cpo.Id, cpo);
            }
        }
        if(!updatedChannelMap.keyset().isEmpty()) {
            for(Notification__c notify : [SELECT Id, CP_SC_ID__c 
                                            FROM Notification__c 
                                            WHERE Object_Type__c = 'Channel Partner Offer' AND 
                                                CP_SC_ID__c IN: updatedChannelMap.keyset() LIMIT 49999]) {
                if(updatedChannelMap.containskey(notify.CP_SC_ID__c)) {
                    Notification__c updateNotify = new Notification__c(Id=notify.Id);
                    updateNotify.Title__c = updatedChannelMap.get(notify.CP_SC_ID__c).Offer_Name__c != null ? updatedChannelMap.get(notify.CP_SC_ID__c).Offer_Name__c : '';
                    updateNotify.Description__c = updatedChannelMap.get(notify.CP_SC_ID__c).Offer_Description__c != null ? updatedChannelMap.get(notify.CP_SC_ID__c).Offer_Description__c : '';
                    updateNotify.IsActive__c = updatedChannelMap.get(notify.CP_SC_ID__c).IsActive__c;
                    updateNotifyList.add(updateNotify);
                }
            }
        }
        if(!updateNotifyList.isEmpty()) {
            update updateNotifyList;
        }
    }
    public static Boolean runOnce() {
        if(run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }
}