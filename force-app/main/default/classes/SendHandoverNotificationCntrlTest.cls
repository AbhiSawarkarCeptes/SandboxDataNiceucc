@isTest
public class SendHandoverNotificationCntrlTest {

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
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        insert appDetail;
    }

    @isTest
    static void testConstructor_ValidId() {
        // Mock the ApexPages parameters
        Test.setCurrentPageReference(new PageReference('https://test.salesforce.com?id=' + [SELECT Id FROM PropStrength__Tower__c LIMIT 1].Id));

        SendHandoverNotificationCntrl controller = new SendHandoverNotificationCntrl();
    }

    @isTest
    static void testConstructor_InvalidId() {
        // Mock the ApexPages parameters with an invalid Id
        Test.setCurrentPageReference(new PageReference('https://test.salesforce.com?id=invalidId'));

        SendHandoverNotificationCntrl controller = new SendHandoverNotificationCntrl();
    }

    @isTest
    static void testSendLetter_Tower() {
        PropStrength__Tower__c tower = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];

        Test.setCurrentPageReference(new PageReference('https://test.salesforce.com?id=' + tower.Id));

        SendHandoverNotificationCntrl controller = new SendHandoverNotificationCntrl();
        controller.sendLetter();
    }

    @isTest
    static void testSendLetter_ApplicationBooking() {
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];

        Test.setCurrentPageReference(new PageReference('https://test.salesforce.com?id=' + booking.Id));

        SendHandoverNotificationCntrl controller = new SendHandoverNotificationCntrl();
        controller.sendLetter();
    }

    @isTest
    static void testCancelLetter() {
        PropStrength__Tower__c tower = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];

        Test.setCurrentPageReference(new PageReference('https://test.salesforce.com?id=' + tower.Id));

        SendHandoverNotificationCntrl controller = new SendHandoverNotificationCntrl();
        PageReference result = controller.cancelLetter();
    }

    @isTest
    static void testSendMailToCustomer() {
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];

        Test.startTest();
        SendHandoverNotificationCntrl.sendMailToCustomer(booking.Id);
        Test.stopTest();

        // Assert that the email was sent (using a mock email service or verifying other results)
        // As email sending cannot be tested directly, you might check if certain fields were updated.
        PropStrength__Application_Booking__c updatedBooking = [SELECT PropStrength__Completion_Certificate_Received__c FROM PropStrength__Application_Booking__c WHERE Id = :booking.Id];
    }
}