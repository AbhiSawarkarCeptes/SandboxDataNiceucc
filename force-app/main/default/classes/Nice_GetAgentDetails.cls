@RestResource(urlMapping='/Nice_GetAgentDetails/*')
global with sharing class Nice_GetAgentDetails {
    
    Final static String SOURCE = 'Nice_GetAgentDetails.getAgentDetails';
    
    @HttpGet
    global static String getAgentDetails() {
        
        try {
            
            RestRequest req = RestContext.request;
            String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            
            if (String.isBlank(accountId)) {
                RestContext.response.statusCode = 400;
                NICE_APICalloutLogUtility.createLog(SOURCE, accountId, 'Missing required parameter: accountId is missing', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'Missing required parameter: accountId is missing'});
            }
            
            Set<Id> bookingIds = new Set<Id>();
            Set<String> agentNiceIds = new Set<String>();
            
            for (Applicant_Details__c appDetail : [SELECT Id, Account__c, Booking__c FROM Applicant_Details__c WHERE Account__c = :accountId AND Booking__c != Null]) {
                system.debug('appDetail.Booking__c -->'+appDetail.Booking__c);
                bookingIds.add(appDetail.Booking__c);
            }
            
            if (bookingIds.isEmpty()) {
                RestContext.response.statusCode = 206;
                NICE_APICalloutLogUtility.createLog(SOURCE, accountId, 'No Bookings records found for the provided accountId.', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'No Bookings records found for the provided accountId.'});
            }
            
            for (Collector_Assignment__c collAssign : [SELECT Id, User__c, User__r.Nice_User_ID__c FROM Collector_Assignment__c WHERE Booking__c IN :bookingIds]) {
                system.debug('collAssign -->'+collAssign);
                if (collAssign.User__r.Nice_User_ID__c != null) {
                    agentNiceIds.add(collAssign.User__r.Nice_User_ID__c);
                }
            }
            
            if(agentNiceIds.isEmpty()) {
                RestContext.response.statusCode = 206;
                NICE_APICalloutLogUtility.createLog(SOURCE, accountId, 'No nice userids found for the provided accountId.', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, String>{'message' => 'No nice userids found for the provided accountId.'});
            } else {
                RestContext.response.statusCode = 200;
                NICE_APICalloutLogUtility.createLog(SOURCE, accountId, 'Agent Ids retrieved successfully', RestContext.response.statusCode);
                return JSON.serialize(new Map<String, Object>{'message' => 'Agent Ids retrieved successfully', 'AgentId' => agentNiceIds});
            }
            
        } catch (Exception ex) {
            
            RestContext.response.statusCode = 500;
            NICE_APICalloutLogUtility.createLog(SOURCE, String.valueOf(RestContext.request), 'Agent Ids retrieved successfully', RestContext.response.statusCode);
            return JSON.serialize(new Map<String, String>{'message' => ex.getMessage()});
            
        }
        
    }
    
   // @HttpGet
    global static void getAccountById() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        if (String.isNotBlank(accountId)) {
            try {
                Set<Id> bookingIdSet = new Set<Id>();
                List<String> agentIdList = new List<String>();
                Set<String> agentIdSet = new Set<String>();

                for (Booking__c bk : [SELECT Id FROM Booking__c WHERE Account__c = :accountId AND Account__c != Null]) {
                    system.debug('bk.Id -->'+bk.Id);
                    bookingIdSet.add(bk.Id);
                }
                
               //Account -- Applicant -- Bookings -- 

                // Query collector assignments for those bookings
                for (Collector_Assignment__c collAss : [
                    SELECT Id, User__c, User__r.Nice_User_ID__c 
                    FROM Collector_Assignment__c 
                    WHERE Booking__c IN :bookingIdSet
                ]) {
                    system.debug('collAss -->'+collAss);
                    if (collAss.User__r.Nice_User_ID__c != null) {
                        agentIdSet.add(collAss.User__r.Nice_User_ID__c);
                    }
                }

                agentIdList.addAll(agentIdSet);
                system.debug('agentIdList -->'+ agentIdList);
                // Success response
                res.statusCode = 200; // OK
                res.responseBody = Blob.valueOf(
                    JSON.serialize(new Map<String, Object>{
                        'status' => 'success',
                        'message' => 'Data retrieved successfully',
                        'AgentId' => agentIdList
                    })
                );
            } catch (Exception e) {
                // Error response for exceptions
                res.statusCode = 500; // Internal Server Error
                res.responseBody = Blob.valueOf(
                    JSON.serialize(new Map<String, String>{
                        'status' => 'error',
                        'message' => 'An error occurred: ' + e.getMessage()
                    })
                );
            }
        } else {
            // Error response for missing Account ID
            res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf(
                JSON.serialize(new Map<String, String>{
                    'status' => 'error',
                    'message' => 'Invalid request: Account ID is missing'
                })
            );
        }
    }
}