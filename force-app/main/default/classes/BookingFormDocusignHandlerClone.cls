/*********************************************************************
 * Class Name  :   BookingFormDocusignHandlerClone
 * Description :   Helper Class of Flow Send Booking Form for Docusign Clone (Flow)
 * Created Date:   12/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 12/01/2024
 *********************************************************************/
public with sharing class BookingFormDocusignHandlerClone {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> appBookingIds) {
        Id mySourceId = appBookingIds[0];
        forForSigningFuture(mySourceId);
    } 
    
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            Map<String,String> emailToRoleMap = new Map<String,String>();
            List<Applicant_Details__c> sortedApplicants = new List<Applicant_Details__c>();
    
            Id myDocumentId = BookingFormDocusignUtilClone.getFileId(mySourceId);
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
            
            PropStrength__Application_Booking__c booking = BookingFormDocusignUtilClone.getBooking(mySourceId);
            List<PropStrength__Applicant_Detail__c> applicants = BookingFormDocusignUtilClone.getApplicants(mySourceId);

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
            if(booking.POA_Name__c != null && booking.POA_Email_Address__c != null && booking.POA_Mobile_Number__c != null) {
                emailToRoleMap.put(booking.POA_Email_Address__c +'_'+i,'POA');

                String sub = 'Congratulations on booking the unit '+booking.PropStrength__Property__r.Name+' ('+booking.Name+') Project - '+booking.PropStrength__Project__r.Name;
                String body = BookingFormDocusignUtilClone.docusignEmailBody();

                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        sub,
                                                                                                        body);
    
                //SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                String applPhoneNumber = BookingFormDocusignUtilClone.validateAndUpdatePhoneNumber(booking.POA_Mobile_Number__c);
                smsPhoneNumbers.add(applPhoneNumber);

                // Create an Initial Here tab
                dfsle.Tab myInitialHereTab = new dfsle.InitialHereTab()
                .withRequired(true) // Signing optional
                .withAnchor(new dfsle.Tab.Anchor(
                                                'initialsOfPurchaser', // Anchor string
                                                false, // Do not allow white space in anchor string
                                                false, // Anchor string is not case sensitive
                                                'left', // Horizontal alignment in relation to the anchor text
                                                true, // Ignore if the anchor text is not present in the document
                                                true, // Must match the value of the anchor string in its entirety
                                                'pixels', // Unit of the x and y offset properties
                                                0, // X offset
                                                yOffset)); // Y offset

                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                
                String anchorString = 'purchaserinitials' + String.valueOf(i);

                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                
                // Create a Sign Here tab for applicant
                dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
                    .withScale(1.5) // 1.5 scale
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

                applicantsTabs.add(myInitialHereTab);
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
            else {
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
                    
                    String sub = 'Congratulations on booking the unit '+booking.PropStrength__Property__r.Name+' ('+booking.Name+') Project - '+booking.PropStrength__Project__r.Name;
                    String body = BookingFormDocusignUtilClone.docusignEmailBody();
    
                    dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                            'English',
                                                                                                            sub,
                                                                                                            body);
        
                    //SMS authentication phone numbers
                    List<String> smsPhoneNumbers = new List<String>();
                    String applPhoneNumber = BookingFormDocusignUtilClone.validateAndUpdatePhoneNumber(applicant.PropStrength__Applicant_Mobile__c);
                    smsPhoneNumbers.add(applPhoneNumber);
                    //Set the authentication
                    dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );

                    List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();

                    // Create an Initial Here tab
                    dfsle.Tab myInitialHereTab = new dfsle.InitialHereTab()
                    .withRequired(true) // Signing optional
                    .withAnchor(new dfsle.Tab.Anchor(
                                                    'initialsOfPurchaser', // Anchor string
                                                    false, // Do not allow white space in anchor string
                                                    false, // Anchor string is not case sensitive
                                                    'left', // Horizontal alignment in relation to the anchor text
                                                    true, // Ignore if the anchor text is not present in the document
                                                    true, // Must match the value of the anchor string in its entirety
                                                    'pixels', // Unit of the x and y offset properties
                                                    temp, // X offset
                                                    yOffset)); // Y offset


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
                            

                    applicantsTabs.add(myInitialHereTab);

                    
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
            }

            
    
            String SMSDDub = 'Docusign for booking the unit# '+booking.PropStrength__Property__r.Name+'  Project Name : '+booking.PropStrength__Project__r.Name;
            String SMSDBody = BookingFormDocusignUtilClone.getSMSDBody(booking.Name,booking.PropStrength__Property__r.Name);

            dfsle.Recipient.EmailSettings smsdEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        SMSDDub,
                                                                                                        SMSDBody);
            
            String salesManagerAnchor = 'salesmanager';
            // Create a Sign Here tab
            dfsle.Tab salesManagerTab = new dfsle.SignHereTab()
                                                .withScale(1.0) // 1.0 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                    salesManagerAnchor, // Anchor string
                                                    false, // Do not allow white space in anchor string
                                                    false, // Anchor string is not case sensitive
                                                    'left', // Horizontal alignment in relation to the anchor text
                                                    true, // Ignore if the anchor text is not present in the document
                                                    true, // Must match the value of the anchor string in its entirety
                                                    'pixels', // Unit of the x and y offset properties
                                                    0, // X offset
                                                    0)); // Y offset 

            dfsle.Recipient salesManager = dfsle.Recipient.fromSource(
                                                                    booking.Sales_Manager__r.Name, 
                                                                    booking.Sales_Manager__r.Email,
                                                                    null, 
                                                                    null,
                                                                    null)
                                                                .withTabs(new List<dfsle.Tab> {
                                                                    salesManagerTab
                                                                })
                                                                .withEmailSettings(smsdEmailSetting);
            recipientList.add(salesManager);
            emailToRoleMap.put(booking.Sales_Manager__r.Email +'_'+ i,'Sales manager');
            i=i+1;
