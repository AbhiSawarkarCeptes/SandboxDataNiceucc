@isTest
public class Test_Mb_paymentReceipts {

    @testSetup
    static void setupTestData() {
        Mobile_TestUtil.createBooking();
    }
    
    @isTest
    static void testGetBookingListWithRecords() {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/getPaymentReceipts';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<booking__c> book = [select id, name from booking__c];
        
        Receipt__c rec = new Receipt__c();
        rec.Receipt_Status__c = 'Cleared';
        rec.Mode__c = 'Cheque';
        rec.Total_Amount__c =5000.00;
        rec.Booking__c = book[0].Id;
        
        insert rec;
        
        Test.startTest();
        Mobile_PaymentReceipts.getPaymentReceipts(book[0].Id);
        Test.stopTest();
        
        System.assertEquals(200, response.statusCode);
        
    }
    
    @isTest
    static void testGetBookingListWithRecords2() {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/getPaymentReceipts';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<booking__c> book = [select id, name from booking__c];
        
        Payment_Request__c pr = new Payment_Request__c();
        pr.Booking__c = book[0].Id;
        pr.Receipt_Created__c = false;
        pr.Mode__c = 'Website';
        pr.Mode_Option__c = 'Single Mode';
        pr.Amount__c = 450000;
        pr.Status__c = 'Approved by Accounts';
        pr.Mobile_Number__c = '98765';
        insert pr;
        
      /*  Receipt__c rec = new Receipt__c();
        rec.Receipt_Status__c = 'UnProcessed';
        rec.Mode__c = 'Cheque';
        rec.Total_Amount__c =5000.00;
        rec.Booking__c = book[0].Id;
        
        insert rec; */
        
        Test.startTest();
        Mobile_PaymentReceipts.getPaymentReceipts(book[0].Id);
        Test.stopTest();
        
        System.assertEquals(200, response.statusCode);
        
    }
}