public class WebEngageServiceEnquiryContactHandler {
    @Future(callout=true)
    public static Void userPostAPI(String enquryJson){
        HTTPResponse postAPIResponse;
        HttpRequest hReq = WebEngageEnquiryHandler.createHttpRequestForUser();
        try{
            hReq = WebEngageEnquiryHandler.createHttpRequestBodyUser(hReq, enquryJson);
            system.debug('RequestBody:'+hReq.getBody() );
            postAPIResponse = new HTTP().send(hReq);
            WebEngageServiceEnquiryContactHandler.createLog(hreq, postAPIResponse,'WebEngageServiceEnquiryContactHandler.userPostAPI','');
            system.debug('responseBody'+postAPIResponse.getBody());
        } catch (Exception e) {
            System.debug('Exception in leadPostAPI: ' + e.getMessage());
            WebEngageServiceEnquiryContactHandler.createLog(hreq, postAPIResponse,'WebEngageServiceEnquiryContactHandler.userPostAPI', e.getMessage());
        }
    }
    
    @Future(callout=true)
    public static Void enquiryPostAPI(String enquryJson, String eventName){
        HTTPResponse postAPIResponse;
        HttpRequest hReq = WebEngageEnquiryHandler.createHttpRequestForEnquiry();
        try{
            hReq = WebEngageEnquiryHandler.createHttpRequestBodyForEnquiry(hReq, enquryJson, eventName);
            system.debug('RequestBody:'+hReq.getBody());
            postAPIResponse = new HTTP().send(hReq);
            WebEngageServiceEnquiryContactHandler.createLog(hreq, postAPIResponse,'WebEngageServiceEnquiryContactHandler.enquiryPostAPI','');
            system.debug('responseBody'+postAPIResponse.getBody());
            
        } catch (Exception e) {
            System.debug('Exception in EventPostAPI: ' + e.getMessage());
            WebEngageServiceEnquiryContactHandler.createLog(hreq, postAPIResponse,'WebEngageServiceEnquiryContactHandler.enquiryPostAPI',e.getMessage());
        }
        
    }
    public static Void createLog(HttpRequest hReq,HTTPResponse hRes,String className, String errMsg){
        API_Callout_Log__c errLog = new API_Callout_Log__c();
        errLog.Context_User__c = UserInfo.getUserId();
        errLog.Data_Source__c = className;
        errLog.EndPoint__c = hreq.getEndpoint();
        errLog.Method__c = hreq.getMethod();
        errLog.Request_Body__c = truncateToFieldSize(hReq.getBody(),API_Callout_Log__c.fields.Request_Body__c.getDescribe().getLength());//hReqBody;
        String requestHeaders = 'Content-Type:'+ hReq.getHeader('Content-Type') + ', Authorization:'+ hReq.getHeader('Authorization');
        // Get  request headers
        errLog.Request_Headers__c = truncateToFieldSize(requestHeaders, API_Callout_Log__c.fields.Request_Headers__c.getDescribe().getLength());
        
        if(hRes != null ) {
            errLog.Response_Status_Code__c = hRes.getStatusCode();
            errLog.Response_Status__c = hRes.getStatus();
            errLog.Response_Body__c = truncateToFieldSize(hRes.getBody(),API_Callout_Log__c.fields.Response_Body__c.getDescribe().getLength());
        }
        else {
            //errLog.Response_Status_Code__c = 500;
            errLog.Response_Status__c = 'Salesforce error';
            errLog.Response_Body__c = errMsg;
        }
        
        insert errLog;
        
    }
    public static String truncateToFieldSize(String str,Integer lengthLimit){
        return String.isNotBlank(str) && str.length() > lengthLimit ? str.substring(0,lengthLimit) : str;
    }
}