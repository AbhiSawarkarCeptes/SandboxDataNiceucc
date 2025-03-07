public class TRHandoverController {
    public String msges {get;set;}
    public String frameSrc {get;set;}
    public String typeCode;
    public String recId;
    public List<PropStrength__Transaction_Requests__c> record;
    public Map<String, String> toAddressMap;
    
    public TRHandoverController() {
        typeCode = ApexPages.currentPage().getParameters().get('type');
        recId = ApexPages.currentPage().getParameters().get('id');
        toAddressMap = new Map<String, String>();
        if(typeCode == 'CompletionNotice') {
            frameSrc = '/apex/CompletionNotice?id='+recId;
        } else if(typeCode == 'AuthorityLetter') {
            frameSrc = '/apex/AuthorityLetter?id='+recId; 
        } else if(typeCode == 'HandoverNotice') {
            frameSrc = '/apex/HandoverNotice?id='+recId; 
        } else if(typeCode == 'HandoverWelcomeLetter') {
            frameSrc = '/apex/HandoverWelcomeLetter?id='+recId; 
        }
        
        if(recId != null) {
            record = [SELECT Id, PropStrength__Application_Booking__c, PropStrength__Status__c, Handover_to_be_done_by__c, PropStrength__Application_Booking__r.POA_Email_Address__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, (SELECT Id, StartDateTime FROM EVENTS ORDER BY CreatedDate DESC) FROM PropStrength__Transaction_Requests__c WHERE Id = :recId AND RecordType.Name = 'Handover'];
            if(!record.isEmpty() && record[0].PropStrength__Application_Booking__c != null) {
                Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r) FROM PropStrength__Application_Booking__c WHERE Id = :record[0].PropStrength__Application_Booking__c]);
                if(!bookMap.isEmpty() && !bookMap.get(record[0].PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appDet : bookMap.get(record[0].PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r) {
                        toAddressMap.put(appDet.PropStrength__Applicant_Email__c, appDet.PropStrength__Customer_Name__c);
                    }
                }
            }
        }
        System.debug('toAddressMap***'+toAddressMap);
    }
    
    public PageReference saveDocFile() {
        if(recId != null && typeCode == 'CompletionNotice') {
            SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'CompletionNotice');
            return new PageReference('/'+recId);
        } else if(recId != null && typeCode == 'AuthorityLetter') {
            SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'AuthorityLetter');
            return new PageReference('/'+recId);
        } else if(recId != null && typeCode == 'HandoverNotice') {
            SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'HandoverNotice');
            return new PageReference('/'+recId);
        } else if(recId != null && typeCode == 'HandoverWelcomeLetter') {
            SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'HandoverWelcomeLetter');
            return new PageReference('/'+recId);
        }
        
        return null;
    }
    
    public PageReference backToRecPage() {
        if(recId != null) {
            return new PageReference('/'+recId);
        }
        return null;
    }
    
    public PageReference recOrInv() {
        if(recId != null && typeCode == 'CompletionNotice') {
            sendCompletionNoticeEmail();
            saveDocFile();
            return new PageReference('/'+recId);
        } else if(recId != null && typeCode == 'AuthorityLetter' && !record[0].Events.isEmpty()) {
            sendAuthorityLetterEmail();
            saveDocFile();
            return new PageReference('/'+recId);
        } else if(recId != null && typeCode == 'HandoverNotice') {
            sendHandoverNoticeEmail();
            saveDocFile();
            return new PageReference('/'+recId);
        } else if(recId != null && typeCode == 'HandoverWelcomeLetter' && record[0].PropStrength__Status__c == 'Request Completed') {
            sendHandoverWelcomeLetterEmail();
            saveDocFile();
            return new PageReference('/'+recId);
        }
        return null;
    }
    
    public void sendCompletionNoticeEmail() {
        if(recId != null && !record.isEmpty()) {
            List<EmailMessage> mailList = new List<EmailMessage>();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
                
            Map<Id,PropStrength__Transaction_Requests__c> trListUp = new Map<Id,PropStrength__Transaction_Requests__c>();
            for(String emails : toAddressMap.keySet()) {
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String frmsrc = '/apex/CompletionNotice?id='+recId;
                PageReference p1 = new PageReference(frmsrc);
                blob content;
                if(Test.isRunningTest()) { 
                    content = blob.valueOf('Unit.Test');
                } else {
                    content = p1.getContentAsPDF();
                }
                System.debug(content);
                mail.setSubject('Property Completion Notice and PDF Attached');
                mail.setplaintextbody('Dear '+toAddressMap.get(emails)+',\n\nWe are pleased to inform you that the construction of your property has been successfully completed. It is with great satisfaction that we share this significant milestone with you.\n\nPlease find attached the Completion Notice PDF, which contains all the necessary details about the completion of your property, final inspections, and relevant documentation.\nWe appreciate your trust in us throughout this journey. Should you have any questions or require further assistance, please do not hesitate to contact our dedicated customer support team.\n\nThank you for choosing us to be part of your property venture. We look forward to your feedback and to serving you in the future.\n\n\nBest regards,\nSobha LLC');
                mail.setToAddresses(new List<String>{emails});
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }


                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setFileName('Completion Notice.pdf');
                efa1.setBody(content);   
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                System.debug(mail);
                emailList.add(mail);
                
                System.debug(emailList);
                try{
                    if(emailList != null && emailList.size()>0 ) {
                        System.debug(emailList);
                        Messaging.sendEmail(emailList);
                        msges = 'Mail sent successfully...';
                        EmailMessage newEmail = new EmailMessage();
                        newEmail.ToAddress = emails;
                        newEmail.Subject = 'Property Completion Notice and PDF Attached';
                        newEmail.TextBody = mail.getPlainTextBody();
                        newEmail.RelatedToId = recId;
                        newEmail.Status = '3';
                        mailList.add(newEmail);
                        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(Id=recId, Completion_Notice_Sent__c=TRUE, Completion_Notice_Sent_Date__c=System.Today());
                        if(!trListUp.containsKey(tr.Id)) {
                            trListUp.put(tr.Id, tr);
                        }
                    }
                }catch(Exception ex){
                    msges = 'Mail not sent...';
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
            if(!mailList.isEmpty()) {
                insert mailList;
            }
            if(!trListUp.isEmpty()) {
                update trListUp.values();
            }
        } else {
            msges = 'Email Can\'t be sent.';
        }
    }
    
    public void sendAuthorityLetterEmail() {
        if(recId != null && !record.isEmpty()) {
            List<EmailMessage> mailList = new List<EmailMessage>();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
                
            Map<Id, PropStrength__Transaction_Requests__c> trListUp = new Map<Id,PropStrength__Transaction_Requests__c>();
            for(String emails : toAddressMap.keySet()) {
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String frmsrc = '/apex/AuthorityLetter?id='+recId;
                PageReference p1 = new PageReference(frmsrc);
                blob content;
                if(Test.isRunningTest()) { 
                    content = blob.valueOf('Unit.Test');
                } else {
                    content = p1.getContentAsPDF();
                }
                String formattedTime = '';
                if(!record[0].Events.isEmpty()) {
                    Time timeValue = record[0].Events[0].StartDateTime.time();
                    
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
                }
                System.debug(content);
                mail.setSubject('Scheduled Site Visit for Your Property with Sobha LLC');
                mail.setplaintextbody('Dear '+toAddressMap.get(emails)+'\n\nWe hope this email finds you well. We are excited to inform you that a site visit for your esteemed property has been successfully scheduled by Sobha LLC. We understand the importance of seeing your property firsthand and are committed to providing you with the best service possible.\n\nSite Visit Details:\nDate:'+ ((record[0].Events.isEmpty()) == FALSE ? record[0].Events[0].StartDateTime.date().format() : '')+'\nTime: '+formattedTime+'\n\nOur team of experts will be on-site to guide you through the property, address any questions you may have, and provide you with a comprehensive understanding of the progress and developments. We believe this visit will offer you a deeper insight into the work that has been done so far and the exceptional quality we uphold.\nTo ensure a seamless experience during your site visit, we have attached the necessary authority letter to this email. Kindly review the attached letter as it outlines the essential details and arrangements for your visit.\nShould you have any inquiries or if the scheduled date and time pose any inconvenience, please do not hesitate to contact our customer service team. We are more than happy to accommodate any adjustments that may be required.\n\nWe appreciate your trust in Sobha LLC and the opportunity to be a part of your property journey. Our commitment to excellence drives us to deliver the best possible service and create remarkable spaces for our valued customers.\n\nThank you for choosing Sobha LLC. We look forward to welcoming you on [Site Visit Date].\n\n\nBest regards,\nSobha LLC');
                mail.setToAddresses(new List<String>{emails});
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
                try{
                    if(emailList != null && emailList.size()>0 ) {
                        System.debug(emailList);
                        Messaging.sendEmail(emailList);
                        msges = 'Mail sent successfully...';
                        EmailMessage newEmail = new EmailMessage();
                        newEmail.ToAddress = emails;
                        newEmail.Subject = 'Scheduled Site Visit for Your Property with Sobha LLC';
                        newEmail.TextBody = mail.getPlainTextBody();
                        newEmail.RelatedToId = recId;
                        newEmail.Status = '3';
                        mailList.add(newEmail);
                        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(Id=recId, Site_Visit_Email_Sent_to_customer__c=TRUE, Site_Visit_Email_Sent_to_customer_Date__c=System.Today());
                        if(!trListUp.containsKey(tr.Id)) {
                            trListUp.put(tr.Id, tr);
                        }
                    }
                }catch(Exception ex){
                    msges = 'Mail not sent...';
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
            if(!mailList.isEmpty()) {
                insert mailList;
            }
            if(!trListUp.isEmpty()) {
                update trListUp.values();
            }
        } else {
            msges = 'Email Can\'t be sent.';
        }
    }
    
    public void sendHandoverNoticeEmail() {
        if(recId != null && !record.isEmpty()) {
            List<EmailMessage> mailList = new List<EmailMessage>();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
                
            Map<Id, PropStrength__Transaction_Requests__c> trListUp = new Map<Id,PropStrength__Transaction_Requests__c>();
            for(String emails : toAddressMap.keySet()) {
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String frmsrc = '/apex/HandoverNotice?id='+recId;
                PageReference p1 = new PageReference(frmsrc);
                blob content;
                if(Test.isRunningTest()) { 
                    content = blob.valueOf('Unit.Test');
                } else {
                    content = p1.getContentAsPDF();
                }
                System.debug(content);
                mail.setSubject('Upcoming Property Handover: Important Notice');
                mail.setplaintextbody('Dear '+toAddressMap.get(emails)+',\n\nWe hope this email finds you well. As we approach the final stages of your property\'s construction, we wanted to share an important update regarding the upcoming handover process.\n\nWe are excited to inform you that the completion of your property is nearing, and we are preparing for the handover to you. This process involves a few crucial steps to ensure that everything is in order and ready for your possession.\n\nIn the next few weeks, our team will be conducting final inspections, quality checks, and any necessary touch-ups to ensure that your property meets the high standards we uphold. Once these steps are completed, we will contact you to schedule the actual handover date.\n\nWe understand that this is an exciting time for you, and we want to ensure that the handover process is smooth and hassle-free. To help you prepare, we will be sending you a comprehensive Handover Guide that outlines the process, documentation, and any other relevant information.\n\nIf you have any questions or concerns leading up to the handover, please don\'t hesitate to reach out to our customer support team. We are here to assist you every step of the way.\n\nThank you for choosing us as your partner in this journey. We look forward to soon handing over your new property to you.\n\n\nBest regards,\nSOBHA LLC');
                mail.setToAddresses(new List<String>{emails});
                
                if(record[0].Handover_to_be_done_by__c == 'POA' && record[0].PropStrength__Application_Booking__r.POA_Email_Address__c != null) {
                    mail.setCcAddresses(new List<String>{record[0].PropStrength__Application_Booking__r.POA_Email_Address__c});   
                }
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }

                
                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setFileName('Handover Notice.pdf');
                efa1.setBody(content);   
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                System.debug(mail);
                emailList.add(mail);
                
                System.debug(emailList);
                try{
                    if(emailList != null && emailList.size()>0 ) {
                        System.debug(emailList);
                        Messaging.sendEmail(emailList);
                        msges = 'Mail sent successfully...';
                        EmailMessage newEmail = new EmailMessage();
                        newEmail.ToAddress = emails;
                        newEmail.Subject = 'Upcoming Property Handover: Important Notice';
                        newEmail.TextBody = mail.getPlainTextBody();
                        newEmail.RelatedToId = recId;
                        newEmail.Status = '3';
                        if(record[0].Handover_to_be_done_by__c == 'POA' && record[0].PropStrength__Application_Booking__r.POA_Email_Address__c != null) {
                            newEmail.CcAddress =record[0].PropStrength__Application_Booking__r.POA_Email_Address__c;   
                        }
                        mailList.add(newEmail);
                        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(Id=recId, Handover_Notice_Sent__c=TRUE, Handover_Notice_Sent_Date__c=System.Today());
                        if(!trListUp.containsKey(tr.Id)) {
                            trListUp.put(tr.Id, tr);
                        }
                    }
                }catch(Exception ex){
                    msges = 'Mail not sent...';
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
            if(!mailList.isEmpty()) {
                insert mailList;
            }
            if(!trListUp.isEmpty()) {
                update trListUp.values();
            }
        } else {
            msges = 'Email Can\'t be sent.';
        }
    }
    
    public void sendHandoverWelcomeLetterEmail() {
        if(recId != null && !record.isEmpty()) {
            List<EmailMessage> mailList = new List<EmailMessage>();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
                
            Map<Id, PropStrength__Transaction_Requests__c> trListUp = new Map<Id,PropStrength__Transaction_Requests__c>();
            Map<Id, PropStrength__Application_Booking__c> bookListUp = new Map<Id,PropStrength__Application_Booking__c>();
            for(String emails : toAddressMap.keySet()) {
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String frmsrc = '/apex/HandoverWelcomeLetter?id='+recId;
                PageReference p1 = new PageReference(frmsrc);
                blob content;
                if(Test.isRunningTest()) { 
                    content = blob.valueOf('Unit.Test');
                } else {
                    content = p1.getContentAsPDF();
                }
                System.debug(content);
                mail.setSubject('Welcome to Your New Home: A Heartfelt Congratulations');
                mail.setplaintextbody('Dear '+toAddressMap.get(emails)+',\n\nWarm greetings from Sobha LLC! We are absolutely delighted to extend our warmest congratulations to you on the successful completion of your property\'s handover.\n\nIt brings us immense joy to officially welcome you to your new home. This moment marks the culmination of months of hard work, dedication, and anticipation. Your property is now more than just a construction; it\'s a place where memories will be created, dreams will be realized, and milestones will be celebrated.\n\nWe trust that you\'ll find every corner of your new home meticulously crafted to reflect our commitment to quality, design, and comfort. It\'s now your canvas to make uniquely yours, and we\'re thrilled to be a part of your journey.\n\nAs you settle in, we\'re here to assist you with any questions or needs you may have. Our customer support team is available to address any inquiries or offer guidance.\n\nWe hope your time here is filled with joy, warmth, and the fulfillment of cherished aspirations. Once again, welcome to your new home, and thank you for choosing Sobha LLC to be a part of this special chapter in your life.\n\nWishing you countless happy moments ahead.\n\n\nWarm regards,\nSobha LLC');
                mail.setToAddresses(new List<String>{emails});
                
                if(record[0].Handover_to_be_done_by__c == 'POA' && record[0].PropStrength__Application_Booking__r.POA_Email_Address__c != null) {
                    mail.setCcAddresses(new List<String>{record[0].PropStrength__Application_Booking__r.POA_Email_Address__c});   
                }
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }


                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setFileName('Handover Welcome Letter.pdf');
                efa1.setBody(content);   
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                System.debug(mail);
                emailList.add(mail);
                
                System.debug(emailList);
                try{
                    if(emailList != null && emailList.size()>0 ) {
                        System.debug(emailList);
                        Messaging.sendEmail(emailList);
                        msges = 'Mail sent successfully...';
                        EmailMessage newEmail = new EmailMessage();
                        newEmail.ToAddress = emails;
                        newEmail.Subject = 'Welcome to Your New Home: A Heartfelt Congratulations';
                        newEmail.TextBody = mail.getPlainTextBody();
                        newEmail.RelatedToId = recId;
                        newEmail.Status = '3';
                        if(record[0].Handover_to_be_done_by__c == 'POA' && record[0].PropStrength__Application_Booking__r.POA_Email_Address__c != null) {
                            newEmail.CcAddress =record[0].PropStrength__Application_Booking__r.POA_Email_Address__c;   
                        }
                        mailList.add(newEmail);
                        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(Id=recId, Handover_Completed__c=TRUE, Handover_WL_Sent_Date__c=System.Today(), Handover_Completed_Date__c = System.Today());
                        if(!trListUp.containsKey(tr.Id)) {
                            trListUp.put(tr.Id, tr);
                        }
                        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Id=record[0].PropStrength__Application_Booking__c, Handover_Completed__c = TRUE);
                        if(!bookListUp.containsKey(book.Id)) {
                            bookListUp.put(book.Id, book);
                        }
                    }
                }catch(Exception ex){
                    msges = 'Mail not sent...';
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
            if(!mailList.isEmpty()) {
                insert mailList;
            }
            if(!trListUp.isEmpty()) {
                update trListUp.values();
            }
            if(!bookListUp.isEmpty()) {
                update bookListUp.values();
            }
        } else {
            msges = 'Email Can\'t be sent.';
        }
    }
}