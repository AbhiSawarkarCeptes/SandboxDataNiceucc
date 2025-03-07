global class QMSServiceUtility {
    
     Public static QMSResponseWrapper.getUnitHttpResponseWrapper prepareResponse(List<QMSResponseWrapper.GetUnitInfoWrapper> rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        QMSResponseWrapper.getUnitHttpResponseWrapper resWrap = new QMSResponseWrapper.getUnitHttpResponseWrapper();
        resWrap.data = rBody; 
         resWrap.Message = rMessage;
         resWrap.status = rStatus;
         resWrap.statusCode = rStatusCode;
         resWrap.success = rSuccess;
        return resWrap;
    }
    
     Public static QMSResponseWrapper.postCaseVisitHttpResponseWrapper prepareResponse(QMSResponseWrapper.postVisitInfoWrapper rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        QMSResponseWrapper.postCaseVisitHttpResponseWrapper resWrap = new QMSResponseWrapper.postCaseVisitHttpResponseWrapper();
        resWrap.data = rBody; 
         resWrap.Message = rMessage;
         resWrap.status = rStatus;
         resWrap.statusCode = rStatusCode; 
         resWrap.success = rSuccess;
        return resWrap;
    }
    Public static QMSResponseWrapper.postCaseTransferResponseWrapper prepareResponse(string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        QMSResponseWrapper.postCaseTransferResponseWrapper resWrap = new QMSResponseWrapper.postCaseTransferResponseWrapper();
        //resWrap.data = rBody; 
         resWrap.Message = rMessage;
         resWrap.status = rStatus;
         resWrap.statusCode = rStatusCode;
         resWrap.success = rSuccess;
        return resWrap;
    }

    Public static String getRecordType(String requestType){
        
        	List<QMS_Case_RequestType__mdt> reqTypes = [SELECT 	Case_RecordTypeName__c 
                                                        FROM QMS_Case_RequestType__mdt 
                                                        WHERE RequestType__c = : requestType LIMIT 1];
        if(reqTypes.size()>0)
        return reqTypes[0].Case_RecordTypeName__c;
        else
            return 'CRM';
    }
   
}