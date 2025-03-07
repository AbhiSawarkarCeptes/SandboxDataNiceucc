/*******************************************
Class : Nice_CampaignHeaderAPI
covers : 92%
Author : Artee Varma
********************************************/
@isTest
private class Nice_CampaignHeaderAPITest {
    
    private class MockHttpSuccessResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"access_token":"testAccessToken123"}');
            return response;
        }
    }
    
        private class MockHttpNoResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody('{"access_token":"testAccessToken123"}');
            return response;
        }
    }

    @isTest
    static void testMakePostCallout_SuccessfulResponse() {
        // Set the mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccessResponseGenerator());
        
        Test.startTest();
        // Your List<String> to be passed as jsonParams
        List<String> headerFields = new List<String>{'ID','Booking','UnitName','AccountName','Owner','CustomerName','Overdue','PaidPercentage','UserId','NiceAgentId','PhoneNum'};
            
        // Convert the List to a JSON string
        String jsonParams = '{"headerFields":' + JSON.serialize(headerFields) + '}';
        
        String mockAccessToken = 'testAccessToken123'; // Mocked token for testing
        Nice_CampaignHeaderAPI.ApiResponseWrapper responseWrapper = Nice_CampaignHeaderAPI.makePostCallout(jsonParams);
        Test.stopTest();
        
        System.assertEquals(200, responseWrapper.status_code, 'Expected status code 200');
        System.assertEquals('{"access_token":"testAccessToken123"}', responseWrapper.calling_api_response, 'Expected response body');
        System.assertEquals('testAccessToken123', responseWrapper.access_Token, 'Access token should match mock value');
    }
    
    @isTest
    static void testMakePostCallout_FailureResponse() {
        // Set the mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpNoResponseGenerator());
        
        Test.startTest();
        // Your List<String> to be passed as jsonParams
        List<String> headerFields = new List<String>{'ID','Booking','UnitName','AccountName','Owner','CustomerName','Overdue','PaidPercentage','UserId','NiceAgentId'};
            
        // Convert the List to a JSON string
        String jsonParams = '{"headerFields":' + JSON.serialize(headerFields) + '}';
        
        String mockAccessToken = 'testAccessToken123'; // Mocked token for testing
        Nice_CampaignHeaderAPI.ApiResponseWrapper responseWrapper = Nice_CampaignHeaderAPI.makePostCallout(jsonParams);
        Test.stopTest();
        
        System.assertEquals(400, responseWrapper.status_code, 'Expected status code 400');
        System.assertEquals('{"access_token":"testAccessToken123"}', responseWrapper.calling_api_response, 'Expected response body');
        //System.assertEquals('testAccessToken123', responseWrapper.access_Token, 'Access token should match mock value');
    }
}