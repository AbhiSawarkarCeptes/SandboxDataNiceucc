@isTest
global class LeadDownloadReportAPIMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                         ' "success": true, '+
                         ' "statusCode": 200, '+
                         ' "message": "Details captured successfully."'+
                         '}');
        response.setStatusCode(200);
        return response; 
    }
}