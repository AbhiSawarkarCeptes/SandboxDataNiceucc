/***************************************************************************
Class      : Nice_SearchCustomerAPI
Test Class : Nice_SearchCustomerTest
Purpose    : Nice - An Apex REST resource class returns information about the 
             customer to the NICE system for the provided phone number.
Author     : Ashok Kumar M
*****************************************************************************/
@RestResource(urlMapping='/NiceSearchCustomerInfo/*')
global with sharing class Nice_SearchCustomerAPI {
    
    Final static String SOURCE = 'Nice_SearchCustomerAPI.searchMobileNumber';
    
    @HttpPost
    global static String searchMobileNumber() {
        
        try {
            
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            PhoneNumberSearchRequest requestData = (PhoneNumberSearchRequest) JSON.deserialize(requestBody, PhoneNumberSearchRequest.class);
            
            if (String.isBlank(requestData.phoneNumber)) {
                RestContext.response.statusCode = 400;
                Nice_LoggerUtility.createLog(SOURCE, requestBody, 'Phone number is blank.', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'Phone number is blank.'});
            }
            
            String phoneNumber = test.isRunningTest() ? requestData.phoneNumber : Nice_EncryptionUtility.decryptPhoneNumber(requestData.phoneNumber);
            Map<String, Phone_Search_Object_Config__mdt> objectConfigMap = new Map<String, Phone_Search_Object_Config__mdt>([SELECT DeveloperName, Object_Name__c, Order_No__c 
                                                                                                                             FROM Phone_Search_Object_Config__mdt ORDER BY Order_No__c ASC ]);
            
            if (objectConfigMap.isEmpty()) {
                RestContext.response.statusCode = 206;
                Nice_LoggerUtility.createLog(SOURCE, requestBody, 'No valid CMDT configurations found.', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'No valid CMDT configurations found.'});
            }
            
            Map<String, List<Phone_Search_Field_Config__mdt>> fieldConfigMap = new Map<String, List<Phone_Search_Field_Config__mdt>>();
            Map<String, List<String>> objectAndFieldsMap = new Map<String, List<String>>();
            
            for (Phone_Search_Field_Config__mdt fieldConfig : [SELECT Phone_Search_Object_Config__c, Field_Name__c, Order_Number__c 
                                                               FROM Phone_Search_Field_Config__mdt ORDER BY Order_Number__c ASC]) {
                                                                   
                if (!fieldConfigMap.containsKey(fieldConfig.Phone_Search_Object_Config__c)) {
                    fieldConfigMap.put(fieldConfig.Phone_Search_Object_Config__c, new List<Phone_Search_Field_Config__mdt>());
                }
                fieldConfigMap.get(fieldConfig.Phone_Search_Object_Config__c).add(fieldConfig);
                
                if (!objectAndFieldsMap.containsKey(fieldConfig.Phone_Search_Object_Config__c)) {
                    objectAndFieldsMap.put(fieldConfig.Phone_Search_Object_Config__c, new List<String>());
                }
                objectAndFieldsMap.get(fieldConfig.Phone_Search_Object_Config__c).add(fieldConfig.Field_Name__c);
            }
            
            String soslQuery = 'FIND \'' + String.escapeSingleQuotes(phoneNumber) + '\' IN ALL FIELDS RETURNING ';
            List<String> soslObjectList = new List<String>();
            
            for (Phone_Search_Object_Config__mdt objConfig : objectConfigMap.values()) {
                if (objectAndFieldsMap.containsKey(objConfig.Id) && !objectAndFieldsMap.get(objConfig.Id).isEmpty()) {
                    soslObjectList.add(objConfig.Object_Name__c + '(' + String.join(objectAndFieldsMap.get(objConfig.Id), ', ') + ')');
                }
            }
            
            if (soslObjectList.isEmpty()) {
                RestContext.response.statusCode = 206;
                Nice_LoggerUtility.createLog(SOURCE, requestBody, 'No valid configurations found for SOSL.', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'No valid configurations found for SOSL.'});
            }
            
            soslQuery += String.join(soslObjectList, ', ');
            List<List<SObject>> searchResults = search.query(soslQuery);
            
            List<SObject> flatSearchResults = new List<SObject>();
            for (List<SObject> recordList : searchResults) {
                if (!recordList.isEmpty()) {
                    flatSearchResults.addAll(recordList);
                }
            }
            
           Map<String, List<Map<String, Object>>> matchingRecords = new Map<String, List<Map<String, Object>>>();
            
            for (Phone_Search_Object_Config__mdt objConfig : objectConfigMap.values()) {
                for (SObject record : flatSearchResults) {
                    if (record != null && record.getSObjectType().getDescribe().getName() == objConfig.Object_Name__c) {
                        Map<String, Object> recordMap = constructResponseData(record, objConfig.Object_Name__c, fieldConfigMap.get(objConfig.Id), phoneNumber);
                        
                        if (recordMap != null) {
                            if (!matchingRecords.containsKey(objConfig.Object_Name__c)) {
                                matchingRecords.put(objConfig.Object_Name__c, new List<Map<String, Object>>());
                            }
                            
                            matchingRecords.get(objConfig.Object_Name__c).add(recordMap);
                        }
                    }
                }
            }
            
            RestContext.response.statusCode = matchingRecords.isEmpty() ? 206 : 200;
            String responseMap = matchingRecords.isEmpty() ? JSON.serialize(new Map<String, String>{'message' => 'No records found with the provided phone number'}) : JSON.serialize(matchingRecords);
            Nice_LoggerUtility.createLog(SOURCE, requestBody, responseMap, RestContext.response.statusCode);
            return responseMap;
            
        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            Nice_LoggerUtility.createLog(SOURCE, String.valueOf(RestContext.request.requestBody) , e.getMessage(), RestContext.response.statusCode);
            return JSON.serialize(new Map<String, String>{'message' => e.getMessage()});
        }
        
    }
    
    private static Map<String, Object> constructResponseData(SObject record, String objectName, List<Phone_Search_Field_Config__mdt> fieldConfigs, String phoneNumber) {
        
        for (Phone_Search_Field_Config__mdt fieldConfig : fieldConfigs) {
            
            String fieldName = fieldConfig.Field_Name__c;
            if (record.get(fieldName) != null && record.get(fieldName) == phoneNumber) {
                
                Map<String, Object> response = new Map<String, Object>();
                response.put('RecordId', record.Id);
                response.put('Preferred_Language', record.get('Preferred_Language__c'));
                
                if (objectName == 'Lead') {
                    response.put('Nice_User_Id', getLeadRecord(record.Id));
                }
                
                if (objectName == 'Account') {
                    String accType = getRecordTypeName((String) record.get('recordTypeId'));
                    response.put('Account_Type', accType);
                    response.put('VIP_Customer', record.get('VIP_Customer__c'));
                    response.put('Registered_Customer', 'Yes');
                }
                
                response.put('Name', record.get('Name'));
                return response;
            }
        }
        
        return null;
        
    }
    
    private static String getLeadRecord(String leadId) {
        
        String niceUserId;
        Lead leadRecord = [SELECT Id, Name, Phone, Status, Presales_Agent__c, Presales_Agent__r.isActive, Presales_Agent__r.Nice_User_ID__c, Preferred_Language__c, Presales_Agent__r.ManagerId,
                           IsConverted, ConvertedAccountId, Presales_Agent__r.Manager.isActive
                           FROM Lead WHERE Id = :leadId LIMIT 1] ?? Null;
        
        if (leadRecord.Presales_Agent__c == Null) {
            niceUserId = Null;
        } else if (leadRecord.Presales_Agent__r.isActive && leadRecord.Presales_Agent__r.Nice_User_ID__c != Null) {
            niceUserId = leadRecord.Presales_Agent__r.Nice_User_ID__c;
        } else if (leadRecord.Presales_Agent__r.ManagerId == Null) {
            niceUserId = Null;
        } else if (!leadRecord.Presales_Agent__r.Manager.isActive) {
            niceUserId = Null; 
        } else {
            niceUserId = leadRecord.Presales_Agent__r.ManagerId; 
        }
        return niceUserId;
        
    }

    private static string getRecordTypeName(String recordTypeId) {
        
        if(recordTypeId == Null){return null;}
        RecordType recordType = [SELECT Name FROM RecordType WHERE Id = :recordTypeId  WITH USER_MODE LIMIT 1] ?? Null;
        return recordType != Null ? recordType.Name : Null;
        
    }
    
    public class PhoneNumberSearchRequest {
        public String phoneNumber;
    }
    
}