@IsTest
public class MagnatiTransStatusUpdQueuableCopy_Test {
    @TestSetup
    static void data(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;      
        uhw.Is_Make_Payment_Clicked__c = true;  
        uhw.Payment_Link_Expiry__c = System.now().addDays(-1);
        insert uhw;        

        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C ='OTC Deposits';        
        uh.Status__c ='Approved';
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Payment_Link_Status__c = 'Active';
        insert uh;

        Magnati_Transaction_History__c mth = new Magnati_Transaction_History__c();
        mth.Payment_Request_Wrapper__c = uhw.id;
        mth.Status_Fetched__c = false;
        mth.TransactionID__c = '12345';
        insert mth;
    }

    @IsTest
    static void testMagnati1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Payment_Request_Wrapper__c prw = [SELECT Id FROM Payment_Request_Wrapper__c LIMIT 1];
        List<Magnati_Transaction_History__c> historyList = [SELECT Id,TransactionId__c FROM Magnati_Transaction_History__c];
        MagnatiTransactionStatusUpdQueuableCopy m = new MagnatiTransactionStatusUpdQueuableCopy(0,prw.id,historyList,'Test');
        Id apexJobID = system.enqueueJob(m);
    }
    @IsTest
    static void testMagnati2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Payment_Request_Wrapper__c prw = [SELECT Id FROM Payment_Request_Wrapper__c LIMIT 1];
        List<Magnati_Transaction_History__c> historyList = [SELECT Id,TransactionId__c FROM Magnati_Transaction_History__c];
        MagnatiTransactionStatusUpdQueuableCopy m = new MagnatiTransactionStatusUpdQueuableCopy(10,prw.id,historyList,'Test');
        Id apexJobID = system.enqueueJob(m);
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Transaction": {"ResponseCode": "0", "ApprovalCode": "APPROVED", "Account": "123456", "Amount": {"Value": "100.00"}, "CardToken": "token123", "CardNumber": "411111******1111", "CardBrand": "VISA", "CardType": "CREDIT", "ResponseDescription": "Approved", "IsWalletUsed": false}}');
            res.setStatusCode(200);
            return res;
        }
    }
}