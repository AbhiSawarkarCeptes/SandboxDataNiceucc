/*********************************************************************
 * Class Name  :   DocusignRecipientStatusSobhaTrigHelper
 * Description :   Helper Class of DocusignRecipientStatusSobhaTrigger
 * Created Date:   31/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 31/01/2024
                        Deepak Sharma 31/01/2024
                        Gourav Gour 13/05/2024

 *********************************************************************/
public class DocusignRecipientStatusSobhaTrigHelper {
    //Added by Nishank Manwani on 31/01/2024 to update Type Field
    public static void updateTypeField(List<Docusign_Recipient_Status_Sobha__c> esList, Map<Id,Docusign_Recipient_Status_Sobha__c> esMap) {
        List<PropStrength__Transaction_Requests__c> updateTransactionReq = new List<PropStrength__Transaction_Requests__c>();
        List<Account> updateAccount = new List<Account>();
        for(Docusign_Recipient_Status_Sobha__c es : esList) {
            if(es.Name == 'Audit Team' && es.Transaction_Request__c != null) {
                es.Type__c = 'Approver';
            } else if (es.Name == 'CRM Document Controller' && es.Transaction_Request__c != null) {
                es.Type__c = 'Stamp';
            }
            System.debug('es.Status__c****');
            System.debug(es.Status__c);
            System.debug(es.Envelope_Type__c);
            System.debug(es.Transaction_Request__c);
            System.debug(es.Envelope_Recipient_Type__c);
            
            if(esMap != null) {
                
                if(es.Envelope_Type__c == 'Broker Agreement' && es.Broker_Account__c!= null && es.Envelope_Recipient_Type__c == 'Sobha LLC' && (es.Status__c == 'Delivered' || es.Status__c == 'Completed' ) && (es.Status__c != esMap.get(es.Id).Status__c)) {
                    updateAccount.add(new Account(Id=es.Broker_Account__c, PropStrength__Broker_Approval_Status__c = 'Signed Agreement Received - Documents Awaiting'));
                }
                if(es.Envelope_Type__c == 'NOC' && es.Broker_Account__c!= null && es.Name == 'Audit Team' && (es.Status__c == 'Delivered' || es.Status__c == 'Completed' )  && (es.Status__c != esMap.get(es.Id).Status__c)) {
                    updateAccount.add(new Account(Id=es.Broker_Account__c, PropStrength__Broker_Approval_Status__c = 'Pending with Ashish Parakh/ Sent for final signatures'));
                }
                if(es.Envelope_Type__c == 'Amendment Letter' && es.Broker_Account__c!= null && es.Envelope_Recipient_Type__c == 'Authorised Representative' && (es.Status__c == 'Delivered' || es.Status__c == 'Completed' )  && (es.Status__c != esMap.get(es.Id).Status__c)) {
                    updateAccount.add(new Account(Id=es.Broker_Account__c, PropStrength__Broker_Approval_Status__c = 'Amendment Signed by Broker'));
                }
                if(es.Envelope_Type__c == 'Amendment Letter' && es.Broker_Account__c!= null && es.Envelope_Recipient_Type__c == system.label.Siniya_Island_Final_Signatory_Name && (es.Status__c == 'Delivered' || es.Status__c == 'Completed' )  && (es.Status__c != esMap.get(es.Id).Status__c)) {
                    updateAccount.add(new Account(Id=es.Broker_Account__c, PropStrength__Broker_Approval_Status__c = 'Amendment Final Signature Completed'));
                }
                // if(es.Envelope_Type__c == 'NOC' && es.Broker_Account__c!= null && es.Envelope_Recipient_Type__c.contains('Broker Registration - ') && (es.Status__c == 'Delivered' || es.Status__c == 'Completed' ) && (es.Status__c != esMap.get(es.Id).Status__c)) {
                //     updateAccount.add(new Account(Id=es.Broker_Account__c, PropStrength__Broker_Approval_Status__c = 'Executed Agreement Sent to CHRM'));
                //     DocusignRecipientStatusSobhaTrigHelper.sendEmailNotification(es.Broker_Account__c);
                // }
            }
        }
        if(!updateTransactionReq.isEmpty()) {
            update updateTransactionReq;
        }
        if(!updateAccount.isEmpty()) {
            update updateAccount;
        }
    }

