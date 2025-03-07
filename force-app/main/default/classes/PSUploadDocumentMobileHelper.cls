global class PSUploadDocumentMobileHelper {
    global Static String UploadDocumentMobile(RestRequest request) {
        String responce = '';
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                String jsonString = request.requestBody.toString();
                try {
                    PSUploadDocumentMobilePOJO uploadDocumentPOJO = (PSUploadDocumentMobilePOJO) JSON.deserialize(jsonString, PSUploadDocumentMobilePOJO.class);
                    if(!String.isBlank(uploadDocumentPOJO.base64Data) &&
                       !String.isBlank(uploadDocumentPOJO.parentId)) {
                        Blob imageBlob = EncodingUtil.base64Decode(uploadDocumentPOJO.base64Data);
                        ContentVersion cv = new ContentVersion();
                        cv.Origin = 'H';
                        cv.VersionData = imageBlob;
                        cv.PathOnClient = uploadDocumentPOJO.fileName;
                        Id parentValue = Id.valueOf(uploadDocumentPOJO.parentId);
                        String parentObject = parentValue.getsobjecttype().getDescribe().getName(); 
                        if(parentObject.equals('Payment_Request__c')) {//Payment_Request__c
                            cv.title = uploadDocumentPOJO.isthirdpartydoc == 'True' ? 'Third Party Form' : 'POP';
                        } else {
                            cv.title = uploadDocumentPOJO.fileName;
                        }
                        Database.SaveResult saveContentVersion = Database.insert(cv);
                        if(saveContentVersion.isSuccess()) {
                            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                                               FROM ContentVersion WHERE Id = :saveContentVersion.getId() LIMIT 1];
                            
                            ContentDocumentLink contentlink = new ContentDocumentLink();
                            contentlink.LinkedEntityId = uploadDocumentPOJO.parentId;
                            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
                            contentlink.ShareType = 'V';
                            Database.SaveResult saveContent = Database.insert(contentlink);
                            if(saveContent.isSuccess()) {
                                gen.writeStartObject();     
                                gen.writeBooleanField('success', true);
                                gen.writeNumberField('statusCode', 200);
                                gen.writeStringField('status', 'Success');
                                gen.writeStringField('Message', 'Operation Successfull');
                                gen.writeEndObject();
                                responce = gen.getAsString();
                                Mobile_App_Log__c logError = new Mobile_App_Log__c();
                                logError.Response_Body__c = responce;
                                logError.Class_Name__c = 'PSUploadDocumentMobileHelper';
                                logError.API_Name__c = '/services/apexrest/uploadDocument_Dummy/';
                                logError.Status__c = '200';
                               // logError.Request_Body__c = JSON.serialize(jsonString);
                                insert logError;
                            } else {
                                gen.writeStartObject();  gen.writeBooleanField('success', false);gen.writeNumberField('statusCode', 400);gen.writeStringField('status', 'Error'); gen.writeStringField('Message', 'Error==>'+saveContent.getErrors());gen.writeEndObject(); responce = gen.getAsString();Mobile_App_Log__c logError = new Mobile_App_Log__c();logError.Response_Body__c = responce; logError.Class_Name__c = 'PSUploadDocumentMobileHelper';logError.API_Name__c = '/services/apexrest/uploadDocument_Dummy/';logError.Status__c = '400';logError.Request_Body__c = JSON.serialize(jsonString);insert logError;
                            }
                        } else {
                            gen.writeStartObject();gen.writeBooleanField('success', false);gen.writeNumberField('statusCode', 400);gen.writeStringField('status', 'Error');gen.writeStringField('Message', 'Error==>'+saveContentVersion.getErrors());
                            gen.writeEndObject();responce = gen.getAsString();Mobile_App_Log__c logError = new Mobile_App_Log__c();logError.Response_Body__c = responce;logError.Class_Name__c = 'PSUploadDocumentMobileHelper';logError.API_Name__c = '/services/apexrest/uploadDocument_Dummy/';
                            logError.Status__c = '400';logError.Request_Body__c = JSON.serialize(jsonString);insert logError;
                        }
                    }
                } catch(Exception e) {
                    gen.writeStartObject();     
                    gen.writeBooleanField('success', false);
                    gen.writeNumberField('statusCode', 400);
                    gen.writeStringField('status', 'Error');
                    gen.writeStringField('Message', String.valueOf(e.getMessage()));
                    gen.writeFieldName('data');
                    gen.writeEndObject();
                    responce = gen.getAsString();
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                    Mobile_App_Log__c logError = new Mobile_App_Log__c();
                    logError.Response_Body__c = responce;
                    logError.Class_Name__c = 'PSUploadDocumentMobileHelper';
                    logError.API_Name__c = '/services/apexrest/uploadDocument_Dummy/';
                    logError.Status__c = '400';
                    logError.Request_Body__c = JSON.serialize(jsonString);
                    insert logError;
                }
            }
        return responce;
    }
}