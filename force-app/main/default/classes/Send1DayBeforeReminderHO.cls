/*********************************************************************
 * Class Name  :   Send1DayBeforeReminderHO
 * Description :   Helper Class of Flow Send_1_day_before_Home_orientation_reminder (Flow)
 * Created Date:   20/05/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 20/05/2024
 *********************************************************************/
public with sharing class Send1DayBeforeReminderHO {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<PropStrength__Application_Booking__c> bookId) {
        Id recId = bookId[0].Id;
        if(recId != null) {
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                 owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];


            List<PropStrength__Application_Booking__c> record = [SELECT Id, PropStrength__Primary_Customer__c, 
                                                            (SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE)   
                                                            FROM PropStrength__Application_Booking__c 
                                                            WHERE Id = :recId AND PropStrength__Active__c = TRUE];

            List<String> toAddList = new List<String>();
            for(PropStrength__Applicant_Detail__c appDet : record[0].PropStrength__Applicant_Details__r) {
                toAddList.add(appDet.PropStrength__Applicant_Email__c);
            }
            
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                    FROM EmailTemplate 
                                                    WHERE DeveloperName =: 'Send_1_Day_Before_Reminder_HO'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddList);
            email.setWhatId(record[0].id);
            email.setTargetObjectId(record[0].PropStrength__Primary_Customer__c);
            email.setTreatTargetObjectAsRecipient(False);
            email.setSaveAsActivity(true); 
            email.setTemplateId(tempId);
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            emailList.add(email); 
            
            System.debug(emailList);
            try{
                if(emailList != null && emailList.size()>0 ) {
                    System.debug(emailList);
                    Messaging.sendEmail(emailList);
                }
            }catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }   
        }
    } 
}