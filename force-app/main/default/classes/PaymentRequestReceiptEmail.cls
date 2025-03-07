public class PaymentRequestReceiptEmail {
    public static PageReference sendAttachedReceiptbatch(List<Receipt__c> receiptList)
    { 
        List<Messaging.SingleEmailMessage> emailsList = new  List<Messaging.SingleEmailMessage>();
        for(Receipt__c receipt : receiptList){
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
            att.ParentId = receipt.Payment_Request__c;
            att.Description = descr;
        	insert att;
		//End ---
			            
        System.debug('I am recordidyamini-->'+receipt.Id);
        String fileName;
       
        User usr = [SELECT Id, Email,Name FROM User WHERE Id = :UserInfo.getUserId()]; 
        if((receipt.Payment_Request__r.Owner.email != null && receipt.Payment_Request__r.Owner.email  != '') || Test.isRunningTest()){   
            
            PageReference pref = new PageReference('/apex/PrintReceiptSobhaDubai');
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
            
            String body =  'Dear ' + receipt.Payment_Request__r.Name__c+ ',<br/><br/>' +                        
                
                'Greetings, <br/><br/>'+
                'Thank you for your payment towards your property'+' ' +receipt.Booking__r.Tower__c+' '+receipt.Project_Unit__r.Name +
                '.Please find attached receipt of amount'+' '+receipt.Currency__c+' '+receipt.Total_Amount__c +'.<br/><br/>'+                
                'Best Regards,<br/>'+
                usr.Name;
            
            if(receipt.Payment_Request__r.Owner.email  !=null && receipt.Payment_Request__r.Owner.email  != ''){
                lststringtoaddress.add(receipt.Payment_Request__r.Owner.email ); //Commented to block direct communication with client and added booking owner  
                System.debug('lststringtoaddress -->'+ lststringtoaddress);          
            }
           
           if(receipt.Booking__r.Primary_Applicant_Email__c != null && receipt.Booking__r.Primary_Applicant_Email__c != ''){
                        //lstStringtoaddress.add(receipt.Booking__r.Primary_Applicant_Email__c);
                    }
                    SYSTEM.DEBUG('I AM EMAIL'+receipt.Booking__r.sales_Head__r.email);
                    if(receipt.Booking__r.Sales_Head__c != null){
                        lstStringccaddress.add(receipt.Booking__r.Sales_Head__r.email);
                        lstStringccaddress.add(receipt.Booking__r.Sales_Head__r.Manager.Email);
                        SYSTEM.DEBUG('I AM EMAIL'+receipt.Booking__r.sales_Head__r.email);
                    }
                    if(receipt.Booking__r.Secondary_Sales_Head__c!=null){
                        lstStringccaddress.add(receipt.Booking__r.Secondary_Sales_Head__r.Manager.Email);
                    }
                    if(receipt.Booking__r.Sales_Managers__c!=null){
                        lstStringccaddress.add(receipt.Booking__r.Sales_Managers__r.email);
                    }
                    if(receipt.Booking__r.Secondary_Sales_Manager__c!=null){
                        lstStringccaddress.add(receipt.Booking__r.Secondary_Sales_Manager__r.email);
                    }
                    if(receipt.Booking__r.Secondary_Sales_Head__c!=null){
                        lstStringccaddress.add(receipt.Booking__r.Secondary_Sales_Head__r.email);
                    }
                    
                    lstStringccaddress.add('salesops@sobharealty.com');                 
           
            email.setToAddresses(lststringtoaddress);
            email.setccAddresses(lstStringccaddress);
            email.setbccAddresses(lstStringbccaddress);
            email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});   
            emailsList.add(email);
           
        
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'A mail has been sent to customer on email Id: ' + receiptdetails.Requester__r.Owner.email)); 
        } else 
        {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'Customer Email Id is blank'));     
        }  
        }
         Messaging.sendEmail(emailsList);
        return null;                           
    }

}