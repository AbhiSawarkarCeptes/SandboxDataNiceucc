/******************************************************
Class : Nice_SL_PhoneValidationBatch
Test Class : Nice_SL_PhoneValidationBatchTest
Purpose : NICE - To validate Phone on Stand Lead
Author : Ayaz Anis 
*******************************************************/

global class Nice_SL_PhoneValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    global List<Id> validPhoneRecordIds = new List<Id>();
    global List<Id> invalidPhoneRecordIds = new List<Id>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query for records where the phone needs validation
        String query = 'SELECT Id, Contact_Number__c, Country_Code__c, Syntax_Valid__c ' +
                       'FROM Stand_Lead__c ' +
                       'WHERE Contact_Number__c != NULL AND Country_Code__c	 != NULL AND Syntax_Valid__c = false ' +
                       'ORDER BY CreatedDate DESC LIMIT 100';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Stand_Lead__c> leadsToValidate = (List<Stand_Lead__c>) scope;

        for (Stand_Lead__c lead : leadsToValidate) {
            try {
                system.debug('The Validation for the ID is  : '+lead.id);
                // Combine Mobile Country Code and Contact Number for validation
                String mobileAndCountryCode = lead.Country_Code__c + lead.Contact_Number__c;
                system.debug('The mobile and CountryCode is : '+mobileAndCountryCode);
                
                String responseBody = Nice_PhoneValidationUtility.validatePhoneNumber(mobileAndCountryCode);
                
                system.debug('The response is : '+responseBody);

                if (!String.isBlank(responseBody)) {
                    if (responseBody.contains('"error"')) {
                        System.debug('Error response for lead ID ' + lead.Id + ': ' + responseBody);
                        invalidPhoneRecordIds.add(lead.Id);
                    } else {
                        Nice_PhoneValidationUtility.PhoneValidationResponse response =
                            (Nice_PhoneValidationUtility.PhoneValidationResponse) JSON.deserialize(responseBody, Nice_PhoneValidationUtility.PhoneValidationResponse.class);

                        // Determine validity and update lists
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
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Update records with valid phone numbers
        if (!validPhoneRecordIds.isEmpty()) {
            List<Stand_Lead__c> leadsToUpdate = new List<Stand_Lead__c>();
            for (Id leadId : validPhoneRecordIds) {
                leadsToUpdate.add(new Stand_Lead__c(Id = leadId, Syntax_Valid__c = true));
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

        // Log invalid records
        if (!invalidPhoneRecordIds.isEmpty()) {
            System.debug('The following records had invalid phone numbers or errors: ' + invalidPhoneRecordIds);
        }

        System.debug('Batch completed. Valid records: ' + validPhoneRecordIds.size() + ', Invalid records: ' + invalidPhoneRecordIds.size());
    }
}