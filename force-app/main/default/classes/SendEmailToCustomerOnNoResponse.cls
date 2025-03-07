/*********************************************************************
 * Class Name  :   SendEmailToCustomerOnNoResponse
 * Description :   Helper Class of Send Email To Customer On No Response Flow
 * Created Date:   28/05/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 28/05/2024
 *********************************************************************/
public class SendEmailToCustomerOnNoResponse {
    @InvocableMethod
    public static void SendEmailToCustomerOnNoResponseCD (List<String> recId) {
        List<Application_Booking_Call_Detail__c> acdList = [SELECT Id, Application_Booking__c FROM Application_Booking_Call_Detail__c WHERE Id = :recId AND Application_Booking__c != null AND Call_Update__c = 'No Response'];
        if(!acdList.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookRec = [SELECT Id, PropStrength__Primary_Customer__c, 
                                                                (SELECT Id, PropStrength__Applicant_Email__c 
                                                                FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE 
                                                                AND PropStrength__Applicant_Email__c != null) 
                                                                FROM PropStrength__Application_Booking__c WHERE Id = :acdList[0].Application_Booking__c];

            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                FROM EmailTemplate 
                                                WHERE DeveloperName =: 'SendEmailToCustomerOnNoResponseCD'];
            String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                 owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
    
    

            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

            for(PropStrength__Application_Booking__c book : bookRec) {
                if(!book.PropStrength__Applicant_Details__r.isEmpty()) {
                    List<String> sendTo = new List<String>();
                    for(PropStrength__Applicant_Detail__c appDet : book.PropStrength__Applicant_Details__r) {
                        sendTo.add(appDet.PropStrength__Applicant_Email__c);
                    }

                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    email.setToAddresses(sendTo);
                    email.setWhatId(acdList[0].Id);
                    email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.setSaveAsActivity(true); 
                    email.setTemplateId(tempId);
                    mails.add(email); 
                }
            }
            
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    }
}