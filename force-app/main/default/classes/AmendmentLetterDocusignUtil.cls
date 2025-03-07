/*********************************************************************
 * Class Name  :   AmendmentLetterDocusignUtil
 * Description :   Utilty Class
 * Created Date:   23/08/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 23/08/2024
 *********************************************************************/
public with sharing class AmendmentLetterDocusignUtil {
    public static Account getAccount(Id accId) {
        Account acc = [SELECT id, Name, Mobile_No__c, Al_Siniya_Partner__c, list_of_missing_documents__c,
                        Email_ID_1__c, Broker_Category_Type_Doc__c, Owner.Name, Owner.Email, CreatedDate
                        FROM Account 
                        WHERE id=:accId LIMIT 1];
        return acc;
    }

    public static Id getFileId(Id accId) {
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:accId 
                                                AND ContentDocument.title LIKE 'Amendment Document%'
                                                ORDER BY ContentDocument.CreatedDate desc];   
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
            ds.Envelope_Type__c = 'Amendment Letter';
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
                    rs.Envelope_Type__c = 'Amendment Letter';
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
        string missingDocuments = (acc.list_of_missing_documents__c!=null)?acc.list_of_missing_documents__c:'';
        String recipientName;
        if(acc.Al_Siniya_Partner__c) {
            recipientName =  system.label.Siniya_Island_Final_Signatory_Name;
        } else if(acc.Broker_Category_Type_Doc__c.contains('UAE')){
            recipientName = system.label.UAE_Category_Name;
        } else {
            recipientName = system.label.VP_First_Name+' '+system.label.VP_Last_Name;
        }
        String baseUrl = Url.getOrgDomainURL().toExternalForm();
        String url = baseUrl + '/' + acc.id;
        return 
        '<p> Dear '+acc.Name+' ,</p> '+
        '<p>I hope this email finds you well.</p>'+
        '<p>The Sobha Siniya agreement is ready for your signature. Please find the link to digitally sign the agreement using DocuSign.</p>'+
        '<p>Additionally, kindly provide the following documents which are awaited.</p>'+
        '<p>'+missingDocuments+'</p>'+
        '<p>Kindly send the list of missing documents (if any) to <b>'+acc.Owner.Email+'</b></p>'+
        '<p>Please do not hesitate to contact me regarding any questions you may have.</p>'+
        '<p>Thank you for your cooperation.</p>'+
         /*'<p>'+
         'Please be informed that the Amendment Letter for the registration of '+acc.Name+' is ready for Signature. Please find the details below.'+
        '</p>   '+*/
        
  
        /*'<table border="1" >'+
            '<tr>'+
                '<td>Broker Name</td>'+
                '<td>'+acc.Name+'</td> '+                 
            '</tr>'+
            '<tr>'+
                '<td>Broker Category</td>'+
                '<td>'+acc.Broker_Category_Type_Doc__c+'</td>'+
                
            '</tr>'+
            '<tr>'+
                '<td>Created Date</td>'+
            '<td>'+acc.createdDate+'</td>'+
                
            '</tr> '+
                '<tr>'+
                '<td>CHRM</td>'+
            '<td>'+acc.Owner.Name+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Status</td>'+
                '<td>Awaiting VP signature</td>'+                  
            '</tr>'+
        '</table>'+*/
        '<p>Thank you.</p>'+
        '<p>Best Regards,</p>'+
        '<p>'+acc.Owner.Name+'</p>';
    }

    public static String docusignEmailBody1(Account acc) {
        String recipientName;
        recipientName =  system.label.Siniya_Island_Final_Signatory_Name;
        String baseUrl = Url.getOrgDomainURL().toExternalForm();
        String url = baseUrl + '/' + acc.id;
        return 
        '<p> Dear '+recipientName+' ,</p> '+
        '<p>'+
         'Please be informed that the Amendment Letter for the registration of '+acc.Name+' is ready for Signature. Please find the details below.'+
        '</p>   '+
  
        '<table border="1" >'+
            '<tr>'+
                '<td>Broker Name</td>'+
                '<td>'+acc.Name+'</td> '+                 
            '</tr>'+
            '<tr>'+
                '<td>Broker Category</td>'+
                '<td>'+acc.Broker_Category_Type_Doc__c+'</td>'+
                
            '</tr>'+
            '<tr>'+
                '<td>Created Date</td>'+
            '<td>'+acc.createdDate+'</td>'+
                
            '</tr> '+
                '<tr>'+
                '<td>CHRM</td>'+
            '<td>'+acc.Owner.Name+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Status</td>'+
                '<td>Awaiting VP signature</td>'+                  
            '</tr>'+
        '</table>'+
        '<p>Thank you.</p>'+
        '<p>Best Regards,</p>'+
        '<p>Channel Manager</p>';
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

    public static String getAuditBody() {
        return
        'Dear Audit Team,\n\nThis is to inform you that the customer signed NOC has been reviewed and approved.\n\n'+
        'Request you to review and approve the NOC.Once appproved, NOC is further sent to seller representative signatures.\n\nThanks\nSobha Realty\n';
    }

    public static String validateAndUpdatePhoneNumber(String phoneNumber) {
        if (!phoneNumber.startsWith('+')) {
            phoneNumber = '+'+phoneNumber;
        }
        return phoneNumber;
    }
}