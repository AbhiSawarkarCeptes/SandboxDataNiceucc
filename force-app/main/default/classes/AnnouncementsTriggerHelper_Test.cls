@isTest
public class AnnouncementsTriggerHelper_Test {
	@isTest
    static void testMethod1() {
        Announcements__c a = new Announcements__c();
        a.Announcement_Title__c = 'Test';
        a.Announcement_Description__c = 'Test';
        a.IsActive__c = true;
        insert a;
        
        a.IsActive__c = false;
        update a;
        
        Notification__c ntRec = new Notification__c();
        ntRec.Object_Type__c = 'Announcement';
        ntRec.CP_SC_ID__c = a.Id;
        insert ntRec;
    }
}