@isTest
public class InventoryControllerMock_Test implements HttpCalloutMock {
    // Implement this method to simulate the HTTP response
    public HTTPResponse respond(HTTPRequest req) {
        // Create a new HTTPResponse object
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Define the response body that simulates the API response
        String responseBody = '{"features":[{"properties":{"state":"MockState","city":"MockCity"}}]}';
        res.setBody(responseBody);
        
        // Set the status code to 200 (OK)
        res.setStatusCode(200);
        
        return res;
    }
}