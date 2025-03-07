/*********************************************************************
 * Class Name  :   HOUndertakingDocusignHandler
 * Description :   Helper Class of Flow Send_Home_Orientation_Undertaking_Letter (Flow)
 * Created Date:   20/05/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 20/05/2024
 *********************************************************************/
public with sharing class HOUndertakingDocusignHandler {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> appBookingIds) {
        Id mySourceId = appBookingIds[0];
        PropStrength__Application_Booking__c book = [SELECT Id,Home_Orientation_Undertaking_Sent_Date__c FROM PropStrength__Application_Booking__c WHERE Id = :mySourceId];
        if(book.Home_Orientation_Undertaking_Sent_Date__c == null) {
            forForSigningFuture(mySourceId);
        }
    } 
    
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            Map<String,String> emailToRoleMap = new Map<String,String>();
    
            Id myDocumentId = HOUndertakingUtil.getFileId(mySourceId);
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
            
            PropStrength__Application_Booking__c booking = HOUndertakingUtil.getBooking(mySourceId);
            List<PropStrength__Applicant_Detail__c> applicants = HOUndertakingUtil.getApplicants(mySourceId);

            Integer i=1;
            Integer applicantsSize = applicants.size();
            Decimal scaleValue;
            Integer yOffset = 0;
            if (applicantsSize > 2) {
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
			System.debug('test*----1234');
            
            Integer temp = 0;
            Integer temp2 = 0;
            Integer temp3 = 0;
            for(PropStrength__Applicant_Detail__c applicant : authorizedMap.Values()) {
                applicantsSize=i;
                String toEmailAddress;
                String anchorString;
                String phonenumber;

                emailToRoleMap.put(applicant.PropStrength__Applicant_Email__c +'_'+i,'Applicant');
                toEmailAddress=applicant.PropStrength__Applicant_Email__c;
                anchorString = 'purchaserinitials' + String.valueOf(i);
                phonenumber=applicant.PropStrength__Applicant_Mobile__c;
                
                String sub = 'Home Orientation Undertaking Document for the unit '+booking.PropStrength__Property__r.Name;
                String body = HOUndertakingUtil.docusignEmailBody();

                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        sub,
                                                                                                        body);
    
                //SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                String applPhoneNumber = HOUndertakingUtil.validateAndUpdatePhoneNumber(applicant.PropStrength__Applicant_Mobile__c);
                smsPhoneNumbers.add(applPhoneNumber);
                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );

                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();


                if(i==1) {
                        // Create a Sign Here tab for applicant
                    dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
                        .withScale(1.0) // 1.5 scale
                        .withRequired(true) // Signing mandatory
                        .withAnchor(new dfsle.Tab.Anchor(
                            anchorString, // Anchor string
                            false, // Do not allow white space in anchor string
                            false, // Anchor string is not case sensitive
                            'left', // Horizontal alignment in relation to the anchor text
                            true, // Ignore if the anchor text is not present in the document
                            true, // Must match the value of the anchor string in its entirety
                            'pixels', // Unit of the x and y offset properties
                            temp, // X offset
                            yOffset)); // Y offset 

                            if(applicant.PropStrength__Applicant_Acc__r.PropStrength__Account_Type__c == 'Company') {
                                dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                                dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                            .withScale(0.6) // 1.5 scale
                                                            .withRequired(true) // Signing mandatory
                                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                                'corpstamp', // Anchor string
                                                                                false, // Do not allow white space in anchor string
                                                                                false, // Anchor string is not case sensitive
                                                                                'right', // Horizontal alignment in relation to the anchor text
                                                                                true, // Ignore if the anchor text is not present in the document
                                                                                true, // Must match the value of the anchor string in its entirety
                                                                                'pixels', // Unit of the x and y offset properties
                                                                                temp, // X offset
                                                                                yOffset)
                                                                        ); // Y offset
                                applicantsTabs.add(corpAppStampTab);
                            }
                            applicantsTabs.add(mySignHereTab);
                } else {
                
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
                            temp2, // X offset
                            yOffset+5)); // Y offset 

                    temp2 += 15;
                    temp3 += 40;

                    if(applicant.PropStrength__Applicant_Acc__r.PropStrength__Account_Type__c == 'Company') {
                        dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                        dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                    .withScale(0.6) // 1.5 scale
                                                    .withRequired(true) // Signing mandatory
                                                    .withAnchor(new dfsle.Tab.Anchor(
                                                                        'corpstamp', // Anchor string
                                                                        false, // Do not allow white space in anchor string
                                                                        false, // Anchor string is not case sensitive
                                                                        'right', // Horizontal alignment in relation to the anchor text
                                                                        true, // Ignore if the anchor text is not present in the document
                                                                        true, // Must match the value of the anchor string in its entirety
                                                                        'pixels', // Unit of the x and y offset properties
                                                                        temp3, // X offset
                                                                        yOffset)
                                                                ); // Y offset
                        applicantsTabs.add(corpAppStampTab);
                    }
                    temp3 += 10;
                    
                    applicantsTabs.add(mySignHereTab);
                }

                
                temp += 30;

                System.debug('applicantsTabs2***');
                System.debug(applicantsTabs);
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                        applicant.name,
                                                                        toEmailAddress,
                                                                        null, 
                                                                        applicant.PropStrength__Type__c,
                                                                        null)
                                                                    .withTabs(applicantsTabs)
                                                                    .withAuthentication(auth)
                                                                    .withEmailSettings(applicantEmailSetting);
                recipientList.add(myRecipient);
    
                i = i+1;
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
        System.debug('test*----1234');
            //Add the signers...
            myEnvelope = myEnvelope
                        .withRecipients(recipientList)
                        .withNotifications(expirySettings );
            System.debug('test*----123');
            // Send the envelope!
            if(!Test.isRunningTest()) {
                myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                    myEnvelope,
                    true
                );
                System.debug('test*----');
                String envelopeId = String.valueOf(myEnvelope.docuSignId);
                HOUndertakingUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap, applicantsSize);
            }
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Booking Form sent successfully sent for Docusign.';
            event.Booking_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        } 
        catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Error sending booking Form for Docusign - '+e.getMessage();
            event.Booking_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }
}