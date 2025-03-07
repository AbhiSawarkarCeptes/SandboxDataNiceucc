@isTest
public class PSGetNationalityMobile_Test {
    @isTest
    static void getItemstest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/services/apexrest/getNationalities';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"dummyKey": "dummyValue"}');
         Test.startTest();
        PSGetNationalityMobile.getItems();
        Test.stopTest();
    }
}