public Without sharing class VatUploadController {
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
            System.debug('upload method is called');
            ContentVersion cv = createContentVersion(base64, filename);
            ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
            if (cv == null || cdl == null) { return null; }
            return cdl.Id;
    }
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        insert cv;
        return cv;
    }
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        insert cdl;
        return cdl;
    }
}