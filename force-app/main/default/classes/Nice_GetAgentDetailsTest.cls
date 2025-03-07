@isTest
private class Nice_GetAgentDetails_Test {

    // Test data setup
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Booking__c booking = new Booking__c(Account__c = acc.Id);
        insert booking;
        
        Applicant_Details__c app = new Applicant_Details__c(
            Account__c = acc.Id,
            Booking__c = booking.Id
        );
        insert app;
        
        User testUser = new User(
            Alias = 'test',
            Email = 'test@test.com',
            Nice_User_ID__c = 'AGENT123'
        );
        insert testUser;
        
        Collector_Assignment__c coll = new Collector_Assignment__c(
            Booking__c = booking.Id,
            User__c = testUser.Id
        );
        insert coll;
    }

    // Test successful agent details retrieval
    @isTest
    static void testGetAgentDetails_Success() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Nice_GetAgentDetails/' + acc.Id;
        RestContext.request = req;
        
        String response = Nice_GetAgentDetails.getAgentDetails();
        System.assertEquals(200, RestContext.response.statusCode);
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.assert(responseMap.containsKey('AgentId'));
        Test.stopTest();
    }

    // Test missing accountId scenario
    @isTest
    static void testGetAgentDetails_MissingAccountId() {
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Nice_GetAgentDetails/';
        RestContext.request = req;
        
        String response = Nice_GetAgentDetails.getAgentDetails();
        System.assertEquals(400, RestContext.response.statusCode);
        Test.stopTest();
    }

    // Test no bookings found scenario
    @isTest
    static void testGetAgentDetails_NoBookings() {
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Nice_GetAgentDetails/' + acc.Id;
        RestContext.request = req;
        
        String response = Nice_GetAgentDetails.getAgentDetails();
        System.assertEquals(206, RestContext.response.statusCode);
        Test.stopTest();
    }

    // Test getAccountById method
    @isTest
    static void testGetAccountById_Success() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Nice_GetAgentDetails/getAccountById/' + acc.Id;
        RestContext.request = req;
        
        Nice_GetAgentDetails.getAccountById();
        System.assertEquals(200, RestContext.response.statusCode);
        Test.stopTest();
    }

    // Test exception handling
    @isTest
    static void testGetAgentDetails_ExceptionHandling() {
        Test.startTest();
        
        // Mock SOQL results to throw an exception
        Test.setFixedSearchResults(new List<Id>{
            '001UB00000Ghkj8YAB', // Account Id
            'a01UB00000GhY2iYAF',  // Applicant Id
            'a06UB00000Cg7cUYAR',  // Booking Id
            'a7yUB0000001IanYAE'   // Collector Assignment Id
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Passing an invalid ID format to trigger an exception
        req.requestURI = '/services/apexrest/Nice_GetAgentDetails/INVALID_ID';
        RestContext.request = req;
        RestContext.response = res;

        String response = Nice_GetAgentDetails.getAgentDetails();
        System.assert(response != null);
        System.assertEquals(500, RestContext.response.statusCode);
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.assert(responseMap.containsKey('message'));
        Test.stopTest();
    }
}
