@isTest
public class NICEOTPVerificationRestResourceTest {
    
    // Mock class for Twilio API callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            String endpoint = request.getEndpoint();
            String requestBody = request.getBody();
            
            if (endpoint.contains('/Verifications')) {
                if(requestBody.contains('Invalid')){
                    response.setStatusCode(400);
                    response.setBody('{"code": 20404, "message": "Invalid phone number", "status": 400}');
                }else{
                    response.setStatusCode(200);
                    response.setBody('{"sid": "12345", "status": "pending", "to": "+1234567890", "channel": "sms"}');
                }
            } else {
                response.setStatusCode(400);
                response.setBody('{"code": 20404, "message": "Invalid phone number", "status": 400}');
            }
            return response;
        }
    }
    
    @testSetup
    private static void setup(){
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email__c = 'ashok.kumar@ceptes.onmicrosoft.com';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.Primary_Number__c = '+918838391997';
        insert acc;
    }
    
    @isTest
    static void testValidRequest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account acc = [SELECT Id, Name, Account_Id__c FROM Account LIMIT 1];
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": '+acc.Account_Id__c+'}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationRestResource.sendOTP();
        System.assertEquals(201, RestContext.response.statusCode, 'Expected status code 201 for valid request');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assert(responseMap.containsKey('sid'), 'Response should contain sid');
        Test.stopTest();
    }
    
    @isTest
    static void testuniqueIdAsText() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": Invalid}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationRestResource.sendOTP();
        System.assertEquals(400, RestContext.response.statusCode, 'Expected status code 400 for invalid uniqueId');
        Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assert(errorMap.containsKey('message'), 'Error response should contain message');
        Test.stopTest();
    }
    
    @isTest
    static void testMissingUniqueId() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId":}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationRestResource.sendOTP();
        System.assertEquals(400, RestContext.response.statusCode, 'Expected status code 400 for missing uniqueId');
        Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assert(errorMap.containsKey('message'), 'Error response should contain message');
        Test.stopTest();
    }
    
    @isTest
    static void testInvalidPhoneNumber() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"phoneNumber": "+911883839199","emailAddress":"ashok.kumar@ceptes.onmicrosoft.com"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationRestResource.sendOTP();
        System.assertEquals(400, RestContext.response.statusCode, 'Expected status code 400 for invalid phone number');
        Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assert(errorMap.containsKey('message'), 'Error response should contain message');
        Test.stopTest();
    }
    
    @isTest
    static void testAccountNotFound() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": "INVALID_ID"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationRestResource.sendOTP();
        System.assertEquals(404, RestContext.response.statusCode, 'Expected status code 404 for account not found');
        Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assert(errorMap.containsKey('message'), 'Error response should contain account not found message');
        Test.stopTest();
    }

    @isTest
    static void testMissingPhoneAndEmail() {
        Account acc = new Account(
            Name = 'Test Acc No Contact',
            recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(),
            Broker_Sub_Type__c = 'Broker UAE'
        );
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": "' + acc.Account_Id__c + '"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationRestResource.sendOTP();
        System.assertEquals(400, RestContext.response.statusCode, 'Expected status code 400 for missing phone and email');
        Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assert(errorMap.containsKey('message'), 'Error response should contain missing contact info message');
        Test.stopTest();
    }

    @isTest
    static void testExceptionHandling() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        // Force exception by passing invalid JSON
        req.requestBody = Blob.valueOf('invalid json');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationRestResource.sendOTP();
        System.assertEquals(500, RestContext.response.statusCode, 'Expected status code 500 for exception');
        Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assert(errorMap.containsKey('message'), 'Error response should contain error message');
        Test.stopTest();
    }
}
