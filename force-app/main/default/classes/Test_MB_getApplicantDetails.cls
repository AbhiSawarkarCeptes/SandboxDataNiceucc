@isTest
public class Test_MB_getApplicantDetails {
	
    @testSetup
    static void setupTestData() {
        Mobile_TestUtil.createBooking();
        List<Booking__c> bookList = [Select Id from Booking__c];
        Applicant_Details__c appd = Mobile_TestUtil.createApplicantDetails(bookList[0].Id);
    }
    
    @isTest
    static void testMethod1(){
        String jsonBody ='';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/getApplicantDetails'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res; 
        
        List<Booking__c> bookList = [Select Id from Booking__c];
        
        Test.startTest();
        	Mobile_getApplicantDetails.getApplicantDetails(bookList[0].id);
       	Test.stopTest();
        
    }
    
}