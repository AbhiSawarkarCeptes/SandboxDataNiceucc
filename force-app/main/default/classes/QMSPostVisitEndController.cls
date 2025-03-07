@RestResource(urlMapping = '/PostVisitEndInfo/*')
global class QMSPostVisitEndController {
      @HttpPost
    global static  void  doPost(){
        String data = RestContext.request.requestBody.toString();
        system.debug('Data:'+data);
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        QMSRequestWrapper.PostVisitEndInfoWrapper visitEnd;
        QMSApiCalloutLogUtil logUtil;


        try{
             visitEnd =  (QMSRequestWrapper.PostVisitEndInfoWrapper) JSON.deserialize(data, QMSRequestWrapper.PostVisitEndInfoWrapper.class);
        }catch(Exception e){
                        logUtil = QMSApiCalloutLogUtil.initializeLog('Improper request');
                        logUtil.logIt(data, 'Post', req.requestURI);
                        logUtil.logIt(e);
                        res.responseBody =  BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse('Please send proper request. '+e.getMessage(),'Failure',400,false))) ;
                        res.statusCode = 400;
                        logApiResponse(logUtil,'Improper request body', 400, 'Failure');
                        return;
                
        }
        logUtil = QMSApiCalloutLogUtil.initializeLog(visitEnd.caseId);     
        logUtil.logIt(data, 'Post', req.requestURI);
        String msg = validateRequestBody(visitEnd);
        if(msg != ''){
            res.responseBody = BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse(msg,'Failure',400,false))) ;
            res.statusCode = 400;
            logApiResponse(logUtil,msg, 400, 'Failure');
            return;

        }
            
            
            try{
             
                case c = [SELECT Id, status FROM Case 
                    WHERE Id = :visitEnd.CaseId];
                 if(c.Status == 'Closed'){
                    res.responseBody = BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse('Visit Already Ended','Success',200,true))) ;
                    res.statusCode = 200;
                    logApiResponse(logUtil,'Visit Aleady Ended', 200, 'Success');
                 }else
                 {
                     c.Serving_Time__c = visitEnd.servingTime;
                    c.RM_Remarks__c = visitEnd.description;
                    c.Status = 'Closed';
                    update c;   
                    res.responseBody =  BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse('Visit Ended Successfully.','Success',200,true))) ;
                    res.statusCode = 200;
                    logApiResponse(logUtil,'Visit Ended Successfully', 200, 'Success');
                       
                 }      
              }catch(Exception e){
                        logUtil.logIt(e);
                        res.responseBody =   BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse('Visit could not be ended. '+e.getMessage(),'Failure',400,false))) ;
                        res.statusCode = 400;
                        //logUtil.logIt('Visit could not be ended. ', 400, 'Success');
                        logApiResponse(logUtil,'Visit could not be ended.Something went wrong', 400, 'Failure');
                                                
              }

       
        
    }
    
    Public Static void logApiResponse(QMSApiCalloutLogUtil logUtil, String ResponseBody, Integer StatusCode, String Status){
        logUtil.logIt(ResponseBody, StatusCode,Status);
                        QMSApiCalloutLogUtil.finalizeLogs(logUtil);
                        
    }
    
    Public Static String validateRequestBody(QMSRequestWrapper.PostVisitEndInfoWrapper visitEnd){
        String errorMsg=''; 
        If(visitEnd.caseId == null || !String.valueOf(visitEnd.caseId).startsWith('500') 
           || !(String.valueOf(visitEnd.caseId).length() == 15 || String.valueOf(visitEnd.caseId).length() == 18)){
               errorMsg+='Improper CaseId.';
                   }
          If(visitEnd.servingTime == null ){
               errorMsg+='servingTime Missing.';
                   }
        
         return errorMsg;
       
    }

}