@isTest
global class TeleSalesAgentExtensionSearchMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                         ' "success": true, '+
                         ' "statusCode": 200, '+
                         ' "message": "EXTENSION RETRIVED SUCCESSFULLY", '+
                         ' "extension": "2018" '+
                         '}');
        response.setStatusCode(200);
        return response; 
    }
}