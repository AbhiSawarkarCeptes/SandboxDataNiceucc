@IsTest
public class NOCDocumentCreator_Test {
    @TestSetup
    static void setupData() {
        // Create test account
        Account testAccount = TestDataFactorySobha.createAccount(null);
        insert testAccount;
    }

    @IsTest
    static void testBrokerRegistrationAttacher() {
        // Fetch the test account created in the setup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Call the method with test data
        List<Id> accIds = new List<Id>{testAccount.Id};
        NOCDocumentCreator.brokerRegistrationAttacher(accIds);

        // Verify that the ContentDocumentLink is created
        List<ContentDocumentLink> docLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :testAccount.Id
        ];
        System.assertEquals(1, docLinks.size(), 'ContentDocumentLink should have been created');
        System.assertEquals(testAccount.Id, docLinks[0].LinkedEntityId, 'LinkedEntityId should match the test account Id');
    }

    @IsTest
    static void testBrokerRegistrationAttacher2() {
        // Fetch the test account created in the setup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Call the method with test data
        List<Id> accIds = new List<Id>{testAccount.Id};
        List<ContentDocumentLink> docLinks = NOCDocumentCreator.brokerRegistrationAttacher2(accIds);

        // Verify the method returned the expected ContentDocumentLink
        System.assertEquals(1, docLinks.size(), 'ContentDocumentLink should have been created and returned');
        System.assertEquals(testAccount.Id, docLinks[0].LinkedEntityId, 'LinkedEntityId should match the test account Id');
    }

    @IsTest
    static void testNoDuplicateDocumentCreation() {
        // Fetch the test account created in the setup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Call the method twice to check for duplicates
        List<Id> accIds = new List<Id>{testAccount.Id};
        NOCDocumentCreator.brokerRegistrationAttacher(accIds);
        NOCDocumentCreator.brokerRegistrationAttacher(accIds);

        // Verify that only one ContentDocumentLink is created
        List<ContentDocumentLink> docLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :testAccount.Id
        ];
        System.assertEquals(1, docLinks.size(), 'Only one ContentDocumentLink should exist');
    }
}