@RestResource(urlMapping='/NICEOTPVerification/*')
global with sharing class NICEOTPVerificationRestResource {
    
    Final static String ERROR_SOURCE = 'NICEOTPVerificationRestResource.sendOTP';
    
    @HttpPost
    global static String sendOTP() {
        try {
            
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String jsonStr = body.toString();
            TwilioOTPRequestWrapper wrapper = (TwilioOTPRequestWrapper) JSON.deserialize(jsonStr, TwilioOTPRequestWrapper.class);
            
            if (String.isBlank(wrapper.uniqueId)) {
                RestContext.response.statusCode = 400;
                NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, jsonStr, 'Missing required parameter: uniqueId.', 400);
                return JSON.serialize(new Map<String, String>{'message' => 'Missing required parameter: uniqueId.'});
            } 
            
            Account acc = [SELECT Id, Name, Email__c, Primary_Number__c FROM Account WHERE Account_Id__c = :wrapper.uniqueId LIMIT 1] ?? Null;
            
            if (acc == Null){
                RestContext.response.statusCode = 200;
                NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, jsonStr, 'No account available with the entered uniqueId', 200);
                return JSON.serialize(new Map<String, String>{'message' => 'No account available with the entered uniqueId'});
            }
            
            if (String.isBlank(acc.Primary_Number__c) && String.isBlank(acc.Email__c)) {
                RestContext.response.statusCode = 200;
                NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, jsonStr, 'No mobile number and email Address available for this account for verification', 200);
                return JSON.serialize(new Map<String, String>{'message' => 'No mobile number and email Address available for this account for verification'});
            } 
            
            Map<String, Object> responseMap = NICEOTPVerificationUtility.sendOTP(acc.Primary_Number__c, acc.Email__c, acc.Id);
            
            RestContext.response.statusCode = NICEOTPVerificationUtility.hasSuccessfulResponse ? 200 : NICEOTPVerificationUtility.errorCode;
            NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, jsonStr, JSON.serialize(responseMap), RestContext.response.statusCode);
            return JSON.serialize(responseMap);
            
        } catch (Exception ex) {
            RestContext.response.statusCode = 500;
            NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, String.valueOf(RestContext.request.requestBody), ex.getMessage(), 500);
            return JSON.serialize(new Map<String, String>{ 'error' => ex.getMessage() });
        }
    }
    
    // Wrapper class for deserialization
    public class TwilioOTPRequestWrapper {
        public String uniqueId;
    }
    
    // Custom exception for validation errors
    public class CustomException extends Exception {}
    
}