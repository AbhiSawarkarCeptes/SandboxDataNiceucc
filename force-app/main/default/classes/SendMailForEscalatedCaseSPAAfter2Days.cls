/*********************************************************************
 * Class Name  :   SendMailForEscalatedCaseSPAAfter2Days
 * Description :   Send Escalated Mail To Manager for SPA Not Sent to the Customer
 * Created Date:   08/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 08/01/2024
 *********************************************************************/
public class SendMailForEscalatedCaseSPAAfter2Days {
    @InvocableMethod
    public static void sendMail(List<PropStrength__Application_Booking__c> appBookRec) {
        try{
            System.debug(appBookRec);
            if(appBookRec != null && !appBookRec.isEmpty()) {
                List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
                List<PropStrength__Application_Booking__c> bookList = [select Id,SPA_Execution_Date__c,CRM_Executive__c, CRM_Executive__r.ManagerId FROM PropStrength__Application_Booking__c where Id =: appBookRec[0].Id];
                if(!bookList.isEmpty()){
                    PropStrength__Application_Booking__c booking = bookList[0];
                    if(booking.CRM_Executive__c != null && booking.CRM_Executive__r.ManagerId != null && booking.SPA_Execution_Date__c == null) {
                        User u = [SELECT Id, Email FROM User WHERE Id = :booking.CRM_Executive__r.ManagerId];
                        if(u.Email != null) {
                            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
                            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                            List<EmailTemplate> templatelist ;
                            Id TempId;
                            String searchTxt = 'Send_Escalated_Case_SPA_Not_Sent';
                            templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
                            if(!templatelist.isEmpty()) {
                                TempId = templatelist[0].id;
                            }
                            
                            emails.setWhatId(booking.Id);
                            emails.setToAddresses( new String[] {u.Email} ); 
                            emails.setTemplateId(TempId);
                            emails.setSaveAsActivity(true); 
                            emails.setTargetObjectId(u.Id);
                            emails.setTreatTargetObjectAsRecipient(false); 
                            emaillist.add(emails);
                            updateBookList.add(new PropStrength__Application_Booking__c(Id=booking.Id, Escalated_Case_Mail_Send__c = true));
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