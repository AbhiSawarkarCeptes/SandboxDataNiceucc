/******************************************************
Class : Nice_CampaignDataAPI
Test Class : Nice_CampaignDataAPITest
Purpose : NICE - This Apex class updates the disposition of a NICE contact by making a callout to the NICE API, attaching a specified tag to a given calling session using an authorization token.
Author : Artee Varma
*******************************************************/


public with sharing class Nice_CampaignDataAPI {
    
    Final static String SOURCE = 'Nice_CampaignDataAPI.postToUploadAPI';
    
    //method to ivoke all APIs to send Task data
    public static String invokeNiceCallingApi(Set<Id> taskIds) {
        List<Map<String, Object>> taskHeaderList = new List<Map<String, Object>>();
        
        // Add the field names and field value to the header
        Map<String, Object> taskData = new Map<String, Object>();
        taskData.put('Booking', 'Booking');
        taskData.put('UnitName', 'Unit');
        taskData.put('AccountName', 'Account');
        taskData.put('OwnerId', 'Owner');
        taskData.put('CustomerName', 'CustomerName');
        taskData.put('Overdue', 'Overdue');
        taskData.put('PaidPercentage', 'PaidPercentage'); 
        taskData.put('UserId', 'UserId');
        taskData.put('NiceAgentId', 'NiceAgentId');
        taskHeaderList.add(taskData);       
        
        List<String> headerFields = new List<String>{'ID','Booking','UnitName','AccountName','Owner','CustomerName','Overdue','PaidPercentage','UserId','NiceAgentId','PhoneNum'};
            String taskHeaderJson = JSON.serialize(headerFields);
        
        // Call the Calling API method and get the wrapper response (access token + API response)
        Nice_CampaignHeaderAPI.ApiResponseWrapper responseWrapper = Nice_CampaignHeaderAPI.makePostCallout(taskHeaderJson);            
        
        String SOURCE = 'Nice_CampaignHeaderAPI.makePostCallout';
        
        if (responseWrapper.status_code == 200 && responseWrapper.calling_api_response.contains('listId')) { 
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(responseWrapper.calling_api_response);
            String listId = String.valueOf(parsedJson.get('listId'));
            String sendHeaderResponse = sendHeader(headerFields, taskIds, responseWrapper.access_Token, responseWrapper.isNewToken, listId, responseWrapper.listName);        
            Nice_LoggerUtility.createLog(SOURCE, taskHeaderJson, responseWrapper.calling_api_response,responseWrapper.status_code);
            return sendHeaderResponse;
        } else {
            return 'Error: List ID not available or API call failed.';
        }
    }
    
    //method to send data is csv format to 3rd api to get job id
    public static String sendHeader(List<String> headerFields, Set<Id> taskIds, String access_Token, Boolean isNewToken, String list_Id, String listName) {
        System.debug('list_id===>'+list_Id);
        
        //Id recordTypeCollection = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Collection').getRecordTypeId();
        
        if (headerFields == null || headerFields.isEmpty() || taskIds == null || taskIds.isEmpty()) {
            throw new IllegalArgumentException('Invalid input: headerFields and taskIds cannot be null or empty.');
        }
        
        // Query Task records based on provided taskIds
        List<Task__c> taskList = [SELECT Id, 
                                  Booking__r.Name, 
                                  booking__r.Unit_Name__c, 
                                  Booking__r.Account_Holder__c, 
                                  Owner.Name,
                                  //Account__r.Customer_Name__c, 
                                  Booking__r.Overdue__c, 
                                  Booking__r.Paid_Percentage__c,
                                  Booking__r.Account__r.Primary_Mobile_Number__c,
                                  Calling_Agent__c,
                                  Calling_Agent__r.Nice_User_ID__c,
                                  Skill_Id__c,
                                  Campaign__r.Id
                                  FROM Task__c 
                                  WHERE Id IN :taskIds];
        
        System.debug('HEADER FIELDS==>'+headerFields);
        String skillId = '';
        String campaignId = '';
        String csvData = '';        
        csvData += String.join(headerFields, ',') + '\n';
        
        for (Task__c t : taskList) {
            Booking__c b = t.Booking__r;     
            List<Object> row = new List<Object>();
            row.add(t.Id);
            row.add(String.isNotBlank(b.Name) ? b.Name : '');
            row.add(String.isNotBlank(b.Unit_Name__c) ? b.Unit_Name__c : '');
            row.add(String.isNotBlank(b.Account_Holder__c) ? b.Account_Holder__c : '');
            row.add(t.Owner.Name);
            // row.add(String.isNotBlank(t.Account__r.Customer_Name__c) ? t.Account__r.Customer_Name__c : '');
            row.add(b.Overdue__c != null ? String.valueOf(b.Overdue__c) : '');
            row.add(b.Paid_Percentage__c != null ? String.valueOf(b.Paid_Percentage__c) : '');
            row.add(t.Calling_Agent__c);
            row.add(t.Calling_Agent__r.Nice_User_ID__c);                      
            String encryptedPhone = Nice_EncryptionUtility.encryptPhoneNumber(b.Account__r.Primary_Mobile_Number__c);
            row.add(encryptedPhone);
            csvData += String.join(row, ',') + '\n';
            
            campaignId = t.Campaign__r.Id;
            skillId = t.Skill_Id__c;            
        }            
        
        System.debug('FINAL CSV=>'+csvData);
        
        String fileName = listName + '.csv';        
        Blob csvBlob = Blob.valueOf(csvData);
        String encodedCsv = EncodingUtil.base64Encode(csvBlob);
        
        String jsonBody = '{' +
            '"listFile": "' + encodedCsv + '",' +
            '"fileName": "' + fileName + '",' +
            '"skillId": "' + skillId + '",' +
            '"defaultTimeZone": "Arabian",' +
            '"forceOverwrite": true,' +
            '"expirationDate": "string",' +
            '"startSkill": true,' +
            '"sendEmail": true' +
            '}';
        system.debug('INPUT JSON BODY==>'+jsonBody);
        String jsonFinalOutput = postToUploadAPI(jsonBody, access_Token, isNewToken, list_Id);
        system.debug('FINAL JSON OUTPUT==>'+jsonFinalOutput);
        
        //calling method to attach csv file to campaign
        attachCSVToCamaign(campaignId, csvData, fileName);
        
        return  jsonFinalOutput;
    }
    
    //method to send final csv data to upload records 3rd api
    public static String postToUploadAPI(String jsonBody, String access_Token, Boolean isNewToken, String list_Id) {
        String endpoint = 'https://api-ae26.nicecxone.com/incontactapi/services/v31.0/lists/call-lists/'+list_Id+'/upload';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        //req.setHeader('Accept-Encoding', 'gzip, deflate, br');
        req.setHeader('Accept-Encoding', 'identity');
        req.setHeader('Authorization', 'Bearer ' + access_Token); 
        req.setBody(jsonBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        String uploadApiResponse;
        
        if (res.getStatusCode() == 200) {
            System.debug('SUCCESS: ' + res.getBody());
            uploadApiResponse = res.getBody();
            Nice_LoggerUtility.createLog(SOURCE, jsonBody, uploadApiResponse, res.getStatusCode());
        } else if (res.getStatusCode() == 202){
            uploadApiResponse = res.getBody();
            Nice_LoggerUtility.createLog(SOURCE, jsonBody, uploadApiResponse, res.getStatusCode());
            System.debug('UPLOAD RECORDS API RESPONSE BODY==>: ' + uploadApiResponse);            
        }else {
            System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getBody());
            uploadApiResponse = res.getStatusCode() + ' - ' + res.getBody();
            Nice_LoggerUtility.createLog(SOURCE, jsonBody, 'Failed to upload records for calling list', res.getStatusCode());
        }
        if(isNewToken){
            Nice_AccessTokenUtility.saveToken(access_Token);
        }
        return uploadApiResponse;
    }
    
    //method to attach a CSV file to the specified Campaign record
    //@future(callout=true)
    public static void attachCSVToCamaign(Id campaignId, String csvData, String fileName) {
        try {            
            if (String.isEmpty(csvData)) {
                throw new IllegalArgumentException('CSV data cannot be empty.');
            }
            if (campaignId == null) {
                throw new IllegalArgumentException('Campaign ID cannot be null.');
            }
            Attachment attachment = new Attachment(
                ParentId = campaignId,
                Name = fileName,
                Body = Blob.valueOf(csvData),
                ContentType = 'text/csv'
            );
            
            insert attachment;
            System.debug('CSV file successfully attached to Campaign ID: ' + campaignId);
            
        } catch (Exception e) {
            System.debug('Error creating or attaching CSV file: ' + e.getMessage());
        }
    }
}