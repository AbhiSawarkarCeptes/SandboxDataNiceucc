/*********************************************************************
 * Class Name  :   HandoverOfPossessionDocusignHandler
 * Description :   Helper Class of Flow Send HOP And UL for Docusign (Flow)
 * Created Date:   08/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 08/02/2024
 *********************************************************************/
public with sharing class HandoverOfPossessionDocusignHandler {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> bookId) {
        Id mySourceId = bookId[0];

        forForSigningFuture(mySourceId);
    } 
    
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            Map<String,String> emailToRoleMap = new Map<String,String>();
    
            Id myDocumentId = HandoverOfPossessionUtil.getFileId(mySourceId);
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
            
            PropStrength__Application_Booking__c booking = HandoverOfPossessionUtil.getBooking(mySourceId);

            Integer i=1;
            Decimal scaleValue;
            Integer yOffset;
            scaleValue = 1.0;
            yOffset = 5;

            //Pass the booking record id
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
        
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
        
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
            

            if(booking.Handover_will_be_taken_by__c == 'Owner – Individual') {
                if(booking.PropStrength__Primary_Customer__c != null && booking.PropStrength__Primary_Customer__r.PropStrength__Account_Type__c == 'Individual') {
                    if(booking.PropStrength__Primary_Customer__r.Name != null && booking.PropStrength__Primary_Customer__r.Email != null) {
                        emailToRoleMap.put(booking.PropStrength__Primary_Customer__r.Email +'_'+i,'Primary Customer');

                        String sub = 'Handover Of Possession Letter';
                        String body = HandoverOfPossessionUtil.docusignEmailBody();

                        dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                                'English',
                                                                                                                sub,
                                                                                                                body);
            
                        //SMS authentication phone numbers
                        List<String> smsPhoneNumbers = new List<String>();
                        String applPhoneNumber = HandoverOfPossessionUtil.validateAndUpdatePhoneNumber(booking.PropStrength__Primary_Customer__r.MobilePhone);
                        smsPhoneNumbers.add(applPhoneNumber);

                        //Set the authentication
                        dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                        
                        String anchorString = 'primaryContactOrPOASign';

                        List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                        
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
            
                        dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                                booking.PropStrength__Primary_Customer__r.Name,
                                                                                booking.PropStrength__Primary_Customer__r.Email,
                                                                                null, 
                                                                                null,
                                                                                null)
                                                                            .withTabs(applicantsTabs)
                                                                            .withAuthentication(auth)
                                                                            .withEmailSettings(applicantEmailSetting);
                        recipientList.add(myRecipient);

                        i = i+1;
                    }
                }
            } else if(booking.Handover_will_be_taken_by__c == 'Owner – Company') {
                if(booking.PropStrength__Primary_Customer__c != null && booking.PropStrength__Primary_Customer__r.PropStrength__Account_Type__c == 'Company') {
                    if(booking.PropStrength__Primary_Customer__r.Name != null && booking.PropStrength__Primary_Customer__r.Email != null) {
                        emailToRoleMap.put(booking.PropStrength__Primary_Customer__r.Email +'_'+i,'Primary Customer');

                        String sub = 'Handover Of Possession Letter';
                        String body = HandoverOfPossessionUtil.docusignEmailBody();

                        dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                                'English',
                                                                                                                sub,
                                                                                                                body);
            
                        //SMS authentication phone numbers
                        List<String> smsPhoneNumbers = new List<String>();
                        String applPhoneNumber = HandoverOfPossessionUtil.validateAndUpdatePhoneNumber(booking.PropStrength__Primary_Customer__r.MobilePhone);
                        smsPhoneNumbers.add(applPhoneNumber);

                        //Set the authentication
                        dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                        
                        String anchorString = 'primaryContactOrPOASign';

                        List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                        
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

                        
                        dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                        dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                    .withScale(1.0) // 1.5 scale
                                                    .withRequired(true) // Signing mandatory
                                                    .withAnchor(new dfsle.Tab.Anchor(
                                                                        'primaryContactOrPoaStamp', // Anchor string
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
                                                                                booking.PropStrength__Primary_Customer__r.Name,
                                                                                booking.PropStrength__Primary_Customer__r.Email,
                                                                                null, 
                                                                                null,
                                                                                null)
                                                                            .withTabs(applicantsTabs)
                                                                            .withAuthentication(auth)
                                                                            .withEmailSettings(applicantEmailSetting);
                        recipientList.add(myRecipient);

                        i = i+1;
                    }
                }
            } else if(booking.Handover_will_be_taken_by__c == 'POA – Owner') {
                if(booking.POA_Email_Address__c != null && booking.POA_Mobile_Number__c != null && booking.POA_Name__c != null) {
                    emailToRoleMap.put(booking.POA_Email_Address__c +'_'+i,'POA');

                    String sub = 'Handover Of Possession Letter';
                    String body = HandoverOfPossessionUtil.docusignEmailBody();

                    dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                            'English',
                                                                                                            sub,
                                                                                                            body);
        
                    //SMS authentication phone numbers
                    List<String> smsPhoneNumbers = new List<String>();
                    String applPhoneNumber = HandoverOfPossessionUtil.validateAndUpdatePhoneNumber(booking.POA_Mobile_Number__c);
                    smsPhoneNumbers.add(applPhoneNumber);

                    //Set the authentication
                    dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                    
                    String anchorString = 'primaryContactOrPOASign';

                    List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                    
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
        
                    dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                            booking.POA_Name__c,
                                                                            booking.POA_Email_Address__c,
                                                                            null, 
                                                                            null,
                                                                            null)
                                                                        .withTabs(applicantsTabs)
                                                                        .withAuthentication(auth)
                                                                        .withEmailSettings(applicantEmailSetting);
                    recipientList.add(myRecipient);

                    i = i+1;
                }
            } else if(booking.Handover_will_be_taken_by__c == 'POA – Company') {
                if(booking.POA_Email_Address__c != null && booking.POA_Mobile_Number__c != null && booking.POA_Name__c != null) {
                    emailToRoleMap.put(booking.POA_Email_Address__c +'_'+i,'POA');

                    String sub = 'Handover Of Possession Letter';
                    String body = HandoverOfPossessionUtil.docusignEmailBody();

                    dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                            'English',
                                                                                                            sub,
                                                                                                            body);
        
                    //SMS authentication phone numbers
                    List<String> smsPhoneNumbers = new List<String>();
                    String applPhoneNumber = HandoverOfPossessionUtil.validateAndUpdatePhoneNumber(booking.POA_Mobile_Number__c);
                    smsPhoneNumbers.add(applPhoneNumber);

                    //Set the authentication
                    dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                    
                    String anchorString = 'primaryContactOrPOASign';

                    List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                    
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

                    dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                .withScale(1.0) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                    'primaryContactOrPoaStamp', // Anchor string
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
                                                                            booking.POA_Name__c,
                                                                            booking.POA_Email_Address__c,
                                                                            null, 
                                                                            null,
                                                                            null)
                                                                        .withTabs(applicantsTabs)
                                                                        .withAuthentication(auth)
                                                                        .withEmailSettings(applicantEmailSetting);
                    recipientList.add(myRecipient);

                    i = i+1;
                }
            }
            
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
                HandoverOfPossessionUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap);
            }
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Handover Of Possession Letter sent successfully sent for Docusign.';
            event.Booking_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        } 
        catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Error sending Handover Of Possession for Docusign - '+e.getMessage();
            event.Booking_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }
}