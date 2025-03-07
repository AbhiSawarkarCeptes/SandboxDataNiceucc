@isTest
public class Test_MB_MockupClass implements HttpCalloutMock {
	public String responseBody;
    public Integer responseCode;
    public String responseStatus;
    public Test_MB_MockupClass(String resBody, Integer resCode, String resStatus){
        responseBody = resBody;
        responseCode = resCode;
        responseStatus = resStatus;
    }
	
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBody);
        response.setStatus(responseStatus);
        response.setStatusCode(responseCode);
        return response; 
    }
    
    public class responseBodyWrapper{
        public string result;
    }
}