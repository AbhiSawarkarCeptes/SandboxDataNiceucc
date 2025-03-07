/******************************************************
Class : Nice_Lead_PhoneValidationBatch
Test Class : Nice_Lead_PhoneValidationBatchTest
Purpose : NICE - To validate Phone on Lead
Author : Ayaz Anis 
*******************************************************/
global class Nice_Lead_PhoneValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    global List<Id> validPhoneRecordIds = new List<Id>();
    global List<Id> invalidPhoneRecordIds = new List<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, MobilePhone, Is_ValidPhone__c FROM Lead ' +
                       'WHERE MobilePhone != NULL AND Is_ValidPhone__c = false ' +
                       'ORDER BY CreatedDate DESC LIMIT 100';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Lead> leadsToValidate = (List<Lead>) scope;
        
        for (Lead lead : leadsToValidate) {
            try {
                system.debug('Performing phone validation for ID: ' + lead.Id);
                
                // Call the Phone Validation Utility
                String responseBody = Nice_PhoneValidationUtility.validatePhoneNumber(lead.MobilePhone);
                system.debug('Response for ID ' + lead.Id + ': ' + responseBody);
                
                if (!String.isBlank(responseBody)) {
                    if (responseBody.contains('"error"')) {
                        System.debug('Error response for lead ID ' + lead.Id + ': ' + responseBody);
                        invalidPhoneRecordIds.add(lead.Id);
                    } else {
                        Nice_PhoneValidationUtility.PhoneValidationResponse response =
                            (Nice_PhoneValidationUtility.PhoneValidationResponse) JSON.deserialize(responseBody, Nice_PhoneValidationUtility.PhoneValidationResponse.class);
                        
                        if (response.valid) {
                            validPhoneRecordIds.add(lead.Id);
                        } else {
                            invalidPhoneRecordIds.add(lead.Id);
                        }
                    }
                }
            } catch (Exception ex) {
                System.debug('Error processing lead ID ' + lead.Id + ': ' + ex.getMessage());
                invalidPhoneRecordIds.add(lead.Id);
            }
            system.debug('The size of the validPhoneRecordIds list after processing: ' + validPhoneRecordIds);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('The size of the validPhoneRecordIds list: ' + validPhoneRecordIds.size());
        system.debug('Valid Phone Records: ' + validPhoneRecordIds);
        
        if (!validPhoneRecordIds.isEmpty()) {
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Id leadId : validPhoneRecordIds) {
                leadsToUpdate.add(new Lead(Id = leadId, Is_ValidPhone__c = true));
            }
            if (!leadsToUpdate.isEmpty()) {
                try {
                    update leadsToUpdate;
                    System.debug('Successfully updated valid phone statuses for ' + leadsToUpdate.size() + ' records.');
                } catch (DmlException e) {
                    System.debug('Error updating valid phone records: ' + e.getMessage());
                }
            }
        }
        
        if (!invalidPhoneRecordIds.isEmpty()) {
            System.debug('The following records had invalid phone numbers or errors: ' + invalidPhoneRecordIds);
        }
        
        System.debug('Batch completed. Valid records: ' + validPhoneRecordIds.size() + ', Invalid records: ' + invalidPhoneRecordIds.size());
    }
}