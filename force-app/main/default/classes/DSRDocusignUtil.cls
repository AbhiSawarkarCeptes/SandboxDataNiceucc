/*********************************************************************
 * Class Name  :   DSRDocusignUtil
 * Description :   Utilty Class
 * Created Date:   12/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 12/02/2024
 *********************************************************************/
public with sharing class DSRDocusignUtil {
    public static PropStrength__Transaction_Requests__c getTransactionRequest(Id trId) {
        PropStrength__Transaction_Requests__c trRec = [Select id,PropStrength__Application_Booking__r.PropStrength__Tower__c,PropStrength__Application_Booking__r.PropStrength__Project__r.Accounts_Executive__c, 
                                        PropStrength__Application_Booking__r.PropStrength__Project__r.Accounts_Executive__r.Email, PropStrength__Application_Booking__r.PropStrength__Project__r.Accounts_Executive__r.Name, 
                                        Name,PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.Name,PropStrength__Application_Booking__r.PropStrength__Property__r.Name,
                                        PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name,
                                        PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone,
                                        PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.PropStrength__Account_Type__c,
                                        PropStrength__Application_Booking__r.POA_Name__c, PropStrength__Application_Booking__r.POA_Email_Address__c, PropStrength__Application_Booking__r.Seller_Representative__c, PropStrength__Application_Booking__r.Seller_Representative__r.Email,
                                        PropStrength__Application_Booking__r.Seller_Representative__r.Name, PropStrength__Application_Booking__r.CRM_Document_Controller__r.Name, PropStrength__Application_Booking__r.CRM_Document_Controller__r.Email, PropStrength__Application_Booking__r.Docusign_Audit_Email__c,
                                        PropStrength__Application_Booking__r.POA_Mobile_Number__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Application_Booking__r.CRM_Executive__c,PropStrength__Application_Booking__r.CRM_Executive__r.Email,
                                        PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__c , PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__r.Name, 
                                        PropStrength__Application_Booking__r.PropStrength__Project__r.DLD_Executive__r.Email   
                                        FROM PropStrength__Transaction_Requests__c 
                                        WHERE id=:trId LIMIT 1];
        return trRec;
    }

    public static Id getFileId(Id trId) {
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:trId 
                                                AND ContentDocument.title LIKE '%DSR%'
                                                ORDER BY ContentDocument.CreatedDate desc];   
        Id myDocumentId = docList[0].ContentDocumentId;
        return myDocumentId;
    }

    public static List<PropStrength__Applicant_Detail__c> getApplicants(Id bookingId) {
        List<PropStrength__Applicant_Detail__c> applicants = [SELECT Id, Name, PropStrength__Applicant_Email__c, PropStrength__Applicant_Mobile__c, PropStrength__Type__c, PropStrength__Applicant_Acc__r.PropStrength__Account_Type__c  
                                                        FROM PropStrength__Applicant_Detail__c
                                                        WHERE PropStrength__Application__c =:bookingId AND PropStrength__Active__c = true 
                                                        ORDER BY PropStrength__Type__c ASC];
        return applicants;
    }

    public static void docusignPostProcessing(String envelopeId, 
                                                    Id trId, 
                                                    Id myDocumentId, 
                                                    Map<String,String> emailToRoleMap,
                                                    Integer applicantsSize) {
    
        List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c
                                                                From dfsle__EnvelopeStatus__c
                                                                Where dfsle__DocuSignId__c=:envelopeId];
    
        if (docusignStatusList.size() > 0) {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'DSR';
            ds.Transaction_Request__c = trId;
            update ds;

            List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
            List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__RoutingOrder__c,Transaction_Request__c,
                                                                                dfsle__Email__c,Envelope_Type__c,
                                                                                Envelope_Recipient_Type__c 
                                                                            From dfsle__RecipientStatus__c
                                                                            Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];

            Integer i = 1;
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) {
                String drsKey=rs.dfsle__Email__c+'_'+rs.dfsle__RoutingOrder__c;
                System.debug('key is:====> '+drsKey);

                if (emailToRoleMap.containsKey(drsKey)) {
                    rs.Transaction_Request__c = trId;
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(drsKey);
                    rs.Envelope_Type__c = 'DSR';
                    if (i==applicantsSize) {
                        rs.Last_Applicant__c = true;
                    } else {
                        rs.Last_Applicant__c = false;
                    }
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
        return [Select id, Transaction_Request__c, 
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
                            FROM Docusign_Recipient_Status_Sobha__c
                            WHERE DocuSign_Envelope_Status__c=:docusignEnvelopeStatusId];
    }
    
    public static Map<string,Docusign_Recipient_Status_Sobha__c> getDocusignRecipientStatusSobhaByKey(set<Id> envIds){
        Map<string,Docusign_Recipient_Status_Sobha__c> keyToDRS = new Map<string,Docusign_Recipient_Status_Sobha__c>();
        list<Docusign_Recipient_Status_Sobha__c> drsSobhaList = [Select id, Transaction_Request__c, 
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
                s.Transaction_Request__c = dsr.Transaction_Request__c;
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

    public static String docusignEmailBody(String towerName) {
        return 
        'Dear Customer \n\n'+
        'Greetings from Sobha Realty! \n\n'+
        'We trust this communication finds you well and thank you for booking your unit in project, “'+towerName+'”. \n \n'+
        'Attached to this email is the DSR Agreement for digital signoff via DocuSign, the link for which is <b>valid for seven days</b> from the day of origination of the email. \n \n'+
        'The instructions for signing the document via DocuSign are as below: \n\n'+
        '<ol>'+
        '<li>Click on Review document and enter the OTP received on your registered mobile number to procced to sign.</li>\n'+
        '<li>Click on the Start to initiate the signing.</li>\n'+
        '<li>Draw the Initials and Signature and follow the Docusign flow to sign the Document</li> \n'+
        '<li>Click on Finish once the document is complete.</li></ol>\n'+
        '\n'+
        '<i>All terms and conditions signed between the Purchaser(s) and the Seller shall remain valid and in continuance, without any modification until specifically intimated by the Seller in writing. This email has been sent without prejudice to the Seller’s and/or Master Developer’s legal rights which are expressly reserved.</i>\n\n'+
        '<b><i>Please note that the final unit layout and areas mentioned in these documents are as per the final approvals obtained from the relevant authorities and might vary in reference to the areas mentioned in your booking form.</i></b> \n\n'+
        '<b><i>The areas mentioned in these documents shall be considered final and your unit in Dubai Land Department will be registered with these areas.</i></b> \n \n'+
        '\n'+
        '<b><i>Also, the final payment shall vary and shall be based on the areas mentioned in the attached DSR Agreement.</i></b>\n\n'+
        'Best Regards,\n\n'+
        'CRM Team \n'+
        'Sobha Realty</p>\n';
    }

    public static String docusignSellerEmailBody() {
        return 
        'Dear Seller Representative \n\n'+
        'Please find attached the DSR Agreement signed off by the customer. Please review the same and sign off.\n'+
        '\n'+
        '\n'+
        'Thank you, \n'+
        'Sobha LLC,</p>\n';
    }

    public static String docusignDldEmailBody() {
        return 
        'Dear DLD Executive \n\n'+
        'Please find attached the DSR Agreement signed off by the customer. Please review the same and sign off.\n'+
        '\n'+
        '\n'+
        'Thank you, \n'+
        'Sobha LLC,</p>\n';
    }

    public static String docusignDocumentControllerEmailBody() {
        return 
        'Dear Document Controller \n\n'+
        'Please find attached the DSR Agreement signed off by the customer. Please review the same and add stamp.\n'+
        '\n'+
        '\n'+
        'Thank you, \n'+
        'Sobha LLC,</p>\n';
    }

    public static String getAuditBody(String bookingName, String unitName) {
        return
        'Dear Audit Team,\n\nThis is to inform you that the customer signed DSR with Booking ID-'+bookingName+' for Unit # '+unitName+'has been reviewed and approved.\n\n'+
        'Request you to review and approve the DSR.Once appproved, DSR is further sent to document controller for final stamping.\n\nThanks\nSobha Realty\n';
    } 

    public static String getAccountBody(String bookingName, String unitName) {
        return
        'Dear Account Executive,\n\nThis is to inform you that the customer signed DSR with Booking ID-'+bookingName+' for Unit # '+unitName+'has been reviewed and approved.\n\n'+
        'Request you to review and approve the DSR.Once appproved, DSR is further sent to document controller for final stamping.\n\nThanks\nSobha Realty\n';
    } 

    public static String getCrmBody(String bookingName, String unitName) {
        return
        'Dear CRM Team,\n\nThis is to inform you that the customer signed DSR with Booking ID-'+bookingName+' for Unit # '+unitName+'has been reviewed and approved.\n\n'+
        'Request you to review and approve the DSR.Once appproved, DSR is further sent to document controller for final stamping.\n\nThanks\nSobha Realty\n';
    } 

    public static String validateAndUpdatePhoneNumber(String phoneNumber) {
        if (!phoneNumber.startsWith('+')) {
            phoneNumber = '+'+phoneNumber;
        }
        return phoneNumber;
    }
}