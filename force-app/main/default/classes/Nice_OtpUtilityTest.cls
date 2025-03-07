/***************************************************************************
Class Name     : Nice_OtpUtilityTest
Covers         : Nice_OtpUtility
Author         : Ashok Kumar M
*****************************************************************************/
@isTest
public class Nice_OtpUtilityTest {
    
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
    Private static void setup(){
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email__c = 'ashok.kumar@ceptes.com';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.Primary_Mobile_Number__c = '+918838391993';
        insert acc;
        
    }

    @isTest
    Private static void testSendOTP() { 
        
        Map<String, String> requestMap = new Map<String, String>();
        Account acc = [SELECT Id, Name, Account_Id__c, Primary_Mobile_Number__c, Email__c FROM Account WHERE Name = 'Test Acc' LIMIT 1];
        requestMap.put('sms', acc.Primary_Mobile_Number__c);
        requestMap.put('email', acc.Email__c);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        Map<String, Object> responseMap = Nice_OtpUtility.sendOTP(requestMap, acc.Id, acc.Name);
        Assert.isNotNull(responseMap);
        test.stopTest();        
        
    }
    
}