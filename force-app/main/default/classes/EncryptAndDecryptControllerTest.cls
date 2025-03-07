@isTest
public class EncryptAndDecryptControllerTest {
    static void setUpTestData(){
        List<Nice_Map__c> testMapping = new List<Nice_Map__c>();
        for(Integer i = 0; i < 10; i++){
            testMapping.add(new Nice_Map__c (
            Key__c= string.valueOf(i), 
            Value__c= 'mapping'+ i,
            Set__c= 12));
        }
        insert testMapping;
    }
    
    @isTest
    static void testEncryptPhoneNumber_ValidInput() {
        String phoneNumber = '+911234567890';
        String encrypted = EncryptAndDecryptController.encryptPhoneNumber(phoneNumber);
        System.assertNotEquals(null, encrypted, 'Encrypted number should not be null');
    }

    @isTest
    static void testEncryptPhoneNumber_EmptyInput() {
        String encrypted = EncryptAndDecryptController.encryptPhoneNumber('');
        System.assertEquals(null, encrypted, 'Empty input should return null');
        
    }

    @isTest
    static void testDecryptPhoneNumber_ValidInput() {
        // Setup test data
        setUpTestData();
        
        // Test with valid phone number
        String phoneNumber = '1234567890';
        String encrypted = EncryptAndDecryptController.encryptPhoneNumber(phoneNumber);
        
        // Test decryption
        String decrypted = EncryptAndDecryptController.decryptPhoneNumber(encrypted);
        System.assertEquals(phoneNumber, decrypted, 'Decrypted number should match original');
    }


    @isTest
    static void testDecryptPhoneNumber_EmptyInput() {
        // Test with empty input
        String decrypted = EncryptAndDecryptController.decryptPhoneNumber('');
        System.assertEquals(null, decrypted, 'Empty input should return null');
    }

    @isTest
    static void testDecryptPhoneNumber_NoMappingFound() {
        // Test with encrypted number that has no corresponding mapping
        String encryptedNumber = '+912000000000';
        String decrypted = EncryptAndDecryptController.decryptPhoneNumber(encryptedNumber);
        System.assertEquals(null, decrypted, 'Decrypted number should be null when no mapping is found');
    }

    @isTest
    static void testDecryptPhoneNumber_MalformedInput() {
        // Test with various malformed inputs
        String decrypted1 = EncryptAndDecryptController.decryptPhoneNumber('invalid');
        System.assertEquals(null, decrypted1, 'Malformed input should return null');
        
        String decrypted2 = EncryptAndDecryptController.decryptPhoneNumber('+12');
        System.assertEquals(null, decrypted2, 'Short malformed input should return null');
        
        String decrypted3 = EncryptAndDecryptController.decryptPhoneNumber('+12345');
        System.assertEquals(null, decrypted3, 'Invalid format should return null');
    }



    @isTest
    static void testGenerateRandomNumber_ValidInput() {
        Integer length = 5;
        String randomNumber = EncryptAndDecryptController.generateRandomNumber(length);
        System.assertEquals(length, randomNumber.length(), 'Random number should have correct length');
    }

    @isTest
    static void testGenerateRandomNumber_InvalidInput() {
        Boolean exceptionThrown = false;
        
        try {
            EncryptAndDecryptController.generateRandomNumber(-1);
        } catch(IllegalArgumentException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Should throw exception for invalid length');
    }    
}
