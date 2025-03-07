global with sharing class FetchCdrMock implements HTTPCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        String json = '['+
        '    {'+
        '        \"calldate\": \"2019-04-24 19:24:47\",'+
        '        \"src\": \"101\",'+
        '        \"dst\": \"0545549067\",'+
        '        \"duration\": \"15\",'+
        '        \"uniqueid\": \"1556119481.14\",'+
        '        \"recordingfile\": \"20190424-192447-101.wav\",'+
        '        \"xdispo\": \"CANCEL\",'+
        '        \"recordingurl\": \"http://10.150.5.230/recordings/2019/04/24/20190424-192447-101.wav\"'+
        '    }'+
        ']';
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}