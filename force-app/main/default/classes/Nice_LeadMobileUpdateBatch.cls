/******************************************************
Class 		: Nice_LeadMobileUpdateBatch
Test Class  : Nice_LeadMobileUpdateBatchTest
Purpose 	: NICE - Apex batch class handles mobile number with country code.
Author 		: Artee Varma
*******************************************************/

public class Nice_LeadMobileUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    // Query to fetch Leads with missing Primary or Alternate Mobile Numbers
    public Database.QueryLocator start(Database.BatchableContext BC) {      
        return Database.getQueryLocator([
        	SELECT Id, 
                Primary_Mobile__c,
            	Primary_Mobile_Country_Code__c,
                Primary_Mobile_Number__c,
                Secondary_Mobile__c, 
            	Secondary_Mobile_Country_Code__c,
            	Secondary_Mobile_Number__c            
            FROM Lead 
            WHERE (Primary_Mobile__c != null AND Primary_Mobile_Country_Code__c != null)
                      OR
                  (Secondary_Mobile__c != null AND Secondary_Mobile_Country_Code__c != null)
        ]);
    }
    
    // Processes each batch of Lead records
    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Lead lead : scope) {
            String mobileNumber = lead.Primary_Mobile__c;
            String mobileCountryCode = lead.Primary_Mobile_Country_Code__c;
            String secondaryNumber = lead.Secondary_Mobile__c;
            String secondaryMobileCountryCode = lead.Secondary_Mobile_Country_Code__c;
            
            //for primary number
                if(mobileNumber != null) {
                    if (mobileNumber.startsWith('+')) {                    
                        lead.Primary_Mobile_Number__c = mobileNumber;
                    } 
                    else if (mobileNumber.startsWith('0')) {
                        lead.Primary_Mobile_Number__c = mobileCountryCode + mobileNumber.substringAfter('0');
                    } 
                    else {
                        lead.Primary_Mobile_Number__c = mobileCountryCode + mobileNumber;
                    }
                }
                
                //for secondary number
                if(secondaryNumber != null) {
                    if (secondaryNumber.startsWith('+')) {
                        lead.Secondary_Mobile_Number__c = secondaryNumber;
                    }                    
                    else if (secondaryNumber.startsWith('0')) {
                        lead.Secondary_Mobile_Number__c = secondaryMobileCountryCode + secondaryNumber.substringAfter('0');
                    } 
                    else {
                        lead.Secondary_Mobile_Number__c = secondaryMobileCountryCode + secondaryNumber;
                    }
                }
            leadsToUpdate.add(lead);
        }
        
        if (!leadsToUpdate.isEmpty()) {
            try {
                update leadsToUpdate;
                List<String> updatedLeadIds = new List<String>();
                for (Lead lead : leadsToUpdate) {
                    updatedLeadIds.add(lead.Id);
                }
                String updatedLeadIdsString = String.join(updatedLeadIds, ', ');
            } catch (DmlException e) {
                System.debug('Error updating Lead records: ' + e.getMessage());
            }
        }
    }
    
     // Finish method
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch job completed!');
    }
}