@isTest
global with sharing class EzetapStartCalloutMock implements HTTPCalloutMock {
	global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        res.setBody('{"success":true,"messageCode":null,"message":null,"errorCode":null,"errorMessage":null,"realCode":null,"apiMessageTitle":null,"apiMessage":null,"apiMessageText":null,"apiWarning":null,"p2pRequestId":"230103090Test"}');
        res.setStatusCode(200);
        return res;
    }
}