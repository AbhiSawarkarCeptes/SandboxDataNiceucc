global class X_ServiceController implements Queueable,Database.AllowsCallouts {
    static final Integer RETRY_LIMIT = 1;//5 
    static final Set<Integer> RETRY_RESPONSE_CODES = new Set<Integer>();//408,500 
    static final Integer MAX_CONNECTION_TIMEOUT = 120000;//Set Max
    List<X_APIData> apiData;
    Integer tryCount;
    List<X_ApiCalloutLogUtil> logUtils;
    
    //INITIALISATION JOB
    public X_ServiceController(List<X_APIData> apiData){
        this.apiData = apiData;
        this.tryCount = 0;
        this.logUtils = new List<X_ApiCalloutLogUtil>();
    }
    
    //PROPAGATION JOB
    X_ServiceController(X_ServiceController that){
        this.apiData = that.apiData;
        this.tryCount = that.tryCount+1;
        this.logUtils = that.logutils;
    }
    
    public void execute(QueueableContext qc){
        if(this.syncController())
            System.enqueueJob(new X_ServiceController(this));
    }
    
    public Boolean syncController(){
        if(
            (this.apiData == NULL || apiData.isEmpty() || String.isBlank(this.apiData[0].recordId) || String.isBlank(this.apiData[0].apiMethodName))
            || this.tryCount >= RETRY_LIMIT
            || !this.syncProcess()
        ){
            X_ApiCalloutLogUtil.finalizeLogs(logUtils);
            return false;
        }else{
            return true;
        }
    }
    
    public Boolean syncProcess(){//returns if retry required or not
        
        sobjectType sObjectName = Id.valueOf(apiData[0].recordId).getSObjectType();
        String ObjectName = String.valueOf(sObjectName);
        HTTPResponse response;
        if(sObjectName == Applicant_Details__c.sObjectType && apiData[0].apiMethodName == 'POST' ){
            response = customerPostAPI(apiData[0].recordId);
        }else if(sObjectName == Applicant_Details__c.sObjectType && apiData[0].apiMethodName == 'PUT'){
            //response = customerPutAPI(apiData[0].recordId); 
        }else if(sObjectName == Demand__c.sObjectType && apiData[0].apiMethodName == 'POST'){
            response =invoicePostAPI(apiData[0].recordId);
        }//else if((sObjectName == Unit__c.sObjectType || sObjectName == Project__c.sObjectType|| sObjectName == Cluster__c.sObjectType ||  sObjectName == Tower__c.sObjectType) 
        else if(sObjectName == Unit__c.sObjectType && apiData[0].apiMethodName == 'POST'){
            response = unitPostAPI(apiData[0].recordId);
        }else if(sObjectName == Payment_Request__c.sObjectType && apiData[0].apiMethodName == 'POST'){
            response = UnAllocatedRecPostAPI(apiData[0].recordId);
          
        }else if(sObjectName == Receipt__c.sObjectType && apiData[0].apiMethodName == 'POST'){
          
          response = AllocatedRecPostAPI(apiData[0].recordId);
            
        }
        else if(sObjectName == Tower__c.sObjectType && apiData[0].apiMethodName == 'POST'){
            response = PhasePostAPI(apiData[0].recordId);
        }
        
        return (response!= NULL && RETRY_RESPONSE_CODES.contains(response.getStatusCode()));
    }
    
    @InvocableMethod(label='Send/get Data to Xpedeon' )
    public static void handleAPI(List<X_APIData> apiData){
        X_ServiceController x_SC = new X_ServiceController(apiData); 
        while(x_SC.syncController()){
            x_SC = new X_ServiceController(x_SC);
        }
    }
    
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
    /*
    public HTTPResponse customerPutAPI(String applicantId){
        X_ApiCalloutLogUtil logUtil = X_ApiCalloutLogUtil.initializeLog(applicantId);
        HTTPResponse putAPIResponce;
        try{
            HttpRequest hReq = X_CustomerPutRequestHandler.createHttpRequest();
            logUtil.logIt(hReq,X_CustomerPutRequestHandler.getRequestHeaders());
            
            hReq = X_CustomerPutRequestHandler.createHttpRequestBody(hReq,applicantId);
            //logUtil.logIt(hReq.getBody());            
            logUtil.logIt(hReq);
            hReq.setTimeout(MAX_CONNECTION_TIMEOUT);
            putAPIResponce = new HTTP().send(hReq);
            logUtil.logIt(putAPIResponce);
            
            // X_CustomerPostResponseHandler.handlePostResponse(postAPIresponce);
        }catch(Exception ex){
            logUtil.logIt(ex);
        }
        
        finally{
            logUtils.add(logUtil);
            //logUtil.finalizeLog();
        }
        
        return putAPIResponce;
    }
    */
    public HTTPResponse UnAllocatedRecPostAPI(String prId){
        X_ApiCalloutLogUtil logUtil = X_ApiCalloutLogUtil.initializeLog(prId);
        HTTPResponse postAPIResponse;
        try{
            HttpRequest hReq = X_UnAllocatReceiptPostRequestHandler.createHttpRequest();
            logUtil.logIt(hReq,X_UnAllocatReceiptPostRequestHandler.getRequestHeaders());
            
            hReq = X_UnAllocatReceiptPostRequestHandler.createHttpRequestBody(hReq,prId);
            //logUtil.logIt(hReq.getBody());            
            logUtil.logIt(hReq);
            hReq.setTimeout(MAX_CONNECTION_TIMEOUT);
            postAPIResponse = new HTTP().send(hReq);
            logUtil.logIt(postAPIResponse);
            
            
        }catch(Exception ex){
            logUtil.logIt(ex);
        }
        
        finally{
            logUtils.add(logUtil);
            //logUtil.finalizeLog();
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
   
    
/* Commenting for now as discussed not required  
 *   public HTTPResponse BlockPostAPI(String projId){
        X_ApiCalloutLogUtil logUtil = X_ApiCalloutLogUtil.initializeLog(projId);
        HTTPResponse postAPIResponce;
        try{
            HttpRequest hReq = X_BlockPostRequestHandler.createHttpRequest();
            logUtil.logIt(hReq,X_BlockPostRequestHandler.getRequestHeaders());
            
            hReq = X_BlockPostRequestHandler.createHttpRequestBody(hReq,projId);
            //logUtil.logIt(hReq.getBody());
            logUtil.logIt(hReq);
            hReq.setTimeout(MAX_CONNECTION_TIMEOUT);
            postAPIResponce = new HTTP().send(hReq);
            logUtil.logIt(postAPIResponce);
            
            
        }catch(Exception ex){
            logUtil.logIt(ex);
        }
        
        finally{
            logUtils.add(logUtil);
            //logUtil.finalizeLog();
        }
        return postAPIResponce;
    }
   */
    
    public class X_APIData{
        @InvocableVariable(required=true)
        public string recordId;
        
        @InvocableVariable(required=true)
        public String apiMethodName;
        
        public X_APIData(string recordId,String apiMethodName){
            this.recordId = recordId;
            this.apiMethodName = apiMethodName;
        }
        public X_APIData(){}
    }
    
    public class SyncResponse{
        Boolean retry;
        Integer responseCode;
        Boolean success;
    }
    
}