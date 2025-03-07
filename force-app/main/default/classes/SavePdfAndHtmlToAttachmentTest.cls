@IsTest
public class SavePdfAndHtmlToAttachmentTest {

    @IsTest
    static void testDoSaveReceipt() {
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert testAccount;

        Attachment attachment = new Attachment();
        attachment.ParentId = testAccount.Id;
        attachment.Name = 'Welcome Letter.pdf';
        attachment.Body = Blob.valueOf('Test Data');  
        insert attachment;
        
        Test.startTest();
        SavePdfAndHtmlToAttachement.doSaveReceipt(testAccount.Id, 'Welcome Letter');
        Test.stopTest();
    }
    @IsTest
    static void testDoSaveReceipt2() {
        
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert testAccount;

        Attachment attachment = new Attachment();
        attachment.ParentId = testAccount.Id;
        attachment.Name = 'Welcome Letter.pdf';
        attachment.Body = Blob.valueOf('Test Data');  
        insert attachment;
        
        Test.startTest();
        SavePdfAndHtmlToAttachement.doSaveReceipt(testAccount.Id, 'Welcome');
        Test.stopTest();
    }

    @IsTest
    static void testDoSaveAgreement() {
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert testAccount;

        Attachment a1 = new Attachment();
        a1.parentid = testAccount.Id;
        a1.name = 'TestPage.pdf';
        a1.body = Blob.valueOf('UNIT.TEST');
        Insert a1; 
        
        Test.startTest();
        SavePdfAndHtmlToAttachement.doSaveAgreement(testAccount.Id, 'TestPage');
        Test.stopTest();
        
       

    }

    @IsTest
    static void testDoSaveAgreement2() {
        Account testAccount = new Account(Name = 'Test Account');
		testAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert testAccount;

        Attachment a1 = new Attachment();
        a1.parentid = testAccount.Id;
        a1.name = 'Page.pdf';
        a1.body = Blob.valueOf('UNIT.TEST');
        Insert a1; 
        
        Test.startTest();
        SavePdfAndHtmlToAttachement.doSaveAgreement(testAccount.Id, 'TestPage');
        Test.stopTest();
    
     }

    @IsTest
    static void testDoSave() {
        Account testAccount = TestDataFactorySobha.createAccount(null);
        testAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert testAccount;
        List<Attachment> attclist = new List<Attachment>();
        Attachment attachment = new Attachment();
        attachment.ParentId = testAccount.Id;
        attachment.Name = 'Test.pdf';
        attachment.Body = Blob.valueOf('Test Data');  
        attclist.add(attachment);
        
        Attachment attachment2 = new Attachment();
        attachment2.ParentId = testAccount.Id;
        attachment2.Name = 'Test1.pdf';
        attachment2.Body = Blob.valueOf('Test Data Test Data');  
        attclist.add(attachment2);
        Attachment attachment3 = new Attachment();
        attachment3.ParentId = testAccount.Id;
        attachment3.Name = 'Test1.html';
        attachment3.Body = Blob.valueOf('Test Data');  
        attclist.add(attachment3);
        insert attclist;
        Test.startTest();
        SavePdfAndHtmlToAttachement.doSave(testAccount.Id, 'Test1');
        Test.stopTest();

    }

    @IsTest
    static void testDoSaveWithExistingHtml() {
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert testAccount;

        Attachment htmlAttachment = new Attachment(ParentId = testAccount.Id, Name = 'TestPage.html', Body = Blob.valueOf('Existing HTML Content'));
        insert htmlAttachment;

        Test.startTest();
        SavePdfAndHtmlToAttachement.doSave(testAccount.Id, 'TestPage');
        Test.stopTest();
    }
    @IsTest
    static void testDoSaveWithExistingHtml2() {
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert testAccount;

        Attachment htmlAttachment = new Attachment(ParentId = testAccount.Id, Name = 'TestPage.svg', Body = Blob.valueOf('Existing HTML Content'));
        insert htmlAttachment;

        Test.startTest();
        SavePdfAndHtmlToAttachement.doSave(testAccount.Id, 'TestPage');
        Test.stopTest();
    }
}