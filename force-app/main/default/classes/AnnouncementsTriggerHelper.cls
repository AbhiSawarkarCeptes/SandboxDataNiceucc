public without sharing class AnnouncementsTriggerHelper {
    public static Boolean run = true;
    public static void updateNotification(List<Announcements__c> newList, Map<Id, Announcements__c> oldMap) {
        List<Notification__c> updateNotifyList = new List<Notification__c>();
        Map<Id, Announcements__c> updatedAnnounceMap = new Map<Id, Announcements__c>();
        for(Announcements__c announce : newList) {
            if(announce.IsActive__c != oldMap.get(announce.Id).IsActive__c || 
                announce.Announcement_Title__c != oldMap.get(announce.Id).Announcement_Title__c || 
                announce.Announcement_Description__c != oldMap.get(announce.Id).Announcement_Description__c) {
                updatedAnnounceMap.put(announce.Id, announce);
            }
        }
        if(!updatedAnnounceMap.keyset().isEmpty()) {
            for(Notification__c notify : [SELECT Id, CP_SC_ID__c 
                                            FROM Notification__c 
                                            WHERE Object_Type__c = 'Announcement' AND 
                                                CP_SC_ID__c IN: updatedAnnounceMap.keyset() LIMIT 49999]) {
                if(updatedAnnounceMap.containskey(notify.CP_SC_ID__c)) {
                    Notification__c updateNotify = new Notification__c(Id=notify.Id);
                    updateNotify.Title__c = updatedAnnounceMap.get(notify.CP_SC_ID__c).Announcement_Title__c != null ? updatedAnnounceMap.get(notify.CP_SC_ID__c).Announcement_Title__c : '';
                    updateNotify.Description__c = updatedAnnounceMap.get(notify.CP_SC_ID__c).Announcement_Description__c != null ? updatedAnnounceMap.get(notify.CP_SC_ID__c).Announcement_Description__c : '';
                    updateNotify.IsActive__c = updatedAnnounceMap.get(notify.CP_SC_ID__c).IsActive__c;
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