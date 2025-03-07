@isTest
public class PSGetDocumentMobile_Test {
    @IsTest
    static void testGetDocumentSuccess() {
        // Setup test data
        //ContentDocument contentDoc = new ContentDocument(
            //Title = 'Test Document',
            //FileType = 'txt'
        //);
        //insert contentDoc;
        /*
        ContentDocument contentDoc = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        ContentVersion contentVer = new ContentVersion(
            ContentDocumentId = contentDoc.Id,
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test data')
        );
        insert contentVer;
*/
        ContentVersion contentVer = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test Document.txt',
            VersionData = Blob.valueOf('Test data'),
            IsMajorVersion = true
        );
        insert contentVer;
        
        String contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVer.Id].ContentDocumentId;
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"documentId" : "' + contentDocId + '"}');
        RestContext.request = req;
        RestContext.response = res;
        
        PSGetDocumentMobile.getDocument(contentDocId);
        
        Test.stopTest();
        
        // Verify response
        String responseBody = res.responseBody.toString();
        PSGetDocumentMobile.HttpResponseWrapper responseWrapper = 
            (PSGetDocumentMobile.HttpResponseWrapper) JSON.deserialize(responseBody, PSGetDocumentMobile.HttpResponseWrapper.class);
        
        
    }
    
    @IsTest
    static void testGetDocumentNoDataFound() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"documentId" : "nonexistent"}');
        RestContext.request = req;
        RestContext.response = res;
        
        PSGetDocumentMobile.getDocument('nonexistent');
        
        Test.stopTest();
        
        // Verify response
        String responseBody = res.responseBody.toString();
        PSGetDocumentMobile.HttpResponseWrapper responseWrapper = 
            (PSGetDocumentMobile.HttpResponseWrapper) JSON.deserialize(responseBody, PSGetDocumentMobile.HttpResponseWrapper.class);
        
        
    }    
    
}