@isTest
private class BRPortalHomeControllerTest {
   @isTest
    static void testGetHomePageContents() {
        Profile userProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Community%' LIMIT 1];
        User adminUser = [SELECT Id, UserRoleId, Email FROM User 
                            WHERE Profile.Name = 'System Administrator' AND 
                                isActive = true LIMIT 1];
        // Create related objects
        Account testAccount = new Account(Name = 'Test Account', OwnerId = adminUser.Id);
        insert testAccount;
        // Create test Contact
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',
                                            Birthdate = System.today().addDays(-300),
                                            AccountId=testAccount.Id);
        insert testContact;
        // Create a test User linked to the test Contact and assign the Role
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = userProfile.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id,
            isActive=true
        );
        insert testUser;
        
        ContentVersion contentVersionn = new ContentVersion(
            Title = 'Booking form form.pdf',
            PathOnClient = 'Penguinns.jpg',
            VersionData = Blob.valueOf('Test Content Test'),
            IsMajorVersion = true
        );
        insert contentVersionn;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = testAccount.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        System.runAs(testUser) {
            // dummy data for the wrapper object
            List<Channel_Partner_Offers__c> dummyCPOffers = new List<Channel_Partner_Offers__c>();
            List<Customer_Offers__c> dummyCustomerOffers = new List<Customer_Offers__c>();
            List<Announcements__c> dummyAnnouncements = new List<Announcements__c>();
            List<PropStrength__Projects__c> dummyProjects = new List<PropStrength__Projects__c>();
    
            BRPortalHomeController.HomePageWrapper expectedResult = new BRPortalHomeController.HomePageWrapper();
            expectedResult.channelPartnerOffer = dummyCPOffers;
            expectedResult.customerOffer = dummyCustomerOffers;
            expectedResult.announcements = dummyAnnouncements;
            expectedResult.latestProjects = dummyProjects;
            Sobha_Event__c evt = new Sobha_Event__c();
            evt.Name = 'Test Event';
            evt.IsActive__c = true;
            insert evt;
            
            
            
            /*ContentVersion contentVersion = new ContentVersion(
                Title = 'form.pdf',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content') 
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = evt.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            conList.add(cdl);
            insert conList;*/
            BRPortalHomeController.HomePageWrapper result = BRPortalHomeController.getHomePageContents();
            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    @isTest
    static void testGetGallery() {
        Profile userProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Community%' LIMIT 1];
        User adminUser = [SELECT Id, UserRoleId, Email FROM User 
                            WHERE Profile.Name = 'System Administrator' AND 
                                isActive = true LIMIT 1];
        // Create related objects
        Account testAccount = new Account(Name = 'Test Account', OwnerId = adminUser.Id);
        insert testAccount;
        // Test data setup
        String eventName = 'Sobha Annual Meetup';
        ContentVersion contentVersionn = new ContentVersion(
            Title = 'Booking form form.pdf',
            PathOnClient = 'Penguinns.jpg',
            VersionData = Blob.valueOf('Test Content Test'),
            IsMajorVersion = true
        );
        insert contentVersionn;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = testAccount.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        // Add ContentDistribution records with dummy data related to the eventName
        Test.startTest();
        // Calling the method to get gallery
        BRPortalHomeController.HomePageWrapper result = BRPortalHomeController.getGallery(eventName);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');   
    }
}