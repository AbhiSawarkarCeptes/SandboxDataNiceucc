/******************************************************
Class : Nice_AD_EmailValidationBatch
Test Class : Nice_AD_EmailValidationBatchTest
Purpose : NICE - To validate Email on Applicant Detail
Author : Ayaz Anis
*******************************************************/
global class Nice_AD_EmailValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    global List<Applicant_Details__c> validEmailRecords = new List<Applicant_Details__c>();
    global Set<Id> invalidEmailRecordIds = new Set<Id>();
    private Map<String, Boolean> emailValidationCache = new Map<String, Boolean>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Inside the Start');
        String query = 'SELECT Id, Email_Address__c, POA_Email_Id__c, POA_2_Email_Id__c, ' +
            'Is_ValidEmail__c, Is_ValidPOA_Email__c, Is_ValidPOA_2_Email__c ' +
            'FROM Applicant_Details__c ' +
            'WHERE (Email_Address__c != NULL AND Is_ValidEmail__c = false) ' +
            'OR (POA_Email_Id__c != NULL AND Is_ValidPOA_Email__c = false) ' +
            'OR (POA_2_Email_Id__c != NULL AND Is_ValidPOA_2_Email__c = false) ' +
            'ORDER BY CreatedDate DESC LIMIT 5';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('Inside the execute');
        List<Applicant_Details__c> applicantsToValidate = (List<Applicant_Details__c>) scope;
        System.debug('The records are: ' + applicantsToValidate);

        for (Applicant_Details__c applicant : applicantsToValidate) {
            try {
                // Validate Email_Address__c
                if (applicant.Email_Address__c != null && !applicant.Is_ValidEmail__c) {
                    validateAndUpdate(applicant, applicant.Email_Address__c, 'Email_Address__c');
                }

                // Validate POA_Email_Id__c
                if (applicant.POA_Email_Id__c != null && !applicant.Is_ValidPOA_Email__c) {
                    validateAndUpdate(applicant, applicant.POA_Email_Id__c, 'POA_Email_Id__c');
                }

                // Validate POA_2_Email_Id__c
                if (applicant.POA_2_Email_Id__c != null && !applicant.Is_ValidPOA_2_Email__c) {
                    validateAndUpdate(applicant, applicant.POA_2_Email_Id__c, 'POA_2_Email_Id__c');
                }

                // Add applicant to validEmailRecords if not already added
                if (!validEmailRecords.contains(applicant)) {
                    validEmailRecords.add(applicant);
                }
            } catch (Exception ex) {
                System.debug('Error processing applicant ID ' + applicant.Id + ': ' + ex.getMessage());
                invalidEmailRecordIds.add(applicant.Id);
            }
        }
    }

    private void validateAndUpdate(Applicant_Details__c applicant, String email, String emailField) {
        System.debug('Validating email: ' + email);

        // Check if the email is already validated
        if (emailValidationCache.containsKey(email)) {
            Boolean isDeliverable = emailValidationCache.get(email);
            updateFieldBasedOnCache(applicant, emailField, isDeliverable);
            return;
        }

        // If not cached, validate the email via API
        try {
            String responseBody = Nice_EmailValidationUtility.validateEmail(email);
            System.debug('API response for email: ' + email + ' is: ' + responseBody);

            if (!String.isBlank(responseBody)) {
                if (responseBody.contains('"error"')) {
                    System.debug('Error response for email: ' + email + ', response: ' + responseBody);
                    invalidEmailRecordIds.add(applicant.Id);
                    emailValidationCache.put(email, false); 
                } else {
                    Nice_EmailValidationUtility.EmailValidationResponse response =
                        (Nice_EmailValidationUtility.EmailValidationResponse) JSON.deserialize(responseBody, Nice_EmailValidationUtility.EmailValidationResponse.class);

                    Boolean isDeliverable = response.is_deliverable;
                    emailValidationCache.put(email, isDeliverable);
                    updateFieldBasedOnCache(applicant, emailField, isDeliverable);

                    if (!isDeliverable) {
                        invalidEmailRecordIds.add(applicant.Id);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + email + ', exception: ' + ex.getMessage());
            invalidEmailRecordIds.add(applicant.Id);
            emailValidationCache.put(email, false);
        }
    }

    private void updateFieldBasedOnCache(Applicant_Details__c applicant, String emailField, Boolean isDeliverable) {
        System.debug('Inside updateFieldBasedOnCache method');
        if (emailField == 'Email_Address__c') applicant.Is_ValidEmail__c = isDeliverable;
        if (emailField == 'POA_Email_Id__c') applicant.Is_ValidPOA_Email__c = isDeliverable;
        if (emailField == 'POA_2_Email_Id__c') applicant.Is_ValidPOA_2_Email__c = isDeliverable;
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('The size of the list validEmailRecords is: ' + validEmailRecords.size());
        System.debug('The validEmailRecords are: ' + validEmailRecords);

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