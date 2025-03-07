@isTest
public class PSGetPaymentPlanMobileHelperTest {

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
        payPlanDetails.PropStrength__Payment_Due_Date__c = Date.today();
        insert payPlanDetails;
        
        PropStrength__Other_Charges_Percentage__c psOtherCharges = new PropStrength__Other_Charges_Percentage__c(); 
        psOtherCharges.PropStrength__Payment_Plan_Detail__c = payPlanDetails.Id;
        psOtherCharges.PropStrength__Amount__c = 2000;
        insert psOtherCharges;
        
    
    }

    @isTest
    static void testGetPaymentPlanMobile_ValidData() {
        // Create test data
        PropStrength__Application_Booking__c pc = [SELECT ID FROM PropStrength__Application_Booking__c LIMIT 1];
           
        // Create a mock request
        String requestBody = '{"bookingId":"' + pc.Id + '"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        
        // Call the method
        Test.startTest();
        String response = PSGetPaymentPlanMobileHelper.GetPaymentPlanMobile(req);
        Test.stopTest();
    }

    @isTest
    static void testGetPaymentPlanMobile_MissingBookingId() {
        // Create a mock request with missing bookingId
        String requestBody = '{}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        
        // Call the method
        Test.startTest();
        String response = PSGetPaymentPlanMobileHelper.GetPaymentPlanMobile(req);
        Test.stopTest();
    }

    @isTest
    static void testGetPaymentPlanMobile_NoPaymentPlanDetails() {
        // Create a mock request with a non-existing bookingId
        String requestBody = '{"bookingId":"NonExistingBookingId"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        
        // Call the method
        Test.startTest();
        String response = PSGetPaymentPlanMobileHelper.GetPaymentPlanMobile(req);
        Test.stopTest();
    }

    @isTest
    static void testGetPaymentPlanMobile_ExceptionHandling() {
        // Create a mock request with invalid JSON
        String requestBody = '{"invalidJson';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        
        // Call the method
        Test.startTest();
        String response = PSGetPaymentPlanMobileHelper.GetPaymentPlanMobile(req);
        Test.stopTest();
    }

    @isTest
    static void testLogError() {
        // Create test data that will generate an error log
        String requestBody = '{"bookingId":"TestBookingId"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        
        Test.startTest();
        // Call the method
        String response = PSGetPaymentPlanMobileHelper.GetPaymentPlanMobile(req);
        Test.stopTest();
        
        // Check the Mobile_App_Log__c records
        List<Mobile_App_Log__c> logs = [SELECT Id, Response_Body__c, Status__c FROM Mobile_App_Log__c];
    }
}