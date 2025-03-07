@isTest
global class CallOzonetelSchedulerMockImp implements HttpCalloutMock{
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","message":[{"Response":"success","ScheduleTime":"2020-07-20 11:37:00","campaign_name":"StetigTesting_918046387485_1","PhoneNumber":"7776960529","Name":null,"AgentID":"TestAgent","skill":null,"msg":"Data updated successfully","index":0}]}');
        response.setStatusCode(200);
        return response; 
    }
}