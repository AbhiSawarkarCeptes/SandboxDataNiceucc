public without sharing class SobhaEventTriggerHelper {
    public static Boolean run = true;
    public static void updateNotification(List<Sobha_Event__c> newList, Map<Id, Sobha_Event__c> oldMap) {
        List<Notification__c> updateNotifyList = new List<Notification__c>();
        Map<Id, Sobha_Event__c> updatedEventMap = new Map<Id, Sobha_Event__c>();
        for(Sobha_Event__c evt : newList) {
            if(evt.IsActive__c != oldMap.get(evt.Id).IsActive__c || 
                evt.Event_Description__c != oldMap.get(evt.Id).Event_Description__c) {
                updatedEventMap.put(evt.Id, evt);
            }
        }
        if(!updatedEventMap.keyset().isEmpty()) {
            for(Notification__c notify : [SELECT Id, CP_SC_ID__c 
                                            FROM Notification__c 
                                            WHERE Object_Type__c = 'Gallery' AND 
                                                CP_SC_ID__c IN: updatedEventMap.keyset() LIMIT 49999]) {
                if(updatedEventMap.containskey(notify.CP_SC_ID__c)) {
                    Notification__c updateNotify = new Notification__c(Id=notify.Id);
                    updateNotify.Description__c = updatedEventMap.get(notify.CP_SC_ID__c).Event_Description__c != null ? updatedEventMap.get(notify.CP_SC_ID__c).Event_Description__c : '';
                    updateNotify.IsActive__c = updatedEventMap.get(notify.CP_SC_ID__c).IsActive__c;
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