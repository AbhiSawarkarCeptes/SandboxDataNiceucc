@isTest
private class NICEResidentInfoRestResourceTest {
    @testSetup
    static void setupTestData() {
        // Check if Person Accounts are enabled
        Boolean isPersonAccountEnabled = Schema.sObjectType.Account.fields.getMap().containsKey('IsPersonAccount');
        
        // Create a test account with phone and email (Business or Person)
        Account testAccount;
        if (isPersonAccountEnabled) {
            testAccount = new Account(
                FirstName = 'John',
                LastName = 'Doe',
                PersonEmail = 'john.doe@example.com',
                Phone = '+971501234567'
            );
        } else {
            testAccount = new Account(
                Name = 'John Doe',
                Email__c = 'john.doe@example.com',  // Custom field for Business Accounts
                Phone = '+971501234567'
            );
        }
        
        insert testAccount;
    }

    @isTest
    static void testSearchMobileNumber_NoRecordsFound() {
        // Prepare mock request data with non-matching phone/email
        NICEResidentInfoRestResource.ResidentRequestClass requestData = new NICEResidentInfoRestResource.ResidentRequestClass();
        requestData.firstName = 'No';
        requestData.lastName = 'Match';
        requestData.primaryMobileCountryCode = '+971';
        requestData.primaryMobileNumber = '999999999'; // Non-matching phone
        requestData.primaryEmail = 'no.match@example.com'; // Non-matching email

        String requestBody = JSON.serialize(requestData);

        // Mock HTTP request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        String responseBody = NICEResidentInfoRestResource.searchMobileNumber();
        Test.stopTest();

        // Verify response
        System.assertEquals(404, res.statusCode, 'Status code should be 404 for no records found');
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        System.assertEquals('No records found with the provided phone number or email', 
                          (String)responseMap.get('message'), 'Response should contain correct error message');
    }

    @isTest
    static void testSearchMobileNumber_EmailMatch() {
        // Prepare mock request data with matching email
        NICEResidentInfoRestResource.ResidentRequestClass requestData = new NICEResidentInfoRestResource.ResidentRequestClass();
        requestData.firstName = 'John';
        requestData.lastName = 'Doe';
        requestData.primaryEmail = 'john.doe@example.com'; // Matching email

        String requestBody = JSON.serialize(requestData);

        // Mock HTTP request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        String responseBody = NICEResidentInfoRestResource.searchMobileNumber();
        Test.stopTest();

        // Verify response
        System.assertEquals(200, res.statusCode, 'Status code should be 200 for successful match');
        
        // Verify resident record was created
        Resident__c[] residents = [SELECT Id FROM Resident__c WHERE Email__c = 'john.doe@example.com'];
        System.assertEquals(1, residents.size(), 'Resident record should be created for email match');
        
        // Verify response contains record ID
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        System.assert(responseMap.containsKey('RecordId'), 'Response should contain RecordId');
    }

    // Other test methods remain unchanged...
}
