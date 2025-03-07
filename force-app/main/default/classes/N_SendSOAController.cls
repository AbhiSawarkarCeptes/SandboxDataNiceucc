public class N_SendSOAController{
    Id oppId;
    Id bookingId;
    Opportunity Customer;
    String userId;
    public User u;
 
    public N_SendSOAController(){    
        if(ApexPages.currentPage().getParameters().get('id') != null)
            oppId = ApexPages.currentPage().getParameters().get('id');
            bookingId = ApexPages.currentPage().getParameters().get('bookingid');
             
        Customer = [SELECT Id, Name, Booking__r.Primary_Applicant_Email__c,Primary_Name__c, Booking__r.Unit__r.Name, Booking__r.Owner.Name,
                    Booking__r.Owner.Email,booking__c
                    FROM Opportunity WHERE Id = :OppId AND Unit__r.Tower__r.Stop_Automatic_Email__c = false ];
        u = [SELECT Id, Email,Name FROM User WHERE Id = :UserInfo.getUserId()];        
    }
   
    public PageReference sendAttachedSOA(){
        if(Customer.Booking__r.Primary_Applicant_Email__c != null && Customer.Booking__r.Primary_Applicant_Email__c != ''){  
           
            PageReference pref = new PageReference('/apex/N_CustomerSOAPage');
            pref.getParameters().put('Id', OppId);
            pref.getParameters().put('bookingid', bookingId);
            Blob b;
            if(!Test.isRunningTest()){
                b = pref.getContent();  
            } else {
                b = Blob.valueOf('Test123');
            }                          
           
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
            attach.setBody(b);
            attach.setFileName('SOA.pdf');  
           
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
            email.setSubject('SOA for ' + Customer.Booking__r.Unit__r.Name);
            List <String> lststringtoaddress = new List<String>();
            List <String> lstStringccaddress = new List <String>();

            Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
            System.debug(' owaMap '+owaMap); 
            for(OrgWideEmailAddress owa : [SELECT id,DisplayName, Address FROM OrgWideEmailAddress]){
                owaMap.put(owa.Address,owa);
            }
                     
            String body =  'Dear ' + Customer.Primary_Name__c+ ',<br/><br/>' +                        
                        /*   'Please find attached SOA.<br/><br/>'+ */
                            'Greetings, <br/><br/>'+
                           'Please find attached the statement of account (SOA) for your unit. <br/><br/>'+
                           'In case of any query, please drop an email to <a href="'+System.label.collection_email+'">'+ System.label.collection_email+'. </a><br/><br/>'+
 
                           'Best Regards,<br/>'+
                            u.Name;
           //SOB-336 start
           String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(customer.booking__c);
            if(!string.isblank(emailAddressFromBooking)){
                for(String s : emailAddressFromBooking.split(',')){
                    if(!s.containsIgnoreCase('null')){
                        lststringtoaddress.add(s);
                    }
                }
            }
           //SOB-336 end
           lststringtoaddress.add(Customer.Booking__r.Primary_Applicant_Email__c); //Commented to block direct communication with client and added booking owner  
           if(u.Email != null && u.Email != ''){
              //  lststringtoaddress.add(u.Email);  
                lstStringccaddress.add(u.Email);  // logged in user (Finance)
            }                  
            lstStringccaddress.add(System.label.CollectionTeamEmail);
            lstStringccaddress.add('sfnotifications@sobharealty.com');
           
            email.setToAddresses(lststringtoaddress);
            email.setccAddresses(lstStringccaddress);
            email.setWhatId(bookingId);
            email.setOrgWideEmailAddressId(owaMap.get(System.Label.collection_email).id);
            email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});          
            Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'A mail has been sent to customer on email Id: ' + Customer.Booking__r.Primary_Applicant_Email__c));
            if(Customer != null){
                Booking__c bookingRec = [SELECT ID,SOA_Sent__c,SOA_Sent_by__c,SOA_Sent_Date__c FROM Booking__c where id =: Customer.booking__c];
                if(bookingRec != null){
                    Datetime currentDateTime = Datetime.now();
                    bookingRec.SOA_Sent__c = true;
                    bookingRec.SOA_Sent_by__c = u.id;
                    bookingRec.SOA_Sent_Date__c = currentDateTime;
                    update bookingRec;
                }    
            }
           
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Customer Email Id is blank'));    
        }            
       return null;  
    }
}