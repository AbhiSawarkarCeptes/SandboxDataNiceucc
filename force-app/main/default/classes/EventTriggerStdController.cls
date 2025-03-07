public class EventTriggerStdController {
    public static void sendEmailForTRHandover(List<Event> evtList) {
        Set<Id> trId = new Set<Id>();
        for(Event evt : evtList) {
            trId.add(evt.WhatId);
        }
        Map<Id, PropStrength__Transaction_Requests__c> mapTr = new Map<Id, PropStrength__Transaction_Requests__c>([SELECT Id, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, PropStrength__Application_Booking__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trId]);
        Set<Id> bookId = new Set<Id>();
        for(PropStrength__Transaction_Requests__c tr  :mapTr.values()) {
            if(tr.PropStrength__Application_Booking__c != null) {
                bookId.add(tr.PropStrength__Application_Booking__c);
            }
        }
        Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r) FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
        for(Event evt : evtList) {
            if(bookMap.containsKey(mapTr.get(evt.WhatId).PropStrength__Application_Booking__c) && !bookMap.get(mapTr.get(evt.WhatId).PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r.isEmpty()) {
                for(PropStrength__Applicant_Detail__c appDetail : bookMap.get(mapTr.get(evt.WhatId).PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r) {
                    EventTriggerStdController.sendEmail(evt.WhatId, evt.StartDateTime, appDetail.PropStrength__Customer_Name__c, appDetail.PropStrength__Applicant_Email__c);
                }
            }
        }
    }
    
    @Future(Callout=true)
    public static void sendEmail(Id evtWhatId, DateTime evtStartDateTime, String customerName, String customerEmail) {
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> msgList= new List<EmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest()) {
            owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Contact_From_Address_Email limit 1];
        }
        String frmsrc = '/apex/AuthorityLetter?id='+evtWhatId;
        PageReference p1 = new PageReference(frmsrc);
        blob content;
        if(Test.isRunningTest()) { 
            content = blob.valueOf('Unit.Test');
        } else {
            content = p1.getContentAsPDF();
        }
        String formattedTime = '';
        Time timeValue = evtStartDateTime.time();
        
        Integer hours = timeValue.hour();
        Integer minutes = timeValue.minute();
        String amPm = hours < 12 ? 'AM' : 'PM';
        
        if (hours > 12) {
            hours -= 12;
        }
        
        String formattedHours = String.valueOf(hours);
        String formattedMinutes = minutes < 10 ? '0' + String.valueOf(minutes) : String.valueOf(minutes);
        
        formattedTime = formattedHours + ':' + formattedMinutes + amPm;
        
        System.debug(formattedTime);            
        System.debug(content);
        mail.setSubject('Scheduled Site Visit for Your Property with Sobha LLC');
        mail.setplaintextbody('Dear '+customerName+'\n\nWe hope this email finds you well. We are excited to inform you that a site visit for your esteemed property has been successfully scheduled by Sobha LLC. We understand the importance of seeing your property firsthand and are committed to providing you with the best service possible.\n\nSite Visit Details:\nDate:'+ evtStartDateTime.date().format()+'\nTime: '+formattedTime+'\n\nOur team of experts will be on-site to guide you through the property, address any questions you may have, and provide you with a comprehensive understanding of the progress and developments. We believe this visit will offer you a deeper insight into the work that has been done so far and the exceptional quality we uphold.\n\nTo ensure a seamless experience during your site visit, we have attached the necessary authority letter to this email. Kindly review the attached letter as it outlines the essential details and arrangements for your visit.\n\nShould you have any inquiries or if the scheduled date and time pose any inconvenience, please do not hesitate to contact our customer service team. We are more than happy to accommodate any adjustments that may be required.\n\nWe appreciate your trust in Sobha LLC and the opportunity to be a part of your property journey. Our commitment to excellence drives us to deliver the best possible service and create remarkable spaces for our valued customers.\n\nThank you for choosing Sobha LLC. We look forward to welcoming you on [Site Visit Date].\n\n\nBest regards,\nSobha LLC');
        mail.setToAddresses(new List<String>{customerEmail});

        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        
        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        efa1.setFileName('Authority Letter.pdf');
        efa1.setBody(content);   
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
        System.debug(mail);
        emailList.add(mail);
        System.debug(emailList);
        if(emailList != null && emailList.size()>0 ) {
            System.debug(emailList);
            try {
                            Messaging.sendEmail(emailList);

            }
            catch(exception e) {
                System.debug('System.debug');
            }
            EmailMessage newEmail = new EmailMessage();
            newEmail.ToAddress = customerEmail;
            newEmail.Subject = 'Scheduled Site Visit for Your Property with Sobha LLC';
            newEmail.TextBody = mail.getPlainTextBody();
            newEmail.RelatedToId = evtWhatId;
            newEmail.Status = '3';
            msgList.add(newEmail);
            trList.add(new PropStrength__Transaction_Requests__c(Id=evtWhatId, Site_Visit_Email_Sent_to_customer__c=TRUE, Site_Visit_Email_Sent_to_customer_Date__c=System.Today()));
            
        }
        
        if(!msgList.isEmpty()) {
            insert msgList;
        }
        if(!trList.isEmpty()) {
            update trList;
        }
    }
}