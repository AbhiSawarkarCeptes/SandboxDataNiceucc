public with sharing class niceClickToViewController {
    // Import the NiceClickToDialController class
    //import NiceClickToDialController;
    
    @AuraEnabled
    public static List<Map<String, String>> getPhoneFieldsValueToClickToView(String recordId) {
        // Call the method from NiceClickToDialController
        return NiceClickToDialController.getPhoneFieldsValueToClickToView(recordId);
    }

}















/*
    @AuraEnabled
    public static List<Map<String, String>> getPhoneFieldsValueToClickToView(String recordId) {
        
        try{
            
            Id recId = recordId;
            SObjectType sObjectType = recId.getSObjectType();
            String objectName = String.valueOf(sObjectType);
            
            List<Nice_Click_To_Call__mdt> cmdtRecords = [SELECT Id, Object_Name__c, Field_Name__r.Label, Field_Name__r.QualifiedApiName, DeveloperName 
                                                         FROM Nice_Click_To_Call__mdt 
                                                         WHERE Object_Name__c = :objectName];
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
            System.debug('Executing Query: ' + query);
            SObject result = Database.query(query) ?? Null;
            
            if (result == Null) {
                throw new AuraHandledException('No records available for the provided Id. Please reach out system Administrator.');
            }
            
            List<Map<String, String>> phoneFields = new List<Map<String, String>>();
            for (String fieldName : fieldApiNames.KeySet()) {
                Object fieldValue = result.get(fieldName);
                //String phoneNumber = fieldValue != Null ? NICE_PhoneNumberEncryption.encryptPhoneNumber(String.valueOf(fieldValue)) : Null;
                //if (String.valueOf(fieldValue).trim() != '' ) {//fieldValue != null
                    phoneFields.add(new Map<String, String>{
                        'label'   => fieldApiNames.get(fieldName),
                        'value'   => String.isNotBlank(String.valueOf(fieldValue)) ? String.valueOf(fieldValue) : 'NA',//phoneNumber == Null ? 'NA' : phoneNumber;
                        'apiName' => fieldName
                        });
                //}
            }
            
            return phoneFields;
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    */
  /*  @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPhoneFields(String recordId) {
        Id recId = recordId;
        system.debug('recordId -->'+recordId);
        SObjectType sObjectType = recId.getSObjectType();
        system.debug('sObjectType --> '+sObjectType);
        Map<String, Schema.SObjectField> fieldsMap = sObjectType.getDescribe().fields.getMap();
        
        // Query the record
        SObject record = Database.query('SELECT ' + String.join(new List<String>(fieldsMap.keySet()), ',') + ' FROM ' + sObjectType.getDescribe().getName() + ' WHERE Id = :recordId LIMIT 1');
        
        List<Map<String, String>> phoneFields = new List<Map<String, String>>();
        for (String fieldName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.Phone) {
                Object fieldValue = record.get(fieldName);
                if (fieldValue != null) {
                  //  String phone = NICE_PhoneNumberEncryption.encryptPhoneNumber(String.valueOf(fieldValue));
                    phoneFields.add(new Map<String, String>{
                        'label' => fieldDescribe.getLabel(),
                        'value' => String.valueOf(fieldValue),
                        'apiName' => fieldName
                    });
                }
            }
        }
        return phoneFields;
    }*/
    
    
    



