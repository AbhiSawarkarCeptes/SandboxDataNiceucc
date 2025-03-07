@isTest
private class BrokerPortalHomePageControllerTest {
    @testSetup
   	static void createData()
    {
         List<Channel_Partner_Offers__c> dummyCPOffers = new List<Channel_Partner_Offers__c>();
        List<Customer_Offers__c> dummyCustomerOffers = new List<Customer_Offers__c>();
        List<Announcements__c> dummyAnnouncements = new List<Announcements__c>();
        List<Cluster__c> dummyProjects = new List<Cluster__c>();
        
         BrokerPortalHomePageController.HomePageWrapper expectedResult = new BrokerPortalHomePageController.HomePageWrapper();
        expectedResult.channelPartnerOffer = dummyCPOffers;
        expectedResult.customerOffer = dummyCustomerOffers;
        expectedResult.announcements = dummyAnnouncements;
        expectedResult.latestProjects = dummyProjects;
        Sobha_Event__c evt = new Sobha_Event__c();
        evt.Name = 'Test Event2';
        evt.IsActive__c = true;
        insert evt;
        
         ContentVersion contentVersion3 = new ContentVersion(
        Title = 'Agreement',
        PathOnClient = 'Agreement.jpg',
        VersionData = Blob.valueOf('Test File Content agreement'),
        IsMajorVersion = true
    );
    insert contentVersion3;
           List<ContentVersion> contentDoc3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='Agreement'];

        ContentDocumentLink contentDocLink3 = new ContentDocumentLink(
        LinkedEntityId = evt.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc3[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink3;
        
         ContentVersion contentVersion4 = new ContentVersion(
        Title = 'video',
        PathOnClient = 'video.MP4',
        VersionData = Blob.valueOf('Test File Content agreement'),
        IsMajorVersion = true
    );
    insert contentVersion4;
        
           List<ContentVersion> contentDoc4 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='video'];

        ContentDocumentLink contentDocLink4 = new ContentDocumentLink(
        LinkedEntityId = evt.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc4[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink4;
        
        Announcements__c announce= new Announcements__c();
        announce.Announcement_Title__c='title one';
        announce.Announcement_Description__c='test description';
        announce.IsActive__c=true;
        insert announce;
        
        ContentVersion contentVersion5 = new ContentVersion(
        Title = 'testFile',
        PathOnClient = 'testFile.pdf',
        VersionData = Blob.valueOf('Test File Content agreement'),
        IsMajorVersion = true
    );
    insert contentVersion5;
           List<ContentVersion> contentDoc5 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='testFile'];

        ContentDocumentLink contentDocLink5 = new ContentDocumentLink(
        LinkedEntityId = announce.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc5[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink5;
        
    }
   @isTest
    static void testGetHomePageContents() {
        // Test data s
     
        // dummy data for the wrapper object
        List<Channel_Partner_Offers__c> dummyCPOffers = new List<Channel_Partner_Offers__c>();
        List<Customer_Offers__c> dummyCustomerOffers = new List<Customer_Offers__c>();
        List<Announcements__c> dummyAnnouncements = new List<Announcements__c>();
        List<Cluster__c> dummyProjects = new List<Cluster__c>();

        BrokerPortalHomePageController.HomePageWrapper expectedResult = new BrokerPortalHomePageController.HomePageWrapper();
        expectedResult.channelPartnerOffer = dummyCPOffers;
        expectedResult.customerOffer = dummyCustomerOffers;
        expectedResult.announcements = dummyAnnouncements;
        expectedResult.latestProjects = dummyProjects;
        Sobha_Event__c evt = new Sobha_Event__c();
        evt.Name = 'Test Event';
        evt.IsActive__c = true;
        insert evt;
        
         ContentVersion contentVersion3 = new ContentVersion(
        Title = 'Agreement',
        PathOnClient = 'Agreement.jpg',
        VersionData = Blob.valueOf('Test File Content agreement'),
        IsMajorVersion = true
    );
    insert contentVersion3;
           List<ContentVersion> contentDoc3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='Agreement'];

        ContentDocumentLink contentDocLink3 = new ContentDocumentLink(
        LinkedEntityId = evt.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc3[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink3;
        
        
        Test.startTest();
        // Call the method to get home page contents
        BrokerPortalHomePageController.HomePageWrapper result = BrokerPortalHomePageController.getHomePageContents();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        // Add more assertions as needed
    }

    @isTest
    static void testGetGallery() {
        // Test data setup
        String eventName = 'Test Event2';
        // Add ContentDistribution records with dummy data related to the eventName

        Test.startTest();
        // Calling the method to get gallery
        BrokerPortalHomePageController.HomePageWrapper result = BrokerPortalHomePageController.getGallery(eventName);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
       
    }
    
}