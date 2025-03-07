@isTest
public class QRCodeUtility_Copy_Test {
    @isTest
    static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.Birthdate = System.Today();
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        proj.Customer_Care_Email_ID__c = 'crmops@sobharealty.com';
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        Test.StartTest();
        PropStrength__Milestone_Group__c milestonegrp = TestDataFactorySobha.createMilestoneGroup(null);
        insert milestonegrp;
        
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c payplan = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert payplan;
        
        PropStrength__Received_Payment__c recvpay = TestDataFactorySobha.createPayment(null);
        insert recvpay;
        
        PropStrength__Projects__c PSProject = new PropStrength__Projects__c ();
        PSProject .name = 'Tomar';
        PSProject.Do_Not_Raise_Demand__c = true;
        PSProject.Do_Not_Send_Reminder__c = true;
        PSProject.PropStrength__Active__c = true;
        PSProject.Customer_Care_Email_ID__c = 'crmops@sobharealty.com';
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
        insert AppBooking;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = AppBooking.Id);
        insert appDetail;
        
        Contact cont1 = new Contact();
        cont1.FirstName = 'Test' + DateTime.now();
        cont1.LastName = 'testKYCForm';
        cont1.Email = 'test@test.com';
        insert cont1;
        
        
        Interim_Payments__c interimPay = new Interim_Payments__c(RecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), Interim_Payment_Type__c = 'Payment Request',Application_Booking_Interim__c = AppBooking.Id, Cheque_Bounced_Interim__c = false, Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay;
        QRCodeUtility_Copy.getQrDataFor(enq.Id);
        QRCodeUtility_Copy.getQrDataFor(interimPay.Id);
        Test.StopTest();
    }
}