public class DocuSignNotificationEmailSent {
    
     @InvocableMethod
        public static void sendEmailMethod(List<String> bookingIds){
            String mySourceId = bookingIds[0];
            PrepareNSendEmail(mySourceId);
        }
    
    
        public static void PrepareNSendEmail(String mySourceId) {
            List <String> lststringtoaddress = new List<String>();
            List <String> lststringCCaddress = new List<String>();
             Booking__c booking = [Select id,Name,
                                        Sales_Manager__c,
                                        Sales_Managers__r.name, 
                                        Sales_Managers__r.email, 
                                        Sales_Head__c, 
                                        Sales_Head__r.name,
                                        Sales_Head__r.email,
                                        Sales_Head__r.Manager.Email, 
                                        Unit__r.Name
                                    From Booking__c 
                                    where id=:mySourceId limit 1];
             String body =  'Dear Team ,<br/><br/>'+
                            'This is to inform you that the Booking form with Booking ID-'+ booking.name+ ' for Unit #'+ booking.Unit__r.name+ ' has been SIGNED by '+ 
                            'the client. Request you to kindly review and complete the DocuSign process. '+
                            'Please check Salesforce for the latest update. <br/><br/> '+
                            '<i>Note: If SM is no longer active, Kindly notify Sales-force team to move the DocuSign process to SD queue</i>  '+                     
                            '<i>Note: If SD is no longer active, kindly notify Sales-force team to move the DocuSign process to VP queue</i> ';
            
            lststringtoaddress.add(booking.Sales_Managers__r.email);
            lststringtoaddress.add(booking.Sales_Head__r.email);
           // lststringCCaddress.add('salesops@sobharealty.com');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            String sub = 'DocuSign Unit #' + booking.Unit__r.Name+'- Booking ID #' +  booking.Name; 
            email.setSubject(sub);        
            email.setToAddresses(lststringtoaddress);
            email.setCcAddresses(lststringCCaddress);
            email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
            Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});
           
        }
   

}