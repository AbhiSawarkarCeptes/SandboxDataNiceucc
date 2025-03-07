@RestResource(urlMapping='/NICEOTPVerificationCheck/*')
global with sharing class NICEOTPVerificationCheckRestResource {
    
    Final static String ERROR_SOURCE = 'NICEOTPVerificationCheckRestResource.validateOTP';
        
    @HttpPost
    global static String validateOTP() {
        
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String jsonStr = body.toString();
        TwilioOTPVerificationCheckRequestWrapper wrapper = (TwilioOTPVerificationCheckRequestWrapper) JSON.deserialize(jsonStr, TwilioOTPVerificationCheckRequestWrapper.class);
        
        try {
            
            if (String.isBlank(wrapper.code)) {
                RestContext.response.statusCode = 400;
                NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, jsonStr, 'Missing required parameter code.', 400);
                return JSON.serialize(new Map<String, String>{'message' => 'Missing required parameter code.'});
            }
            
            if (String.isBlank(wrapper.uniqueId)) {
                RestContext.response.statusCode = 400;
                NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, jsonStr, 'Missing required parameter uniqueId.', 400);
                return JSON.serialize(new Map<String, String>{'message' => 'Missing required parameter uniqueId.'});
            } 
            
            Account acc = [SELECT Id, Name, Email__c, Primary_Number__c FROM Account WHERE Account_Id__c = :wrapper.uniqueId LIMIT 1] ?? Null;
            
            if (acc == Null){
                RestContext.response.statusCode = 200;
                NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, jsonStr, 'No account available to verify the OTP for the entered uniqueId', 200);
                return JSON.serialize(new Map<String, String>{'message' => 'No account available to verify the OTP for the entered uniqueId'});
            }
            
            if (String.isBlank(acc.Primary_Number__c) && String.isBlank(acc.Email__c)) {
                RestContext.response.statusCode = 200;
                NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, jsonStr, 'Mobile number and email Address not available for this account to verify OTP', 200);
                return JSON.serialize(new Map<String, String>{'message' => 'Mobile number and email Address not available for this account to verify OTP'});
            } 
            
            Map<String, Object> responseMap = NICEOTPVerificationCheckUtility.validateOTP(acc.Primary_Number__c, acc.Email__c, wrapper.code, acc.Id);
            
            RestContext.response.statusCode = NICEOTPVerificationUtility.hasSuccessfulResponse ? 201 : NICEOTPVerificationUtility.errorCode;
            NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, jsonStr, JSON.serialize(responseMap), RestContext.response.statusCode);
            return JSON.serialize(responseMap);
            
        } catch (Exception ex) {
            RestContext.response.statusCode = 500;
            NICE_APICalloutLogUtility.createLog(ERROR_SOURCE, String.valueOf(RestContext.request.requestBody), ex.getMessage(), 500);
            return JSON.serialize(new Map<String, String>{'error' => ex.getMessage()});
        }
    }
    
    
    // Wrapper class for deserialization of input data
    public class TwilioOTPVerificationCheckRequestWrapper {
        public String uniqueId;
        public String code;
    }
    
    // Custom exception class for validation errors
    public class CustomException extends Exception {}
    
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  /*  @HttpPost
    global static String validateOTP() {
        
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String jsonStr = body.toString();
        TwilioOTPVerificationCheckRequestWrapper wrapper = (TwilioOTPVerificationCheckRequestWrapper) JSON.deserialize(jsonStr, TwilioOTPVerificationCheckRequestWrapper.class);
        
        try {
            
             Map<String, String> requestMap = new Map<String, String>();
            
            // Validate input parameters
            if (String.isBlank(wrapper.code)) {
                throw new CustomException('Missing required parameter code.');
            }
            
            // Validate input
            if (String.isBlank(wrapper.phoneNumber) || String.isBlank(wrapper.emailAddress)) {
                throw new CustomException('Missing required parameters: phoneNumber or emailAddress.');
            } else {
                 requestMap.put(wrapper.phoneNumber, 'sms');
                 requestMap.put(wrapper.emailAddress, 'email');
            }
            
            String endpoint = 'callout:Twilio_Verify/v2/Services/' + SERVICE_SID + '/VerificationCheck';
            List<TwilioVerifyApiResponseWrapper> queuableList = new List<TwilioVerifyApiResponseWrapper>();
            Map<String, Object> responseMap = new Map<String, Object>();
            Boolean hasSuccessfulResponse = false;
            Integer errorCode;
            
            for (String recipient : requestMap.keySet()) {
                Map<String, String> requestBody = new Map<String, String> {
                    'To' => recipient, 
                    'Code' => wrapper.code
                };
                
                HttpResponse httpResponse = NICETwilioUtility.sendTwilioRequest(endpoint, requestBody, 'VerificationCheck');
                
                if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                    hasSuccessfulResponse = true;
                    queuableList.add((TwilioVerifyApiResponseWrapper) JSON.deserialize(httpResponse.getBody(), TwilioVerifyApiResponseWrapper.class));
                    NICETwilioUtility.TwilioVerifyResponse twilioVerifyResponse = (NICETwilioUtility.TwilioVerifyResponse) JSON.deserialize(httpResponse.getBody(), NICETwilioUtility.TwilioVerifyResponse.class);
                    twilioVerifyResponse.apiService = 'VerificationCheck';
                    twilioVerifyResponse.channel = requestMap.get(recipient);
                    twilioVerifyResponse.message = twilioVerifyResponse.status == 'Approved' ? 'OTP Verified Successfully' : 'Please provide valid OTP';
                    twilioVerifyResponse.statusCode  = httpResponse.getStatusCode();
                    responseMap.put(requestMap.get(recipient), twilioVerifyResponse);
                } else {
                    NICETwilioUtility.TwilioErrorResponse twilioErrorResponse = (NICETwilioUtility.TwilioErrorResponse) JSON.deserialize(httpResponse.getBody(), NICETwilioUtility.TwilioErrorResponse.class);
                    twilioErrorResponse.status = String.valueOf(httpResponse.getStatusCode());
                    errorCode = httpResponse.getStatusCode();
                    responseMap.put(requestMap.get(recipient), twilioErrorResponse);
                }
            }

            RestContext.response.statusCode = hasSuccessfulResponse ? 200 : errorCode;
            
            if (!queuableList.isEmpty()) {
                System.enqueueJob(new NICEOTPVerificationQueueable(queuableList, 'VerificationCheck', Null));
            }
            
            return JSON.serialize(responseMap);
            
        } catch (CustomException ex) {
            RestContext.response.statusCode = 400;  // Bad Request
            return JSON.serialize(new Map<String, String>{'error' => ex.getMessage()});
        } catch (Exception ex) {
            RestContext.response.statusCode = 500;  // Internal Error
            return JSON.serialize(new Map<String, String>{'error' => ex.getMessage()});
        }
    }*/
    
    
    
}