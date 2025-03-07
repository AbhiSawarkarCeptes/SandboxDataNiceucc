@isTest
public class CreatePaymentPlanFromOfferControl_Test {
    @isTest
    public static void testCheckValidation(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
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
        
        Test.startTest();
        CreatePaymentPlanFromOfferController.checkValidation(offer.Id);
        offer.Deviation_on_Payment_Plan_Approved__c = true;
        update offer;
        CreatePaymentPlanFromOfferController.checkValidation(offer.Id);
        CreatePaymentPlanFromOfferController.checkValidation(null);
        //CreatePaymentPlanFromOfferController.checkValidation(offer4.Id);
        Test.stopTest();
        
    }
}