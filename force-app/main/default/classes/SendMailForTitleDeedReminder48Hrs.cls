/*********************************************************************
 * Class Name  :   SendMailForTitleDeedReminder48Hrs
 * Description :   Send Mail For Title Deed Reminder in every 48 Hours for the Title_Deed_Reminder_48_Hours (Flow)
 * Created Date:   15/05/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 15/05/2024
 *********************************************************************/
public class SendMailForTitleDeedReminder48Hrs {
    @InvocableMethod
    public static void sendMail(List<PropStrength__Transaction_Requests__c> trRec) {
        try{
            System.debug(trRec);
            if(trRec != null && !trRec.isEmpty()) {
                Id bookId = [SELECT Id, PropStrength__Application_Booking__c FROM PropStrength__Transaction_Requests__c WHERE Id = :trRec[0].Id].PropStrength__Application_Booking__c;
                List<PropStrength__Application_Booking__c> appBookRec  = new List<PropStrength__Application_Booking__c>{new PropStrength__Application_Booking__c(Id=bookId)};

                List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
                List<PropStrength__Transaction_Requests__c> updateTrList = new List<PropStrength__Transaction_Requests__c>();
                List<PropStrength__Application_Booking__c> bookList = [SELECT Id,PropStrength__Primary_Customer__c, (SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = true), (SELECT Id, Customer_Signed_DSR_Uploaded__c FROM PropStrength__Transaction_Request__r WHERE RecordType.Name = 'Title Deed Process' ORDER BY CreatedDate DESC) FROM PropStrength__Application_Booking__c where Id =: appBookRec[0].Id];

                if(!bookList.isEmpty()){
                    PropStrength__Application_Booking__c booking = bookList[0];
                    if(!booking.PropStrength__Applicant_Details__r.isEmpty() && !booking.PropStrength__Transaction_Request__r.isEmpty() && !booking.PropStrength__Transaction_Request__r[0].Customer_Signed_DSR_Uploaded__c) {
                        List<String> toAdd = new List<String>();
                        for(PropStrength__Applicant_Detail__c appDet : booking.PropStrength__Applicant_Details__r) {
                            if(appDet.PropStrength__Applicant_Email__c != null) {
                                toAdd.add(appDet.PropStrength__Applicant_Email__c);
                            }
                        }
                        if(!toAdd.isEmpty()) {

                            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
                            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                            if( !test.isrunningtest())
                                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
                                
                                
                            if (owea.size() > 0) {
                                                emails.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            List<EmailTemplate> templatelist ;
                            Id TempId;
                            String searchTxt = 'Send_Title_Deed_Reminder_48_Hrs';
                            templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
                            if(!templatelist.isEmpty()) {
                                TempId = templatelist[0].id;
                            }
                            
                            emails.setWhatId(bookId);
                            emails.setToAddresses(toAdd); 
                            emails.setTemplateId(TempId);
                            emails.setTargetObjectId(bookList[0].PropStrength__Primary_Customer__c);
                            emails.setTreatTargetObjectAsRecipient(false); 
                            emaillist.add(emails);
                            updateBookList.add(new PropStrength__Application_Booking__c(Id=booking.Id, Last_Title_Deed_Reminder_Date__c = System.Today()));
                            updateTrList.add(new PropStrength__Transaction_Requests__c(Id=trRec[0].Id, Title_Deed_Reminder_48_Hours__c = System.Today()));
                            try{
                                if(emaillist != null && emaillist.size()>0 ) {
                                    Messaging.sendEmail(emaillist);
                                    update updateBookList;
                                    update updateTrList;
                                }
                            } catch(Exception ex){
                                system.debug('===========Exception ============'+ex.getmessage());
                                system.debug('===========Exception ============'+ex.getlinenumber());
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}