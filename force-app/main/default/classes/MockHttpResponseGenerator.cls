@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    private Integer statusCode;
    
    global MockHttpResponseGenerator() {
        this.statusCode = 200; // Default to success
    }
    
    global MockHttpResponseGenerator(Integer statusCode) {
        this.statusCode = statusCode;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if (statusCode == 200) {
            res.setBody('{"success":true,"data":["TEST123"]}');
        } else if (statusCode == 500) {
            res.setBody('{"success":false,"message":"Error occurred while processing request"}');
        }
        
        res.setStatusCode(statusCode);
        return res;
    }
}
