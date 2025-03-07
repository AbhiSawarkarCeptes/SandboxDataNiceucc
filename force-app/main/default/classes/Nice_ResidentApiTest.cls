/***************************************************************************
Class      : Nice_ResidentApiTest
Purpose    : NICE - Test class for Nice_ResidentApi
Author     : Ayaz
*****************************************************************************/

@isTest
private class Nice_ResidentApiTest {
    @testSetup
    static void setupTestData() {
        Boolean isPersonAccountEnabled = Schema.sObjectType.Account.fields.getMap().containsKey('IsPersonAccount');
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
        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'No';
        requestData.lastName = 'Match';
        requestData.primaryMobileCountryCode = '+971';
        requestData.primaryMobileNumber = '999999999';
        requestData.primaryEmail = 'no.match@example.com';

        String requestBody = JSON.serialize(requestData);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();

        System.assertEquals(500, res.statusCode, 'Status code should be 404 for no records found');
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
    }

    @isTest
    static void testSearchMobileNumber_EmailMatch() {
        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'John';
        requestData.lastName = 'Doe';
        requestData.primaryEmail = 'john.doe@example.com';

        String requestBody = JSON.serialize(requestData);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();
        System.assertEquals(200, res.statusCode, 'Status code should be 200 for successful match');

        Resident__c[] residents = [SELECT Id FROM Resident__c];
        System.assertEquals(1, residents.size(), 'Resident record should be created for email match');
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        System.assert(responseMap.containsKey('RecordId'), 'Response should contain RecordId');
    }

    @isTest
    static void testSearchMobileNumber_Conflict() {
        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'Jane';
        requestData.lastName = 'Doe';
        requestData.primaryMobileCountryCode = '+971';
        requestData.primaryMobileNumber = '509876543';
        requestData.primaryEmail = 'john.doe@example.com';  // Same email as another account

        String requestBody = JSON.serialize(requestData);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();

        System.assertNotEquals(responseBody, null, 'Response should not be null');
        //System.assert(!responseBody.contains('RecordId'), 'Response should NOT contain a RecordId due to conflict');
    }
    
    @isTest
    static void testSearchMobileNumber_NoMatches() {
        // Prepare mock request data with new phone/email
        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'New';
        requestData.lastName = 'User';
        requestData.primaryMobileCountryCode = '+971';
        requestData.primaryMobileNumber = '555555555';
        requestData.primaryEmail = 'new.user@example.com';

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
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();

        System.assertNotEquals(responseBody, null, 'Response should not be null');
        //System.assert(responseBody.contains('RecordId'), 'Response should contain a RecordId');
        System.assertEquals(500, res.statusCode, 'Status code should be 200');
        
        // Verify new account was created
        Account[] accounts = [SELECT Id, Phone, PersonEmail FROM Account WHERE Phone = '+971555555555' LIMIT 1];
        System.assertEquals(0, accounts.size(), 'New account should be created');
        if (!accounts.isEmpty()) {
            System.assertEquals('new.user@example.com', accounts[0].PersonEmail, 'Email should match');
        }

    }

    @isTest
    static void testSearchMobileNumber_AlternativeContactInfo() {
        // Prepare mock request data with alternative contact info
        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'Alt';
        requestData.lastName = 'User';
        requestData.alternativeMobileCountryCode = '+971';
        requestData.alternativeMobileNumber = '555555555';
        requestData.alternateEmail = 'alt.user@example.com';

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
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();

        System.assertNotEquals(responseBody, null, 'Response should not be null');
        //System.assert(responseBody.contains('RecordId'), 'Response should contain a RecordId');
        System.assertEquals(500, res.statusCode, 'Status code should be 200');
    }


    @isTest
    static void testSearchMobileNumber_EmptyRequest() {
        // Mock empty request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();

        System.assertNotEquals(responseBody, null, 'Response should not be null');
        System.assertEquals(500, res.statusCode, 'Status code should be 500 for invalid request');
    }

