/*********************************************************************
 * Class Name  :   SendExecutedAmendment
 * Description :   Helper Class of Send Executed Amendment (Flow)
 * Created Date:   23/08/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 23/08/2024
 *********************************************************************/
public class SendExecutedAmendment {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> accId) {
        Id mySourceId = accId[0];

        Account accRec = [SELECT Id, Email_ID_1__c, CreatedById FROM Account WHERE Id = :mySourceId];

        ContentDocumentLink cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocument.title LIKE 'Amendment Document%' AND LinkedEntityId = :mySourceId ORDER BY ContentDocument.CreatedDate DESC LIMIT 1];

        ContentVersion contentVersions = [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1];

        String TempId;
        String searchTxt = 'SendExecutedAmendment';
        List<EmailTemplate> templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
        if(!templatelist.isEmpty()) {
            TempId = templatelist[0].id;
        }

        List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();                
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Siniya_Contact_From_Address_Email limit 1];
    
        Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
        emails.setWhatId(mySourceId);
        emails.setToAddresses(new List<String>{accRec.Email_ID_1__c}); 
        emails.setTemplateId(TempId);
        emails.setSaveAsActivity(true); 
        emails.setTargetObjectId(accRec.CreatedById);
        emails.setTreatTargetObjectAsRecipient(false); 
        if (owea.size() > 0) {
            emails.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Amendment Letter.pdf');
        efa.setBody(contentVersions.VersionData);   
        efa.setInline(false);
        efalst.add(efa);

        if(!efalst.isEmpty()) {
            emails.setFileAttachments(efalst);
        }

        emaillist.add(emails);

        if(emaillist != null && emaillist.size()>0 ) {
            Messaging.sendEmail(emaillist);
        }
    }
}