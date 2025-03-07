public without sharing class SendPccAction {
    
    @InvocableMethod(label='Send PCC' description='Send PCC')
    public static void sendPCCs(List<Id> bookingIds) {
        for(Id bookingId : bookingIds)
        SendPccAction.sendPcc(bookingId);
    }

    @future(callout=true)
    public static void sendPcc(Id bookingId) {

        Booking__c booking = [
            SELECT Id, Primary_Applicant_Email__c
            FROM Booking__c
            WHERE Id = :bookingId
        ];

        if( String.isBlank( booking.Primary_Applicant_Email__c ) ){
            return;
        }

        EmailTemplate template = [
            SELECT Id, Subject, Body
            FROM EmailTemplate
            WHERE DeveloperName = 'PCC_Approved_Email_Draft'
        ];  

        Contact dummyContact = new Contact(LastName = booking.Primary_Applicant_Email__c, Email = booking.Primary_Applicant_Email__c);
        insert dummyContact;
        System.debug('dummyContact --> '+dummyContact);
        PageReference pageRef = new PageReference('/apex/PCCVFPAGE?bookingId=' + bookingId);
        Blob pdfBlob;

        try {
            pdfBlob = Test.isRunningTest() ? blob.valueOf('Unit.Test') : pageRef.getContentAsPDF();
        } catch (VisualforceException e) {
            System.debug('Error generating PDF: ' + e.getMessage());
            return;
        }

        OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'helpdesk@sobharealty.com' Limit 1];

        // Create email message with attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('PCC.pdf');
        attachment.setBody(pdfBlob);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //email.setSubject(template.Subject);
        //email.setPlainTextBody(template.Body);
        email.setTemplateId(template.Id);
        email.setTargetObjectId(dummyContact.Id);
        email.setWhatId(booking.Id);
        email.setToAddresses(new List<String>{booking.Primary_Applicant_Email__c}); // Set recipient email address
        email.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});

        // Send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});

        // Check the email send results
        for (Messaging.SendEmailResult result : results) {
            if (result.isSuccess()) {
                System.debug('Email sent successfully.');
            } else {
                System.debug('Error sending email: ' + result.getErrors()[0].getMessage());
            }
        }

        delete dummyContact;
    }
}