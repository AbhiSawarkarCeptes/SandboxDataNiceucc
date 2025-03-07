@isTest
private class BrokerPortalNotificationControllerTest {
    @isTest
    static void testCreateNotification() {
        Announcements__c a = new Announcements__c();
        a.Announcement_Title__c = 'Test';
        a.Announcement_Description__c = 'Test';
        a.IsActive__c = true;
        insert a;
        
        Channel_Partner_Offers__c cp =new Channel_Partner_Offers__c();
        cp.Offer_Name__c = 'Test';
        cp.Offer_Description__c = 'Test';
        cp.IsActive__c = true;
        insert cp;
        
        Customer_Offers__c c = new Customer_Offers__c();
        c.Offer_Name__c = 'Test';
        c.Offer_Description__c = 'Test';
        c.IsActive__c = true;
        insert c;

        
        // Test data setup
        List<BrokerPortalNotificationController.NotificationWrapper> wrapList = new List<BrokerPortalNotificationController.NotificationWrapper>();
        wrapList.add(new BrokerPortalNotificationController.NotificationWrapper('Object Type 1', 'Notification Title 1', 'Notification Description 1', 'CP_SC_ID_1'));
        wrapList.add(new BrokerPortalNotificationController.NotificationWrapper('Object Type 2', 'Notification Title 2', 'Notification Description 2', 'CP_SC_ID_2'));

        Test.startTest();
        // Calling the method to create notifications
        BrokerPortalNotificationController.createNotification(wrapList);
        Test.stopTest();

        // Assertions
        // Query the notifications and verify if they are inserted
        List<BrokerPortalNotificationController.NotificationData> notifications = BrokerPortalNotificationController.getNotifications();
        System.assertNotEquals(0, notifications.size(), 'Notifications should have been created');
    
    }

    @isTest
    static void testGetNotifications() {
        // Test data setup
        // Insert some dummy notifications using wrapperlist
        List<BrokerPortalNotificationController.NotificationWrapper> wrapList = new List<BrokerPortalNotificationController.NotificationWrapper>();
        wrapList.add(new BrokerPortalNotificationController.NotificationWrapper('Object Type 1', 'Notification Title 1', 'Notification Description 1', 'CP_SC_ID_1'));
        wrapList.add(new BrokerPortalNotificationController.NotificationWrapper('Object Type 2', 'Notification Title 2', 'Notification Description 2', 'CP_SC_ID_2'));
        BrokerPortalNotificationController.createNotification(wrapList);

        Test.startTest();
        // Call the method to get notifications
        List<BrokerPortalNotificationController.NotificationData> notifications = BrokerPortalNotificationController.getNotifications();
        BrokerPortalNotificationController.getOffers();
        BrokerPortalNotificationController.updateLastSeen();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, notifications.size(), 'Notifications should not be empty');
      
    }

 
}