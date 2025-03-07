/***************************************************************************
Class      : Nice_OtpUtility
Test Class : NICE_OTPUtilityTest
Purpose    : Nice - An Apex utility class helps send OTP to the customer SMS/Email.
Author     : Ashok Kumar M
*****************************************************************************/
public class Nice_OtpUtility {
   
    private static String baseUrl;
    private static String userName;
    private static String password;
    private static string otpMessage;

    public static Map<String, Object> sendOTP(Map<String, String> requestMap, String accountId, String customerName) {
        
        List<OTP_Verification__c> otpVerificationList = new List<OTP_Verification__c>();
        String otpCode = String.valueOf(Math.round(Math.random() * 899999) + 100000);
        DateTime createdTime = DateTime.now();
        DateTime expiryTime = createdTime.addMinutes(5);
        
        Nice_API_Configurations__mdt apiConfig = [SELECT Id, DeveloperName, Base_URL__c, Username__c, Password__c, Message_Body__c 
                                                  FROM Nice_API_Configurations__mdt WHERE DeveloperName = 'Etisalat_SMS' 
                                                  AND Base_URL__c != Null AND Username__c != Null AND Password__c != Null AND Message_Body__c != Null LIMIT 1] ?? Null;
            
        Map<String, Object> response = new Map<String, Object>();
        if (apiConfig == Null) {
            return response;
        }
        
        baseUrl = apiConfig.Base_URL__c;
        userName = apiConfig.Username__c;
        password = apiConfig.Password__c;
        otpMessage = apiConfig.Message_Body__c.replace('{otp}', otpCode);
        
        for (String key : requestMap.keySet()) {
            
            String message;
            Boolean isSent = false;
            String toValue = requestMap.get(key);
            Map<String, Object> details = new Map<String, Object>();
            
            if (key.equalsIgnoreCase('sms')) {
                isSent = sendSMS(toValue);
                message = isSent ? 'SMS sent successfully' : 'SMS failed';
            } else if (key.equalsIgnoreCase('email')) {
                isSent = sendEmail(toValue);
                message = isSent ? 'Email sent successfully' : 'Email failed';
            }
            
            if(isSent) {
                
                Nice_SendOtpAPI.Nice_SendOtpAPIResponseWrapper responseWrapper = new Nice_SendOtpAPI.Nice_SendOtpAPIResponseWrapper();
                responseWrapper.to = toValue;
                responseWrapper.otp = otpCode;
                responseWrapper.status = 'Pending';
                responseWrapper.createdTime = createdTime.format();
                responseWrapper.expiryTime = expiryTime.format();
                responseWrapper.message = message;
                responseWrapper.accountId = accountId;
                
                OTP_Verification__c record = new OTP_Verification__c();
                record.Status__c = 'Pending';
                record.To__c = toValue;
                record.Channel__c = key;
                record.Custom_Code__c = otpCode;
                record.Date_Created__c = createdTime;
                record.Date_Expires__c = expiryTime;
                record.Attempts_Checked__c = 0;
                record.Account__c = accountId;
                otpVerificationList.add(record);            
                response.put(key, responseWrapper);
                
            }
            
        }
        
        updateOTPStatus(accountId);
        
        if(!otpVerificationList.isEmpty()) {
            insert otpVerificationList;
        }
        
        return response;
        
    }
    
    public static Boolean sendSMS(String recipientNumber) {
        
        String authToken = authenticate();
        if (authToken == null) {
            return false;
        }
                
        String endpoint = baseUrl + '/campaigns/submissions/sms/nb';
        String smsBody = otpMessage.replaceAll('<br\\s*/?><br\\s*/?>', '\n').replaceAll('<br\\s*/?>', '');
        recipientNumber = recipientNumber.replace('+','');
        recipientNumber = recipientNumber.trim();
        Map<String, Object> requestBody = new Map<String, Object>{
            'msgCategory' => '4.2',
                'contentType' => '3.1',
                'senderAddr' => '800SOBHA',
                'dndCategory' => '',
                'priority' => 1,
                'clientTxnId' => '',
                'recipient' => recipientNumber,
                'msg' => smsBody,
                'dr' => '1',
                'expiryDt' => Datetime.now().addMinutes(5).format('yyyy-MM-dd\'T\'HH:mm:ss')
                };
                    
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + authToken);
        req.setBody(JSON.serialize(requestBody));
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 201) {
            return true;
        } else {
            return false;
        }
        
    }
    
    private static Boolean sendEmail(String emailAddress) {
        
        try {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{emailAddress});
            mail.setSubject('One-time verification code');
            mail.setHtmlBody(otpMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            return true;
            
        } catch (Exception e) {
            return false;
        }
        
    }

    public static String authenticate() {
        
        String endpoint = baseUrl + '/login/user/';
        Map<String, String> requestBody = new Map<String, String>{'username' => userName,'password' => password};
            
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200 ) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String authToken = (String) responseMap.get('token');
            return authToken;
        } else {
            return null;
        }
        
    }
    
    private static void updateOTPStatus(String accountId) {
        
        List<OTP_Verification__c> otpList = [SELECT Id, Account__c, Status__c 
                                             FROM OTP_Verification__c WHERE Account__c = :accountId AND Status__c = 'pending'];
        
        for(OTP_Verification__c otp : otpList) {
            otp.Status__c = 'Expired';
        }
        
        Update otpList;
        
    }
    
}