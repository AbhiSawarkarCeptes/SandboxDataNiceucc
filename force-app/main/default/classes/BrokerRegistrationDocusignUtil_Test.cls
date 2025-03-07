@isTest
public class BrokerRegistrationDocusignUtil_Test {
    @testSetup
    static void setupTestData() {
        // Create test data that will be used in all test methods
        Account acc = new Account(Name='Test Account', CHRM_s_Email__c='test@example.com', Mobile_No__c='+1234567890',list_of_missing_documents__c='Document1, Document2');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
                
        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'Agreement -',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = documents[0].Id;
            cdl.LinkedEntityId = acc.Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        
        dfsle__EnvelopeStatus__c envStatus = new dfsle__EnvelopeStatus__c(dfsle__DocuSignId__c='12345', Broker_Account__c=acc.Id);
        insert envStatus;
        
        dfsle__RecipientStatus__c recStatus = new dfsle__RecipientStatus__c(dfsle__EnvelopeStatus__c=envStatus.Id, dfsle__Email__c='recipient@example.com', dfsle__RoutingOrder__c=1);
        insert recStatus;
    }
    
    @isTest
    static void testGetAccount() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        Account result = BrokerRegistrationDocusignUtil.getAccount(testAcc.Id);
        
       
    }

    @isTest
    static void testGetFileId() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        Id fileId = BrokerRegistrationDocusignUtil.getFileId(testAcc.Id);
    }

    @isTest
    static void testDocusignPostProcessing() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        dfsle__EnvelopeStatus__c envStatus = [SELECT Id, dfsle__DocuSignId__c FROM dfsle__EnvelopeStatus__c LIMIT 1];
        Id myDocumentId = [SELECT ContentDocumentId , LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: testAcc.Id LIMIT 1].ContentDocumentId;
        
        Map<String, String> emailToRoleMap = new Map<String, String>{'recipient@example.com_1' => 'Buyer'};
        BrokerRegistrationDocusignUtil.docusignPostProcessing(envStatus.dfsle__DocuSignId__c, testAcc.Id, myDocumentId, emailToRoleMap);        
    }

    @isTest
    static void testGetDocusignRecipientStatusSobha() {
        dfsle__EnvelopeStatus__c envStatus = [SELECT Id FROM dfsle__EnvelopeStatus__c LIMIT 1];
        List<Docusign_Recipient_Status_Sobha__c> result = BrokerRegistrationDocusignUtil.getDocusignRecipientStatusSobha(envStatus.Id);        
    }

    @isTest
    static void testCreateDocusignRecipientStatusSobhaRecords() {
        dfsle__RecipientStatus__c recStatus = [SELECT Id,Name,dfsle__Email__c,Envelope_Recipient_Type__c, dfsle__EnvelopeStatus__c,dfsle__Reason__c,dfsle__Type__c,dfsle__Completed__c,Application_Booking__c,dfsle__Status__c,dfsle__Sequence__c,dfsle__Sent__c,dfsle__SourceId__c,Envelope_Type__c,Last_Applicant__c,dfsle__LastStatusUpdate__c,dfsle__RoutingOrder__c FROM dfsle__RecipientStatus__c LIMIT 1];
        List<dfsle__RecipientStatus__c> recStatusList = new List<dfsle__RecipientStatus__c>{recStatus};
        
        Test.startTest();
        BrokerRegistrationDocusignUtil.createDocusignRecipientStatusSobhaRecords(recStatusList);
        Test.stopTest();
        
    }

    @isTest
    static void testDocusignEmailBody() {
        Account testAcc = [SELECT Id, Owner.email,owner.name,Name, list_of_missing_documents__c FROM Account LIMIT 1];
        String emailBody = BrokerRegistrationDocusignUtil.docusignEmailBody(testAcc);        
    }

    @isTest
    static void testValidateAndUpdatePhoneNumber() {
        String phoneNumber = '1234567890';
        String validatedNumber = BrokerRegistrationDocusignUtil.validateAndUpdatePhoneNumber(phoneNumber); 
        String SalesOperationBody = BrokerRegistrationDocusignUtil.getSalesOperationBody('booking 1' , 'unit 1');
        String smsbody = BrokerRegistrationDocusignUtil.getSMSDBody('booking 1' , 'unit 1');
        String AuditBody = BrokerRegistrationDocusignUtil.getAuditBody('booking 1' , 'unit 1');
        String CHRMOpsBody = BrokerRegistrationDocusignUtil.getCHRMOpsBody('booking1');

    }
}