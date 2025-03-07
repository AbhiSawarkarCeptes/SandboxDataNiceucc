/*********************************************************************
 * Class Name  :   SendMailToApplicantsAfter2Days
 * Description :   Helper of Send Reminder For SPA Digi Sign In Every 2 Day Flow to send Mail to Applicants after 2 Days For Digi Sign Reminder
 * Created Date:   04/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 04/01/2024
 *********************************************************************/
public class SendMailToApplicantsAfter2Days {
    @InvocableMethod
    public static void email2Days(List<PropStrength__Application_Booking__c> bookList) {
        List<Id> PrIdList = new List<Id>();
        List<PropStrength__Application_Booking__c> firstBooking = [SELECT ID,SPA_Reminder_Count__c,PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c,(SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Name, PropStrength__Applicant_Acc__c 
                                                                    FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = true) 
                                                                    FROM PropStrength__Application_Booking__c where id =: bookList[0].id AND PropStrength__Project__r.Accounts_Executive__c != null];
        
        if(!firstBooking.isEmpty() && !firstBooking[0].PropStrength__Applicant_Details__r.isEmpty()){
            PropStrength__Application_Booking__c book = firstBooking[0];
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            
            if( !test.isrunningtest())
            owea = [SELECT id, DisplayName from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email OR DisplayName =: System.Label.Siniya_Contact_From_Address_Email limit 2];

            Set<String> emailAddress = new Set<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> templatelist = new List<EmailTemplate>();
            
            if(firstBooking[0].PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                templatelist = [SELECT id,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Reminder_Applicants_After_2_Days_Siniya' limit 1];
            } else {
                templatelist = [SELECT id,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Reminder_Applicants_Dg_Sgn_After_2_Days' limit 1];
            }
            
            Id TempId;
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }

            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            List<String> toList = new List<String>();
            emails.setWhatId(book.Id);

            for(PropStrength__Applicant_Detail__c appDetails : book.PropStrength__Applicant_Details__r) {
                if(appDetails.PropStrength__Applicant_Email__c != null) {
                    toList.add(appDetails.PropStrength__Applicant_Email__c);
                }
            }

            if(!toList.isEmpty()) {
                emails.setToAddresses(toList); 
            }

            if (owea.size() > 0) {
                for(OrgWideEmailAddress ow : owea) {
                    if(ow.DisplayName == System.Label.Siniya_Contact_From_Address_Email && book.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                        emails.setOrgWideEmailAddressId(ow.Id);
                    } else {
                        emails.setOrgWideEmailAddressId(ow.Id);
                    }
                }
            }
            emails.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
            emails.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
            emails.setTemplateId(TempId);
            emails.setSaveAsActivity(true); 
            emails.setTargetObjectId(book.PropStrength__Applicant_Details__r[0].PropStrength__Applicant_Acc__c);
            emails.setTreatTargetObjectAsRecipient(false); 
            emaillist.add(emails);

            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                    book.SPA_Reminder_Flow_Date__c = System.Today();
                    book.SPA_Reminder_Count__c = book.SPA_Reminder_Count__c != null ? book.SPA_Reminder_Count__c + 1 : 1;
                    update book;
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
}