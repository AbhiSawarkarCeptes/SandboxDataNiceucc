public class BookingHandoverController {
    public String msges {get;set;}
    public String frameSrc {get;set;}
    public String typeCode;
    public String recId;
    public List<PropStrength__Application_Booking__c> record;
    public Map<String, String> toAddressMap;
    public Boolean showPage {get;set;}
    public PropStrength__Application_Booking__c appbObj      {get;set;}
    public List<PropStrength__Applicant_Detail__c> applicantList {get;set;}
    public PropStrength__Applicant_Detail__c appDetail {get;set;}
    public PropStrength__Applicant_Detail__c appDetailSec {get;set;}
    public PropStrength__Applicant_Detail__c appDetailThir {get;set;}
    public PropStrength__Applicant_Detail__c appDetailForth {get;set;}
    public PropStrength__Applicant_Detail__c appDetailFifth {get;set;}
    public List<PropStrength__Applicant_Detail__c> DetailLst {get;set;}
    
    
    public BookingHandoverController() {
        typeCode = ApexPages.currentPage().getParameters().get('type');
        recId = ApexPages.currentPage().getParameters().get('id');
        toAddressMap = new Map<String, String>();
        appbObj = new PropStrength__Application_Booking__c();
        DetailLst = new list<PropStrength__Applicant_Detail__c>();
        applicantList = new list<PropStrength__Applicant_Detail__c>();
        appDetail = new PropStrength__Applicant_Detail__c();
        appDetailSec = new PropStrength__Applicant_Detail__c();
        appDetailThir = new PropStrength__Applicant_Detail__c();
        appDetailForth = new PropStrength__Applicant_Detail__c();
        appDetailFifth = new PropStrength__Applicant_Detail__c();
        
        if(recId != null) {
            record = [SELECT Id, CRM_Executive__c,PropStrength__Applicant_Email__c,PropStrength__Property_Name__c,PropStrength__Project__r.Name, CRM_Executive_Email__c, SPA_Executed__c, Pre_Registration_Completed__c, PropStrength__Outstanding_Balance__c, HO_Appointment_Exception__c , Home_Orientation_Date__c, Unit_Readiness_Date__c, Unit_Handover_Date__c, Handover_Notice_Sent__c, POA_Email_Address__c, Handover_will_be_taken_by__c, PropStrength__Primary_Customer__c, PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email FROM PropStrength__Application_Booking__c WHERE Id = :recId];
            if(!record.isEmpty()) {
                appbObj = record[0];
                if(((record[0].SPA_Executed__c && record[0].Pre_Registration_Completed__c && record[0].PropStrength__Outstanding_Balance__c <= 0 && record[0].Home_Orientation_Date__c != null) || record[0].HO_Appointment_Exception__c) && record[0].Unit_Readiness_Date__c != null && record[0].Unit_Handover_Date__c != null && !record[0].Handover_Notice_Sent__c) {
                        if(record[0].PropStrength__Primary_Customer__c != null) {
                            toAddressMap.put(record[0].PropStrength__Primary_Customer__r.Email, record[0].PropStrength__Primary_Customer__r.Name);
                            if(typeCode == 'HandoverNotice') {
                                frameSrc = '/apex/HandoverNotice?id='+recId; 
                                showPage = true;
                            }
                        }
                } else {
                    showPage = false;
                    if(!(record[0].SPA_Executed__c && record[0].Pre_Registration_Completed__c && record[0].PropStrength__Outstanding_Balance__c <= 0 && record[0].Home_Orientation_Date__c != null)) {
                        if(!record[0].SPA_Executed__c) {
                            msges = 'SPA is not checked';
                            if(!record[0].HO_Appointment_Exception__c) {
                                msges = 'SPA is not checked OR HO Appointment Exception is not checked';
                            }
                        } else if(!record[0].Pre_Registration_Completed__c) {
                            msges = 'Pre Registration Completed is not checked';
                            if(!record[0].HO_Appointment_Exception__c) {
                                msges = 'Pre Registration Completed is not checked OR HO Appointment Exception is not checked';
                            }
                        } else if(record[0].PropStrength__Outstanding_Balance__c > 0) {
                            msges = 'Outstanding balance is greater than zero';
                            if(!record[0].HO_Appointment_Exception__c) {
                                msges = 'Outstanding balance is greater than zero OR HO Appointment Exception is not checked';
                            }
                        } else if(record[0].Home_Orientation_Date__c == null) {
                            msges = 'Please enter date in Home Orientation Date';
                            if(!record[0].HO_Appointment_Exception__c) {
                                msges = 'Please enter date in Home Orientation Date OR HO Appointment Exception is not checked';
                            }
                        }
                    } 

                    if(record[0].Unit_Readiness_Date__c == null) {
                        msges = 'Please enter date in Unit Readiness Date';
                    } else if(record[0].Unit_Handover_Date__c == null) {
                        msges = 'Please enter date in Unit Handover Date';
                    } else if(record[0].Handover_Notice_Sent__c) {
                        msges = 'Handover notice is already sent';
                    }
                }
            }
        }
        System.debug('toAddressMap***'+toAddressMap);
        //List<PropStrength__Applicant_Detail__c> DetailLst = new List<PropStrength__Applicant_Detail__c>();
        if(appbObj.id != null){
            DetailLst = [Select id, Name,PropStrength__Applicant_Acc__r.Salutation,PropStrength__Account_Name__c,PropStrength__Applicant_Acc__r.Name,PropStrength__Applicant_Acc__r.FirstName,PropStrength__Applicant_Acc__r.Mailing_City__c  ,PropStrength__Applicant_Acc__r.MailingStreet, PropStrength__Applicant_Acc__r.MailingCity, PropStrength__Applicant_Acc__r.MailingState,PropStrength__Applicant_Acc__r.PropStrength__Account_Type__c,
                         PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Active__c,PropStrength__Applicant_Acc__r.MailingCountry, PropStrength__Applicant_Acc__r.MailingPostalCode From PropStrength__Applicant_Detail__c Where PropStrength__Application__c =: appbObj.id AND PropStrength__Active__c=true];
            
            if(DetailLst != null && DetailLst.size()>0){
                for(PropStrength__Applicant_Detail__c app : DetailLst){
                    applicantList.add(app);
                    
                    if(app.PropStrength__Type__c == '1st Applicant' && app.PropStrength__Active__c ==True){
                        appDetail = app;
                    }
                    if(app.PropStrength__Type__c == '2nd Applicant' && app.PropStrength__Active__c ==True){
                        appDetailSec = app;
                    }                
                    if(app.PropStrength__Type__c == '3rd Applicant' && app.PropStrength__Active__c ==True){
                        appDetailThir = app;
                    }
                    if(app.PropStrength__Type__c == '4th Applicant' && app.PropStrength__Active__c ==True){
                        appDetailForth = app;
                    }
                    if(app.PropStrength__Type__c == '5th Applicant' && app.PropStrength__Active__c ==True){
                        appDetailFifth = app;
                    }
                }
            } 
        }
    }
    
    public PageReference saveDocFile() {
        if(recId != null && typeCode == 'HandoverNotice') {
            SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'HandoverNotice');
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
        if(recId != null && typeCode == 'HandoverNotice') {
            sendHandoverNoticeEmail();
            saveDocFile();
            return new PageReference('/'+recId);
        }
        return null;
    }
    
    public void sendHandoverNoticeEmail() {
        if(recId != null && !record.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                    FROM EmailTemplate 
                                                    WHERE DeveloperName =: 'Handover_Notice_Sent_Update_Slot_Details'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'helpdesk@sobharealty.com' AND IsVerified = true LIMIT 1];  
            List<EmailMessage> mailList = new List<EmailMessage>();
            List<String> sendTo = new List<String>();
            for(PropStrength__Applicant_Detail__c appBook : DetailLst){
                if(appBook.PropStrength__Applicant_Email__c != null){                        
                    sendTo.add(appBook.PropStrength__Applicant_Email__c);
                }
            }
            Map<Id, PropStrength__Application_Booking__c> bookingListUpdate = new Map<Id,PropStrength__Application_Booking__c>();
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
                String PropertyName = record[0].PropStrength__Property_Name__c;
                String ProjectName = record[0].PropStrength__Project__r.Name;
                String aplicant1 = appDetail.PropStrength__Applicant_Acc__r.Name != null ? appDetail.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetail.PropStrength__Applicant_Acc__r.Name : '';
                
                String aplicant2 = appDetailSec.PropStrength__Applicant_Acc__r.Name != null ? ' & ' + appDetailSec.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetailSec.PropStrength__Applicant_Acc__r.Name : '';
                
                String aplicant3 = appDetailThir.PropStrength__Applicant_Acc__r.Name != null ? ' & ' + appDetailThir.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetailThir.PropStrength__Applicant_Acc__r.Name : '';
                
                String aplicant4 = appDetailForth.PropStrength__Applicant_Acc__r.Name != null ? ' & ' + appDetailForth.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetailForth.PropStrength__Applicant_Acc__r.Name : '';
                
                String aplicant5 = appDetailFifth.PropStrength__Applicant_Acc__r.Name != null ? ' & ' + appDetailFifth.PropStrength__Applicant_Acc__r.Salutation + ' ' + appDetailFifth.PropStrength__Applicant_Acc__r.Name : '';
                System.debug('====aplicant1======='+aplicant1);
                System.debug('====aplicant2======='+aplicant2);
                mail.setSubject('Handover Notice - ' +PropertyName+ ' - ' +ProjectName);
                //mail.setplaintextbody('Dear '+toAddressMap.get(emails)+',\n\nWe hope this email finds you well. As we approach the final stages of your property\'s construction, we wanted to share an important update regarding the upcoming handover process.\n\nWe are excited to inform you that the completion of your property is nearing, and we are preparing for the handover to you. This process involves a few crucial steps to ensure that everything is in order and ready for your possession.\n\nIn the next few weeks, our team will be conducting final inspections, quality checks, and any necessary touch-ups to ensure that your property meets the high standards we uphold. Once these steps are completed, we will contact you to schedule the actual handover date.\n\nWe understand that this is an exciting time for you, and we want to ensure that the handover process is smooth and hassle-free. To help you prepare, we will be sending you a comprehensive Handover Guide that outlines the process, documentation, and any other relevant information.\n\nIf you have any questions or concerns leading up to the handover, please don\'t hesitate to reach out to our customer support team. We are here to assist you every step of the way.\n\nThank you for choosing us as your partner in this journey. We look forward to soon handing over your new property to you.\n\n\nBest regards,\nSOBHA LLC');
                Date handoverDate = record[0].Unit_Handover_Date__c;
                DateTime handoverDateTime = DateTime.newInstance(handoverDate.year(), handoverDate.month(), handoverDate.day(), 0, 0, 0);
                String formattedDate = handoverDateTime.format('dd-MM-yyyy');
                System.debug('====formattedDate======='+formattedDate);
                String emailBody = 'Dear ' + aplicant1 + aplicant2 + aplicant3 + aplicant4 + aplicant5 +',<br/><br/>' +
                    'Greetings from Sobha Realty!<br/><br/>' +
                    'This is in reference to the notification regarding the handover of the property issued to you. Please note that your unit will be ready for handover on ' + formattedDate + ' or on the date that you take actual possession of the Property, whichever is earlier.<br/><br/>' +
                    'Please find attached the Handover Notice for your unit. Accordingly, you are requested to kindly settle/fulfill all obligations as per your Sale and Purchase Agreement (SPA), and the Completion Notice on or before the Handover Date to enable us to handover possession of your Property. Request you to kindly take prior appointment basis available slots for the handover to ensure effective handover process.<br/><br/>' +
                    'If you have authorized a third party or representative to take possession of your Property, please ensure that you have granted a valid original power of attorney attested by the Notary Public (“POA”) and if such POA is executed outside UAE, then it needs to be attested by the UAE Embassy in the relevant country and the UAE Ministry of Foreign Affairs, and we will need to see the original POA at the time of handover.<br/><br/>' +
                    'We look forward to welcoming you into the proud community of property owners at Sobha Hartland. Should you require any further assistance, feel free to write to us at helpdesk@sobharealty.com or contact us on 800 SOBHA (76242).<br/><br/>' +
                    'Thanks and regards,\nCRM Team,\nSOBHA Realty.<br/><br/>' +
                    '<a href="https://www.facebook.com/SobhaRealty/" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZAf&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;' +
                    '<a href="https://www.instagram.com/sobharealty/" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZH7&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;' +
                    '<a href="https://www.linkedin.com/company/sobharealty/" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZFV&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;' +
                    '<a href="https://twitter.com/SobhaRealty" style="width:1%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZ2b&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;' +
                    '<a href="https://www.youtube.com/channel/UCKIR9isiNyYq1T0GSnIUyHQ" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZCH&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;' +
                    '<a href="https://www.sobharealty.com/" style="color:black;">www.sobharealty.com</a><br/><br/>' +
                    '<a href="https://www.sobharealty.com/"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZ0z&oid=00D3N0000000e7H" style="width:50%;"></img></a>';
                
                mail.setHtmlBody(emailBody);
                System.debug('====emailBody======='+emailBody);
                mail.setToAddresses(new List<String>{emails});
                System.debug('====sendTo======='+sendTo);
                System.debug('====sendTo==size====='+sendTo.size());
                mail.setToAddresses(sendTo);
                mail.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
                mail.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                if(!owea.isEmpty()) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }
                if((record[0].Handover_will_be_taken_by__c == 'POA – Owner' || record[0].Handover_will_be_taken_by__c == 'POA – Company') && record[0].POA_Email_Address__c != null) {
                    mail.setCcAddresses(new List<String>{record[0].POA_Email_Address__c});   
                }
                
                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setFileName('Handover Notice.pdf');
                efa1.setBody(content);   
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                System.debug(mail);
                emailList.add(mail);

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{record[0].CRM_Executive_Email__c});
                email.setWhatId(record[0].id);
                email.setTargetObjectId(record[0].CRM_Executive__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.setSaveAsActivity(true); 
                email.setTemplateId(tempId);
                if(!owea.isEmpty()) {
                    email.setOrgWideEmailAddressId(owea[0].Id);
                }
                emailList.add(email); 
                
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
                        if((record[0].Handover_will_be_taken_by__c == 'POA – Owner' || record[0].Handover_will_be_taken_by__c == 'POA – Company') && record[0].POA_Email_Address__c != null) {
                            newEmail.CcAddress =record[0].POA_Email_Address__c;   
                        }
                        mailList.add(newEmail);
                        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Id=recId, Handover_Notice_Sent__c=TRUE, Handover_Notice_Sent_Date__c=System.Now());
                        if(!bookingListUpdate.containsKey(book.Id)) {
                            bookingListUpdate.put(book.Id, book);
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
            if(!bookingListUpdate.isEmpty()) {
                update bookingListUpdate.values();
            }
        } else {
            msges = 'Email Can\'t be sent.';
        }
    }
}