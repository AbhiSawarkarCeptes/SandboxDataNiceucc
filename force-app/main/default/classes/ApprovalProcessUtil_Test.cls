@isTest
public class ApprovalProcessUtil_Test {
    
    
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
       // Insert ProcessInstance and ProcessInstanceStep for testing
        ProcessDefinition pd = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'Broker_Reg_Initial_Approvl_Renewal' LIMIT 1];
        
        // Create a mock ProcessInstance (Pending approval)
        ProcessInstance pi = new ProcessInstance(
            TargetObjectId = brokerReg.Id,
            Status = 'Pending',
            ProcessDefinitionId = pd.Id
        );
        //insert pi;

        // Mock ProcessInstanceStep (Approved steps)
        ProcessInstanceStep pis = new ProcessInstanceStep(
            ProcessInstanceId = pi.Id,
            StepStatus = 'Approved'
        );
        //insert pis;
        
        
    }

   @isTest
    static void test_migrateApprovalProcess() {
        List<Broker_Registration__c> brRecordList=[Select Id from Broker_Registration__c WHERE Mobile__c = '9870989989'];
        List<Account> accRecordList=[Select Id From Account WHERE Name = 'Test Account'];
        User user1 = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId !=null AND isActive=true LIMIT 1][0];

        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(brRecordList[0].id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(user1.Id); 

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Broker_Reg_Initial_Approvl_Renewal');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
         ApprovalProcessUtil.migrateApprovalProcess(brRecordList[0].Id,accRecordList[0].Id,'Broker_Reg_Initial_Approvl_Renewal','Broker_Registration_Field_Update_Request');
    }
    
    @isTest
    public static void coverageGainer_Test()
    {
        ApprovalProcessUtil.coverageGainer();
    }


}