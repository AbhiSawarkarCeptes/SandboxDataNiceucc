/******************************************************
Class : Nice_AesEncryptionUtility
Test Class : Nice_AesEncryptionUtilityTest
Purpose : NICE - Apex class handles mobile number and email Id encryption & decryption.
Author : Artee Varma
*******************************************************/

public class Nice_AesEncryptionUtility {
    private static final String ENCRYPTION_ALGORITHM = 'AES128';
    private static final String HASH_ALGORITHM = 'MD5';
    private static final String INITIALIZATION_VECTOR = '000102030405060708090a0b0c0d0e0f'; // 16-byte IV
    private static final String SECRET_KEY = 'MY_SECRET_KEY_16CH'; // 16-character secret key

    // Encrypt Mobile Number
    public static String encryptMobile(String mobileNumber) {
        System.debug('mobileNumber::' + mobileNumber);
        try {
            // Generate a hash key
            Blob hashKey = Crypto.generateDigest(HASH_ALGORITHM, Blob.valueOf(SECRET_KEY));

            // Convert the mobile number into a Blob
            Blob mobileBlob = Blob.valueOf(mobileNumber);

            // Encrypt the Blob using AES
            Blob encryptedBlob = Crypto.encrypt(
                ENCRYPTION_ALGORITHM,
                hashKey,
                EncodingUtil.convertFromHex(INITIALIZATION_VECTOR),
                mobileBlob
            );

            // Convert encrypted Blob to Base64
            String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
            return encryptedString;
        } catch (Exception e) {
            System.debug('Error during encryption: ' + e.getMessage());
            return 'ENCRYPTION_FAILED';
        }
    }

    // Decrypt Mobile Number
    public static String decryptMobile(String encryptedMobile) {
        try {
            Blob encryptedBlob = EncodingUtil.base64Decode(encryptedMobile);
            Blob hashKey = Crypto.generateDigest(HASH_ALGORITHM, Blob.valueOf(SECRET_KEY));
            Blob decryptedBlob = Crypto.decrypt(
                ENCRYPTION_ALGORITHM,
                hashKey,
                EncodingUtil.convertFromHex(INITIALIZATION_VECTOR),
                encryptedBlob
            );
            return decryptedBlob.toString();
        } catch (Exception e) {
            System.debug('Error during decryption: ' + e.getMessage());
            return 'DECRYPTION_FAILED';
        }
    }

    // Encrypt Email
    public static String encryptEmail(String email) {
        System.debug('email::' + email);
        try {
            // Generate a hash key
            Blob hashKey = Crypto.generateDigest(HASH_ALGORITHM, Blob.valueOf(SECRET_KEY));

            // Convert the email into a Blob
            Blob emailBlob = Blob.valueOf(email);

            // Encrypt the Blob using AES
            Blob encryptedBlob = Crypto.encrypt(
                ENCRYPTION_ALGORITHM,
                hashKey,
                EncodingUtil.convertFromHex(INITIALIZATION_VECTOR),
                emailBlob
            );

            // Convert encrypted Blob to Base64
            String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
            return encryptedString;
        } catch (Exception e) {
            System.debug('Error during encryption: ' + e.getMessage());
            return 'ENCRYPTION_FAILED';
        }
    }

    // Decrypt Email
    public static String decryptEmail(String encryptedEmail) {
        try {
            Blob encryptedBlob = EncodingUtil.base64Decode(encryptedEmail);
            Blob hashKey = Crypto.generateDigest(HASH_ALGORITHM, Blob.valueOf(SECRET_KEY));
            Blob decryptedBlob = Crypto.decrypt(
                ENCRYPTION_ALGORITHM,
                hashKey,
                EncodingUtil.convertFromHex(INITIALIZATION_VECTOR),
                encryptedBlob
            );
            return decryptedBlob.toString();
        } catch (Exception e) {
            System.debug('Error during decryption: ' + e.getMessage());
            return 'DECRYPTION_FAILED';
        }
    }

    // Adjust length to the desired size
    private static String adjustLength(String input, Integer desiredLength) {
        if (input.length() > desiredLength) {
            return input.substring(0, desiredLength);
        } else if (input.length() < desiredLength) {
            while (input.length() < desiredLength) {
                input += '0'; // Pad with zeroes for numeric consistency
            }
        }
        return input;
    }
}