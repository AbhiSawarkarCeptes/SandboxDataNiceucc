@isTest
public class Mobile_getMobileNationalityCodes_Test {
	@isTest static void testMethod1() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/getMobileNationalityCodes';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        Mobile_getMobileNationalityCodes.getItems();
        Test.stopTest();
        // Assert the response status code and any other expected results
        System.assertEquals(200, response.statusCode);
        
    }
}