/******************************************************
    Class : Nice_FieldMaskingUtility
    Test Class : Nice_FieldMaskingUtilityTest
    Purpose : NICE - Masks an email address by replacing the middle part of the local part (before the '@')
    Author : Artee Verma
*******************************************************/

@isTest
public class Nice_FieldMaskingUtilityTest {

    @isTest
    static void testMaskEmail() {
        // Test with valid email
        String email = 'testemail@example.com';
        String maskedEmail = Nice_FieldMaskingUtility.maskEmail(email);
        System.assertEquals('te*****il@example.com', maskedEmail, 'Email masking failed for valid email.');

        // Test with short local part
        String shortEmail = 'ab@domain.com';
        String maskedShortEmail = Nice_FieldMaskingUtility.maskEmail(shortEmail);
        System.assertEquals('ab@domain.com', maskedShortEmail, 'Email masking failed for short email.');

        // Test with invalid email (no @ symbol)
        String invalidEmail = 'invalidemail.com';
        String maskedInvalidEmail = Nice_FieldMaskingUtility.maskEmail(invalidEmail);
        System.assertEquals('invalidemail.com', maskedInvalidEmail, 'Email masking failed for invalid email.');

        // Test with empty email
        String emptyEmail = '';
        String maskedEmptyEmail = Nice_FieldMaskingUtility.maskEmail(emptyEmail);
        System.assertEquals('', maskedEmptyEmail, 'Email masking failed for empty email.');

        // Test with null email
        String nullEmail = null;
        String maskedNullEmail = Nice_FieldMaskingUtility.maskEmail(nullEmail);
        System.assertEquals(null, maskedNullEmail, 'Email masking failed for null email.');
    }

    @isTest
    static void testMaskPhoneNumber() {
        // Test case 1: Valid phone number with masking
        String phoneNumber1 = '9876543210';
        String expectedMasked1 = '987*****10';
        String result1 = Nice_FieldMaskingUtility.maskPhoneNumber(phoneNumber1);
        System.assertEquals(expectedMasked1, result1, 'Phone number should be masked correctly');

        // Test case 2: Phone number with special characters
        String phoneNumber2 = '(987) 654-3210';
        String expectedMasked2 = '987*****10';
        String result2 = Nice_FieldMaskingUtility.maskPhoneNumber(phoneNumber2);
        System.assertEquals(expectedMasked2, result2, 'Phone number should be masked correctly after cleaning special characters');

        // Test case 3: Short phone number (less than 5 digits)
        String phoneNumber3 = '123';
        String result3 = Nice_FieldMaskingUtility.maskPhoneNumber(phoneNumber3);
        System.assertEquals(phoneNumber3, result3, 'Short phone number should not be masked');

        // Test case 4: Empty phone number
        String phoneNumber4 = '';
        String result4 = Nice_FieldMaskingUtility.maskPhoneNumber(phoneNumber4);
        System.assertEquals(phoneNumber4, result4, 'Empty phone number should return empty result');

        // Test case 5: Phone number with non-numeric characters
        String phoneNumber5 = 'abcde12345';        
        String expectedMasked5 = '12345';
        String result5 = Nice_FieldMaskingUtility.maskPhoneNumber(phoneNumber5);
        System.assertEquals(expectedMasked5, result5, 'Phone number with invalid characters should not be masked');
    }
}