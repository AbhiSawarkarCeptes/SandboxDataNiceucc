/*********************************************************************
 * Class Name  :   BrokerRegistrationDocumentCreator
 * Description :   Helper Class of Flow Send Broker Registration for Docusign (Flow)
 * Created Date:   06/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 06/02/2024
 *********************************************************************/
public class BrokerRegistrationDocumentCreator {
    @InvocableMethod
    public static void brokerRegistrationAttacher(List<Id> accIds){
        Id accId = accIds[0];

        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =:accId 
                                            AND ContentDocument.title = 'Broker_Agreement.pdf'];
                                                
        if (docList.size() < 1) {
            PageReference PDf =  Page.Broker_Agreement;
            PDf.getParameters().put('id',accId);
            PDf.setRedirect(true);
            Attachment attach = new Attachment();

            Blob b ;
            if(Test.IsRunningTest())
                b= Blob.valueOf('This is Test');    
            else
                b= PDf.getContentAsPDF(); 

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = 'Broker_Agreement.pdf';
            contentVersion.Title = 'Broker_Agreement.pdf';
            contentVersion.VersionData = b;
            insert contentVersion;

            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = conDoc;
            contentDocumentLink.LinkedEntityId = accId;
            contentDocumentLink.ShareType = 'I';
            contentDocumentLink.Visibility = 'InternalUsers';
            insert contentDocumentLink;
        }
    }

    public static List<ContentDocumentLink> brokerRegistrationAttacher2(List<Id> accIds){
        Id accId = accIds[0];
        
        PageReference PDf =  Page.Broker_Agreement;
        PDf.getParameters().put('id',accId);
        PDf.setRedirect(true);
        Attachment attach = new Attachment();

        Blob b ;
        if(Test.IsRunningTest())
            b= Blob.valueOf('This is Test');    
        else
            b= PDf.getContentAsPDF(); 

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
        contentVersion.PathOnClient = 'Broker_Agreement.pdf';
        contentVersion.Title = 'Broker_Agreement.pdf';
        contentVersion.VersionData = b;
        insert contentVersion;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conDoc;
        contentDocumentLink.LinkedEntityId = accId;
        contentDocumentLink.ShareType = 'I';
        contentDocumentLink.Visibility = 'InternalUsers';
        insert contentDocumentLink;

        return [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =:accId 
                                            AND ContentDocument.title = 'Broker_Agreement.pdf'];
    }
}