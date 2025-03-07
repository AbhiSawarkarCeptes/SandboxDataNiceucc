@isTest
public class ResaleprocessFromAppBookingCont_Test {
    @isTest
    static void testResaleprocessFromAppBookingController(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
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

        PropStrength__Transaction_Requests__c ptr = TestDataFactorySobha.createTransactionRequest(null);
        ptr.PropStrength__Application_Booking__c = appBook.id;
        ptr.PropStrength__Application_Booking_Id__c = appBook.id;
        ptr.PropStrength__Status__c = 'Voided';
        Id recordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId();
        ptr.RecordTypeId = recordTypeId;
        insert ptr;

        string result = ResaleprocessFromAppBookingController.checkBookingIsAvailable(String.valueOf(appBook.ID));
        Id recordTypeId2 = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('DSPA Process').getRecordTypeId();
        ptr.RecordTypeId = recordTypeId2;
        update ptr;

        string result2 = ResaleprocessFromAppBookingController.checkBookingIsAvailable(String.valueOf(appBook.ID));
    }

    @isTest
    static void testRetrieveSellerInfo(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
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
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.PropStrength__Status__c = 'Audit Approved';
        insert appBook;

        // PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Reversal payment due', PropStrength__Application_Booking__c = AppBooking.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId(), PropStrength__Amount__c = 1000);
        // insert pay;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        appDetail.PropStrength__Application__c = appBook.id;
        insert appDetail;
        PropStrength__Application_Booking__c result = ResaleprocessFromAppBookingController.retrieveSellerInfo(String.valueOf(appBook.id));

    }

    @isTest
    static void testRetrieveSellerInfo1(){
        PropStrength__Application_Booking__c result = ResaleprocessFromAppBookingController.retrieveSellerInfo(null);
    }

    @isTest
    static void testGetPicklistValuesResaleType(){
        List<String> result = ResaleprocessFromAppBookingController.getPicklistValuesResaleType();
    }
}