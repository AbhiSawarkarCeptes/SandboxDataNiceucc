@isTest
private class BRPortalBrokerEventsControllerTest {
    @testSetup
    static void testDataPreparation() {
        // Fetch the Profile and admin User for creating setup objects
        Profile userProfile = [SELECT Id FROM Profile WHERE Name like '%Community%' LIMIT 1];
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId !=null AND isActive=true LIMIT 1];
        
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;
        // Create related objects
        Account testAccount = new Account(BillingPostalCode= '123245', BillingCountry = 'Country', BillingState = 'state', BillingCity = 'Test City', BillingStreet = 'Test', Name = 'Test Account', OwnerId = adminUser.Id, Channel_Relationship_Manager__c = UserInfo.getUserId(), RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId());
        insert testAccount;
        // Create test Contact
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',AccountId=testAccount.Id);
        insert testContact;
        Contact testContact2 = new Contact(LastName = 'Test2', FirstName = 'User2',AccountId=testAccount.Id);
        insert testContact2;
        // Run as admin user to create setup objects
        System.runAs(adminUser) {
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
        }
        
        // Now that setup objects are created, proceed with non-setup objects
        
        // Create Sales Manager User
        User salesManager = [SELECT Id FROM User  LIMIT 1];
        
        // Create Sales Director User
        User salesDirector = [SELECT Id FROM User  LIMIT 1];
        
