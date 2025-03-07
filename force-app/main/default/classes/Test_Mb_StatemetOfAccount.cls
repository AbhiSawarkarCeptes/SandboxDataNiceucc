@isTest
public class Test_Mb_StatemetOfAccount {
    
	@testSetup
    static void setupTestData() {
        Mobile_TestUtil.createBooking();
    }
    
     @isTest
    static void testGetBookingListWithRecords() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/getStatementOfAccount';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<booking__c> book = [select id, name from booking__c];
        
        Demand__c dm = new Demand__c();
        dm.Debit_Type__c = 'DP Charges';
        dm.Booking__c = book[0].id;
        
        insert dm;
        
        Receipt__c rc = new Receipt__c();
        rc.Receipt_Status__c = 'Cleared';
        rc.Mode__c = 'Debit Note';
        rc.Booking__c = book[0].id;
        insert rc;
        
        Test.startTest();
        Mobile_getStatementOfAccount.getStatementOfAccount(book[0].Id);
        Test.stopTest();
        
      //  System.assertEquals(200, response.statusCode);
        
    }
    
}