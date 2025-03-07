@isTest
public class ReceiptModulePSController_Test {

    @testSetup
    static void setup() {
        
   		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
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
        prop.PropStrength__Unit_Status__c = 'SOLD';
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
        appBook.PropStrength__Property__c = prop.id;
        insert appBook;
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        insert appDetail;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        pay.RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        pay.PropStrength__Payment_Type__c = 'Cash';
        pay.PropStrength__Application_Booking__c =  appBook.id;
         pay.Currency__c = 'AED';
        insert pay;
    }

    @isTest
    static void testConstructor() {
        // Set up the page parameters
        Test.setCurrentPage(Page.ReceiptModule_PS); 
        PropStrength__Received_Payment__c pay = [Select id, Currency__c, PropStrength__Payment_Type__c, PropStrength__Bank_Name__c, Instrument_Number__c, Drawee_Bank_If_Others__c, PropStrength__Application_Booking__c, Receipt_Status__c, Drawn_in_favour_of__c from PropStrength__Received_Payment__c pay limit 1];
        ApexPages.currentPage().getParameters().put('id', pay.id); 

        // Initialize the controller
        ReceiptModulePSController controller = new ReceiptModulePSController();
    }

    @isTest
    static void testGetCustomerDetails() {
        // Set up the page parameters
        PropStrength__Received_Payment__c payment = [SELECT Id,Currency__c, PropStrength__Payment_Type__c, PropStrength__Bank_Name__c, Instrument_Number__c, Drawee_Bank_If_Others__c, PropStrength__Application_Booking__c, Receipt_Status__c, Drawn_in_favour_of__c FROM PropStrength__Received_Payment__c LIMIT 1];
        Test.setCurrentPage(Page.ReceiptModule_PS);
        ApexPages.currentPage().getParameters().put('id', payment.Id);

        // Initialize the controller
        ReceiptModulePSController controller = new ReceiptModulePSController();

        // Call the getCustomerDetails method
        controller.getCustomerDetails();        
    }

    @isTest
    static void testApplyReceipt() {
        // Set up the page parameters
        PropStrength__Received_Payment__c payment = [SELECT Id, Currency__c, PropStrength__Payment_Type__c, PropStrength__Bank_Name__c, Instrument_Number__c, Drawee_Bank_If_Others__c, PropStrength__Application_Booking__c, Receipt_Status__c, Drawn_in_favour_of__c FROM PropStrength__Received_Payment__c LIMIT 1];
        Test.setCurrentPage(Page.ReceiptModule_PS);
        ApexPages.currentPage().getParameters().put('id', payment.Id);

        // Initialize the controller
        ReceiptModulePSController controller = new ReceiptModulePSController();

        // Call the applyReceipt method
        Test.startTest();
        controller.applyReceipt();
        Test.stopTest();
    }

    @isTest
    static void testSaveReceipt() {
        // Set up the page parameters
        PropStrength__Received_Payment__c payment = [SELECT Id,RecordType.Name, Currency__c, PropStrength__Payment_Type__c, PropStrength__Bank_Name__c, Instrument_Number__c, Drawee_Bank_If_Others__c, PropStrength__Application_Booking__c, Receipt_Status__c, Drawn_in_favour_of__c FROM PropStrength__Received_Payment__c where recordtype.name = 'Payment Received' LIMIT 1];
        Test.setCurrentPage(Page.ReceiptModule_PS);
        ApexPages.currentPage().getParameters().put('id', payment.Id);

        // Initialize the controller
        ReceiptModulePSController controller = new ReceiptModulePSController();
		controller.adjustmentFlow = true;
        controller.moneyInHand = 1000;
        // Call the applyReceipt method to set up data
        controller.applyReceipt();

        // Call the saveReceipt method
        Test.startTest();
        controller.saveReceipt();
        Test.stopTest();
    }

    @isTest
    static void testAdvanceReceipt() {
        PropStrength__Application_Booking__c appBook = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        // Set up the page parameters
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        pay.RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        pay.PropStrength__Payment_Type__c = 'Cash';
        pay.PropStrength__Application_Booking__c =  appBook.id;
         pay.Currency__c = 'AED';
        insert pay;
        
        PropStrength__Received_Payment__c payDue = TestDataFactorySobha.createPayment(null);
        payDue.RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId();
        payDue.PropStrength__Payment_Type__c = 'Cash';
        payDue.PropStrength__Application_Booking__c =  appBook.id;
         payDue.Currency__c = 'AED';
        insert payDue;
        PropStrength__Received_Payment__c payment = [SELECT Id, Currency__c, PropStrength__Payment_Type__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Bank_Name__c, Instrument_Number__c, Drawee_Bank_If_Others__c, PropStrength__Application_Booking__c, Receipt_Status__c, Drawn_in_favour_of__c FROM PropStrength__Received_Payment__c WHERE Id = :pay.Id LIMIT 1];
        Test.setCurrentPage(Page.ReceiptModule_PS);
        ApexPages.currentPage().getParameters().put('id', payment.Id);

        // Initialize the controller
        ReceiptModulePSController controller = new ReceiptModulePSController();

        // Set the moneyInHand to simulate a payment scenario
        controller.moneyInHand = 500;
        controller.rmw.r = payment;
        controller.receiptId = payment.Id;
        
		controller.adjustmentFlow = true;
        controller.moneyInHand = 1000;

        // Call the advanceReceipt method
        Test.startTest();
        
        // Call the applyReceipt method to set up data
        controller.applyReceipt();
        controller.advanceReceipt();
        controller.saveReceipt();
        Test.stopTest();
    }
}