@isTest
public class EmailTemplateController_Test {
    @testSetup static void setup() {
		List<Contact> conlist = new List<Contact>();
        conList.add(new Contact(FirstName = 'Test' + DateTime.now(),LastName = 'test1',Email = 'test1@test.com'));
        conList.add(new Contact(FirstName = 'Test' + DateTime.now(),LastName = 'test2',Email = 'test2@test.com'));
        conList.add(new Contact(FirstName = 'Test' + DateTime.now(),LastName = 'test3',Email = 'test3@test.com'));
        insert conList;
    }
    static testMethod void getEmailAddress() {
       Test.startTest();
        List<String> st = EmailTemplateController.getEmailAddress('');
        System.assertEquals(4,st.size());
        List<String> st1 = EmailTemplateController.getEmailAddress('test1');
        System.assertEquals(2,st1.size());
       Test.stopTest();
    }
    static testMethod void sendEmailsTest() {
        String json = '[{"To":"test1@test.com","Bcc":"test2@test.com","EmailSubject":"Testing","EmailBody":"<p>Testing The Email</p>"},{"To":"test2@test.com","Cc":"test3@test.com","Bcc":"test3@test.com","EmailSubject":"Test Subject","EmailBody":"<p>Test Body</p>"}]';
        Test.startTest();
        String st = EmailTemplateController.sendEmail(json, '');
        ContentVersion cv = EmailTemplateController.uploadFile('Testing', 'Testing ContentVersion File Data');
        String st1 = EmailTemplateController.sendEmail(json, cv.ContentDocumentId);
        Test.stopTest();
    }
}