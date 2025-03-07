@isTest
global class CallOzonetelMockImp implements HttpCalloutMock{
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"SUCCESS","message":"SuccessFully Updated, Progressive was started"}');
        response.setStatusCode(200);
        return response; 
    }
}