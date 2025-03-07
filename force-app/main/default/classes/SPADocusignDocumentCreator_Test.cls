@isTest
public class SPADocusignDocumentCreator_Test {

    @isTest
    static void testSpaAttacher() {
        
        Account testAccount = TestDataFactorySobha.createAccount(null);
        insert testAccount;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'SPA Letter.pdf';
        cv.PathOnClient = 'SPA Letter.pdf';
        cv.VersionData = Blob.valueOf('Sample PDF Content');
        insert cv;
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = con.Id; // Replace with a valid record Id if necessary
        cdl.ShareType = 'V';
        insert cdl;

        //insert testAccount;
        Attachment testAttachment = new Attachment();
        testAttachment.ParentId = testAccount.Id;
        testAttachment.Name = 'SPA Letter.pdf';
        testAttachment.Body = Blob.valueOf('Sample Attachment Content');
        insert testAttachment;

        Test.startTest();
        SPADocusignDocumentCreator.spaAttacher(new List<Id>{ testAccount.Id });
        Test.stopTest();

    }
}