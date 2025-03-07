@isTest
global class CTIMissCallAPIMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                            ' "success": true, '+
                            ' "statusCode": 200, '+
                            ' "message": "Task created successfully"'+
                        '}');
        response.setStatusCode(200);
        return response; 
    }
}