    //Added by Nishank Manwani on 06/02/2024 to send Email on final signature for NOC and Broker Registration
    @future(callout=true)
    public static void sendEmailNotification(Id accId) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        System.debug(accId);  
        Account acc = [SELECT Id, Name, Code__c, Email_ID_1__c FROM Account WHERE Id = :accId];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Final NOC and Agreement Letter');
        //mail.setPlainTextBody('Dear CRM Team,\n\nPlease note Transfer of Property for unit '+house+', booking ID '+bookName+' has been approved by audit for processing.\n\nIt is in your queue for execution. Please complete the execution and close the step.\n\nRegards,\nSalesforce');
        mail.setHtmlBody('<html><body>Dear Team,<br/><br/>The Final NOC and Agreement Letter are ready to be sent to the below mentioned Broker.<br/>Request you to please take this forward.<br/><br/>Broker Name : '+acc.Name+'<br/>Broker Code : '+acc.Code__c+'<br/><br/>Thank You</body></html>');
        mail.setToAddresses(new List<String>{acc.Email_ID_1__c});

        System.debug(mail);
        emailList.add(mail);
        
        System.debug(emailList);
        if(emailList != null && emailList.size()>0 ) {
            System.debug(emailList);
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            System.debug('result***');
            System.debug(result);
            EmailMessage newEmail = new EmailMessage();
            newEmail.ToAddress = acc.Email_ID_1__c;
            newEmail.Subject = 'Final NOC and Agreement Letter';
            newEmail.HtmlBody = mail.getHtmlBody();
            newEmail.RelatedToId = accId;
            newEmail.Status = '3';
            insert newEmail;
        }
    }

    //Added by Nishank Manwani on 06/02/2024 to send Email on final signature for NOC and Broker Registration
    // Email subject body updated by Gourav Gour 06/06/2024
    @future(callout=true)
    public static void sendEmailNotificationBroker(Id accId) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        System.debug(accId);  

        Account acc = [SELECT Id, Name, Code__c, Email_ID_1__c, OwnerId, Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.Name FROM Account WHERE Id = :accId];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Sobha Realty Registration - Executed Agreement');
        //mail.setHtmlBody('<html><body>Dear '+acc.Name+',<br/><br/>Sobha Realty Registration - Executed Agreement <br/><br/>Please do not hesitate to contact me regarding any questions you may have.<br/><br/>We look forward to a mutually beneficial and successful business relationship with you. <br/><br/>Thank you.<br/><br/>Best Regards,<br/><br/>'+acc.Channel_Relationship_Manager__r.Name+'</body></html>');
        // updated By Gourav Gour 17/07/2024
        //mail.setHtmlBody('<html><body>Dear '+acc.Name+',<br/><br/>Sobha Realty Registration - Executed Agreement <br/><br/>Please do not hesitate to contact me regarding any questions you may have.<br/><br/>We look forward to a mutually beneficial and successful business relationship with you. <br/><br/>Thank you.<br/><br/>Best Regards,<br/><br/>CHRM Manager</body></html>');
        mail.setHtmlBody('<html><body>Dear '+acc.Name+',<br/><br/>Hope this email finds you well. I am pleased to inform you that your Sobha Registration – Agreement has been Executed. Please find attached Executed Agreement & NOC for your reference.  <br/><br/>Please do not hesitate to contact me regarding any questions you may have.<br/><br/>We look forward to a mutually beneficial and successful business relationship with you. <br/><br/>Thank you.<br/><br/>Best Regards,<br/><br/>'+acc.Channel_Relationship_Manager__r.Name+'</body></html>');
        mail.setToAddresses(new List<String>{acc.Email_ID_1__c});

        Map<Id,ContentVersion> attachmentMap = new Map<Id,ContentVersion>();
        List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :accId];
        if(!contDocLinks.isEmpty()) {
            Set<Id> cdIds= new Set<Id>();
            for(ContentDocumentLink cd : contDocLinks) {
                cdIds.add(cd.ContentDocumentId);
            }
            Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment efa2 = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment efa3 = new Messaging.EmailFileAttachment();
            List<Messaging.EmailFileAttachment> fileAttachList = new List<Messaging.EmailFileAttachment>();
            List<ContentDocument> documents = [SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id IN :cdIds AND Title LIKE :'NOC -%' ORDER BY CreatedDate DESC LIMIT 1];
            if(!documents.isEmpty()) {
                List<ContentVersion> contentVersions = [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId = :documents[0].Id];
                if(!contentVersions.isEmpty()) {
                    efa1.setFileName(contentVersions[0].Title + '.' + contentVersions[0].FileExtension);
                    efa1.setBody(contentVersions[0].VersionData); 
                    fileAttachList.add(efa1);
                }
            }
            List<ContentDocument> documents1 = [SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id IN :cdIds AND Title LIKE :'%Broker%' AND (NOt Title LIKE '%NOC%') AND (NOt Title LIKE '%Agreement%') ORDER BY CreatedDate DESC LIMIT 1];
            if(!documents1.isEmpty()) {
                List<ContentVersion> contentVersions = [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId = :documents1[0].Id];
                if(!contentVersions.isEmpty()) {
                    efa2.setFileName(contentVersions[0].Title + '.' + contentVersions[0].FileExtension);
                    efa2.setBody(contentVersions[0].VersionData); 
                    //fileAttachList.add(efa2);
                }
            }
            List<ContentDocument> documents2 = [SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id IN :cdIds AND Title LIKE :'Agreement -%' ORDER BY CreatedDate DESC LIMIT 1];
            if(!documents2.isEmpty()) {
                List<ContentVersion> contentVersions = [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId = :documents2[0].Id];
                if(!contentVersions.isEmpty()) {
                    efa3.setFileName(contentVersions[0].Title + '.' + contentVersions[0].FileExtension);
                    efa3.setBody(contentVersions[0].VersionData); 
                    fileAttachList.add(efa3);
                }
            }

            if(!fileAttachList.isEmpty()) {
                mail.setFileAttachments(fileAttachList);
            }
        }
        mail.setTargetObjectId(acc.OwnerId);
        mail.setWhatId(acc.Id);
        mail.setSaveAsActivity(true);
        mail.setTreatTargetObjectAsRecipient(false); 

        System.debug(mail);
        emailList.add(mail);
        
        System.debug(emailList);
        if(emailList != null && emailList.size()>0 ) {
            System.debug(emailList);
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
            System.debug('result***');
            System.debug(result);
            EmailMessage newEmail = new EmailMessage();
            newEmail.ToAddress = acc.Email_ID_1__c;
            newEmail.Subject = 'Final NOC and Agreement Letter';
            newEmail.HtmlBody = mail.getHtmlBody();
            newEmail.RelatedToId = accId;
            newEmail.Status = '3';
           // insert newEmail;
        }
    }

    //Added by Nishank Manwani on 08/02/2024 to update Handover Field
    public static void updateHandover(List<Docusign_Recipient_Status_Sobha__c> esList, Map<Id,Docusign_Recipient_Status_Sobha__c> esMap) {
        List<PropStrength__Application_Booking__c> updateBooking = new List<PropStrength__Application_Booking__c>();
        List<Docusign_Recipient_Status_Sobha__c> statusSobhaList = [SELECT Id, Envelope_Type__c, Status__c FROM Docusign_Recipient_Status_Sobha__c WHERE (Envelope_Type__c = 'Handover of Possession' OR Envelope_Type__c = 'Undertaking Letter') AND Application_Booking__c != null];
        Map<String, String> mapOfType = new Map<String, String>();

        for(Docusign_Recipient_Status_Sobha__c sb : statusSobhaList) {
            mapOfType.put(sb.Envelope_Type__c, sb.Status__c);
        }

        for(Docusign_Recipient_Status_Sobha__c es : esList) {
            if(esMap != null) {
                if(mapOfType.containsKey('Undertaking Letter') && (mapOfType.get('Undertaking Letter') == 'Delivered' || mapOfType.get('Undertaking Letter') == 'Completed' ) && es.Envelope_Type__c == 'Handover of Possession' && es.Application_Booking__c!= null && (es.Status__c == 'Delivered' || es.Status__c == 'Completed' ) && (es.Status__c != esMap.get(es.Id).Status__c)) {
                    updateBooking.add(new PropStrength__Application_Booking__c(Id=es.Application_Booking__c, Handover_Date__c = System.Now(), Handover_Completed__c = true));
                }
                if(mapOfType.containsKey('Handover of Possession') && (mapOfType.get('Handover of Possession') == 'Delivered' || mapOfType.get('Handover of Possession') == 'Completed' ) && es.Envelope_Type__c == 'Undertaking Letter' && es.Application_Booking__c!= null && (es.Status__c == 'Delivered' || es.Status__c == 'Completed' ) && (es.Status__c != esMap.get(es.Id).Status__c)) {
                    updateBooking.add(new PropStrength__Application_Booking__c(Id=es.Application_Booking__c, Handover_Date__c = System.Now(), Handover_Completed__c = true));
                }
            }
        
            if(!updateBooking.isEmpty()) {
                update updateBooking;
            }
        }
    }

    //Added by Nishank Manwani on 20/05/2024 to update Home Orientation Received Date Field
    public static void updateHomeOrientation(List<Docusign_Recipient_Status_Sobha__c> esList, Map<Id,Docusign_Recipient_Status_Sobha__c> esMap) {
        List<PropStrength__Application_Booking__c> updateBooking = new List<PropStrength__Application_Booking__c>();
        List<Docusign_Recipient_Status_Sobha__c> statusSobhaList = [SELECT Id, Envelope_Type__c, Status__c FROM Docusign_Recipient_Status_Sobha__c WHERE (Envelope_Type__c = 'Home Orientation Undertaking Letter') AND Application_Booking__c != null];
        Map<String, String> mapOfType = new Map<String, String>();

        for(Docusign_Recipient_Status_Sobha__c sb : statusSobhaList) {
            mapOfType.put(sb.Envelope_Type__c, sb.Status__c);
        }

        for(Docusign_Recipient_Status_Sobha__c es : esList) {
            if(esMap != null) {
                if(mapOfType.containsKey('Home Orientation Undertaking Letter') && (mapOfType.get('Home Orientation Undertaking Letter') == 'Delivered' || mapOfType.get('Home Orientation Undertaking Letter') == 'Completed' ) && es.Envelope_Type__c == 'Home Orientation Undertaking Letter' && es.Application_Booking__c!= null && (es.Status__c == 'Delivered' || es.Status__c == 'Completed' ) && (es.Status__c != esMap.get(es.Id).Status__c)) {
                    Time elevenFiftyThreePM = Time.newInstance(23, 53, 0, 0);
                    DateTime reminderDateTime = DateTime.newInstance(System.Today(), elevenFiftyThreePM);
                    updateBooking.add(new PropStrength__Application_Booking__c(Id=es.Application_Booking__c, Home_Orientation_Undertaking_Receive_Dt__c = System.Now(), HO_Escalation_Reminder_Flow_Date__c = reminderDateTime));
                }
            }
        
            if(!updateBooking.isEmpty()) {
                update updateBooking;
            }
        }
    }
}