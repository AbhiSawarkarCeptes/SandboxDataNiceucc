@isTest
public class PaymentReceiptComponentController_Test {
	@isTest 
    public static void TestPaymentReceiptComponentController(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Installment', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1000);
        insert pay;
        
        PropStrength__Payment_Plan_Details__c ppd = new PropStrength__Payment_Plan_Details__c(PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60);
        insert ppd;
        
        PropStrength__Other_Charge_Due_Partition__c chargeDue = new PropStrength__Other_Charge_Due_Partition__c(PropStrength__Payment__c = pay.Id, PropStrength__Milestone_Payment_Recieved_cur__c = 1000, PropStrength__Payment_Plan_Detail__c = ppd.Id);
        insert chargeDue;
        
        PaymentReceiptComponentController.payId = pay.Id;
        Test.startTest();
        PaymentReceiptComponentController.getPaymentRecLineItemList();
        Test.stopTest();
    }
}