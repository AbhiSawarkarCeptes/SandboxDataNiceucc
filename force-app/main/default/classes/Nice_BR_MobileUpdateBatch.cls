/******************************************************
Class 		: Nice_BR_MobileUpdateBatch
Test Class  : Nice_BR_MobileUpdateBatchTest
Purpose 	: NICE - Apex batch class handles mobile number with country code.
Author 		: Artee Varma
*******************************************************/

public class Nice_BR_MobileUpdateBatch implements Database.Batchable<SObject> {    
    //Start Method
    public Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator([
            SELECT Id,
            Mobile_Country_Code__c, 
            Primary_Mobile_Number__c,
            Mobile__c,
            Telephone_Country_Code__c, 
            Secondary_Mobile_Number__c,
            Telephone__c
            FROM Broker_Registration__c
            WHERE (Mobile_Country_Code__c != null AND Mobile__c != null)
            OR 
            (Telephone_Country_Code__c != null AND Telephone__c != null) 
        ]);
    }
    
    // Execute method
    public void execute(Database.BatchableContext BC, List<Broker_Registration__c> brokerregistrations) {
        System.debug('brokerregistrations: ' + brokerregistrations);
        List<Broker_Registration__c> brToUpdate = new List<Broker_Registration__c>();
        
        for (Broker_Registration__c br : brokerregistrations) {
            try {               
                System.debug('Processing BR ID: ' + br.Id);
                String mobileNumber = br.Mobile__c;
                String mobilecountryCode = br.Mobile_Country_Code__c;
                String telephoneNumber = br.Telephone__c;
                String telephonecountryCode = br.Telephone_Country_Code__c;
                
                //for primary mobile number
                if(mobileNumber != null) {
                    if (mobileNumber.startsWith('+')) {
                        br.Primary_Mobile_Number__c = mobileNumber;
                    }                    
                    else if (mobileNumber.startsWith('0')) {
                        br.Primary_Mobile_Number__c = mobilecountryCode + mobileNumber.substringAfter('0');                  
                    } 
                    else {
                        br.Primary_Mobile_Number__c = mobilecountryCode + mobileNumber;
                    }
                }
                
                //for telephone number
                if (telephoneNumber != null) {
                    if (telephoneNumber.startsWith('+')) {
                        br.Secondary_Mobile_Number__c = telephoneNumber;  
                    }
                    else if (telephoneNumber.startsWith('0')) {
                         br.Secondary_Mobile_Number__c = telephonecountryCode + telephoneNumber.substringAfter('0');
                    }
                    else {
                        br.Secondary_Mobile_Number__c = telephonecountryCode + telephoneNumber;
                    }
                }
                
                brToUpdate.add(br);
                
            } catch (Exception e) {
                System.debug('Error processing BR ID ' + br.Id + ': ' + e.getMessage());
            }
        }
        
        if (!brToUpdate.isEmpty()) {
            try {
                update brToUpdate;
                
                List<String> updatedBRIds = new List<String>();
                for (Broker_Registration__c br : brToUpdate) {
                    updatedBRIds.add(br.Id);
                }
                
                String updatedBRIdsString = String.join(updatedBRIds, ', ');
                System.debug('Successfully updated the following BR IDs: ' + updatedBRIdsString);
            } catch (DmlException e) {
                System.debug('DML Error while updating BR IDs: ' + e.getMessage());
            }
        }
    }
    // Finish method
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch process completed successfully.');
    }
}