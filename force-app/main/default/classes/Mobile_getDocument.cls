@RestResource(urlMapping = '/getDocument')
global class Mobile_getDocument {
    @HttpPost
    global static void getDocument(String documentId) { 
        ResponseBodyWrapper documentWrapper = new ResponseBodyWrapper();
        RestResponse res = RestContext.response;
        try{
            List<ContentVersion> contentVersionList = [SELECT id, ContentDocument.Title, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.FileType, ContentDocument.ContentSize, VersionData, Title, TextPreview
                                                        FROM ContentVersion WHERE ContentDocumentId = :documentId LIMIt 1];
            if(contentVersionList.size() > 0){
                documentWrapper.fileName = contentVersionList[0].ContentDocument.Title;
                documentWrapper.type = contentVersionList[0].ContentDocument.FileType;
                documentWrapper.fileData = Blob.valueOf(EncodingUtil.base64Encode(contentVersionList[0].VersionData));
                res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(documentWrapper,'Operation Successfull','Success',200,true)));
                res.statusCode = 200;
            }
            else{
                res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'No data found','No data found',400,false)));
                res.statusCode = 400;
            }
        }catch(Exception ex){
            Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
            logError.class__c = 'Mobile_getStatementOfAccount';
            insert logError;
            res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,ex.getMessage(),'Error',400,false)));
            res.statusCode = 400;
        }
    }
    
    public static HttpResponseWrapper prepareResponse(ResponseBodyWrapper rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.data = rBody;
        resWrap.Message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        return resWrap;
    }
    
    public class ResponseBodyWrapper{
        public String fileName;
        public Blob fileData;
        public String type;
    }
    
    global class HttpResponseWrapper{
        public String status;
        public Integer statusCode;
        public Boolean success;
        public String Message;
        public ResponseBodyWrapper data;
    }
}