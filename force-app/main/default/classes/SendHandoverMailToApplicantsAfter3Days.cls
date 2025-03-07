/*********************************************************************
 * Class Name  :   SendHandoverMailToApplicantsAfter3Days
 * Description :   Helper of Send Reminder For Handover Slot Confirmation In Every 3 Day Flow to send Mail to Applicants after 3 Days For Handover Slot Confirmation
 * Created Date:   06/05/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 06/05/2024
 *********************************************************************/
public class SendHandoverMailToApplicantsAfter3Days {
    @InvocableMethod
    public static void email3Days(List<PropStrength__Application_Booking__c> bookList) {
        List<Id> PrIdList = new List<Id>();
        List<PropStrength__Application_Booking__c> firstBooking = [SELECT ID,Last_Handover_Reminder_Count__c,(SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Name, PropStrength__Applicant_Acc__c 
                                                                    FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = true) 
                                                                    FROM PropStrength__Application_Booking__c where id =: bookList[0].id];
        
        if(!firstBooking.isEmpty() && !firstBooking[0].PropStrength__Applicant_Details__r.isEmpty()){
            PropStrength__Application_Booking__c book = firstBooking[0];
            
            Set<String> emailAddress = new Set<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            
            List<EmailTemplate> templatelist = [SELECT id,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Handover_Slot_Confirmation' limit 1];
            
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
            emails.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
            emails.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
                
                
            if (owea.size() > 0) {
                                emails.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
            emails.setTemplateId(TempId);
            emails.setSaveAsActivity(true); 
            emails.setTargetObjectId(book.PropStrength__Applicant_Details__r[0].PropStrength__Applicant_Acc__c);
            emails.setTreatTargetObjectAsRecipient(false); 
            emaillist.add(emails);

            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                    book.Last_Handover_Reminder_Date__c = System.Today();
                    book.Handover_Reminder_Flow_Date__c = System.Today();
                    book.Last_Handover_Reminder_Count__c = book.Last_Handover_Reminder_Count__c != null ? book.Last_Handover_Reminder_Count__c + 1 : 1;
                    update book;
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
    
   
}