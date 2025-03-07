@isTest
public class PSGetPaymentReceiptsMobile_Test {
    @isTest
    static void PSGetPaymentReceiptsMobileTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/services/apexrest/getPaymentReceipts/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"dummyKey": "dummyValue"}');
         Test.startTest();
        PSGetPaymentReceiptsMobile.MobileToSFDC();
        Test.stopTest();
    }
}