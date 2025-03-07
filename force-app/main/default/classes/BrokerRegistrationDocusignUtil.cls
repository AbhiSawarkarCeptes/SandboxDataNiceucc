/*********************************************************************
 * Class Name  :   BrokerRegistrationDocusignUtil
 * Description :   Utilty Class
 * Created Date:   06/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 06/02/2024
                         Gourav Gour 02/05/20024
 *********************************************************************/
public with sharing class BrokerRegistrationDocusignUtil {
    public static Account getAccount(Id accId) {
        Account acc = [Select id, Name,CHRM_s_Email__c, CHRM_Ops_Email__c, Mobile_No__c,Broker_Category__c,list_of_missing_documents__c, Owner.email, OwnerId, Owner.name, PropStrength__Broker_Type__c,CHRM_Ops__c,
                        CHRM_Ops__r.Email, 
                        Email_ID_1__c, Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.Email
                        FROM Account 
                        WHERE id=:accId LIMIT 1];
        return acc;
    }

    public static Id getFileId(Id accId) {
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:accId 
                                                AND ContentDocument.title LIKE 'Agreement -%'
                                                ORDER BY ContentDocument.CreatedDate desc];   
        // if(docList.isEmpty()) {
        //     docList = BrokerRegistrationDocumentCreator.brokerRegistrationAttacher2(new List<Id>{accId});
        // }     
        Id myDocumentId = docList[0].ContentDocumentId;
        return myDocumentId;
    }

    public static void docusignPostProcessing(String envelopeId, 
                                                    Id accId, 
                                                    Id myDocumentId, 
                                                    Map<String,String> emailToRoleMap) {
    
        List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c
                                                                From dfsle__EnvelopeStatus__c
                                                                Where dfsle__DocuSignId__c=:envelopeId];
    
        if (docusignStatusList.size() > 0) {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'Broker Agreement';
            ds.Broker_Account__c = accId;
            update ds;

            List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
            List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__RoutingOrder__c,Broker_Account__c,
                                                                                dfsle__Email__c,Envelope_Type__c,
                                                                                Envelope_Recipient_Type__c 
                                                                            From dfsle__RecipientStatus__c
                                                                            Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];

            Integer i = 1;
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) {
                String drsKey=rs.dfsle__Email__c+'_'+rs.dfsle__RoutingOrder__c;
                System.debug('key is:====> '+drsKey);

                if (emailToRoleMap.containsKey(drsKey)) {
                    rs.Broker_Account__c = accId;
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(drsKey);
                    rs.Envelope_Type__c = 'Broker Agreement';
                    System.debug('Standard DRS records for Booking: '+rs);
                    rsToUpdateList.add(rs);
                }
                i += 1;
            }                                                       
            update rsToUpdateList;
            system.debug(rsToUpdateList);
        }
    }

    public static List<Docusign_Recipient_Status_Sobha__c> getDocusignRecipientStatusSobha(Id docusignEnvelopeStatusId) {
        return [Select id, Application_Booking__c, 
                            Completed__c,
                            Decline_Reason__c,
                            DocuSign_Envelope_Status__c,
                            Name,
                            Email__c,
                            Envelope_Recipient_Type__c,
                            Envelope_Type__c,
                            Last_Applicant__c,
                            Transaction_Request__c	,
                            Broker_Account__c,
                            Last_Status_Update__c,
                            Routing_Order__c,
                            Salesforce_Source_ID__c,
                            Sent__c,
                            Sequence__c,
                            Status__c,
                            Type__c
                            FROM Docusign_Recipient_Status_Sobha__c
                            WHERE DocuSign_Envelope_Status__c=:docusignEnvelopeStatusId];
    }
    
    public static Map<string,Docusign_Recipient_Status_Sobha__c> getDocusignRecipientStatusSobhaByKey(set<Id> envIds){
        Map<string,Docusign_Recipient_Status_Sobha__c> keyToDRS = new Map<string,Docusign_Recipient_Status_Sobha__c>();
        list<Docusign_Recipient_Status_Sobha__c> drsSobhaList = [Select id, Application_Booking__c, 
                            Completed__c,
                            Decline_Reason__c,
                            DocuSign_Envelope_Status__c,
                            Name,
                            Email__c,
                            Envelope_Recipient_Type__c,
                            Envelope_Type__c,
                            Last_Applicant__c,
                            Last_Status_Update__c,
                            Routing_Order__c,
                            Salesforce_Source_ID__c,
                            Sent__c,
                            Sequence__c,
                            Status__c,
                            Type__c
                            FROM Docusign_Recipient_Status_Sobha__c WHERE DocuSign_Envelope_Status__c IN: envIds];
        for(Docusign_Recipient_Status_Sobha__c dsrSobha : drsSobhaList){
            keyToDRS.put(dsrSobha.DocuSign_Envelope_Status__c+'#'+dsrSobha.Sequence__c+'#'+dsrSobha.Email__c,dsrSobha);
        }
        return keyToDRS;
    }

    public static void createDocusignRecipientStatusSobhaRecords(List<dfsle__RecipientStatus__c> dsrList) {
        List<Docusign_Recipient_Status_Sobha__c> dsrSobhaInsertList = new List<Docusign_Recipient_Status_Sobha__c>();
        if (dsrList.size() > 0) {
            for (dfsle__RecipientStatus__c dsr:dsrList) {
                Docusign_Recipient_Status_Sobha__c s = new Docusign_Recipient_Status_Sobha__c();
                s.Application_Booking__c = dsr.Application_Booking__c;
                s.Completed__c = dsr.dfsle__Completed__c;
                s.Decline_Reason__c = dsr.dfsle__Reason__c;
                s.DocuSign_Envelope_Status__c = dsr.dfsle__EnvelopeStatus__c;
                s.DocuSignEnvelope__c = dsr.dfsle__EnvelopeStatus__c;
                s.Name = dsr.Name;
                s.Email__c = dsr.dfsle__Email__c;
                s.Envelope_Recipient_Type__c = dsr.Envelope_Recipient_Type__c;
                s.Envelope_Type__c = dsr.Envelope_Type__c;
                s.Last_Applicant__c = dsr.Last_Applicant__c;
                s.Last_Status_Update__c = dsr.dfsle__LastStatusUpdate__c;
                s.Routing_Order__c = dsr.dfsle__RoutingOrder__c;
                s.Salesforce_Source_ID__c = dsr.dfsle__SourceId__c;
                s.Sent__c = dsr.dfsle__Sent__c;
                s.Sequence__c = dsr.dfsle__Sequence__c;
                s.Status__c = dsr.dfsle__Status__c;
                s.Type__c = dsr.dfsle__Type__c;
                dsrSobhaInsertList.add(s);
            }
            if (dsrSobhaInsertList.size() > 0) {
                insert dsrSobhaInsertList;
            }
        }
    }

    public static String docusignEmailBody(Account acc) {
        String missingdocument;
        if(acc.list_of_missing_documents__c=='' || acc.list_of_missing_documents__c==null){
            missingdocument='None';
        }else{
            missingdocument = acc.list_of_missing_documents__c;
        }
        /*return 
        'Dear '+acc.Name+ '\n\n'+
        'I hope this email finds you well.\n'+
        'The registration agreement is ready for your signature.'+
        'Please find the link below to digitally sign the agreement using DocuSign:\n\n'+ 
        'Additionally, kindly provide the following documents which are awaited:\n'+
        missingdocument+'\n\n'+
        'Please do not hesitate to contact me regarding any questions or issues that you encounter. We are here to assist you.\n'+
        '<b>Please send the list of missing documents (if any) to '+acc.Owner.email+'</b>\n\n'+
        'Thank you for your cooperation. \n'+
        'Best regards,\n'+
        acc.Owner.name;*/
        return 
        'Dear '+acc.Name+ '\n\n'+
        'I hope this email finds you well.\n'+
        'The registration agreement is ready for your signature.'+
        'Please find the link above to digitally sign the agreement using DocuSign:\n\n'+
            'Additionally, kindly provide the following documents which are awaited:\n'+
         missingdocument+'\n\n'+
        '<b>Kindly send the list of missing documents (if any) to '+acc.Owner.email+'</b>\n\n'+
        
        'Please do not hesitate to contact me regarding any questions you may have.\n'+
        
        'Thank you for your cooperation. \n'+
        'Best regards,\n'+
        acc.Owner.name;
    }

    public static String getSMSDBody(String bookingName, String unitName) {
        return 
            'This is to inform you that the Booking form with Booking ID-'+bookingName+' for Unit #'+unitName+' has been SIGNED by the client. Request you to kindly review and complete the DocuSign process. Please check Salesforce for the latest update. \n\n';
    }

    public static String getSalesOperationBody(String bookingName, String unitName) {
        return
        'Dear SalesOps Team,\n\n This is to inform you that the Booking form with Booking ID-'+bookingName+' for Unit # '+unitName+' has been Signed by the Sales Manager and Sales Director.\n\n'+
        'Request you to review and approve the booking form. Once appproved, booking form is further sent to audit team for review.\n\nThanks\nSobha Realty\n';
    }

    public static String getAuditBody(String bookingName, String unitName) {
        return
        'Dear Audit Team,\n\nThis is to inform you that the customer signed Booking form with Booking ID-'+bookingName+' for Unit # '+unitName+'has been reviewed and approved.\n\n'+
        'Request you to review and approve the booking form.Once appproved, booking form is further sent to seller representative signatures.\n\nThanks\nSobha Realty\n';
    }

    public static String validateAndUpdatePhoneNumber(String phoneNumber) {
        if (!phoneNumber.startsWith('+')) {
            phoneNumber = '+'+phoneNumber;
        }
        return phoneNumber;
    }
    public static String getCHRMOpsBody(String Name) {
        /*return
        'Dear CHRM Ops Team,\n\nThis is to inform you that the Agreement signed with Broker Registration-'+Name+' has been generated. \n\n'+
        'Request you to review and approve the Agreement .Once appproved, Agreement is further sent to broker for sign.\n\nThanks\nSobha Realty\n';*/
        return
        'Dear CHRM Ops Team,\n\nThis is to inform you that the Broker Registration Agreement for '+Name+' has been generated. \n\n'+
        'Request you to review and approve the Agreement .Once appproved, Agreement is further sent to broker for signature.\n\nThanks\nSobha Realty\n';
    }
}