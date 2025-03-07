@RestResource(urlMapping='/Nice_PhoneNumberEncryption/*')
global with sharing class NICE_PhoneNumberEncryption {
    
    @HttpPost
    global static String encryptPhoneNumber() {
        
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String jsonStr = body.toString();
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            
            PhoneEncryptionWrapper input = (PhoneEncryptionWrapper) JSON.deserialize(jsonStr, PhoneEncryptionWrapper.class);
            
            if (String.isBlank(input.method) || String.isBlank(input.phoneNumber)) {
                RestContext.response.statusCode = 400;
                responseMap.put('Message', 'Error: Required parameter is missing - phoneNumber or method.');
                return JSON.serialize(responseMap);
            }
            
            String result = null;
            
            switch on input.method {
                when 'Encrypt' {
                    result = encryptPhoneNumber(input.phoneNumber);
                    responseMap.put('encryptedPhoneNumber', result);
                    responseMap.put('Message', 'Encryption completed successfully');
                }
                when 'Decrypt' {
                    result = decryptPhoneNumber(input.phoneNumber);
                    responseMap.put('decryptedPhoneNumber', result);
                    responseMap.put('Message', 'Decryption completed successfully');
                }
                when else {
                    RestContext.response.statusCode = 400;
                    responseMap.put('Message', 'Error: Please provide a valid method - Encrypt or Decrypt.');
                    return JSON.serialize(responseMap);
                }
            }
            
            RestContext.response.statusCode = 200;
            responseMap.put('phoneNumber', input.phoneNumber);
            
        } catch (Exception e) {
            
            RestContext.response.statusCode = 500;
            responseMap.put('Message', 'Error: ' + e.getMessage());
            
        }
        
        return JSON.serialize(responseMap);
        
    }


    // Encrypt a phone number
    public static String encryptPhoneNumber(String phoneNumber) {
        if (String.isEmpty(phoneNumber)) {
            return null; // Return null for empty phone numbers
        }
        
        phoneNumber = phoneNumber.replace('+','');
        Integer numberLength = phoneNumber.length();
        String numberLengthStr = String.valueOf(numberLength);
        Integer randomNum = Integer.valueOf(Math.floor(Math.random() * 9)) + 1;
        String randomNumberStr = String.valueOf(numberLength);
        
        if(numberLength == 1) {
            numberLengthStr = '0' + numberLengthStr;
        }
        
        if(randomNum < 10) {
            randomNumberStr = '0' + String.valueOf(randomNum);
        }
        
        Map<String, String> digitMaps = new Map<String, String>();
        List<Nice_Map__c> mappings = [SELECT Id, Key__c, Value__c FROM Nice_Map__c where set__c = :randomNum];
        for(Nice_Map__c thisMap: mappings) {
            digitMaps.put(thisMap.Key__c, thisMap.Value__c);
        }
        
        String encryptedNumber = '';      
        for (Integer i = 0; i < phoneNumber.length(); i ++) {
            // Get the 2-digit substring (or remaining digits)
            String part = phoneNumber.substring(i, Math.min(i + 1, phoneNumber.length()));
            encryptedNumber += digitMaps.get(part);
        }
        
        System.debug('numberLength' + numberLength);
        Integer n = 21 - numberLength; 
        System.debug('n' + n);
        String fillerNumber = generateRandomNumber(n);
                System.debug(fillerNumber);

        
        encryptedNumber = numberLengthStr + randomNumberStr + encryptedNumber + fillerNumber;
        system.debug(encryptedNumber);
        return encryptedNumber;
    } 

    // Decrypt a phone number
    public static String decryptPhoneNumber(String encryptedNumber) {
        if (String.isEmpty(encryptedNumber)) {
            return null; // Return null for empty encrypted data
        }
        
        Integer encryptedLength = Integer.valueOf(encryptedNumber.subString(0,2));
        String encryptedRandom = encryptedNumber.subString(2,4);
        
        Map<String, String> digitMaps2 = new Map<String, String>();
        List<Nice_Map__c> mappings2 = [SELECT Id, Key__c, Value__c FROM Nice_Map__c where set__c = :Integer.valueOf(encryptedRandom)];    
        for(Nice_Map__c thisMap: mappings2) {
            digitMaps2.put(thisMap.Value__c, thisMap.Key__c);
        }
        
        String actualNumber = '';
        actualNumber = String.valueOf(encryptedNumber).subString(4, 4 + encryptedLength);
        String decryptedNumber = '+';
        for (Integer i = 0; i < actualNumber.length(); i ++) {
            // Get the 2-digit substring (or remaining digits)
            String part = actualNumber.substring(i, Math.min(i + 1, actualNumber.length()));
            decryptedNumber += digitMaps2.get(part);
        }
        
        System.debug(decryptedNumber);
        
        return decryptedNumber;
        
    }
        
    public class PhoneEncryptionWrapper {
        public String phoneNumber;
        public String method;
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