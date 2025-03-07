@isTest
public class TrgDocumentValidatorTest {
    @testSetup
    public static void createData()
    {
   // Fetch the Profile and admin User for creating setup objects
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login' LIMIT 1];
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId !=null AND isActive=true LIMIT 1];

        
        Account testAccount = new Account(Name = 'Test Account', OwnerId = adminUser.Id);
        insert testAccount;
      Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',AccountId=testAccount.Id,Email='test@test2.com');
        insert testContact;
        
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
            CPID__c=partnerRecord.Id );
        
        insert brokerReg;
        
        
         BR_Document_History__c brd= new BR_Document_History__c();
        //brd.Name='Test';
        brd.Expiry_date__c=Date.Today().addDays(-2);
        brd.File_Name__c='TestFile.pdf';
        brd.File_Type__c='RERA Certificate';
        brd.Broker_Registration__c=brokerReg.Id;
        insert brd;
        
         Document_validator__c dvRecord = new Document_validator__c( BR_doc_history_id__c=String.valueOf(brd.Id));
        insert dvRecord;
        
        ContentVersion contentVersion3 = new ContentVersion(
        Title = 'testFile',
        PathOnClient = 'testFile.pdf',
        VersionData = Blob.valueOf('Test File Content agreement'),
        IsMajorVersion = true
    );
    insert contentVersion3;
        
           List<ContentVersion> contentDoc3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='testFile'];

        ContentDocumentLink contentDocLink3 = new ContentDocumentLink(
        LinkedEntityId = dvRecord.Id, // Replace with the appropriate record Id (e.g., Event or Broker_Registration)
        ContentDocumentId = contentDoc3[0].ContentDocumentId,
        ShareType = 'V', // 'I' for Inferred, other options: 'V' for Viewer, 'C' for Collaborator
        Visibility = 'AllUsers'
    );
    insert contentDocLink3;
        
        //BR_Document_History__c brDocH
       
    }

    @isTest
    public static void trgTestMethod()
    {
        
        Document_validator__c dvRecord =[ Select Id,Approval_status__c FROM Document_validator__c WHERE BR_doc_history_id__c!=Null Limit 1];
        dvRecord.Approval_status__c='Approved';
        update dvRecord;
    }
}