@isTest
public class SitevisitChartControllerTest {
    
    @isTest
    static void testSiteVisits() {
        // Create a test profile of standard User
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; // Adjust profile name as needed
        
        // Attempt to create a unique username based on a pattern (e.g., 'testuser1', 'testuser2', etc.)
        User testUser;
        String baseUsername = 'testuser@gmail.com';
        Integer suffix = 1;
        Boolean usernameCreated = false;
        
        // Try multiple usernames until a unique one is created
        while (!usernameCreated) {
            String username = baseUsername + String.valueOf(suffix);
            testUser = new User(
                FirstName = 'Test',
                LastName = 'User',
                Email = 'testuser@example.com',
                Username = username,
                Alias = 'tuser',
                ProfileId = testProfile.Id,
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                IsActive = true
            );
            
            try {
                insert testUser;
                usernameCreated = true; // Username insertion succeeded
            } catch (DmlException e) {
                // Handle duplicate username exception
                if (e.getMessage().contains('Duplicate Username')) {
                    suffix++; // Increment suffix to try a different username
                } else {
                    // Rethrow other exceptions
                    throw e;
                }
            }
        }
        
        // Run test method within the context of the created test user
        System.runAs(testUser) {
            // Call the SiteVisits method from the controller
            List<Customer_Registration__c> siteVisits = SitevisitChartController.SiteVisits();
            
            // Perform assertions based on the expected behavior of the method
            System.assertNotEquals(null, siteVisits, 'Site visits should not be null');
            // Add more specific assertions as needed
        }
    }
    
    @isTest
    static void testFetchEmailTemplateInfo() {
        // Call the fetchEmailTemplateInfo method with a test template name
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CreateEnquiry' LIMIT 1];
        System.assertNotEquals(null, template, 'Email template should exist');
        
        SitevisitChartController.TemplateInfo templateInfo = SitevisitChartController.fetchEmailTemplateInfo('CreateEnquiry');
        // Perform assertions based on the expected behavior of the method
        System.assertNotEquals(null, templateInfo, 'TemplateInfo should not be null');
        System.assertEquals('Your Enquiry Created SucessFully', templateInfo.subject, 'Subject should match');
        
        // Remove all white spaces and line breaks for comparison
        String expectedBody = 'Hi<UserName>,youEnquirywascreatedsuccessfully<EnquiryNumber>.ItwasassignedtotheCHRMManager.wewillgetbacktoyoushortly.Regards,ChannelOperations';
        String actualBody = templateInfo.body.replaceAll('\\s+', '');
        
        System.assertEquals(expectedBody, actualBody, 'Body should match');
    }
    
    
    
    
    @isTest
    static void testGetBookingAppartmentsCount() {
        // Call the getBookingAppartmentsCount method
        Integer apartmentCount = SitevisitChartController.getBookingAppartmentsCount();
        // Perform assertions based on the expected behavior of the method
        System.assertNotEquals(null, apartmentCount, 'Apartment count should not be null');
        
    }
    
    @isTest
    static void testGetBookingVillasCount() {
        // Calling the getBookingVillasCount method
        Integer villasCount = SitevisitChartController.getBookingVillasCount();
        // Perform assertions based on the expected behavior of the method
        System.assertNotEquals(null, villasCount, 'Villas count should not be null');
        
    }
    
    @isTest
    static void testGetBookingData() {
        // Calling the getBookingData method
        List<AggregateResult> bookingData = SitevisitChartController.getBookingData();
        // Perform assertions based on the expected behavior of the method
        System.assertNotEquals(null, bookingData, 'Booking data should not be null');
        
    }
    
    @isTest
    static void testGetSitevisits1() {
        // Call the getSitevisits1 method with test data
        List<Integer> testYears = new List<Integer>{2023, 2024}; // Adjust years 
            List<Integer> testMonths = new List<Integer>{1, 2, 3}; // Adjust months 
                Map<String, Integer> siteVisitData = SitevisitChartController.getSitevisits1(testYears, testMonths);
        // Perform assertions based on the expected behavior of the method
        System.assertNotEquals(null, siteVisitData, 'Site visit data should not be null');
        
    }
    
