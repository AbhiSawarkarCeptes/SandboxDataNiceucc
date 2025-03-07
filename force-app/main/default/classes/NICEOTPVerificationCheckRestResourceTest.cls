@isTest
public class NICEOTPVerificationCheckRestResourceTest {
    
    private static final String ERROR_SOURCE = 'NICEOTPVerificationCheckRestResource';
    
    // Mock class for Twilio API callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            String endpoint = request.getEndpoint();
            String requestBody = request.getBody();
            
            if (endpoint.contains('/VerificationCheck')) {
                if(requestBody.contains('12345678')){
                    response.setStatusCode(400);
                    response.setBody('{"code": 20404, "message": "Invalid phone number", "status": 400}');
                }else{
                    response.setStatusCode(200);
                    response.setBody('{"status": "approved", "to": "+1234567890", "message": "OTP Verified Successfully"}');
                }
            } else {
                response.setStatusCode(400);
                response.setBody('{"code": 20404, "message": "Invalid OTP", "status": 400}');
            }
            return response;
        }
    }

    @isTest
    static void testAccountNotFoundScenario() {
        // Test when account is not found
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": "invalidId", "code": "123456"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationCheckRestResource.validateOTP();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode, 'Expected status code 200');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals('No account available to verify the OTP for the entered uniqueId', 
                          responseMap.get('message'), 
                          'Expected account not found message');
    }

    @isTest
    static void testExceptionHandlingScenario() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Account_Id__c = '12345',
            Primary_Number__c = '+1234567890',
            Email__c = 'test@example.com'
        );
        insert testAccount;
        
        // Mock utility to throw exception
        NICEOTPVerificationCheckUtilityMock mockUtility = new NICEOTPVerificationCheckUtilityMock();
        mockUtility.throwException = true;
        Test.setMock(HttpCalloutMock.class, mockUtility);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": "12345", "code": "123456"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationCheckRestResource.validateOTP();
        Test.stopTest();
        
        System.assertEquals(500, RestContext.response.statusCode, 'Expected status code 500');
        Map<String, Object) responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertNotEquals(null, responseMap.get('error'), 'Expected error message');
    }

    @isTest
    static void testMissingPhoneAndEmailScenario() {
        // Create test account with no phone or email
        Account testAccount = new Account(
            Name = 'Test Account',
            Account_Id__c = '12345',
            Primary_Number__c = null,
            Email__c = null
        );
        insert testAccount;
        
        // Mock response for missing phone/email scenario
        NICEOTPVerificationCheckUtilityMock mockUtility = new NICEOTPVerificationCheckUtilityMock();
        mockUtility.missingContactInfo = true;
        Test.setMock(HttpCalloutMock.class, mockUtility);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": "12345", "code": "123456"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationCheckRestResource.validateOTP();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode, 'Expected status code 200');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals('Mobile number and email Address not available for this account to validate OTP', 
                          responseMap.get('message'), 
                          'Expected missing phone and email message');
    }

    @isTest
    static void testSuccessfulOTPValidationWithPhone() {
        // Create test account with phone
        Account testAccount = new Account(
            Name = 'Test Account',
            Account_Id__c = '12345',
            Primary_Number__c = '+1234567890',
            Email__c = null
        );
        insert testAccount;
        
        NICEOTPVerificationCheckUtilityMock mockUtility = new NICEOTPVerificationCheckUtilityMock();
        mockUtility.phoneOnly = true;
        Test.setMock(HttpCalloutMock.class, mockUtility);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": "12345", "code": "123456"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationCheckRestResource.validateOTP();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode, 'Expected status code 200');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals('approved', responseMap.get('status'), 'Expected successful OTP validation');
    }

    @isTest
    static void testSuccessfulOTPValidationWithEmail() {
        // Create test account with email
        Account testAccount = new Account(
            Name = 'Test Account',
            Account_Id__c = '12345',
            Primary_Number__c = null,
            Email__c = 'test@example.com'
        );
        insert testAccount;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": "12345", "code": "123456"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationCheckRestResource.validateOTP();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode, 'Expected status code 200');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals('approved', responseMap.get('status'), 'Expected successful OTP validation');
    }

    @isTest
    static void testFailedOTPValidation() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Account_Id__c = '12345',
            Primary_Number__c = '+1234567890',
            Email__c = 'test@example.com'
        );
        insert testAccount;
        
        // Mock utility to fail OTP validation
        NICEOTPVerificationCheckUtilityMock mockUtility = new NICEOTPVerificationCheckUtilityMock();
        mockUtility.failCallout = true;
        Test.setMock(HttpCalloutMock.class, mockUtility);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": "12345", "code": "wrongcode"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationCheckRestResource.validateOTP();
        Test.stopTest();
        
        System.assertEquals(500, RestContext.response.statusCode, 'Expected status code 500');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertNotEquals(null, responseMap.get('error'), 'Expected error message');
    }

    @isTest
    static void testSuccessfulOTPValidation() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Account_Id__c = '12345',
            Primary_Number__c = '+1234567890',
            Email__c = 'test@example.com'
        );
        insert testAccount;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"uniqueId": "12345", "code": "123456"}');
        req.httpMethod = 'POST';
        
        Test.startTest();
        String response = NICEOTPVerificationCheckRestResource.validateOTP();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode, 'Expected status code 200');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals('approved', responseMap.get('status'), 'Expected successful OTP validation');
    }

    private class NICEOTPVerificationCheckUtilityMock implements HttpCalloutMock {
        public Boolean throwException = false;
        public Boolean failCallout = false;
        public Boolean missingContactInfo = false;
        public Boolean phoneOnly = false;
        
        public HttpResponse respond(HttpRequest request) {
            if (throwException) {
                throw new CalloutException('Test utility exception');
            }
            HttpResponse response = new HttpResponse();
            if (failCallout) {
                response.setStatusCode(500);
                response.setBody('{"message": "Callout failed", "status": "failed"}');
            } else if (missingContactInfo) {
                response.setStatusCode(200);
                response.setBody('{"message": "Mobile number and email Address not available for this account to validate OTP"}');
            } else if (phoneOnly) {
                response.setStatusCode(200);
                response.setBody('{"status": "approved", "to": "+1234567890"}');
            } else {
                response.setStatusCode(200);
                response.setBody('{"status": "approved", "to": "test@example.com"}');
            }
            return response;
        }
    }
}
