/******************************************************
Class : Nice_Lead_EmailValidationBatch
Test Class : Nice_Lead_EmailValidationBatchTest
Purpose : NICE - To validate Email on Lead
Author : Ayaz Anis 
*******************************************************/
global class Nice_Lead_EmailValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    global List<Id> validEmailRecordIds = new List<Id>();
    global List<Id> invalidEmailRecordIds = new List<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('Inside Start');
        String query = 'SELECT Id,Name, Email, Is_ValidEmail__c, Lead_source__c, LeadSource,status ' +
               'FROM Lead ' +
               //'WHERE LeadSource = \'Stand Leads\' AND Lead_source__c = \'Stand Leads\' ' +
               'WHERE Email != NULL AND Is_ValidEmail__c = false AND Status !=\'Qualified\' ' +
               'ORDER BY CreatedDate DESC LIMIT 5';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        system.debug('Inside Execute');
        List<Lead> leadsToValidate = (List<Lead>) scope;
        system.debug('Leads to validate: ' + leadsToValidate);

        for (Lead ld : leadsToValidate) {
            try {
                // Perform email validation via the utility class
                String responseBody = Nice_EmailValidationUtility.validateEmail(ld.Email);
                system.debug('API response for email: ' + ld.Email + ' is: ' + responseBody);

                if (!String.isBlank(responseBody)) {
                    if (responseBody.contains('"error"')) {
                        system.debug('Error response for Lead ID ' + ld.Id + ': ' + responseBody);
                        invalidEmailRecordIds.add(ld.Id);
                    } else {
                        Nice_EmailValidationUtility.EmailValidationResponse response =
                            (Nice_EmailValidationUtility.EmailValidationResponse) JSON.deserialize(responseBody, Nice_EmailValidationUtility.EmailValidationResponse.class);
                        system.debug('The response for Email is '+response);
                        
                        if (response.is_deliverable) {
                            system.debug('The response for Email is '+response.is_deliverable);
                            validEmailRecordIds.add(ld.Id);
                            system.debug('The updated size of the validEmailRecordIds is '+validEmailRecordIds.size());
                        } else {
                            invalidEmailRecordIds.add(ld.Id);
                        }
                    }
                }
            } catch (Exception ex) {
                system.debug('Error processing Lead ID ' + ld.Id + ': ' + ex.getMessage());
                invalidEmailRecordIds.add(ld.Id);
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Inside Finish');
        system.debug('Valid Email IDs: ' + validEmailRecordIds);
        system.debug('Invalid Email IDs: ' + invalidEmailRecordIds);

        if (!validEmailRecordIds.isEmpty()) {
            try {
                List<Lead> leadsToUpdate = new List<Lead>();
                for (Id leadId : validEmailRecordIds) {
                    leadsToUpdate.add(new Lead(Id = leadId, Is_ValidEmail__c = true));
                }
                update leadsToUpdate;
                system.debug('Successfully updated ' + leadsToUpdate.size() + ' records as valid.');
            } catch (DmlException ex) {
                system.debug('Error updating valid email records: ' + ex.getMessage());
            }
        }

        if (!invalidEmailRecordIds.isEmpty()) {
            system.debug('The following records had invalid emails or errors: ' + invalidEmailRecordIds);
        }

        system.debug('Batch completed. Valid records: ' + validEmailRecordIds.size() + ', Invalid records: ' + invalidEmailRecordIds.size());
    }
}