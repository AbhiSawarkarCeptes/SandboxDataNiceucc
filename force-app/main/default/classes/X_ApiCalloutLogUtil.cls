public class X_ApiCalloutLogUtil {
	private API_Callout_Log__c log;
    
    private X_ApiCalloutLogUtil(List<String> dataSource){
    	this.log = new API_Callout_Log__c();
        
        this.log.Context_User__c = UserInfo.getUserId();
        
        this.log.Data_Source__c = String.join(dataSource,',');
    }
    
    public static X_ApiCalloutLogUtil initializeLog(List<String> dataSource){
        return new X_ApiCalloutLogUtil(dataSource);
    }
    
    public static X_ApiCalloutLogUtil initializeLog(String dataSource){
        return new X_ApiCalloutLogUtil(new List<String>{dataSource});
    }
    
    public void logIt(HttpRequest hReq,Map<String,String> headerMap){
        headerMap = headerMap == NULL ? new Map<String,String>() : headerMap;
        
        this.log.EndPoint__c = hreq.getEndpoint();
        this.log.Method__c = hreq.getMethod();
        String headerString = '';
        for(String headerMapKey : headerMap.keySet()){
            headerString += (headerMapKey +' => '+ headerMap.get(headerMapKey)+'\n');
        }
        this.log.Request_Headers__c = truncateToFieldSize(headerString,API_Callout_Log__c.fields.Request_Headers__c.getDescribe().getLength());
 //headerString;
    }
    
    public void logIt(String hReqBody){//redundant now
		
    }
    
    public void logIt(HttpRequest hReq){
        this.log.EndPoint__c = hreq.getEndpoint();
        this.log.Request_Body__c = truncateToFieldSize(hReq.getBody(),API_Callout_Log__c.fields.Request_Body__c.getDescribe().getLength());//hReqBody;
    }
    
    public void logIt(HttpResponse hRes){
  		 this.log.Response_Status_Code__c = hRes.getStatusCode();
		this.log.Response_Status__c = hRes.getStatus();
        String headerString = '';
        for(String headerMapKey : hRes.getHeaderKeys()){
            headerString += (headerMapKey +' => '+ hRes.getHeader(headerMapKey)+'\n');
        }
        this.log.Response_Headers__c =  truncateToFieldSize(headerString,API_Callout_Log__c.fields.Request_Headers__c.getDescribe().getLength());
// headerString;
        this.log.Response_Body__c = truncateToFieldSize(hRes.getBody(),API_Callout_Log__c.fields.Response_Body__c.getDescribe().getLength());
    }
    
    public void logIt(Exception ex){
         this.log.Error_Log__c = ex.getMessage()+' @ '+ex.getStackTraceString();
    }
    
    public static void finalizeLogs(List<X_ApiCalloutLogUtil> logUtils,Id xsdId){
        for(X_ApiCalloutLogUtil logUtil : logUtils){
            logUtil.log.Xpedeon_Sync_Delegate__c = xsdId;
        }
        finalizeLogs(logUtils);
    }
    
    public static void finalizeLogs(List<X_ApiCalloutLogUtil> logUtils){
        if(isAsyncContext()){
            for(X_ApiCalloutLogUtil logUtil : logUtils){
                insert logUtil.log;
            }
        }else{
        	finalizeLogsFuture(JSON.serialize(logUtils));
        }
    }
    
    @future
    public static void finalizeLogsFuture(String logUtilsString){
        List<X_ApiCalloutLogUtil> logUtils = (List<X_ApiCalloutLogUtil>) JSON.deserialize(logUtilsString,List<X_ApiCalloutLogUtil>.class);
        finalizeLogs(logUtils);
    }
    
    //UTILITIES
    static String truncateToFieldSize(String str,Integer lengthLimit){
        return String.isNotBlank(str) && str.length() > lengthLimit ? str.substring(0,lengthLimit) : str;
    }
    
    static Boolean isAsyncContext(){
        return System.isFuture() || System.isScheduled() || System.isQueueable() || System.isBatch();
    }
}