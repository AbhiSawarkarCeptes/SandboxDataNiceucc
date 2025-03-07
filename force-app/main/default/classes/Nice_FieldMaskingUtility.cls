/******************************************************
    Class : Nice_FieldMaskingUtility
    Test Class : Nice_FieldMaskingUtilityTest
    Purpose : NICE - Masks an email address by replacing the middle part of the local part (before the '@')
    Author : Artee Verma
*******************************************************/

public class Nice_FieldMaskingUtility {
    
    /**
     * Masks an email address by replacing the middle part of the local part (before the '@')
     * with asterisks, leaving the first two and last two characters visible.
     * @param email The email address to mask.
     * @return The masked email address or original input if invalid.
     */
    
    
    public static String maskEmail(String email) {
        if (String.isEmpty(email) || !email.contains('@')) {
            return email;
        }
        List<String> parts = email.split('@');
        if (parts.size() != 2 || String.isEmpty(parts[0]) || String.isEmpty(parts[1])) {
            return email;
        }
        String localPart = parts[0];
        if (localPart.length() <= 4) {
            return localPart + '@' + parts[1];
        }
        return localPart.substring(0, 2) + repeatChar('*', localPart.length() - 4) + localPart.substring(localPart.length() - 2) + '@' + parts[1];
    }
    
    /**
     * Masks a phone number by replacing the middle part with asterisks,
     * leaving the first two and last two digits visible.
     * @param phone The phone number to mask.
     * @return The masked phone number or original input if invalid.
     */
    
    public static String maskPhoneNumber(String phone) {
        if (String.isEmpty(phone) || phone.length() <= 4 || !phone.replaceAll('[^0-9]', '').isNumeric()) {
            return phone;
        }
        phone = phone.replaceAll('[^0-9+]', '');
        return phone.substring(0, 3) + repeatChar('*', phone.length() - 5) + phone.substring(phone.length() - 2);
    }
    
    /**
     * Helper method to repeat a character multiple times.
     * @param c The character to repeat.
     * @param count The number of repetitions.
     * @return A string containing the repeated character.
     */
    private static String repeatChar(String c, Integer count) {
        String result = '';
        for (Integer i = 0; i < count; i++) {
            result += c;
        }
        return result;
    }
}