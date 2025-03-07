/*********************************************************************
 * Class Name  :   SendRenwalMailToBroker
 * Description :   Helper Class of Flow Send Renewl Mail To Broker (Flow)
 * Created Date:   24/05/2024
 * Authored By :   CloudSteer Technology Pvt Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :  Gourav Gour 25/05/2024
 *********************************************************************/
public with sharing class SendRenwalMailToBroker {
    @InvocableMethod
    public static void sendEmail(List<Id> renewId) {
        Id mySourceId = renewId[0];
        try{
            update new Broker_Renewal__c(Id = mySourceId, Broker_Approval_Status__c = 'Executed Agreement Sent to Broker', Executed_Agreement_sent_to_Broker__c = true);

            Broker_Renewal__c renew = [SELECT Id, Account_Owner_Email__c, Broker_Type__c, Broker_Sub_Type__c, Broker_Account__c, Email_ID_1__c, Country_Code__c, Mobile_No__c, Phone__c, Fax__c, Broker_Category__c, Name_as_per_passport__c,
                                        Name_as_per_trade_license__c, Company_Registered_In__c, Villa_Building_name__c, Nationality__c, Witness_Email__c, Witness_Name__c, Street_name__c, Office_Apartment_number__c, ZIP_Postal_Code_PO_Box__c,
                                        City_Province__c, District_Area__c, Country__c, Channel_Relationship_Manager__c, Channel_Relationship_Head__c, Broker_Created_Date__c, CHRM_Head_Approval_Date__c, CHRM_Ops_Approval_Date__c, Assigned_to_Audit_Date__c, 
                                        Audit_Date_Sent__c, Broker_Approval_Status__c, Executed_Agreement_sent_to_Broker__c, NOC_Generated__c FROM Broker_Renewal__c WHERE Id =: mySourceId];
            Account acc = new Account();
            if(renew != null) {
                acc.Id = renew.Broker_Account__c!= null? renew.Broker_Account__c : null;
                acc.PropStrength__Broker_Type__c = renew.Broker_Type__c!= null? renew.Broker_Type__c : null;
                acc.Broker_Sub_Type__c = renew.Broker_Sub_Type__c!= null? renew.Broker_Sub_Type__c : null;
                acc.Email_ID_1__c = renew.Email_ID_1__c!= null? renew.Email_ID_1__c : null;
                acc.Country_Code__c = renew.Country_Code__c!= null? renew.Country_Code__c : null;
                acc.Mobile_No__c = renew.Mobile_No__c!= null? renew.Mobile_No__c : null;
                acc.Phone = renew.Phone__c!= null? renew.Phone__c : null;
                acc.Fax = renew.Fax__c!= null? renew.Fax__c : null;
                acc.Broker_Category__c = renew.Broker_Category__c!= null? renew.Broker_Category__c : null;
                acc.Name_as_per_passport__c = renew.Name_as_per_passport__c!= null? renew.Name_as_per_passport__c : null;
                acc.Name_as_per_trade_license__c = renew.Name_as_per_trade_license__c!= null? renew.Name_as_per_trade_license__c : null;
                acc.Company_Registered_In__c = renew.Company_Registered_In__c!= null? renew.Company_Registered_In__c : null;
                acc.Nationality__c = renew.Nationality__c!= null? renew.Nationality__c : null;
                acc.Witness_Email__c = renew.Witness_Email__c!= null? renew.Witness_Email__c : null;
                acc.Witness_Name__c = renew.Witness_Name__c!= null? renew.Witness_Name__c : null;
                acc.Villa_Building_name__c = renew.Villa_Building_name__c!= null? renew.Villa_Building_name__c : null;
                acc.Street_name__c = renew.Street_name__c!= null? renew.Street_name__c : null;
                acc.Account_Owner_Email__c = renew.Account_Owner_Email__c!= null? renew.Account_Owner_Email__c : null;
                String billingStreet = '';
                billingStreet += renew.Office_Apartment_number__c != null ? renew.Office_Apartment_number__c +', ' : '';
                billingStreet += renew.Street_name__c != null ? renew.Street_name__c +', ' : '';
                billingStreet += renew.Villa_Building_name__c != null ? renew.Villa_Building_name__c +', ' : '';
                acc.BillingStreet = billingStreet;
                acc.Office_Apartment_number__c = renew.Office_Apartment_number__c!= null? renew.Office_Apartment_number__c : null;
                acc.BillingPostalCode = renew.ZIP_Postal_Code_PO_Box__c!= null? renew.ZIP_Postal_Code_PO_Box__c : null;
                acc.BillingCity = renew.City_Province__c!= null? renew.City_Province__c : null;
                acc.BillingState = renew.District_Area__c!= null? renew.District_Area__c : null;
                acc.BillingCountry = renew.Country__c!= null? renew.Country__c : null;
                acc.Channel_Relationship_Manager__c = renew.Channel_Relationship_Manager__c!= null? renew.Channel_Relationship_Manager__c : null;
                acc.Channel_Relationship_Head__c = renew.Channel_Relationship_Head__c!= null? renew.Channel_Relationship_Head__c : null;
                acc.CHRM_Head_Approval_Date__c = renew.CHRM_Head_Approval_Date__c!= null? renew.CHRM_Head_Approval_Date__c : null;
                acc.CHRM_Ops_Approval_Date__c = renew.CHRM_Ops_Approval_Date__c!= null? renew.CHRM_Ops_Approval_Date__c : null;
                acc.Assigned_to_Audit_Date__c = renew.Assigned_to_Audit_Date__c!= null? renew.Assigned_to_Audit_Date__c : null;
                acc.Audit_Date_Sent__c = renew.Audit_Date_Sent__c!= null? renew.Audit_Date_Sent__c : null;
                acc.PropStrength__Broker_Approval_Status__c = renew.Broker_Approval_Status__c!= null? renew.Broker_Approval_Status__c : null;
                acc.Executed_Agreement_sent_to_Broker__c = renew.Executed_Agreement_sent_to_Broker__c!= null? renew.Executed_Agreement_sent_to_Broker__c : null;
                acc.NOC_Generated__c = renew.NOC_Generated__c!= null? renew.NOC_Generated__c : null;
                acc.Renewal_Status__c = 'Renewal Completed';
                acc.Show_Send_Renewal_Link_Button__c = false;
                acc.Renewal_Record_Old__c = renew.Id;
                acc.Renewal_Record_Id__c = null;
                acc.Expiry_Date__c = System.today().addYears(1);
                acc.Broker_Expiry_Date__c = System.today().addYears(1);
                update acc;
            }                            
            
            SendRenwalMailToBroker.sendEmailNotificationBroker(mySourceId);
        } catch(Exception ex){
            system.debug('===========Exception ============'+ex.getmessage());
            system.debug('===========Exception ============'+ex.getlinenumber());
        }
        
    } 
    @future(callout=true)
    public static void sendEmailNotificationBroker(Id renewId) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        Broker_Renewal__c renewRec = [SELECT Id, Name_as_per_trade_license__c,Channel_Relationship_Manager__r.Name, Email_ID_1__c, OwnerId FROM Broker_Renewal__c WHERE Id = :renewId];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Sobha Realty Registration - Executed Agreement');
        // mail.setHtmlBody('<html><body>Dear '+renewRec.Name_as_per_trade_license__c+',<br/><br/>Sobha Realty Registration - Executed Agreement <br/><br/>Please do not hesitate to contact me regarding any questions you may have.<br/><br/>We look forward to a mutually beneficial and successful business relationship with you. <br/><br/>Thank you.<br/><br/>Best Regards,<br/><br/>'+renewRec.Channel_Relationship_Manager__r.Name+'</body></html>');
        // Updated By Gourav Gour 17/07/2024
        mail.setHtmlBody('<html><body>Dear '+renewRec.Name_as_per_trade_license__c+',<br/><br/>Sobha Realty Registration - Executed Agreement <br/><br/>Please do not hesitate to contact me regarding any questions you may have.<br/><br/>We look forward to a mutually beneficial and successful business relationship with you. <br/><br/>Thank you.<br/><br/>Best Regards,<br/><br/>CHRM Manager</body></html>');

        mail.setToAddresses(new List<String>{renewRec.Email_ID_1__c});

        Map<Id,ContentVersion> attachmentMap = new Map<Id,ContentVersion>();
        List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :renewId];
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
            List<ContentDocument> documents1 = [SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id IN :cdIds AND Title LIKE :'Broker%'  ORDER BY CreatedDate DESC LIMIT 1];
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
        //mail.setTargetObjectId('003ba000000zSsE');
        mail.setWhatId(renewId);
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
        }
    }
}