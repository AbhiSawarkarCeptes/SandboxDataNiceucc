@isTest
public class EventTriggerStdController_Test {
    @isTest
    public static void TestEventTriggerStdController(){
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;
        PropStrength__Payment_Plan__c propPlan = TestDataFactorySobha.createPaymentPlan(null);
        insert propPlan;
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        con.Email = 'test123@gmail.com';
        insert con;
        PropStrength__Request__c propRequest = TestDataFactorySobha.createEnquiry(null);
        insert propRequest;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c propTower = TestDataFactorySobha.createTower(null);
        insert propTower;
        PropStrength__Property__c property = TestDataFactorySobha.createProperty(null);
        insert property;
        PropStrength__Offer__c proStrengthOffer = TestDataFactorySobha.createOffer(null);
        insert proStrengthOffer;
        PropStrength__Brokerage_Scheme__c proBrokerage = TestDataFactorySobha.createBrokerageScheme(null);
        insert proBrokerage;
        PropStrength__Application_Booking__c appBookingRec = TestDataFactorySobha.createApplicationBooking(null);
        appBookingRec.PropStrength__Applicant_Email__c = 'test123@gmail.com';
        insert appBookingRec;
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=con.Id,
                                                                                            PropStrength__Type__c = '1st Applicant', 
                                                                                            PropStrength__Active__c = true, 
                                                                                            PropStrength__Non_Resident__c = true, 
                                                                                            PropStrength__Application__c = appBookingRec.Id);
        insert appDetail;
        PropStrength__Transaction_Requests__c propTransReq = TestDataFactorySobha.createTransactionRequest(null);
        propTransReq.PropStrength__Application_Booking__c = appBookingRec.Id;
        insert propTransReq;
        Event evt = new Event(Subject = 'Meeting' , DurationInMinutes = 1 ,ActivityDateTime= System.now());
        evt.WhatId = propTransReq.Id;
        insert evt;
        List<Event> evtList = [SELECT ID , Subject  , WhatId , StartDateTime FROM Event WHERE Subject = 'Meeting' ];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        EventTriggerStdController.sendEmailForTRHandover(evtList);
        EventTriggerStdController.sendEmail(evtList[0].WhatId , evtList[0].StartDateTime , appDetail.PropStrength__Customer_Name__c , 'test123@gmail.com');
        Test.stopTest();
    }
}