@isTest
public class Test_mb_uploadDocument {
    
    @testSetup
    static void setupTestData() {
        Mobile_TestUtil.createBooking();
    }

     @isTest
    static void testuploadDocument() {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/uploadDocument';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<Booking__c> book = [select id, name from booking__c];
        
        String base64Data = '8989nnklklj';
        String parentId = book[0].Id;
        String fileName = 'Test.pdf';
        boolean isthirdpartydoc = true;
        TEst.startTest();
        Mobile_uploadDocument.uploadDocument(base64Data,parentId,fileName,isthirdpartydoc);
        Test.stopTest();
        
        System.assertEquals(200, response.statusCode);
         
    }
    
    @isTest
    static void testuploadDocument2() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/uploadDocument';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<Booking__c> book = [select id, name from booking__c];
        
        String base64Data = '8989nnklklj';
        String parentId = book[0].Id;
        String fileName = 'Test.pdf';
        boolean isthirdpartydoc = false;
        TEst.startTest();
        Mobile_uploadDocument.uploadDocument(base64Data,parentId,fileName,isthirdpartydoc);
        Test.stopTest();
        
        System.assertEquals(200, response.statusCode);
    }
    
    @isTest
    static void testuploadDocument3() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/uploadDocument';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<Booking__c> book = [select id, name from booking__c];
        
        String base64Data = 'pdf8989nnklklj';
        String parentId = book[0].Id;
        String fileName = 'Test.pdf';
        boolean isthirdpartydoc = false;
        TEst.startTest();
        Mobile_uploadDocument.uploadDocument(base64Data,parentId,fileName,isthirdpartydoc);
        Test.stopTest();
        
        System.assertEquals(200, response.statusCode);
    }
}