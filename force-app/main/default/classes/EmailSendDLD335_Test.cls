@isTest
public class EmailSendDLD335_Test {
    @isTest
    static void testSendEmail() {
        List<EmailSendDLD335.EmailRequest> requests = new List<EmailSendDLD335.EmailRequest>();

        EmailSendDLD335.EmailRequest request1 = new EmailSendDLD335.EmailRequest();
        request1.emailAddress = 'test1@example.com';
        request1.customerName = 'Customer One';
        request1.trId = 'a0B5g00000B5C1DEAV';
        requests.add(request1);

        EmailSendDLD335.EmailRequest request2 = new EmailSendDLD335.EmailRequest();
        request2.emailAddress = 'test2@example.com';
        request2.customerName = 'Customer Two';
        request2.trId = 'a0B5g00000B5C2DEAV';
        requests.add(request2);

        Test.startTest();
        EmailSendDLD335.sendEmail(requests);
        Test.stopTest();
    }
}