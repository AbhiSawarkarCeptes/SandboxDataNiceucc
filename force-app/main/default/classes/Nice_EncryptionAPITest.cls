/***************************************************************************
Class Name     : Nice_EncryptionAPITest
Covers         : Nice_EncryptionAPI
Author         : Ashok Kumar M
*****************************************************************************/
@isTest
private with sharing class Nice_EncryptionAPITest {
    
    @isTest
    private static void testEncryptPhoneNumberSuccess() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/NICE_PhoneNumberEncryptionQuery';
        req.httpMethod = 'GET';
        req.addParameter('phoneNumber', '+918838391997');
        req.addParameter('method', 'Encrypt');
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        String response = Nice_EncryptionAPI.encryptPhoneNumber();
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Assert.areEqual(200, RestContext.response.statusCode);
        test.stopTest();
        
    }
    
    @isTest
    static void testDecryptPhoneNumberSuccess() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/NICE_PhoneNumberEncryptionQuery';
        req.httpMethod = 'GET';
        req.addParameter('phoneNumber', '+78890212720124017654');
        req.addParameter('method', 'Decrypt');
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        String response = Nice_EncryptionAPI.encryptPhoneNumber();
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Assert.areEqual(200, RestContext.response.statusCode);
        test.stopTest();
        
    }
    
    @isTest
    private static void testInvalidMethodName() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/NICE_PhoneNumberEncryptionQuery';
        req.httpMethod = 'GET';
        req.addParameter('phoneNumber', '+918838391997');
        req.addParameter('method', 'decrypt');
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        String response = Nice_EncryptionAPI.encryptPhoneNumber();
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Assert.areEqual(400, RestContext.response.statusCode);
        test.stopTest();
        
    }
    
    @isTest
    private static void testMissingMethodName() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/NICE_PhoneNumberEncryptionQuery';
        req.httpMethod = 'GET';
        req.addParameter('phoneNumber', '+918838391997');
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        String response = Nice_EncryptionAPI.encryptPhoneNumber();
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Assert.areEqual(400, RestContext.response.statusCode);
        test.stopTest();
        
    }
    
    @isTest
    private static void testwithEmptyBody() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/NICE_PhoneNumberEncryptionQuery';
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        String response = Nice_EncryptionAPI.encryptPhoneNumber();
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Assert.areEqual(400, RestContext.response.statusCode);
        test.stopTest();
        
    }
    
    
}