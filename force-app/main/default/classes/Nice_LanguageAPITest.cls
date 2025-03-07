/***************************************************************************
Class Name     : Nice_LanguageAPITest
Covers         : Nice_LanguageSetAPI
Author         : Ashok Kumar M
*****************************************************************************/
@isTest
private with sharing class Nice_LanguageAPITest {
    
    @testSetup
    private static void setUp(){
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email__c = 'ashok.kumar@ceptes.onmicrosoft.com';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        insert acc;
        
    }
    
    @isTest
    private static void testPreferredLanguagepositive(){
        
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        String requestBody = JSON.serialize(new Map<String, String>{
            'recordId' => acc.Id,
            'preferredLanguage' => 'English'
             });
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_LanguageSetAPI.updatePreferredLanguage();
        Assert.areEqual(RestContext.response.statusCode , 200);
        test.stopTest();
        
    }
    
    @isTest
    private static void testWithInvalidLanguage(){
        
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        String requestBody = JSON.serialize(new Map<String, String>{
            'recordId' => acc.Id,
            'preferredLanguage' => 'Eng'
             });
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_LanguageSetAPI.updatePreferredLanguage();
        Assert.areEqual(RestContext.response.statusCode , 500);
        test.stopTest();
        
    }
    
    @isTest
    private static void testWithIsBlank(){
        
        String requestBody = JSON.serialize(new Map<String, String>{
            'recordId' => '',
            'preferredLanguage' => 'EngLish'
             });
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_LanguageSetAPI.updatePreferredLanguage();
        Assert.areEqual(RestContext.response.statusCode , 400);
        test.stopTest();
        
    }
    
    @isTest
    private static void testWithNoRequestBody(){
        
        String requestBody = JSON.serialize(new Map<String, String>{
            'recordId' => '',
            'preferredLanguage' => 'EngLish'
             });
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_LanguageSetAPI.updatePreferredLanguage();
        Assert.areEqual(RestContext.response.statusCode , 500);
        test.stopTest();
        
    }
    
    @isTest
    private static void testWithNoPLObject(){
        
        Test.startTest();
        Task__c tsk = new Task__c();
        insert tsk;
        
        String requestBody = JSON.serialize(new Map<String, String>{
            'recordId' => tsk.Id,
            'preferredLanguage' => 'English'
             });
        
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_LanguageSetAPI.updatePreferredLanguage();
        Assert.areEqual(RestContext.response.statusCode , 500);
        test.stopTest();
        
    }

}