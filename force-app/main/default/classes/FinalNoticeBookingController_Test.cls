@isTest
public class FinalNoticeBookingController_Test {
    
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
        appBook.Booking_Form_Signed_Date__c = System.today();
        appBook.PropStrength__Applicant_Email__c = 'test@gmail.com';
        insert appBook;
    }


    @isTest
    static void testMethod1() { 
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c LIMIT 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            FinalNoticeBookingController controller = new FinalNoticeBookingController();
        Test.stopTest();
    }
    
    @isTest
    static void testSendFinalNotice() { 
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c LIMIT 1];
        Test.startTest();
            FinalNoticeBookingController.sendFinalNotice(psab.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSendForfeitureNotice() { 
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c LIMIT 1];
        Test.startTest();
            FinalNoticeBookingController.sendForfeitureNotice(psab.Id);
        Test.stopTest();
    }
    
    
}