public class NICE_APICalloutLogUtility {
    
    @future
    public static Void createLog(String source, String requestBody, String responseBody, integer statusCode){
        
        API_Callout_Log__c errLog = new API_Callout_Log__c();
        errLog.Context_User__c = UserInfo.getUserId();
        errLog.Data_Source__c = source;
        errLog.Request_Body__c = requestBody;
        errLog.Response_Body__c = responseBody;
        errLog.Response_Status_Code__c = statusCode;
        insert errLog;
        
    }
    
}