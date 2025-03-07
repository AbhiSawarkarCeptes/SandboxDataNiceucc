@isTest
public class BRPortalNotificationControllerTest {
    @isTest
    static void testCreateNotification() {
        Announcements__c a = new Announcements__c();
        a.Announcement_Title__c = 'Test';
        a.Announcement_Description__c = 'Test';
        a.IsActive__c = true;
        insert a;
        Channel_Partner_Offers__c cp = new Channel_Partner_Offers__c();
        cp.Offer_Name__c = 'Test';
        cp.Offer_Description__c = 'Test';
        cp.IsActive__c = true;
        insert cp;
        Customer_Offers__c c = new Customer_Offers__c();
        c.Offer_Name__c = 'Test';
        c.Offer_Description__c = 'Test';
        c.IsActive__c = true;
        insert c;
        List<BRPortalNotificationController.NotificationWrapper> wrapList = new List<BRPortalNotificationController.NotificationWrapper>();
        wrapList.add(new BRPortalNotificationController.NotificationWrapper('Channel Partner Offers', 'Notification Title 1', 'Notification Description 1', cp.Id, true));
        wrapList.add(new BRPortalNotificationController.NotificationWrapper('Customer Offers', 'Notification Title 2', 'Notification Description 2', c.Id, true));
        Test.startTest();
        BRPortalNotificationController.createNotification(wrapList);
        Test.stopTest();
        List<BRPortalNotificationController.NotificationData> notifications = BRPortalNotificationController.getNotifications();
        BRPortalNotificationController.getOffers();
        BRPortalNotificationController.updateLastSeen();
        System.assertNotEquals(0, notifications.size(), 'Notifications should have been created');
    }
}