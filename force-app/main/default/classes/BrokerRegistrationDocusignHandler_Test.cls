@isTest
public class BrokerRegistrationDocusignHandler_Test {
    
    @testSetup
    static void setup() {
        Account testAccount = TestDataFactorySobha.createAccount(null);
        testAccount.Email_ID_1__c = 'test@test.com';
        testAccount.Broker_Category__c = 'Company';
        insert testAccount;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Agreement -1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=testAccount.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
    }

    @isTest
    static void testSendEnvelopeMethod() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<Id> accIdList = new List<Id>{testAccount.Id};
        BrokerRegistrationDocusignHandler.sendEnvelopeMethod(accIdList);
        Test.stopTest();   
    }

    @isTest
    static void testForForSigningFuture() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        BrokerRegistrationDocusignHandler.forForSigningFuture(testAccount.Id);
        Test.stopTest();        
    }

    @isTest
    static void testErrorHandling() {
        Test.startTest();
        BrokerRegistrationDocusignHandler.forForSigningFuture(null);
        Test.stopTest();
    }
}