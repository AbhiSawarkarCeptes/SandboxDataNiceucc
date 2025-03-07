/******************************************************
Class : Nice_EmailValidationMock
Purpose : NICE - Mock Class for Email verification API
Author : Ayaz Anis
*******************************************************/
@isTest
public class Nice_EmailValidationMock implements HttpCalloutMock{
    private Boolean isSuccess;
        private Boolean throwException;
        
        public Nice_EmailValidationMock(Boolean isSuccess, Boolean throwException) {
            this.isSuccess = isSuccess;
            this.throwException = throwException;
        }
        
        public HttpResponse respond(HttpRequest req) {
            if (throwException) {
                // Simulate an exception during the HTTP callout
                throw new CalloutException('Simulated callout exception');
            }
            
            HttpResponse res = new HttpResponse();
            if (isSuccess) {
                // Simulate a successful response with all the fields
                res.setStatusCode(200);
                res.setBody('{"email": "test@example.com", "user": "test", "domain": "example.com", "syntax_valid": true, "is_disposable": false, "is_role_account": false, "is_catch_all": false, "is_deliverable": true, "can_connect_smtp": true, "is_inbox_full": "No", "is_disabled": "No", "mx_records": true, "free": false, "score": 0.95}');
            } else {
                // Simulate an error response with non-200 status code
                res.setStatusCode(400);
                res.setBody('{"error": "Invalid email address"}');
            }
            return res;
        }
}