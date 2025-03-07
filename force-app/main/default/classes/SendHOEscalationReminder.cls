/*********************************************************************
 * Class Name  :   SendHOEscalationReminder
 * Description :   Helper Class of Flow Send HO Escalation Reminder (Flow)
 * Created Date:   21/05/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 21/05/2024
 *********************************************************************/
public with sharing class SendHOEscalationReminder {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<PropStrength__Application_Booking__c> bookId) {
        Id recId = bookId[0].Id;
        if(recId != null) {
            List<PropStrength__Application_Booking__c> record = [SELECT Id, CRM_Executive_Email__c, CRM_Executive__c, 
                                                            CRM_Executive__r.ManagerId, CRM_Executive__r.Manager.Email, 
                                                            Last_HO_Appointment_Reminder_Sent_Count__c  
                                                            FROM PropStrength__Application_Booking__c 
                                                            WHERE Id = :recId AND PropStrength__Active__c = TRUE AND 
                                                            Home_Orientation_Scheduled_Date__c = null];

            if(!record.isEmpty()) {

                List<String> toAddList = new List<String>();
                List<String> ccAddList = new List<String>();

                if(record[0].CRM_Executive__c != null && record[0].CRM_Executive_Email__c != null) {
                    toAddList.add(record[0].CRM_Executive_Email__c);

                    if(record[0].CRM_Executive__r.ManagerId != null && record[0].CRM_Executive__r.Manager.Email != null) {
                        ccAddList.add(record[0].CRM_Executive__r.ManagerId);
                    }
                }

                if(!toAddList.isEmpty()) {
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

                    List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                FROM EmailTemplate 
                                                WHERE DeveloperName =: 'HomeOrientationScheduleAppointment'];
                    String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(toAddList);
                    if(!ccAddList.isEmpty()) {
                        email.setccAddresses(ccAddList);
                    }
                    email.setWhatId(record[0].Id);
                    email.setTargetObjectId(record[0].CRM_Executive__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.setSaveAsActivity(true); 
                    email.setTemplateId(tempId);
                    mails.add(email); 
                    
                    System.debug(mails);
                    try{
                        if(mails != null && mails.size()>0 ) {
                            System.debug(mails);
                            Messaging.sendEmail(mails);
                            Time elevenFiftyThreePM = Time.newInstance(23, 53, 0, 0);
                            DateTime reminderDateTime = DateTime.newInstance(System.Today().addDays(1), elevenFiftyThreePM);
                            PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Id=record[0].Id, HO_Escalation_Reminder_Flow_Date__c = reminderDateTime, Last_HO_Appointment_Reminder_Sent_Count__c = record[0].Last_HO_Appointment_Reminder_Sent_Count__c != null ? record[0].Last_HO_Appointment_Reminder_Sent_Count__c + 1 : 1, Last_HO_Appointment_Reminder_Sent_Date__c = System.Now());
                            update book;
                        }
                    }catch(Exception ex){
                        system.debug('===========Exception ============'+ex.getmessage());
                        system.debug('===========Exception ============'+ex.getlinenumber());
                    }   
                }
            }
        }
    } 
}