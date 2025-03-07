public class NocLetterForAccountController {
    
    public Account acct{get;set;}
    private final String versionData;
    public ContentDocumentLink content{get;set;}
    public ContentVersion att{get;set;}
    public NocLetterForAccountController(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        //SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = '<Opportunity or other object id here>'
        content = [SELECT Id, LinkedEntityId, ContentDocumentId,Visibility, IsDeleted, ShareType,ContentDocument.Title,ContentDocument.createdDate, ContentDocument.FileType FROM
                   ContentDocumentLink WHERE LinkedEntityId =: acct.Id AND ContentDocument.FileType = 'PDF' AND ContentDocument.Title LIKE '%NOC%' limit 1];
        /*att =   [SELECT Id  FROM ContentVersion  WHERE ContentDocumentId ='069Vc000001MOHeIAO']; */
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:content.ContentDocumentId ];       
        versionData = EncodingUtil.base64Encode(cv.VersionData);
        
    }
    public String getVersionData() {
        return versionData;
    }

}