/*********************************************************************
 * Class Name  :   SendBulkHandoverNotice
 * Description :   Helper Class of Flow Send Bulk Handover Notice (Flow)
 * Created Date:   07/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 07/02/2024
 *********************************************************************/
public class SendBulkHandoverNotice {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> towerId) {
        Id mySourceId = towerId[0];
        Map<String, String> toAddressMap = new Map<String, String>();

        List<PropStrength__Tower__c> towerList = [SELECT Id, (SELECT Id FROM PropStrength__Properties__r) 
                                        FROM PropStrength__Tower__c WHERE Id = :mySourceId];
        if(!towerList.isEmpty() && !towerList[0].PropStrength__Properties__r.isEmpty()) {
            Set<Id> propId = new Set<Id>();

            for(PropStrength__Property__c prop : towerList[0].PropStrength__Properties__r) {
                propId.add(prop.Id);
            }

            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, SPA_Executed__c, Pre_Registration_Completed__c, 
                                                                    PropStrength__Outstanding_Balance__c, HO_Appointment_Exception__c , Home_Orientation_Date__c, 
                                                                    Unit_Readiness_Date__c, Unit_Handover_Date__c, Handover_Notice_Sent__c, 
                                                                    POA_Email_Address__c, Handover_will_be_taken_by__c, PropStrength__Primary_Customer__c, 
                                                                    PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email 
                                                                    FROM PropStrength__Application_Booking__c 
                                                                    WHERE PropStrength__Property__c IN :propId AND PropStrength__Active__c = TRUE];
            
            if(!bookList.isEmpty()) {
                for(PropStrength__Application_Booking__c record : bookList) {
                    if(((record.SPA_Executed__c && record.Pre_Registration_Completed__c && record.PropStrength__Outstanding_Balance__c <= 0 && record.Home_Orientation_Date__c!= null) || record.HO_Appointment_Exception__c) && record.Unit_Readiness_Date__c != null && record.Unit_Handover_Date__c != null && !record.Handover_Notice_Sent__c) {
                            if(record.PropStrength__Primary_Customer__c != null) {
                                toAddressMap.put(record.PropStrength__Primary_Customer__r.Email, record.PropStrength__Primary_Customer__r.Name);
                                SendBulkHandoverNotice.sendHandoverNoticeEmail(toAddressMap, record.Id);
                            }
                    }
                }
            }
        }
    }

    @Future(callout=true)
    public static void sendHandoverNoticeEmail(Map<String, String> toAddressMap, String recId) {
        if(recId != null) {
            List<PropStrength__Application_Booking__c> record = [SELECT Id, SPA_Executed__c, Pre_Registration_Completed__c, 
                                                                    CRM_Executive__c, CRM_Executive_Email__c, 
                                                                    PropStrength__Outstanding_Balance__c, HO_Appointment_Exception__c , 
                                                                    Unit_Readiness_Date__c, Unit_Handover_Date__c, Handover_Notice_Sent__c, 
                                                                    POA_Email_Address__c, Handover_will_be_taken_by__c, PropStrength__Primary_Customer__c, 
                                                                    PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email 
                                                                    FROM PropStrength__Application_Booking__c 
                                                                    WHERE Id = :recId AND PropStrength__Active__c = TRUE];
            List<EmailMessage> mailList = new List<EmailMessage>();
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                    FROM EmailTemplate 
                                                    WHERE DeveloperName =: 'Handover_Notice_Sent_Update_Slot_Details'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
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
                mail.setSubject('Upcoming Property Handover: Important Notice');
                mail.setplaintextbody('Dear '+toAddressMap.get(emails)+',\n\nWe hope this email finds you well. As we approach the final stages of your property\'s construction, we wanted to share an important update regarding the upcoming handover process.\n\nWe are excited to inform you that the completion of your property is nearing, and we are preparing for the handover to you. This process involves a few crucial steps to ensure that everything is in order and ready for your possession.\n\nIn the next few weeks, our team will be conducting final inspections, quality checks, and any necessary touch-ups to ensure that your property meets the high standards we uphold. Once these steps are completed, we will contact you to schedule the actual handover date.\n\nWe understand that this is an exciting time for you, and we want to ensure that the handover process is smooth and hassle-free. To help you prepare, we will be sending you a comprehensive Handover Guide that outlines the process, documentation, and any other relevant information.\n\nIf you have any questions or concerns leading up to the handover, please don\'t hesitate to reach out to our customer support team. We are here to assist you every step of the way.\n\nThank you for choosing us as your partner in this journey. We look forward to soon handing over your new property to you.\n\n\nBest regards,\nSOBHA LLC');
                mail.setToAddresses(new List<String>{emails});
                // Set the CC email address
                String[] ccAddresses = new String[] {'helpdesk@sobharealty.com'};
                    mail.setCcAddresses(ccAddresses);
                // Set the BCC email address
                String[] bccAddresses = new String[] {'sfnotifications@sobharealty.com'};
                    mail.setBccAddresses(bccAddresses);
                
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
                emailList.add(email); 
                
                System.debug(emailList);
                try{
                    if(emailList != null && emailList.size()>0 ) {
                        System.debug(emailList);
                        Messaging.sendEmail(emailList);
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
        }
    }
}