@isTest
public class DocumentUtil_test {
    @TestSetUp
    public static void makeData(){
        Id orgID = [SELECT Id FROM Organization].Id;
        System.debug(orgID);
        
         Document testDocument = new Document(
            Name = 'Test Document',
            Body = Blob.valueOf('Test body'),
            ContentType = 'text/plain',
            FolderId = System.Userinfo.getUserId()
        );
        insert testDocument;
    }
    
    @isTest
    public static void testDocumentUtil(){
        Document cd = [select id from Document limit 1];
        DocumentUtil du = new DocumentUtil();
        du.doc = cd;
        du.getURL();
        DocumentUtil.getInstance();
    }
}