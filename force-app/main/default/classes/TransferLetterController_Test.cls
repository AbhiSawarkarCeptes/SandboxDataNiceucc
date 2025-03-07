@isTest
public class TransferLetterController_Test {
    
    @TestSetup
    static void setup(){
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
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        insert pay;
        PropStrength__Transaction_Requests__c transReq = TestDataFactorySobha.createTransactionRequest(null);
        insert transReq;
        dfsle__EnvelopeStatus__c envelopeStatus = TestDataFactorySobha.createDocusignEnvelopeStatus(null);
        insert envelopeStatus;
    }

    @isTest
    static void testTransferLetterController() {
        PropStrength__Projects__c pp = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        PropStrength__Property_Type__c ppt = [SELECT Id FROM PropStrength__Property_Type__c LIMIT 1];
        PropStrength__Tower__c pt = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];
        PropStrength__Property__c pp2 = [SELECT Id FROM PropStrength__Property__c LIMIT 1];
        

        PropStrength__Application_Booking__c testBooking = new PropStrength__Application_Booking__c(
            PropStrength__Project__c = pp.id,
            PropStrength__Property__c = pp2.Id,
            POA_Name__c = 'POA Test',
            PropStrength__Property_Type__c = ppt.Id,
            Create_SBTR__c = true
        );
        insert testBooking;

        List<PropStrength__Transaction_Requests__c> transactionlist = new List<PropStrength__Transaction_Requests__c>([select id from PropStrength__Transaction_Requests__c]);
        List<Contact> cont = new List<Contact>([SELECT id from Contact]);
        System.debug('Transaction ID--> '+transactionlist[0].Id);

        PropStrength__Customer_Detail__c testCusDet1 = new PropStrength__Customer_Detail__c(
            PropStrength__Transaction_Request__c = transactionlist[0].Id,
            PropStrength__Contact__c = cont[0].Id,
            PropStrength__Type__c = '1st Applicant',
            PropStrength__Active__c = true
        );
        insert testCusDet1;
        
        PropStrength__Applicant_Detail__c testApplicant1 = new PropStrength__Applicant_Detail__c(
            PropStrength__Application__c = testBooking.Id,
            PropStrength__Applicant_Acc__c = cont[0].Id,
            PropStrength__Type__c = '1st Applicant',
            PropStrength__Active__c = true
        );
        insert testApplicant1;
        
        PropStrength__Applicant_Detail__c testApplicant2 = new PropStrength__Applicant_Detail__c(
            PropStrength__Application__c = testBooking.Id,
            PropStrength__Applicant_Acc__c = cont[0].Id,
            PropStrength__Type__c = '2nd Applicant',
            PropStrength__Active__c = true
        );
        insert testApplicant2;
        
        List<PropStrength__Applicant_Detail__c> lst = new List<PropStrength__Applicant_Detail__c> ();
        lst.add(testApplicant1);
        lst.add(testApplicant2);
        

        Test.setCurrentPage(Page.TransferLetter_TR);
        ApexPages.currentPage().getParameters().put('id', transactionlist[0].Id);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        TransferLetterController controller = new TransferLetterController();
        controller.applicantDetailsFetch(lst);
        Test.stopTest();
    }
    @isTest
    static void testDoCancel() {
        PropStrength__Projects__c pp = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        PropStrength__Property_Type__c ppt = [SELECT Id FROM PropStrength__Property_Type__c LIMIT 1];
        PropStrength__Tower__c pt = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];
        PropStrength__Property__c pp2 = [SELECT Id FROM PropStrength__Property__c LIMIT 1];
        

        PropStrength__Application_Booking__c testBooking = new PropStrength__Application_Booking__c(
            PropStrength__Project__c = pp.id,
            PropStrength__Property__c = pp2.Id,
            POA_Name__c = 'POA Test',
            PropStrength__Property_Type__c = ppt.Id,
            Create_SBTR__c = true
        );
        insert testBooking;
        
        List<PropStrength__Transaction_Requests__c> transactionlist = new List<PropStrength__Transaction_Requests__c>([select id from PropStrength__Transaction_Requests__c]);
        System.debug('Transaction ID--> '+transactionlist[0].Id);
        
        Test.setCurrentPage(Page.TransferLetter_TR);
        ApexPages.currentPage().getParameters().put('id', transactionlist[0].Id);
        
        TransferLetterController controller = new TransferLetterController();
        
        Test.startTest();
        PageReference result = controller.docancel();
        Test.stopTest();
    }
    
    @isTest
    static void testSavePdf() {
        PropStrength__Projects__c pp = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        PropStrength__Property_Type__c ppt = [SELECT Id FROM PropStrength__Property_Type__c LIMIT 1];
        PropStrength__Tower__c pt = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];
        PropStrength__Property__c pp2 = [SELECT Id FROM PropStrength__Property__c LIMIT 1];
        

        PropStrength__Application_Booking__c testBooking = new PropStrength__Application_Booking__c(
            PropStrength__Project__c = pp.id,
            PropStrength__Property__c = pp2.Id,
            POA_Name__c = 'POA Test',
            PropStrength__Property_Type__c = ppt.Id,
            Create_SBTR__c = true
        );
        insert testBooking;
        
        List<PropStrength__Transaction_Requests__c> transactionlist = new List<PropStrength__Transaction_Requests__c>([select id from PropStrength__Transaction_Requests__c]);
        System.debug('Transaction ID--> '+transactionlist[0].Id);
        
        Test.setCurrentPage(Page.TransferLetter_TR);
        ApexPages.currentPage().getParameters().put('id', transactionlist[0].Id);
        
        Attachment attachment = new Attachment(
            Name = 'Transfer Letter.pdf',
            Body = Blob.valueOf('Test Data'),
            ParentId = transactionlist[0].Id
        );
        insert attachment;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        TransferLetterController controller = new TransferLetterController();
        
        Test.startTest();
        PageReference result = controller.savepdf();
        Test.stopTest();
    }
}