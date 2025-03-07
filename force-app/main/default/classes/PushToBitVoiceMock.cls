global with sharing class PushToBitVoiceMock implements HTTPCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        MockWrapper w = new MockWrapper();
        w.status='success';
        w.message='msg';
        res.setBody(JSON.serialize(w));
        res.setStatusCode(200);
        return res;
    }
    Class MockWrapper {
        String status;
        String message;
    }
}