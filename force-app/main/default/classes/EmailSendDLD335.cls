public with sharing class EmailSendDLD335 {
    @InvocableMethod(label='Send Email with Attachment' description='Sends an email with attachment')
    public static void sendEmail(List<EmailRequest> requests) {
        List<Messaging.Email> emails = new List<Messaging.Email>();

        for (EmailRequest request : requests) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{request.emailAddress});
            email.setSubject('DLP End Date Approaching : Reminder');
            email.setPlainTextBody('Dear '+request.customerName+',\n\nThis is to bring to your notice that your DLP End date is approaching soon in next 30 days.\n\n\nWarm Regards,\nSobha LLP');

            String frmsrc = '/apex/DLDSendDateVFFlow?id='+request.trId;
            PageReference p1 = new PageReference(frmsrc);
            blob content;
            if(Test.isRunningTest()) { 
                content = blob.valueOf('Unit.Test');
            } else {
                content = p1.getContentAsPDF();
            }
            
            Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
            efa1.setFileName('DLP End Date Notification.pdf');
            efa1.setBody(content);   
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});

            emails.add(email);
        }

        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emails);
        // Handle sendResults and any error handling you need
    }
    public class EmailRequest {
        @InvocableVariable(required=true label='Email Address' description='The recipient email address')
        public String emailAddress;

        @InvocableVariable(required=true label='Customer Name' description='The customer name of related record')
        public String customerName;
        
        @InvocableVariable(required=true label='Transaction Record Id' description='The Record Id of Transaction Request Record')
        public String trId;
    }
}