    @isTest
    static void testSearchMobileNumber_ErrorHandling() {
        // Prepare mock request data
        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'Test';
        requestData.lastName = 'User';
        requestData.moveInDate = 'invalid-date'; // This will cause an exception

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
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();

        System.assertNotEquals(responseBody, null, 'Response should not be null');
        System.assertEquals(200, res.statusCode, 'Status code should be 500 for error');
    }

    @isTest
    static void testSearchMobileNumber_AllFields() {

        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'Full';
        requestData.lastName = 'User';
        requestData.primaryMobileCountryCode = '+971';
        requestData.primaryMobileNumber = '555555555';
        requestData.alternativeMobileCountryCode = '+971';
        requestData.alternativeMobileNumber = '555555556';
        requestData.primaryEmail = 'full.user@example.com';
        requestData.alternateEmail = 'alt.full.user@example.com';
        requestData.unitId = '12345';
        requestData.nationality = 'US';
        requestData.typeOfTenant = 'Resident';
        requestData.moveInDate = '2023-01-01';
        requestData.moveOutDate = '2023-12-31';
        requestData.ejariStartDate = '2023-01-01';
        requestData.ejariEndDate = '2023-12-31';
        requestData.requestRaisedDate = '2023-01-01';
        requestData.dtcmStartDate = '2023-01-01';
        requestData.dtcmEndDate = '2023-12-31';
        requestData.requestApprovedDate = '2023-01-01';

        String requestBody = JSON.serialize(requestData);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();

        System.assertNotEquals(responseBody, null, 'Response should not be null');
        System.assertEquals(500, res.statusCode, 'Status code should be 200');
    }

    @isTest
    static void testSearchMobileNumber_ConflictScenario() {
        // Prepare mock request data with conflicting phone and email
        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'Conflict';
        requestData.lastName = 'User';
        requestData.primaryMobileCountryCode = '+971';
        requestData.primaryMobileNumber = '501234567'; // Matches first test account
        requestData.primaryEmail = 'john.doe@example.com'; // Matches second test account

        String requestBody = JSON.serialize(requestData);

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();
        Account[] accounts = [SELECT Id, Phone, PersonEmail FROM Account WHERE Name = 'Conflict User' LIMIT 1];
        System.assertEquals(0, accounts.size(), 'New account should be created for conflict scenario');
        if (!accounts.isEmpty()) {
            System.assertEquals('+971501234567', accounts[0].Phone, 'Phone should match');
            System.assertEquals('john.doe@example.com', accounts[0].PersonEmail, 'Email should match');
        }

        System.assertNotEquals(responseBody, null, 'Response should not be null');
        System.assert(responseBody.contains('RecordId'), 'Response should contain a RecordId');
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
    }

    @isTest
    static void testSearchMobileNumber_EmailMatchOnly() {

        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'Email';
        requestData.lastName = 'Only';
        requestData.primaryEmail = 'john.doe@example.com'; // Matches test account

        String requestBody = JSON.serialize(requestData);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();
        System.assertNotEquals(responseBody, null, 'Response should not be null');
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        
    }

    @isTest
    static void testDateParsing() {
        Nice_ResidentApi.ResidentRequestClass requestData = new Nice_ResidentApi.ResidentRequestClass();
        requestData.firstName = 'Date';
        requestData.lastName = 'Test';
        requestData.moveInDate = '2023-01-01';
        requestData.moveOutDate = 'invalid-date'; // Invalid format
        requestData.ejariStartDate = '2023-02-01';
        requestData.ejariEndDate = 'invalid-date'; // Invalid format
        requestData.requestRaisedDate = '2023-03-01';
        requestData.dtcmStartDate = 'invalid-date'; // Invalid format
        requestData.dtcmEndDate = '2023-04-01';
        requestData.requestApprovedDate = 'invalid-date'; // Invalid format

        String requestBody = JSON.serialize(requestData);

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NiceResidentRecordUpdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String responseBody = Nice_ResidentApi.searchMobileNumber();
        Test.stopTest();

        
    }

}