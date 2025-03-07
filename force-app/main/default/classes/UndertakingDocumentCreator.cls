/*********************************************************************
 * Class Name  :   UndertakingDocumentCreator
 * Description :   Helper Class of Flow Send HOP And UL for Docusign (Flow)
 * Created Date:   08/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 08/02/2024
 *********************************************************************/
public class UndertakingDocumentCreator {
    @InvocableMethod
    public static void undertakingAttacher(List<Id> bookIds){
        Id bookId = bookIds[0];

        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =:bookId 
                                            AND ContentDocument.title = 'UndertakingDocuments.pdf'];
                                                
        if (docList.size() < 1) {
            PageReference PDf =  Page.UndertakingDocuments;
            PDf.getParameters().put('id',bookId);
            PDf.setRedirect(true);
            Attachment attach = new Attachment();

            Blob b ;
            if(Test.IsRunningTest())
                b= Blob.valueOf('This is Test');    
            else
                b= PDf.getContentAsPDF(); 

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = 'UndertakingDocuments.pdf';
            contentVersion.Title = 'UndertakingDocuments.pdf';
            contentVersion.VersionData = b;
            insert contentVersion;

            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = conDoc;
            contentDocumentLink.LinkedEntityId = bookId;
            contentDocumentLink.ShareType = 'I';
            contentDocumentLink.Visibility = 'InternalUsers';
            insert contentDocumentLink;
        }
    }

    public static List<ContentDocumentLink> brokerRegistrationAttacher2(List<Id> bookIds){
        Id bookId = bookIds[0];
        
        PageReference PDf =  Page.UndertakingDocuments;
        PDf.getParameters().put('id',bookId);
        PDf.setRedirect(true);
        Attachment attach = new Attachment();

        Blob b ;
        if(Test.IsRunningTest())
            b= Blob.valueOf('This is Test');    
        else
            b= PDf.getContentAsPDF(); 

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
        contentVersion.PathOnClient = 'UndertakingDocuments.pdf';
        contentVersion.Title = 'UndertakingDocuments.pdf';
        contentVersion.VersionData = b;
        insert contentVersion;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conDoc;
        contentDocumentLink.LinkedEntityId = bookId;
        contentDocumentLink.ShareType = 'I';
        contentDocumentLink.Visibility = 'InternalUsers';
        insert contentDocumentLink;

        return [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =:bookId 
                                            AND ContentDocument.title = 'UndertakingDocuments.pdf'];
    }
}