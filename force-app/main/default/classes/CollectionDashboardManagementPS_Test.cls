@isTest
public class CollectionDashboardManagementPS_Test {

    @testSetup
    static void setupData() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.Investor_Unit__c = true;
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        PropStrength__Milestone_Group__c milstoneGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert milstoneGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        insert payPlanDetails;
        
        PropStrength__Payment_Plan_Details__c payPlanDetail = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetail.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetail.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetail.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        insert payPlanDetail;
        
        PropStrength__Other_Charges_Percentage__c psOtherCharges = new PropStrength__Other_Charges_Percentage__c(); 
        psOtherCharges.PropStrength__Payment_Plan_Detail__c = payPlanDetails.Id;
        psOtherCharges.PropStrength__Amount__c = 2000;
        insert psOtherCharges;

    }

    @isTest
    static void testGetYearList() {
      Test.StartTest();
         List<String> yearList = CollectionDashboardManagementPS.getYearList();
      Test.StopTest();
    }
    
    @isTest
    static void testGetAllTabData1() {    
      Test.StartTest();
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('Project', '');
      Test.StopTest();
    }

    @isTest
    static void testGetAllTabData2() {
      Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.PropStrength__Status__c = 'Audit Approved';
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        appBook1.PropStrength__Status__c = 'Audit Approved';
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('Project', '');
      Test.StopTest();
    }
    
      
    @isTest
    static void testGetAllTabData3() {    
      Test.StartTest();
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('SubProject', '');
      Test.StopTest();
    }
    
    @isTest
    static void testGetAllTabData() {    
      Test.StartTest();
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('SubProject', 'All');
      Test.StopTest();
    }
    
    
    @isTest
    static void testGetAllTabData5() {
      Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.PropStrength__Status__c = 'Audit Approved';
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        appBook1.PropStrength__Status__c = 'Audit Approved';
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('SubProject', 'All');
      Test.StopTest();
    }
    
    
    @isTest
    static void testGetAllTabData6() {
      Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.PropStrength__Status__c = 'Audit Approved';
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        appBook1.PropStrength__Status__c = 'Audit Approved';
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('Tower', '');
      Test.StopTest();
    }
    
    @isTest
    static void testGetAllTabData7() {
      Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.PropStrength__Status__c = 'Audit Approved';
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        appBook1.PropStrength__Status__c = 'Audit Approved';
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
        PropStrength__Projects__c proj = [SELECT ID FROM PropStrength__Projects__c LIMIT 1];
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('Tower', String.ValueOf(proj.Id));
      Test.StopTest();
    }
    
    @isTest
    static void testGetAllTabData8() {
      Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.PropStrength__Status__c = 'Audit Approved';
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        appBook1.PropStrength__Status__c = 'Audit Approved';
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('Unit', '');
      Test.StopTest();
    }
    
    @isTest
    static void testGetAllTabData9() {
      Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.PropStrength__Status__c = 'Audit Approved';
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        appBook1.PropStrength__Status__c = 'Audit Approved';
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
        PropStrength__Tower__c proj = [SELECT ID FROM PropStrength__Tower__c LIMIT 1];
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('Unit', String.ValueOf(proj.Id));
      Test.StopTest();
    }
    
    @isTest
    static void testGetAgeingData1() {
      Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.PropStrength__Status__c = 'Audit Approved';
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        appBook1.PropStrength__Status__c = 'Audit Approved';
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
        PropStrength__Tower__c proj = [SELECT ID FROM PropStrength__Tower__c LIMIT 1];
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAgeingData(String.ValueOf(proj.Id));
      Test.StopTest();
    }
    
        @isTest
    static void testGetAllTabData11() {
      Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
         PropStrength__Projects__c proj = [SELECT ID FROM PropStrength__Projects__c LIMIT 1];
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('Tower', String.ValueOf(proj.Id));
      Test.StopTest();
    }
    
    @isTest
    static void testGetAllTabData12() {
      Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('Project', '');
      Test.StopTest();
    }
    
    @isTest
    static void testGetAllTabData13() {
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        PropStrength__Application_Booking__c appBook1 = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook1;
        
        
        PropStrength__Payment_Plan_Details__c payPlanDetails = TestDataFactorySobha.createPaymentPlanDetail(null);
        payPlanDetails.PropStrength__Amount_Percent__c = 70 ;
        payPlanDetails.PropStrength__Amount_Due__c = 1000 ;
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today().addDays(2);
        payPlanDetails.PropStrength__Application_Booking__c = appBook.Id; 
        insert payPlanDetails;
        
    
         List<CollectionDashboardManagementPS.AllWrapper> yearList = CollectionDashboardManagementPS.getAllTabData('SubProject', 'All');
      Test.StopTest();

    }
}