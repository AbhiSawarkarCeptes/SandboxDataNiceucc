@RestResource(urlMapping = '/uploadDocument')
global class Mobile_uploadDocument{
    
    @HttpPost
    global static void uploadDocument(String base64Data, String parentId, String fileName,boolean isthirdpartydoc) {
        RestResponse res = RestContext.response;
        String responseString = '';
        String errorMessage = '';
        try{
            String[] fileType;
            String fileData;
            /* if(base64Data.contains(',')){
filetype = base64Data.split(',');
if(filetype[0].contains('pdf')){
filename = fileName+'.pdf';              
}
else{
filename = fileName+'.jpg';   
}
fileData = filetype[1];
} else {

if(fileName.contains('pdf')){
filename = fileName+'.pdf';
}else{
filename = fileName+'.jpeg';
}

fileData = base64Data;
}*/
            
            
            /*if(fileName.contains('pdf')){
                filename = fileName+'.pdf';
            }else{
                filename = fileName+'.jpeg';
            }*/
            
            fileData = base64Data;
            Blob imageBlob = EncodingUtil.base64Decode(fileData);
            /*ContentVersion cv;
if(isthirdpartydoc){
cv = new ContentVersion(
Title='Third Party Form', 
PathOnClient = filename,
VersionData = imageBlob, 
origin = 'H'
);  
} else {
cv = new ContentVersion(
Title='POP', 
PathOnClient = filename,
VersionData = imageBlob, 
origin = 'H'
);
}

insert cv;*/
            
            ContentVersion cv = new ContentVersion();
            cv.Origin = 'H';
            cv.VersionData = imageBlob;
            cv.PathOnClient = fileName;
            
            Id parentValue = Id.valueOf(parentId);
            String parentObject = parentValue.getsobjecttype().getDescribe().getName(); 
            
            if( parentObject.equals('Payment_Request__c')) {
                cv.title = isthirdpartydoc ? 'Third Party Form' : 'POP';
            }
            else {
                cv.title = fileName;
            }
            
            insert cv;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = parentId;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            responseString = (Mobile_ApiUtility.prepareResponse(null,'Operation Successfull','Success',200,true)).toString().replace('"','');
            res.responseBody =  Blob.valueOf(JSON.serialize(Mobile_ApiUtility.prepareResponse(null,'Operation Successfull','Success',200,true)));
            res.statusCode = 200;
        }
        catch(Exception ex){
            errorMessage = ex.getMessage();
            res.responseBody = BLOB.valueOf(JSON.serialize(Mobile_ApiUtility.prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
        }
        Mobile_ApiUtility.createMobileAPILogs('uploadDocument','Mobile_uploadDocument',null,responseString,errorMessage,res.statusCode);
    }
}