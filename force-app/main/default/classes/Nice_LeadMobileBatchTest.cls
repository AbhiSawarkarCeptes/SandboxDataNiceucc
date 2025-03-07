@isTest
private class Nice_LeadMobileBatchTest {
    
    @testSetup
    private static void setup() {
        
        Lead le = new Lead();
        le.FirstName = 'Test';
        le.LastName = 'Lead';
        le.Email = 'ashok.kumar@ceptes.onmicrosoft.com';
        le.MobilePhone = '+918838391997';
        le.Presales_Agent__c = userInfo.getUserId();
        insert le; 
        
    }
    
    @isTest
    private static void testNice_LeadMobileBatch(){
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Database.executeBatch(new Nice_LeadMobileBatch(), 200);
        test.stopTest();
        
    }
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"valid": true, "local_format": "8838391997", "international_format": "+918838391997", "country_prefix": "+91", "country_code": "IN", "country_name": "India"}');
            return res;
        }
    }

}