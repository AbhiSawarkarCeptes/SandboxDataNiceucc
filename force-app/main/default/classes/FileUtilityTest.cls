@isTest
public class FileUtilityTest {
    @isTest
    static void testCopyFile() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        ContentVersion contentVersionWithDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        
        Account sourceAccount = new Account(Name = 'Source Account');
        insert sourceAccount;
        
        Account targetAccount = new Account(Name = 'Target Account');
        insert targetAccount;
        
        // Create a ContentDocumentLink to simulate the file attached to the source account
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentVersionWithDocumentId.ContentDocumentId,
            LinkedEntityId = sourceAccount.Id,
            Visibility = 'AllUsers'
        );
        insert cdl;
        
        // Test the copyFile method
        Test.startTest();
        FileUtility.copyFile(sourceAccount.Id, targetAccount.Id);
        Test.stopTest();
    }
}