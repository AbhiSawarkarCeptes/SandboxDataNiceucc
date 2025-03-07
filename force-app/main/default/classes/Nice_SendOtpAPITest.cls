/***************************************************************************
Class Name     : Nice_SendOtpAPITest
Covers         : Nice_SendOtpAPI
Author         : Ashok Kumar M
*****************************************************************************/
@isTest
private with sharing class Nice_SendOtpAPITest {

   private class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('/login/user/')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"token": "fakeToken"}');
                res.setStatusCode(200);
            }else if (req.getEndpoint().contains('/campaigns/submissions/sms/nb')) {
                res.setStatusCode(201);
                res.setBody('{"status": "sent"}');
            }
            return res;
        }
    }
    
    @testSetup
    Private static void setup() {
        
        List<Account> accountList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email__c = 'ashok.kumar@ceptes.onmicrosoft.com';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.Primary_Number__c = '+918838391997';
        accountList.add(acc);
        
        Account accTwo = new Account();
        accTwo.Name = 'Test Acc two';
        accTwo.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        accTwo.Broker_Sub_Type__c = 'Broker UAE';
        accountList.add(accTwo);
        
        insert accountList;
        
    }
    
    @isTest
    static void testValidRequest() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        Account acc = [SELECT Id, Name, Account_Id__c FROM Account WHERE Name = 'Test Acc' LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf('{"uniqueId": ' + acc.Account_Id__c + '}');
        req.httpMethod = 'POST';
        
        test.startTest();
        String response = Nice_SendOtpAPI.sendOTP();
        Assert.areEqual(RestContext.response.statusCode, 200);
        test.stopTest();
        
    }
    
     @isTest
    static void testInvalidAccId() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf('{"uniqueId":"00000"}');
        req.httpMethod = 'POST';
        
        test.startTest();
        String response = Nice_SendOtpAPI.sendOTP();
        Assert.areEqual(RestContext.response.statusCode, 206);
        test.stopTest();
        
    }
    
    @isTest
    static void testwithNoToAdsress() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        Account acc = [SELECT Id, Name, Account_Id__c FROM Account WHERE Name = 'Test Acc two' LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf('{"uniqueId": ' + acc.Account_Id__c + ' }');
        req.httpMethod = 'POST';
        
        test.startTest();
        String response = Nice_SendOtpAPI.sendOTP();
        Assert.areEqual(RestContext.response.statusCode, 206);
        test.stopTest();
        
    }
    
    @isTest
    static void testuniqueIdAsText() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf('{"uniqueId": Invalid}');
        req.httpMethod = 'POST';
        
        test.startTest();
        String response = Nice_SendOtpAPI.sendOTP();
        Assert.areEqual(RestContext.response.statusCode, 500);
        test.stopTest();
        
    }
    
    @isTest
    static void testMissingUniqueId() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf('{"uniqueId":""}');
        req.httpMethod = 'POST';
        
        test.startTest();
        String response = Nice_SendOtpAPI.sendOTP();
        Assert.areEqual(RestContext.response.statusCode, 400);
        test.stopTest();
        
    }

}