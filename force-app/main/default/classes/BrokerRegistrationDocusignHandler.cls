/*********************************************************************
 * Class Name  :   BrokerRegistrationDocusignHandler
 * Description :   Helper Class of Flow Send Broker Registration for Docusign (Flow)
 * Created Date:   06/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 06/02/2024
                         Gourav Gour 02/05/20024
 *********************************************************************/
public with sharing class BrokerRegistrationDocusignHandler {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> accId) {
        Id mySourceId = accId[0];
        forForSigningFuture(mySourceId);
    } 
    
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            // AuthorisedrepresentativeSOBHAforBrokerDo__mdt  authorisedRepresCM = AuthorisedrepresentativeSOBHAforBrokerDo__mdt.getInstance('Sobha_LLC');
            Map<String,String> emailToRoleMap = new Map<String,String>();
    
            Id myDocumentId = BrokerRegistrationDocusignUtil.getFileId(mySourceId);
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
            
            Account accRec = BrokerRegistrationDocusignUtil.getAccount(mySourceId);

            Integer i=1;
            Decimal scaleValue;
            Integer yOffset;
            scaleValue = 1.0;
            yOffset = 5;

            // system.debug('authorisedRepresCM***');
            // system.debug(authorisedRepresCM);

            //Pass the booking record id
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
        
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
        
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
            
            //CHRM_Ops Team - part 1 Added By Gourav Gour 31/05/2024
            String chrmopsSub = 'Broker Agreement Approval - '+accRec.Name ;
            
            String chrmopsBody = BrokerRegistrationDocusignUtil.getCHRMOpsBody(accRec.Name);
            dfsle.Recipient.EmailSettings chrmopsEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                'English',
                                                                                                chrmopsSub,
                                                                                                chrmopsBody);
            String chrmopsTeamApproveAnchor = 'chrmopsteamapprove';
            String chrmopsTeamDeclineAnchor = 'chrmopsteamdecline';
            dfsle.Tab chrmopsTeamApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            chrmopsTeamApproveAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'left', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            20)); // Y offset
            dfsle.Tab chrmopsTeamDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            chrmopsTeamDeclineAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'left', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            20)); // Y offset

            String chrmOpsEmail = String.valueOf(accRec.CHRM_Ops_Email__c);                                                
            // if(accRec.PropStrength__Broker_Type__c == 'Sobha Connect') {
            //     chrmOpsEmail = [SELECT ID,email FROM Group WHERE DeveloperName ='Broker_Registration_Sobha_Connect_Queue'].email  ;                                             
            // }                                                                                     
            // if(accRec.PropStrength__Broker_Type__c == '	Standard') {
            //     chrmOpsEmail = [SELECT ID,email FROM Group WHERE DeveloperName ='Broker_Reg_Channel_Partner_queue'].email  ;                                             
            // }                                                                                     
            emailToRoleMap.put(chrmOpsEmail+'_'+i,'chrmops Team'); 
            i=i+1;
            dfsle.Recipient chrmopsTeam = dfsle.Recipient.fromSource(
                                                            'chrmops Team',
                                                            chrmOpsEmail,
                                                            null,
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                            chrmopsTeamApproveTab,chrmopsTeamDeclineTab
                                                        })
                                                        .withEmailSettings(chrmopsEmailSetting);
            
            recipientList.add(chrmopsTeam);

            //Broker - part 2
            if(accRec.Name != null && accRec.Email_ID_1__c != null) {
                emailToRoleMap.put(accRec.Email_ID_1__c +'_'+i,'Authorised Representative');

                String sub = 'Sobha Realty Registration – Agreement ready for Signature';
                String body = BrokerRegistrationDocusignUtil.docusignEmailBody(accRec);

                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        sub,
                                                                                                        body);
    
                //SMS authentication phone numbers
                // List<String> smsPhoneNumbers = new List<String>();
                // String applPhoneNumber = BrokerRegistrationDocusignUtil.validateAndUpdatePhoneNumber(accRec.Mobile_No__c);
                // smsPhoneNumbers.add(applPhoneNumber);

                //Set the authentication
                // dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                
                String anchorString = 'brokersignsobha';

                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                String anchorInitialsString = 'brokerinitialsds';

                dfsle.Tab myInitialHereTab = new dfsle.InitialHereTab()
                                                            .withScale(0.8)
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
                                                                22)); // Y offset
                
                // Create a Sign Here tab for applicant
                dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
                    .withScale(scaleValue) // 1.5 scale
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
                        yOffset)); // Y offset 

                applicantsTabs.add(mySignHereTab);
                applicantsTabs.add(myInitialHereTab);

                if (accRec.Broker_Category__c.containsIgnoreCase('Company')) {
                    dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                .withScale(1.0) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                    'brokerStamp', // Anchor string
                                                                    false, // Do not allow white space in anchor string
                                                                    false, // Anchor string is not case sensitive
                                                                    'left', // Horizontal alignment in relation to the anchor text
                                                                    true, // Ignore if the anchor text is not present in the document
                                                                    true, // Must match the value of the anchor string in its entirety
                                                                    'pixels', // Unit of the x and y offset properties
                                                                    0, // X offset
                                                                    0)
                                                            ); // Y offset

                    applicantsTabs.add(corpAppStampTab);
                }
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                        accRec.Name,
                                                                        accRec.Email_ID_1__c,
                                                                        null, 
                                                                        null,
                                                                        null)
                                                                    .withTabs(applicantsTabs)
                                                                    //.withAuthentication(auth)
                                                                    .withEmailSettings(applicantEmailSetting);
                recipientList.add(myRecipient);

                i = i+1;
            }
            // Commented By Gourav Gour 10/05/2024 Document only signed by the broker
        /*    
            if(authorisedRepresCM.Print_name_of_Authorised_Representative__c != null && authorisedRepresCM.Authorised_Representative__c != null) {
                emailToRoleMap.put(authorisedRepresCM.Authorised_Representative__c +'_'+i,'Sobha LLC');

                String sub = 'Broker Agreement Form';
                String body = BrokerRegistrationDocusignUtil.docusignEmailBody();

                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        sub,
                                                                                                        body);
                
                String anchorString = 'vpSignTab';

                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                String anchorInitialsString = 'sobhainitials';

                dfsle.Tab myInitialHereTab = new dfsle.InitialHereTab()
                                                            .withScale(0.5)
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
                                                                20)); // Y offset
                // Create a Sign Here tab for applicant
                dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
                    .withScale(scaleValue) // 1.5 scale
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
                        yOffset)); // Y offset 

                applicantsTabs.add(mySignHereTab);
                applicantsTabs.add(myInitialHereTab);

                
                dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                            .withScale(1.0) // 1.5 scale
                                            .withRequired(true) // Signing mandatory
                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                'vpstamptab', // Anchor string
                                                                false, // Do not allow white space in anchor string
                                                                false, // Anchor string is not case sensitive
                                                                'left', // Horizontal alignment in relation to the anchor text
                                                                true, // Ignore if the anchor text is not present in the document
                                                                true, // Must match the value of the anchor string in its entirety
                                                                'pixels', // Unit of the x and y offset properties
                                                                0, // X offset
                                                                0)
                                                        ); // Y offset

                applicantsTabs.add(corpAppStampTab);
    
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                        authorisedRepresCM.Print_name_of_Authorised_Representative__c,
                                                                        authorisedRepresCM.Authorised_Representative__c,
                                                                        null, 
                                                                        null,
                                                                        null)
                                                                    .withTabs(applicantsTabs)
                                                                    .withEmailSettings(applicantEmailSetting);
                recipientList.add(myRecipient);

                i = i+1;
            }

        */
            
            
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
                BrokerRegistrationDocusignUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap);
                Account acc = new Account(Id = mySourceId, PropStrength__Broker_Approval_Status__c = 'Agreement created and send for Review', Agreement_Created_Sent_Date__c = System.today(),Expiry_Date__c = System.today().addYears(1), Broker_Expiry_Date__c = System.today().addYears(1) );
                update acc;
            }
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Broker Registration Form sent successfully sent for Docusign.';
            event.Booking_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        } 
        catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Error sending Broker Registration for Docusign - '+e.getMessage();
            event.Booking_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }
}