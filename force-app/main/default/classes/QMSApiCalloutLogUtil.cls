public class QMSApiCalloutLogUtil {
    private API_Callout_Log__c log;
    
    private QMSApiCalloutLogUtil(List<String> dataSource){
        this.log = new API_Callout_Log__c();
        
        this.log.Context_User__c = UserInfo.getUserId();
        
        this.log.Data_Source__c = String.join(dataSource,',');
    }
    
    public static QMSApiCalloutLogUtil initializeLog(List<String> dataSource){
        return new QMSApiCalloutLogUtil(dataSource);
    }
    
    public static QMSApiCalloutLogUtil initializeLog(String dataSource){
        return new QMSApiCalloutLogUtil(new List<String>{dataSource});
    }
    
    /*public void logIt(HttpRequest hReq,Map<String,String> headerMap){
        headerMap = headerMap == NULL ? new Map<String,String>() : headerMap;
        
        this.log.EndPoint__c = hreq.getEndpoint();
        this.log.Method__c = hreq.getMethod();
        String headerString = '';
        for(String headerMapKey : headerMap.keySet()){
            headerString += (headerMapKey +' => '+ headerMap.get(headerMapKey)+'\n');
        }
        this.log.Request_Headers__c = truncateToFieldSize(headerString,API_Callout_Log__c.fields.Request_Headers__c.getDescribe().getLength());
 //headerString;
    }*/
    
    
    
    public void logIt(String requestBody, String method, String endPoint){
        
        this.log.EndPoint__c = endPoint;
        this.log.Method__c = method;
        this.log.Request_Body__c = truncateToFieldSize(requestBody,API_Callout_Log__c.fields.Request_Body__c.getDescribe().getLength());
    }
    
    public void logIt(String responseBody, Integer statusCode, String Status){
        this.log.Response_Status_Code__c = StatusCode;
        this.log.Response_Body__c = responseBody;
        this.log.Response_status__c=   Status;   
    }
    
    public void logIt(Exception ex){
         this.log.Error_Log__c = ex.getMessage()+' @ '+ex.getStackTraceString();
    }
    
    
    
    public static void finalizeLogs(QMSApiCalloutLogUtil logUtil){
       
           
                insert logUtil.log;
            
            
    }
    
    
   
    
    static String truncateToFieldSize(String str,Integer lengthLimit){
        return String.isNotBlank(str) && str.length() > lengthLimit ? str.substring(0,lengthLimit) : str;
    }
    
    
}