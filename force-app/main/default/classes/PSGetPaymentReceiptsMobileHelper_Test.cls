@isTest
public class PSGetPaymentReceiptsMobileHelper_Test {
    @isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;    
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',Do_Not_Send_Reminder__c = false);
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true,PropStrength__Tower__c = tower.Id,DLD_Admin_Fees__c = 5);
        insert prop;        
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        insert acc;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Status__c = 'Approved';
        pr.Enquiry__c = enq.Id;
        insert pr;
        
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Payment_Request_1__c = pr.Id,PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, Additional_Discount_Given__c = true, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,DLD_Amount__c =1);
        insert offer;
        
        Test.startTest();      

        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Broker_Account__c = acc.Id,PropStrength__Primary_Customer__c = cont.Id,PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
         PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1000,GL_Date__c = System.today());
        insert pay;
        
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
        insert AppBooking;
        
        Interim_Payments__c interimPay = new Interim_Payments__c(Approval_Status_Interim__c = 'UnProcessed',RecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), Interim_Payment_Type__c = 'Payment Request',
          Application_Booking_Interim__c = AppBooking.Id, Cheque_Bounced_Interim__c = false, Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"bookingId":"' + book.Id + '"}');

        PSGetPaymentReceiptsMobileHelper.GetPaymentReceiptsMobile(req); 
        
        Test.stopTest(); 
    }
    @isTest
    static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        Account acc = TestDataFactorySobha.createAccount(null); 
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
         Test.startTest();
         PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = con.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        
        insert enq;
        
       
        
        PropStrength__Projects__c pro = TestDataFactorySobha.createProject(null);
        insert pro;
       
        
        PropStrength__Property_Type__c type = TestDataFactorySobha.createPropertyType(null);
        insert type;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Request__c reqs = TestDataFactorySobha.createEnquiry(null);
        insert reqs;
        PropStrength__Property__c property = TestDataFactorySobha.createProperty(null);
        insert property;
        PropStrength__Payment_Plan__c plan = TestDataFactorySobha.createPaymentPlan(null);
        insert plan;
        
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        
        
        PropStrength__Brokerage_Scheme__c broker = TestDataFactorySobha.createBrokerageScheme(null);
        insert broker;
        PropStrength__Application_Booking__c res = TestDataFactorySobha.createApplicationBooking(null);
        insert res;
        
         Payment_Request__c pr = new Payment_Request__c();
        pr.Mode__c = 'Credit Card';
        pr.Status__c = 'Approved';
        pr.Enquiry__c = enq.Id;
        pr.Application_Booking__c = res.Id;
        insert pr;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"bookingId":"' + res.Id + '"}');

        PSGetPaymentReceiptsMobileHelper.GetPaymentReceiptsMobile(req); 
        
        Test.stopTest(); 
    }
    
    @isTest
    static void testMethod3() { 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        Account acc = TestDataFactorySobha.createAccount(null); 
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        Test.startTest();
         PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
       
        PropStrength__Projects__c pro = TestDataFactorySobha.createProject(null);
        insert pro;
       
        PropStrength__Property_Type__c type = TestDataFactorySobha.createPropertyType(null);
        insert type;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Request__c reqs = TestDataFactorySobha.createEnquiry(null);
        insert reqs;
        PropStrength__Property__c property = TestDataFactorySobha.createProperty(null);
        insert property;
        PropStrength__Payment_Plan__c plan = TestDataFactorySobha.createPaymentPlan(null);
        insert plan;
        
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        
        
        PropStrength__Brokerage_Scheme__c broker = TestDataFactorySobha.createBrokerageScheme(null);
        insert broker;
        PropStrength__Application_Booking__c res = TestDataFactorySobha.createApplicationBooking(null);
        insert res;
        
       
        
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
        insert AppBooking;
        
        Interim_Payments__c interimPay = new Interim_Payments__c(Approval_Status_Interim__c = 'UnProcessed',RecordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), Interim_Payment_Type__c = 'Payment Request',
        Application_Booking_Interim__c = res.Id, Cheque_Bounced_Interim__c = false, Interim_Receipt_sent_to_customer__c = false, Receipt_Reversed_Interim__c = false, Submit_for_Check_Hold__c = false, Submit_for_Cheque_Replacement_Approval__c = false);
        insert interimPay;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"bookingId":"' + res.Id + '"}');

        PSGetPaymentReceiptsMobileHelper.GetPaymentReceiptsMobile(req); 
        
        Test.stopTest(); 
    }
  @isTest
    static void testPSGetPaymentReceiptsMobile_MissingBookingId() {
        String requestBody = '{}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        
        Test.startTest();
        PSGetPaymentReceiptsMobileHelper.GetPaymentReceiptsMobile(req); 
        Test.stopTest();
    }
  

    
}