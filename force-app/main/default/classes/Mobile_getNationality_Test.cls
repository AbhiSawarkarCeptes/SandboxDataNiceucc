@isTest
public class Mobile_getNationality_Test {

    @isTest static void testMethod1() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/getNationalities';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Mobile_getNationality.getItems();
    }
}