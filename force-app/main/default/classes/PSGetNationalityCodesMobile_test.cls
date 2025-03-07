@isTest
public class PSGetNationalityCodesMobile_test {    
    @isTest
    public static void testGetItems(){ 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/services/apexrest/getMobileNationalityCodes';
        req.httpMethod = 'GET';
        PSGetNationalityCodesMobile.getItems();
    }
    @isTest
    public static void testGetItems1(){ 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/services/apexrest/getMobileNationalityCodes';
        req.httpMethod = 'POST';
        PSGetNationalityCodesMobile.getItems();
    }
}