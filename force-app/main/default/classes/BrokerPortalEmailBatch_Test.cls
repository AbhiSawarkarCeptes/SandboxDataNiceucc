@isTest
public class BrokerPortalEmailBatch_Test {

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

              User salesManager = [SELECT Id FROM User WHERE Profile.Name = 'Sales' AND IsActive=True LIMIT 1];

        // Create Sales Director User
        User salesDirector = [SELECT Id FROM User WHERE Profile.Name = 'Sales' AND IsActive=True LIMIT 1];


        Channel_Partner__c partnerRecord = new Channel_Partner__c(
            Black_listed_user__c = false,
           // Create_Portal_Login__c = false,
            Created_From_SC__c = false,
            Is_Active__c = true,
            Send_Policy_Mandate_Letter__c = false,
            Sent_To_Broker__c = false,
            Contact__c=testContact.Id,
            Channel_Relationship_Manager__c=salesManager.Id
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
           OwnerId = adminUser.Id
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
            //CPID__c=partnerRecord.Id,
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
            SCID__c=partnerRecordSC.Id
        );
        
        insert brokerReg2;
        
        BR_Document_History__c brd= new BR_Document_History__c();
        //brd.Name='Test';
        brd.Broker_Registration__c=brokerReg.Id;
        brd.Expiry_date__c=Date.Today().addDays(-2);
        brd.File_Name__c='TestFile.pdf';
        brd.File_Type__c='RERA Certificate';
        brd.New_File_Uploaded__c = true;
        insert brd;
    }

    @isTest
    static void testBrokerPortalEmailBatch() {
        // Start the test
        Test.startTest();

        // Instantiate the batch class
        BrokerPortalEmailBatch batch = new BrokerPortalEmailBatch();
        
        // Execute the batch
        ID batchJobId = Database.executeBatch(batch);

        // Finish the test
        Test.stopTest();

        // Verify that emails were sent
        // List<Messaging.SingleEmailMessage> sentEmails = [SELECT Id FROM EmailMessage];
        // System.assertEquals(1, sentEmails.size(), 'One email should be sent.');

        // // Verify that the New_File_Uploaded__c field was updated to false
        // BR_Document_History__c updatedDocHistory = [SELECT New_File_Uploaded__c FROM BR_Document_History__c LIMIT 1];
        // System.assertEquals(false, updatedDocHistory.New_File_Uploaded__c, 'New_File_Uploaded__c should be updated to false.');
    }
}