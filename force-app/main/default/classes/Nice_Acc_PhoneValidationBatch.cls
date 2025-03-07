/******************************************************
Class : Nice_Acc_PhoneValidationBatch
Test Class : Nice_Acc_PhoneValidationBatchTest
Purpose : NICE - To validate phone numbers on Account  
Author : Ayaz Anis
*******************************************************/
global class Nice_Acc_PhoneValidationBatch  implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
	global List<Account> validPhoneRecords = new List<Account>();
    global Set<Id> invalidPhoneRecordIds = new Set<Id>();
	private Map<String, PhoneValidationDetails> phoneValidationCache = new Map<String, PhoneValidationDetails>();
    
     global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Inside the Start');
        // Query to fetch records where phone numbers need validation
        String query = 'SELECT Id, Primary_Mobile__c, Primary_Mobile_Country_Code__c, Primary_Mobile_Number__c, Is_Phone_validated__c, ' +
                       'Secondary_Mobile__c, Secondary_Mobile_Country_Code__c, Secondary_Mobile_Number__c, Is_Secondary_Validated__c  ' +
                       'FROM Account ' +
                       'WHERE (Primary_Mobile_Number__c != NULL AND Is_Phone_validated__c = false) ' +
                       'OR (Secondary_Mobile_Number__c != NULL AND Is_Secondary_Validated__c = false) ' +
                       'ORDER BY CreatedDate DESC LIMIT 5';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('Inside the execute');
        List<Account> accountsToValidate = (List<Account>) scope;
        System.debug('The records are: ' + accountsToValidate);

        for (Account acc : accountsToValidate) {
            try {
                // Validate Primary Number
                if (acc.Primary_Mobile_Number__c != null && !acc.Is_Phone_validated__c) {
                    validateAndUpdatePhone(acc, acc.Primary_Mobile_Number__c, 'Primary');
                }

                // Validate Secondary Number
                if (acc.Secondary_Mobile_Number__c != null && !acc.Is_Secondary_Validated__c) {
                    validateAndUpdatePhone(acc, acc.Secondary_Mobile_Number__c, 'Secondary');
                }
            } catch (Exception ex) {
                System.debug('Error processing account ID ' + acc.Id + ': ' + ex.getMessage());
                invalidPhoneRecordIds.add(acc.Id);
            }
        }
    }
    
     private void validateAndUpdatePhone(Account acc, String phoneNumber , String phoneField) {
        System.debug('Validating phone: ' + phoneNumber);

        // Check if the phone number is already validated
       // String fullPhoneNumber = countryCode + phoneNumber;
        if (phoneValidationCache.containsKey(phoneNumber)) {
            PhoneValidationDetails cachedDetails = phoneValidationCache.get(phoneNumber);
            updateFieldBasedOnCache(acc, phoneField, cachedDetails);
            return;
        }

        // If not cached, validate the phone number via API
        try {
            String responseBody = Nice_PhoneValidationUtility.validatePhoneNumber(phoneNumber);
            System.debug('API response for phone: ' + phoneNumber + ' is: ' + responseBody);

            if (!String.isBlank(responseBody)) {
                if (responseBody.contains('"error"')) {
                    System.debug('Error response for phone: ' + phoneNumber + ', response: ' + responseBody);
                    invalidPhoneRecordIds.add(acc.Id);
                    phoneValidationCache.put(phoneNumber, new PhoneValidationDetails(false, null, null, null));
                } else {
                    Nice_PhoneValidationUtility.PhoneValidationResponse response = 
                        (Nice_PhoneValidationUtility.PhoneValidationResponse) JSON.deserialize(responseBody, Nice_PhoneValidationUtility.PhoneValidationResponse.class);

                    Boolean isValid = response.valid;
                    String countryName = response.country_name;
                    String countryCode = response.country_prefix;
                    String primaryMobile = response.local_format;
                   // Store all retrieved values in cache
                    PhoneValidationDetails validationDetails = new PhoneValidationDetails(isValid, countryName, countryCode, primaryMobile);
                    phoneValidationCache.put(phoneNumber, validationDetails);
                    
                    updateFieldBasedOnCache(acc, phoneField, validationDetails);

                    // Add broker to validPhoneRecords only if valid and not already added
                    if (isValid && !validPhoneRecords.contains(acc)) {
                        validPhoneRecords.add(acc);
                    } else if (!isValid) {
                        invalidPhoneRecordIds.add(acc.Id);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Error validating phone: ' + phoneNumber + ', exception: ' + ex.getMessage());
            invalidPhoneRecordIds.add(acc.Id);
    		phoneValidationCache.put(phoneNumber, new PhoneValidationDetails(false, null, null, null));
        }
    }

     private void updateFieldBasedOnCache(Account acc, String phoneField, PhoneValidationDetails details) {
         if (phoneField == 'Primary'){
           acc.Is_Phone_validated__c = details.isValid;
           acc.Primary_Mobile__c = details.primaryMobile;
           acc.Primary_Mobile_Country_Code__c = details.countryCode;
          // acc.Primary_Mobile_Country__c = details.countryName;  
         } 
        if (phoneField == 'Secondary') {
           acc.Is_Secondary_Validated__c = details.isValid;
           acc.Secondary_Mobile__c = details.primaryMobile;
           acc.Secondary_Mobile_Country_Code__c = details.countryCode;
           //acc.Secondary_Mobile_Country__c = details.countryName;  
         } 
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
    
    // Wrapper class to store phone validation details
  public class PhoneValidationDetails {
    public Boolean isValid;
    public String countryName;
    public String countryCode;
    public String primaryMobile;

    public PhoneValidationDetails(Boolean isValid, String countryName, String countryCode, String primaryMobile) {
        this.isValid = isValid;
        this.countryName = countryName;
        this.countryCode = countryCode;
        this.primaryMobile = primaryMobile;
    }
}

}