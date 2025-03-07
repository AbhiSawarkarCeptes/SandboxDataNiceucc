@IsTest
public class IncomingCalls_Test{
    
    static testMethod void testPositiveCases() {
    Test.startTest();
    IncomingCalls.ResponseWrapper rw = new IncomingCalls.ResponseWrapper();
    String json = '['+
        '   {'+
        '       \"starttime\":\"2019-02-13 12:52:46\",'+
        '       \"extension\":\"4444\",'+
        '       \"from\":\"9447111230\",'+
        '       \"DID\":\"231\",'+
        '       \"agent\":\"anil\",'+
        '       \"callType\":\"Incoming\"'+
        '   }'+
    ']';
    List<IncomingCallsParser> r = IncomingCallsParser.parse(json);
       
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    req.requestURI = '/services/apexrest/incomingCalls';  //Request URL
    req.httpMethod = 'POST';//HTTP Request Type
    req.requestBody = Blob.valueof(json);
    RestContext.request = req;
    RestContext.response= res;
    
    IncomingCalls ic = new IncomingCalls();
    IncomingCalls.ResponseWrapper rw1 = IncomingCalls.pushIncoming();
    
    Test.stopTest();
   }
    static testMethod void testPositiveCases1() {
    Test.startTest();
    IncomingCalls.ResponseWrapper rw = new IncomingCalls.ResponseWrapper();
    String json = '['+
        '   {'+
        '       \"starttime\":\"2019-02-13 12:52:46\",'+
        '       \"extension\":\"4444\",'+
        '       \"from\":\"971\",'+
        '       \"DID\":\"231\",'+
        '       \"agent\":\"anil\",'+
        '       \"callType\":\"Incoming\"'+
        '   }'+
    ']';
    List<IncomingCallsParser> r = IncomingCallsParser.parse(json);
       
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    req.requestURI = '/services/apexrest/incomingCalls';  //Request URL
    req.httpMethod = 'POST';//HTTP Request Type
    req.requestBody = Blob.valueof(json);
    RestContext.request = req;
    RestContext.response= res;
    
    IncomingCalls ic = new IncomingCalls();
    IncomingCalls.ResponseWrapper rw1 = IncomingCalls.pushIncoming();
    
    Test.stopTest();
   }

}