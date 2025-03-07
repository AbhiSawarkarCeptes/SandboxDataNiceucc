@isTest
public class FileNoteApplicationBookingAPI_Test {

    @isTest static void doPostTest1(){
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        Contact con = TestDataFactorySobha.createContact(null);
        insert con;

        PropStrength__Assignment_Group_Name__c assgmtGroup = TestDataFactorySobha.createAssignmentGroup(null);
        insert assgmtGroup;

        PropStrength__Request__c requestObj = TestDataFactorySobha.createEnquiry(null);
        insert requestObj;
        
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;

        PropStrength__Property__c property = TestDataFactorySobha.createProperty(null);
        insert property;
        
        PropStrength__Payment_Plan__c paymentPlan = TestDataFactorySobha.createPaymentPlan(null);
        insert paymentPlan;

        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;

        PropStrength__Brokerage_Scheme__c brokerageScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brokerageScheme;

        PropStrength__Application_Booking__c booking = TestDataFactorySobha.createApplicationBooking(null);
        booking.Booking_Approver_Audit__c = 'Accepted';
        insert booking;
		
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/filenoteapplicationbookingapi/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        FileNoteApplicationBookingAPI.doPost();        
        Test.stopTest();
    }
    
    @isTest static void doPostTest2(){
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/filenoteapplicationbookingapi/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        FileNoteApplicationBookingAPI.doPost();        
        Test.stopTest();
    }
}