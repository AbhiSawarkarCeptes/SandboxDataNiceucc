/*********************************************************************
 * Class Name  :   UndertakingUtil
 * Description :   Utilty Class
 * Created Date:   08/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 08/02/2024
 *********************************************************************/
public class UndertakingUtil {
    public static PropStrength__Application_Booking__c getBooking(Id bookingId) {
        PropStrength__Application_Booking__c acc = [Select id, PropStrength__Primary_Customer__c, Handover_will_be_taken_by__c, 
                        PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.MobilePhone, 
                        PropStrength__Primary_Customer__r.PropStrength__Account_Type__c, POA_Name__c, POA_Mobile_Number__c, POA_Email_Address__c 
                        FROM PropStrength__Application_Booking__c 
                        WHERE id=:bookingId LIMIT 1];
        return acc;
    }

    public static Id getFileId(Id bookId) {
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:bookId 
                                                AND ContentDocument.title = 'UndertakingDocuments.pdf'
                                                ORDER BY ContentDocument.CreatedDate desc];   
        if(docList.isEmpty()) {
            docList = HandoverOfPossessionDocumentCreator.brokerRegistrationAttacher2(new List<Id>{bookId});
        }     
        Id myDocumentId = docList[0].ContentDocumentId;
        return myDocumentId;
    }

    public static void docusignPostProcessing(String envelopeId, 
                                                    Id bookId, 
                                                    Id myDocumentId, 
                                                    Map<String,String> emailToRoleMap) {
    
        List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c
                                                                From dfsle__EnvelopeStatus__c
                                                                Where dfsle__DocuSignId__c=:envelopeId];
    
        if (docusignStatusList.size() > 0) {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'Undertaking Letter';
            ds.Application_Booking__c = bookId;
            update ds;

            List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
            List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__RoutingOrder__c,Application_Booking__c,
                                                                                dfsle__Email__c,Envelope_Type__c,
                                                                                Envelope_Recipient_Type__c 
                                                                            From dfsle__RecipientStatus__c
                                                                            Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];

            Integer i = 1;
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) {
                String drsKey=rs.dfsle__Email__c+'_'+rs.dfsle__RoutingOrder__c;
                System.debug('key is:====> '+drsKey);

                if (emailToRoleMap.containsKey(drsKey)) {
                    rs.Application_Booking__c = bookId;
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(drsKey);
                    rs.Envelope_Type__c = 'Undertaking Letter';
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

    public static String docusignEmailBody() {
        return 
        'Dear Sir/Madam \n\n'+
        'Please find attached the Undertaking Letter for the property purchased from Sobha LLC (“<b>Seller</b>”). The document once opened shall be signed and returned to the Seller. \n\n'+
        'The said document when executed will be kept in safe custody of the Seller, and one soft copy will be provided to you for your records. \n'+
        '<ol>'+
        '<li>Click on Review document and enter the OTP received on your registered mobile number to procced to sign.</li>'+
        '<li>Click on the Start to initiate the signing.</li>'+
        '<li>Draw the Initials and Signature and follow the Docusign flow to sign the Document</li> '+
        '<li>Click on Finish once the document is complete.</li></ol>\n'+
        '<ol>'+
        'On agreeing and consenting on below, the Purchaser(s) jointly, severally and irrevocably accept that: \n \n'+
        'The instructions for signing the document via DocuSign are as below: \n\n'+
        '<li>You have read and understood the terms and conditions of the Undertaking Letter. Further, you agree and acknowledge that you have duly understood the content and that by signing the Undertaking Letter in electronic form you will be bound by it as if you have signed the document in ink;</li>\n'+
        '<li>You agree to the comply with the restrictions and penalties as specified in the Undertaking Letter.</li>\n'+
        '<li>You have agreed to comply with the payment plan mentioned in the Undertaking Letter and shall always adhere to the same and make timely payments;</li> \n'+
        '<li>You agree and consent to share your personal details including bank details to the Seller as per the applicable data protections laws applicable in the UAE and Seller undertakes that such data shall be used only for the purposes of this sale and purchase transaction and other offers and proposals by the Seller, during the course;</li>\n'+
        '<li>You confirm that you shall never contravene the electronic signature. It is further agreed and acknowledged that the electronic signature shall be enforceable before the non-exclusive jurisdiction of the courts of UAE, and you shall not object to it on the account of it being an electronic signature;</li>\n'+
        '<li>You confirm that you are the only individual authorized to access the Undertaking Letter received from the Seller electronically. You must not share or disclose the password or other secure method to access Undertaking Letter delivered electronically. You must take all reasonable measures to protect the access devices to prevent unauthorized access to Undertaking Letter delivered electronically;</li>\n'+
        '<li>You hereby agree to notify the Seller promptly of any changes to mailing address, e-mail address, or other information. You agree to hold harmless the Seller (including its Shareholder, Director, Representative, Employees, parent company)  in connection with the your failure to provide current and valid contact information;</li>\n'+
        '<li>You agree to defend, indemnify and hold harmless the Seller, its affiliates, licensors and service providers, and its and their respective officers, directors, employees, contractors, agents, licensors, suppliers, successors and assigns from and against any claims, liabilities, damages, judgments, awards, losses, costs, expenses or fees (including reasonable attorneys’ fees) arising out of or relating to your violation of the terms and conditions mentioned herein.</li>\n'+
        '<li>You hereby acknowledge and agree that the Seller is the sole and exclusive owner of the Intellectual Property and that any goodwill or other right, interest or benefit flowing directly or indirectly from the Intellectual Property is and remains at all times the sole property of the Seller. You agree that it shall not utilize any of the Intellectual Property of the Seller for the purposes of selling or marketing the property.</li>\n'+
        '<li>You hereby agree to adhere and comply with the Federal Decree-Law No. 46/2021 on Electronic Transactions and Trust Services and any other laws and regulations applicable in the UAE. </li>\n'+
        '<li>You hereby acknowledge and undertake that you shall submit the Undertaking Letter within seven (07) calendar days from the date of receiving the Undertaking Letter, to the Seller’s portal, and the failure to do so shall result in auto rejection of the reservation made on your behalf for the unit in the Seller’s system. Upon rejection of the Undertaking Letter from the Seller’s system, the Seller shall have the right to sell the unit to any third party without any requirement to notify you about the same. </li>\n'+
        '</ol>'+
        '\n'+
        'For any clarifications, please reach out to us on contact no: +97144238064 and email: helpdesk@sobharealty.com\n'+
        'For further updates and queries post signing, please contact with your Sales Manager \n\n'+
        'Thank you,\n'+
        'Yours faithfully \n'+
        'Sobha Realty</p>\n';
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
}