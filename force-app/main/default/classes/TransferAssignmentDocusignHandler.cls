/*********************************************************************
 * Class Name  :   TransferAssignmentDocusignHandler
 * Description :   Helper Class of Flow Send Transfer Assignment for Docusign (Flow)
 * Created Date:   04/04/2024
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Gourav Gour
    Last Modified By :   Gourav Gour 04/04/2024
 *********************************************************************/
public with sharing class TransferAssignmentDocusignHandler {
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
    
            Id myDocumentId = TransferAssignmentDocusignUtil.getFileId(mySourceId);
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
            
            PropStrength__Transaction_Requests__c tr = TransferAssignmentDocusignUtil.getTransactionRequest(mySourceId);
            List<PropStrength__Applicant_Detail__c> applicants = TransferAssignmentDocusignUtil.getApplicants(tr.PropStrength__Application_Booking__c);
            List<PropStrength__Customer_Detail__c> customerDetails = TransferAssignmentDocusignUtil.getCustomerDetails(tr.Id);

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
            Integer incXStamp = 0;
            Integer incXSign = 0;
            num = 1;
            for(PropStrength__Applicant_Detail__c applicant : authorizedMap.Values()) {
                applicantsSize=i;
                String toEmailAddress;
                String anchorString;
                String phonenumber;

                emailToRoleMap.put(applicant.PropStrength__Applicant_Email__c +'_'+i,'Applicant');
                toEmailAddress= applicant.PropStrength__Applicant_Email__c;
                anchorString = 'purchasersig' + String.valueOf(num);
                phonenumber= applicant.PropStrength__Applicant_Acc__r.VCC1__Mobile_Encrypted__c;
                // Sub Changed By Gourav Gour 08/06/2024
                String sub = 'Transfer agreement/ Transfer letter for signature UNIT number: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;           
                if(sub.length() > 100){
                    sub = 'Transfer letter for signature Unit No: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;
                }
                // String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - Seller Email';                
                String body = TransferAssignmentDocusignUtil.docusignSellerEmailBody();

                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        sub,
                                                                                                        body);
    
                //SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                String applPhoneNumber = TransferAssignmentDocusignUtil.validateAndUpdatePhoneNumber(applicant.PropStrength__Applicant_Acc__r.VCC1__Mobile_Encrypted__c);
                smsPhoneNumbers.add(applPhoneNumber);
                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );

                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                String anchorInitialsString = 'pids' + String.valueOf(num);
                dfsle.Tab myInitialHereTab = new dfsle.InitialHereTab()
                                                            .withScale(0.7)
                                                            .withRequired(true) // Signing optional
                                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                anchorInitialsString, // Anchor string
                                                                false, // Do not allow white space in anchor string
                                                                false, // Anchor string is not case sensitive
                                                                'left', // Horizontal alignment in relation to the anchor text
                                                                true, // Ignore if the anchor text is not present in the document
                                                                true, // Must match the value of the anchor string in its entirety
                                                                'pixels', // Unit of the x and y offset properties
                                                                0, // X offset
                                                                14)); // Y offset
                
                // Create a Sign Here tab for applicant
                dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
                    .withScale(0.7) // 1.5 scale
                    .withRequired(true) // Signing mandatory
                    .withAnchor(new dfsle.Tab.Anchor(
                        anchorString, // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        14)); // Y offset 

                incXSign += 15;

                applicantsTabs.add(myInitialHereTab);
                applicantsTabs.add(mySignHereTab);

                // applicant.Email_Address__c
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                        'Applicant '+num,
                                                                        toEmailAddress,
                                                                        null, 
                                                                        applicant.PropStrength__Type__c,
                                                                        null)
                                                                    .withTabs(applicantsTabs)
                                                                    .withAuthentication(auth)
                                                                    .withEmailSettings(applicantEmailSetting);
                recipientList.add(myRecipient);
                num = num + 1;
                i = i+1;
            }

            //buyers
            num = 1;
            for (PropStrength__Customer_Detail__c applicant : customerDetails) {
                emailToRoleMap.put(applicant.PropStrength__Contact__r.Email +'_'+i,'Buyer');
                String toEmailAddress;
                toEmailAddress = applicant.PropStrength__Contact__r.Email;
                // SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                String applPhoneNumber = TransferAssignmentDocusignUtil.validateAndUpdatePhoneNumber(applicant.PropStrength__Contact__r.VCC1__Mobile_Encrypted__c);
                smsPhoneNumbers.add(applPhoneNumber);
    
                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                // Sub Changed By Gourav Gour 08/06/2024
                String sub = 'Transfer agreement/ Transfer letter for signature UNIT number: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;           
                if(sub.length() > 100){
                    sub = 'Transfer letter for signature Unit No: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;
                }
                // String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - buyer Email';
                String body = TransferAssignmentDocusignUtil.docusignBuyerEmailBody();

                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en','English',sub,body);
    
                String anchorString = 'buyersign' + String.valueOf(num);
                // Create a Sign Here tab
                dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
                                                            .withScale(0.7) // 1.5 scale
                                                            .withRequired(true) // Signing mandatory
                                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                anchorString, // Anchor string
                                                                false, // Do not allow white space in anchor string
                                                                false, // Anchor string is not case sensitive
                                                                'left', // Horizontal alignment in relation to the anchor text
                                                                true, // Ignore if the anchor text is not present in the document
                                                                true, // Must match the value of the anchor string in its entirety
                                                                'pixels', // Unit of the x and y offset properties
                                                                0, // X offset
                                                                14)); // Y offset 
    
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                'Buyer '+1,
                                                                toEmailAddress,
                                                                null, 
                                                                applicant.PropStrength__Type__c,
                                                                null
                                                            )
                                                            .withTabs(new List<dfsle.Tab> {
                                                                mySignHereTab
                                                            })
                                                           .withAuthentication(auth)
                                                            .withEmailSettings(applicantEmailSetting);
                
                recipientList.add(myRecipient);
                i = i+1;
                num=num+1;
            }

            //Audit - part 3
            // Sub Changed By Gourav Gour 08/06/2024
            String auditSub = 'Transfer agreement/ Transfer letter for approval UNIT number: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;           
            if(auditSub.length() > 100){
                auditSub = 'Transfer letter for approval Unit No: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;
            }
            // String auditSub = 'DocuSign Unit # - '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name+' Booking ID#'+tr.PropStrength__Application_Booking__r.Name+' - Booking for Audit Review';
            String auditBody = TransferAssignmentDocusignUtil.getAuditBody(tr.PropStrength__Application_Booking__r.Name,tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name);
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
        
            // Sub Changed By Gourav Gour 08/06/2024
            String sub = 'Transfer agreement/ Transfer letter for Sign & Stamp UNIT number: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;           
            if(sub.length() > 100){
                sub = 'Transfer letter for Sign & Stamp Unit No: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;
            }
            List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
            // String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name + ' - Authorized Signatory Email';
            String body = TransferAssignmentDocusignUtil.docusignAuthEmailBody();
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
            applicantsTabs.add(sellerSignTab);                                                
            dfsle.SignHereTab.Stamp sellerStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
            dfsle.Tab sellerStampTab = new dfsle.SignHereTab().withStamp(sellerStamp)
                                                .withScale(0.7) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                    'sellerStamp', // Anchor string
                                                                    false, // Do not allow white space in anchor string
                                                                    false, // Anchor string is not case sensitive
                                                                    'left', // Horizontal alignment in relation to the anchor text
                                                                    true, // Ignore if the anchor text is not present in the document
                                                                    true, // Must match the value of the anchor string in its entirety
                                                                    'pixels', // Unit of the x and y offset properties
                                                                    2, // X offset
                                                                    10)
                                                            ); // Y offset
                                                                                                            
            applicantsTabs.add(sellerStampTab);
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.Seller_Representative__r.Email +'_'+i,'Seller Representative');
            i=i+1;
            dfsle.Recipient sellerRecipient = dfsle.Recipient.fromSource(
                                                            'Seller Representative', 
                                                            tr.PropStrength__Application_Booking__r.Seller_Representative__r.Email,
                                                            null, 
                                                            null,
                                                            null)
                                                        .withTabs(applicantsTabs)
                                                        .withEmailSettings(sellerEmailSetting);
            recipientList.add(sellerRecipient);

            // Sub Changed By Gourav Gour 08/06/2024
            String crmSub = 'Transfer agreement/ Transfer letter for Stamp UNIT number: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;           
            if(crmSub.length() > 100){
                crmSub = 'Transfer letter for Stamp Unit No: '+tr.PropStrength__Application_Booking__r.House_Unit_No__c+  +' Project Name: '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name;
            }
            String crmBody = TransferAssignmentDocusignUtil.docusignDocumentControllerEmailBody();
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
                                                            'CRM Document Controller', 
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
                TransferAssignmentDocusignUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap, applicantsSize);
            }
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Transfer & Asignment Agreement sent successfully sent for Docusign.';
            event.Transaction_Request_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        } 
        catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Error sending Transfer & Asignment Agreement for Docusign - '+e.getMessage();
            event.Transaction_Request_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }
}