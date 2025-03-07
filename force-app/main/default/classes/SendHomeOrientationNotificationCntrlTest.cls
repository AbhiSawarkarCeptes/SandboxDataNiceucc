@isTest
public class SendHomeOrientationNotificationCntrlTest {
    @testSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create necessary test data here

        // Create OrgWideEmailAddress
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];

        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        
        Contact primaryCustomer = new Contact(LastName = 'Test Customer');
        insert primaryCustomer;

        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;
        
        // Create Application Booking
        PropStrength__Application_Booking__c booking = new PropStrength__Application_Booking__c(
            PropStrength__Primary_Customer__c = primaryCustomer.Id,
            Create_SBTR__c = true,
            PropStrength__Project__c = project.id);
        insert booking;

        // Create Applicant Details
        PropStrength__Applicant_Detail__c applicant = new PropStrength__Applicant_Detail__c(
            PropStrength__Application__c = booking.Id,
            Formatted_Applicant_Nationality_Docgen__c = 'text',
            Nationality__c = 'Andorran',
            PropStrength__Type__c = '1st Applicant',
            PropStrength__Active__c = true);
        insert applicant;

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
        
        // Link Property to Booking
        PropStrength__Application_Booking__c bookingWithProperty = [SELECT Id FROM PropStrength__Application_Booking__c WHERE Id = :booking.Id LIMIT 1];
        bookingWithProperty.PropStrength__Property__c = property.Id;
        update bookingWithProperty;


        PropStrength__Property__c propertyWithTower = [SELECT Id FROM PropStrength__Property__c WHERE Id = :property.Id LIMIT 1];
        propertyWithTower.PropStrength__Tower__c = tower.Id;
        update propertyWithTower;
    }

    @isTest
    static void testConstructorValidRecordId() {
        Test.startTest();
        PageReference pageRef = Page.TestPage; // Replace with your actual VF page
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', 'VALID_RECORD_ID'); // Replace with a valid ID prefix

        SendHomeOrientationNotificationCntrl controller = new SendHomeOrientationNotificationCntrl();

        Test.stopTest();
    }

    @isTest
    static void testConstructorInvalidRecordId() {
        Test.startTest();
        PageReference pageRef = Page.TestPage; // Replace with your actual VF page
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', 'INVALID');

        SendHomeOrientationNotificationCntrl controller = new SendHomeOrientationNotificationCntrl();

        Test.stopTest();
    }

    @isTest
    static void testSendLetterWithTower() {
        Test.startTest();
        PageReference pageRef = Page.TestPage; // Replace with your actual VF page
        Test.setCurrentPage(pageRef);
        PropStrength__Tower__c tower = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', tower.Id);

        SendHomeOrientationNotificationCntrl controller = new SendHomeOrientationNotificationCntrl();
        controller.sendLetter();

        Test.stopTest();
    }

    @isTest
    static void testSendLetterWithBooking() {
        Test.startTest();
        PageReference pageRef = Page.TestPage; // Replace with your actual VF page
        Test.setCurrentPage(pageRef);
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', booking.Id);

        SendHomeOrientationNotificationCntrl controller = new SendHomeOrientationNotificationCntrl();
        controller.sendLetter();
        Test.stopTest();
    }

    @isTest
    static void testCancelLetter() {
        Test.startTest();
        PageReference pageRef = Page.TestPage; // Replace with your actual VF page
        Test.setCurrentPage(pageRef);
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', booking.Id);

        SendHomeOrientationNotificationCntrl controller = new SendHomeOrientationNotificationCntrl();
        PageReference result = controller.cancelLetter();

        Test.stopTest();
    }

    @isTest
    static void testSendMailToCustomer() {
        Test.startTest();
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
                
        SendHomeOrientationNotificationCntrl.sendMailToCustomer(booking.Id);

        Test.stopTest();
    }
}