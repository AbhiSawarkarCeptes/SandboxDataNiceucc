/***************************************************************************
Class      : Nice_AesEncryptionUtility
Test Class : Nice_AesEncryptionUtilityTest
Purpose    : NICE - Test class Code coverage 80% 
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_AesEncryptionUtilityTest {

    @testSetup
    static void setupTestData() {
        // Test setup, if needed.
    }

    @isTest
    static void testEncryptAndDecryptMobile() {
        String mobileNumber = '1234567890';
        String encryptedMobile = Nice_AesEncryptionUtility.encryptMobile(mobileNumber);
        String decryptedMobile = Nice_AesEncryptionUtility.decryptMobile(encryptedMobile);
        System.assertNotEquals(mobileNumber, encryptedMobile, 'Encrypted mobile should differ from original.');
        System.assertEquals(mobileNumber, decryptedMobile, 'Decrypted mobile should match original.');
        System.assertNotEquals(null, encryptedMobile, 'Encryption should not return null.');
    }

    @isTest
    static void testEncryptAndDecryptEmail() {
        String email = 'test@example.com';
        String encryptedEmail = Nice_AesEncryptionUtility.encryptEmail(email);
        String decryptedEmail = Nice_AesEncryptionUtility.decryptEmail(encryptedEmail);
        System.assertNotEquals(email, encryptedEmail, 'Encrypted email should differ from original.');
        System.assertEquals(email, decryptedEmail, 'Decrypted email should match original.');
        System.assertNotEquals(null, encryptedEmail, 'Encryption should not return null.');
    }

    @isTest
    static void testDecryptInvalidMobile() {
        String result = Nice_AesEncryptionUtility.decryptMobile('InvalidEncryptedString');
        System.assertEquals('DECRYPTION_FAILED', result, 'Should return DECRYPTION_FAILED for invalid input.');
    }

    @isTest
    static void testDecryptInvalidEmail() {
        String result = Nice_AesEncryptionUtility.decryptEmail('InvalidEncryptedString');
        System.assertEquals('DECRYPTION_FAILED', result, 'Should return DECRYPTION_FAILED for invalid input.');
    }
}