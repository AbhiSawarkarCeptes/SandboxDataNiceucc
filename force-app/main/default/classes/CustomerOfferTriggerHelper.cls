public without sharing class CustomerOfferTriggerHelper {
    public static Boolean run = true;
    public static void updateNotification(List<Customer_Offers__c> newList, Map<Id, Customer_Offers__c> oldMap) {
        List<Notification__c> updateNotifyList = new List<Notification__c>();
        Map<Id, Customer_Offers__c> updatedCustomerMap = new Map<Id, Customer_Offers__c>();
        for(Customer_Offers__c co : newList) {
            if(co.IsActive__c != oldMap.get(co.Id).IsActive__c || 
                co.Offer_Name__c != oldMap.get(co.Id).Offer_Name__c || 
                co.Offer_Description__c != oldMap.get(co.Id).Offer_Description__c) {
                updatedCustomerMap.put(co.Id, co);
            }
        }
        if(!updatedCustomerMap.keyset().isEmpty()) {
            for(Notification__c notify : [SELECT Id, CP_SC_ID__c 
                                            FROM Notification__c 
                                            WHERE Object_Type__c = 'Customer Offer' AND 
                                                CP_SC_ID__c IN: updatedCustomerMap.keyset() LIMIT 49999]) {
                if(updatedCustomerMap.containskey(notify.CP_SC_ID__c)) {
                    Notification__c updateNotify = new Notification__c(Id=notify.Id);
                    updateNotify.Title__c = updatedCustomerMap.get(notify.CP_SC_ID__c).Offer_Name__c != null ? updatedCustomerMap.get(notify.CP_SC_ID__c).Offer_Name__c : '';
                    updateNotify.Description__c = updatedCustomerMap.get(notify.CP_SC_ID__c).Offer_Description__c != null ? updatedCustomerMap.get(notify.CP_SC_ID__c).Offer_Description__c : '';
                    updateNotify.IsActive__c = updatedCustomerMap.get(notify.CP_SC_ID__c).IsActive__c;
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