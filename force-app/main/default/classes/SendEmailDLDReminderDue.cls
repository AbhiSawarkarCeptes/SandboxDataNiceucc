/*********************************************************************
 * Class Name  :   SendEmailDLDReminderDue
 * Description :   Send Reminder Mail To Primary Customer for DLD Due for Send DLD Reminder Due Email Daily (Flow)
 * Created Date:   29/12/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 29/12/2023
                        Nishank Manwani 24/07/2024
 *********************************************************************/
public class SendEmailDLDReminderDue {
    @InvocableMethod
    public static void sendMail(List<List<PropStrength__Application_Booking__c>> bookingRecords) {
        try{
            System.debug(bookingRecords);
            if(bookingRecords != null && !bookingRecords.isEmpty()) {
                List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if( !test.isrunningtest())
                    owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

                List<EmailTemplate> templatelist ;
                Id TempId;
                String searchTxt = 'Send_DLD_Reminder_Due';
                templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
                if(!templatelist.isEmpty()) {
                    TempId = templatelist[0].id;
                }
                    
                List<PropStrength__Application_Booking__c> bookList = [SELECT Id,PropStrength__Primary_Customer__c, DLD_Reminder_Count__c, PropStrength__Primary_Customer__r.Email FROM PropStrength__Application_Booking__c WHERE Id IN :bookingRecords[0]];
                if(!bookList.isEmpty()){
                    List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
                    for(PropStrength__Application_Booking__c booking : bookList) {
                        if(booking.PropStrength__Primary_Customer__c != null ) {
                            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                            
                            if (owea.size() > 0) {
                                emails.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            
                            emails.setWhatId(booking.Id);
                            emails.setToAddresses( new String[] {booking.PropStrength__Primary_Customer__r.Email} ); 
                            emails.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
                            emails.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                            emails.setTemplateId(TempId);
                            emails.setSaveAsActivity(true); 
                            emails.setTargetObjectId(booking.PropStrength__Primary_Customer__c);
                            emails.setTreatTargetObjectAsRecipient(false); 
                            emaillist.add(emails);

                            updateBookList.add(new PropStrength__Application_Booking__c(Id=booking.Id, DLD_Fee_Last_Reminder_Date__c = System.now(), DLD_Reminder_Count__c = ((booking.DLD_Reminder_Count__c != null) ? (booking.DLD_Reminder_Count__c + 1) : 1)));
                        }
                    }

                    try{
                        if(emaillist != null && emaillist.size()>0 ) {
                            Messaging.sendEmail(emaillist);

                            if(!updateBookList.isEmpty()) {
                                update updateBookList;
                            }
                        }
                    } catch(Exception ex){
                        system.debug('===========Exception ============'+ex.getmessage());
                        system.debug('===========Exception ============'+ex.getlinenumber());
                    }
                }
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}