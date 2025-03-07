/******************************************************
Class : Nice_PhoneValidationMock
Purpose : Nice- Mock Class for Phone validation scenerio
Author : Ayaz Anis
*******************************************************/
@isTest
public class Nice_PhoneValidationMock implements HttpCalloutMock {
        private Boolean isSuccess;
        private Boolean throwException;
        
        public Nice_PhoneValidationMock(Boolean isSuccess, Boolean throwException) {
            this.isSuccess = isSuccess;
            this.throwException = throwException;
        }
        
        public HttpResponse respond(HttpRequest req) {
            if (throwException) {
                throw new CalloutException('Simulated callout exception');
            }
            
            HttpResponse res = new HttpResponse();
            if (isSuccess) {
                res.setStatusCode(200);
                res.setBody('{"valid": true, "mobNumber": "1234567890", "local_format": "123-456-7890", "international_format": "+1 123-456-7890", "country_prefix": "+1", "country_code": "US", "country_name": "United States", "location": "New York", "carrier": "Verizon", "line_type": "mobile"}');
            } else {
                res.setStatusCode(400);
                res.setBody('{"error": "Invalid phone number"}');
            }
            return res;
        }
}