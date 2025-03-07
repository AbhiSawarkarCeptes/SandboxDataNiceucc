/*********************************************************************
 * Class Name  :   SendHandoverNoticeReminder
 * Description :   Schedulable Class to send email for Handover notice reminder
 * Created Date:   14/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 14/02/2024
 *********************************************************************/
global class SendHandoverNoticeReminder implements Schedulable {
    public String recordId;

    global void execute(SchedulableContext sc) {
        String recordId = this.recordId;

        System.debug('recordId*****');
        System.debug(recordId);
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        PropStrength__Application_Booking__c book = [SELECT Id, PropStrength__Primary_Customer__c, Handover_Completed__c, 
                                                        (SELECT Id, PropStrength__Applicant_Acc__c, PropStrength__Applicant_Acc__r.Email, 
                                                        PropStrength__Type__c, PropStrength__Applicant_Email__c  
                                                        FROM PropStrength__Applicant_Details__r 
                                                        WHERE PropStrength__Active__c = TRUE) 
                                                    FROM PropStrength__Application_Booking__c WHERE Id = :recordId];

        if(!book.Handover_Completed__c) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<String> sendTo = new List<String>(); 
            List<String> ccList = new List<String>();

            for(PropStrength__Applicant_Detail__c applicant : book.PropStrength__Applicant_Details__r) {
                if(applicant.PropStrength__Type__c == '1st Applicant') {
                    sendTo.add(applicant.PropStrength__Applicant_Email__c);
                }
                if(applicant.PropStrength__Type__c != '1st Applicant') {
                    ccList.add(applicant.PropStrength__Applicant_Email__c);
                }
            }
            
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                    FROM EmailTemplate 
                                                    WHERE DeveloperName =: 'Handover_Notice_Reminder'];
            
            String tempId = '';
            if(!emailTemplate.isEmpty()) {
                tempId = emailTemplate[0].Id;
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(!sendTo.isEmpty()) {
                email.setToAddresses(sendTo);
            }
            if(!ccList.isEmpty()) {
                email.setCcAddresses(ccList);
            }
            
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            email.setWhatId(book.id);
            email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
            email.setTreatTargetObjectAsRecipient(False);
            email.setSaveAsActivity(true);
            email.setTemplateId(tempId);
            mails.add(email); 
            
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    
    public static void scheduleEmail(Id recordId) {
        PropStrength__Application_Booking__c booking = [SELECT Id, Handover_Notice_Sent_Date__c,
                                                        PropStrength__Project__c, PropStrength__Project__r.Handover_Reminder_Notice_Day__c 
                                                        FROM PropStrength__Application_Booking__c WHERE Id = :recordId];

        if (booking != null && booking.PropStrength__Project__r.Handover_Reminder_Notice_Day__c != null) {
            Integer noticeDays = Integer.valueOf(booking.PropStrength__Project__r.Handover_Reminder_Notice_Day__c);
            Date handoverDate = booking.Handover_Notice_Sent_Date__c.date();
            Date futureDate = handoverDate.addDays(noticeDays);

            String cronExp = '0 0 0 ' + futureDate.day() + ' ' + futureDate.month() + ' ? ' + futureDate.year();
            SendHandoverNoticeReminder job = new SendHandoverNoticeReminder();
            job.recordId = String.valueOf(recordId);

            System.schedule('SendHandoverNoticeReminder_' + recordId, cronExp, job);
        } else {
            System.debug('Record Id Not found or Handover_Reminder_Notice_Day__c is null');
            System.debug(recordId);
            System.debug(booking.PropStrength__Project__r.Handover_Reminder_Notice_Day__c);
        }
    }
}