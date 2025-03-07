/***************************************************************************
Class      : Nice_ClickToDialUtility
Test Class : Nice_ClickToDialTest
Purpose    : Nice - An Apex class helps the LWC component display the phone numbers 
             available in the record based on CMDT configuration. 
Author     : Ashok Kumar M
*****************************************************************************/
public with sharing class Nice_ClickToDialUtility {

    @AuraEnabled
    public static List<Map<String, String>> getPhoneFields(String recordId) {
         System.debug('recordId' +recordId);
        try{
            
            Id recId = recordId;
            SObjectType sObjectType = recId.getSObjectType();
            String objectName = String.valueOf(sObjectType);
            System.debug('objectName' +objectName);
            
            List<Nice_Click_To_Call__mdt> cmdtRecords = [SELECT Id, Object_Name__r.QualifiedApiName	, Field_Name__r.Label, Field_Name__r.QualifiedApiName, DeveloperName, Order_No__c 
                                                         FROM Nice_Click_To_Call__mdt 
                                                         WHERE Object_Name__r.QualifiedApiName = :objectName ORDER By Order_No__c ASC];
            System.debug('cmdtRecords' +cmdtRecords);
            if (cmdtRecords.isEmpty()) {
                throw new AuraHandledException('No metadata records configured for this object. Please reach out system Administrator.');
            }
            
            Map<String, String>  fieldApiNames = new Map<String, String>();
            for (Nice_Click_To_Call__mdt cmdt : cmdtRecords) {
                fieldApiNames.put(cmdt.Field_Name__r.QualifiedApiName, cmdt.Field_Name__r.Label);
            }
            
            if (fieldApiNames.isEmpty()) {
                throw new AuraHandledException('No field names configured in metadata for this object. Please reach out system Administrator.');
            }
            System.debug('fieldApiNames' +fieldApiNames);
            String query = 'SELECT Id, ' + String.join(fieldApiNames.KeySet(), ', ') + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
            SObject result = Database.query(query) ?? Null;
            System.debug('result' +result);

            if (result == Null) {
                throw new AuraHandledException('No records available for the provided Id. Please reach out system Administrator.');
            }
            
            User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            String allowedProfiles = Label.NICE_Click_To_View_Accessible_Profiles;
            List<String> allowedProfilesList = allowedProfiles.split(',', 0);
            Boolean hasviewAccess = loggedInUser.Profile.Name.Contains('Admin') || allowedProfilesList.contains(loggedInUser.Profile.Name) ? true : false;
            
            List<Map<String, String>> phoneFields = new List<Map<String, String>>();
            phoneFields.add(new Map<String, String>{'click_To_View' => hasViewAccess ? 'Yes' : 'No'});
            for (String fieldName : fieldApiNames.KeySet()) {
                Object fieldValue = result.get(fieldName);
                String phoneNumber = fieldValue != Null ? Nice_EncryptionUtility.encryptPhoneNumber(String.valueOf(fieldValue)) : Null;
                phoneFields.add(new Map<String, String>{
                    'label'   => fieldApiNames.get(fieldName),
                    'value'   => String.isNotBlank(phoneNumber) ? phoneNumber : 'NA',
                    'actual_Phone' => fieldValue != Null ? String.valueOf(fieldValue) : 'NA',
                    'apiName' => fieldName
                    });
            }
            
            return phoneFields;
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static List<Map<String, String>> getPhoneFieldsValueToClickToView(String recordId) {
        
        try{
            
            Id recId = recordId;
            SObjectType sObjectType = recId.getSObjectType();
            String objectName = String.valueOf(sObjectType);
            
            List<Nice_Click_To_Call__mdt> cmdtRecords = [SELECT Id, Object_Name__r.QualifiedApiName	, Field_Name__r.Label, Field_Name__r.QualifiedApiName, DeveloperName 
                                                         FROM Nice_Click_To_Call__mdt 
                                                         WHERE Object_Name__r.QualifiedApiName	 = :objectName];
            if (cmdtRecords.isEmpty()) {
                throw new AuraHandledException('No metadata records configured for this object. Please reach out system Administrator.');
            }
            
            Map<String, String>  fieldApiNames = new Map<String, String>();
            for (Nice_Click_To_Call__mdt cmdt : cmdtRecords) {
                fieldApiNames.put(cmdt.Field_Name__r.QualifiedApiName, cmdt.Field_Name__r.Label);
            }
            
            if (fieldApiNames.isEmpty()) {
                throw new AuraHandledException('No field names configured in metadata for this object. Please reach out system Administrator.');
            }
            
            String query = 'SELECT Id, ' + String.join(fieldApiNames.KeySet(), ', ') + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
            SObject result = Database.query(query) ?? Null;
            
            if (result == Null) {
                throw new AuraHandledException('No records available for the provided Id. Please reach out system Administrator.');
            }
            
            List<Map<String, String>> phoneFields = new List<Map<String, String>>();
            for (String fieldName : fieldApiNames.KeySet()) {
                Object fieldValue = result.get(fieldName);
                phoneFields.add(new Map<String, String>{
                    'label'   => fieldApiNames.get(fieldName),
                    'value'   => String.isNotBlank(String.valueOf(fieldValue)) ? String.valueOf(fieldValue) : 'NA',
                    'apiName' => fieldName
                     });
            }
            
            return phoneFields;
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
 
}