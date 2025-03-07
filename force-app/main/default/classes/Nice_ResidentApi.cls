/******************************************************
Class : Nice_ResidentApi
Test Class : Nice_ResidentApiTest
Purpose : NICE - Rest resource to get Resident Info
Author : Ayaz Anis
*******************************************************/
@RestResource(urlMapping='/NiceResidentRecordUpdate/*')
global class Nice_ResidentApi {
    
    @HttpPost
    global static String searchMobileNumber() {
        try {
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            ResidentRequestClass requestData = (ResidentRequestClass) JSON.deserialize(requestBody, ResidentRequestClass.class);
            
            List<Account> phoneMatches = new List<Account>();
            List<Account> emailMatches = new List<Account>();
            
            // Construct lists for phone numbers and emails to search
            List<String> phoneNumbers = new List<String>();
            List<String> emails = new List<String>();
            
            // Add valid phone numbers
            if (!String.isBlank(requestData.primaryMobileCountryCode) && !String.isBlank(requestData.primaryMobileNumber)) {
                phoneNumbers.add(requestData.primaryMobileCountryCode + requestData.primaryMobileNumber);
            }
            if (!String.isBlank(requestData.alternativeMobileCountryCode) && !String.isBlank(requestData.alternativeMobileNumber)) {
                phoneNumbers.add(requestData.alternativeMobileCountryCode + requestData.alternativeMobileNumber);
            }
            
            // Add valid emails
            if (!String.isBlank(requestData.primaryEmail)) {
                emails.add(requestData.primaryEmail);
            }
            if (!String.isBlank(requestData.alternateEmail)) {
                emails.add(requestData.alternateEmail);
            }
            
            // Query accounts that match the phone numbers
            if (!phoneNumbers.isEmpty()) {
                phoneMatches = [SELECT Id, Phone, PersonEmail FROM Account WHERE Phone IN :phoneNumbers];
            }
            
            // Query accounts that match the emails
            if (!emails.isEmpty()) {
                emailMatches = [SELECT Id, Phone, PersonEmail FROM Account WHERE PersonEmail IN :emails];
            }
            
            // Check if we have conflicting matches
            if (!phoneMatches.isEmpty() && !emailMatches.isEmpty()) {
                Set<Id> phoneAccountIds = new Set<Id>();
                for (Account acc : phoneMatches) {
                    phoneAccountIds.add(acc.Id);
                }
                
                for (Account acc : emailMatches) {
                    // If an email match belongs to a different account than the phone match, treat it as a conflict
                    if (!phoneAccountIds.contains(acc.Id)) {
                        System.debug('Conflict detected: Phone and Email belong to different accounts.');
                        // If no match found, create a new account
                        Account acco = new Account();
                        acco.Name = requestData.firstName + ' ' + requestData.lastName;
                        
                        // Assign first valid phone/email to new account
                        if (!phoneNumbers.isEmpty()) {
                            acco.Phone = phoneNumbers[0];
                        }
                      // Check if Person Accounts are enabled before setting PersonEmail
                        if (Schema.sObjectType.Account.fields.PersonEmail != null) {
                            if (!emails.isEmpty()) {
                                acco.PersonEmail = emails[0];
                            }
                        } else {
                            // Use a custom email field for Business Accounts if necessary
                            if (!emails.isEmpty()) {
                                acco.Email__c = emails[0];  // Replace Email__c with the actual custom field in your org
                            }
                        }

                        
                        insert acco;
                        
                        Resident__c res = createResident(acco.Id, requestData);
                        if (res != null) {
                            String response = constructResponseData(res);
                            System.debug('Response: ' + response);
                            return response;
                        }
                        
                        // RestContext.response.statusCode = 404;
                        // return JSON.serialize(new Map<String, String>{'message' => 'Conflict detected: Phone number and email belong to different accounts.'});
                    }
                }
            }
            
            // If only phone matches are found, use that account
            if (!phoneMatches.isEmpty()) {
                Resident__c res = createResident(phoneMatches[0].Id, requestData);
                if (res != null) {
                    String response = constructResponseData(res);
                    System.debug('Response: ' + response);
                    return response;
                }
            }
            
            // If only email matches are found, use that account
            if (!emailMatches.isEmpty()) {
                Resident__c res = createResident(emailMatches[0].Id, requestData);
                if (res != null) {
                    String response = constructResponseData(res);
                    System.debug('Response: ' + response);
                    return response;
                }
            }
            
            // If no match found, create a new account
            Account acco = new Account();
            acco.Name = requestData.firstName + ' ' + requestData.lastName;
            
            // Assign first valid phone/email to new account
            if (!phoneNumbers.isEmpty()) {
                acco.Phone = phoneNumbers[0];
            }
            // Check if Person Accounts are enabled before setting PersonEmail
            if (Schema.sObjectType.Account.fields.PersonEmail != null) {
                if (!emails.isEmpty()) {
                    acco.PersonEmail = emails[0];
                }
            } else {
                // Use a custom email field for Business Accounts if necessary
                if (!emails.isEmpty()) {
                    acco.Email__c = emails[0];  // Replace Email__c with the actual custom field in your org
                }
            }

            
            insert acco;
            
            Resident__c res = createResident(acco.Id, requestData);
            if (res != null) {
                String response = constructResponseData(res);
                System.debug('Response: ' + response);
                return response;
            }
            
            
            RestContext.response.statusCode = 500;
            return JSON.serialize(new Map<String, String>{'message' => 'No records found with the provided phone number or email'});
            
        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            return JSON.serialize(new Map<String, String>{
                'message' => 'An error occurred: ' + e.getMessage() + ' Line Number --> ' + e.getLineNumber()
                    });
        }
    }
    
    public static Resident__c createResident(Id accId, ResidentRequestClass requestData) {
        Resident__c res = new Resident__c();
        res.Account__c = accId;
        if(!String.isBlank(requestData.unitId))
            res.Unit__c = requestData.unitId;
        if(!String.isBlank(requestData.nationality))
            res.Nationality__c = requestData.nationality;
        if(!String.isBlank(requestData.typeOfTenant))
            res.Type_Of_Tenant__c = requestData.typeOfTenant;
        if (!String.isBlank(requestData.moveInDate)) {
            try {
                res.Move_In_Date__c = Date.valueOf(requestData.moveInDate);
            } catch (Exception e) {
                System.debug('Invalid date format: ' + requestData.moveInDate);
            }
        }
        if (!String.isBlank(requestData.moveOutDate)) {
            try {
                res.Move_Out_Date__c = Date.valueOf(requestData.moveOutDate);
            } catch (Exception e) {
                System.debug('Invalid date format: ' + requestData.moveOutDate);
            }
        }
        if (!String.isBlank(requestData.ejariStartDate)) {
            try {
                res.Ejari_Start_date__c = Date.valueOf(requestData.ejariStartDate);
            } catch (Exception e) {
                System.debug('Invalid date format: ' + requestData.ejariStartDate);
            }
        }
        if (!String.isBlank(requestData.ejariEndDate)) {
            try {
                res.Ejari_End_Date__c = Date.valueOf(requestData.ejariEndDate);
            } catch (Exception e) {
                System.debug('Invalid date format: ' + requestData.ejariEndDate);
            }
        }
        if (!String.isBlank(requestData.requestRaisedDate)) {
            try {
                res.Request_Raised_Date__c = Date.valueOf(requestData.requestRaisedDate);
            } catch (Exception e) {
                System.debug('Invalid date format: ' + requestData.requestRaisedDate);
            }
        }
        if (!String.isBlank(requestData.dtcmStartDate)) {
            try {
                res.DTCM_Start_Date__c = Date.valueOf(requestData.dtcmStartDate);
            } catch (Exception e) {
                System.debug('Invalid date format: ' + requestData.dtcmStartDate);
            }
        }
        if (!String.isBlank(requestData.dtcmEndDate)) {
            try {
                res.DTCM_End_Date__c = Date.valueOf(requestData.dtcmEndDate);
            } catch (Exception e) {
                System.debug('Invalid date format: ' + requestData.dtcmEndDate);
            }
        }
        if (!String.isBlank(requestData.requestApprovedDate)) {
            try {
                res.Request_Approved_Date__c = Date.valueOf(requestData.requestApprovedDate);
            } catch (Exception e) {
                System.debug('Invalid date format: ' + requestData.requestApprovedDate);
            }
        }
        insert res;
        return res;
    }
    
    private static String constructResponseData(Resident__c res) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('RecordId', res.Id);
        RestContext.response.statusCode = 200;
        return JSON.serialize(response);
    }
    
    public class ResidentRequestClass {
        public String firstName;
        public String lastName;
        public String primaryMobileCountryCode;
        public String primaryMobileNumber;
        public String alternativeMobileCountryCode;
        public String alternativeMobileNumber;
        public String primaryEmail;
        public String alternateEmail;
        public String unitId;
        public String nationality;
        public String typeOfTenant;
        public String moveInDate;
        public String moveOutDate;
        public String ejariStartDate;
        public String ejariEndDate;
        public String requestRaisedDate;
        public String dtcmStartDate;
        public String dtcmEndDate;
        public String requestApprovedDate;
    }
}