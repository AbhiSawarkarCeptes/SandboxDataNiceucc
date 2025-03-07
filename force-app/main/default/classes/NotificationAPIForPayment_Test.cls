@isTest
public class NotificationAPIForPayment_Test {

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(responseBody);
            return response;
        }
    }
    
    @isTest
    public static void testSendnotificationsPayment(){
        
        NotificationAPIForPayment.Payload pay = new NotificationAPIForPayment.Payload();
        pay.payloadBooking = '12345';
        pay.slug = 'test_template_slug';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"status":"success"}'));
        NotificationAPIForPayment.sendnotificationsPayment('test_template_slug','test@example.com',pay,'test_type');
        Test.stopTest();
    }
    
    @isTest
    public static void testSendnotificationsPaymentError(){
        
        NotificationAPIForPayment.Payload pay = new NotificationAPIForPayment.Payload();
        pay.payloadBooking = '12345';
        pay.slug = 'test_template_slug';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, '{"status":"failed"}'));
        NotificationAPIForPayment.sendnotificationsPayment('test_template_slug','test@example.com',pay,'test_type');
        Test.stopTest();
    }
}