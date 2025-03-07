/***************************************************************************
Class Name     : Nice_SearchCustomerTest
Covers         : Nice_SearchCustomerAPI
Author         : Ashok Kumar M
*****************************************************************************/
@isTest
private with sharing class Nice_SearchCustomerTest {
        
    @testSetup
    Private static void setup(){
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email__c = 'ashok.kumar@ceptes.onmicrosoft.com';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.Primary_Mobile_Number__c = '+918838391997';
        insert acc;
        
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
    Private static void testSearchkMobileNumberAccount(){
        
        Account acc = [SELECT Id, Name, Primary_Mobile_Number__c FROM Account LIMIT 1];
        List<Id> fixedSearchResults = new List<Id>{acc.Id};
        fixedSearchResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        String requestBody = JSON.serialize(new Map<String, String>{'phoneNumber' => '+918838391997'});
        
        test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_SearchCustomerAPI.searchMobileNumber();
        Assert.areEqual(RestContext.response.statusCode , 200);
        test.stopTest();
        
    }
    
    @isTest
    Private static void testSearchkMobileNumberLead(){
        
        lead le = [SELECT Id, Name, Primary_Mobile_Number__c FROM Lead LIMIT 1];
        List<Id> fixedSearchResults = new List<Id>{le.Id};
        fixedSearchResults[0] = le.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        String requestBody = JSON.serialize(new Map<String, String>{'phoneNumber' => '+918838391997'});
        
        test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_SearchCustomerAPI.searchMobileNumber();
        Assert.areEqual(RestContext.response.statusCode , 200);
        test.stopTest();
        
    }
    
    @isTest
    Private static void testWithBlankPhone(){

        String requestBody = JSON.serialize(new Map<String, String>{'phoneNumber' => ''});
        
        test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_SearchCustomerAPI.searchMobileNumber();
        Assert.areEqual(RestContext.response.statusCode , 400);
        test.stopTest();
        
    }
    
    @isTest
    Private static void testEmptyResult(){
        
        String requestBody = JSON.serialize(new Map<String, String>{'phoneNumber' => '+99712540010154558'});
        
        test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_SearchCustomerAPI.searchMobileNumber();
        Assert.areEqual(RestContext.response.statusCode , 206);
        test.stopTest();
        
    }
    
    @isTest
    Private static void testWithInvalidRequestBody(){
        
        test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Nice_SearchCustomerAPI.searchMobileNumber();
        Assert.areEqual(RestContext.response.statusCode , 500);
        test.stopTest();
        
    }

}