/******************************************************
Class : Nice_BR_PhoneValidationBatch
Test Class : Nice_BR_PhoneValidationBatchTest
Purpose : NICE - To validate Phone on Broker Registration
Author : Ayaz Anis 
*******************************************************/
global class Nice_BR_PhoneValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    global List<Broker_Registration__c> validPhoneRecords = new List<Broker_Registration__c>();
    global Set<Id> invalidPhoneRecordIds = new Set<Id>();
    private Map<String, Boolean> phoneValidationCache = new Map<String, Boolean>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Inside the Start');
        // Query to fetch records where phone numbers need validation
        String query = 'SELECT Id, Name, Telephone__c, Mobile__c, Is_ValidMobileNumber__c, Is_ValidTelephone__c, ' +
                       'Telephone_Country_Code__c, Mobile_Country_Code__c ' +
                       'FROM Broker_Registration__c ' +
                       'WHERE (Telephone__c != NULL AND Is_ValidTelephone__c = false) ' +
                       'OR (Mobile__c != NULL AND Is_ValidMobileNumber__c = false) ' +
                       'ORDER BY CreatedDate DESC LIMIT 5';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('Inside the execute');
        List<Broker_Registration__c> brokersToValidate = (List<Broker_Registration__c>) scope;
        System.debug('The records are: ' + brokersToValidate);

        for (Broker_Registration__c broker : brokersToValidate) {
            try {
                // Validate Mobile__c
                if (broker.Mobile__c != null && !broker.Is_ValidMobileNumber__c) {
                    validateAndUpdatePhone(broker, broker.Mobile__c, broker.Mobile_Country_Code__c, 'Mobile__c');
                }

                // Validate Telephone__c
                if (broker.Telephone__c != null && !broker.Is_ValidTelephone__c) {
                    validateAndUpdatePhone(broker, broker.Telephone__c, broker.Telephone_Country_Code__c, 'Telephone__c');
                }
            } catch (Exception ex) {
                System.debug('Error processing broker ID ' + broker.Id + ': ' + ex.getMessage());
                invalidPhoneRecordIds.add(broker.Id);
            }
        }
    }

    private void validateAndUpdatePhone(Broker_Registration__c broker, String phoneNumber, String countryCode, String phoneField) {
        System.debug('Validating phone: ' + phoneNumber);

        // Check if the phone number is already validated
        String fullPhoneNumber = countryCode + phoneNumber;
        if (phoneValidationCache.containsKey(fullPhoneNumber)) {
            Boolean isValid = phoneValidationCache.get(fullPhoneNumber);
            updateFieldBasedOnCache(broker, phoneField, isValid);
            return;
        }

        // If not cached, validate the phone number via API
        try {
            String responseBody = Nice_PhoneValidationUtility.validatePhoneNumber(fullPhoneNumber);
            System.debug('API response for phone: ' + fullPhoneNumber + ' is: ' + responseBody);

            if (!String.isBlank(responseBody)) {
                if (responseBody.contains('"error"')) {
                    System.debug('Error response for phone: ' + fullPhoneNumber + ', response: ' + responseBody);
                    invalidPhoneRecordIds.add(broker.Id);
                    phoneValidationCache.put(fullPhoneNumber, false);
                } else {
                    Nice_PhoneValidationUtility.PhoneValidationResponse response =
                        (Nice_PhoneValidationUtility.PhoneValidationResponse) JSON.deserialize(responseBody, Nice_PhoneValidationUtility.PhoneValidationResponse.class);

                    Boolean isValid = response.valid;
                    phoneValidationCache.put(fullPhoneNumber, isValid);
                    updateFieldBasedOnCache(broker, phoneField, isValid);

                    // Add broker to validPhoneRecords only if valid and not already added
                    if (isValid && !validPhoneRecords.contains(broker)) {
                        validPhoneRecords.add(broker);
                    } else if (!isValid) {
                        invalidPhoneRecordIds.add(broker.Id);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Error validating phone: ' + fullPhoneNumber + ', exception: ' + ex.getMessage());
            invalidPhoneRecordIds.add(broker.Id);
            phoneValidationCache.put(fullPhoneNumber, false);
        }
    }

    private void updateFieldBasedOnCache(Broker_Registration__c broker, String phoneField, Boolean isValid) {
        if (phoneField == 'Mobile__c') broker.Is_ValidMobileNumber__c = isValid;
        if (phoneField == 'Telephone__c') broker.Is_ValidTelephone__c = isValid;
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('The size of the list validPhoneRecords is: ' + validPhoneRecords.size());
        System.debug('The validPhoneRecords are: ' + validPhoneRecords);

        if (!validPhoneRecords.isEmpty()) {
            try {
                update validPhoneRecords;
                System.debug('Successfully updated valid phone statuses for ' + validPhoneRecords.size() + ' records.');
            } catch (Exception e) {
                System.debug('Error updating records: ' + e.getMessage());
            }
        }

        if (!invalidPhoneRecordIds.isEmpty()) {
            System.debug('The following records had invalid phone numbers or errors: ' + invalidPhoneRecordIds);
        }

        System.debug('Batch completed. Valid records: ' + validPhoneRecords.size() + ', Invalid records: ' + invalidPhoneRecordIds.size());
    }
}