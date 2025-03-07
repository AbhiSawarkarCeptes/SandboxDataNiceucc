public with sharing class BrokerRenewalAgreementDocusignUtil {
    public static Id getFileId(Id renewId) {
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:renewId 
                                                AND ContentDocument.title LIKE 'Agreement -%'
                                                ORDER BY ContentDocument.CreatedDate desc];    
        Id myDocumentId = docList[0].ContentDocumentId;
        return myDocumentId;
    }
    public static Broker_Renewal__c getBrokerRenwal(Id renewId) {
        Broker_Renewal__c renew = [SELECT Id, Name_as_per_trade_license__c, list_of_missing_documents__c,  Mobile_No__c, Broker_Category__c, Broker_Account__r.CHRM_Ops_Email__c,  
                        Email_ID_1__c, CRM_Email__c, Owner.email, Owner.Name
                        FROM Broker_Renewal__c 
                        WHERE id=:renewId LIMIT 1];
        return renew;
    }
    public static void docusignPostProcessing(String envelopeId, 
                                                    Id renewId, 
                                                    Id myDocumentId, 
                                                    Map<String,String> emailToRoleMap) {
    
        List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c
                                                                From dfsle__EnvelopeStatus__c
                                                                Where dfsle__DocuSignId__c=:envelopeId];
    
        if (docusignStatusList.size() > 0) {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'Broker Renew Agreement';
            ds.Broker_Renewal__c = renewId;
            update ds;

            List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
            List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__RoutingOrder__c,Broker_Renewal__c,
                                                                                dfsle__Email__c,Envelope_Type__c,
                                                                                Envelope_Recipient_Type__c 
                                                                            From dfsle__RecipientStatus__c
                                                                            Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];

            Integer i = 1;
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) {
                String drsKey=rs.dfsle__Email__c+'_'+rs.dfsle__RoutingOrder__c;
                System.debug('key is:====> '+drsKey);

                if (emailToRoleMap.containsKey(drsKey)) {
                    rs.Broker_Renewal__c = renewId;
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(drsKey);
                    rs.Envelope_Type__c = 'Broker Renew Agreement';
                    System.debug('Standard DRS records for Booking: '+rs);
                    rsToUpdateList.add(rs);
                }
                i += 1;
            }            
            system.debug('=====>'+rsToUpdateList);
            update rsToUpdateList;
            
        }
    }
    public static String docusignEmailBody(Broker_Renewal__c renew) {
        String missingdocument;
        if(renew.list_of_missing_documents__c=='' || renew.list_of_missing_documents__c==null){
            missingdocument='None';
        }else{
            missingdocument = renew.list_of_missing_documents__c;
        }
        return 
        'Dear '+renew.Name_as_per_trade_license__c+ '\n\n'+
        'I hope this email finds you well.\n'+
        'The registration agreement is ready for your signature.\n'+
        'Please find the link below to digitally sign the agreement using DocuSign:\n\n'+ 
        'Additionally, kindly provide the following documents which are awaited:\n'+
        missingdocument+'\n\n'+
        'Please do not hesitate to contact me regarding any questions or issues that you encounter. We are here to assist you.\n'+
        '<b>Please send the list of missing documents (if any) to '+renew.Owner.email+'</b>\n\n'+
        'Thank you for your cooperation. \n'+
        'Best regards,\n'+
        renew.Owner.name;
    }
    public static String getCHRMOpsBody(String Name) {
        return
        'Dear CHRM Ops Team,\n\nThis is to inform you that the Agreement signed with Broker Registration-'+Name+' has been generated. \n\n'+
        'Request you to review and approve the Agreement .Once appproved, Agreement is further sent to broker for sign.\n\nThanks\nSobha Realty\n';
    }
}