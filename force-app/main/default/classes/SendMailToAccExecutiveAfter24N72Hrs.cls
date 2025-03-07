/*********************************************************************
 * Class Name  :   SendMailToAccExecutiveAfter24N72Hrs
 * Description :   Helper of Send Mail To Account Executive After 24 Hours Flow to send Mail to Account Executive after 24 Hours and 72 Hours of Booking Signed Date
 * Created Date:   04/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 04/01/2024
 *********************************************************************/
public class SendMailToAccExecutiveAfter24N72Hrs {
    @InvocableMethod
    public static void email24Hr72Hr(List<PropStrength__Application_Booking__c> bookList) {
        List<Id> PrIdList = new List<Id>();
        List<PropStrength__Application_Booking__c> firstBooking = [SELECT ID,PropStrength__Project__c,PropStrength__Project__r.Accounts_Executive__r.Email
                                    FROM PropStrength__Application_Booking__c where id =: bookList[0].id AND PropStrength__Project__r.Accounts_Executive__c != null];
        
        if(!firstBooking.isEmpty()){
            PropStrength__Application_Booking__c book = firstBooking[0];
            
            Set<String> emailAddress = new Set<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            
            List<EmailTemplate> templatelist = [SELECT id,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Account_Executive_After_24_72_Hrs' limit 1];
            
            Id TempId;
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }

            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            List<String> toList = new List<String>{book.PropStrength__Project__r.Accounts_Executive__r.Email};
            emails.setWhatId(book.Id);

            if(!toList.isEmpty()) {
                emails.setToAddresses(toList); 
            }

            emails.setTemplateId(TempId);
            emails.setSaveAsActivity(true); 
            emails.setTargetObjectId(book.PropStrength__Project__r.Accounts_Executive__c);
            emails.setTreatTargetObjectAsRecipient(false); 
            emaillist.add(emails);

            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
}