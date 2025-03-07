@isTest
public class PSPayRequestMobileTest {
    
    @testSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
        Contact primaryCustomer = new Contact(LastName = 'Test Customer',
        recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        insert primaryCustomer;

        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;
        
        PropStrength__Application_Booking__c booking = new PropStrength__Application_Booking__c(
            PropStrength__Primary_Customer__c = primaryCustomer.Id,
            Create_SBTR__c = true,
            PropStrength__Project__c = project.id);
        insert booking;

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
        
        PropStrength__Application_Booking__c bookingWithProperty = [SELECT Id FROM PropStrength__Application_Booking__c WHERE Id = :booking.Id LIMIT 1];
        bookingWithProperty.PropStrength__Property__c = property.Id;
        update bookingWithProperty;


        PropStrength__Property__c propertyWithTower = [SELECT Id FROM PropStrength__Property__c WHERE Id = :property.Id LIMIT 1];
        propertyWithTower.PropStrength__Tower__c = tower.Id;
        update propertyWithTower;
    }

    @isTest
    static void testDoCreateCaseWithValidBookingId() {
        Test.startTest();
        
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        PSPayRequestMobile.RequestWrapper request = new PSPayRequestMobile.RequestWrapper();
        request.email = 'test@example.com';
        request.mobile = '1234567890';
        request.description = 'Test description';
        request.requestType = 'Payment Request Created';
        request.bookingId = booking.Id;
        String jsonRequest = JSON.serialize(request);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createRequest_Dummy';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        RestContext.response = res;

        PSPayRequestMobile.doCreateCase();


        Test.stopTest();
    }

    @isTest
    static void testDoCreateCaseWithInvalidBookingId() {
        Test.startTest();
        
        PSPayRequestMobile.RequestWrapper request = new PSPayRequestMobile.RequestWrapper();
        request.email = 'test@example.com';
        request.mobile = '1234567890';
        request.description = 'Test description';
        request.requestType = 'Test Request Type';
        request.bookingId = 'INVALID_ID';
        String jsonRequest = JSON.serialize(request);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createRequest_Dummy';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        RestContext.response = res;

        PSPayRequestMobile.doCreateCase();

        Test.stopTest();
    }

    @isTest
    static void testDoCreateCaseWithMissingBookingId() {
        Test.startTest();
        
        PSPayRequestMobile.RequestWrapper request = new PSPayRequestMobile.RequestWrapper();
        request.email = 'test@example.com';
        request.mobile = '1234567890';
        request.description = 'Test description';
        request.requestType = 'Test Request Type';
        request.bookingId = '';
        String jsonRequest = JSON.serialize(request);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createRequest_Dummy';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        RestContext.response = res;

        PSPayRequestMobile.doCreateCase();

        Test.stopTest();
    }

    @isTest
    static void testPrepareResponse() {
        List<PSPayRequestMobile.ResponseWrapper> resWrap = new List<PSPayRequestMobile.ResponseWrapper>();
        PSPayRequestMobile.ResponseWrapper resp = new PSPayRequestMobile.ResponseWrapper();
        resp.Id = 'TestId';
        resp.RecordTypeId = 'TestRecordTypeId';
        resp.Department = 'CRM';
        resp.SuppliedEmail = 'test@example.com';
        resp.SuppliedPhone = '1234567890';
        resp.Origin = 'Mobile App';
        resp.Category = 'Test Category';
        resp.Booking = 'TestBooking';
        resp.Description = 'Test Description';
        resp.Contact = 'TestContact';
        resp.Comments = 'Test Comments';
        resp.Priority = 'Medium';
        resWrap.add(resp);

        PSPayRequestMobile.HttpResponseWrapper response = PSPayRequestMobile.prepareResponse(resWrap, 'Operation Successfull', 'Success', 200, true, 'TestCaseNumber');
    }
}