@isTest
public class QRCodeReaderControllerTest {
    
    // Helper method to create a User
    private static User createUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User u = new User(
            Username = 'testuser@company.com.invalid.inv',
            LastName = 'testuser',
            Email = 'testuser@company.com',
            Alias = 'testuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        return u;
    }

    // Helper method to create a Lead
    private static Lead createLead(String utmCampaign) {
        Lead ld = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'testlead@company.com',
            MobilePhone = '1234567890',
            UTM_Campaign__c = utmCampaign
        );
        insert ld;
        return ld;
    }
    
    // Helper method to create an Opportunity
    private static Opportunity createOpportunity(String utmCampaign) {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            CloseDate = System.today(),
            StageName = 'Prospecting',
            UTM_Campaign__c = utmCampaign
        );
        insert opp;
        return opp;
    }
    
    // Helper method to create Campaign Schedule
    private static Campaign_Schedule__c createCampaignSchedule(String campaignName) {
        Campaign_Schedule__c cs = new Campaign_Schedule__c(
            Campaign_Name__c = campaignName,
            Active__c = true,
            Start_Date__c = System.today(),
            End_Date__c = System.today().addDays(30),
            Type__c = 'Roadshow'
        );
        insert cs;
        return cs;
    }
    
    // Test method for checkIfCampaignActive
    @isTest
    static void testCheckIfCampaignActive() {
        // Create a test user, lead, and campaign schedule
        User testUser = createUser('Standard User');
        Lead testLead = createLead('Test Campaign');
        Campaign_Schedule__c cs = createCampaignSchedule('Test Campaign');
        
        // Test checkIfCampaignActive
        Test.startTest();
        Boolean result = QRCodeReaderController.checkIfCampaignActive(testLead.Id);
        Test.stopTest();
    }
    
    // Test method for checkIfAlreadyOngoingSiteVisit
    @isTest
    static void testCheckIfAlreadyOngoingSiteVisit() {
        // Create test data (Opportunity with site visit)
        User testUser = createUser('Standard User');
        Opportunity testOpp = createOpportunity('Test Campaign');
        testOpp.Site_Visit_Start_Time__c = System.now();
        update testOpp;
        
        // Test checkIfAlreadyOngoingSiteVisit
        Test.startTest();
        Boolean result = QRCodeReaderController.checkIfAlreadyOngoingSiteVisit();
        Test.stopTest();
    }
    
    // Test method for checkIfSiteVisitExists
    @isTest
    static void testCheckIfSiteVisitExists() {
        // Create test data (Lead and Customer Registration)
        Lead testLead = createLead('Test Campaign');
        testLead = [select Id, Lead_Id__c from Lead where Id =: testLead.Id];
        Opportunity oppty = createOpportunity('Test Campaign');
        oppty.Lead_Id__c = testLead.Lead_Id__c;
        update oppty;
        Customer_Registration__c cr = new Customer_Registration__c(
            opportunity__c = oppty.Id
        );
        insert cr;
        
        // Test checkIfSiteVisitExists
        Test.startTest();
        Boolean result = QRCodeReaderController.checkIfSiteVisitExists(testLead.Id);
        String result1 = QRCodeReaderController.saveDetails(oppty.Id);
        Test.stopTest();
    }
    
    // Test method for saveDetails
    @isTest
    static void testSaveDetails() {
        // Create test data
        User testUser = createUser('Standard User');
        Lead testLead = createLead('Test Campaign');
        Campaign_Schedule__c cs = createCampaignSchedule('Test Campaign1');
        
        testLead.UTM_Campaign__c = 'Test Campaign1';
        testLead.Email = 'test@testing.com';
        update testLead;
        
        // Test saveDetails
        Test.startTest();
        String result = QRCodeReaderController.saveDetails(testLead.Id);
        Test.stopTest();
    }
    
    // Test method for sendRoadshowNotification
    @isTest
    static void testSendRoadshowNotification() {
        // Create test data
        Lead testLead = createLead('Test Campaign');
        
        // Test sendRoadshowNotification
        Test.startTest();
        QRCodeReaderController.sendRoadshowNotification(testLead.Id);
        Test.stopTest();
    }
    
    // Test method for getEmailDetails
    @isTest
    static void testGetEmailDetails() {
        // Create test data
        Lead testLead = createLead('Test Campaign');
        Campaign_Schedule__c cs = createCampaignSchedule('Test Campaign');
        
        // Test getEmailDetails
        Test.startTest();
        QRCodeReaderController.LeadWrapper result = QRCodeReaderController.getEmailDetails(testLead.Id);
        Test.stopTest();
    }
    
    // Test method for getEmailDetails
    @isTest
    static void testSubmitWalkingForm() {
        // Create test data
        Opportunity testOpp = createOpportunity('Test Campaign');
		testOpp = [select Id, AccountId from Opportunity where Id =: testOpp.Id];    
        
        Visitor_Registration__c vrRec = new Visitor_Registration__c();
        vrRec.First_Name__c = 'FirstName';
        vrRec.Last_Name__c = 'LastName';
        vrRec.Mobile__c = '9876565456';
        vrRec.Email__c = 'test@test.com';
        vrRec.Status__c = 'Accepted';
        vrRec.Sales_Adviser__c = 'Test';
        insert vrRec;
        
        Visitor_Registration__c vr = [
            SELECT
            Id,First_Name__c,Last_Name__c,Mobile__c,Email__c,Permanent_Address__c,Birth_Date__c,
            City__c,Country__c,UAE_Resident__c,Interested_in__c,Purpose_of_Purchase__c,DocumentId__c,AlternateEmail_Address__c,
            Remarks_if_any__c,Source__c,Agent_Name__c,Agent_ID__c,Company__c,Sales_Adviser__c,
            Nationality__c,Alternate_Email_Id__c,Alternate_Mobile_Number__c,Designation__c,
            Existing_Sobha_Owner__c,Occupation__c,Project_Name__c,Visiting_On_Behalf_Of__c,Residential_Status__c,Sobha_Connect_Company_Name__c,
            Sobha_Connect_Id__c,Sobha_Connect_Name__c,product_Type__c,Property_Type__c,Possession_Timeline__c,Budget__c,Unique_Id__c
            FROM 
            Visitor_Registration__c
            WHERE
            Id = :vrRec.Id
        ];
        
        Customer_Registration__c sv = new Customer_Registration__c();
        sv.First_Name__c = vr.First_Name__c;
        sv.Last_Name__c = vr.Last_Name__c;
        sv.project__c = vr.Project_Name__c;
        sv.Mobile_Number__c = vr.Mobile__c;
        sv.Email_Address__c = vr.Email__c;
        
        // Test getEmailDetails
        Test.startTest();
        QRCodeReaderController.submitWalkingForm(sv,null,null,testOpp.AccountId,vr.Project_Name__c,vr.Mobile__c,vr.Email__c,'','', vr.Id,'',vr,null);
        QRCodeReaderController.submitWalkingForm(sv,null,testOpp.Id,null,vr.Project_Name__c,vr.Mobile__c,vr.Email__c,'','', vr.Id,'',vr,null);
        Test.stopTest();
    }
}