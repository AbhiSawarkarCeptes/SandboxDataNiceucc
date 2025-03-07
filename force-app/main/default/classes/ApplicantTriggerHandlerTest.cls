@isTest
static void testConvertLeadAndUpdateApplicant() {
    // Create test Account
    Account testAccount = new Account(Name = 'Test Account', Unique_Customer_ID__c = 'UCID12345');
    insert testAccount;
    
    // Create test Opportunity
    Opportunity testOpportunity = new Opportunity(Name = testAccount.Name, StageName = 'Prospecting', CloseDate = Date.today(), AccountId = testAccount.Id);
    insert testOpportunity;
    
    // Create test Booking
    Booking__c testBooking = new Booking__c(Opportunity__c = testOpportunity.Id, Booking_Date__c = system.today());
    insert testBooking;
    
    // Create test Applicant Details records
    Applicant_Details__c primaryApplicant = new Applicant_Details__c(
        Name = 'Primary Applicant',
        Opportunity__c = testOpportunity.Id,
        Booking__c = testBooking.Id,
        Applicant_Number__c = 'Primary Applicant',
        Mobile_Number__c = '1234567890',
        Email_Address__c = 'primary@example.com'
    );
    
    Applicant_Details__c secondaryApplicant = new Applicant_Details__c(
        Name = 'Secondary Applicant',
        Opportunity__c = testOpportunity.Id,
        Booking__c = testBooking.Id,
        Applicant_Number__c = 'Secondary Applicant',
        Mobile_Number__c = '0987654321',
        Email_Address__c = 'secondary@example.com'
    );
    
    insert new List<Applicant_Details__c>{ primaryApplicant, secondaryApplicant };
    
    // Create a Lead that will be converted
    Lead testLead = new Lead(
        FirstName = 'Test',
        LastName = 'Lead',
        Email = 'secondary@example.com',
        MobilePhone = '0987654321',
        IsConverted = false
    );
    insert testLead;
    
    // Create a Lead that will not be converted
    Lead anotherLead = new Lead(
        FirstName = 'Another',
        LastName = 'Lead',
        Email = 'notconverted@example.com',
        MobilePhone = '1234567891',
        IsConverted = false
    );
    insert anotherLead;
    
    // Create a map of new applicants
    Map<String, Applicant_Details__c> newApplicantMap = new Map<String, Applicant_Details__c>();
    newApplicantMap.put(testBooking.Id, primaryApplicant);
    
    Test.startTest();
    ApplicantTriggerHandler.convertLeadAndUpdateApplicant(new List<Lead>{testLead, anotherLead}, newApplicantMap);
    Test.stopTest();
    
    // Verify that the lead was converted
    List<Lead> leads = [SELECT Id, Email, MobilePhone, IsConverted FROM Lead WHERE Email IN ('secondary@example.com') OR MobilePhone IN ('0987654321')];
    System.assertEquals(1, leads.size(), 'One lead should be created for the secondary applicant.'); 
    System.assertEquals(true, leads[0].IsConverted, 'Lead should be converted.');
    
    // Verify Opportunities were created
    List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity WHERE AccountId = :testAccount.Id];
    System.assertEquals(1, opportunities.size(), 'One opportunity should be created for the secondary applicant.');
    
    // Verify that the other lead remains unconverted
    List<Lead> unconvertedLeads = [SELECT Id, IsConverted FROM Lead WHERE Email = 'notconverted@example.com'];
    System.assertEquals(1, unconvertedLeads.size(), 'The other lead should remain unconverted.');
    System.assertEquals(false, unconvertedLeads[0].IsConverted, 'Lead should not be converted.');
}
    // Create test Account
    Account testAccount = new Account(Name = 'Test Account', Unique_Customer_ID__c = 'UCID12345');
    insert testAccount;
    
    // Create test Opportunity
    Opportunity testOpportunity = new Opportunity(Name = testAccount.Name, StageName = 'Prospecting', CloseDate = Date.today(), AccountId = testAccount.Id);
    insert testOpportunity;
    
    // Create test Booking
    Booking__c testBooking = new Booking__c(Opportunity__c = testOpportunity.Id, Booking_Date__c = system.today());
    insert testBooking;
    
    // Create test Applicant Details records
    Applicant_Details__c primaryApplicant = new Applicant_Details__c(
        Name = 'Primary Applicant',
        Opportunity__c = testOpportunity.Id,
        Booking__c = testBooking.Id,
        Applicant_Number__c = 'Primary Applicant',
        Mobile_Number__c = '1234567890',
        Email_Address__c = 'primary@example.com'
    );
    
    Applicant_Details__c secondaryApplicant = new Applicant_Details__c(
        Name = 'Secondary Applicant',
        Opportunity__c = testOpportunity.Id,
        Booking__c = testBooking.Id,
        Applicant_Number__c = 'Secondary Applicant',
        Mobile_Number__c = '0987654321',
        Email_Address__c = 'secondary@example.com'
    );
    
    insert new List<Applicant_Details__c>{ primaryApplicant, secondaryApplicant };
    
    // Create a Lead that will be converted
    Lead testLead = new Lead(
        FirstName = 'Test',
        LastName = 'Lead',
        Email = 'secondary@example.com',
        MobilePhone = '0987654321',
        IsConverted = false
    );
    insert testLead;
    
    // Create a Lead that will not be converted
    Lead anotherLead = new Lead(
        FirstName = 'Another',
        LastName = 'Lead',
        Email = 'notconverted@example.com',
        MobilePhone = '1234567891',
        IsConverted = false
    );
    insert anotherLead;
    
    // Create a map of new applicants
    Map<Id, Applicant_Details__c> newApplicantMap = new Map<Id, Applicant_Details__c>();
    newApplicantMap.put(secondaryApplicant.Id, secondaryApplicant);
    
    Test.startTest();
    ApplicantTriggerHandler.onAfterInsertLeadConversion(newApplicantMap);
    Test.stopTest();
    
    // Verify that the lead was converted
    List<Lead> leads = [SELECT Id, Email, MobilePhone, IsConverted FROM Lead WHERE Email IN ('secondary@example.com') OR MobilePhone IN ('0987654321')];
    System.assertEquals(1, leads.size(), 'One lead should be created for the secondary applicant.'); 
    System.assertEquals(true, leads[0].IsConverted, 'Lead should be converted.');
    
    // Verify Opportunities were created
    List<Opportunity> opportunities = [SELECT Id, Name, Email__c, Mobile_No_O__c FROM Opportunity WHERE Email__c = 'secondary@example.com' OR Mobile_No_O__c = '0987654321'];
    System.assertEquals(1, opportunities.size(), 'One opportunity should be created for the secondary applicant.');
    
    // Verify that the other lead remains unconverted
    List<Lead> unconvertedLeads = [SELECT Id, IsConverted FROM Lead WHERE Email = 'notconverted@example.com'];
    System.assertEquals(1, unconvertedLeads.size(), 'The other lead should remain unconverted.');
    System.assertEquals(false, unconvertedLeads[0].IsConverted, 'Lead should not be converted.');
}
