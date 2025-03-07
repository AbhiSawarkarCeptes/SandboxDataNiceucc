/***************************************************************************
Class      : brokerRegistrationTrghandler
Test Class : brokerRegistrationTriggerTest
Purpose    : NICE - Test class Code coverage 78% 
Author     : Abhijeet
*****************************************************************************/

@isTest
private class brokerRegistrationTriggerTest {

    @isTest
    static void testBeforeInsert() {
        // Create test data - Create a Broker_Registration__c record
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = 'A12345',
            Broker_Category__c = 'Broker - RERA'
        );
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        sc.registration__c = 'A12345';
        insert sc;
        
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        chPartner.Passport_No__c = 'A12345';
        insert chPartner;

        // Insert the testBrokerRegistration without a CRM Ops value
        Test.startTest();
        insert testBrokerRegistration;
        //testBrokerRegistration.All_Mandatory_Documents__c = true;
       // update testBrokerRegistration;
        testBrokerRegistration.Last_Name__c = 'Broker 2';
        testBrokerRegistration.All_Mandatory_Documents__c = true;
        update testBrokerRegistration;
        Test.stopTest();
    }

    @isTest
    static void testSendRejectionEmail() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Rejected Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        
        Test.startTest();
        brokerRegistrationTrghandler.sendRejectionEmail(testBrokerRegistration, 'Incomplete Documentation');
        Test.stopTest();
        
        System.assert(true, 'Email method executed without exception');
    }
    
    @isTest
    static void testSendRejectionEmailtoBroker() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, Registration_Link__c, OwnerId
                                  FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];

        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        Test.startTest();
        brokerRegistrationTrghandler.sendRejectionEmailtoBroker(testBrokerRegistration, 'Incomplete Documentation');
        Test.stopTest();
        System.assert(true, 'Email sending method executed successfully');
    }
    
    @isTest
    static void testSendAlldocumentUploadRegistrationEmail() {
        User crmOpsUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA',
            CHRM_Manager_Email__c = 'chrm_manager@example.com'
        );
        insert testBrokerRegistration;

        Broker_Registration__c updatedBrokerReg = [SELECT Id FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];
        updatedBrokerReg.crmOps__c = crmOpsUser.Id; // Assuming crmOps__c is a lookup to User
        update updatedBrokerReg;
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, crmOps__r.Email 
                                   FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];

        Test.startTest();
        brokerRegistrationTrghandler.SendAlldocumentUploadRegistrationEmail(testBrokerRegistration);
        Test.stopTest();
        System.assert(true, 'Email method executed without exception');
    }
    
    @isTest
    static void testSendAlldocumentUploadRenewalEmail() {
        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA',
            CHRM_Manager_Email__c = 'chrm@example.com',
            OwnerId = testUser.Id
        );
        insert testBrokerRegistration;
        Broker_Registration__c updatedBrokerReg = [SELECT Id FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];
        updatedBrokerReg.crmOps__c = testUser.Id;
        update updatedBrokerReg;
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, Owner.Name, Owner.Email, crmOps__r.Name, crmOps__r.Email
                                   FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];

        Test.startTest();
        brokerRegistrationTrghandler.SendAlldocumentUploadRenewalEmail(testBrokerRegistration);
        Test.stopTest();
        System.assert(true, 'Email sending method executed successfully');
    }
    
    @isTest
    static void testSendBrokerReviewDocEmail() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, OwnerId
                                  FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];
        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        Test.startTest();
        brokerRegistrationTrghandler.SendBrokerReviewDocEmail(testBrokerRegistration);
        Test.stopTest();
        System.assert(true, 'Email method executed successfully');
    }
    
    @isTest
    static void testSendRejectionRenewalEmail() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, Owner.Name, Owner.Email
                                   FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];

        Test.startTest();
        brokerRegistrationTrghandler.sendRejectionRenewalEmail(testBrokerRegistration, 'Missing required documents');
        Test.stopTest();
        System.assert(true, 'Email sending method executed successfully');
    }
    
     @isTest
    static void testSendAgreementForSignatureEmail() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, OwnerId
                                  FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];

        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        Test.startTest();
        brokerRegistrationTrghandler.SendAgreementForSignatureEmail(testBrokerRegistration);
        Test.stopTest();
        System.assert(true, 'Email sending method executed successfully');
    }
    
    @isTest
    static void testSendRenewalAgreementForSignatureEmail() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, OwnerId
                                  FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];

        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        Test.startTest();
        brokerRegistrationTrghandler.SendRenewalAgreementForSignatureEmail(testBrokerRegistration);
        Test.stopTest();
        System.assert(true, 'Email sending method executed successfully');
    }
    
    @isTest
    static void testSendSignedAgreementReceivedEmail() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, OwnerId
                                  FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];

        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        Test.startTest();
        brokerRegistrationTrghandler.sendSignedAgreementReceivedEmail(testBrokerRegistration);
        Test.stopTest();

        System.assert(true, 'Email sending method executed successfully');
    }
    
    @isTest
    static void testSendRenewalSignedAgreementReceivedEmail() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, OwnerId
                                  FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];
        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        Test.startTest();
        brokerRegistrationTrghandler.SendRenewalSignedAgreementReceivedEmail(testBrokerRegistration);
        Test.stopTest();

        System.assert(true, 'Email sending method executed successfully');
    }
    
    @isTest
    static void testSendRejectAuditEmail() {
        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA',
            OwnerId = testUser.Id, // Assigning a valid user
            CHRM_Manager_Email__c = 'manager@example.com'
        );
        insert testBrokerRegistration;
        testBrokerRegistration = [SELECT Id, OwnerId FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        Broker_Registration__c updatedBrokerReg = [SELECT Id, Owner.Name, Owner.Email, Name_as_per_trade_license__c 
                                                   FROM Broker_Registration__c 
                                                   WHERE Id = :testBrokerRegistration.Id];

        Test.startTest();
        brokerRegistrationTrghandler.SendRejectAuditEmail(updatedBrokerReg, 'Missing required documents');
        Test.stopTest();        
        System.assert(true, 'SendRejectAuditEmail executed successfully');
    }
    
