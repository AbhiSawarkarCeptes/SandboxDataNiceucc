/**
 * @created by : Aayushi Goel
 * @created Date : 18 May, 2023
 * @purpose : SOB-551( to create a common framework which should be used for all integration functionality)
 */
global class ApiUtility {
    /**
     * @method : httpCalloutUsingUserNamePassword
     * @purpose : for making http callout using username password authentication
     */
    public static HttpResponseWrapper httpCalloutUsingUserNamePassword(String endPoint, String methodName, 
    String userName, String password){
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod(methodName);
            Blob headerValue = Blob.valueOf(username + ':' + password);// Specify the required user name and password to access the endpoint
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue); // As well as the header and header information
            req.setHeader('Authorization', authorizationHeader);
            Http http = new Http();  // Create a new http object to send the request object
            HTTPResponse res = http.send(req);  // A response object is generated as a result of the request  
            if(res.getStatusCode() != 200){
                
            }
            return prepareResponseObj(res,null);
        }catch(Exception e){
            logAnException(endpoint, null,null,null);
            return prepareResponseObj(null,e.getMessage());
        }
    }
    /**
     * @method : httpCalloutUsingNamedCredentials
     * @purpose : for making http callout using named credentials
     */
    public static HttpResponseWrapper httpCalloutUsingNamedCredentials(String namedCredential, String methodName, String body){
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:'+namedCredential+'/some_path');
            req.setMethod(methodName);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() != 200){
                logAnException(namedCredential, null,null,null);
            }
            return prepareResponseObj(res,null);
        }catch(Exception e){
            return prepareResponseObj(null,e.getMessage());
        }

    }
    /**
     * @class : HttpResponseWrapper
     * @purpose : to enable common http response for all inbound calls to salesforce
     */
    Global class HttpResponseWrapper{
        global String status;
        global Integer statusCode;
        global String body;
        global boolean success;
        global String Message;
    }
    /**
     * @method : prepareResponseObj
     * @purpose : to process http response
     */
    private static HttpResponseWrapper prepareResponseObj(HttpResponse res, String errorMessage){
        HttpResponseWrapper wrap = new HttpResponseWrapper();
        if(res != null){
            wrap.status = res.getStatus();
            wrap.statusCode = res.getStatusCode();
            wrap.body = res.getBody();
            wrap.success = res.getStatusCode() == 200? true:false;
            
        }else{
            wrap.success = false;
            wrap.statusCode = 999;
            wrap.Message = errorMessage;
        }
        return wrap;
       
    }
    public static void logAnException(String endPoint, String errorMessage, String body, String apiType){
        Error_Log__c logError = new Error_Log__c(Message__c = errorMessage);
        logError.endpoint__c = endPoint;
        logError.Request__c = body;
        logError.Api_Type__c = apiType;
        logError.class__c = 'ApiUtility';
        insert logError;
    }
}