/******************************************************
Class : Nice_PhoneValidationUtility
Test Class : Nice_PhoneValidationUtilityTest
Purpose : NICE - Utility class for Phone Validation
Author : Ayaz Anis
*******************************************************/
public with sharing class Nice_PhoneValidationUtility {
    
     Final static String SOURCE = 'Nice_PhoneValidationUtility.validatePhoneNumber';
     public static Nice_API_Configurations__mdt getInfo() {
        Nice_API_Configurations__mdt config = [SELECT API_Key__c, Base_URL__c 
                                  FROM Nice_API_Configurations__mdt 
                                  WHERE DeveloperName = 'PhoneValidation' LIMIT 1];
        return config;
    }
    
    @AuraEnabled
    public static String validatePhoneNumber(String phoneNumber) {
        Nice_API_Configurations__mdt conf = getInfo();
        String apiKey = conf.API_Key__c;
        String baseUrl = conf.Base_URL__c;
        String fullUrl = baseUrl + '?access_key=' + apiKey + 
                         '&number=' + EncodingUtil.urlEncode(phoneNumber, 'UTF-8');

        try {
            Http http = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(fullUrl);
            httpRequest.setMethod('GET');
            //httpRequest.setTimeout(2000); // timeout in milliseconds

            HttpResponse httpResponse = http.send(httpRequest);

            if (httpResponse.getStatusCode() == 200) {
				// Returning the raw JSON string
				Nice_LoggerUtility.createLog(SOURCE, fullUrl, httpResponse.getBody(), httpResponse.getStatusCode());
                return httpResponse.getBody();
            } else {
                System.debug('Error: Received status code ' + httpResponse.getStatusCode());
                Nice_LoggerUtility.createLog(SOURCE, fullUrl, httpResponse.getBody(), httpResponse.getStatusCode());
                return JSON.serialize(new Map<String, String>{
                    'error' => 'Error: Received status code ' + httpResponse.getStatusCode()
                });
            } 
        } catch (Exception ex) {
             System.debug('Exception occurred while making API callout: ' + ex.getMessage());
             Nice_LoggerUtility.createLog(SOURCE, fullUrl, 'Exception occurred while making API callout : '+ex.getMessage(), 500);
            return JSON.serialize(new Map<String, String>{
                'error' => 'Exception: ' + ex.getMessage()
            });
        }
    }

    public class PhoneValidationResponse {
    public Boolean valid { get; set; }
    public String mobNumber { get; set; }
    public String local_format { get; set; }
    public String international_format { get; set; }
    public String country_prefix { get; set; }
    public String country_code { get; set; }
    public String country_name { get; set; }
    public String location { get; set; }
    public String carrier { get; set; }
    public String line_type { get; set; }
}
}