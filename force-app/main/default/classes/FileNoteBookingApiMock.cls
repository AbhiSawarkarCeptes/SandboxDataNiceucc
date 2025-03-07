@isTest
global class FileNoteBookingApiMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"success\":true,\"statusCode\":200,\"errorMessage\":null,\"bookingData\":{\"unit_number\":\"O-1710\",\"SPA_status\":\"TobeIssued\",\"sales_manager\":\"TanviShah\",\"sales_head\":\"TanviShah\",\"saleable_area\":744.33,\"purchase_price_AED\":100000.00,\"project\":\"SobhaHartland\",\"pre_registration_status\":\"Pre-RegistrationPending\",\"paid_percentage\":70.05,\"nationality\":\"Indian\",\"customer_paid_AED\":70050.00,\"customer_name\":\"TanuK,Tanvi,Ankit\",\"broker_name\":\"PROPERTYJUNCTIONINTERNATIONALREALESTATEBROKERLLC\",\"booking_id\":\"a065t000000NB49AAG\",\"booking_date\":\"2022-08-31T06:43:14.000Z\"}}');
        response.setStatusCode(200);
        return response; 
    }
}