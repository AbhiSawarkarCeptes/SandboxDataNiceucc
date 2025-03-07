/******************************************************
Class : Nice_BR_EmailValidationBatch
Test Class : Nice_BR_EmailValidationBatchTest
Purpose : NICE - To validate Email on Broker Registration
Author : Ayaz Anis
*******************************************************/
global class Nice_BR_EmailValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    global List<Broker_Registration__c> validEmailRecords = new List<Broker_Registration__c>();
    global Set<Id> invalidEmailRecordIds = new Set<Id>();
    private Map<String, Boolean> emailValidationCache = new Map<String, Boolean>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('Inside the Start');
        String query = 'SELECT Id, Email__c, Alternate_Email__c, Account_Email__c, ' +
            'Is_ValidAccountEmail__c, Is_ValidEmail__c, Is_ValidOwnerEmail__c ' +
            'FROM Broker_Registration__c ' +
            'WHERE (Email__c != NULL AND Is_ValidEmail__c = false) ' +
            'OR (Alternate_Email__c != NULL AND Is_ValidOwnerEmail__c = false) ' +
            'OR (Account_Email__c != NULL AND Is_ValidAccountEmail__c = false) ' +
            'ORDER BY CreatedDate DESC LIMIT 5';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        system.debug('Inside the execute');
        List<Broker_Registration__c> brokersToValidate = (List<Broker_Registration__c>) scope;
        system.debug('The records are: ' + brokersToValidate);

        for (Broker_Registration__c broker : brokersToValidate) {
            try {
                // Validate Email__c
                if (broker.Email__c != null && !broker.Is_ValidEmail__c) {
                    validateAndUpdate(broker, broker.Email__c, 'Email__c');
                }

                // Validate Alternate_Email__c
                if (broker.Alternate_Email__c != null && !broker.Is_ValidOwnerEmail__c) {
                    validateAndUpdate(broker, broker.Alternate_Email__c, 'Alternate_Email__c');
                }

                // Validate Account_Email__c
                if (broker.Account_Email__c != null && !broker.Is_ValidAccountEmail__c) {
                    validateAndUpdate(broker, broker.Account_Email__c, 'Account_Email__c');
                }

                // Add broker to validEmailRecords if not already added
                if (!validEmailRecords.contains(broker)) {
                    validEmailRecords.add(broker);
                }
            } catch (Exception ex) {
                System.debug('Error processing broker ID ' + broker.Id + ': ' + ex.getMessage());
                invalidEmailRecordIds.add(broker.Id);
            }
        }
    }

    private void validateAndUpdate(Broker_Registration__c broker, String email, String emailField) {
        system.debug('Validating email: ' + email);

        // Check if the email is already validated
        if (emailValidationCache.containsKey(email)) {
            Boolean isDeliverable = emailValidationCache.get(email);
            updateFieldBasedOnCache(broker, emailField, isDeliverable);
            return;
        }

        // If not cached, validate the email via API
        try {
            String responseBody = Nice_EmailValidationUtility.validateEmail(email);
            system.debug('API response for email: ' + email + ' is: ' + responseBody);

            if (!String.isBlank(responseBody)) {
                if (responseBody.contains('"error"')) {
                    system.debug('Error response for email: ' + email + ', response: ' + responseBody);
                    invalidEmailRecordIds.add(broker.Id);
                    emailValidationCache.put(email, false);
                } else {
                    Nice_EmailValidationUtility.EmailValidationResponse response =
                        (Nice_EmailValidationUtility.EmailValidationResponse) JSON.deserialize(responseBody, Nice_EmailValidationUtility.EmailValidationResponse.class);

                    Boolean isDeliverable = response.is_deliverable;
                    emailValidationCache.put(email, isDeliverable);
                    updateFieldBasedOnCache(broker, emailField, isDeliverable);

                    if (!isDeliverable) {
                        invalidEmailRecordIds.add(broker.Id);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + email + ', exception: ' + ex.getMessage());
            invalidEmailRecordIds.add(broker.Id);
            emailValidationCache.put(email, false);
        }
    }

    private void updateFieldBasedOnCache(Broker_Registration__c broker, String emailField, Boolean isDeliverable) {
        if (emailField == 'Email__c') broker.Is_ValidEmail__c = isDeliverable;
        if (emailField == 'Alternate_Email__c') broker.Is_ValidOwnerEmail__c = isDeliverable;
        if (emailField == 'Account_Email__c') broker.Is_ValidAccountEmail__c = isDeliverable;
    }

    global void finish(Database.BatchableContext bc) {
        system.debug('The size of the list validEmailRecords is: ' + validEmailRecords.size());
        system.debug('The validEmailRecords are: ' + validEmailRecords);

        if (!validEmailRecords.isEmpty()) {
            try {
                update validEmailRecords;
                System.debug('Successfully updated valid email statuses for ' + validEmailRecords.size() + ' records.');
            } catch (Exception e) {
                System.debug('Error updating records: ' + e.getMessage());
            }
        }

        if (!invalidEmailRecordIds.isEmpty()) {
            System.debug('The following records had invalid emails or errors: ' + invalidEmailRecordIds);
        }

        System.debug('Batch completed. Valid records: ' + validEmailRecords.size() + ', Invalid records: ' + invalidEmailRecordIds.size());
    }
}