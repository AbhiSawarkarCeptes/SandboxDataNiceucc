public class sendreceiptcontroller{
    
    public String lstReceipt { get; set; }
    
    Id receiptId;
    Requester__c requester;
    receipt__c receiptdetails;
    String userId;
    public User u;
    String fileName;
    
    public sendreceiptcontroller()
    {     
        if(ApexPages.currentPage().getParameters().get('id') != null)
            receiptId= ApexPages.currentPage().getParameters().get('id'); 
        
        receiptdetails = [select name,id,Requester__r.Owner.email,Requester__r.name,Requester__r.Owner.Name,
                          Project_Unit__r.Name,Total_Amount__c,Receipt_No__c from Receipt__c where Id=:receiptId];
        u = [SELECT Id, Email,Name FROM User WHERE Id = :UserInfo.getUserId()]; 
        
    }  
    
    
    public PageReference sendAttachedReceipt()
    { 
        if(receiptdetails.Requester__r.Owner.email != null && receiptdetails.Requester__r.Owner.email  != ''){   
			
            PageReference pref = new PageReference('/apex/PrintReceiptSobhaDubai');
            pref.getParameters().put('Id', receiptId);
            Blob b;
            if(!Test.isRunningTest()){
                b = pref.getContent();   
            } else {
                b = Blob.valueOf('Test123');
            }                           
            
            fileName = receiptdetails.Receipt_No__c +''+  receiptdetails.Project_Unit__r.Name;
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
            attach.setBody(b);
            attach.setFileName(fileName+'.pdf');  
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
            email.setSubject('Receipt for ' + receiptdetails.Requester__r.Name);
            List <String> lststringtoaddress = new List<String>();
            List <String> lstStringccaddress = new List <String>();
            
            String body =  'Dear ' + receiptdetails.Requester__r.Owner.Name+ ',<br/><br/>' +                        
                
                'Greetings, <br/><br/>'+
                'Thank you for your payment towards your property building'+ receiptdetails.Project_Unit__r.Name +
                '.Please find attached receipt of amount'+  receiptdetails.Total_Amount__c +'.<br/><br/>'+
                
                'Best Regards,<br/>'+
                u.Name;
            
            lststringtoaddress.add(receiptdetails.Requester__r.Owner.email); //Commented to block direct communication with client and added booking owner  
            if(u.Email != null && u.Email != ''){
                //  lststringtoaddress.add(u.Email);  
                lstStringccaddress.add(u.Email);  // logged in user (Finance)
            }                   
            
            // if(Customer.Booking__r.Owner.Email != null && Customer.Booking__r.Owner.Email != '')
            //  lstStringccaddress.add(Customer.Booking__r.Owner.Email);
            
            email.setToAddresses(lststringtoaddress);
            email.setccAddresses(lstStringccaddress);
            email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});           
            Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'A mail has been sent to customer on email Id: ' + receiptdetails.Requester__r.Owner.email)); 
        } else 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Customer Email Id is blank'));     
        }            
        return null;                           
    }
    
    // Code added for the purpose of sending email from trigger trgReceipt 
    @Future(callout=true)
    public static void sendAttachedReceiptPB(List<Id> receiptrecordId)
    { 
        
        List<receipt__c> receiptdetail = new List<receipt__c>();
        
        //String fileName;
        if(receiptrecordId.size()>0){
            receiptdetail = [SELECT name,id,Requester__r.Owner.email,Requester__r.name,Requester__r.Owner.Name,
                             Requester__r.Requester_Manager_Email__c,Project_Unit__r.Name,Total_Amount__c,Receipt_No__c,Requester__r.Requested_User__r.Name,
                             Requester__r.Requested_User__r.email,Currency__c,Booking__r.Tower__c,Booking__r.Name,Booking__r.Primary_Applicant_Name__c	
                             FROM Receipt__c 
                             WHERE Id IN: receiptrecordId];
            
            for(Receipt__c receipt: receiptdetail){
                sendAttachedReceipt1(receipt);
            }
        }
    }
    
    public static PageReference sendAttachedReceipt1(Receipt__c receipt)
    { 
        //Changes to attach Receipt to Requester
            PageReference page = new PageReference('/apex/PrintReceiptSobhaDubai?id='+receipt.Id+'&letterhead=0');
            Blob pdf;
            String name = '';
            String descr = 'Receipt';
            try{
            	pdf = page.getContentAsPDF();
            }catch(Exception e){
            	pdf = Blob.valueOf(e.getMessage());
            	descr = e.getMessage();
            }
            
            Attachment att = new Attachment();
            att.Body = pdf;
            att.Name = receipt.name+'.pdf';
            att.IsPrivate = false;
            att.ParentId = receipt.Requester__c;
            att.Description = descr;
        	insert att;
		//End ---
			            
        System.debug('I am recordidyamini-->'+receipt.Id);
        String fileName;
        /*String applicantEmail='';
        Id bookingId = receipt.Booking__c;
        List<Applicant_Details__c> applicantDetailsList = new List<Applicant_Details__c>();
        applicantDetailsList = [SELECT Id,Email_Address__c
                                FROM Applicant_Details__c
                                WHERE Booking__c =: bookingId];
        if(applicantDetailsList != null && applicantDetailsList.size()>0){
            for(Applicant_Details__c ad : applicantDetailsList){
                
                If(ad.Email_Address__c != '' && ad.Email_Address__c != null && applicantEmail.contains(ad.Email_Address__c) == false && ad.Email_Address__c !=receipt.Requester__r.Owner.email){
                    applicantEmail =  applicantEmail !='' && applicantEmail != null ? applicantEmail+','+ad.Email_Address__c:ad.Email_Address__c;              
                }                
            }
            System.debug('i am applicantdetails'+applicantEmail);
        }*/
   
        User usr = [SELECT Id, Email,Name FROM User WHERE Id = :UserInfo.getUserId()]; 
        if(receipt.Requester__r.Owner.email != null && receipt.Requester__r.Owner.email  != ''){   
            
            PageReference pref = new PageReference('/apex/PrintReceiptSobhaDubai');
            //PageReference pref = Page.PrintReceiptSobhaDubai;
            pref.getParameters().put('id', receipt.Id);
            Blob b;
            if(!Test.isRunningTest()){
                b = pref.getContent();   
            } else {
                b = Blob.valueOf('Test123');
            }                           
            
            fileName = receipt.Name;
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
            attach.setBody(b);
            attach.setFileName(fileName+'.pdf');  
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
            email.setSubject('Receipt for ' +receipt.Booking__r.Name+' '+receipt.Project_Unit__r.Name+' '+ receipt.Booking__r.Primary_Applicant_Name__c);
            List <String> lststringtoaddress = new List<String>();
            List <String> lstStringccaddress = new List <String>();
            List <String> lstStringbccaddress = new List <String>();
            
            String body =  'Dear ' + receipt.Requester__r.Requested_User__r.Name+ ',<br/><br/>' +                        
                
                'Greetings, <br/><br/>'+
                'Thank you for your payment towards your property'+' ' +receipt.Booking__r.Tower__c+' '+receipt.Project_Unit__r.Name +
                '.Please find attached receipt of amount'+' '+receipt.Currency__c+' '+receipt.Total_Amount__c +'.<br/><br/>'+
                
                'Best Regards,<br/>'+
                usr.Name;
            
            if(receipt.Requester__r.Requested_User__r.email !=null && receipt.Requester__r.Requested_User__r.email != ''){
                lststringtoaddress.add(receipt.Requester__r.Requested_User__r.email); //Commented to block direct communication with client and added booking owner  
                System.debug('lststringtoaddress -->'+ lststringtoaddress);          
            }
            /*if(applicantEmail != null && applicantEmail != ''){
                List<String> applicantEmailList = new List<String>();
                applicantEmailList=applicantEmail.split(',');                
                lststringtoaddress.addall(applicantEmailList);                
            }*/
            if(usr.Email != null && usr.Email != ''){
                //  lststringtoaddress.add(u.Email);  
                lstStringccaddress.add(usr.Email);  // logged in user (Finance)
            }                   
            lstStringccaddress.add(System.label.SobhaCRMTeam);
            lstStringccaddress.add(System.label.SobhaCollectionTeamMe);
            lstStringccaddress.add(System.label.SobhaAR);
            if(receipt.Requester__r.Requester_Manager_Email__c != null && receipt.Requester__r.Requester_Manager_Email__c != ''){
                lstStringbccaddress.add(receipt.Requester__r.Requester_Manager_Email__c);
            }
            /*if(receipt.Requester__r.Requested_User__r.email !=null && receipt.Requester__r.Requested_User__r.email != ''){
                lstStringbccaddress.add(receipt.Requester__r.Requested_User__r.email);
            }*/
            
            
            // if(Customer.Booking__r.Owner.Email != null && Customer.Booking__r.Owner.Email != '')
            //  lstStringccaddress.add(Customer.Booking__r.Owner.Email);
            
            email.setToAddresses(lststringtoaddress);
            email.setccAddresses(lstStringccaddress);
            email.setbccAddresses(lstStringbccaddress);
            email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});           
            Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'A mail has been sent to customer on email Id: ' + receiptdetails.Requester__r.Owner.email)); 
        } else 
        {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Customer Email Id is blank'));     
        }            
        return null;                           
    }
    
}