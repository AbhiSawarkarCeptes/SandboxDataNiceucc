/***************************************************************************
Class      : Nice_PhoneValidationUtilityTest
Purpose    : NICE - Test class for Nice_PhoneValidationUtilityTest 
Author     : Abhijeet
*****************************************************************************/

@IsTest
public class Nice_PhoneValidationUtilityTest {
    @IsTest
    static void testValidatePhoneNumberSuccess() {
        // Mock the HTTP callout for a` successful response
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(true, false));
        
        // Call the method to test
        String phoneNumber = '1234567890';
        String response = Nice_PhoneValidationUtility.validatePhoneNumber(phoneNumber);
        
        // Parse the response to verify expected results
        Nice_PhoneValidationUtility.PhoneValidationResponse responseObj = (Nice_PhoneValidationUtility.PhoneValidationResponse) JSON.deserialize(response, Nice_PhoneValidationUtility.PhoneValidationResponse.class);
        
        // Assertions for all fields in PhoneValidationResponse
        System.assertEquals(true, responseObj.valid, 'Valid flag does not match');
        System.assertEquals('1234567890', responseObj.mobNumber, 'Mobile number does not match');
        System.assertEquals('123-456-7890', responseObj.local_format, 'Local format does not match');
        System.assertEquals('+1 123-456-7890', responseObj.international_format, 'International format does not match');
        System.assertEquals('+1', responseObj.country_prefix, 'Country prefix does not match');
        System.assertEquals('US', responseObj.country_code, 'Country code does not match');
        System.assertEquals('United States', responseObj.country_name, 'Country name does not match');
        System.assertEquals('New York', responseObj.location, 'Location does not match');
        System.assertEquals('Verizon', responseObj.carrier, 'Carrier does not match');
        System.assertEquals('mobile', responseObj.line_type, 'Line type does not match');
    }
    
    @IsTest
    static void testValidatePhoneNumberErrorStatusCode() {
        // Mock the HTTP callout with a non-200 status code
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(false, false));
        
        // Call the method to test
        String phoneNumber = 'invalid';
        String response = Nice_PhoneValidationUtility.validatePhoneNumber(phoneNumber);
        
        // Parse the response to verify expected error
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        
        // Assertions for error handling
        System.assert(responseMap.containsKey('error'), 'Error key should be present in response');
        System.assert(responseMap.get('error').toString().contains('Error: Received status code'), 'Error message mismatch');
    }

    @IsTest
    static void testValidatePhoneNumberException() {
        // Mock the HTTP callout to throw an exception
        Test.setMock(HttpCalloutMock.class, new Nice_PhoneValidationMock(false, true));
        
        // Call the method to test
        String phoneNumber = 'exception';
        String response = Nice_PhoneValidationUtility.validatePhoneNumber(phoneNumber);
        
        // Parse the response to verify expected exception handling
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        
        // Assertions for exception handling
        System.assert(responseMap.containsKey('error'), 'Error key should be present in response');
        System.assert(responseMap.get('error').toString().contains('Exception:'), 'Exception message mismatch');
    }

}