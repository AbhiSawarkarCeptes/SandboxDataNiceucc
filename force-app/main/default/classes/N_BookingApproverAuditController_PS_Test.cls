@isTest public class N_BookingApproverAuditController_PS_Test {

    @testSetup 
    static void createData(){
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        Contact con = TestDataFactorySobha.createContact(null);
        insert con;

        PropStrength__Assignment_Group_Name__c assgmtGroup = TestDataFactorySobha.createAssignmentGroup(null);
        insert assgmtGroup;

        PropStrength__Request__c request = TestDataFactorySobha.createEnquiry(null);
        insert request;
        
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;

        PropStrength__Property__c property = TestDataFactorySobha.createProperty(null);
        insert property;
        
        PropStrength__Payment_Plan__c paymentPlan = TestDataFactorySobha.createPaymentPlan(null);
        insert paymentPlan;

        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;

        PropStrength__Brokerage_Scheme__c brokerageScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brokerageScheme;
    }
    
    @isTest static void getBookingList1(){
        PropStrength__Application_Booking__c appBookObj = TestDataFactorySobha.createApplicationBooking(null);
        appBookObj.Booking_Approver_Audit__c = 'Not Started';
        appBookObj.Verification_status__c = 'Accepted';
        appBookObj.PropStrength__Status__c = 'Booking In Process';
        appBookObj.Select_All_Audit__c = true;
        insert appBookObj;

        Test.startTest();
        N_BookingApproverAuditController_PS approverCont = new N_BookingApproverAuditController_PS();
        approverCont.Save();
        approverCont.Back();
        Test.stopTest();
    }
    
    @isTest static void getBookingList3(){
        PropStrength__Application_Booking__c appBookObj = TestDataFactorySobha.createApplicationBooking(null);
        appBookObj.Booking_Approver_Audit__c = 'Rejected';
        appBookObj.Verification_status__c = 'Accepted';
        appBookObj.PropStrength__Status__c = 'Booking In Process';
        appBookObj.Select_All_Audit__c = true;
        insert appBookObj;

        Test.startTest();
        N_BookingApproverAuditController_PS approverCont = new N_BookingApproverAuditController_PS();
        approverCont.lstBooking = new List<PropStrength__Application_Booking__c>{appBookObj};
        approverCont.Save();
        Test.stopTest();
    }

}