        Channel_Partner__c partnerRecord = new Channel_Partner__c(
            Black_listed_user__c = false,
            // Create_Portal_Login__c = false,
            Created_From_SC__c = false,
            Is_Active__c = true,
            Send_Policy_Mandate_Letter__c = false,
            Sent_To_Broker__c = false
        );
        insert partnerRecord;
        // Create a test Event
        Events__c testEvent = new Events__c(
            Name = 'Test Event',
            Collateral_Uploaded__c = false,
            Campaign_Leads__c = 10,
            Campaign_Lead_7_days_before_event__c = 7,
            Sales_Manager__c = salesManager.Id,
            Sales_Director__c = salesDirector.Id,
            Total_Purchase_Price__c = 10000,
            Expected_number_of_Visitors__c = 100,
            city_country__c = 'Test City country',
            Confirmed_No_of_Meeting__c = 5,
            Country__c = 'Test Country',
            Date_Of_Event__c = Date.today().addDays(45),
            End_Date_Of_Event__c = Date.today().addDays(50),
            Visit_numbers__c = 50,
            Event_Sales_Value__c = 5000,
            recordTypeId = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId(),
            //   CreatedById = UserInfo.getUserId(),
            Channel_Partner__c=partnerRecord.Id
        );
        insert testEvent;
        
    }
    
    /*  @isTest
static void testGetContactInfo() {
// Test getting contact info for a user
User communityUser=[Select ID,ContactId From User WHERE ContactId !=null LIMIT 1];
}
*/
    @isTest
    static void testGetEventsDetails() {
        // Test getEventsDetails method with Null inputs
        Test.startTest();
        User u = [SELECT Id FROM USER WHERE  Email = 'testuser@example.com' LIMIT 1];
        System.runAs(u) {
            Map<String, Object> result = BRPortalBrokerEventsController.getEventsDetails('Road Shows', String.valueOf(Date.today().addDays(46)),String.valueOf(Date.today().addDays(48)), 'Upcoming', '2024');
            Map<String, Object> result1 = BRPortalBrokerEventsController.getEventsDetails('Road Shows', '', '', 'Upcoming', '2024');
            Map<String, Object> result2 = BRPortalBrokerEventsController.getEventsDetails('Road Shows', '', '', 'Completed', '2024');
            Map<String, Object> result3 = BRPortalBrokerEventsController.getEventsDetails('Road Shows', '', '', '', '2024');
            Map<String, Object> result4 = BRPortalBrokerEventsController.getEventsDetails('Road Shows', '', '', '', '');
        }
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testCreateEventRecord() {
        // Test createEventRecord method
        Test.startTest();
        Time eventStartTime = Time.newInstance(14, 30, 0, 0);
        Time eventStartTime2 = Time.newInstance(18, 30, 0, 0);
        // Prepare test data
        User u = [SELECT id FROM User WHERE Email = 'testuser@example.com'];
        System.runAs(u) {
            Object eventData = new Map<String, Object>{'Name' => 'Test Event','Start_Time_of_the_Event__c' => eventStartTime, 'End_Time_of_the_Event__c' => eventStartTime2};
                String eventId = BRPortalBrokerEventsController.createEventRecord(eventData);
        }
        Test.stopTest();
        
        
    }
    @isTest
    static void testGetProfileDetails() {
        // Test getProfileDetails method
        Test.startTest();
        // Prepare test data
        // Ensure the user has a contact associated with it
        
        User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        // Simulate running as the test user
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetProjectsDetails() {
        // Test getProjectsDetails method
        Test.startTest();
        // Prepare test data if needed
        // List<Project__c> projectList = BRPortalBrokerEventsController.getProjectsDetails();
        // Ensure the result is as expected
        // System.assert(projectList == null, 'Project list should not be null');
        // Add more assertions as needed
        Test.stopTest();
    }
    
    @isTest
    static void testRenewAgreement() {
        // Test renewAgreement method
        Test.startTest();
        // Prepare test data if needed
        String renewalStatus = BRPortalBrokerEventsController.renewAgreement();
        // Ensure the result is as expected
        // Add more assertions as needed
        Test.stopTest();
    }
    
    @isTest
    static void testGetRelatedContacts() {
        // Test getRelatedContacts method
        Test.startTest();
        // Prepare test data if needed
        // Ensure the user has a contact associated with it
        
        User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        // Simulate running as the test user
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetBRFileHistory() {
        // Test getBRFileHistory method
        Test.startTest();
        User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        // Simulate running as the test user
        System.runAs(usr) {
            // List<BRPortalBrokerEventsController.docWrapper> brFileHistory = BRPortalBrokerEventsController.getBRFileHistory();
            // Ensure the result is as expected
            //System.assertEquals(null, brFileHistory, 'BR File History should not be null');
            
        }
        Test.stopTest();
    }
    @isTest
    static void testUploadFiles() {
        // Test uploadFiles method
        Test.startTest();
        String base64 = ' base64 data';
        String filename = 'test.txt';
        String recordId = [SELECT Id FROM Account LIMIT 1].Id;
        String filetype = 'FileType';
        
        String contentDocumentLinkId = BRPortalBrokerEventsController.uploadFiles(base64, filename, recordId, filetype);
        
        
        
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateBRHistoryRecord() {
        // Test updateBRHistoryRecord method
        Test.startTest();
        List<BRPortalBrokerEventsController.FileExpiryInfo> fileExpiryList = new List<BRPortalBrokerEventsController.FileExpiryInfo>();
        
        // Add FileExpiryInfo records to the list
        BRPortalBrokerEventsController.FileExpiryInfo feRec = new BRPortalBrokerEventsController.FileExpiryInfo();
        feRec.Id = 'YourRecordId';
        feRec.expiryDate = Date.today();
        fileExpiryList.add(feRec);
        
        // Call the method
        //BRPortalBrokerEventsController.updateBRHistoryRecord(fileExpiryList);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUploadMultipleFiles() {
        // Test uploadMultipleFiles method
        Test.startTest();
        User u = [SELECT id FROM User WHERE Email = 'testuser@example.com'];
        
        String recordId = [SELECT Id FROM Account LIMIT 1].Id; 
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Policy_2',
            PathOnClient = 'Policy_2',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = recordId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        String filedata = '[{"fileName": "file1.txt", "fileContent": "Base64Data1"}, {"fileName": "file2.txt", "fileContent": "Base64Data2"}]';
        Object eventData = new Map<String, Object>{'Id' => [SELECT Id FROM Events__c LIMIT 1].Id, 'Name' => 'Test Event2'};
            String result = BRPortalBrokerEventsController.uploadMultipleFiles(recordId, filedata);
        List<ContentDocumentLink> result2 = BRPortalBrokerEventsController.getVideoFiles(recordId);
        String result3 = BRPortalBrokerEventsController.uploadMultipleBalanceFiles(recordId, fileData);
        List<User> result4 = BRPortalBrokerEventsController.getSalesTeam('test', 'user');
        String result5 = BRPortalBrokerEventsController.getBaseURL();
        List<BRPortalBrokerEventsController.PolicyWrapper> result6 = BRPortalBrokerEventsController.getPolicyFiles();
        
        String result8 = BRPortalBrokerEventsController.getBodyFile([SELECT Id FROM ContentVersion LIMIT 1].Id);
        List<ContentDocumentLink> result9 = BRPortalBrokerEventsController.getAttachedDocuments(recordId);
        BRPortalBrokerEventsController.sendEmails(new List<String>{'test@6532423563.com'}, [SELECT Id FROM Contact LIMIT 1].Id ,recordId);
        BRPortalBrokerEventsController.submitApproval(recordId);
        Id result10 = BRPortalBrokerEventsController.updateEventsRecord(eventData);
        
        List<PropStrength__Projects__c> result12 = BRPortalBrokerEventsController.getProjectsDetails();
        System.runAs(u) {
            Boolean result7 = BRPortalBrokerEventsController.isEligibleForAction();
            Map<String, Object> result11 = BRPortalBrokerEventsController.getProfileDetails();
            List<BRPortalBrokerEventsController.ContactWithImage> result13 = BRPortalBrokerEventsController.getRelatedContacts();
            List<BRPortalBrokerEventsController.docWrapper> result14 = BRPortalBrokerEventsController.getBRFileHistory(false);
            List<BRPortalBrokerEventsController.docWrapper> result15 = BRPortalBrokerEventsController.getBRFileHistory(true);
            BRPortalBrokerEventsController.sendEmailToCHRM(new List<String>{'test@6532423563.com'}, recordId,recordId);
            BRPortalBrokerEventsController.deleteFile([SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId LIMIT 1].ContentDocumentId);
        }
        // Ensure the result is as expected
        Test.stopTest();
    }
    
    @IsTest
    static void testUploadMultipleFiles2() {
        // Test uploadMultipleFiles method
        Test.startTest();
        
        Broker_Renewal__c brkRenew= TestDataFactorySobha.createBrokerRenewal(null);
        insert brkRenew;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Agreement.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = brkRenew.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        conList.add(cdl);
        
        Insert conList;

        Account testAccount = new Account(Renewal_Record_Id__c = brkRenew.Id, Name = 'Test Account', OwnerId = UserInfo.getUserId(), Channel_Relationship_Manager__c = UserInfo.getUserId(), RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId());
        insert testAccount;
        Profile userProfile = [SELECT Id FROM Profile WHERE Name like '%Community%' LIMIT 1];
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',AccountId=testAccount.Id);
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
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Policy_1',
            PathOnClient = 'Policy_1',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;    
        List<ContentDocument> documents1 = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = testAccount.id;
        cdl1.ContentDocumentId = documents1[0].Id;
        cdl1.ShareType = 'V';
        insert cdl1;
        
        String recordId = testAccount.Id; 
        String filedata = '[{"fileName": "file1.txt", "fileContent": "Base64Data1"}, {"fileName": "file2.txt", "fileContent": "Base64Data2"}]';
        Object eventData = new Map<String, Object>{'Id' => [SELECT Id FROM Events__c LIMIT 1].Id, 'Name' => 'Test Event2'};
            String result = BRPortalBrokerEventsController.uploadMultipleFiles(recordId, filedata);
        List<ContentDocumentLink> result2 = BRPortalBrokerEventsController.getVideoFiles(recordId);
        String result3 = BRPortalBrokerEventsController.uploadMultipleBalanceFiles(recordId, fileData);
        List<User> result4 = BRPortalBrokerEventsController.getSalesTeam('test', 'user');
        String result5 = BRPortalBrokerEventsController.getBaseURL();
        List<BRPortalBrokerEventsController.PolicyWrapper> result6 = BRPortalBrokerEventsController.getPolicyFiles();
        Boolean result7 = BRPortalBrokerEventsController.isEligibleForAction();
        String result8 = BRPortalBrokerEventsController.getBodyFile([SELECT Id FROM ContentVersion LIMIT 1].Id);
        List<ContentDocumentLink> result9 = BRPortalBrokerEventsController.getAttachedDocuments(recordId);
        BRPortalBrokerEventsController.sendEmails(new List<String>{'test@6532423563.com'}, [SELECT Id FROM Contact LIMIT 1].Id ,recordId);
        BRPortalBrokerEventsController.submitApproval(recordId);
        Id result10 = BRPortalBrokerEventsController.updateEventsRecord(eventData);
        List<ContentDistribution> result16 = BRPortalBrokerEventsController.getCollataralFiles(testAccount.Id);
        List<PropStrength__Projects__c> result12 = BRPortalBrokerEventsController.getProjectsDetails();
        System.runAs(testUser) {
            Map<String, Object> result17 = BRPortalBrokerEventsController.getEventsDetails('Road Shows', '2024-05-24', '2024-05-30', 'Upcoming', '2024');
            Map<String, Object> result11 = BRPortalBrokerEventsController.getProfileDetails();
            List<BRPortalBrokerEventsController.ContactWithImage> result13 = BRPortalBrokerEventsController.getRelatedContacts();
            List<BRPortalBrokerEventsController.docWrapper> result14 = BRPortalBrokerEventsController.getBRFileHistory(false);
            List<BRPortalBrokerEventsController.docWrapper> result15 = BRPortalBrokerEventsController.getBRFileHistory(true);
        }
        // Ensure the result is as expected
        Test.stopTest();
    }
    
    @IsTest
    static void testUploadMultipleFiles3() {
        // Test uploadMultipleFiles method
        Test.startTest();
        
        Broker_Renewal__c brkRenew= TestDataFactorySobha.createBrokerRenewal(null);
        insert brkRenew;
        
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Noc.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = brkRenew.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        conList.add(cdl);
        
        Insert conList;

        Account testAccount = new Account(Renewal_Record_Old__c = brkRenew.Id, Name = 'Test Account', OwnerId = UserInfo.getUserId(), Channel_Relationship_Manager__c = UserInfo.getUserId(), RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId());
        insert testAccount;
        Profile userProfile = [SELECT Id FROM Profile WHERE Name like '%Community%' LIMIT 1];
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',AccountId=testAccount.Id, RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId());
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
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Policy_1',
            PathOnClient = 'Policy_1',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;    
        List<ContentDocument> documents1 = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = testAccount.id;
        cdl1.ContentDocumentId = documents1[0].Id;
        cdl1.ShareType = 'V';
        insert cdl1;
        
        String recordId = testAccount.Id; 
        String filedata = '[{"fileName": "file1.txt", "fileContent": "Base64Data1"}, {"fileName": "file2.txt", "fileContent": "Base64Data2"}]';
        Object eventData = new Map<String, Object>{'Id' => [SELECT Id FROM Events__c LIMIT 1].Id, 'Name' => 'Test Event2'};
            String result = BRPortalBrokerEventsController.uploadMultipleFiles(recordId, filedata);
        List<ContentDocumentLink> result2 = BRPortalBrokerEventsController.getVideoFiles(recordId);
        String result3 = BRPortalBrokerEventsController.uploadMultipleBalanceFiles(recordId, fileData);
        List<User> result4 = BRPortalBrokerEventsController.getSalesTeam('test', 'user');
        String result5 = BRPortalBrokerEventsController.getBaseURL();
        List<BRPortalBrokerEventsController.PolicyWrapper> result6 = BRPortalBrokerEventsController.getPolicyFiles();
        Boolean result7 = BRPortalBrokerEventsController.isEligibleForAction();
        String result8 = BRPortalBrokerEventsController.getBodyFile([SELECT Id FROM ContentVersion LIMIT 1].Id);
        List<ContentDocumentLink> result9 = BRPortalBrokerEventsController.getAttachedDocuments(recordId);
        BRPortalBrokerEventsController.sendEmails(new List<String>{'test@6532423563.com'}, [SELECT Id FROM Contact LIMIT 1].Id ,recordId);
        BRPortalBrokerEventsController.submitApproval(recordId);
        Id result10 = BRPortalBrokerEventsController.updateEventsRecord(eventData);
        List<ContentDistribution> result16 = BRPortalBrokerEventsController.getCollataralFiles(testAccount.Id);
        List<PropStrength__Projects__c> result12 = BRPortalBrokerEventsController.getProjectsDetails();
        System.runAs(testUser) {
            Map<String, Object> result11 = BRPortalBrokerEventsController.getProfileDetails();
            List<BRPortalBrokerEventsController.ContactWithImage> result13 = BRPortalBrokerEventsController.getRelatedContacts();
            List<BRPortalBrokerEventsController.docWrapper> result14 = BRPortalBrokerEventsController.getBRFileHistory(false);
            List<BRPortalBrokerEventsController.docWrapper> result15 = BRPortalBrokerEventsController.getBRFileHistory(true);
        }
        // Ensure the result is as expected
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateBRHistoryRecord1() {
        // Test updateBRHistoryRecord method
        BR_Document_History__c brd= new BR_Document_History__c();
        //brd.Name='Test';
        brd.Expiry_date__c=Date.Today().addDays(-2);
        brd.File_Name__c='TestFile.pdf';
        brd.File_Type__c='RERA Certificate';
        insert brd;
        
        Test.startTest();
        List<BRPortalBrokerEventsController.ExpiryInfoWrapper> fileExpiryList = new List<BRPortalBrokerEventsController.ExpiryInfoWrapper>();
        
        // Add FileExpiryInfo records to the list
        BRPortalBrokerEventsController.ExpiryInfoWrapper feRec = new BRPortalBrokerEventsController.ExpiryInfoWrapper();
        feRec.Id = brd.id;
        feRec.expiryDate = Date.today();
        feRec.docName = 'docName';
        fileExpiryList.add(feRec);
        
        // Call the method
        BRPortalBrokerEventsController.updateBRHistoryRecord(fileExpiryList);
        
        Test.stopTest();
    }
    
    
}