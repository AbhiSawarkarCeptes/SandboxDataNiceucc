//Test Class: TestLeadTrigger
public class WebEngageUtility {
    
    public static String getTransformedValue(WebEng_Sync_Fields__mdt  singleMap, String actualFieldValue){
        List<WebEng_Field_Transformation__mdt> transformationMap = new List<WebEng_Field_Transformation__mdt>();
        
        transformationMap = [SELECT Transformed_Value__c,Transform_Key__c  
                             FROM WebEng_Field_Transformation__mdt 
                             WHERE Web_Eng_Sync_Field__c = :singleMap.Id 
                             AND Transform_Key__c = :actualFieldValue LIMIT 1];
        
        
        system.debug('transformationMap::'+transformationMap);
        // system.debug('transformationMap.Transformed_Value__c::'+transformationMap.Transformed_Value__c);
        system.debug('actualFieldValue::'+actualFieldValue);
        return (!transformationMap.isEmpty())  ? transformationMap[0].Transformed_Value__c : '' ;
    }
    
    
    
    public static String getEventName(String leadStatus){
        String eventName =
            (leadStatus == 'Qualified') ? 'Lead Qualified' :
        ((leadStatus == 'Lost' || leadStatus == 'UnQualified') ? 'Lead Lost' :
         'Lead Disposition');
             return eventName;
        
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
    
    public static Void createLog(String errorMsg,Id recId, String className){
        API_Callout_Log__c errLog = new API_Callout_Log__c();
        errLog.Context_User__c = UserInfo.getUserId();
        errLog.Data_Source__c = className;
        errLog.Response_Body__c = recId;
        
        errLog.Response_Body__c = errorMsg;
        
        insert errLog;
        
        
    }
    public static String truncateToFieldSize(String str,Integer lengthLimit){
        return String.isNotBlank(str) && str.length() > lengthLimit ? str.substring(0,lengthLimit) : str;
    }
    
    
}