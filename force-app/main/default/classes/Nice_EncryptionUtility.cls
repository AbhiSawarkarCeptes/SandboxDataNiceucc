/***************************************************************************
Class      : Nice_EncryptionUtility
Test Class : Nice_EncryptionTest
Purpose    : Nice - An Apex utility class helps to encrypt and decrypt the phone number.
Author     : Ashok Kumar M
*****************************************************************************/
public class Nice_EncryptionUtility {
    
    public static String encryptPhoneNumber(String phoneNumber) {
        
        if (String.isEmpty(phoneNumber)) {
            return null;
        }
        
        phoneNumber = phoneNumber.replace('+','');
        phoneNumber = phoneNumber.trim();
        
        Integer numberLength = phoneNumber.length();
        String numberLengthStr = String.valueOf(numberLength);
        Integer randomNum = Integer.valueOf(Math.floor(Math.random() * 9)) + 1;
        String randomNumberStr = String.valueOf(numberLength);
        Integer lastTwoDigits = Integer.valueOf(phoneNumber.substring(phoneNumber.length() - 2));
        
        if(numberLength == 1) {
            numberLengthStr = '0' + numberLengthStr;
        }
        
        if(randomNum < 10) {
            randomNumberStr = '0' + String.valueOf(randomNum);
        }
        
        Map<String, String> digitMaps = new Map<String, String>();
        List<Nice_Map__c> mappings = [SELECT Id, Key__c, Value__c FROM Nice_Map__c where set__c = :lastTwoDigits];
        for(Nice_Map__c thisMap: mappings) {
            digitMaps.put(thisMap.Key__c, thisMap.Value__c);
        }
        
        String encryptedNumber = '';      
        for (Integer i = 0; i < phoneNumber.length(); i ++) {
            String part = phoneNumber.substring(i, Math.min(i + 1, phoneNumber.length()));
            encryptedNumber += digitMaps.get(part);
        }
        
        String lastTwoDigitStr = String.valueOf(lastTwoDigits);
        if(lastTwoDigits < 10) {
            lastTwoDigitStr = '0' + lastTwoDigits;
        }
        
        encryptedNumber = '+7889' + lastTwoDigitStr + numberLengthStr + encryptedNumber ;
        return encryptedNumber;
        
    } 

    public static String decryptPhoneNumber(String encryptedNumber) {
        
        if (String.isEmpty(encryptedNumber)) {
            return null; 
        }
        
        encryptedNumber = encryptedNumber.replace('+','');
        encryptedNumber = encryptedNumber.trim();
        Integer encryptedLength = Integer.valueOf(encryptedNumber.subString(6,8));
        String encryptedRandom = encryptedNumber.subString(4,6);
        
        Map<String, String> digitMaps2 = new Map<String, String>();
        List<Nice_Map__c> mappings2 = [SELECT Id, Key__c, Value__c FROM Nice_Map__c where set__c = :Integer.valueOf(encryptedRandom)];    
        for(Nice_Map__c thisMap: mappings2) {
            digitMaps2.put(thisMap.Value__c, thisMap.Key__c);
        }
        
        String actualNumber = '';
        actualNumber = String.valueOf(encryptedNumber).subString(8, 8 + encryptedLength);
        String decryptedNumber = '+';
        
        for (Integer i = 0; i < actualNumber.length(); i ++) {
            String part = actualNumber.substring(i, Math.min(i + 1, actualNumber.length()));
            decryptedNumber += digitMaps2.get(part);
        }
        
        return decryptedNumber;
        
    }
        

    public static String generateRandomNumber(Integer n) {
        
        if (n <= 0) {
            throw new IllegalArgumentException('Number of digits must be greater than 0');
        }
        String randomNumber = '';
        for(integer i = 0; i < n; i++) {
            randomNumber += (Integer) (Math.random() * 10);
        }
        return randomNumber;
    }

}