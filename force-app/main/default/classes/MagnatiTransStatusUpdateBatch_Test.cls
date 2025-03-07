@isTest
public class MagnatiTransStatusUpdateBatch_Test {
    @IsTest
    static void testMagnatiTransactionStatusUpdateBatchClone(){
              

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


        Test.startTest();
        MagnatiTransactionStatusUpdateBatchClone mtsupc = new MagnatiTransactionStatusUpdateBatchClone();
        Database.executeBatch(mtsupc);
        Test.stopTest();

    }

    @IsTest
    static void testMagnatiTransactionStatusUpdateBatchClone1(){
              

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
        insert mth;


        Test.startTest();
        MagnatiTransactionStatusUpdateBatchClone mtsupc = new MagnatiTransactionStatusUpdateBatchClone();
        Database.executeBatch(mtsupc);
        Test.stopTest();

    }
}