@isTest
public with sharing class Mobile_getScheduleAppointmentTest {

    @isTest
    static void testScheduleAppointments() {
        Mobile_TestUtil.createBooking();
        Booking__c b = [Select id From Booking__c limit 1];
        // Set up the request parameters
        String bookingId = b.id;
        String apntType = 'HandOver';
        Date scheduleDate = Date.today();
        String timing = '7 PM - 8 PM';
        String remarks = 'Test remarks';        
        
        Time_Slot_For_Handover__c tfh = new Time_Slot_For_Handover__c();
        tfh.Status__c = '';
        tfh.Remarks__c = 'Test remarks';
        tfh.Scheduled_Date__c = Date.today();
        tfh.QT_Keepout_Date__c = Date.today();
        tfh.Booking__c = b.id;
        tfh.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'HandOver'].id;
        insert tfh;

        // Create a RestRequest object and set the request parameters
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/getScheduleAppointment';
        req.httpMethod = 'POST';
        RestContext.request = req;

        RestContext.request.params.put('bookingId', bookingId);
        RestContext.request.params.put('apntType', apntType);
        RestContext.request.params.put('scheduleDate', String.valueOf(scheduleDate));
        RestContext.request.params.put('timing', timing);
        RestContext.request.params.put('remarks', remarks);

        // Call the REST service
        Mobile_getScheduleAppointment.HttpResponseWrapper response = Mobile_getScheduleAppointment.getPaymentReceipts(bookingId, apntType, scheduleDate, timing, remarks);

    }
    
    @isTest
    static void testScheduleAppointments2() {
        Mobile_TestUtil.createBooking();
        Booking__c b = [Select id From Booking__c limit 1];
        // Set up the request parameters
        String bookingId = b.id;
        String apntType = 'HandOver';
        Date scheduleDate = Date.today();
        String timing = '8 PM - 9 PM';
        String remarks = 'Test remarks';        
        
        Time_Slot_For_Handover__c tfh = new Time_Slot_For_Handover__c();
        tfh.Status__c = '';
        tfh.Scheduled_Date__c = Date.today();
        tfh.QT_Keepout_Date__c = Date.today();
        tfh.Booking__c = b.id;
        tfh.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'HandOver'].id;
        insert tfh;

        // Create a RestRequest object and set the request parameters
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/getScheduleAppointment';
        req.httpMethod = 'POST';
        RestContext.request = req;

        RestContext.request.params.put('bookingId', bookingId);
        RestContext.request.params.put('apntType', apntType);
        RestContext.request.params.put('scheduleDate', String.valueOf(scheduleDate));
        RestContext.request.params.put('timing', timing);
        RestContext.request.params.put('remarks', remarks);

        // Call the REST service
        Mobile_getScheduleAppointment.HttpResponseWrapper response = Mobile_getScheduleAppointment.getPaymentReceipts(bookingId, apntType, scheduleDate, timing, remarks);

    }
    
    @isTest
    static void testScheduleAppointments3() {
        Mobile_TestUtil.createBooking();
        Booking__c b = [Select id From Booking__c limit 1];
        // Set up the request parameters
        String bookingId = b.id;
        String apntType = 'HandOver';
        Date scheduleDate = Date.today();
        String timing = '8 PM - 9 PM';
        String remarks = 'Test remarks';        
        
        Time_Slot_For_Handover__c tfh = new Time_Slot_For_Handover__c();
        tfh.Status__c = 'Confirmed';
        tfh.Scheduled_Date__c = Date.today();
        tfh.QT_Keepout_Date__c = Date.today();
        tfh.Booking__c = b.id;
        tfh.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'HandOver'].id;
        insert tfh;

        // Create a RestRequest object and set the request parameters
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/getScheduleAppointment';
        req.httpMethod = 'POST';
        RestContext.request = req;

        RestContext.request.params.put('bookingId', bookingId);
        RestContext.request.params.put('apntType', apntType);
        RestContext.request.params.put('scheduleDate', String.valueOf(scheduleDate));
        RestContext.request.params.put('timing', timing);
        RestContext.request.params.put('remarks', remarks);

        // Call the REST service
        Mobile_getScheduleAppointment.HttpResponseWrapper response = Mobile_getScheduleAppointment.getPaymentReceipts(bookingId, apntType, scheduleDate, timing, remarks);

    }
}