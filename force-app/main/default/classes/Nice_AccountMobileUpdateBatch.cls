/******************************************************
Class : Nice_AccountMobileUpdateBatch
Test Class : Nice_AccountMobileUpdateBatchTest
Purpose : NICE - Apex batch class handles mobile number with country code.
Author : Artee Verma
*******************************************************/

public class Nice_AccountMobileUpdateBatch implements Database.Batchable<SObject> {
    
    //Start Method
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id,
            Primary_Mobile__c,
            Primary_Mobile_Country_Code__c, 
            Primary_Mobile_Number__c,
            Secondary_Mobile__c,
            Secondary_Mobile_Country_Code__c,
            Secondary_Mobile_Number__c,
            Tertiary_Mobile__c,
            Tertiary_Mobile_Country_Code__c,
            Tertiary_Mobile_Number__c,
            Fourth_Mobile__c,
            Fourth_Mobile_Country_Code__c,
            Fourth_Mobile_Number__c,
            Primary_POA_Mobile__c,
            Primary_POA_Mobile_Country_Code__c,
            Primary_POA_Mobile_Number__c,
            Secondary_POA_Mobile__c,
            Secondary_POA_Mobile_Country_Code__c,
            Secondary_POA_Mobile_Number__c
            FROM 	Account
            WHERE 	(Primary_Mobile_Country_Code__c != null AND Primary_Mobile__c != null)
            OR 
            (Secondary_Mobile_Country_Code__c != null AND Secondary_Mobile__c != null)
            OR
            (Tertiary_Mobile_Country_Code__c != null AND Tertiary_Mobile__c != null)
            OR
            (Fourth_Mobile_Country_Code__c != null AND Fourth_Mobile__c != null)
            OR
            (Primary_POA_Mobile_Country_Code__c != null AND Primary_POA_Mobile__c != null)
            OR
            (Secondary_POA_Mobile_Country_Code__c != null AND Secondary_POA_Mobile__c != null)
        ]);
    }
    
    // Execute method
    public void execute(Database.BatchableContext BC, List<Account> accounts) {
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : accounts) {
            try {
                System.debug('Processing Account ID: ' + acc.Id);
                String mobileNumber = acc.Primary_Mobile__c;
                String mobileCountryCode = acc.Primary_Mobile_Country_Code__c;
                String secondaryNumber = acc.Secondary_Mobile__c;
                String secondaryMobileCountryCode = acc.Secondary_Mobile_Country_Code__c;
                String tertiaryNumber = acc.Tertiary_Mobile__c;
                String tertiaryCountryCode = acc.Tertiary_Mobile_Country_Code__c;
                String fourthNumber = acc.Fourth_Mobile__c;
                String fourthCountryCode = acc.Fourth_Mobile_Country_Code__c;
                String poa1Number = acc.Primary_POA_Mobile__c;
                String poa1CountryCode = acc.Primary_POA_Mobile_Country_Code__c;
                String poa2Number = acc.Secondary_POA_Mobile__c;
                String poa2CountryCode = acc.Secondary_POA_Mobile_Country_Code__c;
                
                //for primary number
                if(mobileNumber != null) {
                    if (mobileNumber.startsWith('+')) {
                        acc.Primary_Mobile_Number__c = mobileNumber;
                    }
                    else if (mobileNumber.startsWith('0')) {
                        acc.Primary_Mobile_Number__c = mobileCountryCode + mobileNumber.substringAfter('0');
                    }
                    else {
                        acc.Primary_Mobile_Number__c = mobileCountryCode + mobileNumber;
                    }
                }
                
                //for secondary number
                if(secondaryNumber != null) {
                    if (secondaryNumber.startsWith('+')) {
                        acc.Secondary_Mobile_Number__c = secondaryNumber;
                    }
                    else if (secondaryNumber.startsWith('0')) {
                        acc.Secondary_Mobile_Number__c = secondaryMobileCountryCode + secondaryNumber.substringAfter('0');
                    }
                    else {
                        acc.Secondary_Mobile_Number__c = secondaryMobileCountryCode + secondaryNumber;
                    }
                }
                
                //for tertiary number
                if(tertiaryNumber != null) {
                    if (tertiaryNumber.startsWith('+')) {
                        acc.Tertiary_Mobile_Number__c = tertiaryNumber;
                    }
                    else if (tertiaryNumber.startsWith('0')) {
                        acc.Tertiary_Mobile_Number__c = tertiaryCountryCode + tertiaryNumber.substringAfter('0');
                    }
                    else {
                        acc.Tertiary_Mobile_Number__c = tertiaryCountryCode + tertiaryNumber;
                    }
                }
                //for fourth number
                if(fourthNumber != null) {
                    if (fourthNumber.startsWith('+')) {
                        acc.Fourth_Mobile_Number__c = fourthNumber;
                    }
                    else if (fourthNumber.startsWith('0')) {
                        acc.Fourth_Mobile_Number__c = fourthCountryCode + fourthNumber.substringAfter('0');
                    }
                    else {
                        acc.Fourth_Mobile_Number__c = fourthCountryCode + fourthNumber;
                    }
                }
                //for poa1 number
                if(poa1Number != null) {
                    if (poa1Number.startsWith('+')) {
                        acc.Primary_POA_Mobile_Number__c = poa1Number;
                    }
                    else if (poa1Number.startsWith('0')) {
                        acc.Primary_POA_Mobile_Number__c = poa1CountryCode + poa1Number.substringAfter('0');
                    }
                    else {
                        acc.Primary_POA_Mobile_Number__c = poa1CountryCode + poa1Number;
                    }
                }
                //for poa2 number
                if(poa2Number != null) {
                    if (poa2Number.startsWith('+')) {
                        acc.Secondary_POA_Mobile_Number__c = poa2Number;
                    }
                    else if (poa2Number.startsWith('0')) {
                        acc.Secondary_POA_Mobile_Number__c = poa2CountryCode + poa2Number.substringAfter('0');
                    }
                    else {
                        acc.Secondary_POA_Mobile_Number__c = poa2CountryCode + poa2Number;
                    }
                }
                
                accountsToUpdate.add(acc);
                
            } catch (Exception e) {
                System.debug('Error processing Account ID ' + acc.Id + ': ' + e.getMessage());
            }
        }
        if (!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate;
                List<String> updatedAccountIds = new List<String>();
                for (Account acc : accountsToUpdate) {
                    updatedAccountIds.add(acc.Id);
                }
                String updatedAccountIdsString = String.join(updatedAccountIds, ', ');
            } catch (DmlException e) {
                System.debug('DML Error while updating Account IDs: ' + e.getMessage());
            }
        }
    }
    
    // Finish method
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch process completed successfully.');
    }
}