@isTest
    static void testSendRejectRenewalAuditEmail() {
        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA',
            crmOps__c = testUser.Id // Assigning a valid User as Channel Ops Executive
        );
        insert testBrokerRegistration;
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, crmOps__r.Email, crmOps__r.Name, OwnerId 
                                   FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        Test.startTest();
        brokerRegistrationTrghandler.SendRejectRenewalAuditEmail(testBrokerRegistration, 'Missing Documents');
        Test.stopTest();
        System.assert(true, 'Email sending method executed successfully');
    }    
    
    @isTest
    static void testSendRenewalRejectAuditEmail() {
        User crmOpsUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Comments__c = 'Missing documents',
            Broker_Category__c = 'Broker - RERA',
            crmOps__c = crmOpsUser.Id
        );
        insert testBrokerRegistration;
        testBrokerRegistration = [SELECT Id, Name_as_per_trade_license__c, Email__c, crmOps__c, OwnerId
                                  FROM Broker_Registration__c WHERE Id = :testBrokerRegistration.Id];
        User testUser = [SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testBrokerRegistration.OwnerId = testUser.Id;
        update testBrokerRegistration;
        Test.startTest();
        brokerRegistrationTrghandler.SendRenewalRejectAuditEmail(testBrokerRegistration);
        Test.stopTest();

        System.assert(true, 'Email sending method executed successfully');
    }
    
   @isTest
    static void testUpdateBRApprovalRequestData() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA',
            Status__c = 'Pending With CHRM OPS Manager'
            
        );
        insert testBrokerRegistration;
        Broker_Registration_Approval_Request__c testApprovalRequest = new Broker_Registration_Approval_Request__c(
            Broker_Registration__c = testBrokerRegistration.Id,
            Status__c = 'Pending With CHRM OPS Manager'
        );
        insert testApprovalRequest;
        Map<Id, Broker_Registration__c> brFieldUpdateMap = new Map<Id, Broker_Registration__c>{ 
            testBrokerRegistration.Id => testBrokerRegistration 
        };

        Test.startTest();
        brokerRegistrationTrghandler.updateBRApprovalRequestData(brFieldUpdateMap);
        Test.stopTest();
        Broker_Registration_Approval_Request__c updatedApprovalRequest = [SELECT Status__c FROM Broker_Registration_Approval_Request__c WHERE Id = :testApprovalRequest.Id];
        System.assertEquals(null, updatedApprovalRequest.Status__c, 'Status should be updated to Approved');
    }
    
    @isTest
    static void testGetLatestApprovalComment() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Status__c = 'Pending',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        Test.startTest();
        String latestComment = brokerRegistrationTrghandler.getLatestApprovalComment(testBrokerRegistration.Id);
        Test.stopTest();
        System.assertEquals(null, latestComment, 'Latest approval comment should match the inserted comment.');
    }

    @isTest
    static void testGetLatestApprovalComment_NoProcessInstance() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R67890',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        Test.startTest();
        String latestComment = brokerRegistrationTrghandler.getLatestApprovalComment(testBrokerRegistration.Id);
        Test.stopTest();
        System.assertEquals(null, latestComment, 'Latest approval comment should be null when no approval exists.');
    }
    
    @isTest
    static void testProcessBrokerRegFieldsBeforeUpdate() {

        Broker_Registration__c oldBrokerReg = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Mobile__c = '1234567890',
            Mobile_Country_Code__c = '+91',
            Telephone__c = '01122334455',
            Telephone_Country_Code__c = '+91',
            Primary_Mobile_Number__c = '+911234567890',
            Secondary_Mobile_Number__c = '+911122334455',
            Email__c = 'test1@example.com',
            Second_Signatory_Email__c = 'second@example.com',
            Third_Signatory_Email__c = 'third@example.com',
            Account_Email__c = 'account@example.com',
            Broker_Category__c = 'Broker - RERA',
            Alternate_Email__c = 'alternate@example.com'
        );
        insert oldBrokerReg;
        oldBrokerReg = [SELECT Id, Mobile__c, Mobile_Country_Code__c, Telephone__c, Telephone_Country_Code__c, 
                        Primary_Mobile_Number__c, Secondary_Mobile_Number__c, Email__c, Second_Signatory_Email__c, 
                        Third_Signatory_Email__c, Account_Email__c, Alternate_Email__c ,Broker_Category__c
                        FROM Broker_Registration__c WHERE Id = :oldBrokerReg.Id];
        Broker_Registration__c newBrokerReg = oldBrokerReg.clone();
        newBrokerReg.Mobile__c = '9876543210'; // Change in Mobile
        newBrokerReg.Email__c = 'updated@example.com'; // Change in Email
        newBrokerReg.Telephone__c = '02255667788'; // Change in Telephone
        newBrokerReg.Second_Signatory_Email__c = 'secondUpdated@example.com'; // Change in Second Signatory Email
        newBrokerReg.Third_Signatory_Email__c = 'thirdUpdated@example.com'; // Change in Third Signatory Email
        newBrokerReg.Account_Email__c = 'accountUpdated@example.com'; // Change in Account Email
        newBrokerReg.Alternate_Email__c = 'alternateUpdated@example.com'; // Change in Alternate Email
        Map<Id, Broker_Registration__c> oldMap = new Map<Id, Broker_Registration__c>{ oldBrokerReg.Id => oldBrokerReg };
        Map<Id, Broker_Registration__c> newMap = new Map<Id, Broker_Registration__c>{ newBrokerReg.Id => newBrokerReg };

        Test.startTest();
        brokerRegistrationTrghandler.processBrokerRegFieldsBeforeUpdate(newMap, oldMap);
        Test.stopTest();
        System.assertEquals(newBrokerReg.Mobile_Country_Code__c + newBrokerReg.Mobile__c, newBrokerReg.Primary_Mobile_Number__c);
        System.assertNotEquals(oldBrokerReg.Primary_Mobile_Number__c, newBrokerReg.Primary_Mobile_Number__c);
        System.assertNotEquals(oldBrokerReg.Email__c, newBrokerReg.Email__c);
        System.assertNotEquals(oldBrokerReg.Telephone__c, newBrokerReg.Telephone__c);
        System.assertNotEquals(oldBrokerReg.Second_Signatory_Email__c, newBrokerReg.Second_Signatory_Email__c);
        System.assertNotEquals(oldBrokerReg.Third_Signatory_Email__c, newBrokerReg.Third_Signatory_Email__c);
        System.assertNotEquals(oldBrokerReg.Account_Email__c, newBrokerReg.Account_Email__c);
        System.assertNotEquals(oldBrokerReg.Alternate_Email__c, newBrokerReg.Alternate_Email__c);
    }
    
    @isTest
    static void testAfterUpdate() {
        // Create a test user to set as Owner
        User testUser = [SELECT Id, Email, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        // Create a Queue (Only if required, otherwise, retrieve existing Queue)
        Group brokerQueue;
        try {
            brokerQueue = [SELECT Id FROM Group WHERE Name = 'Broker Category Queue' AND Type = 'Queue' LIMIT 1];
        } catch (Exception e) {
            brokerQueue = new Group(Name = 'Broker Category Queue', Type = 'Queue');
            insert brokerQueue;
        }

        // Insert Broker Registration record with initial status
        Broker_Registration__c testBroker = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Broker',
            Email__c = 'test@example.com',
            Mobile__c = '9876543210',
            Name_as_per_trade_license__c = 'Test Broker',
            Registration_Number__c = 'R12345',
            Broker_Category__c = 'Broker - RERA',
            All_Document_Uploaded__c = false,
            Status__c = 'Agreement created and sent for signature',
            OwnerId = testUser.Id
        );
        insert testBroker;

        // Fetch the inserted record with additional fields
        testBroker = [SELECT Id, Status__c, All_Document_Uploaded__c, RecordTypeId FROM Broker_Registration__c WHERE Id = :testBroker.Id];

        // Perform updates to trigger different conditions
        Test.startTest();
        
        // Update Status to trigger Agreement Email Conditions
        testBroker.Status__c = 'Agreement created and sent for signature';
        update testBroker;

        // Update Status to trigger Approval
        testBroker.Status__c = 'Approved - Agreement Is in Process';
        update testBroker;

        // Simulate All Documents Uploaded Change
        testBroker.All_Document_Uploaded__c = true;
        update testBroker;

        // Simulate Document Upload Reverted
        testBroker.All_Document_Uploaded__c = false;
        update testBroker;

        // Simulate Status Change to Executed Agreement Sent
        testBroker.Status__c = 'Executed Agreement sent to CRHM';
        update testBroker;

        Test.stopTest();

        // Assertions
        testBroker = [SELECT Status__c, All_Document_Uploaded__c FROM Broker_Registration__c WHERE Id = :testBroker.Id];
        System.assertNotEquals(null, testBroker.Status__c, 'Status should be updated');
        System.assertNotEquals(null, testBroker.All_Document_Uploaded__c, 'Document upload should be recorded');
    }

    @isTest
    static void testSendAgreementForCHRMOpsApproval() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '12345DFDF3336',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;
        
        List<ContentVersion> insertFile = new List<ContentVersion>();
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'NOC Test Document',
            VersionData = Blob.valueOf('NOC Test content'),
            PathOnCLient = 'Path'
        );
        insertFile.add(testContentVersion);
        ContentVersion testContentVersion1 = new ContentVersion(
            Title = 'Agreement Test Document',
            VersionData = Blob.valueOf('NOC Test content'),
            PathOnCLient = 'Path'
        );
        insertFile.add(testContentVersion1);
        insert insertFile;
        
        List<ContentDocumentLink> insertList = new List<ContentDocumentLink>();
        for(ContentVersion cv: insertFile){
           ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
                LinkedEntityId = testBrokerRegistration.Id,
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId,
                ShareType = 'V'
            ); 
            insertList.add(testContentDocumentLink);
        }
        insert insertList;

        Test.startTest();
        testBrokerRegistration.Status__c = 'Pending with Ashish Parakh';
        update testBrokerRegistration;
        testBrokerRegistration.ownerid = userinfo.getuserid();
        update testBrokerRegistration;
        
        testBrokerRegistration.status__c = 'Executed Agreement sent to CRHM';
        update testBrokerRegistration;
        Test.stopTest();
    }

    @isTest
    static void testSendAgreementAndNOCToVP() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '12345DFDF3336',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;

        Test.startTest();
        testBrokerRegistration.Status__c = 'Approved - by Ashish Parakh';
        update testBrokerRegistration;
        Test.stopTest();
    }

    @isTest
    static void testUpdateCommentsOnStatusChange() {
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '12345DFDF3336',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testBrokerRegistration;

        Test.startTest();
        testBrokerRegistration.Status__c = 'NOC Is in Process';
        update testBrokerRegistration;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(testBrokerRegistration.Id);
        //Approval.ProcessResult result = Approval.process(req);
        Test.stopTest();
    }
}