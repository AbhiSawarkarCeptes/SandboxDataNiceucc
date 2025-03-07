@isTest
public class InstallmentNotificationControllerTest {

    @testSetup
    static void setupData() {
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
        

        

        // Create test data for Bank_GL__r related to the project
        Bank_GL__c escrowAccount = new Bank_GL__c(
            Bank_Account_Type__c = 'Escrow Account',
            Beneficiary__c = 'Test Beneficiary',
            Account_Number__c = '123456789',
            IBAN__c = 'Test IBAN',
            Swift_Code__c = 'Test Swift',
            Bank_Name__c = 'Test Bank',
            Project__c = project.id
        );
        insert escrowAccount;

        // Create test data for PropStrength__Received_Payment__c
        PropStrength__Received_Payment__c receivedPayment = new PropStrength__Received_Payment__c(
            PropStrength__Application_Booking__c = appBookObj.Id,
            PropStrength__Amount_Due_Type__c = 'Test Amount Due Type',
            PropStrength__Payment_Date__c = Date.today(),
            PropStrength__Amount__c = 100
        );
        insert receivedPayment;
    }

    @isTest
    static void testInstallmentNotificationController() {
        // Get the Id of the test PropStrength__Received_Payment__c record
        PropStrength__Received_Payment__c testPayment = [SELECT Id FROM PropStrength__Received_Payment__c LIMIT 1];

        // Set the current page parameters
        Test.setCurrentPageReference(new PageReference('/apex/InstallmentNotificationPage'));
        ApexPages.currentPage().getParameters().put('id', testPayment.Id);
		InstallmentNotificationController inc = new InstallmentNotificationController();
    }
}