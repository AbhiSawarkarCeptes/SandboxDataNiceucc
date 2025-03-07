global with sharing class ProcessMock implements HTTPCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        String json = '[{\"mid\":\"100\",\"number\":\"042924333\",\"mtime\":\"1557313211\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"},{\"mid\":\"101\",\"number\":\"043555582\",\"mtime\":\"1557641699\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"1\"},{\"mid\":\"102\",\"number\":\"0564017612\",\"mtime\":\"1558000832\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"}]';
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}