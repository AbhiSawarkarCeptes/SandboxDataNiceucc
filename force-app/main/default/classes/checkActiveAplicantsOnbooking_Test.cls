@isTest
public class checkActiveAplicantsOnbooking_Test {
    
    @testSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        Contact con = TestDataFactorySobha.createContact(null);
        con.recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
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
        
        


        PropStrength__Applicant_Detail__c applicant1 = new PropStrength__Applicant_Detail__c(
   
            PropStrength__Application__c = appBookObj.Id,
            PropStrength__Applicant_Acc__c = con.Id,
            PropStrength__Active__c = true,
            Send_for_Docusign__c = true,
            PropStrength__Type__c = '1st Applicant',
            Formatted_Applicant_Nationality_Docgen__c = 'test',
            Nationality__c = 'Afghanistan'
        );
        insert applicant1;

        PropStrength__Applicant_Detail__c applicant2 = new PropStrength__Applicant_Detail__c(
           
            PropStrength__Application__c = appBookObj.Id,
            PropStrength__Applicant_Acc__c = con.Id,
            PropStrength__Active__c = true,
            Send_for_Docusign__c = false,
            PropStrength__Type__c = '1st Applicant',
            Formatted_Applicant_Nationality_Docgen__c = 'test',
            Nationality__c = 'Afghanistan'

        );
        insert applicant2;
    }

    @isTest
    static void testSendEnvelopeMethod1() {
        // Get the test data
        Test.startTest();
        List<PropStrength__Application_Booking__c> applications = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        // Invoke the method
        List<Id> trIds = new List<Id>{applications[0].Id};
        List<String> result = checkActiveAplicantsOnbooking.sendEnvelopeMethod1(trIds);
        Test.StopTest();
    }
}