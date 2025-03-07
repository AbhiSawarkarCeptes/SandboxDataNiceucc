@isTest
public class SendEmailToCustomerOnNoResponse_Test {
    @isTest
    static void testSendEmailToCustomerOnNoResponseCD(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();        
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.email = 'test@gmail.com';
        cont.recordTypeId = recordTypeId;
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
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);//
        appBook.PropStrength__Status__c = 'Audit Approved';
        insert appBook;

        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        appDetail.PropStrength__Application__c = appBook.id;
        //appDetail.PropStrength__Applicant_Email__c = 'test@gmail.com';
        appDetail.PropStrength__Active__c = true;
        appDetail.PropStrength__Applicant_Acc__c = cont.Id;
        insert appDetail;

        Application_Booking_Call_Detail__c appCallDetail   = new Application_Booking_Call_Detail__c();
        appCallDetail.Application_Booking__c = appBook.id;
        appCallDetail.Call_Update__c = 'No Response';
        insert appCallDetail;

        List<String> appCallDetailList = new List<String>();
        appCallDetailList.add(String.valueOf(appCallDetail.Id));

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SendEmailToCustomerOnNoResponse.SendEmailToCustomerOnNoResponseCD(appCallDetailList);
    }
}