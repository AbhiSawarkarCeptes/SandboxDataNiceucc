/******************************************************
Class : Nice_DispositionAPI
Test Class : Nice_DispositionAPITest
Purpose : NICE - This Apex class updates the disposition of a NICE contact by making a callout to the NICE API, attaching a specified tag to a given calling session using an authorization token.
Author : Artee Varma
*******************************************************/

public class Nice_DispositionAPI {
    
    Final static String SOURCE = 'Nice_DispositionAPI.postToUpdateDisposition';
    
    @future(callout=true)
    public static void postToUpdateDisposition(String taskId, String callingId, String tagId) {
        System.debug('tag Id is future'  + tagId);
        // Generate auth token
        Map<String, Boolean> tokenMap = Nice_AccessTokenUtility.getToken();
        String myToken;
        Boolean isNewToken;
        
        for(String key: tokenMap.keySet()){
            myToken = key;
            isNewToken = tokenMap.get(key);
        }
        String endpoint = 'https://api-ae26.nicecxone.com/incontactapi/services/v31.0/contacts/'+callingId+'/tags';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setHeader('Accept-Encoding', 'identity');
        req.setHeader('Authorization', 'Bearer ' + myToken);
        
        // Request body setup
        Map<String, Object> requestBody = new Map<String, Object>();
        List<Map<String, Object>> tags = new List<Map<String, Object>>();
        Map<String, Object> mapping = new Map<String, Object>();
        mapping.put('tagId', tagId);
        //mapping.put('tagId', 3409);
        tags.add(mapping);
        requestBody.put('tags', tags);
        
        String jsonBody = JSON.serialize(requestBody);
        System.debug('jsonBody: ' + jsonBody);
        System.debug('Calling ID: ' + callingId);
        req.setBody(jsonBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        String updateApiResponse;
        System.debug('res: ' + res);
        if(isNewToken){
            Nice_AccessTokenUtility.saveToken(myToken);
        }
        if (res.getStatusCode() == 200) {
            updateApiResponse = res.getBody();
            System.debug('UPDATE RECORDS API RESPONSE==>: ' + updateApiResponse);
            Nice_LoggerUtility.createLog(SOURCE, jsonBody, updateApiResponse, res.getStatusCode());
        } else if (res.getStatusCode() == 202){
            updateApiResponse = res.getBody();
            System.debug('UPDATE RECORDS API RESPONSE==>: ' + updateApiResponse);
            Nice_LoggerUtility.createLog(SOURCE, jsonBody, updateApiResponse, res.getStatusCode());
        }else {
            System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getBody());
            updateApiResponse = res.getStatusCode() + ' - ' + res.getBody();
            System.debug('UPDATE RECORDS API RESPONSE==>: ' + updateApiResponse);
            Nice_LoggerUtility.createLog(SOURCE, jsonBody, updateApiResponse, res.getStatusCode());
        }
    }
}