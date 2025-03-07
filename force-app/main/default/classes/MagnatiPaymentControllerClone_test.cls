@isTest
public with sharing class MagnatiPaymentControllerClone_test {
    
    @TestSetup
    static void makeData(){
        Payment_Request_Wrapper__c prw = new Payment_Request_Wrapper__c();
        prw.Email__c = 'testclass@gmail.com';
        prw.Is_Make_Payment_Clicked__c = true;
        insert prw;
    }
    
    @isTest
    static void setLinkClicked(){
        Payment_Request_Wrapper__c prw = new Payment_Request_Wrapper__c();
        insert prw;
        MagnatiPaymentControllerClone.setLinkClicked(prw.Id);
        prw = [SELECT Id, Is_Make_Payment_Clicked__c FROM Payment_Request_Wrapper__c WHERE Id = :prw.Id];
        System.assertEquals(prw.Is_Make_Payment_Clicked__c, true, 'setLinkClicked assert failed');
    }
    @isTest
    static void testGenerateMagnatiTransaction() {
        Payment_Request_Wrapper__c prw = new Payment_Request_Wrapper__c();
        prw.Units__c ='ordernumber1234567890123456789';
        insert prw;
        // List<Payment_Request_Wrapper__c> prwlist = new List<Payment_Request_Wrapper__c>([select id from Payment_Request_Wrapper__c]);
        Payment_Request__c reqInst = new Payment_Request__c();
        reqInst.Mode__c = 'Website';
        reqInst.Payment_Request_Wrapper__c = prw.Id;
        reqInst.Mobile_Number__c = '9876543210';
        reqInst.Payment_Public_Link__c = 'hello/how';
        reqInst.Payment_Public_Link_Copy__c = URL.getOrgDomainUrl().toExternalForm();        
        system.debug('link her ++'+ reqInst.Payment_Public_Link_Copy__c);
        insert reqInst;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String result = MagnatiPaymentControllerClone.generateMagnatiTransaction(prw.Id);
        System.assertNotEquals(result, null, 'testGenerateMagnatiTransaction assert failed');
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateMagnatiTransactionCatch() {
        Payment_Request_Wrapper__c prw = new Payment_Request_Wrapper__c();
        insert prw;
        Payment_Request__c reqInst = new Payment_Request__c();
        reqInst.Mode__c = 'Website';
        reqInst.Mobile_Number__c = '9876543210';
        reqInst.Payment_Public_Link__c = URL.getOrgDomainUrl().toExternalForm();        
        insert reqInst;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        try {
            String result = MagnatiPaymentControllerClone.generateMagnatiTransaction(prw.Id);
        } catch (Exception ex) {
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckTransactionStatus() {
        Payment_Request_Wrapper__c wrapperInst = new Payment_Request_Wrapper__c();
        wrapperInst = [SELECT Id FROM Payment_Request_Wrapper__c];
        Payment_Request__c reqInst = new Payment_Request__c();
        reqInst.Mode__c = 'Website';
        reqInst.Mobile_Number__c ='9876543210';
        reqInst.Payment_Public_Link__c = URL.getOrgDomainUrl().toExternalForm();
        insert reqInst;
        Magnati_Transaction_History__c historyRecord = new Magnati_Transaction_History__c(
            TransactionID__c = '123', Payment_Request_Wrapper__c = wrapperInst.Id
        );
        insert historyRecord;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String prwId = historyRecord.Payment_Request_Wrapper__c;
        String result = MagnatiPaymentControllerClone.checkTransactionStatus(wrapperInst.Id);
        System.assertNotEquals(result, null, 'testCheckTransactionStatus assert failed');
        Test.stopTest();
    }


@isTest
    static void testCheckTransactionStatus1() {
        Payment_Request_Wrapper__c wrapperInst = new Payment_Request_Wrapper__c();
        wrapperInst = [SELECT Id FROM Payment_Request_Wrapper__c];
        Payment_Request__c reqInst = new Payment_Request__c();
        reqInst.Mode__c = 'Website';
        reqInst.Mobile_Number__c ='9876543210';
        reqInst.Payment_Public_Link__c = URL.getOrgDomainUrl().toExternalForm();
        insert reqInst;
      
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String result = MagnatiPaymentControllerClone.updatePaymentStatus(reqInst.id);
        Test.stopTest();
    }    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"Transaction":{"ResponseCode":"0","TransactionID":"123","PaymentPortal":"https://example.com","Amount":{"value":""}}}');
            return res;
        }
    }
}