@isTest
public class BookingHandoverController_Test {
    
    @testSetup
    static void setupData() {
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
        appBook.PropStrength__Primary_Customer__c = cont.Id;
        appBook.PropStrength__Applicant_Email__c = 'test@gmail.com';
        appBook.SPA_Executed__c = true;
        appBook.Pre_Registration_Completed__c = true;
        appBook.Home_Orientation_Date__c = Date.today();
        appBook.Unit_Readiness_Date__c = Date.today();
        appBook.Unit_Handover_Date__c = Date.today();
        insert appBook;
        
        PropStrength__Application_Booking__c appBook2 = TestDataFactorySobha.createApplicationBooking(null);
        appBook2.Booking_Form_Signed_Date__c = System.today();
        appBook2.PropStrength__Primary_Customer__c = cont.Id;
        appBook2.PropStrength__Applicant_Email__c = 'test@gmail.com';
        appBook2.SPA_Executed__c = FALSE;
        appBook2.Pre_Registration_Completed__c = FALSE;
        insert appBook2;
        Test.StopTest();
    }
    
    @isTest
    static void testMethod1() {
        
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c LIMIT 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            BookingHandoverController controller = new BookingHandoverController();
        Test.stopTest();
    }
    
    
    @isTest
    static void testMethod2() {
        
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = FALSE LIMIT 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            BookingHandoverController controller = new BookingHandoverController();
        controller.recOrInv();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod3() {
        
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = FALSE LIMIT 1];
        psab.HO_Appointment_Exception__c = False;
        Test.startTest();
            update psab;
            ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            BookingHandoverController controller = new BookingHandoverController();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod4() {
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = TRUE LIMIT 1];
        psab.HO_Appointment_Exception__c = False;
        psab.Pre_Registration_Completed__c = False;
        Test.startTest();
            update psab;
            ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            BookingHandoverController controller = new BookingHandoverController();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod5() {
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = TRUE LIMIT 1];
        psab.HO_Appointment_Exception__c = False;
        psab.Home_Orientation_Date__c = null;
        Test.startTest();
            update psab;
            ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            BookingHandoverController controller = new BookingHandoverController();
        Test.stopTest();
    }
   /* 
    @isTest
    static void testMethod6() {
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = TRUE LIMIT 1];
        psab.HO_Appointment_Exception__c = False;
        psab.Unit_Handover_Date__c = null;
        Test.startTest();
            update psab;
            ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            BookingHandoverController controller = new BookingHandoverController();
        Test.stopTest();
    }
    */
    
    @isTest
    static void testMethod7() {
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = TRUE LIMIT 1];
        psab.HO_Appointment_Exception__c = False;
        psab.Handover_Notice_Sent__c = True;
        Test.startTest();
            update psab;
            ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            BookingHandoverController controller = new BookingHandoverController();
        Test.stopTest();
    }
    
    @isTest
    static void testSaveDocFile() {
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = TRUE LIMIT 1];
        BookingHandoverController controller = new BookingHandoverController();
        controller.recId = psab.Id;
        controller.typeCode = 'HandoverNotice';

        Test.startTest();
        PageReference result = controller.saveDocFile();
        Test.stopTest();
    }
    
    @isTest
    static void testBackToRecPage() {
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = TRUE LIMIT 1];
        BookingHandoverController controller = new BookingHandoverController();
        controller.recId = psab.Id;
        controller.typeCode = 'HandoverNotice';

        // Call the method
        Test.startTest();
        PageReference result = controller.backToRecPage();
        Test.stopTest();
    }
    
   /* @isTest
    static void testRecOrInv() {
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = TRUE LIMIT 1];
        BookingHandoverController controller = new BookingHandoverController();
        controller.recId = psab.Id;
        controller.typeCode = 'HandoverNotice';

        Test.startTest();
        PageReference result = controller.recOrInv();
        Test.stopTest();
    }*/
    
 /*   @isTest
    static void testSendHandoverNoticeEmail() {
        List<PropStrength__Application_Booking__c> psab = [SELECT Id FROM PropStrength__Application_Booking__c WHERE SPA_Executed__c = TRUE LIMIT 1];
        Contact con = [SELECT Id,Email,Name FROM CONTACT LIMIT 1];
        Map<String, String> emailNameMap = new Map<String, String>{con.Email => con.Name};  
        
              
        ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
        ApexPages.currentPage().getParameters().put('id', psab.Id);
        BookingHandoverController controller = new BookingHandoverController();
    //    controller.recId = psab[0].Id;
       // controller.record = psab;
        //controller.toAddressMap = emailNameMap;      

        Test.startTest();
        controller.sendHandoverNoticeEmail();
        Test.stopTest();
    }*/
    
    @isTest
    static void testSendHandoverNoticeEmail() {
        
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c LIMIT 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            BookingHandoverController controller = new BookingHandoverController();
            controller.sendHandoverNoticeEmail();
        Test.stopTest();
    }
    
    @isTest
    static void testSendHandoverNoticeEmail2() {  
        PropStrength__Application_Booking__c psab = [SELECT ID FROM PropStrength__Application_Booking__c LIMIT 1];
        psab.Handover_will_be_taken_by__c = 'POA – Owner';
        psab.POA_Email_Address__c = 'test@gmail.com';
      
        Test.startTest();
            update psab;
            ApexPages.currentPage().getParameters().put('type', 'HandoverNotice');
            ApexPages.currentPage().getParameters().put('id', psab.Id);
            BookingHandoverController controller = new BookingHandoverController();
            controller.sendHandoverNoticeEmail();
        Test.stopTest();
    }
    
    
}