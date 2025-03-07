/******************************************************
Class : Nice_EmailValidationUtilityTest
Purpose : Test class for Nice_EmailValidationUtility
Author : Ayaz Anis 
*******************************************************/
@IsTest
public class Nice_EmailValidationUtilityTest {
    @IsTest
    static void testValidateEmailSuccess() {
        // Mock the HTTP callout for a successful response
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(true, false));
        
        // Call the method to test
        String emailAddress = 'test@example.com';
        String response = Nice_EmailValidationUtility.validateEmail(emailAddress);
        
         // Parse the response to verify expected results
        Nice_EmailValidationUtility.EmailValidationResponse responseMap = (Nice_EmailValidationUtility.EmailValidationResponse) JSON.deserialize(response, Nice_EmailValidationUtility.EmailValidationResponse.class);
        
        // Assertions for all fields in EmailValidationResponse
        System.assertEquals('test@example.com', responseMap.email, 'Email does not match');
        System.assertEquals('test', responseMap.user, 'User does not match');
        System.assertEquals('example.com', responseMap.domain, 'Domain does not match');
        System.assertEquals(true, responseMap.syntax_valid, 'Syntax valid does not match');
        System.assertEquals(false, responseMap.is_disposable, 'Disposable flag does not match');
        System.assertEquals(false, responseMap.is_role_account, 'Role account flag does not match');
        System.assertEquals(false, responseMap.is_catch_all, 'Catch all flag does not match');
        System.assertEquals(true, responseMap.is_deliverable, 'Deliverable flag does not match');
        System.assertEquals(true, responseMap.can_connect_smtp, 'Can connect SMTP does not match');
        System.assertEquals('No', responseMap.is_inbox_full, 'Inbox full status does not match');
        System.assertEquals('No', responseMap.is_disabled, 'Disabled status does not match');
        System.assertEquals(true, responseMap.mx_records, 'MX records flag does not match');
        System.assertEquals(false, responseMap.free, 'Free flag does not match');
        System.assertEquals(0.95, responseMap.score, 'Score does not match');
    }
    
    @IsTest
    static void testValidateEmailErrorStatusCode() {
        // Mock the HTTP callout with a non-200 status code
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(false, false));
        
        // Call the method to test
        String emailAddress = 'invalid@example.com';
        String response = Nice_EmailValidationUtility.validateEmail(emailAddress);
        
        // Parse the response to verify expected error
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        
        // Assertions for error handling
        System.assert(responseMap.containsKey('error'), 'Error key should be present in response');
        System.assert(responseMap.get('error').toString().contains('Error: Received status code'), 'Error message mismatch');
    }

    @IsTest
    static void testValidateEmailException() {
        // Mock the HTTP callout to throw an exception
        Test.setMock(HttpCalloutMock.class, new Nice_EmailValidationMock(false, true));
        
        // Call the method to test
        String emailAddress = 'exception@example.com';
        String response = Nice_EmailValidationUtility.validateEmail(emailAddress);
        
        // Parse the response to verify expected exception handling
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        
        // Assertions for exception handling
        System.assert(responseMap.containsKey('error'), 'Error key should be present in response');
        System.assert(responseMap.get('error').toString().contains('Exception:'), 'Exception message mismatch');
    }

    
}