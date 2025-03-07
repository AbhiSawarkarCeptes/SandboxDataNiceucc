@isTest
public class AttachmentTriggerHelper_Test {
	@isTest
    public static void testMethod1() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Attachment attachment = new Attachment();
    	attachment.ParentId = acc.Id;
    	attachment.Name = 'Welcome Letter.pdf';
    	attachment.Body = Blob.valueOf('Test Data');  
        insert attachment;
    }
}