@isTest
public class BrokerRegistrationFormExternalCtrlTest {

    @isTest
    static void testGetRecord() {
        // Create test data
        Broker_Registration__c testRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testRecord;

        // Test getRecord method
        Test.startTest();
        Map<String, Object> response = BrokerRegistrationFormExternalController.getRecord(testRecord.Id);
        Test.stopTest();

        System.assertEquals(testRecord.Id, ((Broker_Registration__c)response.get('record')).Id, 'Returned record should match test record');
        // Add more assertions if needed
    }

    @isTest
    static void testUpdateRecord() {
        // Create test data
        Broker_Registration__c testRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testRecord;

        // Test updateRecord method
        Test.startTest();
        try {
            Broker_Registration__c result = BrokerRegistrationFormExternalController.updateRecord(testRecord);
        } catch (Exception e) {
        }
        Test.stopTest();

        // Add more assertions if needed
    }

   @isTest
    static void testSendEmailToCHRM() {
        // Create test data
        Broker_Registration__c testRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            CHRM_Manager_Email__c = 'chrm@example.com'
        );
        insert testRecord;

        // Test sendEmailToCHRM method
        Test.startTest();
        BrokerRegistrationFormExternalController.sendEmailToCHRM(testRecord.Id);
        Test.stopTest();

        // Add assertions to verify the email sending, such as checking the sent emails or the log records
        // Add assertions to verify the deletion of dummyContact
    }

    @isTest
    static void testDeleteDocuments() {
        // Create test data
        Broker_Registration__c testRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            CHRM_Manager_Email__c = 'chrm@example.com'
        );
        insert testRecord;

        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test content'),
            PathOnCLient = 'Path'
        );
        insert testContentVersion;

        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = testRecord.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert testContentDocumentLink;

        // Test deleteDocuments method
        Test.startTest();
        List<Id> docIds = new List<Id>{ [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id].ContentDocumentId };
        BrokerRegistrationFormExternalController.deleteDocuments(docIds);
        Test.stopTest();

        // Add assertions to verify that the document was deleted, such as querying ContentDocument and ContentVersion
    }

    @isTest
    static void testGetDocID() {
        // Create test data
        Broker_Registration__c testRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testRecord;

        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test content'),
            PathOnCLient = 'Path'
        );
        insert testContentVersion;

        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = testRecord.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert testContentDocumentLink;

        // Test getDocID method
        Test.startTest();
        String docId = BrokerRegistrationFormExternalController.getDocID(testRecord.Id,'','');
        BrokerRegistrationFormExternalController.DocumentWrapper doc = new BrokerRegistrationFormExternalController.DocumentWrapper();
        doc.versionId = testContentVersion.Id;
        doc.filelabel = 'RERA Certificate';
        doc.fileName = 'test';
        list<BrokerRegistrationFormExternalController.DocumentWrapper> docList = new list<BrokerRegistrationFormExternalController.DocumentWrapper>{doc};
        BrokerRegistrationFormExternalController.createBRDocumentHistory(testRecord.Id, JSON.serialize(docList));
        Test.stopTest();
    }

    @isTest
    static void testPicklistValues() {
        // Define test data
        String objectName = 'Broker_Registration__c';
        String fieldName = 'Status__c';

        // Test picklistValues method
        Test.startTest();
        List<Map<String, String>> picklistOptions = BrokerRegistrationFormExternalController.picklistValues(objectName, fieldName);
        Test.stopTest();

        // Verify the picklist options
        System.assertNotEquals(0, picklistOptions.size(), 'Picklist options should not be empty');

        // Add more assertions as needed to verify the content of picklistOptions
    }
    
    @isTest
    static void testValidation() {
       
        // Create test data
        Broker_Registration__c testRecord = new Broker_Registration__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Broker',
            Email__c = 'test@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA'
        );
        insert testRecord;
        
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
        
        Test.StartTest();
        BrokerRegistrationFormExternalController.validateRegistrationNo('A12345','Broker',testRecord.Broker_Category__c,testRecord.recordTypeId);
        BrokerRegistrationFormExternalController.validateRegistrationNo('A12345','SC',testRecord.Broker_Category__c,testRecord.recordTypeId);
        Test.StopTest();
        
    }
}