System.debug('test*----1234');
            String salesHeadAnchor = 'saleshead';
            dfsle.Tab salesHeadTab = new dfsle.SignHereTab()
                                                    .withScale(1.0) // 1.5 scale
                                                    .withRequired(true) // Signing mandatory
                                                    .withAnchor(new dfsle.Tab.Anchor(
                                                        salesHeadAnchor, // Anchor string
                                                        false, // Do not allow white space in anchor string
                                                        false, // Anchor string is not case sensitive
                                                        'right', // Horizontal alignment in relation to the anchor text
                                                        true, // Ignore if the anchor text is not present in the document
                                                        true, // Must match the value of the anchor string in its entirety
                                                        'pixels', // Unit of the x and y offset properties
                                                        0, // X offset
                                                        0)); // Y offset
            dfsle.Recipient salesHead = dfsle.Recipient.fromSource(
                                                                booking.Sales_Head__r.Name, 
                                                                booking.Sales_Head__r.Email,
                                                                null, 
                                                                null,
                                                                null)
                                                            .withTabs(new List<dfsle.Tab> {
                                                                salesHeadTab
                                                            })
                                                            .withEmailSettings(smsdEmailSetting);
            recipientList.add(salesHead);
            emailToRoleMap.put(booking.Sales_Head__r.Email +'_'+i,'Sales Head');
            i=i+1;

            String SalesOpsSub = 'DocuSign Unit # - '+booking.PropStrength__Property__r.Name+' Booking ID#'+booking.Name+' - Booking for Salesops Review';
            String SalesOpsBody = BookingFormDocusignUtilClone.getSalesOperationBody(booking.Name,booking.PropStrength__Property__r.Name);

            dfsle.Recipient.EmailSettings salesOpsEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                'English',
                                                                                                SalesOpsSub,
                                                                                                SalesOpsBody);
            String salesopsApproveAnchor = 'salesopsapprove';
            String salesopsDeclineAnchor = 'salesopsdecline';
            dfsle.Tab salesopsApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            salesopsApproveAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            dfsle.Tab salesopsDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            salesopsDeclineAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            dfsle.Recipient salesops = dfsle.Recipient.fromSource(
                                                                'Sales Operations', 
                                                                booking.Docusign_Sales_Ops_Email__c,
                                                                null,
                                                                null,
                                                                null)
                                                            .withTabs(new List<dfsle.Tab> {
                                                                salesopsApproveTab,salesopsDeclineTab
                                                            })
                                                            .withEmailSettings(salesOpsEmailSetting);
            recipientList.add(salesops);
            emailToRoleMap.put(booking.Docusign_Sales_Ops_Email__c +'_'+i,'Sales Ops');
            i=i+1;

            String auditSub = 'DocuSign Unit # - '+booking.PropStrength__Property__r.Name+' Booking ID#'+booking.Name+' - Booking for Salesops Review';
            String auditBody = BookingFormDocusignUtilClone.getAuditBody(booking.Name,booking.PropStrength__Property__r.Name);

            dfsle.Recipient.EmailSettings auditEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                'English',
                                                                                                auditSub,
                                                                                                auditBody);

            String auditTeamApproveAnchor = 'auditteamapprove';
            String auditTeamDeclineAnchor = 'auditteamdecline';
            dfsle.Tab auditTeamApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            auditTeamApproveAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            dfsle.Tab auditTeamDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            auditTeamDeclineAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset

            dfsle.Recipient auditTeam = dfsle.Recipient.fromSource(
                                                            'Audit Team',
                                                            booking.Docusign_Audit_Email__c,
                                                            null,
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                            auditTeamApproveTab,auditTeamDeclineTab
                                                        })
                                                        .withEmailSettings(auditEmailSetting);
            
            recipientList.add(auditTeam);
            emailToRoleMap.put(booking.Docusign_Audit_Email__c +'_'+i,'Audit Team');
            i=i+1;

            // Create an Initial Here tab
            dfsle.Tab myInitialHereTab2 = new dfsle.InitialHereTab()
            .withRequired(true) // Signing optional
            .withAnchor(new dfsle.Tab.Anchor(
                                            'initialsOfSeller', // Anchor string
                                            false, // Do not allow white space in anchor string
                                            false, // Anchor string is not case sensitive
                                            'left', // Horizontal alignment in relation to the anchor text
                                            true, // Ignore if the anchor text is not present in the document
                                            true, // Must match the value of the anchor string in its entirety
                                            'pixels', // Unit of the x and y offset properties
                                            -30, // X offset
                                            0)); // Y offset
            String anchorString = 'sellerrep';
            // Create a Sign Here tab
            dfsle.Tab sellerRepTab = new dfsle.SignHereTab()
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
                                                                0, // X offset
                                                                5)); // Y offset 

            

            dfsle.Recipient sellerRep = dfsle.Recipient.fromSource(
                                                            booking.Seller_Representative__r.name,
                                                            booking.Seller_Representative__r.Email,
                                                            null, 
                                                            null,
                                                            null)
                                                            .withTabs(new List<dfsle.Tab> {
                                                                sellerRepTab, myInitialHereTab2
                                                                });
            recipientList.add(sellerRep);
            emailToRoleMap.put(booking.Seller_Representative__r.Email +'_'+i,'Seller Representative');
            i=i+1;
            
            
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
                BookingFormDocusignUtilClone.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap, applicantsSize);
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