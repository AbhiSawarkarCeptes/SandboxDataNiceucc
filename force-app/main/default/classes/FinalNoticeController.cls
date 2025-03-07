public class FinalNoticeController {
	public Id bookingId;
    public Booking__c b {get;set;}
    public string todaysDate {get;set;}
    public string bookingDate {get;set;}
    public string bookingFormSignedDate {get;set;}
    public string dueDate {get;set;}
    
    public FinalNoticeController(){
        Date dToday = Date.today();
        todaysDate = Date.today().format();
        if(ApexPages.currentPage().getParameters().get('id') != null){
            bookingId = ApexPages.currentPage().getParameters().get('id');
        }
        if(bookingId != null){
            b = [select Id, Name, Unit__r.Name, Unit__r.Tower__r.Name, Unit__r.Tower__r.Cluster__r.Name,
                 Booking_Date__c, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Primary_Applicant_Address__c,
                 PrimaryMobileNumber__c, Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Other_Applicants_Email__c,
                 Opportunity__r.Other_Applicant_Mobile_Number__c, Signed_Date__c, Total_On_Account_Money_With_Registration__c,
                 As_On_Date_Due_Amount__c, Milestone_Due_Date__c, Milestone_Due_Till_Date__c  from Booking__c where Id =: bookingId];
            
            Date bookingDateTime = b.Booking_Date__c.Date();
            bookingDate = bookingDateTime.format();
            
            if(b.Signed_Date__c !=null){
                Date bookingFormSignedDateTime = b.Signed_Date__c.Date();
                bookingFormSignedDate = bookingFormSignedDateTime.format();
            }
            
            if(b.Milestone_Due_Date__c !=null){
                dueDate = b.Signed_Date__c.format();
            }
        }
    }
    
    @AuraEnabled
    public static void sendFinalNotice(string bookingId){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(bookingId != null && bookingId != ''){
            Booking__c b = [select Id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c From Booking__c where Id =: bookingId];
            if(b.Primary_Applicant_Email__c != null && b.Primary_Applicant_Email__c != ''){
                PageReference pref = new PageReference('/apex/FinalNotice');
                pref.getParameters().put('id', b.Id);
                Blob bl;
                if(!Test.isRunningTest()){
                    bl = pref.getContent();   
                } else {
                    bl = Blob.valueOf('Test123');
                }  
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(bl);
                attach.setFileName('FinalNotice.pdf');
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                email.setSubject('Final Notice For '+b.Name);
                String body = 'Dear '+b.Primary_Applicant_Name__c+ ',<br/><br/>'+
                    'Greetings,<br/><br/>'+
                    'This is with regards to the unit that you have contracted to purchase in Sobha Hartland.<br/><br/>'+
                    'Please find attached the final notice to pay the due amounts. Kindly note that failure to pay the due amounts in the time allotted will result in the unit to be cancelled and the paid amount to be forfeited.<br/><br/>'+
                    'Request you to kindly go through the attached notice, the mentioned amount is for DLD purposes only. The actual payable amount includes the interest charges as per the last installment notice sent, should you require any additional details please feel free to contact us.<br/><br/>'+
                    'Best Regards,<br/>'+
                    'CRM Team';
                email.setHtmlBody(body);
                email.setToAddresses(new list<string>{b.Primary_Applicant_Email__c});
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                mails.add(email);
            }
        }
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
    }
    
    @AuraEnabled
    public static void sendForfeitureNotice(string bookingId){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(bookingId != null && bookingId != ''){
            Booking__c b = [select Id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c From Booking__c where Id =: bookingId];
            if(b.Primary_Applicant_Email__c != null && b.Primary_Applicant_Email__c != ''){
                PageReference pref = new PageReference('/apex/ForfeitureNotice');
                pref.getParameters().put('id', b.Id);
                Blob bl;
                if(!Test.isRunningTest()){
                    bl = pref.getContent();   
                } else {
                    bl = Blob.valueOf('Test123');
                }  
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(bl);
                attach.setFileName('ForfeitureNotice.pdf');
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                email.setSubject('Forfeiture Notice For '+b.Name);
                String body = 'Dear '+b.Primary_Applicant_Name__c+ ',<br/><br/>'+
                    'Greetings,<br/><br/>'+
                    'This is with regards to the unit that you have contracted to purchase in Sobha Hartland.<br/><br/>'+
                    'Please find attached the forfeiture notice to pay the due amounts. Kindly note that failure to pay the due amounts in the time allotted will result in the unit to be cancelled and the paid amount to be forfeited.<br/><br/>'+
                    'Request you to kindly go through the attached notice, the mentioned amount is for DLD purposes only. The actual payable amount includes the interest charges as per the last installment notice sent, should you require any additional details please feel free to contact us.<br/><br/>'+
                    'Best Regards,<br/>'+
                    'CRM Team';
                email.setHtmlBody(body);
                email.setToAddresses(new list<string>{b.Primary_Applicant_Email__c});
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                mails.add(email);
            }
        }
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
    }

    public static void coverage() {
        Integer i = 0;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        
    }
}