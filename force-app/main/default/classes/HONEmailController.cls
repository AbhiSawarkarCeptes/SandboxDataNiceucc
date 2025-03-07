public class HONEmailController {

    Id oppId;
    Opportunity Customer;
    String userId;
    public User u;
   
    public HONEmailController(){    
        String errorMessage = '';
        if(ApexPages.currentPage().getParameters().get('id') != null)
            oppId = ApexPages.currentPage().getParameters().get('id'); 
             
        Customer = [SELECT Id, Name, Booking__r.Primary_Applicant_Email__c,Primary_Name__c, Booking__r.Unit__r.Name, Booking__r.Owner.Name,
                    Booking__r.Owner.Email,Booking__r.Tower_Name__c,Booking__r.Handover_Date__c,Unit__r.Tower__r.Name,booking__c
                    FROM Opportunity WHERE Id = :OppId];
        
     
       /* handoverdate = Customer.Booking__r.Handover_Date__c; */
        u = [SELECT Id, Email,Name FROM User WHERE Id = :UserInfo.getUserId()];        
    }
    
    public PageReference sendAttachedhandovernotice(){ 
        String errorMessage;
        try { 
            if(Customer.Booking__r.Primary_Applicant_Email__c != null && Customer.Booking__r.Primary_Applicant_Email__c != ''){   
                PageReference pref = new PageReference('/apex/HandoverNoticeVFpage');
                pref.getParameters().put('Id', OppId);
                Blob b;
                if(!Test.isRunningTest()){
                    b = pref.getContent();   
                } else {
                    b = Blob.valueOf('Test123');
                }                           
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(b);
                attach.setFileName('Handover Notice.pdf');
                fileAttachments.add(attach);
        
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
                errorMessage = 'Tower Name OR Unit Name On Booking is Empty (Booking__r.Tower_Name__c || Booking__r.Unit__r.Name)'; 
                
                email.setSubject(Customer.Booking__r.Tower_Name__c +' - Handover Notice for'  + Customer.Booking__r.Unit__r.Name);
                List <String> lststringtoaddress = new List<String>();
                List <String> lstStringccaddress = new List <String>();
                
                errorMessage = 'Handover Date On Booking is Empty (Booking__r.Handover_Date__c)';

                Integer d = Customer.Booking__r.Handover_Date__c.day();
                Integer mo = Customer.Booking__r.Handover_Date__c.month();
                Integer yr = Customer.Booking__r.Handover_Date__c.year();
                Datetime dt = DateTime.newInstance(yr, mo, d);
                String handoverdate = dt.format('dd MMMM yyyy');
                
                errorMessage = 'Primary Name On Opportunity is Empty (Customer.Primary_Name__c)';

                String body =  'Dear ' + Customer.Primary_Name__c+ ',<br/><br/>' +                        
                            'Greetings! <br/><br/>'+
                            'We are delighted to inform you that your Property will be ready for handover on ' + handoverdate + ' or on the date that you take actual possession of the Property, whichever is earlier (“<b>Handover Date</b>”). <br/><br/>'+
                            'Please find attached the <b>Handover Notice</b> for your unit. Accordingly, you are requested to kindly settle/fulfill all obligations as per your Sale and Purchase Agreement (SPA), and this Handover Notice on or before the Handover Date in order to enable us to handover possession of your Property. Request you to kindly take prior appointment for the handover to ensure effective handover process. Please contact us on      +971 4 3687845 or write to us at <a href="'+System.label.SobhaHelpdesk+'"> '+System.label.SobhaHelpdesk+' </a> to schedule your appointments for the handover.<br/><br/>'+
                            'If you have authorized a third party or representative to take possession of your Property, please ensure that you have granted a valid original power of attorney attested by the Notary Public (“<b>POA</b>”) and if such POA is executed outside UAE, then it needs to be attested by the UAE Embassy in the relevant country and the UAE Ministry of Foreign Affairs, and we will need to see the original POA at the time of handover.<br/><br/>'+
                            'Please log on to our website <a href="www.sobharealty.com"> www.sobharealty.com </a> for information regarding our current and upcoming Projects.<br/><br/>'+
                            'We look forward to welcoming you into the proud community of property owners at Sobha Hartland.<br/><br/>'+

    

                            'Thanks and regards,<br/>'+
                            'CRM Team <br/>'+
                            '+971 4 368 7845<br/>' +                
            '<a href="https://www.facebook.com/SobhaRealty/" style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px;"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPN&oid=00D1t000000G1gX"></img></a>' +
            '<a href="https://www.instagram.com/sobharealty/"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px;"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPO&oid=00D1t000000G1gX"></img></a>'+
            '<a href="https://www.youtube.com/channel/UCKIR9isiNyYq1T0GSnIUyHQ"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px;"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPS&oid=00D1t000000G1gX" ></img></a>'+
            '<a href="https://www.linkedin.com/company/sobharealty/"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px;"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPX&oid=00D1t000000G1gX"></img></a><a href="https://www.sobharealty.com/" style="float:left; margin-top: 14px;">www.sobharealty.com</a><br/>'+

            '<a href="https://www.sobharealty.com/"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPc&oid=00D1t000000G1gX" style="float:left; width:25%;"></img></a>';
            lststringtoaddress.add(Customer.Booking__r.Primary_Applicant_Email__c);
            if(u.Email != null && u.Email != ''){
                //  lststringtoaddress.add(u.Email);  
                    lstStringccaddress.add(u.Email);  // logged in user (Finance)
                }                   
                    lstStringccaddress.add(System.label.SobhaHelpdesk);
                
            
            // if(Customer.Booking__r.Owner.Email != null && Customer.Booking__r.Owner.Email != '')
                //  lstStringccaddress.add(Customer.Booking__r.Owner.Email);
                //SOB-336 start
                String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(customer.Booking__c);
                if(!string.isblank(emailAddressFromBooking)){
                    for(String s : emailAddressFromBooking.split(',')){
                        if(!s.containsIgnoreCase('null')){
                            lststringtoaddress.add(s);
                        }
                    }
                }
                //SOB-336 end
                email.setToAddresses(lststringtoaddress);
                email.setccAddresses(lstStringccaddress);
                email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
                email.setFileAttachments(fileAttachments);           
                Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'A mail has been sent to customer on email Id: ' + Customer.Booking__r.Primary_Applicant_Email__c)); 
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Customer Email Id is blank'));     
            }            
            return null;   
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,e.getMessage()+' - '+errorMessage));  
            return null;    
        }
    }


}