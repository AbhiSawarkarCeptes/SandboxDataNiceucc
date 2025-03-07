@isTest
public class PaymentCompletionCertControllerTest {
    @isTest 
    public static void TestPaymentCompletionCertControllerTest(){
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;
        PropStrength__Payment_Plan__c propPlan = TestDataFactorySobha.createPaymentPlan(null);
        insert propPlan;
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
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
        insert appBookingRec;
        String bookId = ApexPages.currentPage().getParameters().put('id', appBookingRec.Id);
        Test.startTest();
        PaymentCompletionCertificateController p = new PaymentCompletionCertificateController();
        Test.stopTest();
    }
}