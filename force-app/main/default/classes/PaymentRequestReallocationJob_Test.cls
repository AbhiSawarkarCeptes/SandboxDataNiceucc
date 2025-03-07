@isTest
public class PaymentRequestReallocationJob_Test {
	@istest
    public static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Application_Booking__c AppBooking = new PropStrength__Application_Booking__c ();
        AppBooking.PropStrength__Project__c = proj.id;
        AppBooking.PropStrength__Booking_Date__c = system.today();
        insert AppBooking;
        
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Unit_Status__c = 'Available', Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        uhw.Payment_Order_Number__c = '123456';
        
        insert uhw;
        
        Payment_Request__c uh = new Payment_Request__c();
        uh.mode__C = 'International Wire Transfer';
        uh.Property__c = prop.Id;
        uh.Status__c ='Approved';
        uh.Payment_Request_Wrapper__c = uhw.Id;
        uh.Sales_Manager__c = UserInfo.getUserId();
        uh.Amount__c = 100000;
        uh.Total_Amount__c = 100000;
        uh.Currency__c ='AED';
        uh.Enquiry_Source__c = 'Web';
        uh.Towards_Unit_Price_Amount__c = 1000;
        uh.Towards_Pre_Registration_Amount__c = 1000;
        uh.Towards_Other_Charges_Amount__c = 1000;
        insert uh;
        Interim_Payments__c interimPay = new Interim_Payments__c(Payment_Request__c=uh.Id, RecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), Interim_Payment_Type__c = 'Payment Request',Application_Booking_Interim__c = AppBooking.Id, Cheque_Bounced_Interim__c = false, Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay;
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Reversal payment due', PropStrength__Application_Booking__c = AppBooking.Id, Interim_Payments_Received__c = interimPay.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId(), PropStrength__Amount__c = 1000);
        insert pay;
        PaymentRequestReallocationJob.emitPR_ReallocationEvent(uh.Id);
        PaymentRequestReallocationJob.initiate(new Set<Id>{uh.Id});
        PaymentRequestReallocationJob.initiateProcess(new Set<Id>{uh.Id});
    }
}