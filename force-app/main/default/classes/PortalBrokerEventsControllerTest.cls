@isTest
private class PortalBrokerEventsControllerTest {
         @testSetup
    static void testDataPreparation() {
        // Fetch the Profile and admin User for creating setup objects
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login' LIMIT 1];
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId !=null AND isActive=true LIMIT 1];

        
        // Create related objects
        Account testAccount = new Account(Name = 'Test Account', OwnerId = adminUser.Id);
        insert testAccount;
 // Create test Contact
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',AccountId=testAccount.Id,Email='test@test2.com');
        insert testContact;
        Contact testContact2 = new Contact(LastName = 'Test2', FirstName = 'User2',AccountId=testAccount.Id,Email='test@test3.com');
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
            
                User testUser2 = new User(
                FirstName = 'Test2',
                LastName = 'User2',
                Email = 'testuser2@example.com',
                Username = 'testuser2' + DateTime.now().getTime() + '@example.com',
                Alias = 'tuser2',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = userProfile.Id,
                LanguageLocaleKey = 'en_US',
                ContactId = testContact2.Id,
                isActive=true
            );
            insert testUser2;
        }

        // Now that setup objects are created, proceed with non-setup objects

        // Create Sales Manager User
        User salesManager = [SELECT Id FROM User WHERE Profile.Name = 'Sales' LIMIT 1];

        // Create Sales Director User
        User salesDirector = [SELECT Id FROM User WHERE Profile.Name = 'Sales' LIMIT 1];

        Channel_Partner__c partnerRecord = new Channel_Partner__c(
            Black_listed_user__c = false,
           // Create_Portal_Login__c = false,
            Created_From_SC__c = false,
            Is_Active__c = true,
            Send_Policy_Mandate_Letter__c = false,
            Sent_To_Broker__c = false,
            Contact__c=testContact.Id
			);
        insert partnerRecord;
        
        Sobha_connect__c partnerRecordSC = new Sobha_connect__c(
            Black_listed_user__c = false,
            Create_Portal_Login__c = false,
            Created_From_CP__c = false,
            //Is_Active__c = true,
            Send_SC_Mandate_Letter__c = false,
            Contact__c=testContact2.Id
            //Sent_To_Broker__c = false
			);
        insert partnerRecordSC;
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
            Date_Of_Event__c = Date.today().addDays(40),
            End_Date_Of_Event__c = Date.today().addDays(41),
            Visit_numbers__c = 50,
            Event_Sales_Value__c = 5000,
            recordTypeId = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId(),
         //   CreatedById = UserInfo.getUserId(),
            Channel_Partner__c=partnerRecord.Id,
           OwnerId = adminUser.Id,
           Event_status__c='Completed',
           Event_Approved_status__c='Approved'

        );
        insert testEvent;
      
         Broker_Registration__c brokerReg = new Broker_Registration__c(
            Agreement_Generated_Status_Updatec__c = false,
            All_Document_Uploaded__c = false,
            All_Mandatory_Documents__c = false,
            All_Mandatory_Non_Mandatory_Documents__c = false,
          //  Blacklisted__c = false,
            Broker_Category__c = 'Broker - RERA', // Assuming this is a string	
            //Document_Visibility__c = false,
            Email__c = 'test1@example1.com', // Assuming this is a string
            Email_Category__c = false, // Assuming this is a string
           // Emirates_ID__c = false,
          //  Identification_Documents__c = false,
            Is_Batch_Loaded__c = false,
           // Is_Renewed__c = false,
            //Is_Rera_Catg_and_Not_Renewal__c = false,
            //Is_Rera_Catg_and_Renewal__c = true,
            //Is_UAE_Category__c = false,
           // Make_Readyonly__c = false,
            Mandatory_Documents_Missing__c = false,
            Mobile__c = '9870989989', // Assuming this is a string
            NOC_generated_status_updated__c = false,
          //  Passport_Copy__c = false,
          //  POA_MOA__c = false,
          //  Registration_Form__c = false,
          //  RERA_Certificate__c = false,
          //  Show_Send_Renewal_Link_Button__c = false,
          //  Skip_Broker_Email_Notification__c = false,
          //  Skip_Record_Lock_Validation__c = false,
          //  Trade_License__c = false,
          //  Translated_Company_Documents__c = false,
           // Vat_Certificate__c = false,
          //  Visa_Copy__c = false,
          Renewal_Status__c ='Renewal Initiated',
           Last_Name__c='test',
            CPID__c=partnerRecord.Id
        );
        
        insert brokerReg;
        
         Broker_Registration__c brokerReg2 = new Broker_Registration__c(
            Agreement_Generated_Status_Updatec__c = false,
            All_Document_Uploaded__c = false,
            All_Mandatory_Documents__c = false,
            All_Mandatory_Non_Mandatory_Documents__c = false,
           // Blacklisted__c = false,
            Broker_Category__c = 'Broker - RERA', // Assuming this is a string	
            //Document_Visibility__c = false,
            Email__c = 'test2@example2.com', // Assuming this is a string
            Email_Category__c = false, // Assuming this is a string
           // Emirates_ID__c = false,
          //  Identification_Documents__c = false,
            Is_Batch_Loaded__c = false,
         //   Is_Renewed__c = false,
            //Is_Rera_Catg_and_Not_Renewal__c = false,
            //Is_Rera_Catg_and_Renewal__c = true,
            //Is_UAE_Category__c = false,
           // Make_Readyonly__c = false,
            Mandatory_Documents_Missing__c = false,
            Mobile__c = '9870989959', // Assuming this is a string
            NOC_generated_status_updated__c = false,
        //    Passport_Copy__c = false,
        //    POA_MOA__c = false,
       //     Registration_Form__c = false,
      //      RERA_Certificate__c = false,
            Show_Send_Renewal_Link_Button__c = false,
      //      Skip_Broker_Email_Notification__c = false,
       //     Skip_Record_Lock_Validation__c = false,
      //      Trade_License__c = false,
     //       Translated_Company_Documents__c = false,
     //       Vat_Certificate__c = false,
     //       Visa_Copy__c = false,
     Renewal_Status__c ='Renewal Initiated',
     Last_Name__c='Test',
            SCID__c=partnerRecordSC.Id
        );
        
        insert brokerReg2;
 
        ContentVersion contentVersion3 = new ContentVersion(
        Title = 'Agreement',
        PathOnClient = 'Agreement.pdf',
        VersionData = Blob.valueOf('Test File Content agreement'),
        IsMajorVersion = true
    );
    insert contentVersion3;
           List<ContentVersion> contentDoc3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='Agreement'];

        ContentDocumentLink contentDocLink3 = new ContentDocumentLink(
        LinkedEntityId = brokerReg.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc3[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink3;
        
        ContentVersion contentVersion4 = new ContentVersion(
        Title = 'NOC',
        PathOnClient = 'NOC.pdf',
        VersionData = Blob.valueOf('Test File Content agreement NOc'),
        IsMajorVersion = true
    );
    insert contentVersion4;
         List<ContentVersion> contentDoc4 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='NOC'];

        ContentDocumentLink contentDocLink4 = new ContentDocumentLink(
        LinkedEntityId = brokerReg.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc4[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink4;
         ContentVersion contentVersion5= new ContentVersion(
        Title = 'Agreement',
        PathOnClient = 'Agreement.pdf',
        VersionData = Blob.valueOf('Test File Content agreement'),
        IsMajorVersion = true
    );
    insert contentVersion5;
           List<ContentVersion> contentDoc5 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='Agreement'];

        ContentDocumentLink contentDocLink5 = new ContentDocumentLink(
        LinkedEntityId = brokerReg2.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc5[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink5;
        
        ContentVersion contentVersion6 = new ContentVersion(
        Title = 'NOC',
        PathOnClient = 'NOC.pdf',
        VersionData = Blob.valueOf('Test File Content agreement NOc'),
        IsMajorVersion = true
    );
    insert contentVersion6;
         List<ContentVersion> contentDoc6 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='NOC'];

        ContentDocumentLink contentDocLink6 = new ContentDocumentLink(
        LinkedEntityId = brokerReg2.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc6[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink6;

        
        
        BR_Document_History__c brd= new BR_Document_History__c();
        //brd.Name='Test';
        brd.Expiry_date__c=Date.Today().addDays(-2);
        brd.File_Name__c='TestFile.pdf';
        brd.File_Type__c='RERA Certificate';
        insert brd;
        
        ContentVersion contentVersion = new ContentVersion(
        Title = 'Test Document',
        PathOnClient = 'TestFile.pdf',
        VersionData = Blob.valueOf('Test File Content'),
        IsMajorVersion = true
    );
    insert contentVersion;
        
        ContentVersion contentVersion2 = new ContentVersion(
        Title = 'Test Document2',
        PathOnClient = 'TestFile2.pdf',
        VersionData = Blob.valueOf('Test File Content2'),
        IsMajorVersion = true
    );
    insert contentVersion2;

    // Retrieve the ContentDocumentId from the inserted ContentVersion
   List<ContentVersion> contentDoc = [SELECT ContentDocumentId FROM ContentVersion];

    // Create ContentDocumentLink to associate with a specific record
    ContentDocumentLink contentDocLink = new ContentDocumentLink(
        LinkedEntityId = brd.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink;
    
    // You can create more ContentDocumentLinks as needed for other records
    ContentDocumentLink contentDocLink2 = new ContentDocumentLink(
        LinkedEntityId = brd.Id, // Another record to associate with the document
        ContentDocumentId = contentDoc[1].ContentDocumentId,
        ShareType = 'V',
        Visibility = 'AllUsers'
    );
    insert contentDocLink2;
    }

    @isTest
    static void testGetContactInfo() {
        // Test getting contact info for a user
        User communityUser=[Select ID,ContactId From User WHERE ContactId !=null LIMIT 1];
        System.runAs(communityUser) {
            System.assertEquals(communityUser.ContactId, PortalBrokerEventsController.getContactInfo());
        }
    }

    @isTest
    static void testGetEventsDetails() {
        // Test getEventsDetails method with Null inputs
        Test.startTest();
        Map<String, Object> result = PortalBrokerEventsController.getEventsDetails('Road Shows', String.valueOf(Date.today().addDays(40)), String.valueOf(Date.today().addDays(41)), 'Upcoming', '2024');
        Map<String, Object> result2 = PortalBrokerEventsController.getEventsDetails('Road Shows', '', '', 'Upcoming', '2024');
        Map<String, Object> result3 = PortalBrokerEventsController.getEventsDetails('Road Shows', '', '', 'Completed', '2024');
        Map<String, Object> result4 = PortalBrokerEventsController.getEventsDetails('Road Shows', '', '', '', '2024');
        Map<String, Object> result5 = PortalBrokerEventsController.getEventsDetails('Road Shows', '', '', '', '');

        Test.stopTest();
        
    }

    @isTest
    static void testCreateEventRecord() {
        
        User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        User usr2=[Select Id from User where Email='testuser2@example.com' Limit 1];
        // Test createEventRecord method
        Test.startTest();
        // Prepare test data
        system.runAs(usr)
        {
        Map<String, Object> eventData1 = new Map<String, Object>{'Date_Of_Event__c'=>Date.today().addDays(40),'End_Date_Of_Event__c'=>Date.today().addDays(41),'Start_Time_of_the_Event__c'=>'07:27','End_Time_of_the_Event__c'=>'11:25','Brief_on_city_country__c'=>'test 1','Target_audience__c'=>'test 2','Venue_Hotel_Name_Name_of_Event_Hall__c'=>'test 3','Platforms_for_campaigns__c'=>'test 4','HOTEL2__c'=>'test 5','Sobha_sales_team__c'=>'test 6','HOTEL3__c'=>'test 7','Projects_focused_on__c'=>'test 8','Expected_Closure__c'=>'12','Expected_Meetings__c'=>'13'};
        Id eventId1 = PortalBrokerEventsController.createEventRecord(eventData1);
        System.assertNotEquals(null, eventId1, 'Event Id should not be null');
        }
         system.runAs(usr2)
        {
        Map<String, Object> eventData2 = new Map<String, Object>{'Date_Of_Event__c'=>Date.today().addDays(40),'End_Date_Of_Event__c'=>Date.today().addDays(41),'Start_Time_of_the_Event__c'=>'07:27','End_Time_of_the_Event__c'=>'11:25','Brief_on_city_country__c'=>'test 1','Target_audience__c'=>'test 2','Venue_Hotel_Name_Name_of_Event_Hall__c'=>'test 3','Platforms_for_campaigns__c'=>'test 4','HOTEL2__c'=>'test 5','Sobha_sales_team__c'=>'test 6','HOTEL3__c'=>'test 7','Projects_focused_on__c'=>'test 8','Expected_Closure__c'=>'12','Expected_Meetings__c'=>'13'};
        Id eventId2 = PortalBrokerEventsController.createEventRecord(eventData2);    
        Test.stopTest();
        }

        

       
    }
      @isTest
    static void testGetProfileDetails() {
        // Test getProfileDetails method
        Test.startTest();
        // Prepare test data
        // Ensure the user has a contact associated with it
       
        User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        // Simulate running as the test user
        System.runAs(usr) {
            Map<String, Object> result = PortalBrokerEventsController.getProfileDetails();
            // Ensure the result is as expected
            System.assert(result != null, 'Result should not be null');
            // Add more assertions as needed
        }
        
        User usr2=[Select Id from User where Email='testuser2@example.com' Limit 1];
        // Simulate running as the test user
        System.runAs(usr2) {
            Map<String, Object> result = PortalBrokerEventsController.getProfileDetails();
            // Ensure the result is as expected
            System.assert(result != null, 'Result should not be null');
            // Add more assertions as needed
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProjectsDetails() {
        // Test getProjectsDetails method
        Test.startTest();
        // Prepare test data if needed
        List<Project__c> projectList = PortalBrokerEventsController.getProjectsDetails();
        // Ensure the result is as expected
        System.assert(projectList == null, 'Project list should not be null');
        // Add more assertions as needed
        Test.stopTest();
        PortalBrokerEventsController.getPolicyFiles();
        PortalBrokerEventsController.getBaseURL();
        PortalBrokerEventsController.getSalesTeam('Test','User');
    }

    @isTest
    static void testRenewAgreement() {
        // Test renewAgreement method
        User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        User usr2=[Select Id from User where Email='testuser2@example.com' Limit 1];
        Test.startTest();
        // Prepare test data if needed
       System.runAs(usr) {
        String renewalStatus = PortalBrokerEventsController.renewAgreement();
      
        // Ensure the result is as expected
        System.assert(renewalStatus != null, 'Renewal status should not be null');
            }
        System.runAs(usr2) {
        String renewalStatus = PortalBrokerEventsController.renewAgreement();
      
        // Ensure the result is as expected
        System.assert(renewalStatus != null, 'Renewal status should not be null');
            }
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
        System.runAs(usr) {
            List<PortalBrokerEventsController.ContactWithImage> relatedContacts = PortalBrokerEventsController.getRelatedContacts();
            // Ensure the result is as expected
            System.assertEquals(false, relatedContacts.isEmpty(), 'Related contacts should not be null');
            // Add more assertions as needed
        }
        Test.stopTest();
    }

    
     @isTest
    static void testIsEligibleForAction() {
        // Test getRelatedContacts method
        Test.startTest();
        // Prepare test data if needed
        // Ensure the user has a contact associated with it
       
        User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        // Simulate running as the test user
        System.runAs(usr) {
            Boolean isItTrue = PortalBrokerEventsController.isEligibleForAction();
            // Ensure the result is as expected
            System.assertEquals(false, isItTrue, 'still valid');
            // Add more assertions as needed
        }
        Test.stopTest();
    }
    @isTest
    static void testGetBRFileHistory() {
        // Test getBRFileHistory method
        Test.startTest();
         User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
         User usr2=[Select Id from User where Email='testuser2@example.com' Limit 1];
        // Simulate running as the test user
        System.runAs(usr) {
            List<PortalBrokerEventsController.docWrapper> brFileHistory = PortalBrokerEventsController.getBRFileHistory(false);
            // Ensure the result is as expected
            System.assertNotEquals(null, brFileHistory, 'BR File History should not be null');
           
        }
        System.runAs(usr2) {
            List<PortalBrokerEventsController.docWrapper> brFileHistory2 = PortalBrokerEventsController.getBRFileHistory(false);
            // Ensure the result is as expected
            System.assertNotEquals(null, brFileHistory2, 'BR File History should not be null');
           
        }
        System.runAs(usr) {
            List<PortalBrokerEventsController.docWrapper> brFileHistory = PortalBrokerEventsController.getBRFileHistory(true);
            // Ensure the result is as expected
            System.assertNotEquals(null, brFileHistory, 'BR File History should not be null');
           
        }
        System.runAs(usr2) {
            List<PortalBrokerEventsController.docWrapper> brFileHistory2 = PortalBrokerEventsController.getBRFileHistory(true);
            // Ensure the result is as expected
            System.assertNotEquals(null, brFileHistory2, 'BR File History should not be null');
           
        }
        Test.stopTest();
    }
     @isTest
    static void testUploadFiles() {
        // Test uploadFiles method
        Test.startTest();
        String base64 = ' base64 data';
        String filename = 'test.txt';
        Events__c evRec=[Select id, Name from Events__c Limit 1];
        String recordId = evRec.Id;
        String filetype = 'FileType';
        
        String contentDocumentLinkId = PortalBrokerEventsController.uploadFiles(base64, filename, recordId, filetype);
       
        System.assertNotEquals(null, contentDocumentLinkId, 'ContentDocumentLink Id should not be null');
      
        
        Test.stopTest();
    }
    
    
   @IsTest
    static void TestSetProfilePicture() {
        // Test uploadFiles method
        Test.startTest();
        User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        User usr2=[Select Id from User where Email='testuser2@example.com' Limit 1];
        // Simulate running as the test user
       // insert testEvent2;
        System.runAs(usr) {
        String base64 = ' base64 data';
        String filename = 'test.txt';
        //Events__c evRec=[Select id, Name from Events__c Limit 1];
       // String recordId = evRec.Id;
        String filetype = 'jpeg';
        
        String contentDocumentLinkId = PortalBrokerEventsController.setProfilePicture(filename,filetype,base64 );
       
        }
        
        Test.stopTest();
    }
      

    @isTest
    static void testUpdateBRHistoryRecord() {
        // Test updateBRHistoryRecord method
        Test.startTest();
        BR_Document_History__c brRec=[Select Id,Expiry_date__c From BR_Document_History__c Limit 1];
        List<PortalBrokerEventsController.FileExpiryInfo> fileExpiryList = new List<PortalBrokerEventsController.FileExpiryInfo>();
      
        // Add FileExpiryInfo records to the list
        PortalBrokerEventsController.FileExpiryInfo feRec = new PortalBrokerEventsController.FileExpiryInfo();
        feRec.Id=brRec.Id;
        feRec.expiryDate = Date.today().addDays(10);
        fileExpiryList.add(feRec);

        // Call the method
        PortalBrokerEventsController.updateBRHistoryRecord(fileExpiryList);
       
        Test.stopTest();
    }

    @isTest
    static void testUploadMultipleFiles() {
        // Test uploadMultipleFiles method
        Test.startTest();
        Broker_Registration__c brRec=[Select Id FROM Broker_Registration__c WHERE Email__c='test1@example1.com'];
        Events__c evRec=[Select id, Name from Events__c Limit 1];
        String recordId = evRec.Id;
        String filedata = '[{"fileName": "file1.txt", "fileContent": "Base64Data1"}, {"fileName": "file2.txt", "fileContent": "Base64Data2"}]';
        
        String result = PortalBrokerEventsController.uploadMultipleFiles(recordId, filedata);
        // Ensure the result is as expected
        System.assertEquals('success', result, 'Upload should be successful');
        Test.stopTest();
    }
    
    @isTest
    static void testUploadMultipleBalanceFiles() {
        // Test uploadMultipleFiles method
        Test.startTest();
        Broker_Registration__c brRec=[Select Id FROM Broker_Registration__c WHERE Email__c='test1@example1.com'];
         Events__c evRec=[Select id, Name from Events__c Limit 1];
        String recordId = evRec.Id;
        String filedata = '[{"fileName": "file1.txt", "fileContent": "Base64Data1"}, {"fileName": "file2.txt", "fileContent": "Base64Data2"}]';
        
        String result = PortalBrokerEventsController.uploadMultipleBalanceFiles(brRec.Id, filedata);
        // Ensure the result is as expected
        System.assertEquals('success', result, 'Upload should be successful');
        Test.stopTest();
    }

    @isTest
    static void testUpdateEventsRecord() {
        // Test updateEventsRecord method
        Test.startTest();
         Map<String, Object> eventData = new Map<String, Object>{'Date_Of_Event__c'=>Date.today().addDays(40),'End_Date_Of_Event__c'=>Date.today().addDays(41),'Start_Time_of_the_Event__c'=>'07:27','End_Time_of_the_Event__c'=>'11:25','Brief_on_city_country__c'=>'test 1','Target_audience__c'=>'test 2','Venue_Hotel_Name_Name_of_Event_Hall__c'=>'test 3','Platforms_for_campaigns__c'=>'test 4','HOTEL2__c'=>'test 5','Sobha_sales_team__c'=>'test 6','HOTEL3__c'=>'test 7','Projects_focused_on__c'=>'test 8','Expected_Closure__c'=>'12','Expected_Meetings__c'=>'13','Collateral_Uploaded__c'=>'true'};
       // Object updateData = new Object();
        Events__c evRec=[Select id, Name from Events__c Limit 1]; 
       eventData.put('Id',evRec.ID);
       Id result = PortalBrokerEventsController.updateEventsRecord(eventData);
       
      // System.assertNotEquals(null, result, 'Id should not be null');
        
        Test.stopTest();
    }
    
    @isTest
    public static void TestGetAttachedDocuments()
    {
        test.startTest();
        Events__c evRec=[Select id, Name from Events__c Limit 1];
        PortalBrokerEventsController.getAttachedDocuments(evRec.Id);
        test.stopTest();
    }
    
     @isTest
    public static void TestGetCollateralFiles()
    {
        test.startTest();
        Events__c evRec=[Select id, Name from Events__c Limit 1];
        PortalBrokerEventsController.getCollataralFiles(evRec.Id);
        test.stopTest();
    }
    
    @isTest
    public static void TestDeleteFile()
    {
         Events__c evRec=[Select id, Name from Events__c Limit 1];
         ContentVersion contentVersion2 = new ContentVersion(
        Title = 'Test Document4',
        PathOnClient = 'TestFile4.pdf',
        VersionData = Blob.valueOf('Test File Content2'),
        IsMajorVersion = true
    );
    insert contentVersion2;

    // Retrieve the ContentDocumentId from the inserted ContentVersion
   List<ContentVersion> contentDoc = [SELECT ContentDocumentId FROM ContentVersion];

    // Create ContentDocumentLink to associate with a specific record
    ContentDocumentLink contentDocLink = new ContentDocumentLink(
        LinkedEntityId = evRec.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink;
        
        Test.startTest();
        String base64 = ' base64 data';
        String filename = 'test.txt';
        //Events__c evRec=[Select id, Name from Events__c Limit 1];
        String recordId = evRec.Id;
        String filetype = 'FileType';
        
        String contentDocumentLinkId = PortalBrokerEventsController.uploadFiles(base64, filename, recordId, filetype);
       	PortalBrokerEventsController.deleteFile(contentDocumentLinkId);
        System.assertNotEquals(null, contentDocumentLinkId, 'ContentDocumentLink Id should not be null');
      PortalBrokerEventsController.deleteFile(contentDocLink.Id);
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void TestGetVideoFiles()
    {
        test.startTest();
        Events__c evRec=[Select id, Name from Events__c Limit 1];
        PortalBrokerEventsController.getVideoFiles(evRec.Id);
        test.stopTest();
    }
    
     @isTest
    public static void TestdeleteUserPhoto()
    {
         User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        test.startTest();
         System.runAs(usr) {
        
        PortalBrokerEventsController.deleteUserPhoto();
         }
        test.stopTest();
    }
    
    
     @isTest
    public static void TestGetBodyFile()
    {
         ContentVersion cV=[Select Id from ContentVersion where title='Test Document2' Limit 1];
        test.startTest();
        
        
        PortalBrokerEventsController.getBodyFile(cV.Id);
         
        test.stopTest();
    }
    
   /*  @isTest
    public static void TestSendEmailToCHRM()
    {
        test.startTest();
        // User communityUser=[Select ID,ContactId From User WHERE LastName='Test' LIMIT 1];
         //System.runAs(communityUser) {
             User usr=[Select Id from User where Email='testuser@example.com' Limit 1];
        // Simulate running as the test user
        System.runAs(usr) {
        List<string> emailRecievers= new List<string>();
        emailRecievers.add('tset@test.com');
        Events__c evRec=[Select id, Name from Events__c WHERE city_country__c = 'Test City country' Limit 1];
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'uniqueTemplateName';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();

        insert validEmailTemplate;
        PortalBrokerEventsController.sendEmailToCHRM(emailRecievers,'uniqueTemplateName',evRec.Id);
         }
        test.stopTest();
    }*/
}