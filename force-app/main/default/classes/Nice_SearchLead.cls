/***************************************************************************
Class      : Nice_SearchLead
Test Class : Nice_SearchLeadTest
Purpose    : Nice - An Apex REST resource class helps search for the lead 
             and returns NICE user IDs for the provided ID.
Author     : Ashok Kumar M
*****************************************************************************/
@RestResource(urlMapping='/NICE_SearchLead/*')
global with sharing class Nice_SearchLead {
    
    Final static String SOURCE = 'Nice_SearchLead.searchLead';
    
    @HttpPost
    global static String searchLead() {
        
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try{
            
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String jsonStr = body.toString();
            
            SearchLeadWrapper wrapper = (SearchLeadWrapper) JSON.deserialize(jsonStr, SearchLeadWrapper.class);
            
            if (String.isBlank(wrapper.phoneNumber)) {
                RestContext.response.statusCode = 400;
                responseMap.put('Message', 'Missing required parameter: phoneNumber');
                Nice_LoggerUtility.createLog(SOURCE, jsonStr, 'Missing required parameter: phoneNumber', RestContext.response.statusCode);
                return JSON.serialize(responseMap);
            }
            
            string PhoneNumber = test.isRunningTest() ? wrapper.phoneNumber : Nice_EncryptionUtility.decryptPhoneNumber(wrapper.phoneNumber);
            Lead leadRecord = getLeadRecord(PhoneNumber);
            
            if(leadRecord != Null){
                
                RestContext.response.statusCode = 200;
                responseMap.put('Message', 'The lead record for the provided phone number is found successfully.');
                responseMap.put('Preferred_Language', leadRecord.Preferred_Language__c);
                responseMap.put('Name', leadRecord.Name);
                responseMap.put('Lead_Id', leadRecord.Id);
                
                if (leadRecord.Presales_Agent__c == Null) {
                    responseMap.put('Nice_User_Id', Null);     
                } else if (leadRecord.Presales_Agent__r.isActive && leadRecord.Presales_Agent__r.Nice_User_ID__c != Null) {
                    responseMap.put('Nice_User_Id', leadRecord.Presales_Agent__r.Nice_User_ID__c);    
                } else if (leadRecord.Presales_Agent__r.ManagerId == Null) {
                    responseMap.put('Nice_User_Id', Null); 
                } else if (!leadRecord.Presales_Agent__r.Manager.isActive) {
                    responseMap.put('Nice_User_Id', Null); 
                } else {
                    Set<String> usrList = getAllActiveUsers(leadRecord.Presales_Agent__r.ManagerId);
                    responseMap.put('Nice_User_Id', usrList);
                }
                
            } else {
                
                RestContext.response.statusCode = 206;
                responseMap.put('Message', 'No lead record is found for the provided phone number.');
                
            }
            
        } catch (Exception e) {
            
            RestContext.response.statusCode = 500;
            responseMap.put('Message', e.getMessage());
            
        }
        
        Nice_LoggerUtility.createLog(SOURCE, String.valueOf(RestContext.request.requestBody), JSON.serialize(responseMap), RestContext.response.statusCode);
        return JSON.serialize(responseMap);
        
    }
    
    private static Lead getLeadRecord(String phoneNumber) {
        
        return [SELECT Id, Name, Primary_Mobile_Number__c, Secondary_Mobile_Number__c, Status, Presales_Agent__c, Presales_Agent__r.isActive, 
                Presales_Agent__r.Nice_User_ID__c, Preferred_Language__c, Presales_Agent__r.ManagerId,
                IsConverted, ConvertedAccountId, Presales_Agent__r.Manager.isActive
                FROM Lead WHERE Primary_Mobile_Number__c = :phoneNumber OR Secondary_Mobile_Number__c  = :phoneNumber LIMIT 1] ?? Null;
        
    }
    
    private static Set<String> getAllActiveUsers (String magagerId) {
        
        Set<string> userIds = new Set<String>();
        List<User> usrList = [SELECT Id, isActive, Nice_User_ID__c, ManagerId FROM user WHERE isActive = true 
                              AND ManagerId = :magagerId AND Id != :magagerId AND Nice_User_ID__c != Null];
        
        for(User u : usrList){
            userIds.add(u.Nice_User_ID__c);
        }
        return userIds;
        
    }
    
    public class SearchLeadWrapper {
        public string phoneNumber;
    }
    
}