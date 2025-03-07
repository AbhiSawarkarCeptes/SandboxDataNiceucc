@isTest
public class CreateBRDocumentHistoryBatchTest {
    
    @isTest
    static void testCreateBRDocumentHistoryBatch() {
        // Step 1: Create test data for Broker_Registration__c and BR_Document_Mapping__c objects
        
        // Create a Broker_Registration__c record
        Broker_Registration__c brokerReg = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Status__c = 'Pending with CHRM OPS'
        );
        insert brokerReg;
        brokerReg = [select Id,Name from Broker_Registration__c where Id =: brokerReg.Id];
        
        // Create BR_Document_Mapping__c records
        BR_Document_Mapping__c docMapping1 = new BR_Document_Mapping__c(
            Name = brokerReg.Name,
            Document_Type__c = 'TypeA',
            Expiry_Date__c = Date.today().addMonths(6),
            File_Title__c = 'DocumentA1'
        );
        BR_Document_Mapping__c docMapping2 = new BR_Document_Mapping__c(
            Name =  brokerReg.Name,
            Document_Type__c = 'TypeB',
            Expiry_Date__c = Date.today().addMonths(12),
            File_Title__c = 'DocumentB1'
        );
        insert new List<BR_Document_Mapping__c>{docMapping1, docMapping2};
        
        // Create ContentDocument and ContentDocumentLink records for the documents
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'DocumentA1.pdf',
            PathOnClient = 'DocumentA1.pdf',
            VersionData = Blob.valueOf('DocumentA1 content')
        );
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'DocumentB1.pdf',
            PathOnClient = 'DocumentB1.pdf',
            VersionData = Blob.valueOf('DocumentB1 content')
        );
        insert new List<ContentVersion>{contentVersion1, contentVersion2};
        
        // Fetch the ContentDocumentId for the ContentVersions created
        ContentDocument doc1 = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'DocumentA1.pdf') LIMIT 1];
        ContentDocument doc2 = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'DocumentB1.pdf') LIMIT 1];
        
        ContentDocumentLink link1 = new ContentDocumentLink(
            ContentDocumentId = doc1.Id,
            LinkedEntityId = brokerReg.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        ContentDocumentLink link2 = new ContentDocumentLink(
            ContentDocumentId = doc2.Id,
            LinkedEntityId = brokerReg.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert new List<ContentDocumentLink>{link1, link2};
        
        // Step 2: Instantiate the batch class
        Test.startTest();
        CreateBRDocumentHistoryBatch batch = new CreateBRDocumentHistoryBatch();
        Database.executeBatch(batch, 1); // Execute the batch with a batch size of 1
        Test.stopTest();
    }
}