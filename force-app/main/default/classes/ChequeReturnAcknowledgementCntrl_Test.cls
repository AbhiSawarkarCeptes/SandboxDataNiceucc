@IsTest
public class ChequeReturnAcknowledgementCntrl_Test {
    @isTest
    static void testChequeReturnAcknowledgementCntrl() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c PSProject = new PropStrength__Projects__c ();
        PSProject .name = 'Tomar';
        PSProject.Do_Not_Raise_Demand__c = true;
        PSProject.Do_Not_Send_Reminder__c = true;
        PSProject.PropStrength__Active__c = true;
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
        
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = PSProject.Id;
        attachment.Name = 'Test Attachment for Parent LOGO';
        attachment.Body = b;
        insert attachment;
        
        PropStrength__Application_Booking__c AppBooking = new PropStrength__Application_Booking__c ();
        AppBooking.PropStrength__Project__c = PSProject.id;
        
        AppBooking.PropStrength__Booking_Date__c = system.today();
        insert AppBooking;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = AppBooking.Id);
        insert appDetail;
        
        Interim_Payments__c interimPay = new Interim_Payments__c(Application_Booking_Interim__c = AppBooking.Id, Cheque_Bounced_Interim__c = false, Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay;

        PageReference pageRef = Page.ChequeReturnAcknowledgement;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',interimPay.Id);
        ChequeReturnAcknowledgementCntrl crac = new ChequeReturnAcknowledgementCntrl();
    }
}