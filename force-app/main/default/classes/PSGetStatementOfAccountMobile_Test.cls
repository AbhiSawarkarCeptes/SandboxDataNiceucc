@isTest
public class PSGetStatementOfAccountMobile_Test{
    @isTest
    static void testMobileToSFDC(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/services/apexrest/getStatementOfAccount';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"dummyKey": "dummyValue"}');
         Test.startTest();
        PSGetStatementOfAccountMobile.MobileToSFDC();
        Test.stopTest();
    }
}