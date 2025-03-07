/***************************************************************************
Class      : Nice_AccessTokenUtility
Test Class : Nice_AccessTokenUtilityTest
Purpose    : NICE - Test class Code coverage 94% 
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_AccessTokenUtilityTest {

    @testSetup
    static void setupTestData() {
        NiceApiAccessSettings__c testSettings = new NiceApiAccessSettings__c(
            Access_Token__c = 'testToken123',
            Token_Expiry_Time__c = DateTime.now().addMinutes(-60)
        );
        insert testSettings;
    }

    @isTest
    static void testGetToken_NewTokenGeneratedWhenNoSettingsExist() {
        delete [SELECT Id FROM NiceApiAccessSettings__c];
        Test.startTest();
        Map<String, Boolean> tokenMap = Nice_AccessTokenUtility.getToken();
        Test.stopTest();
        System.assert(!tokenMap.isEmpty(), 'Token map should not be empty');
        System.assert(tokenMap.values().contains(true), 'New token should be generated');
    }

    @isTest
    static void testGetToken_TokenExpired() {
        NiceApiAccessSettings__c expiredSettings = [SELECT Id, Access_Token__c, Token_Expiry_Time__c FROM NiceApiAccessSettings__c LIMIT 1];
        expiredSettings.Token_Expiry_Time__c = DateTime.now().addMinutes(-60); // Force expiry
        update expiredSettings;
        Test.startTest();
        Map<String, Boolean> tokenMap = Nice_AccessTokenUtility.getToken();
        Test.stopTest();
        System.assert(!tokenMap.isEmpty(), 'Token map should not be empty');
        System.assert(tokenMap.values().contains(true), 'New token should be generated for expired token');
    }

    @isTest
    static void testGetToken_ValidTokenNotExpired() {
        NiceApiAccessSettings__c validSettings = [SELECT Id, Access_Token__c, Token_Expiry_Time__c FROM NiceApiAccessSettings__c LIMIT 1];
        validSettings.Token_Expiry_Time__c = DateTime.now().addMinutes(60); // Set future expiry
        update validSettings;
        Test.startTest();
        Map<String, Boolean> tokenMap = Nice_AccessTokenUtility.getToken();
        Test.stopTest();
        System.assert(!tokenMap.isEmpty(), 'Token map should not be empty');
    }
 
    @isTest
    static void testGetToken_BlankAccessTokenAndNullExpiryTime() {
        NiceApiAccessSettings__c settings = new NiceApiAccessSettings__c(
            Access_Token__c = null,
            Token_Expiry_Time__c = null
        );
        insert settings;
        Test.startTest();
        Map<String, Boolean> tokenMap = Nice_AccessTokenUtility.getToken();
        Test.stopTest();
        System.assert(!tokenMap.isEmpty(), 'Token map should not be empty');
        System.assert(tokenMap.values().contains(true), 'New token should be generated when access token is blank and expiry time is null');
    }

    @isTest
    static void testGetToken_ExpiredToken() {
        NiceApiAccessSettings__c settings = new NiceApiAccessSettings__c(
            Access_Token__c = 'ExpiredToken123',
            Token_Expiry_Time__c = System.now().addMinutes(-60) 
        );
        insert settings;
        Test.startTest();
        Map<String, Boolean> tokenMap = Nice_AccessTokenUtility.getToken();
        Test.stopTest();

        System.assert(!tokenMap.isEmpty(), 'Token map should not be empty');
        System.assert(tokenMap.values().contains(true), 'New token should be generated when the existing token is expired');
    }

    @isTest
    static void testGenerateNewToken() {
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"access_token":"newMockToken123"}');

        HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        String newToken = Nice_AccessTokenUtility.generateNewToken();
        Test.stopTest();

        System.assertEquals('newMockToken123', newToken, 'Expected new mock token to be returned');
    }
    
    @isTest
    static void testSaveToken_InsertNewRecord() {
        Test.startTest();
        delete [SELECT Id FROM NiceApiAccessSettings__c];
        Nice_AccessTokenUtility.saveToken('TestToken123');
        Test.stopTest();
        NiceApiAccessSettings__c settings = [SELECT Access_Token__c, Token_Expiry_Time__c FROM NiceApiAccessSettings__c LIMIT 1];
        System.assertEquals('TestToken123', settings.Access_Token__c, 'Access token should be saved');
        System.assertNotEquals(null, settings.Token_Expiry_Time__c, 'Expiry time should be set');
    }

    @isTest
    static void testSaveToken_UpdateExistingRecord() {
        NiceApiAccessSettings__c existingSettings = new NiceApiAccessSettings__c(
            Access_Token__c = 'OldToken',
            Token_Expiry_Time__c = System.now().addMinutes(-30) // Expired token
        );
        insert existingSettings;

        Test.startTest();
        Nice_AccessTokenUtility.saveToken('UpdatedToken456');
        Test.stopTest();
        NiceApiAccessSettings__c updatedSettings = [SELECT Access_Token__c, Token_Expiry_Time__c FROM NiceApiAccessSettings__c WHERE Id = :existingSettings.Id];
        System.assertEquals('OldToken', updatedSettings.Access_Token__c, 'Access token should be updated');
        System.assertNotEquals(null, updatedSettings.Token_Expiry_Time__c, 'Expiry time should be updated');
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}