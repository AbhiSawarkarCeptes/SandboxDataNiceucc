@istest()
public class NocLetterForAccountController_Test {
    
    @istest()
    public static void testNOC(){
        Account acc= new Account();
        acc.Name = 'test';
        insert acc;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Noc',
            PathOnClient = 'Penguins.PDF',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = acc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        PageReference pageRef = Page.NocLetterForAccount;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(acc.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        NocLetterForAccountController Noc = new NocLetterForAccountController(sc);
        Noc.att = new ContentVersion();
        Noc.getVersionData();
    }
    
}