public with sharing class FinalNoticeBookingController {
    public Id bookingId;
    public PropStrength__Application_Booking__c b {get;set;}
    public string todaysDate {get;set;}
    public string bookingDate {get;set;}
    public string bookingFormSignedDate {get;set;}
    public string dueDate {get;set;}
    
    public FinalNoticeBookingController(){
        Date dToday = Date.today();
        todaysDate = Date.today().format();
        if(ApexPages.currentPage().getParameters().get('id') != null){
            bookingId = ApexPages.currentPage().getParameters().get('id');
        }
        if(bookingId != null){
            b = [SELECT ID, PropStrength__Project__r.Project_Address__c, PropStrength__Primary_Applicant_Name__c, PropStrength__Applicant_Address__c, PropStrength__Applicant_Mobile__c, Booking_Form_Signed_Date__c,PropStrength__Total_Agreement_Amount__c,
                PropStrength__Applicant_Email__c, House_Unit_No__c, PropStrength__Tower__c, PropStrength__Property__r.Floor_Name__c, PropStrength__Booking_Date__c, PropStrength__Booking_Amount_Received__c
                FROM PropStrength__Application_Booking__c WHERE Id =: bookingId];
            
            Date bookingDateTime = b.PropStrength__Booking_Date__c;
            bookingDate = bookingDateTime.format();
            
            if(b.Booking_Form_Signed_Date__c !=null){
                Date bookingFormSignedDateTime = b.Booking_Form_Signed_Date__c;
                bookingFormSignedDate = bookingFormSignedDateTime.format();
            }
            
            // if(b.Milestone_Due_Date__c !=null){
            //     dueDate = b.Signed_Date__c.format();
            // }
        }
    }

    @AuraEnabled
    public static void sendFinalNotice(string bookingId){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        if(bookingId != null && bookingId != ''){
            PropStrength__Application_Booking__c b = [SELECT ID,PropStrength__Primary_Customer__c,Final_Notice_Sent_Date__c, PropStrength__Primary_Applicant_Name__c,PropStrength__Applicant_Email__c, CRM_Executive_Email__c,PropStrength__Property_Name__c, 
                            (SELECT Id, PropStrength__Applicant_Email__c, PropStrength__Type__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = true) 
                            FROM PropStrength__Application_Booking__c WHERE Id =: bookingId];
            List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Final Notice for Booking' limit 1];
            if(b.PropStrength__Applicant_Email__c != null && b.PropStrength__Applicant_Email__c != '') {
                PageReference pref = new PageReference('/apex/FinalNoticeBooking');
                pref.getParameters().put('id', b.Id);
                Blob bl;
                if(!Test.isRunningTest()){
                    bl = pref.getContent();   
                } else {
                    bl = Blob.valueOf('Test123');
                }  
                List<String> emailAddress = new List<String>();
                emailAddress.add(b.PropStrength__Applicant_Email__c);

                List<String> ccAddressEmails = new List<String>();
                
                for(PropStrength__Applicant_Detail__c ad : b.PropStrength__Applicant_Details__r) {
                    if(ad.PropStrength__Type__c != '1st Applicant' && ad.PropStrength__Applicant_Email__c != null && ad.PropStrength__Applicant_Email__c != '') {
                        ccAddressEmails.add(ad.PropStrength__Applicant_Email__c);
                    }
                }
                if(b.CRM_Executive_Email__c != null && b.CRM_Executive_Email__c != '') {
                    ccAddressEmails.add(b.CRM_Executive_Email__c);
                }

                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(bl);
                attach.setFileName('FinalNotice.pdf');
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
                email.setWhatId(b.Id);
                email.setToAddresses(emailAddress);
                if(templatelist.size() > 0)
                	email.setTemplateId(templatelist[0].Id);
                email.setSaveAsActivity(true); 
                email.setTargetObjectId(b.PropStrength__Primary_Customer__c);
                email.setTreatTargetObjectAsRecipient(false); 
                if(!ccAddressEmails.isEmpty()) {
                    email.setccAddresses(ccAddressEmails);
                }
                mails.add(email);
            }
            PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Id = b.Id, Final_Notice_Sent_Date__c = System.Now());
            update book;
        }
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
        
    }
    @AuraEnabled
    public static void sendForfeitureNotice(string bookingId){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];


        if(bookingId != null && bookingId != ''){
            PropStrength__Application_Booking__c b = [SELECT ID,PropStrength__Primary_Customer__c, PropStrength__Primary_Applicant_Name__c,PropStrength__Applicant_Email__c, CRM_Executive_Email__c,PropStrength__Property_Name__c, 
                            (SELECT Id, PropStrength__Applicant_Email__c, PropStrength__Type__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = true) 
                            FROM PropStrength__Application_Booking__c WHERE Id =: bookingId];
            List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Forfeiture Notice for Booking' limit 1];
            if(b.PropStrength__Applicant_Email__c != null && b.PropStrength__Applicant_Email__c != ''){
                PageReference pref = new PageReference('/apex/ForfeitureNoticeBooking');
                pref.getParameters().put('id', b.Id);
                Blob bl;
                if(!Test.isRunningTest()){
                    bl = pref.getContent();   
                } else {
                    bl = Blob.valueOf('Test123');
                }  
                List<String> emailAddress = new List<String>();
                emailAddress.add(b.PropStrength__Applicant_Email__c);
                List<String> ccAddressEmails = new List<String>();
                
                for(PropStrength__Applicant_Detail__c ad : b.PropStrength__Applicant_Details__r) {
                    if(ad.PropStrength__Type__c != '1st Applicant' && ad.PropStrength__Applicant_Email__c != null && ad.PropStrength__Applicant_Email__c != '') {
                        ccAddressEmails.add(ad.PropStrength__Applicant_Email__c);
                    }
                }
                if(b.CRM_Executive_Email__c != null && b.CRM_Executive_Email__c != '') {
                    ccAddressEmails.add(b.CRM_Executive_Email__c);
                }

                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(bl);
                attach.setFileName('ForfeitureNotice.pdf');
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
                email.setWhatId(b.Id);
                email.setToAddresses(emailAddress);
                if(templatelist.size() > 0)
                	email.setTemplateId(templatelist[0].Id);
                email.setSaveAsActivity(true); 
                email.setTargetObjectId(b.PropStrength__Primary_Customer__c);
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setTreatTargetObjectAsRecipient(false); 
                if(!ccAddressEmails.isEmpty()) {
                    email.setccAddresses(ccAddressEmails);
                }
                mails.add(email);
            }
            PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Id = b.Id, Forfeiture_Notice_Sent_Date__c = System.Today());
            update book;
        }
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
    }
}