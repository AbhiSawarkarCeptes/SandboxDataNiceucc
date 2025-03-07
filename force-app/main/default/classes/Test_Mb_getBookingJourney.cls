@isTest
public class Test_Mb_getBookingJourney {
    
    @testSetup
    static void setupTestData() {
        Mobile_TestUtil.createBooking();
    }
    
    @isTest
    static void testGetBookingListWithRecords() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/getBookingJourney';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<booking__c> book = [select id, name from booking__c];

        Test.startTest();
        Mobile_getBookingJourney.getBookingJourney(book[0].Id);
        Test.stopTest();
        
        System.assertEquals(200, response.statusCode);
    }
    
    @isTest
    static void testGetBookingListWithRecords2() {
         RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/getBookingJourney';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<booking__c> book = [select id, name from booking__c];
        
        

        Time_Slot_For_Handover__c tsh = new Time_Slot_For_Handover__c();
        tsh.recordTypeId = Schema.SObjectType.Time_Slot_For_Handover__c.getRecordTypeInfosByName().get('Home Orientation').getRecordTypeId();
        tsh.Booking__c = book[0].Id;
        tsh.QT_Keepout_Date__c = Date.valueOf('2023-09-09'); 
        insert tsh;
        
        Test.startTest();
        Mobile_getBookingJourney.getBookingJourney(book[0].Id);
        Test.stopTest();
        
        System.assertEquals(200, response.statusCode);
        
    }
    
    @isTest
    static void testGetBookingListWithRecords3() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/getBookingJourney';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<booking__c> book = [select id, name from booking__c];
        
        

        Time_Slot_For_Handover__c tsh = new Time_Slot_For_Handover__c();
        tsh.recordTypeId = Schema.SObjectType.Time_Slot_For_Handover__c.getRecordTypeInfosByName().get('HandOver').getRecordTypeId();
        tsh.Booking__c = book[0].Id;
        tsh.QT_Keepout_Date__c = Date.valueOf('2023-09-09'); 
        insert tsh;
        
        Test.startTest();
        Mobile_getBookingJourney.getBookingJourney(book[0].Id);
        Test.stopTest();
        
        System.assertEquals(200, response.statusCode);
    }

}