@isTest
public class Demand_LetterController_Test {
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
        appBook.PropStrength__Project__c = proj.Id;
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
        PropStrength__Tax_Record__c tr = new PropStrength__Tax_Record__c(PropStrength__Tax_Type__c = 'VAT', PropStrength__Tax_Percentage_Aftr_limit__c = 15, PropStrength__Tax_Percentage__c = 15, PropStrength__Start_Date__c = System.Today(), PropStrength__PMAY_GST__c = 10, PropStrength__Abatement_Rate__c = 10, PropStrength__End_Date__c = System.Today().addDays(30), PropStrength__New_Tax_Percentage_After_Set_Limit__c = 10, PropStrength__New_Tax_Percentage__c = 10, PropStrength__New_PMAY_GST__c = 10);
        insert tr;
        ApexPages.currentPage().getParameters().put('id', recvpay.Id);
        Demand_LetterController dmd = new Demand_LetterController();
        dmd.paymentId = 'Test';
        dmd.payList = null;
        dmd.AppDetailLst = null;
        Test.StopTest();
        
    }
}