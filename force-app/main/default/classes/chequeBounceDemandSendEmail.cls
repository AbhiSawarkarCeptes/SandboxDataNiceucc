public  class chequeBounceDemandSendEmail {
    @InvocableMethod(label='Send Email' description='Sends Email')
    public static void sendEmail(List<id> ids) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        Booking__c booking = [SELECT Id, Primary_Applicant_Name__c, Primary_Applicant_Email__c FROM Booking__c WHERE Id = :ids[0] LIMIT 1];
        List<string> toAddresses = new List<string>();
        toAddresses.add(booking.Primary_Applicant_Email__c);
        
        //SOB-336 start
        String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(booking.id);
        if(!string.isblank(emailAddressFromBooking)){
            for(String s : emailAddressFromBooking.split(',')){
                if(!s.containsIgnoreCase('null')){
                    toAddresses.add(s);
                }
            }
        }
        //SOB-336 end
       
        email.setToAddresses(toAddresses);
        List<string> ccAddresses = new List<string>();
        ccAddresses.add(System.label.SobhaHelpDeskMe);
        email.setCCAddresses(ccAddresses);
        PageReference pdf = Page.demandCheckBounce;
        pdf.getParameters().put('demandId',ids[0]);
        pdf.setRedirect(true);
        Blob b;
        if(!test.isRunningTest()) {
            b = pdf.getContent();
        }else{
            b=blob.valueOf('test');
        }
        string body = '<br>Dear '+booking.Primary_Applicant_Name__c+',</br>';
        body += '<p>Hope you are doing well.</p>';
        body += '<p>As per the terms and conditions of the booking form in Part B clause 3, “If any cheque issued by the Purchaser is dishonored, a fee of AED 1,000 shall be charged to the purchaser for each dishonored cheque (to cover administrative costs)”. Please find attached notice on the same.</p>';
        body += '<span style="font-family:Tahoma;font-size:14px;">Should you require any further assistance in this regard, feel free to contact us on the email address <a href="mailto:'+System.label.SobhaHelpDeskMe+'">'+System.label.SobhaHelpDeskMe+'</a> or the mailing address mentioned in the letter.</span>';
        body += '<p>Regards, </p>';
        body += '<p>Collection Team.</p>';
        body += '<a href="https://www.instagram.com/sobharealty/"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px;"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPO&oid=00D1t000000G1gX"></img></a>';
        body += '<a href="https://www.facebook.com/SobhaRealty/" style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px;"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPN&oid=00D1t000000G1gX"></img></a>';
        body += '<a href="https://www.instagram.com/sobharealty/"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px;"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPO&oid=00D1t000000G1gX"></img></a>';
        body += '<a href="https://www.youtube.com/channel/UCKIR9isiNyYq1T0GSnIUyHQ"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px;"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPS&oid=00D1t000000G1gX" ></img></a>';
        body += '<a href="https://www.linkedin.com/company/sobharealty/"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px;"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPX&oid=00D1t000000G1gX"></img></a><a href="https://www.sobharealty.com/" style="float:left; margin-top: 14px;">www.sobharealty.com</a><br/><br/>';
        body += '<p><a href="https://www.sobharealty.com/"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPc&oid=00D1t000000G1gX" style="float:left; width:25%;"></img></a></p>';
        email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
        email.setSubject('Cheque Dishonoured Charges');
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('ChequeBounce.pdf');         
        efa.setBody(b);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        Messaging.SendEmailResult [] r =   Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
    }
}