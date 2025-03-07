@isTest
public class HOUndertakingDocumentCreatorTest {
    @isTest
    static void testUndertakingAttacher() {
      
		Test.startTest();

        Account accA =new Account(Name='Demo');
        accA.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert accA ; 

        ContentVersion content=new ContentVersion(); 

        content.Title='Header_Picture1'; 

        content.PathOnClient='/' + content.Title + '.jpg'; 

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 

        content.VersionData=bodyBlob; 

        //content.LinkedEntityId=accA.id;

        content.origin = 'H';

        insert content;

        ContentDocumentLink contentlink=new ContentDocumentLink();

        contentlink.LinkedEntityId=accA.id;

        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;

        contentlink.ShareType = 'I';

        contentlink.Visibility = 'AllUsers'; 

        insert contentlink;

        List<Id> bookIds = new List<Id>{acca.Id};
        HOUndertakingDocumentCreator.undertakingAttacher(bookIds);
        Test.stopTest();
    }
}