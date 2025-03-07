@isTest
private class OnedaybeforeEmailReminder_Sch_Test {
    
    @testSetup
    static void setupTestData() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.Email = 'test@gamil.com';
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
        Test.StartTest();
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
			appBook.Booking_Form_Signed_Date__c = System.today();
			appBook.Slot_Scheduled_Date__c = System.today();
			appBook.Previous_Slot_Date__c = System.today();  
			appBook.PropStrength__Primary_Customer__c = cont.Id;
			appBook.PropStrength__Applicant_Email__c = 'test@gmail.com';
			appBook.SPA_Executed__c = true;
			appBook.Pre_Registration_Completed__c = true;
			appBook.Home_Orientation_Date__c = Date.today();
			appBook.Unit_Readiness_Date__c = Date.today();
			appBook.Unit_Handover_Date__c = Date.today();
        insert appBook;
    }

    @isTest
    static void testScheduler() {
        OnedaybeforeEmailReminder_Sch scheduler = new OnedaybeforeEmailReminder_Sch();
        
        Test.startTest();
        
        String jobId = System.schedule('Test OnedaybeforeEmailReminder_Sch', '0 0 13 * * ?', scheduler);
        
        Test.stopTest();
        
        
    }
   
}