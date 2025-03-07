/*********************************************************************
 * Class Name  :   NOC_TR_DocusignHandler
 * Description :   Helper Class of Flow Send Transfer Assignment for Docusign (Flow)
 * Created Date:   04/04/2024
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Gourav Gour
    Last Modified By :   Gourav Gour 04/04/2024
 *********************************************************************/
public with sharing class NOC_TR_DocusignHandler {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> transactionReqIds) {
        Id mySourceId = transactionReqIds[0];
        forForSigningFuture(mySourceId);
    } 
    
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            Map<String,String> emailToRoleMap = new Map<String,String>();
    
            Id myDocumentId = NOC_TR_DocusignUtil.getFileId(mySourceId);
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
            
            PropStrength__Transaction_Requests__c tr = NOC_TR_DocusignUtil.getTransactionRequest(mySourceId);

            Integer i=1;
            //Pass the booking record id
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
        
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
        
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();

            //Audit - part 1
            String auditSub = 'DocuSign Unit # - '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name+' Booking ID#'+tr.PropStrength__Application_Booking__r.Name+' - Booking for Audit Review';
            String auditBody = NOC_TR_DocusignUtil.getAuditBody(tr.PropStrength__Application_Booking__r.Name,tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name);
            dfsle.Recipient.EmailSettings auditEmailSetting = new dfsle.Recipient.EmailSettings('en','English',auditSub,auditBody);
            
            String auditTeamApproveAnchor = 'auditteamapprove';
            String auditTeamDeclineAnchor = 'auditteamdecline';

            dfsle.Tab auditTeamApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            auditTeamApproveAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'left', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            14)); // Y offset
            dfsle.Tab auditTeamDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            auditTeamDeclineAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'left', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            14)); // Y offset
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.Docusign_Audit_Email__c +'_'+i,'Audit Team');
            i=i+1;
            dfsle.Recipient auditTeam = dfsle.Recipient.fromSource(
                                                            'Audit Team', 
                                                            tr.PropStrength__Application_Booking__r.Docusign_Audit_Email__c,
                                                            null,
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                            auditTeamApproveTab,auditTeamDeclineTab
                                                        })
                                                        .withEmailSettings(auditEmailSetting);
            
            recipientList.add(auditTeam);
        
            String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name + ' - Authorized Signatory Email';
            String body = NOC_TR_DocusignUtil.docusignSellerEmailBody();
            dfsle.Recipient.EmailSettings sellerEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                    'English',
                                                                                                    sub,
                                                                                                    body);
            dfsle.Tab sellerSignTab = new dfsle.SignHereTab()
                                                .withScale(0.7) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                        'authsign', // Anchor string
                                                                        false, // Do not allow white space in anchor string
                                                                        false, // Anchor string is not case sensitive
                                                                        'left', // Horizontal alignment in relation to the anchor text
                                                                        true, // Ignore if the anchor text is not present in the document
                                                                        true, // Must match the value of the anchor string in its entirety
                                                                        'pixels', // Unit of the x and y offset properties
                                                                        0, // X offset
                                                                        14)
                                                            ); // Y offset 
            
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.Seller_Representative__r.Email +'_'+i,'Seller Representative');
            i=i+1;
            dfsle.Recipient sellerRecipient = dfsle.Recipient.fromSource(
                                                            'Seller Representative', 
                                                            tr.PropStrength__Application_Booking__r.Seller_Representative__r.Email,
                                                            null, 
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                                sellerSignTab
                                                            })
                                                        .withEmailSettings(sellerEmailSetting);
            recipientList.add(sellerRecipient);


            String crmSub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name + ' - NOC for Digital Signoff';
            String crmBody = NOC_TR_DocusignUtil.docusignDocumentControllerEmailBody();
            dfsle.Recipient.EmailSettings crmDocuStamp = new dfsle.Recipient.EmailSettings('en',
                                                                                                    'English',
                                                                                                    crmSub,
                                                                                                    crmBody);
            
            dfsle.SignHereTab.Stamp crmStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
            dfsle.Tab crmStampTab = new dfsle.SignHereTab().withStamp(crmStamp)
                                                .withScale(0.7) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                    'crmstamp', // Anchor string
                                                                    false, // Do not allow white space in anchor string
                                                                    false, // Anchor string is not case sensitive
                                                                    'left', // Horizontal alignment in relation to the anchor text
                                                                    true, // Ignore if the anchor text is not present in the document
                                                                    true, // Must match the value of the anchor string in its entirety
                                                                    'pixels', // Unit of the x and y offset properties
                                                                    2, // X offset
                                                                    10)
                                                            ); // Y offset
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.CRM_Document_Controller__r.Email +'_'+i,'CRM Document Controller');
            i=i+1;
            dfsle.Recipient crmDocuumentRecipient = dfsle.Recipient.fromSource(
                                                            'CRM Document Controller', // @Deepak Added by 
                                                            /*tr.PropStrength__Application_Booking__r.CRM_Document_Controller__r.Name,*/
                                                            tr.PropStrength__Application_Booking__r.CRM_Document_Controller__r.Email,
                                                            null, 
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                                crmStampTab
                                                            })
                                                        .withEmailSettings(crmDocuStamp);
            recipientList.add(crmDocuumentRecipient);

            
            Integer expiryDays = Integer.valueOf(docusignDefaultSettings.Booking_Form_Expiry_Days__c);

            dfsle.Notifications expirySettings = new dfsle.Notifications(
                                                                    false, // Indicates that reminders are enabled
                                                                    null, // Number of days to wait before sending a reminder
                                                                    null, // Number of days between reminders
                                                                    true, // Whether or not the envelope expires and is voided
                                                                    expiryDays, // Number of days before the envelope expires
                                                                    null, // Number of days before expiration to remind the recipient
                                                                    false // Placeholder for deprecated field
                                                                ); 
        
            //Add the signers...
            myEnvelope = myEnvelope
                        .withRecipients(recipientList)
                        .withNotifications(expirySettings );
            
            // Send the envelope!
            if(!Test.isRunningTest()) {
                myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                    myEnvelope,
                    true
                );
                
                String envelopeId = String.valueOf(myEnvelope.docuSignId);
                NOC_TR_DocusignUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap);
            }
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'NOC sent successfully sent for Docusign.';
            event.Transaction_Request_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        } 
        catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Error sending NOC for Docusign - '+e.getMessage();
            event.Transaction_Request_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }
}