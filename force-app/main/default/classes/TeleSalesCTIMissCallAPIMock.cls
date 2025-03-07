@isTest
global class TeleSalesCTIMissCallAPIMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                         ' "success": true, '+
                         ' "statusCode": 200, '+
                         ' "message": "Missed call task created successfully."'+
                         '}');
        response.setStatusCode(200);
        return response; 
    }
}