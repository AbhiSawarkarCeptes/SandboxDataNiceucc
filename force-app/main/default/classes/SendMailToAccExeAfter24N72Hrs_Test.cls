@isTest
public class SendMailToAccExeAfter24N72Hrs_Test{

    @isTest static void email24Hr72HrTest(){
        User usr = TestDataFactorySobha.createUser(null);
        insert usr;
        
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        project.Accounts_Executive__c = usr.Id;
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

        List<PropStrength__Application_Booking__c> bookList = new List<PropStrength__Application_Booking__c>{appBookObj};
        Test.startTest();
        SendMailToAccExecutiveAfter24N72Hrs.email24Hr72Hr(bookList);
        Test.stopTest();
    }
}