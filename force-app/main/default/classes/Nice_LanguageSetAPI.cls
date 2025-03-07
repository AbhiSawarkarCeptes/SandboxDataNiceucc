/***************************************************************************
Class      : Nice_LanguageSetAPI
Test Class : Nice_LanguageAPITest
Purpose    : Nice - An Apex REST resource class helps update the preferred language 
             entered by the user in the record for the provided recordId.
Author     : Ashok Kumar M
*****************************************************************************/
@RestResource(urlMapping='/NicePreferredLanguage/*')
global with sharing class Nice_LanguageSetAPI {
    
    Final static String SOURCE = 'Nice_LanguageSetAPI.updatePreferredLanguage';
    
    @HttpPost
    global static String updatePreferredLanguage() {
        
        try {
            
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            PreferredLanguageRequest requestData = (PreferredLanguageRequest) JSON.deserialize(requestBody, PreferredLanguageRequest.class);
            
            if (String.isBlank(requestData.recordId) || String.isBlank(requestData.preferredLanguage)) {
                RestContext.response.statusCode = 400;
                Nice_LoggerUtility.createLog(SOURCE, requestBody, 'recordId and preferredLanguage are required.', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'recordId and preferredLanguage are required.'});
            }
            
            String recordId = requestData.recordId;
            String preferredLanguage = requestData.preferredLanguage;
            String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjName);
            Schema.DescribeSObjectResult objDescribe = sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = objDescribe.fields.getMap();
            
            if (!fieldsMap.containsKey('Preferred_Language__c')) {
                RestContext.response.statusCode = 500;
                Nice_LoggerUtility.createLog(SOURCE, requestBody, 'Preferred Language field not found on ' + sObjName, RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'Preferred Language field not found on ' + sObjName});
            }
            
            SObject record = sObjectType.newSObject();
            record.put('Id', recordId);
            record.put('Preferred_Language__c', preferredLanguage);
            update record;
            
            RestContext.response.statusCode = 200;
            Nice_LoggerUtility.createLog(SOURCE, requestBody, 'Preferred Language updated successfully.', RestContext.response.statusCode);
            return JSON.serialize(new Map<String, String>{'message' => 'Preferred Language updated successfully.'});
            
        } catch (Exception e) {
            
            RestContext.response.statusCode = 500;
            String responseMap;
            if (e.getMessage().contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST')) {
                responseMap = JSON.serialize(new Map<String, String>{'message' => 'The selected language is not available. Please choose a valid option.'});
            }else{
                responseMap = JSON.serialize(new Map<String, String>{'message' => e.getMessage()});
            }
            
            Nice_LoggerUtility.createLog(SOURCE, String.valueOf(RestContext.request.requestBody), responseMap, RestContext.response.statusCode);
            return responseMap;
            
        }
        
    }
    
    public class PreferredLanguageRequest {
        public String recordId;           
        public String preferredLanguage;  
    }
    
}