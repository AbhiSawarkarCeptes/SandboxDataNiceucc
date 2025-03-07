global with sharing class CallByIdMock implements HTTPCalloutMock {
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        CallByIdResponseWrapper w = new CallByIdResponseWrapper();
        w.sucess=true;
        w.message='msg';
        w.uid='xxxxxxxxxxxxx';
        res.setBody(JSON.serialize(w));
        res.setStatusCode(200);
        return res;
    }
    Class CallByIdResponseWrapper {
        Boolean sucess;
        String uid;
        String message;
    }
}