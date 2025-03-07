/******************************************************
Class 		: Nice_ApplicantDetailsMobileUpdateBatch
Test Class  : Nice_AppDetailsMobUpdateBatchTest
Purpose 	: NICE - Apex batch class handles mobile number with country code.
Author 		: Artee Varma
*******************************************************/

public class Nice_ApplicantDetailsMobileUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<Id> recordIds; 
    public Nice_ApplicantDetailsMobileUpdateBatch(List<Id> recordIds) {
        this.recordIds = recordIds;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query to fetch records where all Mobile Numbers needs to be updated
        return Database.getQueryLocator([
            SELECT Id,
            	Mobile_Number__c,Mobile_Country_With_Code__c,Primary_Mobile_Number__c,
            	Secondary_Mobile_Number__c,Alternate_Mobile_Country_with_Code__c,Alternate_Mobile_Number__c,
            	Landline_Number__c,Landline_Number_Country_Code__c,Landline_Number_wcc__c,
            	Secondary_Contact_Number__c,Secondary_Contact_Country_Code__c,Secondary_Contact_Number_wcc__c,
            	POA_Contact_Number__c,POA_Contact_Country_Code__c,Authorized_Signatory2_Phone__c,
            	POA_2_Contact_Number__c,POA2_Contact_Country_Code__c,Authorized_Signatory3_Phone__c,
            	Organization_Phone_numbers__c,Office_Country_Code__c
            	FROM Applicant_Details__c
            	WHERE (Mobile_Number__c != null AND Mobile_County_Code__c != null)
            		OR
            		(Secondary_Mobile_Number__c != null AND Alternate_Mobile_Country_with_Code__c != null)
            		OR
            		(Landline_Number__c != null AND Landline_Number_Country_Code__c != null)
            		OR
            		(Secondary_Contact_Number__c != null AND Secondary_Contact_Country_Code__c !=null)
            		OR
            		(POA_Contact_Number__c != null AND POA_Contact_Country_Code__c !=null)
            		OR
            		(POA_2_Contact_Number__c != null ANd POA2_Contact_Country_Code__c != null)
            		OR
            		(Organization_Phone_numbers__c != null AND Office_Country_Code__c != null)
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Applicant_Details__c> scope) {
        List<Applicant_Details__c> recordsToUpdate = new List<Applicant_Details__c>();

        for (Applicant_Details__c record : scope) {
            String mobileNumber = record.Mobile_Number__c;
            String mobileCountryCode = record.Mobile_Country_With_Code__c;
            String secondaryNumber = record.Secondary_Mobile_Number__c;
            String secondaryMobileCountryCode = record.Alternate_Mobile_Country_with_Code__c;
            String landlineNumber = record.Landline_Number__c;
            String landlineCountryCode = record.Landline_Number_Country_Code__c;
            String secondaryContactNumber = record.Secondary_Contact_Number__c;
            String secondaryContactCountryCode = record.Secondary_Contact_Country_Code__c;
            String poaNumber = record.POA_Contact_Number__c;
            String poaCountryCode = record.POA_Contact_Country_Code__c;
            String poa2Number = record.POA_2_Contact_Number__c;
            String poa2CountryCode = record.POA2_Contact_Country_Code__c;
            String orgNumber = record.Organization_Phone_numbers__c;
            String orgCountryCode = record.Office_Country_Code__c;
            
			//checking for mobile number
            if(mobileNumber != null) {
                if (mobileNumber.startsWith('+')) {                    
                    record.Primary_Mobile_Number__c = mobileNumber;
                } 
                else if (mobileNumber.startsWith('0')) {
                    record.Primary_Mobile_Number__c = mobileCountryCode + mobileNumber.substringAfter('0');                  
                } 
                else {
                    record.Primary_Mobile_Number__c = mobileCountryCode + mobileNumber;
                }
            }
            // Alternate Mobile Number
            if (secondaryNumber != null) {
                if (secondaryNumber.startsWith('+')) {
                    record.Alternate_Mobile_Number__c = secondaryNumber;
                } 
                else if (secondaryNumber.startsWith('0')) {
                    record.Alternate_Mobile_Number__c = secondaryNumber + secondaryNumber.substringAfter('0');
                } 
                else {
                    record.Alternate_Mobile_Number__c = secondaryMobileCountryCode + secondaryNumber;
                }
            }
            
            // Landline Number
            if (landlineNumber != null) {
                if (landlineNumber.startsWith('+')) {
                    record.Landline_Number_wcc__c = landlineNumber;
                }  
                else if (landlineNumber.startsWith('0')) {
                    record.Landline_Number_wcc__c = landlineNumber + landlineNumber.substringAfter('0');
                } 
                else {
                    record.Landline_Number_wcc__c = landlineCountryCode + landlineNumber;
                }
            }
            
            // Secondary Contact Number
            if (secondaryContactNumber != null) {
                if (secondaryContactNumber.startsWith('+')) {
                    record.Secondary_Contact_Number_wcc__c = secondaryContactNumber;
                }
                else if (secondaryContactNumber.startsWith('0')) {
                    record.Secondary_Contact_Number_wcc__c = secondaryContactNumber + secondaryContactNumber.substringAfter('0');                    
                } 
                else {
                    record.Secondary_Contact_Number_wcc__c = secondaryContactCountryCode + secondaryContactNumber;
                }
            }
            
            // POA Contact Number
            if (poaNumber != null) {
                if (poaNumber.startsWith('+')) {
                    record.Authorized_Signatory2_Phone__c = poaNumber;
                } 
                else if (poaNumber.startsWith('0')) {
                    record.Authorized_Signatory2_Phone__c = poaNumber + poaNumber.substringAfter('0');                 
                } 
                else {
                    record.Authorized_Signatory2_Phone__c = poaCountryCode + poaNumber;
                }
            }
            
            // POA2 Contact Number
            if (poa2Number != null) {
                if (poa2Number.startsWith('+')) {
                    record.Authorized_Signatory3_Phone__c = poa2Number;
                }  
                else if (poa2Number.startsWith('0')) {
                    record.Authorized_Signatory3_Phone__c = poa2Number + poa2Number.substringAfter('0');                    
                } 
                else {
                    record.Authorized_Signatory3_Phone__c = poa2CountryCode + poa2Number;
                }
            }
            
            // Office Phone Number
            if (orgNumber != null) {
                if (orgNumber.startsWith('+')) {
                    record.Office_Phoner_Number_wcc__c = orgNumber;
                }   
                else if (orgNumber.startsWith('0')) {
                    record.Office_Phoner_Number_wcc__c = orgNumber + orgNumber.substringAfter('0');              
                } 
                else {
                    record.Office_Phoner_Number_wcc__c = orgCountryCode + orgNumber;
                }
            }            

            recordsToUpdate.add(record);
        }

        // Update the records in Salesforce
        if (!recordsToUpdate.isEmpty()) {
            try {
                update recordsToUpdate;
            } catch (DmlException e) {
                System.debug('Error updating Applicant Details records: ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Optionally send a notification or log the completion of the batch process
        System.debug('Batch Process for updating Primary Mobile Number completed.');
    }
}