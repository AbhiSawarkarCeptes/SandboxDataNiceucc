@isTest
public class MobileAppQueuableNotification_Test {

    @isTest
    static void mobileAppNotificationTest() {
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        Contact con = TestDataFactorySobha.createContact(null);
        insert con;

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
        
        PropStrength__Payment_Plan__c paymentPlan = TestDataFactorySobha.createPaymentPlan(null);
        insert paymentPlan;

        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;

        PropStrength__Brokerage_Scheme__c brokerageScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brokerageScheme;

        PropStrength__Application_Booking__c appBookObj = TestDataFactorySobha.createApplicationBooking(null);
        insert appBookObj;


        String notificationStatus = 'Success';
        String type = 'Test';
        Set<Id> bookingIdSet = new Set<Id>{appBookObj.Id};
        MobileAppQueuableNotification mobileNotifyObj = new MobileAppQueuableNotification(bookingIdSet, notificationStatus, type);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id apexJobID = system.enqueueJob(mobileNotifyObj);
        Test.stopTest();
    }
     @isTest
    public static void testCallMobileApp_Success() {
        Mobile_App__mdt mockMobileAppMdt = new Mobile_App__mdt(
            End_Point__c = 'mockEndpoint',
            sf_Token__c = 'mockSfToken',
            Subscription_Key__c = 'mockSubscriptionKey'
        );
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        MobileIntegrationCallOutsAPI_PS.callMobileApp('mockEndpoint', 'GET', 'mockBody');
    }
    
     @isTest
    static void mobileAppNotificationTest2() {
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        Contact con = TestDataFactorySobha.createContact(null);
        insert con;

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
        
        PropStrength__Payment_Plan__c paymentPlan = TestDataFactorySobha.createPaymentPlan(null);
        insert paymentPlan;

        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;

        PropStrength__Brokerage_Scheme__c brokerageScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brokerageScheme;

        PropStrength__Application_Booking__c appBookObj = TestDataFactorySobha.createApplicationBooking(null);
        insert appBookObj;


        String notificationStatus = 'Success';
        String type = 'Test';
        Set<Id> bookingIdSet = new Set<Id>{appBookObj.Id};
        MobileAppQueuableNotification mobileNotifyObj = new MobileAppQueuableNotification(bookingIdSet, notificationStatus, type);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorError());
        Id apexJobID = system.enqueueJob(mobileNotifyObj);
        Test.stopTest();
    }
     public class MockHttpResponseGeneratorError implements HttpCalloutMock {
        public Integer statusCode;
        public String responseBody;
        
        public MockHttpResponseGeneratorError() {
            this.statusCode = 400;
            this.responseBody = JSON.serialize(new Map<String, Object>{'key' => 'value'});
        }
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(responseBody);
            return response;
        }
    }

}