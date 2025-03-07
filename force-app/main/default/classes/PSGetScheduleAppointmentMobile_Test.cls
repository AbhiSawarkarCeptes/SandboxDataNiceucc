@isTest
public class PSGetScheduleAppointmentMobile_Test {

    @testSetup
    static void createData(){
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
    }
    
    @isTest static void getPaymentReceiptsTest1(){
        PropStrength__Application_Booking__c appBookObj = TestDataFactorySobha.createApplicationBooking(null);
        insert appBookObj;
        
        Test.startTest();
        PSGetScheduleAppointmentMobile.getPaymentReceipts(appBookObj.Id, 'Home Orientation', String.valueOf(Date.today()), '20', 'Test');
        Test.stopTest();
    }
    
    @isTest static void getPaymentReceiptsTest2(){
        PropStrength__Application_Booking__c appBookObj = TestDataFactorySobha.createApplicationBooking(null);
        insert appBookObj;
        
        Test.startTest();
        PSGetScheduleAppointmentMobile.getPaymentReceipts(appBookObj.Id, 'HandOver', String.valueOf(Date.today()), '20', 'Test');
        Test.stopTest();
    }
    
    @isTest static void getPaymentReceiptsTest3(){
        Test.startTest();
        PSGetScheduleAppointmentMobile.getPaymentReceipts('TestId', 'HandOver', String.valueOf(Date.today()), '20', 'Test');
        Test.stopTest();
    }
    @isTest static void getPaymentReceiptsTest4(){
        Test.startTest();
        PSGetScheduleAppointmentMobile.getPaymentReceipts('', '', String.valueOf(Date.today()), '20', 'Test');
        Test.stopTest();
    }
}