    @isTest
    static void testGetSitevisits() {
        // Call the getSitevisits method with test data
        Integer testYear = 2024; // Adjust year data
        Integer testMonth = 5; // Adjust month data
        List<AggregateResult> siteVisitData = SitevisitChartController.getSitevisits(testYear, testMonth);
        // Perform assertions based on the expected behavior of the method
        System.assertNotEquals(null, siteVisitData, 'Site visit data should not be null');
        
    }
    
    @isTest
    static void testGetSalesBookings() {
        // Test data setup
        List<Integer> testYears = new List<Integer>{2023, 2024};
            List<Integer> testMonths = new List<Integer>{1, 2, 3}; // Assuming January, February, and March Month
                
                // Call the method
                Map<String, Integer> result = SitevisitChartController.getSalesBookings(testYears, testMonths);
        
        // Assertions
        System.assertEquals(6, result.size()); // 2 years * 3 months = 6 combinations expected
        for (Integer year : testYears) {
            for (Integer month : testMonths) {
                String key = SitevisitChartControllerTest.getMonthName(month) + '-' + String.valueOf(year);
                System.assert(result.containsKey(key), 'Key ' + key + ' not found in result map.');
                System.assertEquals(0, (Integer)result.get(key), 'Expected value for key ' + key + ' is 0.');
            }
        }
    }
    
    // Adding similar test methods for other methods in SitevisitChartController
    
    // Utility method to get month name from integer
    static String getMonthName(Integer monthNumber) {
        Map<Integer, String> monthNames = new Map<Integer, String>{
            1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun',
                7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
                };
                    return monthNames.get(monthNumber);
    }
    
    @isTest
    static void testGetBookingDataQuaterly() {
        // Test data setup
        Integer selectedYear = 2023; // Assuming  year is 2023
        
        // Calling the the method
        List<AggregateResult> result = SitevisitChartController.getBookingDataQuaterly(selectedYear);
        System.assertNotEquals(null, result, 'Get Booking data Quaterly '); 
        
    }
    
    @isTest
    static void testGetSitevisitsQuaterly() {
        // Set up test data if needed
        
        // Mock the parameter
        Integer selectedYear = 2024;
        
        // Call the method with the mock parameter
        Test.startTest();
        List<AggregateResult> result = SitevisitChartController.getSitevisitsQuaterly(selectedYear);
        Test.stopTest();
        
        // Assertions
        // Verify that the result list is not null
        System.assertNotEquals(null, result, 'Result should not be null');
        
        //System.assertEquals(expectedSize, result.size(), 'Result size should match');
        
    }    
    @isTest
    static void testGetBookingDataHalfYearly() {
        // Set up test data if needed
        
        Integer selectedYear = 2024;
        
        // Call the method with the mock parameter
        Test.startTest();
        List<AggregateResult> result = SitevisitChartController.getBookingDataHalfYearly(selectedYear);
        Test.stopTest();
        
        // Assertions
        // Verify that the result list is not null
        System.assertNotEquals(null, result, 'Result should not be null');
        
        
        
    }
    
    @isTest
    static void testGetSitevisitsHalfYearly() {
        // Set up test data if needed
        
        // Mock the parameter
        Integer selectedYear = 2024;
        
        // Call the method with the mock parameter
        Test.startTest();
        List<AggregateResult> result = SitevisitChartController.getSitevisitsHalfYearly(selectedYear);
        Test.stopTest();
        
        // Assertions
        // Verify that the result list is not null
        System.assertNotEquals(null, result, 'Result should not be null');
        
    }
    
    @isTest
    static void testGetBookingDataYearly() {
        // Set up test data if needed
        
        // Mock the parameter
        Integer selectedYear = 2024;
        
        // Call the method with the mock parameter
        Test.startTest();
        List<AggregateResult> result = SitevisitChartController.getBookingDataYearly(selectedYear);
        Test.stopTest();
        
        // Assertions
        // Verify that the result list is not null
        System.assertNotEquals(null, result, 'Result should not be null');
        
    }
    
    @isTest
    static void testGetSitevisitsYearly() {
        // Set up test data if needed
        
        // Mock the parameter
        Integer selectedYear = 2024;
        
        // Call the method with the mock parameter
        Test.startTest();
        List<AggregateResult> result = SitevisitChartController.getSitevisitsYearly(selectedYear);
        Test.stopTest();
        
        // Assertions
        // Verify that the result list is not null
        System.assertNotEquals(null, result, 'Result should not be null');
        
    }
    
