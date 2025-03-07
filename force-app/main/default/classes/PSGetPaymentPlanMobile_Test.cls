@isTest
public class PSGetPaymentPlanMobile_Test {
    @isTest
    static void PSGetPaymentPlanMobileTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/services/apexrest/getPaymentPlan/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"dummyKey": "dummyValue"}');
         Test.startTest();
        PSGetPaymentPlanMobile.MobileToSFDC();
        Test.stopTest();
    }
}