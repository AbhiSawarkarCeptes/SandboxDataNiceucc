/***************************************************************************
Class      : Nice_SendOtpAPI
Test Class : Nice_SendOtpAPITest
Purpose    : Nice - An Apex REST resource class helps send OTP to the customer SMS/Email.
Author     : Ashok Kumar M
*****************************************************************************/
@RestResource(urlMapping='/NICE_SendOTP/*')
global with sharing class Nice_SendOtpAPI {
    
    Final static String ERROR_SOURCE = 'Nice_SendOtpAPI.sendOTP';
    
    @HttpPost
    global static String sendOTP() {
        
        try {
            
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String jsonStr = body.toString();
            Nice_SendOtpAPIRequestWrapper wrapper = (Nice_SendOtpAPIRequestWrapper) JSON.deserialize(jsonStr, Nice_SendOtpAPIRequestWrapper.class);
            
            if (String.isBlank(wrapper.uniqueId)) {
                RestContext.response.statusCode = 400;
                Nice_LoggerUtility.createLog(ERROR_SOURCE, jsonStr, 'Missing required parameter: uniqueId.', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'Missing required parameter: uniqueId.'});
            } 
            
            Account acc = [SELECT Id, Name, Email__c, Primary_Mobile_Number__c 
                           FROM Account 
                           WHERE Account_Id__c = :wrapper.uniqueId LIMIT 1] ?? Null;
            
            if (acc == Null){
                RestContext.response.statusCode = 206;
                Nice_LoggerUtility.createLog(ERROR_SOURCE, jsonStr, 'No account record found for the provided uniqueId', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'No account record found for the provided uniqueId'});
            }
            
            if (String.isBlank(acc.Primary_Mobile_Number__c) && String.isBlank(acc.Email__c)) {
                RestContext.response.statusCode = 206;
                Nice_LoggerUtility.createLog(ERROR_SOURCE, jsonStr, 'Mobile number and email Address not available for this account', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'Mobile number and email Address not available for this account'});
            }
            
            Map<String, String> requestMap = new Map<String, String>();
            if (!String.isBlank(acc.Primary_Mobile_Number__c)) {
                requestMap.put('sms', acc.Primary_Mobile_Number__c);
            }
            
            if (!String.isBlank(acc.Email__c)) {
                requestMap.put('email', acc.Email__c);
            }
            
            Map<String, Object> responseMap = Nice_OtpUtility.sendOTP(requestMap, acc.Id, acc.Name);
            RestContext.response.statusCode = responseMap.isEmpty() ? 500 : 200;
            String response = responseMap.isEmpty() ? JSON.serialize(new Map<String, String>{'message' => 'Failed to send OTP for the provided uniqueId.'}) : JSON.serialize(responseMap);
            Nice_LoggerUtility.createLog(ERROR_SOURCE, jsonStr, response , RestContext.response.statusCode);
            return response;
            
        } catch (Exception ex) {
            
            RestContext.response.statusCode = 500;
            Nice_LoggerUtility.createLog(ERROR_SOURCE, String.valueOf(RestContext.request.requestBody), ex.getMessage(), RestContext.response.statusCode);
            return JSON.serialize(new Map<String, String>{'error' => ex.getMessage() , 'LineNumber' => String.valueOF(ex.getLineNumber())});
        }
        
    }
    
    
    public class Nice_SendOtpAPIRequestWrapper {
        public String uniqueId;
    }
    
    public class Nice_SendOtpAPIResponseWrapper {
        public String to;
        public String otp;
        public String status;
        public String createdTime;
        public String expiryTime;
        public String message;
        public String accountId;
    }
    
}