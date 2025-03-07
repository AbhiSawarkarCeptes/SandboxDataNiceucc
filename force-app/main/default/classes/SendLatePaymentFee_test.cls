@IsTest
public class SendLatePaymentFee_test {
    @IsTest
    static void testExecute() {
        Set<Id> testPayIds = new Set<Id>();
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
        insert appBook;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        insert pay;
        testPayIds.add(pay.Id);
        SendLatePaymentFee sendLatePaymentFee = new SendLatePaymentFee(testPayIds);
        Test.startTest();
        System.enqueueJob(sendLatePaymentFee);
        Test.stopTest();
    }
}