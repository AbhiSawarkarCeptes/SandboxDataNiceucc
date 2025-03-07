public class Completionnotionemail{
    Id oppId;
    Opportunity Customer;
    String userId;
    public User u;

    public Completionnotionemail(){    
        if(ApexPages.currentPage().getParameters().get('id') != null)
            oppId = ApexPages.currentPage().getParameters().get('id'); 
             
        Customer = [SELECT Id, Name, Booking__r.Primary_Applicant_Email__c,Primary_Name__c, Booking__r.Unit__r.Name, Booking__r.Owner.Name,
                    Booking__r.Owner.Email,Booking__c
                    FROM Opportunity WHERE Id = :OppId]; 
        u = [SELECT Id, Email,Name FROM User WHERE Id = :UserInfo.getUserId()];        
    }
    
    public PageReference sendAttachedcompletionnotice(){ 
        if(Customer.Booking__r.Primary_Applicant_Email__c != null && Customer.Booking__r.Primary_Applicant_Email__c != ''){   
            List <String> lststringtoaddress = new List<String>();
            //SOB-336 start
            String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(Customer.Booking__c);
            if(!string.isblank(emailAddressFromBooking)){
                for(String s : emailAddressFromBooking.split(',')){
                    if(!s.containsIgnoreCase('null')){
                        lststringtoaddress .add(s);
                    }
                }
            }
           //SOB-336 end
           
           
            PageReference pref = new PageReference('/apex/CompletionNoticevfpage');
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
            attach.setFileName('CompletionNotice.pdf');
            fileAttachments.add(attach);
            
            List<contentversion> fillst1 = [ SELECT title, PathOnClient, FileType, versiondata FROM contentversion where title = :system.Label.BCC_for_Creek_Vista.split(',')];
                system.debug(fillst1);
                for(contentversion ct1 : fillst1){
                    Messaging.EmailFileAttachment tempaatach1 = new Messaging.EmailFileAttachment();
                    tempaatach1.setBody(ct1.versiondata);
                    tempaatach1.setContentType('application/pdf');
                    tempaatach1.setFileName(ct1.title+'.pdf');  
                    tempaatach1.setInline(false);
                    fileAttachments.add(tempaatach1);
                    }  
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
            email.setSubject('Sobha Creek Vistas Reserve - Completion Notice for ' + Customer.Booking__r.Unit__r.Name);
             List <String> lstStringccaddress = new List <String>();
                     
                   
            String body =  'Dear ' + Customer.Primary_Name__c+ ',<br/><br/>' +                        
                        /*   'Please find attached SOA.<br/><br/>'+ */
                            'Greetings! <br/><br/>'+
                           'We thank you for your purchase of the above Property. We are pleased to inform you that we have received the Building Completion Certificate and the Completion Date of your Property is 1 November 2022. Please find attached Building Completion Certificate and the Completion notice for your reference. <br/><br/>'+
                           'A notification regarding the instalment payments for your unit will be sent shortly(If applicable). <br/><br/>'+
                           'Further, we will be contacting you shortly to schedule the Home Orientation/Inspection for your Property.<br/><br/>'+
                           'Should you require any further assistance in this regard, feel free to contact us on +971 4 368 7845 or write to us at <a href="'+System.label.SobhaHelpdesk+'"> '+System.label.SobhaHelpdesk+' </a><br/><br/>'+

 

                           'Thanks and regards,<br/>'+
                           'CRM Team <br/>'+
                           '+971 4 368 7845';
           
           lststringtoaddress.add(Customer.Booking__r.Primary_Applicant_Email__c); //Commented to block direct communication with client and added booking owner  
           if(u.Email != null && u.Email != ''){
              //  lststringtoaddress.add(u.Email);  
                lstStringccaddress.add(u.Email);  // logged in user (Finance)
            }                   
                lstStringccaddress.add(System.label.SobhaHelpdesk);
            
           
           // if(Customer.Booking__r.Owner.Email != null && Customer.Booking__r.Owner.Email != '')
             //  lstStringccaddress.add(Customer.Booking__r.Owner.Email);
            
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
    }

}