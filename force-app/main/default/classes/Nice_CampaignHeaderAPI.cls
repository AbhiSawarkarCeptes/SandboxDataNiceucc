/******************************************************
Class : Nice_CampaignHeaderAPI
Test Class : Nice_CampaignHeaderAPITest
Purpose : NICE - This class is used to send task header to Create Calling List to NICE API.
Author : Artee Varma
*******************************************************/

public class Nice_CampaignHeaderAPI {
    
    Final static String SOURCE = 'Nice_CampaignHeaderAPI.makePostCallout';
    
    public class ApiResponseWrapper {
        public String access_Token { get; set; }
        public String calling_api_response { get; set; }
        public Integer status_code { get; set; }
        public Boolean isNewToken { get; set; }
        public String listName { get; set; }
        
        public ApiResponseWrapper(String access_Token, Boolean isNewToken, String calling_api_response, Integer status_code, String listname) {
            this.access_Token = access_Token;
            this.isNewToken = isNewToken;
            this.calling_api_response = calling_api_response;
            this.status_code = status_code;
            this.listname = listname;
        }
    }
    
    //method to call NiceAPIAuthenticationTokenGenerator to get access token
    //and return list Id as response after posting task headers
    public static ApiResponseWrapper makePostCallout(String JsonParameters) {
        
        String encodedJsonParams = EncodingUtil.urlEncode(JsonParameters, 'UTF-8');
        String callingApiResult;
        Integer statusCode;
        Datetime currentDateTime = Datetime.now();
        String formattedDateTime = currentDateTime.format('yyyyMMddHHmmss');
        String listName = 'Collection_Calling_List_' + formattedDateTime;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String endpoint = 'https://api-ae26.nicecxone.com/incontactapi/services/v31.0/lists/call-lists'
            + '?listName=' + EncodingUtil.urlEncode(listName, 'UTF-8')
            + '&externalIdColumn=ID' + encodedJsonParams;
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        
        // Generate auth token
        Map<String, Boolean> tokenMap = Nice_AccessTokenUtility.getToken();
        String myToken;
        Boolean isNewToken;
        
        for(String key: tokenMap.keySet()){
            myToken = key;
            isNewToken = tokenMap.get(key);
        }
        
        req.setHeader('Authorization', 'Bearer ' + myToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setHeader('Accept-Encoding', 'identity');
        
        // Request body setup
        Map<String, Object> requestBody = new Map<String, Object>();
        List<Map<String, String>> destinationMappings = new List<Map<String, String>>();
        Map<String, String> mapping = new Map<String, String>();
        mapping.put('fieldName', 'PhoneNumber');
        mapping.put('fieldValue', 'Phonenum');
        destinationMappings.add(mapping);
        requestBody.put('destinationMappings', destinationMappings);
        
        String body = JSON.serialize(requestBody);
        req.setBody(body);
        
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                callingApiResult = res.getBody();
                statusCode = res.getStatusCode();
                System.debug('CALLING API Status => ' + statusCode + ' CALLING API RESULT=> ' + callingApiResult);
            } else {
                callingApiResult = res.getBody();
                statusCode = res.getStatusCode();
                Nice_LoggerUtility.createLog(SOURCE, body, callingApiResult, statusCode);
                System.debug('CALLING API Status => ' + statusCode + ' CALLING API RESULT=> ' + callingApiResult);
            }
        } catch (Exception e) {
            System.debug('Exception=>: ' + e.getMessage());
            statusCode = 500;
            callingApiResult = 'Exception: ' + e.getMessage();
            Nice_LoggerUtility.createLog(SOURCE, body, callingApiResult, statusCode);
            System.debug('CALLING API Status => ' + statusCode + ' something went wrong... ');
        }
        
        // Return the token and API response
        return new ApiResponseWrapper(myToken, isNewToken, callingApiResult, statusCode, listName);
    }
}