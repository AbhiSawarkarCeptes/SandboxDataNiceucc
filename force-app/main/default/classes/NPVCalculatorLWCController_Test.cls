@isTest
public class NPVCalculatorLWCController_Test {
	@isTest
    static void testMethod1() {   
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
        
        PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 100, PropStrength__Project__c = proj.Id);
        insert book1;
        
        PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1);
        insert pay1;
        
        NPV_Slab__c slab = new NPV_Slab__c(Rebate__c = 5.00, Days_From__c = 365, Days_to__c = 0);
        insert slab;
        
        PageReference myVfPage = Page.NPVCalculator;
        Test.setCurrentPage(myVfPage);

        ApexPages.currentPage().getParameters().put('id',book.Id);
        NPVCalculatorLWCController npv = new NPVCalculatorLWCController();
        NPVCalculatorLWCController.ppdRecords(book.Id);
        NPVCalculatorLWCController.paymentRecords(book.Id);
        NPVCalculatorLWCController.npvSlabsRecords();
        // NPVCalculatorLWCController.createTransationRequest('1000','10000',book.Id,pay.Id);
        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Addition / Deletion of Name').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id);
        insert tr;
        // NPVCalculatorLWCController.createTransationRequest('1000','10000',book.Id,pay.Id);
        
        ApexPages.currentPage().getParameters().put('id',book1.Id);
        NPVCalculatorLWCController npv1 = new NPVCalculatorLWCController();
    }
}