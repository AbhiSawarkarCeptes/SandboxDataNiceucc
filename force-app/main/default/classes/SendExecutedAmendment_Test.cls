@isTest
public class SendExecutedAmendment_Test {
	@isTest
    static void testMethod1() {
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.Email_ID_1__c = 'test@acc123.com';
        insert acc;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Amendment Document - Letter.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Amendment Document - Letter.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;  
        
        SendExecutedAmendment.sendEnvelopeMethod(new List<Id>{acc.Id});
    }
}