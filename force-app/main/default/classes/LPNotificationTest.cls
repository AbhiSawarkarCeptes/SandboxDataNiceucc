@isTest
public class LPNotificationTest {
    @testSetup
    static void setupTestData() {
        Project__c testProject = new Project__c(Name = 'Test Project',Project_Code__c='ss');
        insert testProject;
        
        Tower__c testTower = new Tower__c(Name = 'Test Tower', Project__c = testProject.Id, Stop_Automatic_Email__c = false);
        insert testTower;
        
        // Create a test Unit
        Unit__c testUnit = new Unit__c(Name = 'Test Unit', Tower__c = testTower.Id, Tower__r = testTower);

        insert testUnit;
		Payment_Plan__c testPaymentPlan = new Payment_Plan__c(Name = 'Test Payment Plan', NoofMilestones__c =1);
        insert testPaymentPlan;
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today(), Other_Applicants_Email__c = 'other@test.com');
        insert testOpp;
        Quotation__c quote = new Quotation__c(Payment_Plan__c = testPaymentPlan.Id);
    	insert quote;
        // Create a test Booking
        Booking__c testBooking = new Booking__c(
            Opportunity__c = testOpp.Id,
            Unit__c = testUnit.Id,
            Primary_Applicant_Email__c = 'primary@test.com',
            Primary_Applicant_Name__c = 'John Doe',
            Tower__c = testTower.Id,
            Quotation__c = quote.Id
            
        );
        insert testBooking;
        
        // Create a test Demand record
        Demand__c testDemand = new Demand__c(
           
            Booking__c = testBooking.Id,
            
            Total_Amount_Demanded__c = 1000.00
        );
        insert testDemand;
    }
    
    @isTest
    static void testResendNotification() {
        // Retrieve the test demand
        List<Demand__c> testDemands = [SELECT Id, Booking__c FROM Demand__c LIMIT 1];
        System.assert(!testDemands.isEmpty(), 'Test demand should exist');
        Demand__c testDemand = testDemands[0];
        
        // Retrieve the associated booking
        Booking__c testBooking = [SELECT Id, Project__r.Name, Unit__r.Name, Primary_Applicant_Email__c, Opportunity__r.Other_Applicants_Email__c, Unit__r.Tower__r.Stop_Automatic_Email__c FROM Booking__c WHERE Id = :testDemand.Booking__c LIMIT 1];

        System.assert(testBooking != null, 'Test booking should exist');
        
        // Test when Stop_Automatic_Email__c is true
        testBooking.Unit__r.Tower__r.Stop_Automatic_Email__c = true; // Ensure this field is queried

        update testBooking;

        Test.startTest();
        LPNotification.resendNotification(new List<Demand__c>{testDemand});
        Test.stopTest();
        
        // Assert that content versions were not created
        List<ContentVersion> contentList = [SELECT Id FROM ContentVersion WHERE ExternalDocumentInfo1 = :testDemand.Id];
        System.assertEquals(0, contentList.size(), 'Content Version should not be created when email is stopped');
        
        // Test when Primary_Applicant_Email__c is null
        testBooking.Primary_Applicant_Email__c = null;
        update testBooking;

        Test.startTest();
        LPNotification.resendNotification(new List<Demand__c>{testDemand});
        Test.stopTest();
        
        // Assert that content versions were created
        contentList = [SELECT Id FROM ContentVersion WHERE ExternalDocumentInfo1 = :testDemand.Id];
        System.assert(contentList.size() > 0, 'Content Version should be created when Primary Applicant Email is null');
        
        // Test when Other_Applicants_Email__c contains invalid emails
        testBooking.Opportunity__r.Other_Applicants_Email__c = 'invalid_email';
        update testBooking;

        Test.startTest();
        LPNotification.resendNotification(new List<Demand__c>{testDemand});
        Test.stopTest();
        
        // Assert that content versions were created
        contentList = [SELECT Id FROM ContentVersion WHERE ExternalDocumentInfo1 = :testDemand.Id];
        System.assert(contentList.size() > 0, 'Content Version should be created when Other Applicants Email is invalid');

    }
}
