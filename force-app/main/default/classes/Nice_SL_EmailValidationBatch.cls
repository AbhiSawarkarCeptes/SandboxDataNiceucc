/******************************************************
Class : Nice_SL_EmailValidationBatch
Test Class : Nice_SL_EmailValidationBatchTest
Purpose : NICE - To validate Email on Stand Lead
Author : Ayaz Anis 
*******************************************************/
global class Nice_SL_EmailValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    global List<Id> validEmailRecordIds = new List<Id>();
    global List<Id> invalidEmailRecordIds = new List<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Email__c,is_deliverable__c FROM Stand_Lead__c WHERE Email__c != NULL AND Is_Deliverable__c = false order by CreatedDate DESC LIMIT 5';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Stand_Lead__c> leadsToValidate = (List<Stand_Lead__c>) scope;
        
        for (Stand_Lead__c lead : leadsToValidate) {
            try {
                system.debug('Performing validation for id : '+lead.id);
                String responseBody = Nice_EmailValidationUtility.validateEmail(lead.Email__c);
                system.debug('The response for the ID is : '+responseBody);
                
                if (!String.isBlank(responseBody)) {
                    if (responseBody.contains('"error"')) {
                        System.debug('Error response for lead ID ' + lead.Id + ': ' + responseBody);
                        invalidEmailRecordIds.add(lead.Id);
                    } else {
                        Nice_EmailValidationUtility.EmailValidationResponse response =
                            (Nice_EmailValidationUtility.EmailValidationResponse) JSON.deserialize(responseBody, Nice_EmailValidationUtility.EmailValidationResponse.class);
                        if (response.is_deliverable) {
                            validEmailRecordIds.add(lead.Id);
                        } else {
                            invalidEmailRecordIds.add(lead.Id);
                        }
                    }
                }
            } catch (Exception ex) {
                System.debug('Error processing lead ID ' + lead.Id + ': ' + ex.getMessage());
                invalidEmailRecordIds.add(lead.Id);
            }
            system.debug('the size of the list validEmail after try '+validEmailRecordIds);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('the size of the list validEmail is '+validEmailRecordIds.size());
        system.debug('the size of the list validEmail is '+validEmailRecordIds);
        if (!validEmailRecordIds.isEmpty()) {
            List<Stand_Lead__c> leadsToUpdate = new List<Stand_Lead__c>();
            for (Id leadId : validEmailRecordIds) {
                leadsToUpdate.add(new Stand_Lead__c(Id = leadId, Is_Deliverable__c = true));
            }
            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
                System.debug('Successfully updated deliverable status for ' + leadsToUpdate.size() + ' records.');
            }
        }
        
        if (!invalidEmailRecordIds.isEmpty()) {
            System.debug('The following records had invalid emails or errors: ' + invalidEmailRecordIds);
        }
        
        System.debug('Batch completed. Valid records: ' + validEmailRecordIds.size() + ', Invalid records: ' + invalidEmailRecordIds.size());
    }
}