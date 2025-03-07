@RestResource(urlMapping = '/PostServingInfo/*')
global class QMSPostTransferController {
    @HttpPost
    global static void doPost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        QMSApiCalloutLogUtil logUtil;
        QMSRequestWrapper.postTokenCalledInfoWrapper caseTransferData;
        String data = RestContext.request.requestBody.toString();
        String newOwner;
        String oldOwnerId;
        
        system.debug('DAta:'+data);
        try{
            caseTransferData =  (QMSRequestWrapper.postTokenCalledInfoWrapper) JSON.deserialize(data, QMSRequestWrapper.postTokenCalledInfoWrapper.class);
        }catch(Exception e){
            logUtil = QMSApiCalloutLogUtil.initializeLog('Improper request');
            logUtil.logIt(data, 'Post', req.requestURI);
            logUtil.logIt(e);
            res.responseBody =   BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse('Please send proper request. '+e.getMessage(),'Failure',400,false))) ;
            res.statusCode = 400;
            logApiResponse(logUtil,'Improper request body', 400, 'Failure');
            return;
            
        }
        logUtil = QMSApiCalloutLogUtil.initializeLog(caseTransferData.caseId);     
        logUtil.logIt(data, 'Post', req.requestURI);
        String msg = validateRequestBody(caseTransferData);
        if(msg != ''){
            res.responseBody =  BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse(msg,'Failure',400,false))) ; 
            res.statusCode = 400;
            logApiResponse(logUtil,msg, 400, 'Failure');
            return;
            
        }
        
        try{   
            Case c = [SELECT ID,CreatedById ,ownerID,Booking__r.Primary_Applicant_Name__c FROM Case WHERE ID =: caseTransferData.caseId];
            oldOwnerId = c.OwnerId;
            // String[] queueCollection = new String[] {'CRM', 'Collection'};
            List<String> queueCollection = new List<String>();
            if (Label.QMSQueueCollection != null) {
                queueCollection = Label.QMSQueueCollection.split(',');
            }
            system.debug('queueCollection:'+queueCollection);
             system.debug('caseTransferData.emailId:'+caseTransferData.emailId);
            if (!queueCollection.contains(caseTransferData.emailId)) {
                User u = [SELECT ID,EMAIL,Name,Phone FROM USER WHERE EMAIL =: caseTransferData.emailId LIMIT 1];
                c.SuppliedEmail = caseTransferData.emailId;
                c.OwnerId = u.id;
                newOwner = u.Name;
            }else{
                Map<String, String> queueMap = new Map<String, String>();
                queueMap.put('CRM','Collection and CRM Queue');
                queueMap.put('Collection','Collection Main Queue');
                
                Group queue = [SELECT ID 
                               FROM GROUP WHERE TYPE = 'Queue' 
                               AND Name =:queueMap.get(caseTransferData.emailId) 
                               LIMIT 1];
                system.debug('queue:'+queue);
                c.OwnerId = queue.id;
                newOwner = caseTransferData.emailId;
            }
            If(c.CreatedById == oldOwnerId)
            {
                c.Token_called_by__c = newOwner;
                c.Token_called_time__c = DATETIME.now();
            }
            update c;
            res.responseBody = BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse('Case Transferred Successfully','Success',200,true))) ;
            res.statusCode = 200;
            logApiResponse(logUtil,'Case Transferred Successfully', 200, 'Success');
        }catch(Exception e){
            logUtil.logIt(e);
            res.responseBody = BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse('Case Transfer could not be done. No user with this email or no Queue available ','Failure',400,False))) ;
            res.statusCode = 400;
            logApiResponse(logUtil,'Case Transfered could not be done.No user with this email or no Queue available specified in Label.QMSQueueName'+e.getMessage(), 400, 'Failure'); 
        }  
    }  
    
    
    
    Public Static void logApiResponse(QMSApiCalloutLogUtil logUtil, String ResponseBody, Integer StatusCode, String Status){
        logUtil.logIt(ResponseBody, StatusCode,Status);
        QMSApiCalloutLogUtil.finalizeLogs(logUtil);
        
    }
    
    
    
    Public Static String validateRequestBody(   QMSRequestWrapper.postTokenCalledInfoWrapper caseTransferData){
        String errorMsg=''; 
        If(caseTransferData.caseId == null || !String.valueOf(caseTransferData.caseId).startsWith('500') 
           || !(String.valueOf(caseTransferData.caseId).length() == 15 || String.valueOf(caseTransferData.caseId).length() == 18)){
               errorMsg+='Improper CaseId.';
           }
        
        If(String.IsBlank(caseTransferData.emailId))
            errorMsg+='Email missing. ';
        
        return errorMsg;
        
    }
}