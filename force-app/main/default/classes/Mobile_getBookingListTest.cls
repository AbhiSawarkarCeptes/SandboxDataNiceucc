@isTest
private class Mobile_getBookingListTest {

    @testSetup
    static void setupTestData() {
        Mobile_TestUtil.createBooking();
    }

    @isTest
    static void testGetBookingListWithRecords() {
        // Test the case where there are records in the database
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/getBookingList';
        request.httpMethod = 'POST';
        // Set the request body, e.g., JSON with the email parameter

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Mobile_getBookingList.getBookingList('test@example.com');
        Test.stopTest();

        // Assert the response status code and any other expected results
        System.assertEquals(200, response.statusCode);
        // Add more assertions as needed
    }

    @isTest
    static void testGetBookingListWithoutRecords() {
        // Test the case where there are no records in the database
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/getBookingList';
        request.httpMethod = 'POST';
        // Set the request body, e.g., JSON with the email parameter

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Mobile_getBookingList.getBookingList('nonexistent@example.com');
        Test.stopTest();

        // Assert the response status code and any other expected results
        System.assertEquals(200, response.statusCode);
        // Add more assertions as needed
    }

    @isTest
    static void testGetBookingListWithException() {
        // Test the case where an exception is thrown in the code
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/getBookingList';
        request.httpMethod = 'POST';
        // Set the request body, e.g., JSON with the email parameter

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        // Simulate an exception by passing a null email parameter
        Mobile_getBookingList.getBookingList(null);
        Test.stopTest();

        // Assert the response status code and any other expected results
        System.assertEquals(200, response.statusCode);
        // Add more assertions as needed
    }
}