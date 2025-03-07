/******************************************************
Class : Nice_AD_PhoneValidationBatch
Test Class : Nice_AD_PhoneValidationBatchTest
Purpose : NICE - To validate Phone on Applicant Detail
Author : Ayaz Anis 
*******************************************************/
global class Nice_AD_PhoneValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
 
    global List<Applicant_Details__c> validPhoneRecords = new List<Applicant_Details__c>();
    global Set<Id> invalidPhoneRecordIds = new Set<Id>();
    private Map<String, Boolean> phoneValidationCache = new Map<String, Boolean>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Inside the Start');
        // Query to fetch records where phone numbers need validation
        String query = 'SELECT Id, Mobile_Country_With_Code__c, Mobile_Number__c,Is_ValidMobileNumber__c, Alternate_Mobile_Country_with_Code__c, Secondary_Mobile_Number__c,Is_ValidAlternateMobileNumber__c, Landline_Number__c, Landline_Number_Country_Code__c, Is_ValidLandlineNumber__c,' +
                       'Secondary_Contact_Country_Code__c, Secondary_Contact_Number__c, Is_ValidSecondaryContactNumber__c, POA_Contact_Country_Code__c, POA_Contact_Number__c, Is_ValidPOAContactNumber__c, POA2_Contact_Country_Code__c, POA_2_Contact_Number__c, Is_ValidPOA2ContactNumber__c, Office_Country_Code__c, Organization_Phone_numbers__c, Is_ValidOfficeNumber__c ' +
                       'FROM Applicant_Details__c ' +
                       'WHERE (Mobile_Number__c != NULL AND Is_ValidMobileNumber__c = false) ' +
                       'OR (Secondary_Mobile_Number__c != NULL AND Is_ValidAlternateMobileNumber__c = false) ' +
           			   'OR (Landline_Number__c != NULL AND Is_ValidLandlineNumber__c = false) ' +
            		   'OR (Secondary_Contact_Number__c != NULL AND Is_ValidSecondaryContactNumber__c = false) ' +
            		   'OR (POA_Contact_Number__c != NULL AND Is_ValidPOAContactNumber__c = false) ' +
            		   'OR (POA_2_Contact_Number__c != NULL AND Is_ValidPOA2ContactNumber__c = false) ' +
                       'OR (Organization_Phone_numbers__c != NULL AND Is_ValidOfficeNumber__c = false) ' +
                       'ORDER BY CreatedDate DESC LIMIT 5';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('Inside the execute');
        List<Applicant_Details__c> appsToValidate = (List<Applicant_Details__c>) scope;
        System.debug('The records are: ' + appsToValidate);

        for (Applicant_Details__c app : appsToValidate) {
            try {
                // Validate Mobile_Number__c
                if (app.Mobile_Number__c != null && !app.Is_ValidMobileNumber__c) {
                    validateAndUpdatePhone(app, app.Mobile_Number__c, app.Mobile_Country_With_Code__c, 'Mobile_Number__c');
                }

                // Validate Secondary_Mobile_Number__c
                if (app.Secondary_Mobile_Number__c != null && !app.Is_ValidAlternateMobileNumber__c) {
                    validateAndUpdatePhone(app, app.Secondary_Mobile_Number__c, app.Alternate_Mobile_Country_with_Code__c, 'Secondary_Mobile_Number__c');
                }
                
                 // Validate Landline_Number__c
                if (app.Landline_Number__c != null && !app.Is_ValidLandlineNumber__c) {
                    validateAndUpdatePhone(app, app.Landline_Number__c, app.Landline_Number_Country_Code__c, 'Landline_Number__c');
                }
                
                 // Validate Secondary_Mobile_Number__c
                if (app.Secondary_Contact_Number__c != null && !app.Is_ValidSecondaryContactNumber__c) {
                    validateAndUpdatePhone(app, app.Secondary_Contact_Number__c, app.Alternate_Mobile_Country_with_Code__c, 'Secondary_Contact_Number__c');
                }
                
                 // Validate POA_Contact_Number__c
                if (app.POA_Contact_Number__c != null && !app.Is_ValidPOAContactNumber__c) {
                    validateAndUpdatePhone(app, app.POA_Contact_Number__c, app.POA_Contact_Country_Code__c, 'POA_Contact_Number__c');
                }
                
                 // Validate POA_2_Contact_Number__c
                if (app.POA_2_Contact_Number__c != null && !app.Is_ValidPOA2ContactNumber__c) {
                    validateAndUpdatePhone(app, app.POA_2_Contact_Number__c, app.POA2_Contact_Country_Code__c, 'POA_2_Contact_Number__c');
                }
                
                 // Validate Secondary_Mobile_Number__c
                if (app.Organization_Phone_numbers__c != null && !app.Is_ValidOfficeNumber__c) {
                    validateAndUpdatePhone(app, app.Organization_Phone_numbers__c, app.Office_Country_Code__c, 'Organization_Phone_numbers__c');
                }
            } catch (Exception ex) {
                System.debug('Error processing app ID ' + app.Id + ': ' + ex.getMessage());
                invalidPhoneRecordIds.add(app.Id);
            }
        }
    }
    
     private void validateAndUpdatePhone(Applicant_Details__c app, String phoneNumber, String countryCode, String phoneField) {
        System.debug('Validating phone: ' + phoneNumber);

        // Check if the phone number is already validated
        String fullPhoneNumber = countryCode + phoneNumber;
        if (phoneValidationCache.containsKey(fullPhoneNumber)) {
            Boolean isValid = phoneValidationCache.get(fullPhoneNumber);
            updateFieldBasedOnCache(app, phoneField, isValid);
            return;
        }

        // If not cached, validate the phone number via API
        try {
            String responseBody = Nice_PhoneValidationUtility.validatePhoneNumber(fullPhoneNumber);
            System.debug('API response for phone: ' + fullPhoneNumber + ' is: ' + responseBody);

            if (!String.isBlank(responseBody)) {
                if (responseBody.contains('"error"')) {
                    System.debug('Error response for phone: ' + fullPhoneNumber + ', response: ' + responseBody);
                    invalidPhoneRecordIds.add(app.Id);
                    phoneValidationCache.put(fullPhoneNumber, false);
                } else {
                    Nice_PhoneValidationUtility.PhoneValidationResponse response =
                        (Nice_PhoneValidationUtility.PhoneValidationResponse) JSON.deserialize(responseBody, Nice_PhoneValidationUtility.PhoneValidationResponse.class);

                    Boolean isValid = response.valid;
                    phoneValidationCache.put(fullPhoneNumber, isValid);
                    updateFieldBasedOnCache(app, phoneField, isValid);

                    // Add app to validPhoneRecords only if valid and not already added
                    if (isValid && !validPhoneRecords.contains(app)) {
                        validPhoneRecords.add(app);
                    } else if (!isValid) {
                        invalidPhoneRecordIds.add(app.Id);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Error validating phone: ' + fullPhoneNumber + ', exception: ' + ex.getMessage());
            invalidPhoneRecordIds.add(app.Id);
            phoneValidationCache.put(fullPhoneNumber, false);
        }
    }

    private void updateFieldBasedOnCache(Applicant_Details__c app, String phoneField, Boolean isValid) {
        if (phoneField == 'Mobile_Number__c') app.Is_ValidMobileNumber__c = isValid;
        if (phoneField == 'Secondary_Mobile_Number__c') app.Is_ValidAlternateMobileNumber__c = isValid;
        if (phoneField == 'Landline_Number__c') app.Is_ValidLandlineNumber__c = isValid;
        if (phoneField == 'Secondary_Contact_Number__c') app.Is_ValidSecondaryContactNumber__c = isValid;
        if (phoneField == 'POA_Contact_Number__c') app.Is_ValidPOAContactNumber__c = isValid;
        if (phoneField == 'POA_2_Contact_Number__c') app.Is_ValidPOA2ContactNumber__c = isValid;
        if (phoneField == 'Organization_Phone_numbers__c') app.Is_ValidOfficeNumber__c = isValid;
        
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