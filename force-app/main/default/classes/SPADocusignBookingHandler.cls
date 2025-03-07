//Test Class: SPADocusignTestClass
public with sharing class SPADocusignBookingHandler  {
    @InvocableMethod
        public static void sendEnvelopeMethod(List<Id> bookingIds){
            Id mySourceId = bookingIds[0];
            forForSigningFuture(mySourceId);
        }
    
        @future(callout=true)
        public static void forForSigningFuture(Id mySourceId) {
            try {
                Map<String,String> emailToRoleMap = new Map<String,String>();
                dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
                List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId =:mySourceId 
                                                    AND ContentDocument.title like '%SPA%' and  (not ContentDocument.title like '%Addendum%')
                                                    Order by ContentDocument.createdDate desc LIMIT 1];
                if(docList.size() > 0){
                    Id myDocumentId = docList[0].ContentDocumentId; 
                    Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id; 
                    
                    Id myFileId2;
                    if(System.Label.Supplemental_Document_Id != null && System.Label.Supplemental_Document_Id != 'NA' && !Test.isRunningTest()){
                        myFileId2 = [SELECT id FROM ContentVersion WHERE ContentDocumentId =: System.Label.Supplemental_Document_Id LIMIT 1].id;
                    }

                    integer aa = 2;
                    system.debug('test');
                    Booking__c booking = SPADocusignBookingFormUtil.getBooking(mySourceId);
                    
                    List<Applicant_Details__c> applicants = [SELECT id,name, Email_Address__c, Authorized_Signatory_2__c, Authorized_Signatory_3__c,Applicant_Number__c,
                                                            Corporate_Stamping_Required__c, Mobile_Number__c, Authorized_Signatory2_Phone__c, Authorized_Signatory3_Phone__c  
                                                            FROM Applicant_Details__c WHERE Booking__c =:mySourceId ORDER BY Applicant_Signing_Order__c ASC];
            
                    Integer applicantsSize = applicants.size();
                    Integer i=1;
                    Decimal scaleValue;
                    Integer yOffset = 0;
                    scaleValue = 1.0;
                    yOffset = 10;
                    List<dfsle.Document> documentList = new List<dfsle.Document>();
                    
                    if(myFileId2 != null){
                        // Add document to the envelope
                        List<dfsle.Document> documentListTemp1 = dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> {  myFileId2 });
                        dfsle.Document a = documentListTemp1[0];

                        documentList.add(a);
                        List<dfsle.Document> documentListTemp2 = dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> {  myFileId });

                        documentList.add(documentListTemp2[0]);
                        
                        Integer indexSuppl;
                        for(dfsle.Document doc: documentList){
                            if(doc.sourceId == myFileId2){
                                indexSuppl = documentList.indexOf(doc);
                            }
                        }
                        documentList[indexSuppl].withSupplementalOptions(new
                                                                dfsle.Document.SupplementalOptions(
                                                                dfsle.Document.SIGNER_ACKNOWLEDGEMENT_VIEW_ACCEPT,
                                                                true));
                    }else{
                        documentList = dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> {  myFileId });
                    }
                    
                    // Update envelope with template & replacement document
                    myEnvelope = myEnvelope.withDocuments(documentList);
                    //Docusign For Appllicants
                    List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
                    //Integer i = 1;
                    Map<Integer, Applicant_Details__c> authorizedMap = new Map<Integer, Applicant_Details__c>();
                    Integer num=1;
                    for (Applicant_Details__c applicant:applicants){
                        //authirised signature logic starts here
                        if(applicant.Corporate_Stamping_Required__c){
                            authorizedMap.put(num, applicant);
                            if(applicant.Authorized_Signatory_2__c  <> null){
                                num=num+1;
                                authorizedMap.put(num, applicant);
                            }
                            if(applicant.Authorized_Signatory_3__c  <> null){
                                num=num+1;
                                authorizedMap.put(num, applicant);
                            }
                            break;
                        }
                    }
                    if(authorizedMap.isEmpty()){
                        for (Applicant_Details__c applicant:applicants) {
                            emailToRoleMap.put(applicant.Email_Address__c +'_'+i,'Applicant');
                            //SMS authentication phone numbers
                            List<String> smsPhoneNumbers = new List<String>();
                            String applPhoneNumber = SPADocusignBookingFormUtil.validateAndUpdatePhoneNumber(applicant.Mobile_Number__c);
                            smsPhoneNumbers.add(applPhoneNumber);
                            //Set the authentication
                            dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                            String sub = booking.Unit__r.Name +' - '+booking.Cluster__c+' - Sales and Purchase Agreement (SPA) for Digital Signoff';
                            String body = docusignApplicantEmailBody(booking);
                            dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en','English',sub,body);
                            String anchorInitialsString = 'pids' + String.valueOf(i);
                            dfsle.Tab myInitialHereTab = new dfsle.InitialHereTab()
                                                                        .withScale(0.5)
                                                                        .withRequired(true) // Signing optional
                                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                                            anchorInitialsString, // Anchor string
                                                                            false, // Do not allow white space in anchor string
                                                                            false, // Anchor string is not case sensitive
                                                                            'right', // Horizontal alignment in relation to the anchor text
                                                                            true, // Ignore if the anchor text is not present in the document
                                                                            true, // Must match the value of the anchor string in its entirety
                                                                            'pixels', // Unit of the x and y offset properties
                                                                            0, // X offset
                                                                            10)); // Y offset
                
                            String anchorString = 'purchasersig' + String.valueOf(i);
                            // Create a Sign Here tab
                            dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
                                                                        .withScale(scaleValue) // 1.5 scale
                                                                        .withRequired(true) // Signing mandatory
                                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                                            anchorString, // Anchor string
                                                                            false, // Do not allow white space in anchor string
                                                                            false, // Anchor string is not case sensitive
                                                                            'right', // Horizontal alignment in relation to the anchor text
                                                                            true, // Ignore if the anchor text is not present in the document
                                                                            true, // Must match the value of the anchor string in its entirety
                                                                            'pixels', // Unit of the x and y offset properties
                                                                            0, // X offset
                                                                            yOffset)); // Y offset 
                
                            dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                            applicant.name,
                                                                            applicant.Email_Address__c,
                                                                            null, 
                                                                            applicant.Applicant_Number__c,
                                                                            null
                                                                        )
                                                                        .withTabs(new List<dfsle.Tab> {
                                                                            myInitialHereTab,mySignHereTab
                                                                        })
                                                                        .withAuthentication(auth)
                                                                        .withEmailSettings(applicantEmailSetting);
                            recipientList.add(myRecipient);
                            i = i+1;
                        }
                    }else{
                        for(Applicant_Details__c applicant : authorizedMap.Values()){
                            String phonenumber;
                            applicantsSize=i;
                            String toEmailAddress;
                            String anchorString; 
                            if(i==1){
                                emailToRoleMap.put(applicant.Email_Address__c +'_'+i,'Applicant');
                                toEmailAddress=applicant.Email_Address__c;
                                anchorString = 'purchasersig' + String.valueOf(i);
                                phonenumber=applicant.Mobile_Number__c;
                            }else if(i==2){
                                emailToRoleMap.put(applicant.Authorized_Signatory_2__c +'_'+i,'Applicant');
                                toEmailAddress=applicant.Authorized_Signatory_2__c;
                                anchorString = 'purchasersig' + String.valueOf(i);
                                phonenumber=applicant.Authorized_Signatory2_Phone__c;
                            }else if(i==3){
                                emailToRoleMap.put(applicant.Authorized_Signatory_3__c +'_'+i,'Applicant');
                                toEmailAddress=applicant.Authorized_Signatory_3__c;
                                anchorString = 'purchasersig' + String.valueOf(i);
                                phonenumber=applicant.Authorized_Signatory3_Phone__c ;
                            }
                            String sub = booking.Unit__r.Name +' - '+booking.Cluster__c+' - Sales and Purchase Agreement (SPA) for Digital Signoff';
                            String body = docusignApplicantEmailBody(booking);
                            dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en','English',sub,body);
                
                            //SMS authentication phone numbers
                            List<String> smsPhoneNumbers = new List<String>();
                            String applPhoneNumber = BookingFormDocusignUtil.validateAndUpdatePhoneNumber(phonenumber);
                            smsPhoneNumbers.add(applPhoneNumber);
                            //Set the authentication
                            dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                            List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                            String anchorInitialsString = 'pids' + String.valueOf(i);
                            dfsle.Tab myInitialHereTab = new dfsle.InitialHereTab()
                                                                        .withScale(0.5)
                                                                        .withRequired(true) // Signing optional
                                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                                            anchorInitialsString, // Anchor string
                                                                            false, // Do not allow white space in anchor string
                                                                            false, // Anchor string is not case sensitive
                                                                            'right', // Horizontal alignment in relation to the anchor text
                                                                            true, // Ignore if the anchor text is not present in the document
                                                                            true, // Must match the value of the anchor string in its entirety
                                                                            'pixels', // Unit of the x and y offset properties
                                                                            0, // X offset
                                                                            10)); // Y offset
                            
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

                            applicantsTabs.add(myInitialHereTab);
                            applicantsTabs.add(mySignHereTab);

                            //If corporate applicant enable stamping for primary
                            if (i==1) {
                                dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                                dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                            .withScale(1.0) // 1.5 scale
                                                            .withRequired(true) // Signing mandatory
                                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                                'corpstamp', // Anchor string
                                                                                false, // Do not allow white space in anchor string
                                                                                false, // Anchor string is not case sensitive
                                                                                'right', // Horizontal alignment in relation to the anchor text
                                                                                true, // Ignore if the anchor text is not present in the document
                                                                                true, // Must match the value of the anchor string in its entirety
                                                                                'pixels', // Unit of the x and y offset properties
                                                                                0, // X offset
                                                                                0)
                                                                        ); // Y offset
                                applicantsTabs.add(corpAppStampTab);
                            }
                            dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                                    applicant.name,
                                                                                    toEmailAddress,
                                                                                    null, 
                                                                                    applicant.Applicant_Number__c,
                                                                                    null)
                                                                                .withTabs(applicantsTabs)
                                                                                .withAuthentication(auth)
                                                                                .withEmailSettings(applicantEmailSetting);
                            recipientList.add(myRecipient);
                            i = i+1;
                        }             
                    }
                    //Audit - part 2
                    String auditSub = 'DocuSign Unit # - '+booking.Unit__r.Name+' Booking ID#'+booking.Name+' - Booking for Audit Review';
                    String auditBody = getAuditBody(booking.Name,booking.Unit__r.Name);
                    dfsle.Recipient.EmailSettings auditEmailSetting = new dfsle.Recipient.EmailSettings('en','English',auditSub,auditBody);
                    
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
                    emailToRoleMap.put(Label.DocusignCRMAssuranceEmail +'_'+i,Label.DocusignCRMAssuranceName);
                    // emailToRoleMap.put(Label.DocusignAuditTeamEmail +'_'+i,'Audit Team');
                             i=i+1;
                    system.debug('emailToRoleMapa:'+emailToRoleMap);
                    dfsle.Recipient auditTeam = dfsle.Recipient.fromSource(
                                                                    Label.DocusignCRMAssuranceName,
                                                                    +Label.DocusignCRMAssuranceEmail,
                        											/*'Audit Team',
                        											Label.DocusignAuditTeamEmail,*/
                                                                    null,
                                                                    null,
                                                                    null)
                                                                .withTabs(new List<dfsle.Tab> {
                                                                    auditTeamApproveTab,auditTeamDeclineTab
                                                                })
                                                                .withEmailSettings(auditEmailSetting);
                    
                    recipientList.add(auditTeam);
                
                    String sub = booking.Unit__r.Name +' - '+booking.Cluster__c+' - Sales and Purchase Agreement (SPA) for Digital Signoff';
                    String body = docusignSellerEmailBody();
                    dfsle.Recipient.EmailSettings sellerEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                            'English',
                                                                                                            sub,
                                                                                                            body);
                    dfsle.Tab sellerSignTab = new dfsle.SignHereTab()
                                                        .withScale(scaleValue) // 1.5 scale
                                                        .withRequired(true) // Signing mandatory
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                                                'sellersigsobha', // Anchor string
                                                                                false, // Do not allow white space in anchor string
                                                                                false, // Anchor string is not case sensitive
                                                                                'left', // Horizontal alignment in relation to the anchor text
                                                                                true, // Ignore if the anchor text is not present in the document
                                                                                true, // Must match the value of the anchor string in its entirety
                                                                                'pixels', // Unit of the x and y offset properties
                                                                                0, // X offset
                                                                                yOffset)
                                                                    ); // Y offset 
                    dfsle.SignHereTab.Stamp sellerStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab sellerStampTab = new dfsle.SignHereTab().withStamp(sellerStamp)
                                                        .withScale(1.0) // 1.5 scale
                                                        .withRequired(true) // Signing mandatory
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                                            'sellerstampsobha', // Anchor string
                                                                            false, // Do not allow white space in anchor string
                                                                            false, // Anchor string is not case sensitive
                                                                            'right', // Horizontal alignment in relation to the anchor text
                                                                            true, // Ignore if the anchor text is not present in the document
                                                                            true, // Must match the value of the anchor string in its entirety
                                                                            'pixels', // Unit of the x and y offset properties
                                                                            10, // X offset
                                                                            0)
                                                                    ); // Y offset
                    dfsle.Tab sellerDateSignedTab = new dfsle.DateSignedTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                                        'sellerdate', // Anchor string
                                                                        false, // Do not allow white space in anchor string
                                                                        false, // Anchor string is not case sensitive
                                                                        'right', // Horizontal alignment in relation to the anchor text
                                                                        true, // Ignore if the anchor text is not present in the document
                                                                        true, // Must match the value of the anchor string in its entirety
                                                                        'pixels', // Unit of the x and y offset properties
                                                                        20, // X offset
                                                                        0)
                                                                    ); // Y offset
                    emailToRoleMap.put(booking.CRM_Seller_representative__r.Email +'_'+i,'Seller Representative');
                    i=i+1;
                    dfsle.Recipient sellerRecipient = dfsle.Recipient.fromSource(
                                                                    booking.CRM_Seller_representative__r.Name,
                                                                    booking.CRM_Seller_representative__r.Email,
                                                                    null, 
                                                                    null,
                                                                    null)
                                                                .withTabs(new List<dfsle.Tab> {
                                                                        sellerSignTab,sellerStampTab,sellerDateSignedTab
                                                                    })
                                                                .withEmailSettings(sellerEmailSetting);
                    recipientList.add(sellerRecipient);
                    //Document Controller - part 4
                    String docContSub = booking.Unit__r.Name +' - '+booking.Cluster__c+' - Sales and Purchase Agreement (SPA) for Digital Signoff';
                    String docContBody = docusignDocumentControllerEmailBody();
                    dfsle.Recipient.EmailSettings docContEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        docContSub,
                                                                                                        docContBody);
                    dfsle.SignHereTab.Stamp docControllerStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab docControllerStampTab = new dfsle.SignHereTab().withStamp(docControllerStamp)
                                                                            .withScale(1.0) // 1.5 scale
                                                                            .withRequired(true) // Signing mandatory
                                                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                                'doccontstamp', // Anchor string
                                                                                false, // Do not allow white space in anchor string
                                                                                false, // Anchor string is not case sensitive
                                                                                'right', // Horizontal alignment in relation to the anchor text
                                                                                true, // Ignore if the anchor text is not present in the document
                                                                                true, // Must match the value of the anchor string in its entirety
                                                                                'pixels', // Unit of the x and y offset properties
                                                                                10, // X offset
                                                                                0)); // Y offset
                    emailToRoleMap.put(booking.CRM_Document_Controller__r.Email +'_'+i,'Document Controller');
                    i=i+1;
                    dfsle.Recipient docControllerRecipient = dfsle.Recipient.fromSource(
                                                                                booking.CRM_Document_Controller__r.Name,
                                                                                booking.CRM_Document_Controller__r.Email,
                                                                                null, 
                                                                                null,
                                                                                null)
                                                                                .withTabs(new List<dfsle.Tab> {
                                                                                        docControllerStampTab
                                                                                })
                                                                                .withEmailSettings(docContEmailSetting);
                    recipientList.add(docControllerRecipient);
                    Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
                    Integer expiryDays = Integer.valueOf(docusignDefaultSettings.SPA_Expiry_Days__c);
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
                    myEnvelope = myEnvelope.withRecipients(recipientList);

                    //Send the Envelope
                    if(!Test.isRunningTest()) {
                        myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                            myEnvelope,
                            true
                        );
                        String envelopeId = String.valueOf(myEnvelope.docuSignId);
                        Booking__c b = new Booking__c(id=mySourceId, SPA_Docusign_Envelope_Id__c=envelopeId);
                        update b;
                    }
                    String envelopeId = String.valueOf(myEnvelope.docuSignId);
                     system.debug('emailToRoleMapfinal:'+emailToRoleMap);
                    SPADocusignBookingFormUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap, applicantsSize);
                
                    Docusign_Result__e event = new Docusign_Result__e();
                    event.MessageToDisplay__c = 'SPA sent successfully for Docusign.';
                    event.Booking_Id__c = mySourceId;
                    event.User_Id__c = UserInfo.getUserId();
                    EventBus.publish(event);
                }else{
                    Docusign_Result__e event = new Docusign_Result__e();
                    event.MessageToDisplay__c = 'Error sending SPA for Docusign - Pleae attached SPA Document in Files';
                    event.Booking_Id__c = mySourceId;
                    event.User_Id__c = UserInfo.getUserId();
                    EventBus.publish(event);
                }
            }catch (Exception e) {
                System.debug('Exception E'+e);
                System.debug('Exception E'+e.getMessage());
                Docusign_Result__e event = new Docusign_Result__e();
                event.MessageToDisplay__c = 'Error sending SPA for Docusign - '+e.getMessage();
                event.Booking_Id__c = mySourceId;
                event.User_Id__c = UserInfo.getUserId();
                EventBus.publish(event);
            } 
        }
    
        public static String docusignApplicantEmailBody(Booking__c booking) {
            return 
            'Dear Customer \n\n'+
            'Greetings from Sobha Realty! \n\n'+
            'We trust this communication finds you well and thank you for booking your unit in project, “'+booking.Tower__c+'”. \n \n'+
            'Attached to this email is the Sale and Purchase Agreement (“SPA”) for digital signoff via DocuSign, the link for which is <b>valid for seven days</b> from the day of origination of the email. \n \n'+
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
            '<b><i>Also, the final payment shall vary and shall be based on the areas mentioned in the attached SPA.</i></b>\n\n'+
            'Best Regards,\n\n'+
            'CRM Team \n'+
            'Sobha Realty</p>\n';
        }

        public static String docusignSellerEmailBody() {
            return 
            'Dear Seller Representative \n\n'+
            'Please find attached the Sale and Purchase Agreement (“SPA”) signed off by the customer. Please review the same and sign off.\n'+
            '\n'+
            '\n'+
            'Thank you, \n'+
            'Sobha LLC,</p>\n';
        }

        public static String docusignDocumentControllerEmailBody() {
            return 
            'Dear Document Controller \n\n'+
            'Please find attached the Sale and Purchase Agreement (“SPA”) signed off by the customer. Please review the same and add stamp.\n'+
            '\n'+
            '\n'+
            'Thank you, \n'+
            'Sobha LLC,</p>\n';
        }

        public static String getAuditBody(String bookingName, String unitName) {
            return
            'Dear CRM Assurance Team,\n\nThis is to inform you that the customer signed SPA with Booking ID-'+bookingName+' for Unit # '+unitName+'has been reviewed and approved.\n\n'+
            'Request you to review and approve the SPA.Once appproved, SPA is further sent to document controller for final stamping.\n\nThanks\nSobha Realty\n';
        } 
}