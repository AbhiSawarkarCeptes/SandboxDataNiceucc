public  class SendEmailForReceiptError {
    public static void sendEmailMessage(String sMessage) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
        String[] toAddresses = System.label.Email_Id_For_Receipt_Error.split(';');
        mail.setToAddresses(toAddresses) ;
        mail.setSubject('Exception occured while creating receipts');
        
        String body = '<html lang="ja"><body>'+
                        '<br><br>'+
                        'This email alert is to bring to your notice that exception occured  '+
                        '<br><br>'+
                        '<b>'+
                        'Here is detail of Exception '+
                        '</b>'+
                        '<br><br>'+ sMessage+
                        '</body></html>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}