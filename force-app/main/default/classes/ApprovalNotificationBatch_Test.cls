@isTest
public class ApprovalNotificationBatch_Test {

    @testSetup
    static void setupTestData() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User u = TestDataFactorySobha.createUser(null);
        insert u;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example87w6732.com',
            Username = 'testuser@examp23i237dqhjle.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = u.Id
        );
        insert testUser;

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
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
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        milestone.PropStrength__Actual_Completed_Date__c= System.Today();
        update milestone;
        Test.StopTest();

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting for approval');
        req.setObjectId(milestone.Id);
        Approval.ProcessResult result = Approval.process(req);

    }

    @isTest
    static void testBatchExecute() {
        Test.startTest();
        User u = TestDataFactorySobha.createUser(null);
        insert u;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@exam6756ple87w6732.com',
            Username = 'testuser@exjdsghdsamp23i237dqhjle.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = u.Id
        );
        insert testUser;
        ApprovalNotificationBacth batch = new ApprovalNotificationBacth();
        Database.executeBatch(batch);

        batch.execute(null);
        Test.stopTest();
    }

    @isTest
    static void testScheduledJob() {
        Test.startTest();
        User u = TestDataFactorySobha.createUser(null);
        insert u;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testu723563ser@example87w6732.com',
            Username = 'tekhdwjdstuser@examp23i237dqhjle.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = u.Id
        );
        insert testUser;
        ApprovalNotificationBacth batch = new ApprovalNotificationBacth();
        batch.finish(null);
        Test.stopTest();
    }
}