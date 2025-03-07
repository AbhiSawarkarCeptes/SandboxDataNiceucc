@isTest
public class CRMDashboardControllerClone_Test {
    @isTest
    static void testMethod1(){
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
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.Cancellation_Allocation__c = 'Allocate to CRM Team';
        appBook.PropStrength__Status__c = 'Audit Approved';
        appBook.PropStrength__Active__c = true;
        appBook.Termination_Process_Status__c = 'Allocated to CRM Team';
        insert appBook;
        PropStrength__Milestone_Group__c milestonegrp = TestDataFactorySobha.createMilestoneGroup(null);
        insert milestonegrp;
        
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c payplan = TestDataFactorySobha.createPaymentPlanDetail(null);
        payplan.PropStrength__Is_Milestone_Completed__c = true;
        insert payplan;
        
        PropStrength__Received_Payment__c recvpay = TestDataFactorySobha.createPayment(null);
        insert recvpay;
        CRMDashboardControllerClone.getProjects();
        CRMDashboardControllerClone.getPickListValuesIntoList();
        CRMDashboardControllerClone.getBookings(proj.Id,'ALL','Dashboard1');
        String raw = '{"bookingId":"'+appBook.Id+'","label":"cancellationAllocation","cancellationAllocation":"Allocate to CRM Team","commentsremarks":"'+String.valueof(Date.today())+'","finalNoticeSentDateCourier":"'+String.valueof(Date.today())+'","finalNoticeReceivedDate":"'+String.valueof(Date.today())+'","forfeitureNoticeSentDateCourier":"'+String.valueof(Date.today())+'","forfeitedAmount":456}';
        CRMDashboardControllerClone.updateBookingRow(raw,true,true,'cancelComments');
        Test.StopTest();
    }
    @isTest
    static void testMethod2(){
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
        insert proj;
        
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Tower__c = tower.Id;
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
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.Cancellation_Allocation__c = 'Allocate to CRM Team';
        insert appBook;
        PropStrength__Milestone_Group__c milestonegrp = TestDataFactorySobha.createMilestoneGroup(null);
        insert milestonegrp;
        
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c payplan = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert payplan;
        
        PropStrength__Received_Payment__c recvpay = TestDataFactorySobha.createPayment(null);
        insert recvpay;
        CRMDashboardControllerClone.getProjects();
        CRMDashboardControllerClone.getPickListValuesIntoList();
        CRMDashboardControllerClone.getBookings(proj.Id,tower.Id,'Dashboard2');
        CRMDashboardControllerClone.getBookings(proj.Id,tower.Id,'Dashboard3');
        String raw = '[{"bookingId":"'+appBook.Id+'","label":"cancellationAllocation","cancellationAllocation":"Allocate to CRM Team","commentsremarks":"'+String.valueof(Date.today())+'","finalNoticeSentDateCourier":"'+String.valueof(Date.today())+'","finalNoticeReceivedDate":"'+String.valueof(Date.today())+'","forfeitureNoticeSentDateCourier":"'+String.valueof(Date.today())+'","forfeitedAmount":456}]';
        CRMDashboardControllerClone.updateBookingRow(raw,false,true,'cancelComments');
        CRMDashboardControllerClone.updateAllocation(appBook.Id,'Allocate to CRM Team');
        Test.StopTest();
    }
}