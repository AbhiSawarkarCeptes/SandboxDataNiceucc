@isTest
public class ApplicationBookingCallDetailTrigHelpTest {
    @testSetup
    static void setupTestData() {
        // Create a test Application Booking
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
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
        insert appBook;

        // Create Application Booking Call Detail records
        List<Application_Booking_Call_Detail__c> callDetails = new List<Application_Booking_Call_Detail__c>();
        callDetails.add(new Application_Booking_Call_Detail__c(Application_Booking__c = appBook.Id, Call_Update__c = 'Not Contactable', Call_Date_Time__c = DateTime.now()));
        callDetails.add(new Application_Booking_Call_Detail__c(Application_Booking__c = appBook.Id, Call_Update__c = 'No Response', Call_Date_Time__c = DateTime.now()));
        insert callDetails; 
    }
    
    @isTest
    static void testUpdateNumberOnBooking() {
        // Retrieve the test data
        List<Application_Booking_Call_Detail__c> callDetails = [SELECT Id, Application_Booking__c, Call_Update__c FROM Application_Booking_Call_Detail__c];
        
        // Call the method to test
        Test.startTest();
        ApplicationBookingCallDetailTrigHelper.updateNumberOnBooking(callDetails);
        Test.stopTest();
        
        }

    @isTest
    static void testUpdateNumberOnBookingOnUpd() {
        // Retrieve the test data
        List<Application_Booking_Call_Detail__c> callDetails = [SELECT Id, Application_Booking__c, Call_Update__c FROM Application_Booking_Call_Detail__c where Call_Update__c = 'Not Contactable'];
        // Simulate an update by changing the call status
        callDetails[0].Call_Update__c = 'No Response';
        
        // Call the method to test
        Test.startTest();
        update callDetails;
        Test.stopTest(); 
       }

    @isTest
    static void testUpdateLastNonContDtTime() {
        // Retrieve the test data
        List<Application_Booking_Call_Detail__c> callDetails = [SELECT Id, Application_Booking__c, Call_Date_Time__c, Call_Update__c FROM Application_Booking_Call_Detail__c];
        
        // Call the method to test
        Test.startTest();
        ApplicationBookingCallDetailTrigHelper.updateLastNonContDtTime(callDetails);
        Test.stopTest();
        }
}