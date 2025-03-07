@isTest
public class PSGetCreateLeadMobile_Test {
    @isTest
    static void MobileToSFDCTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/services/apexrest/registeruser';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"dummyKey": "dummyValue"}');
         Test.startTest();
        PSGetCreateLeadMobile.MobileToSFDC();
        Test.stopTest();
    }
}