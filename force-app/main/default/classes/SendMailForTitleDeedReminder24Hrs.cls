/*********************************************************************
 * Class Name  :   SendMailForTitleDeedReminder24Hrs
 * Description :   Send Mail For Title Deed Reminder in every 24 Hours for the Title Deed Reminder (Flow)
 * Created Date:   17/04/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 17/04/2024
 *********************************************************************/
public class SendMailForTitleDeedReminder24Hrs {
    @InvocableMethod
    public static void sendMail(List<PropStrength__Application_Booking__c> appBookRec) {
        try{
            System.debug(appBookRec);
            if(appBookRec != null && !appBookRec.isEmpty()) {
                List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
                List<PropStrength__Application_Booking__c> bookList = [select Id,PropStrength__Project__r.DLD_Executive__c, (SELECT Id, Title_Deed_Uploaded__c FROM PropStrength__Transaction_Request__r WHERE RecordType.Name = 'Title Deed Process' ORDER BY CreatedDate DESC) FROM PropStrength__Application_Booking__c where Id =: appBookRec[0].Id];
                if(!bookList.isEmpty()){
                    PropStrength__Application_Booking__c booking = bookList[0];
                    if(booking.PropStrength__Project__r.DLD_Executive__c != null && !booking.PropStrength__Transaction_Request__r.isEmpty() && !booking.PropStrength__Transaction_Request__r[0].Title_Deed_Uploaded__c) {
                        List<Task> tk = [SELECT Id FROM Task WHERE WhatId = :booking.PropStrength__Transaction_Request__r[0].Id AND Subject = 'Generate Title Deed and Upload'];
                        User u = [SELECT Id, Email FROM User WHERE Id = :booking.PropStrength__Project__r.DLD_Executive__c];
                        if(!tk.isEmpty() && u.Email != null) {
                            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
                            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                            List<EmailTemplate> templatelist ;
                            Id TempId;
                            String searchTxt = 'Send_Title_Deed_Reminder_24_Hrs';
                            templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
                            if(!templatelist.isEmpty()) {
                                TempId = templatelist[0].id;
                            }
                            
                            emails.setWhatId(tk[0].Id);
                            emails.setToAddresses( new String[] {u.Email} ); 
                            emails.setTemplateId(TempId);
                            emails.setTargetObjectId(u.Id);
                            emails.setTreatTargetObjectAsRecipient(false); 
                            emaillist.add(emails);
                            updateBookList.add(new PropStrength__Application_Booking__c(Id=booking.Id, Title_Deed_Reminder_24_Hr__c = System.Today().addDays(1)));
                            try{
                                if(emaillist != null && emaillist.size()>0 ) {
                                    Messaging.sendEmail(emaillist);
                                    update updateBookList;
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