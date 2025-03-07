/*********************************************************************
 * Class Name  :   DSRDocusignHandler
 * Description :   Helper Class of Flow Send DSR for Docusign (Flow)
 * Created Date:   12/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 12/02/2024
 *********************************************************************/
public with sharing class DSRDocusignHandler {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> transactionReqIds) {
        Id mySourceId = transactionReqIds[0];

        PropStrength__Transaction_Requests__c tr = [SELECT Id, PropStrength__Application_Booking__c FROM PropStrength__Transaction_Requests__c WHERE Id = :mySourceId];

        PropStrength__Application_Booking__c updateBook = new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c);
        updateBook.DSR_Generated_Date__c = System.Today();
        update updateBook;
        forForSigningFuture(mySourceId);
    } 
    
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            Map<String,String> emailToRoleMap = new Map<String,String>();    
            Id myDocumentId = DSRDocusignUtil.getFileId(mySourceId);
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
            
            PropStrength__Transaction_Requests__c tr = DSRDocusignUtil.getTransactionRequest(mySourceId);
            List<PropStrength__Applicant_Detail__c> applicants = DSRDocusignUtil.getApplicants(tr.PropStrength__Application_Booking__c);

            Integer i=1;
            Integer applicantsSize = applicants.size();
            Decimal scaleValue;
            Integer yOffset = 0;
            if (applicantsSize > 3) {
                scaleValue = 0.5;
                yOffset = 10;
            } else {
                scaleValue = 1.0;
                yOffset = 5;
            }

            //Pass the booking record id
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
        
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
        
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
            //Integer i = 1;
            Map<Integer, PropStrength__Applicant_Detail__c> authorizedMap = new Map<Integer, PropStrength__Applicant_Detail__c>();
            Integer num=1;
            for (PropStrength__Applicant_Detail__c applicant:applicants)  {
                //authirised signature logic starts here
                authorizedMap.put(num, applicant);
                num++;
            }

            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email +'_'+i,'Applicant');

            String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - DSR Agreement for Digital Signoff';
            String body = DSRDocusignUtil.docusignEmailBody(tr.PropStrength__Application_Booking__r.PropStrength__Tower__c);

            dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                    'English',
                                                                                                    sub,
                                                                                                    body);

            //SMS authentication phone numbers
            List<String> smsPhoneNumbers = new List<String>();
            String applPhoneNumber = DSRDocusignUtil.validateAndUpdatePhoneNumber(tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone);
            smsPhoneNumbers.add(applPhoneNumber);

            //Set the authentication
            dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
            
            List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();

            String anchorString = 'WHEREOF';
            // Create a Sign Here tab
            dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
                                                        .withScale(1.0) // 1.5 scale
                                                        .withRequired(true) // Signing mandatory
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            anchorString, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            -70, // X offset
                                                            170)); // Y offset  
            applicantsTabs.add(mySignHereTab);

            if(tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.PropStrength__Account_Type__c == 'Company') {
                dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                            .withScale(0.8) // 1.5 scale
                                            .withRequired(true) // Signing mandatory
                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                'WHEREOF', // Anchor string
                                                                false, // Do not allow white space in anchor string
                                                                false, // Anchor string is not case sensitive
                                                                'right', // Horizontal alignment in relation to the anchor text
                                                                true, // Ignore if the anchor text is not present in the document
                                                                true, // Must match the value of the anchor string in its entirety
                                                                'pixels', // Unit of the x and y offset properties
                                                                10, // X offset
                                                                170)
                                                        ); // Y offset
                applicantsTabs.add(corpAppStampTab);
            }

            dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                    tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name,
                                                                    tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email,
                                                                    null, 
                                                                    null,
                                                                    null)
                                                                .withTabs(applicantsTabs)
                                                                .withAuthentication(auth)
                                                                .withEmailSettings(applicantEmailSetting);
            recipientList.add(myRecipient);

            i = i+1;

            //Audit - part 2
            String accountSub = 'DocuSign Unit # - '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name+' Booking ID#'+tr.PropStrength__Application_Booking__r.Name+' - Booking for Account Review';
            String accountBody = DSRDocusignUtil.getAccountBody(tr.PropStrength__Application_Booking__r.Name,tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name);
            dfsle.Recipient.EmailSettings accountEmailSetting = new dfsle.Recipient.EmailSettings('en','English',accountSub,accountBody);
            
            String accountApprove = 'Seller Details';
            String accountDecline = 'Seller Details';

            dfsle.Tab accountApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            accountApprove, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            25, // X offset
                                                            0)); // Y offset
            dfsle.Tab accountDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            accountDecline, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            150, // X offset
                                                            0)); // Y offset
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Accounts_Executive__r.Email +'_'+i,'Account Team');
            i=i+1;
            dfsle.Recipient accountTeam = dfsle.Recipient.fromSource(
                                                            'Account Team', 
                                                            tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Accounts_Executive__r.Email,
                                                            null,
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                            accountApproveTab,accountDeclineTab
                                                        })
                                                        .withEmailSettings(accountEmailSetting);
            
            recipientList.add(accountTeam);
        
            //CRM - part 3
            String crmSub = 'DocuSign Unit # - '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name+' Booking ID#'+tr.PropStrength__Application_Booking__r.Name+' - Booking for CRM Review';
            String crmBody = DSRDocusignUtil.getCrmBody(tr.PropStrength__Application_Booking__r.Name,tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name);
            dfsle.Recipient.EmailSettings crmEmailSetting = new dfsle.Recipient.EmailSettings('en','English',crmSub,crmBody);
            
            String crmApprove = 'Seller Details';
            String crmDecline = 'Seller Details';

            dfsle.Tab crmApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            crmApprove, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            25, // X offset
                                                            0)); // Y offset
            dfsle.Tab crmDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            crmDecline, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            150, // X offset
                                                            0)); // Y offset
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.CRM_Executive__r.Email +'_'+i,'CRM Document Controller');
            i=i+1;
            dfsle.Recipient crmTeam = dfsle.Recipient.fromSource(
                                                            'CRM Document Controller', 
                                                            tr.PropStrength__Application_Booking__r.CRM_Executive__r.Email,
                                                            null,
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                            crmApproveTab,crmDeclineTab
                                                        })
                                                        .withEmailSettings(crmEmailSetting);
            
            recipientList.add(crmTeam);
            

            //Audit - part 4
            String auditSub = 'DocuSign Unit # - '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name+' Booking ID#'+tr.PropStrength__Application_Booking__r.Name+' - Booking for Audit Review';
            String auditBody = DSRDocusignUtil.getAuditBody(tr.PropStrength__Application_Booking__r.Name,tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name);
            dfsle.Recipient.EmailSettings auditEmailSetting = new dfsle.Recipient.EmailSettings('en','English',auditSub,auditBody);
            
            String auditApprove = 'Seller Details';
            String auditDecline = 'Seller Details';

            dfsle.Tab auditApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            auditApprove, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            25, // X offset
                                                            0)); // Y offset
            dfsle.Tab auditDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            auditDecline, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            150, // X offset
                                                            0)); // Y offset
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Accounts_Executive__r.Email +'_'+i,'Audit Team');
            i=i+1;
            dfsle.Recipient auditTeam = dfsle.Recipient.fromSource(
                                                            'Audit Team	', 
                                                            tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Accounts_Executive__r.Email,
                                                            null,
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                            auditApproveTab,auditDeclineTab
                                                        })
                                                        .withEmailSettings(auditEmailSetting);
            
            recipientList.add(auditTeam);


            //Authorised Signatory

            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email +'_'+i,'Seller Representative');

            String srSub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - DSR Agreement for Digital Signoff';
            String srBody = DSRDocusignUtil.docusignSellerEmailBody();

            dfsle.Recipient.EmailSettings sellerRepEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                    'English',
                                                                                                    srSub,
                                                                                                    srBody);
            
            List<dfsle.Tab> sellereRepTab = new List<dfsle.Tab>();

            String anchorStringsr = 'WHEREOF';
            // Create a Sign Here tab
            dfsle.Tab mySignHereTabsr = new dfsle.SignHereTab()
                                                        .withScale(1.0) // 1.5 scale
                                                        .withRequired(true) // Signing mandatory
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            anchorStringsr, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            -80, // X offset
                                                            90)); // Y offset  
            sellereRepTab.add(mySignHereTabsr);

            dfsle.Recipient myRecipientSR = dfsle.Recipient.fromSource(
                                                                    tr.PropStrength__Application_Booking__r.Seller_Representative__r.Name,
                                                                    tr.PropStrength__Application_Booking__r.Seller_Representative__r.Email,
                                                                    null, 
                                                                    null,
                                                                    null)
                                                                .withTabs(sellereRepTab)
                                                                .withEmailSettings(sellerRepEmailSetting);
            recipientList.add(myRecipientSR);

            i = i+1;


            //DLD Stamp
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email +'_'+i,'DLD Executive');

            String dldSub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - DSR Agreement for Digital Signoff';
            String dldBody = DSRDocusignUtil.docusignDldEmailBody();

            dfsle.Recipient.EmailSettings dldExeEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                    'English',
                                                                                                    dldSub,
                                                                                                    dldBody);

            List<dfsle.Tab> dldTabs = new List<dfsle.Tab>();

                dfsle.SignHereTab.Stamp corpAppStamp1 = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                dfsle.Tab corpAppStampTab1 = new dfsle.SignHereTab().withStamp(corpAppStamp1)
                                            .withScale(1.0) // 1.5 scale
                                            .withRequired(true) // Signing mandatory
                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                'WHEREOF', // Anchor string
                                                                false, // Do not allow white space in anchor string
                                                                false, // Anchor string is not case sensitive
                                                                'right', // Horizontal alignment in relation to the anchor text
                                                                true, // Ignore if the anchor text is not present in the document
                                                                true, // Must match the value of the anchor string in its entirety
                                                                'pixels', // Unit of the x and y offset properties
                                                                60, // X offset
                                                                220)
                                                        ); // Y offset
                dldTabs.add(corpAppStampTab1);
                dfsle.Recipient myRecipientDLD = dfsle.Recipient.fromSource(
                                                                    tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name,
                                                                    tr.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email,
                                                                    null, 
                                                                    null,
                                                                    null)
                                                                .withTabs(dldTabs)
                                                                .withEmailSettings(dldExeEmailSetting);
            recipientList.add(myRecipientDLD);

            i = i+1;


            
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
                DSRDocusignUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap, applicantsSize);
            }
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'SPA Letter sent successfully sent for Docusign.';
            event.Transaction_Request_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        } 
        catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Error sending SPA Letter for Docusign - '+e.getMessage();
            event.Transaction_Request_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }
}