/*********************************************************************
 * Class Name  :   InterimPaymentsTriggerHandler_Test
 * Description :   Test class for the InterimPaymentsTriggerHandler Class
 * Created Date:   20/06/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 20/06/2023
 *********************************************************************/
@isTest
public class InterimPaymentsTriggerHandler_Test {
	@isTest
    static void testMethod1() {
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
        
        PropStrength__Application_Booking__c AppBooking = new PropStrength__Application_Booking__c ();
        AppBooking.PropStrength__Project__c = PSProject.id;
        AppBooking.PropStrength__Booking_Date__c = system.today();
        insert AppBooking;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = AppBooking.Id);
        insert appDetail;
        
        Contact cont1 = new Contact();
        cont1.FirstName = 'Test1' + DateTime.now();
        cont1.LastName = 'testKYCForm1';
        cont1.Email = 'test@test1.com';
        insert cont1;
        List<PropStrength__Income_Charges__c> icList = new List<PropStrength__Income_Charges__c>();
        icList.add(new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, 
                                                       PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, 
                                                       RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), 
                                                       PropStrength__Project__c=PSProject.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', 
                                                       PropStrength__Category__c = 'Transfer Of Property', Display_on_Quotation__c = true));
        icList.add(new PropStrength__Income_Charges__c(Name='DLD Fees',PropStrength__Rate_Per_Unit_Area__c = 0.0, PropStrength__Income_Charge_Code__c = 'DLD Fees', 
                                                       PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, 
                                                       RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Flexible').getRecordTypeId(), 
                                                       PropStrength__Project__c=PSProject.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Flexible', 
                                                       PropStrength__Category__c = 'Cheque Bouncing Charges', Display_on_Quotation__c = true,Charge__c = 5));
        insert icList;
        PropStrength__Applicant_Detail__c appDetail1 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont1.Id,PropStrength__Type__c = '2nd Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = AppBooking.Id); 
        insert appDetail1;        
        Interim_Payments__c interimPay = new Interim_Payments__c(RecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), Interim_Payment_Type__c = 'Payment Request',Application_Booking_Interim__c = AppBooking.Id, Cheque_Bounced_Interim__c = false, Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay;
        
        Interim_Payments__c interimPay1 = new Interim_Payments__c(RecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId(), Interim_Payment_Type__c = 'Payment Request',Application_Booking_Interim__c = AppBooking.Id, Cheque_Bounced_Interim__c = false, Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay1;
        
        Interim_Payments__c interimPay2 = new Interim_Payments__c(RecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId(), Interim_Payment_Type__c = 'Payment Request',Application_Booking_Interim__c = AppBooking.Id, Cheque_Bounced_Interim__c = true,Bounced_Reason__c = 'Insufficient Funds', Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay2;
        
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Trade Receivable';
        insert am2;
        
        interimPay.Submit_for_Check_Hold__c = TRUE;
        interimPay.Approval_Status_Interim__c = 'Approved';
        interimPay.GL_Date__c = System.today();
        interimPay.Credit_Account__c = am2.id;
        interimPay.Debit_Account__c = am2.id;
        update interimPay;
        interimPay.Approval_Status_Interim__c = 'Rejected';
        interimPay.Cheque_Bounced_Interim__c = TRUE;
        interimPay.Bounced_Reason__c = 'Insufficient Funds';
        update interimPay;
        
        interimPay1.Submit_for_Check_Hold__c = TRUE;
        interimPay1.Approval_Status_Interim__c = 'Approved';
        interimPay1.GL_Date__c = System.today();
        interimPay1.Credit_Account__c = am2.id;
        interimPay1.Debit_Account__c = am2.id;
        update interimPay1;
        interimPay1.Approval_Status_Interim__c = 'Rejected';
        interimPay1.Cheque_Bounced_Interim__c = TRUE;
        interimPay1.Bounced_Reason__c = 'Insufficient Funds';
        update interimPay1;
    }
    
    @isTest
    static void testMethod2() {
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
        
        PropStrength__Application_Booking__c AppBooking = new PropStrength__Application_Booking__c ();
        AppBooking.PropStrength__Project__c = PSProject.id;
        AppBooking.PropStrength__Booking_Date__c = system.today();
        insert AppBooking;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = AppBooking.Id);
        insert appDetail;
        
        Contact cont1 = new Contact();
        cont1.FirstName = 'Test1' + DateTime.now();
        cont1.LastName = 'testKYCForm1';
        cont1.Email = 'test@test1.com';
        insert cont1;
        
        PropStrength__Applicant_Detail__c appDetail1 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont1.Id,PropStrength__Type__c = '2nd Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = AppBooking.Id); 
        insert appDetail1;  
        List<PropStrength__Income_Charges__c> icList = new List<PropStrength__Income_Charges__c>();
        icList.add(new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, 
                                                       PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, 
                                                       RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), 
                                                       PropStrength__Project__c=PSProject.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', 
                                                       PropStrength__Category__c = 'Transfer Of Property', Display_on_Quotation__c = true));
        icList.add(new PropStrength__Income_Charges__c(Name='DLD Fees',PropStrength__Rate_Per_Unit_Area__c = 0.0, PropStrength__Income_Charge_Code__c = 'DLD Fees', 
                                                       PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, 
                                                       RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Flexible').getRecordTypeId(), 
                                                       PropStrength__Project__c=PSProject.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Flexible', 
                                                       PropStrength__Category__c = 'Cheque Bouncing Charges', Display_on_Quotation__c = true,Charge__c = 5));
        insert icList;
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Trade Receivable';
        insert am2;
        list<Payment_Request__c> uh1 = new list<Payment_Request__c>();
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C ='OTC Deposits';
        //uh.Unit__c = u.id;
        uh.Status__c ='Approved';
        uh.Mobile_Number__c = '9876543210';
        uh.Enquiry_Source__c = 'Web';
        uh.Sales_Manager__c = UserInfo.getUserId();
        //uh.Property__c = prop.id;
        uh1.add(uh);
        insert uh1;
        Interim_Payments__c interimPay = new Interim_Payments__c(RecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), Payment_Date_Interim__c = System.today(),
                                                                Payment_Request__c=uh1[0].id,  Approval_Status_Interim__c = 'Approved', GL_Date__c = System.today(), Credit_Account__c = am2.id, Debit_Account__c = am2.id,Interim_Payment_Type__c = 'Payment Request',Application_Booking_Interim__c = AppBooking.Id, Cheque_Bounced_Interim__c = false, Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay;
        
        Interim_Payments__c interimPay1 = new Interim_Payments__c(RecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId(), 
                                                                  Interim_Payment_Type__c = 'Payment Request',Application_Booking_Interim__c = AppBooking.Id, Payment_Date_Interim__c = System.today(),
                                                                  Approval_Status_Interim__c = 'Approved', GL_Date__c = System.today(), Credit_Account__c = am2.id, Debit_Account__c = am2.id,
                                                                  Payment_Request__c=uh1[0].id,Cheque_Bounced_Interim__c = false, Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, 
                                                                  Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay1;
        interimPay1.Approval_Status_Interim__c = 'Submitted for Cheque Hold';
        interimPay1.Submit_for_Check_Hold__c = true;
        update interimPay1;
        interimPay1.Approval_Status_Interim__c = 'Cheque Hold Approved';
        interimPay1.Submit_for_Check_Hold__c = true;
        update interimPay1;
        interimPay1.Approval_Status_Interim__c = 'Submitted for Cheque Replacement';
        interimPay1.Submit_for_Check_Hold__c = true;
        interimPay1.Submit_for_Cheque_Replacement_Approval__c = true;
        update interimPay1;
        interimPay1.Approval_Status_Interim__c = 'Cheque Replacement Approved';
        interimPay1.Submit_for_Cheque_Replacement_Approval__c = true;
        interimPay1.Submit_for_Check_Hold__c = true;
        update interimPay1;
        
       
        
        
    }
}