    @isTest
    static void testGetUpcomingAllEvents() {
        // Set up test data if needed
        
        // Mock the parameter
        Test.startTest();
        List<Events__c> result = SitevisitChartController.getUpcomingAllEvents();
        Test.stopTest();
        
        // Assertions
        // Verify that the result list is not null
        System.assertNotEquals(null, result, 'Result should not be null');
    } 
    @isTest
    static void testGetUpcomingEvents() {
        // Test data setup
        // Add test data for Events__c object
        
        // Call the method with different record types
        List<String> recordTypes = new List<String>{'Open Houses', 'Road Shows', 'Business Trip', 'Video Shoots', 'All'};
            for (String recordType : recordTypes) {
                Map<String, Object> result = SitevisitChartController.getUpcomingEvents(recordType);
                System.assertNotEquals(null, result, 'Result should not be null');
            }
    }
    @isTest
    static void testGetSitevisitsCountLastSixMonths() {
        // Test data setup
        // Create test data for the Customer_Registration__c object with various Date__c values
        
        // Call the method
        Test.startTest();
        Integer result = SitevisitChartController.getSitevisitsCountLastSixMonths();
        Test.stopTest();
        
        // Assertions
        // Add  assertions here based on the expected behavior of the method
    }
    @isTest
    static void testGetSitevisitsCountLastThreeMonths() {
        // Test data setup
        // Create test data for the Customer_Registration__c object with various Date__c values
        
        // Call the method
        Test.startTest();
        Integer result = SitevisitChartController.getSitevisitsCountLastThreeMonths();
        Test.stopTest();
        
        // Assertions
        // Add  assertions here based on the expected behavior of the method
    }
    
    @isTest
    static void testGetSitevisitsCountInCurrentMonth() {
        // Test data setup
        // Create test data for the Customer_Registration__c object with various Date__c values
        
        // Call the method
        Test.startTest();
        Integer result = SitevisitChartController.getSitevisitsCountInCurrentMonth();
        Test.stopTest();
        
        // Assertions
        // Add your assertions here based on the expected behavior of the method
    }   
    
    @isTest
    static void testGetSitevisitsCountInCurrentYear() {
        // Test data setup
        // Create test data for the Customer_Registration__c object with various Date__c values
        
        // Call the method
        Test.startTest();
        Integer result = SitevisitChartController.getSitevisitsCountInCurrentYear();
        Test.stopTest();
        
        // Assertions
        // Add  assertions here based on the expected behavior of the method
    }
    @isTest
    static void testGetBookingsTotalInCurrentYear() {
        // Test data setup
        // Create test data for the Booking__c object with various Total_Purchase_Price__c and CreatedDate values
        
        // Call the method
        Test.startTest();
        Decimal result = SitevisitChartController.getBookingsTotalInCurrentYear();
        Test.stopTest();
        
        // Assertions
        // Add  assertions here based on the expected behavior of the method
    }
    @isTest
    static void testGetBookingsTotalInLastSixMonths() {
        // Test data setup
        // Create test data for the Booking__c object with various Total_Purchase_Price__c and CreatedDate values
        
        // Call the method
        Test.startTest();
        Decimal result = SitevisitChartController.getBookingsTotalInLastSixMonths();
        Test.stopTest();
        
        // Assertions
        // Add  assertions here based on the expected behavior of the method
    }
    
    @isTest
    static void testGetBookingsTotalInLastThreeMonths() {
        // Test data setup
        // Create test data for the Booking__c object with various Total_Purchase_Price__c and CreatedDate values
        
        // Call the method
        Test.startTest();
        Decimal result = SitevisitChartController.getBookingsTotalInLastThreeMonths();
        Test.stopTest();
        
        // Assertions
        // Add  assertions here based on the expected behavior of the method
    }
    
