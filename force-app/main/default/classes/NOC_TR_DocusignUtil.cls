/*********************************************************************
 * Class Name  :   NOC_TR_DocusignUtil
 * Description :   Utilty Class
 * Created Date:   04/04/2024
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Gourav Gour
    Last Modified By :   Gourav Gour 04/04/2024
 *********************************************************************/
public with sharing class NOC_TR_DocusignUtil {
    public static PropStrength__Transaction_Requests__c getTransactionRequest(Id trId) {
        PropStrength__Transaction_Requests__c trRec = [Select id,PropStrength__Application_Booking__r.PropStrength__Tower__c,PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c, 
                                        Name,PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.Name, PropStrength__Application_Booking__r.PropStrength__Property__r.Name,
                                        PropStrength__Application_Booking__r.POA_Name__c, PropStrength__Application_Booking__r.POA_Email_Address__c, PropStrength__Application_Booking__r.Seller_Representative__c, PropStrength__Application_Booking__r.Seller_Representative__r.Email,
                                        PropStrength__Application_Booking__r.Seller_Representative__r.Name, PropStrength__Application_Booking__r.CRM_Document_Controller__r.Name, PropStrength__Application_Booking__r.CRM_Document_Controller__r.Email, PropStrength__Application_Booking__r.Docusign_Audit_Email__c,
                                        PropStrength__Application_Booking__r.POA_Mobile_Number__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name 
                                        FROM PropStrength__Transaction_Requests__c 
                                        WHERE id=:trId LIMIT 1];
        return trRec;
    }

    public static Id getFileId(Id trId) {
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:trId 
                                                AND ContentDocument.title LIKE '%NOC%'
                                                ORDER BY ContentDocument.CreatedDate desc];   
        Id myDocumentId = docList[0].ContentDocumentId;
        return myDocumentId;
    }
    public static void docusignPostProcessing(String envelopeId, Id trId, 
                                                    Id myDocumentId, 
                                                    Map<String,String> emailToRoleMap
                                                    ) {
    
        List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c
                                                                From dfsle__EnvelopeStatus__c
                                                                Where dfsle__DocuSignId__c=:envelopeId];
    
        if (docusignStatusList.size() > 0) {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'NOC TR';
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
                String drsKey= rs.dfsle__Email__c+'_'+rs.dfsle__RoutingOrder__c;
                System.debug('key is:====> '+drsKey);

                if (emailToRoleMap.containsKey(drsKey)) {
                    rs.Transaction_Request__c = trId;
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(drsKey);
                    rs.Envelope_Type__c = 'NOC TR';
                    rsToUpdateList.add(rs);
                }
                i += 1;
            }                                                       
            update rsToUpdateList;
            system.debug(rsToUpdateList);
        }
    }
    public static String docusignDocumentControllerEmailBody() {
        return 
        'Dear Document Controller \n\n'+
        'Please find attached the NOC signed off by the customer. Please review the same and add stamp.\n'+
        '\n'+
        '\n'+
        'Thank you, \n'+
        'Sobha LLC,</p>\n';
    }

    public static String docusignSellerEmailBody() {
        return 
        'Dear Customer \n\n'+
            'Greetings from Sobha Realty! \n\n'+
            'We trust this communication finds you well. \n\n'+
            'Attached to this email is the Assignment Agreement for digital signoff via DocuSign, the link for which is valid for seven days from the day of origination of the email. \n\n'+
            'The instructions for signing the document via DocuSign are as below: \n'+
            '<ol>'+
            '<li>Click on Review document and enter the OTP received on your registered mobile number to procced to sign..</li>'+
            '<li>Click on the Start to initiate the signing.</li> '+
            '<li>Draw the Signature and follow the Docusign flow to sign the Document</li>'+
            '<li>Click on Finish once the document is complete.</li></ol>\n'+
            '<ol>'+
            'Best Regards,\n\n'+
            'CRM Team \n'+
            'Sobha Realty</p>\n';
    }

    public static String validateAndUpdatePhoneNumber(String phoneNumber) {
        if (!phoneNumber.startsWith('+')) {
            phoneNumber = '+'+phoneNumber;
        }
        return phoneNumber;
    }
    public static String getAuditBody(String bookingName, String unitName) {
        return
        'Dear Audit Team,\n\nThis is to inform you that the Seller & Buyer signed Transfer & Assignment Agreement with Booking ID-'+bookingName+' for Unit # '+unitName+'has been reviewed and approved.\n\n'+
        'Request you to review and approve the Transfer & Assignment Agreement.Once appproved, Transfer & Assignment Agreement is further sent to Seller trepresentative for final signature.\n\nThanks\nSobha Realty\n';
    } 
    public static String docusignBuyerEmailBody() {
        return 
        'Dear Customer \n\n'+
            'Greetings from Sobha Realty! \n\n'+
            'We trust this communication finds you well. \n\n'+
            'Attached to this email is the Assignment Agreement for digital signoff via DocuSign, the link for which is valid for seven days from the day of origination of the email. \n\n'+
            'The instructions for signing the document via DocuSign are as below: \n'+
            '<ol>'+
            '<li>Click on Review document and enter the OTP received on your registered mobile number to procced to sign..</li>'+
            '<li>Click on the Start to initiate the signing.</li> '+
            '<li>Draw the Signature and follow the Docusign flow to sign the Document</li>'+
            '<li>Click on Finish once the document is complete.</li></ol>\n'+
            '<ol>'+
            'Best Regards,\n\n'+
            'CRM Team \n'+
            'Sobha Realty</p>\n';
    }
    public static String docusignAuthEmailBody()
    	{	
            return 
                'Dear Seller Representative \n\n'+
            	'Please find attached the Assignment Agreement signed off by the customer. Please review the same and sign off.\n'+
            	'\n'+
            	'\n'+
            	'Best Regards,\n\n'+
                'CRM Team \n'+
                'Sobha Realty</p>\n';      
    	}
}