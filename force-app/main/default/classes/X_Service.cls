//TestClass : X_Test_ServiceController
global class X_Service{
    static final Integer RETRY_LIMIT = 0;//5 
    static final Set<Integer> RETRY_RESPONSE_CODES = new Set<Integer>();//408,500 
    static final Integer MAX_CONNECTION_TIMEOUT = 120000;//Set Max
    X_APIData apiData;
    Integer tryCount;
    List<X_ApiCalloutLogUtil> logUtils;
    
    //CONSTRUCTORs
    public X_Service(X_APIData apiData){
        this.apiData = apiData;
        this.tryCount = 1;
        this.logUtils = new List<X_ApiCalloutLogUtil>();
    }
    
    public SyncResult sync(){
        if(this.apiData == NULL || String.isBlank(this.apiData.recordId) || String.isBlank(this.apiData.apiMethodName)){
           return new SyncResult();
        }
        
        SyncResult sr = syncProcess();
        X_ApiCalloutLogUtil.finalizeLogs(logUtils,this.apiData.xsdId);
        return sr;
    }
    
    @InvocableMethod(label='Send/get Data to Xpedeon new' )
    public static void handleAPI(List<X_APIData> apiData){
        List<Id> xsdIds = new List<Id>();
        for(X_APIData apiDataSingle : apiData){
            xsdIds.add(apiDataSingle.recordId);
        }
        if(!xsdIds.isEmpty()) Database.executeBatch(new X_SyncBatch(xsdIds),1);
    }
    
    public SyncResult syncProcess(){//returns if retry required or not
        
        SobjectType sObjType = Id.valueOf(apiData.recordId).getSObjectType();
        HTTPResponse response;
        
        if(sObjType == Applicant_Details__c.sObjectType && apiData.apiMethodName == 'POST' ){
            response = customerPostAPI(apiData.recordId);
        }else if(sObjType == Demand__c.sObjectType && apiData.apiMethodName == 'POST'){
            response =invoicePostAPI(apiData.recordId);
        }else if(sObjType == Unit__c.sObjectType && apiData.apiMethodName == 'POST'){
            response = unitPostAPI(apiData.recordId);
        }/*else if(sObjType == Bank_Receipt__c.sObjectType && apiData.apiMethodName == 'POST'){
            response = UnAllocatedRecPostAPI(apiData.recordId);
        }else if(sObjType == Receipt__c.sObjectType && apiData.apiMethodName == 'POST'){
            response = AllocatedRecPostAPI(apiData.recordId);
        }*/else if(sObjType == Tower__c.sObjectType && apiData.apiMethodName == 'POST'){
            response = PhasePostAPI(apiData.recordId);
        }
        
        return new SyncResult(response,shallRetry(response));
    }
    
    //HELPERs
    Boolean shallRetry(HttpResponse hRes){
    	return hRes != NULL && (hRes.getStatusCode() < 200 || hRes.getStatusCode() > 299) && RETRY_RESPONSE_CODES.contains(hRes.getStatusCode()) && tryCount <= RETRY_LIMIT;     
    }
    
    //WORKERs
    public HTTPResponse customerPostAPI(String applicantId){
        X_ApiCalloutLogUtil logUtil = X_ApiCalloutLogUtil.initializeLog(applicantId);
        HTTPResponse postAPIResponce;
        try{
            HttpRequest hReq = X_CustomerPostRequestHandler.createHttpRequest();
            logUtil.logIt(hReq,X_CustomerPostRequestHandler.getRequestHeaders());
            hReq = X_CustomerPostRequestHandler.createHttpRequestBody(hReq,applicantId);//add try catch inside this
            logUtil.logIt(hReq);
            hReq.setTimeout(MAX_CONNECTION_TIMEOUT);
            postAPIResponce = new HTTP().send(hReq);
            logUtil.logIt(postAPIResponce);
            
            //	X_CustomerPostResponseHandler.handlePostResponse(postAPIresponce);
        }catch(Exception ex){
            logUtil.logIt(ex);
        }
        
        finally{
            logUtils.add(logUtil);
            //logUtil.finalizeLog();
        }
        return postAPIResponce;
    }
    
    /* DO NOT DELETE - COMMENTED ONLY FOR PROD DEPLOYMENT
    public HTTPResponse UnAllocatedRecPostAPI(String prId){
        X_ApiCalloutLogUtil logUtil = X_ApiCalloutLogUtil.initializeLog(prId);
        HTTPResponse postAPIResponse;
        try{
            HttpRequest hReq = X_UnallocReceiptPostRequestHandler_V2.createHttpRequest();
            logUtil.logIt(hReq,X_UnallocReceiptPostRequestHandler_V2.getRequestHeaders());
            
            hReq = X_UnallocReceiptPostRequestHandler_V2.createHttpRequestBody(hReq,prId);
            
            logUtil.logIt(hReq);
            hReq.setTimeout(MAX_CONNECTION_TIMEOUT);
            postAPIResponse = new HTTP().send(hReq);
            logUtil.logIt(postAPIResponse);
            
            
        }catch(Exception ex){
            logUtil.logIt(ex);
        }
        
        finally{
            logUtils.add(logUtil);
        }
        return postAPIResponse;
        
    }
    
    public HttpResponse AllocatedRecPostAPI(String recId){
        X_ApiCalloutLogUtil logUtil = X_ApiCalloutLogUtil.initializeLog(recId);
        HTTPResponse postAPIResponse;
        
        try{
            HttpRequest hReq = X_AllocatReceiptPostRequestHandler.createHttpRequest();
            logUtil.logIt(hReq,X_AllocatReceiptPostRequestHandler.getRequestHeaders());
            
            hReq = X_AllocatReceiptPostRequestHandler.createHttpRequestBody(hReq,recId);
            logUtil.logIt(hReq);
            hReq.setTimeout(MAX_CONNECTION_TIMEOUT);
            postAPIResponse = new HTTP().send(hReq);
            logUtil.logIt(postAPIResponse);
        }catch(Exception ex){
            logUtil.logIt(ex);
        }
        
        finally{
            logUtils.add(logUtil);
        }
        return postAPIResponse;
    }
	DO NOT DELETE - COMMENTED ONLY FOR PROD DEPLOYMENT
    */
    public HTTPResponse unitPostAPI(String unitId){
        X_ApiCalloutLogUtil logUtil = X_ApiCalloutLogUtil.initializeLog(unitId);
        HTTPResponse postAPIResponse;
        try{
            HttpRequest hReq = X_UnitPostRequestHandler.createHttpRequest();
            logUtil.logIt(hReq,X_UnitPostRequestHandler.getRequestHeaders());
            hReq = X_UnitPostRequestHandler.createHttpRequestBody(hReq,unitId);
            logUtil.logIt(hReq);
            hReq.setTimeout(MAX_CONNECTION_TIMEOUT);
            postAPIResponse = new HTTP().send(hReq);
            system.debug('Unit RES: '+postAPIresponse.getbody());
            
            logUtil.logIt(postAPIResponse);
            
            
        }catch(Exception ex){
            logUtil.logIt(ex);
        }
        
        finally{
            logUtils.add(logUtil);
        }
        return postAPIresponse;
    }
    
    public HttpResponse invoicePostAPI(String demandId){
        X_ApiCalloutLogUtil logUtil = X_ApiCalloutLogUtil.initializeLog(demandID);
        HTTPResponse postAPIResponse;
        try{
            HttpRequest hReq = X_invoicePostRequestHandler.createHttpRequest();
            logUtil.logIt(hReq,X_invoicePostRequestHandler.getRequestHeaders());
            
            hReq = X_invoicePostRequestHandler.createHttpRequestBody(hReq,demandID);
            logUtil.logIt(hReq);
            hReq.setTimeout(MAX_CONNECTION_TIMEOUT);
            postAPIResponse = new HTTP().send(hReq);
            logUtil.logIt(postAPIResponse);
        }catch(Exception ex){
            logUtil.logIt(ex);
        }
        
        finally{
            logUtils.add(logUtil);
        }
        return postAPIResponse;
    }
    
    public HTTPResponse PhasePostAPI(String phaseId){
        X_ApiCalloutLogUtil logUtil = X_ApiCalloutLogUtil.initializeLog(phaseId);
        HTTPResponse postAPIResponce;
        try{
            HttpRequest hReq = X_PhasePostRequestHandler.createHttpRequest();
            logUtil.logIt(hReq,X_PhasePostRequestHandler.getRequestHeaders());
            
            hReq = X_PhasePostRequestHandler.createHttpRequestBody(hReq,phaseId);
            logUtil.logIt(hReq);
            hReq.setTimeout(MAX_CONNECTION_TIMEOUT);
            postAPIResponce = new HTTP().send(hReq);
            logUtil.logIt(postAPIResponce);
            
            
        }catch(Exception ex){
            logUtil.logIt(ex);
        }
        
        finally{
            logUtils.add(logUtil);
        }
        return postAPIResponce;
    }
    
    //WRAPPERs
    public class X_APIData{
        @InvocableVariable(required=true)
        public string recordId;
        
        @InvocableVariable(required=true)
        public String apiMethodName;
        public Id xsdId;
        
        public X_APIData(string recordId,String apiMethodName,Id xsdId){
            this.recordId = recordId;
            this.apiMethodName = apiMethodName;
            this.xsdId = xsdId;
        }
        
        public X_APIData(string recordId,String apiMethodName){
            this.recordId = recordId;
            this.apiMethodName = apiMethodName;
        }
        
        public X_APIData(){}
    }
    
    public class SyncResult{
        public Integer httpResponseCode;
        public String httpResponseBody;
        public Boolean success;
        public Boolean shallretry;
        
        @TestVisible SyncResult(){
            this.httpResponseCode = 0;
            this.httpResponseBody = '';
            this.success = false;
            this.shallretry = false;
        }
        @TestVisible SyncResult(HttpResponse hRes,Boolean shallretry){
            this.httpResponseCode = hRes == NULL ? 0 : hRes.getStatusCode();
            this.httpResponseBody = String.isNotBlank(hRes?.getBody()) ? hRes.getBody() : '';
            this.success = this.httpResponseCode > 199 && this.httpResponseCode < 300;
            this.shallretry = shallretry;
        }
    }
    
}