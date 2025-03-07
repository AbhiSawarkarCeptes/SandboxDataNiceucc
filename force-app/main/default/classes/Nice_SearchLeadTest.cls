/***************************************************************************
Class Name     : Nice_SearchLeadTest
Covers         : Nice_SearchLead
Author         : Ashok Kumar M
*****************************************************************************/
@isTest
private with sharing class Nice_SearchLeadTest {
    
    @testSetup
    Private static void setup() {
        
        Lead le = new Lead();
        le.FirstName = 'Test';
        le.LastName = 'Lead';
        le.Email = 'ashok.kumar@ceptes.onmicrosoft.com';
        le.MobilePhone = '+918838391997';
        le.Primary_Mobile_Number__c = '+918838391997';
        le.Presales_Agent__c = userInfo.getUserId();
        insert le;
        
    }
    
    @isTest
    private static void testSearchLead() {
        
        String requestBody = JSON.serialize(new Map<String, String>{'phoneNumber' => '+918838391997'});
        
        test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_SearchLead.searchLead();
        Assert.areEqual(RestContext.response.statusCode, 200);
        test.stopTest();
        
    }
    
    @isTest
    private static void testAsMissingPhoneNumber() {
        
        String requestBody = JSON.serialize(new Map<String, String>{'phoneNumber' => ''});
        
        test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_SearchLead.searchLead();
        Assert.areEqual(RestContext.response.statusCode, 400);
        test.stopTest();
        
    }
    
    @isTest
    private static void testAsNoRecordFound() {
        
        String requestBody = JSON.serialize(new Map<String, String>{'phoneNumber' => '+9188345267'});
        
        test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_SearchLead.searchLead();
        Assert.areEqual(RestContext.response.statusCode, 206);
        test.stopTest();
        
    }
    
    @isTest
    private static void testForException() {
                 
        test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_SearchLead.searchLead();
        Assert.areEqual(RestContext.response.statusCode, 500);
        test.stopTest();
        
    }
    
}