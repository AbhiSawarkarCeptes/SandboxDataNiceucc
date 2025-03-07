/***************************************************************************
Class      : Nice_EncryptionAPI
Test Class : Nice_EncryptionAPITest
Purpose    : Nice- An Apex REST resource class helps encrypt and decrypt the 
             provided phone number based on the specified method name.
Author     : Ashok Kumar M
*****************************************************************************/
@RestResource(urlMapping='/NICE_PhoneNumberEncryptionQuery/*')
global with sharing class Nice_EncryptionAPI {
    
    Final static String SOURCE = 'Nice_EncryptionAPI.encryptPhoneNumber';
    
    @HttpGet
    global static String encryptPhoneNumber() {
        
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            
            String phoneNumber = RestContext.request.params.get('phoneNumber');
            String method = RestContext.request.params.get('method');
            
            if (String.isBlank(method) || String.isBlank(phoneNumber)) {
                RestContext.response.statusCode = 400;
                responseMap.put('Message', 'Required parameter is missing - phoneNumber or method.');
                Nice_LoggerUtility.createLog(SOURCE, String.valueOf(RestContext.request.params), JSON.serialize(responseMap), RestContext.response.statusCode);
                return JSON.serialize(responseMap);
            }
            
            String result = null;
            
            switch on method {
                when 'Encrypt' {
                    result = Nice_EncryptionUtility.encryptPhoneNumber(phoneNumber);
                    responseMap.put('encryptedPhoneNumber', result);
                    responseMap.put('Message', 'Encryption completed successfully');
                }
                when 'Decrypt' {
                    result = Nice_EncryptionUtility.decryptPhoneNumber(phoneNumber);
                    responseMap.put('decryptedPhoneNumber', result);
                    responseMap.put('Message', 'Decryption completed successfully');
                }
                when else {
                    RestContext.response.statusCode = 400;
                    responseMap.put('Message', 'Please provide a valid method - Encrypt or Decrypt.');
                    Nice_LoggerUtility.createLog(SOURCE, String.valueOf(RestContext.request.params), JSON.serialize(responseMap), RestContext.response.statusCode);
                    return JSON.serialize(responseMap);
                }
            }
            
            RestContext.response.statusCode = 200;
            responseMap.put('phoneNumber', phoneNumber);
            
        } catch (Exception e) {
            
            RestContext.response.statusCode = 500;
            responseMap.put('Message', e.getMessage());
            
        }
        
        Nice_LoggerUtility.createLog(SOURCE, String.valueOf(RestContext.request.params), JSON.serialize(responseMap), RestContext.response.statusCode);
        return JSON.serialize(responseMap);
        
    }
    
    public class PhoneEncryptionWrapper {
        public String phoneNumber;
        public String method;
    }
 
}