/*********************************************************************
 * Class Name  :   SendReminderAndExpireEmail
 * Description :   Helper Class of Flow Send Reminder And Expire Email (Flow)
 * Created Date:   07/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 07/02/2024
 *********************************************************************/
public with sharing class SendReminderAndExpireEmail {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> bookId) {
        Id mySourceId = bookId[0];
        Map<String, String> toAddressMap = new Map<String, String>();

        List<PropStrength__Application_Booking__c> record = [SELECT Id, Reminder_to_CRM_sent__c, Timings__c, Home_Orientation_Date__c, Slot_Scheduled_Date__c, Handover_Notice_Sent_Date__c, CRM_Executive__r.Name, CRM_Executive__c, CRM_Executive_Email__c, SPA_Executed__c, Pre_Registration_Completed__c, PropStrength__Outstanding_Balance__c, HO_Appointment_Exception__c , Unit_Readiness_Date__c, Unit_Handover_Date__c, Handover_Notice_Sent__c, POA_Email_Address__c, Handover_will_be_taken_by__c, PropStrength__Primary_Customer__c, PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email FROM PropStrength__Application_Booking__c WHERE Id = :mySourceId];
        if(!record.isEmpty()) {
            if(((record[0].SPA_Executed__c && record[0].Pre_Registration_Completed__c && record[0].PropStrength__Outstanding_Balance__c <= 0 && record[0].Home_Orientation_Date__c != null) || record[0].HO_Appointment_Exception__c) && record[0].Unit_Readiness_Date__c != null && record[0].Unit_Handover_Date__c != null && record[0].Handover_Notice_Sent__c && record[0].Handover_Notice_Sent_Date__c != null  && record[0].Slot_Scheduled_Date__c == null && record[0].Timings__c == null) {
                    if(record[0].PropStrength__Primary_Customer__c != null) {
                        toAddressMap.put(record[0].CRM_Executive_Email__c, record[0].CRM_Executive__r.Name);
                        if (!record[0].Reminder_to_CRM_sent__c) {
                            SendReminderAndExpireEmail.sendReminderMail(record[0].Id, toAddressMap);
                        } else {
                            SendReminderAndExpireEmail.sendExpireMail(record[0].Id, toAddressMap);
                        }
                    }
            }
        }
    } 

    @Future(callout=true)
    public static void sendReminderMail(String recId, Map<String, String> toAddressMap) {
        if(recId != null) {
            List<PropStrength__Application_Booking__c> record = [SELECT Id, Timings__c, Slot_Scheduled_Date__c, Handover_Notice_Sent_Date__c, 
                                                                    SPA_Executed__c, Pre_Registration_Completed__c, 
                                                                    CRM_Executive__c, CRM_Executive_Email__c, 
                                                                    PropStrength__Outstanding_Balance__c, HO_Appointment_Exception__c , 
                                                                    Unit_Readiness_Date__c, Unit_Handover_Date__c, Handover_Notice_Sent__c, 
                                                                    POA_Email_Address__c, Handover_will_be_taken_by__c, PropStrength__Primary_Customer__c, 
                                                                    PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email 
                                                                    FROM PropStrength__Application_Booking__c 
                                                                    WHERE Id = :recId AND PropStrength__Active__c = TRUE];
            
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                    FROM EmailTemplate 
                                                    WHERE DeveloperName =: 'Handover_Slot_Update_Reminder'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            Map<Id, PropStrength__Application_Booking__c> bookingListUpdate = new Map<Id,PropStrength__Application_Booking__c>();
            for(String emails : toAddressMap.keySet()) {
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
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
                        Time elevenPM = Time.newInstance(23, 55, 0, 0);
                        DateTime reminderDateTime = DateTime.newInstance(record[0].Handover_Notice_Sent_Date__c.date(), elevenPM);
                        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Id=recId, Reminder_to_CRM_Executive_for_Slot__c=reminderDateTime, Reminder_to_CRM_sent__c = true);
                        if(!bookingListUpdate.containsKey(book.Id)) {
                            bookingListUpdate.put(book.Id, book);
                        }
                    }
                }catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
            if(!bookingListUpdate.isEmpty()) {
                update bookingListUpdate.values();
            }
        }
    }

    @Future(callout=true)
    public static void sendExpireMail(String recId, Map<String, String> toAddressMap) {
        if(recId != null) {
            List<PropStrength__Application_Booking__c> record = [SELECT Id, Timings__c, Slot_Scheduled_Date__c, Handover_Notice_Sent_Date__c, 
                                                                    SPA_Executed__c, Pre_Registration_Completed__c, 
                                                                    CRM_Executive__c, CRM_Executive_Email__c, 
                                                                    PropStrength__Outstanding_Balance__c, HO_Appointment_Exception__c , 
                                                                    Unit_Readiness_Date__c, Unit_Handover_Date__c, Handover_Notice_Sent__c, 
                                                                    POA_Email_Address__c, Handover_will_be_taken_by__c, PropStrength__Primary_Customer__c, 
                                                                    PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email 
                                                                    FROM PropStrength__Application_Booking__c 
                                                                    WHERE Id = :recId AND PropStrength__Active__c = TRUE];
            
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                    FROM EmailTemplate 
                                                    WHERE DeveloperName =: 'Handover_Notice_Expire_Notification'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            Map<Id, PropStrength__Application_Booking__c> bookingListUpdate = new Map<Id,PropStrength__Application_Booking__c>();
            for(String emails : toAddressMap.keySet()) {
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
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
                        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Id=recId, Reminder_to_CRM_Executive_for_Slot__c=null);
                        if(!bookingListUpdate.containsKey(book.Id)) {
                            bookingListUpdate.put(book.Id, book);
                        }
                    }
                }catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
            if(!bookingListUpdate.isEmpty()) {
                update bookingListUpdate.values();
            }
        }
    }
}