    @isTest
    static void testGetBookingsTotalInCurrentMonth() {
        // Test data setup
        // Create test data for the Booking__c object with various Total_Purchase_Price__c and CreatedDate values
        
        // Call the method
        Test.startTest();
        Decimal result = SitevisitChartController.getBookingsTotalInCurrentMonth();
        Test.stopTest();
        
        // Assertions
        // Add  assertions here based on the expected behavior of the method
    }  
    @isTest
    static void testGetLoggedInUserContactId() {
        // Create a test user
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User']; // Assuming you have a standard profile named 'Standard User'
        User testUser = new User(
            ProfileId = prof.Id,
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'TUser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;
        
        // Set the test user as the context user
        System.runAs(testUser) {
            // Call the method
            Test.startTest();
            Id result = SitevisitChartController.getLoggedInUserContactId();
            Test.stopTest();
            
            // Assertions
            // Verify that the method returns the Contact Id of the test user's contact
            System.assertEquals(testUser.ContactId, result, 'Contact Id should match');
        }
    }
    
    
    
    
    @isTest
    static void testGetBookingDataDetails() {
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;  
        
        // Test data setup
        // Create test data for the Booking__c object
        List<Booking__c> bookings = new List<Booking__c>();
        for(Integer i = 0; i < 5; i++) {
            // Create Booking__c records with required fields
            Booking__c booking = new Booking__c(
                Quotation__c=q.Id,
                Booking_Date__c = system.today()
                //  Unit__c ='WS01',
                //Nationality__c ='Indian',
                //Status__c='Processed',
                //Opportunity__c='Titana',
                //DLD_Amount__c ='69819.04',
                //Unit__c ='1BR ',
                //Booking_Date__c ='2023-08-25T13:18:16.000+0000',
                //Agreement_Value__c ='120000',
                //SPA_Executed__c ='To be Issued',
                //Signed_Status__c ='Booking Form Uploaded',
                //Paid_Percentage__c ='1.89',
                //Pre_registration__c='Completed',
                // Current_Status__c='Audit Accepted',
                //Tower_Name__c ='Waterside Plots-Waterside Plots',
                //Total_DLD_Amt_Paid__c='0',
                //Name='B-4012',
                // Channel_Partner__c ='DAVE Properties'
                
            );
            bookings.add(booking);
        }
        insert bookings;
        
        // Set up the logged-in user
        // Example: System.runAs(UserUtils.createStandardUser()) {
        // Set up the logged-in user's ContactId
        // Example: Test.setCurrentUser(UserUtils.createStandardUser());
        // Example: Test.setMock(Accessor.runAs, new User()); // If using RunAs
        
        Test.startTest();
        // Call the method
        List<Booking__c> result = SitevisitChartController.getBookingDataDetails();
        Test.stopTest();
        
        // Assertions
        // Verify that the result is not null
        System.assertNotEquals(null, result, 'Result should not be null');
        
    }
    
    
    @isTest
    static void testGetBookingMonthlyData() {
        // Mock the logged-in user's contact Id
        Id loggedInUserContactId = UserInfo.getUserId(); 
        
        // Set up test data (create Booking__c records with different Booking_Date__c values)
        
        Test.startTest();
        // Call the method with different input parameters
        List<AggregateResult> result1 = SitevisitChartController.getBookingMonthlyData(1, 3); // Assuming January to March
        List<AggregateResult> result2 = SitevisitChartController.getBookingMonthlyData(4, 6); // Assuming April to June
        
        Test.stopTest();
        
        
    }
    @isTest
    static void testGetSitevisitsMonthlyData() {
        // Mock the logged-in user's contact Id
        Id loggedInUserContactId = UserInfo.getUserId(); 
        
        // Set up test data (create Customer_Registration__c records with different Date__c values)
        
        Test.startTest();
        // Call the method with different input parameters
        
        List<AggregateResult> result1 = SitevisitChartController.getSitevisitsMonthlyData(1, 3); // Assuming January to March
        List<AggregateResult> result2 = SitevisitChartController.getSitevisitsMonthlyData(4, 6); // Assuming April to June
        
        Test.stopTest();
        
        
    }   
    @isTest
    static void testGetBookingFormUrl() {
        // Set up test data: create a ContentDocumentLink with LinkedEntityId and ContentDocument.Title
        
        // Mock the recordId and fileTitle parameters
        String recordId = 'a0P0K00000ABCDEF123';
        String fileTitle = 'Test File';
        
        // Create ContentDocumentLink records related to the provided recordId and fileTitle
        
        Test.startTest();
        // Call the method with the mock parameters
        //String resultUrl = SitevisitChartControllerTest.getBookingFormUrl(recordId, fileTitle);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testGetBookingCount() {
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;  
        // Test data setup
        // Create test data for the Booking__c object
        List<Booking__c> bookings = new List<Booking__c>();
        for(Integer i = 0; i < 5; i++) {
            // Create Booking__c records with required fields
            Booking__c booking = new Booking__c(
                Quotation__c=q.Id,
                Booking_Date__c = system.today()
                // Populate required fields as needed
                // Example: Unit__c = 'UnitId'
            );
            bookings.add(booking);
        }
        insert bookings;
        //Test.setCurrentPage(PageReferenceUtils.createPageReference('TestPage')); // Assuming there's a page named 'TestPage'
        //System.assertEquals(testUser.ContactId, UserInfo.getContactId());
        
        Test.startTest();
        // Calling the method with different parameters to cover all if conditions
        // 1. Test with frequency = 'month'
        Map<String, Integer> monthResponse = SitevisitChartController.getBookingCount(new List<String>{}, 'month', new List<Integer>{2022}, new List<Integer>{1}, 2022);
        
        
        // 2. Test with frequency = 'quarter'
        Map<String, Integer> quarterResponse = SitevisitChartController.getBookingCount(new List<String>{}, 'quarter', new List<Integer>{2022}, new List<Integer>{}, 2022);
        
        
        // 3. Test with frequency = 'biyear'
        Map<String, Integer> biyearResponse = SitevisitChartController.getBookingCount(new List<String>{}, 'biyear', new List<Integer>{2022}, new List<Integer>{}, 2022);
        
        
        // 4. Test with frequency = 'year'
        Map<String, Integer> yearResponse = SitevisitChartController.getBookingCount(new List<String>{}, 'year', new List<Integer>{2022}, new List<Integer>{}, 2022);
        // Add assertions to verify the returned map for the 'year' scenario
        //SitevisitChartController.getBookingsInSelectedMonth(new List<Integer>{2},new List<String>{'Apartments'});
        Test.stopTest();
    }
    @AuraEnabled 
    public static Decimal getBookingsInSelectedMonth(list<Integer> months, List<String> TypeValue){
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        List<AggregateResult> results = new List<AggregateResult>();
        if(TypeValue.size() > 0 && months.size() > 0){
            results =   [SELECT SUM(Total_Purchase_Price__c) totalPriceSum
                         FROM Booking__c WHERE  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                         CALENDAR_MONTH(Booking_Date__c) in :months AND  Unit__c IN (
                             SELECT Id FROM Unit__c WHERE Tower__r.Tower_Type__c in :TypeValue) AND CALENDAR_YEAR(CreatedDate) = :currentYear];  
        }
        else  if(TypeValue.size() == 0 && months.size() > 0){
            results =   [SELECT SUM(Total_Purchase_Price__c) totalPriceSum FROM Booking__c
                         WHERE  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                         CALENDAR_MONTH(Booking_Date__c) in :months AND  
                         CALENDAR_YEAR(CreatedDate) = :currentYear];   
        }
        else if(TypeValue.size() > 0){
            results =   [SELECT SUM(Total_Purchase_Price__c) totalPriceSum
                         FROM Booking__c WHERE  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                         Unit__c IN (
                             SELECT Id FROM Unit__c WHERE Tower__r.Tower_Type__c in :TypeValue) AND CALENDAR_YEAR(CreatedDate) = :currentYear];  
        }
        else{
            results =   [SELECT SUM(Total_Purchase_Price__c) totalPriceSum FROM Booking__c
                         WHERE  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                         CALENDAR_YEAR(CreatedDate) = :currentYear];   
        }
        
        if (!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else { 
            return 0;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Id getLoggedInUserContactId() {
        List<User> userList = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if (!userList.isEmpty()) {
            system.debug('userList[0].ContactId'+userList[0].ContactId);
            return userList[0].ContactId;
        } else {
            system.debug('NULLL');
            return null; // Handle the case where no user is found with the given Id
        }
    }
}