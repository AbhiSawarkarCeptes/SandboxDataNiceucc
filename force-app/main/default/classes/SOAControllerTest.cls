@isTest
public class SOAControllerTest {
    @isTest
    public static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        PropStrength__Projects__c PSProject = new PropStrength__Projects__c ();
        PSProject .name = 'Tomar';
        PSProject.Do_Not_Raise_Demand__c = true;
        PSProject.Do_Not_Send_Reminder__c = true;
        PSProject.PropStrength__Active__c = true;
        PSProject.Customer_Care_Email_ID__c = 'divyansh@cloudsteer.com';
        PSProject.PropStrength__Avoid_ITC_calculation_on_Booking_Amount__c = true;
        PSProject.PropStrength__Completion_Certification_Received__c = true;
        PSProject.PropStrength__Enable_Pie_Chart_Count_Wise__c = true;
        PSProject.PropStrength__Is_First_Transfer_Free__c = true;
        PSProject.PropStrength__Over_Booking_Allowed__c = true;
        PSProject.PropStrength__Rebate_Applicable__c = true;
        PSProject.PropStrength__Under_PMAY_Scheme__c = true;
        PSProject.PropStrength__VAT_Applicable__c = true;
        PSProject.RERA_Registered__c = true;
        PSProject.T_link_Demand_Days__c = 5.0;
        insert PSProject;

        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c ();
        book.PropStrength__Project__c = PSProject.id;
        book.PropStrength__Total_Basic_Sales_Price__c = 10;
        book.Create_SBTR__c = true;
        book.PropStrength__Booking_Date__c = SYstem.today();
        book.DSPA_Transaction_Exception__c = true;
        insert book;

        PropStrength__Payment_Plan_Details__c ppd = new PropStrength__Payment_Plan_Details__c(PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60);
        insert ppd;

        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved', PropStrength__Is_Milestone_Completed__c = TRUE);
        insert ppd1;
        
        PropStrength__Received_Payment__c recPayment = TestDataFactorySobha.createPayment(null);
        recPayment.recordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        recPayment.PropStrength__Receipt_Reversed__c = false;
        recPayment.PropStrength__Amount__c = 1000;
        insert recPayment;
        
        PropStrength__Received_Payment__c recPayment2 = TestDataFactorySobha.createPayment(null);
        recPayment2.recordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
        recPayment2.PropStrength__Receipt_Reversed__c = false;
        insert recPayment2;
        PropStrength__Transaction_Requests__c transReq = TestDataFactorySobha.createTransactionRequest(null);  
        transReq.PropStrength__Application_Booking__c = book.Id;
        insert transReq;

        PageReference myVfPage = Page.SOALetterHTML;
        Test.setCurrentPage(myVfPage);
        ApexPages.CurrentPage().getParameters().put('id',book.Id);
        
        Test.startTest();
        SOAController soa = new SOAController();
        soa.backToRecPage();
        soa.saveDocFile();
        soa.sendMail();
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        PropStrength__Projects__c PSProject = new PropStrength__Projects__c ();
        PSProject .name = 'Tomar';
        PSProject.Do_Not_Raise_Demand__c = true;
        PSProject.Do_Not_Send_Reminder__c = true;
        PSProject.PropStrength__Active__c = true;
        PSProject.Customer_Care_Email_ID__c = 'divyansh@cloudsteer.com';
        PSProject.PropStrength__Avoid_ITC_calculation_on_Booking_Amount__c = true;
        PSProject.PropStrength__Completion_Certification_Received__c = true;
        PSProject.PropStrength__Enable_Pie_Chart_Count_Wise__c = true;
        PSProject.PropStrength__Is_First_Transfer_Free__c = true;
        PSProject.PropStrength__Over_Booking_Allowed__c = true;
        PSProject.PropStrength__Rebate_Applicable__c = true;
        PSProject.PropStrength__Under_PMAY_Scheme__c = true;
        PSProject.PropStrength__VAT_Applicable__c = true;
        PSProject.RERA_Registered__c = true;
        PSProject.T_link_Demand_Days__c = 5.0;
        insert PSProject;

        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c ();
        book.PropStrength__Project__c = PSProject.id;
        book.PropStrength__Total_Basic_Sales_Price__c = 10;
        book.Create_SBTR__c = true;
        book.PropStrength__Booking_Date__c = SYstem.today();
        book.DSPA_Transaction_Exception__c = true;
        insert book;

        PropStrength__Payment_Plan_Details__c ppd = new PropStrength__Payment_Plan_Details__c(PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today().addDays(-2));
        insert ppd;

        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today().addDays(-5), PropStrength__Approval_Status__c = 'Approved', PropStrength__Is_Milestone_Completed__c = TRUE);
        insert ppd1;
        
        PropStrength__Received_Payment__c recPayment = TestDataFactorySobha.createPayment(null);
        recPayment.recordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        recPayment.PropStrength__Receipt_Reversed__c = false;
        recPayment.PropStrength__Amount__c = 1000;
        insert recPayment;
        
        PropStrength__Received_Payment__c recPayment2 = TestDataFactorySobha.createPayment(null);
        recPayment2.recordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
        recPayment2.PropStrength__Receipt_Reversed__c = false;
        insert recPayment2;
        PropStrength__Transaction_Requests__c transReq = TestDataFactorySobha.createTransactionRequest(null);  
        transReq.PropStrength__Application_Booking__c = book.Id;
        insert transReq;

        PageReference myVfPage = Page.SOALetterHTML;
        Test.setCurrentPage(myVfPage);
        ApexPages.CurrentPage().getParameters().put('id',book.Id);
        
        Test.startTest();
        SOAController soa = new SOAController();
        soa.backToRecPage();
        soa.saveDocFile();
        soa.sendMail();
        Test.stopTest();
    }
}