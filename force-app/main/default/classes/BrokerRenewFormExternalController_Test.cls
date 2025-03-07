@isTest
public class BrokerRenewFormExternalController_Test {
    @testsetup
    public static void createData() {
        Broker_Renewal__c testRecord = TestDataFactorySobha.createBrokerRenewal(null);
        insert testRecord; 
    }
    @isTest
    static void testGetRecord() {
        Id recId = [SELECT Id FROM Broker_Renewal__c LIMIT 1].Id;
        Test.startTest();
        Map<String, Object> response = BrokerRenewFormExternalController.getRecord(recId);
        try{
                    Map<String, Object> response2 = BrokerRenewFormExternalController.getRecord(null);

       		}catch(Exception e){
        }
        Test.stopTest();
   	}
    @isTest
    static void testUpdate() {
        Broker_Renewal__c rec = [SELECT Id FROM Broker_Renewal__c LIMIT 1]; 
        Test.startTest();
       	Broker_Renewal__c result = BrokerRenewFormExternalController.updateRecord(rec);
        try{
                    Map<String, Object> response2 = BrokerRenewFormExternalController.getRecord(result.Id);

       		}catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    static void createGetDeleteDocumnet() {
        Id recId = [SELECT Id FROM Broker_Renewal__c LIMIT 1].Id;
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
        cdl.LinkedEntityId = recId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        Test.startTest();
        try{
       		String docId = BrokerRenewFormExternalController.createAttachment('Test', 'TestFile', 'Test Datat',recId);
            Id documentId = BrokerRenewFormExternalController.getDocID(String.valueOf(recId), 'TestFile');
            String deleteMssg = BrokerRenewFormExternalController.deleteDocuments(new List<String>{String.valueOf(documentId)});
            String doc2Id = BrokerRenewFormExternalController.createAttachment('', 'TestFile', 'Test Datat',recId);
        }catch(Exception e){
        }
        Test.stopTest();
    }
    
    @isTest
    static void createGetDeleteDocument() {
        Id recId = [SELECT Id FROM Broker_Renewal__c LIMIT 1].Id;
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
        cdl.LinkedEntityId = recId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        Test.startTest();
        try{
            BR_Document_History__c brd= new BR_Document_History__c();
            brd.Expiry_date__c=Date.Today().addDays(-2);
            brd.File_Name__c='TestFile.pdf';
            brd.File_Type__c='Test';
            brd.Broker_Renewal__c = recId;
            insert brd;
            String docId2 = BrokerRenewFormExternalController.createAttachment('Test', 'TestFile', 'Test Datat',recId);
            Id documentId2 = BrokerRenewFormExternalController.getDocID(String.valueOf(recId), 'TestFile');
            String deleteMssg2 = BrokerRenewFormExternalController.deleteDocuments(new List<String>{String.valueOf(documentId2)});
            String doc2Id2 = BrokerRenewFormExternalController.createAttachment('', 'TestFile', 'Test Datat',recId);
        }catch(Exception e){
        }
        Test.stopTest();
    }
}