@isTest
public class InitiateEztapControllerTest {
    
	@isTest
    public static void getAllEztapDevices_test(){
    	Test.startTest();
        InitiateEztapController.getAllEztapDevices();
        Test.stopTest();
    }
    
    @isTest
    public static void checkExistingRequest_test(){
        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        insert pr;
    	Test.startTest();
        InitiateEztapController.checkExistingRequest(pr.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void startEztap_test(){
        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Amount__c = 100;
        insert pr;
    	Test.startTest();
        Eztap_Device__mdt device = [select Id, 
                                    MasterLabel, 
                                    DeveloperName, 
                                    Device_Id__c, Location__c, Username__c 
                                    from Eztap_Device__mdt 
                                    LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new EzetapStartCalloutMock()); 
        InitiateEztapController.startEztap(device.Id,pr.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void eztapCancelTransaction_test(){
        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Amount__c = 100;
        insert pr;
        Payment_Request_POP_Transactions__c txn = new Payment_Request_POP_Transactions__c();
        txn.Payment_Request__c = pr.Id;
        txn.P2PRequestId__c = '230103090Test';
        insert txn;
    	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EzetapCancelCalloutMock()); 
        InitiateEztapController.eztapCancelTransaction(pr.Id); 
        Test.stopTest();
    }
    
    @isTest
    public static void eztapStatusCheck_test(){
        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Amount__c = 100;
        insert pr;
        Payment_Request_POP_Transactions__c txn = new Payment_Request_POP_Transactions__c();
        txn.Payment_Request__c = pr.Id;
        txn.P2PRequestId__c = '230103090Test';
        insert txn;
    	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EzetapStatusCalloutMock()); 
        InitiateEztapController.eztapStatusCheck(pr.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void eztapStatusCheckBatch_test(){
        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Amount__c = 100;
        insert pr;
        Payment_Request_POP_Transactions__c txn = new Payment_Request_POP_Transactions__c();
        txn.Payment_Request__c = pr.Id;
        txn.P2PRequestId__c = '230103090Test';
        insert txn;
    	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EzetapStatusCalloutMock()); 
        EztapStatusCheck ob = new EztapStatusCheck(txn.Id);
        Database.executeBatch(ob);
        Test.stopTest();
    }
}