@isTest
private class MockHttpResponseGeneratorTest {

    @isTest
    static void testMockHttpResponseGenerator() {
        // Set up the mock response generator
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();

        // Set the mock for HttpCalloutMock
        Test.setMock(HttpCalloutMock.class, mock);

        // Create a new HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://example.com');
        request.setMethod('GET');

        // Send the request and receive the response
        Http http = new Http();
        HttpResponse response = http.send(request);

        // Verify that the status code and body are as expected
        System.assertEquals(200, response.getStatusCode(), 'Status code should be 200');
        System.assertEquals('{"key":"value"}', response.getBody(), 'Response body should match');
    }
}