@isTest
public with sharing class Mobile_getCountryListTest {
    @IsTest
    static void methodName(){
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/getCountryList';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        Mobile_getCountryList.getItems();
        Test.stopTest();
        // Assert the response status code and any other expected results
        System.assertEquals(200, response.statusCode);
        
        
    }
}