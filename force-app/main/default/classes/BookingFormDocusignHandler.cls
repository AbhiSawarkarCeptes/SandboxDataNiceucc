public with sharing class BookingFormDocusignHandler 
{
     @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> bookingIds){
        Id mySourceId = bookingIds[0];
        forForSigningFuture(mySourceId);
    } 
    
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
     
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            Map<String,String> emailToRoleMap = new Map<String,String>();
            List<Applicant_Details__c> sortedApplicants = new List<Applicant_Details__c>();
    
            Id myDocumentId = BookingFormDocusignUtil.getFileId(mySourceId);
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
            
            Booking__c booking = BookingFormDocusignUtil.getBooking(mySourceId);
            List<Applicant_Details__c> applicants = BookingFormDocusignUtil.getApplicants(mySourceId);
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
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
                    new dfsle.Entity(mySourceId)
                );
        
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
            // Create an Initial Here tab
            dfsle.Tab myInitialHereTab = new dfsle.InitialHereTab()
            .withRequired(true) // Signing optional
            .withAnchor(new dfsle.Tab.Anchor(
                                            'Page', // Anchor string
                                            false, // Do not allow white space in anchor string
                                            false, // Anchor string is not case sensitive
                                            'right', // Horizontal alignment in relation to the anchor text
                                            true, // Ignore if the anchor text is not present in the document
                                            true, // Must match the value of the anchor string in its entirety
                                            'pixels', // Unit of the x and y offset properties
                                            20, // X offset
                                            0)); // Y offset
        
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
            //Integer i = 1;
            Map<String, Applicant_Details__c> corporateMap = new Map<String, Applicant_Details__c>();
            for (Applicant_Details__c applicant:applicants) 
            {
                //authirised signature logic starts here
    			if(applicant.Type_Of_Applicant__c=='Corporate Purchaser')
                {
                    //corporateMap.put(num, applicant);
                    if(applicant.POA_Email_Id__c  <> null)
                    {
                        corporateMap.put(applicant.POA_Email_Id__c, applicant);   
                    }
                    
                    if(applicant.POA_2_Email_Id__c  <> null && corporateMap.size() < 5)
                    {
                        corporateMap.put(applicant.POA_2_Email_Id__c, applicant);
                    }
                    applicantsSize=corporateMap.size();
                }
            }
            if (applicantsSize > 3) {
                scaleValue = 0.5;
                yOffset = 10;
            } else {
                scaleValue = 1.0;
                yOffset = 5;
            }
            if(corporateMap.isEmpty())
            {
            	for (Applicant_Details__c applicant:applicants) {
                
                emailToRoleMap.put(applicant.Email_Address__c +'_'+i,'Applicant');

                String sub = 'Congratulations on booking the unit '+booking.Unit__r.Name+' ('+booking.Name+') Project - '+booking.Project__r.Name;
                String body = BookingFormDocusignUtil.docusignEmailBody();
 
                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en','English',sub,body);
    
                //SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                String applPhoneNumber = BookingFormDocusignUtil.validateAndUpdatePhoneNumber(applicant.Mobile_Number__c);
                smsPhoneNumbers.add(applPhoneNumber);
                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                
                String anchorString = 'purchaserinitials' + String.valueOf(i);

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

                applicantsTabs.add(myInitialHereTab);
                applicantsTabs.add(mySignHereTab);

                //If corporate applicant enable stamping for primary
                if (applicant.Applicant_Number__c == 'Primary Applicant' && applicant.Corporate_Stamping_Required__c) {
                    dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                .withScale(1.0) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                    'corporateappstamp', // Anchor string
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
                                                                        applicant.Email_Address__c,
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
            else
            {
             for(String  toEmailAddress : corporateMap.keySet())
             {
                Applicant_Details__c applicant= corporateMap.get(toEmailAddress);
                applicantsSize=i;
                String phonenumber;
                emailToRoleMap.put(toEmailAddress +'_'+i,'Applicant');
                String anchorString = 'purchaserinitials' + String.valueOf(i);
                if(applicant.POA_Email_Id__c <> null && toEmailAddress == applicant.POA_Email_Id__c)
                {
                	phonenumber=applicant.POA_Contact_Number__c;
                }
               	if(applicant.POA_2_Email_Id__c <> null && toEmailAddress == applicant.POA_2_Email_Id__c)
                {
                   phonenumber=applicant.POA_2_Contact_Number__c; 
                }
                String sub = 'Congratulations on booking the unit '+booking.Unit__r.Name+' ('+booking.Name+') Project - '+booking.Project__r.Name;
                String body = BookingFormDocusignUtil.docusignEmailBody();
 
                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en','English', sub, body);
    
                //SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                String applPhoneNumber = BookingFormDocusignUtil.validateAndUpdatePhoneNumber(phonenumber);
                smsPhoneNumbers.add(applPhoneNumber);
                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );

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

                applicantsTabs.add(myInitialHereTab);
                applicantsTabs.add(mySignHereTab);

                //If corporate applicant enable stamping for primary
                if (applicant.Applicant_Number__c == 'Primary Applicant' && toEmailAddress == applicant.POA_Email_Id__c) {
                    
                    dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                .withScale(1.0) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                    'corporateappstamp', // Anchor string
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
    			// applicant.Email_Address__c
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
            
            // Hitesh Changes - Code Starts
            Boolean bRegister = docusignDefaultSettings.Broker_Registration_Enabled__c;
            If(bRegister)
            {
            if(booking.Channel_Partner__c != null || booking.Sobha_Connect__c != null)
            {
            String bName;
            String bEmail;
            if((booking.Channel_Partner__c != null && booking.Sobha_Connect__c != null) || booking.Channel_Partner__c != null)
            {
               bName= booking.Channel_Partner__r.name;
               bEmail=booking.Channel_Partner__r.Email_ID_1__c;
            }
            if(booking.Channel_Partner__c == null && booking.Sobha_Connect__c != null)
            {
               bName= booking.Sobha_Connect__r.Name__c;
               bEmail=booking.Sobha_Connect__r.Email_Id__c; 
            }
               
       		String brokersub = 'Docusign for booking the unit# '+booking.Unit__r.Name+'  Project Name : '+booking.Project__r.Name;
            String brokerbody = BookingFormDocusignUtil.getSMSDBody(booking.Name,booking.Unit__r.Name);

            dfsle.Recipient.EmailSettings smsdEmailSetting1 = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        brokersub,
                                                                                                        brokerbody);
            
            String brokerAnchor = 'brokersignature1';
            //i=i+1;
            // Create a Sign Here tab
            dfsle.Tab brokerTab = new dfsle.SignHereTab()
                                                .withScale(1.0) // 1.0 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                    brokerAnchor, // Anchor string
                                                    false, // Do not allow white space in anchor string
                                                    false, // Anchor string is not case sensitive
                                                    'right', // Horizontal alignment in relation to the anchor text
                                                    true, // Ignore if the anchor text is not present in the document
                                                    true, // Must match the value of the anchor string in its entirety
                                                    'pixels', // Unit of the x and y offset properties
                                                    0, // X offset
                                                    0)); // Y offset 

            dfsle.Recipient brokerEmail = dfsle.Recipient.fromSource(
                                                                    bName, 
                                                                    bEmail,
                                                                    null, 
                                                                    null,
                                                                    null)
                                                                .withTabs(new List<dfsle.Tab> {
                                                                    brokerTab
                                                                })
                												.withEmailSettings(smsdEmailSetting1);
            recipientList.add(brokerEmail);
            emailToRoleMap.put(booking.Channel_Partner__r.Email_ID_1__c +'_'+i,'Broker');
            i=i+1;
            }
            }
      		// Hitesh Changes - Code ends 
    
            String SMSDDub = 'Docusign for booking the unit# '+booking.Unit__r.Name+'  Project Name : '+booking.Project__r.Name;
            String SMSDBody = BookingFormDocusignUtil.getSMSDBody(booking.Name,booking.Unit__r.Name);

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
                                                    'right', // Horizontal alignment in relation to the anchor text
                                                    true, // Ignore if the anchor text is not present in the document
                                                    true, // Must match the value of the anchor string in its entirety
                                                    'pixels', // Unit of the x and y offset properties
                                                    0, // X offset
                                                    0)); // Y offset 

            dfsle.Recipient salesManager = dfsle.Recipient.fromSource(
                                                                    booking.Sales_Managers__r.name, 
                                                                    booking.Sales_Managers__r.email,
                                                                    null, 
                                                                    null,
                                                                    null)
                                                                .withTabs(new List<dfsle.Tab> {
                                                                    salesManagerTab
                                                                })
                                                                .withEmailSettings(smsdEmailSetting);
            recipientList.add(salesManager);
            emailToRoleMap.put(booking.Sales_Managers__r.email +'_'+ i,'Sales manager');
            i=i+1;

            if (booking.Secondary_Sales_Manager__c != null) {
                String secondarySalesManagerAnchor = 'secondarysalesmanager';
                // Create a Sign Here tab
                dfsle.Tab secondarySalesManagerTab = new dfsle.SignHereTab()
                                                    .withScale(1.0) // 1.0 scale
                                                    .withRequired(true) // Signing mandatory
                                                    .withAnchor(new dfsle.Tab.Anchor(
                                                        secondarySalesManagerAnchor, // Anchor string
                                                        false, // Do not allow white space in anchor string
                                                        false, // Anchor string is not case sensitive
                                                        'right', // Horizontal alignment in relation to the anchor text
                                                        true, // Ignore if the anchor text is not present in the document
                                                        true, // Must match the value of the anchor string in its entirety
                                                        'pixels', // Unit of the x and y offset properties
                                                        0, // X offset
                                                        0)); // Y offset 

                dfsle.Recipient secondarySalesManager = dfsle.Recipient.fromSource(
                                                                        booking.Secondary_Sales_Manager__r.Name, 
                                                                        booking.Secondary_Sales_Manager__r.Email,
                                                                        null, 
                                                                        null,
                                                                        null)
                                                                    .withTabs(new List<dfsle.Tab> {
                                                                        secondarySalesManagerTab
                                                                    })
                                                                    .withEmailSettings(smsdEmailSetting);
                recipientList.add(secondarySalesManager);
                emailToRoleMap.put(booking.Secondary_Sales_Manager__r.Email +'_'+i,'Secondary Sales manager');
                i=i+1;
            }
    
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
                                                                booking.Sales_Head__r.name, 
                                                                booking.Sales_Head__r.email,
                                                                null, 
                                                                null,
                                                                null)
                                                            .withTabs(new List<dfsle.Tab> {
                                                                salesHeadTab
                                                            })
                                                            .withEmailSettings(smsdEmailSetting);
            recipientList.add(salesHead);
            emailToRoleMap.put(booking.Sales_Head__r.email +'_'+i,'Sales Head');
            i=i+1;

            if (booking.Secondary_Sales_Head__c != null) {
                String secondarySalesHeadAnchor = 'secondarysaleshead';
                dfsle.Tab secondarySalesHeadTab = new dfsle.SignHereTab()
                                                        .withScale(1.0) // 1.5 scale
                                                        .withRequired(true) // Signing mandatory
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            secondarySalesHeadAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            0)); // Y offset
                dfsle.Recipient secondarySalesHead = dfsle.Recipient.fromSource(
                                                                    booking.Secondary_Sales_Head__r.name, 
                                                                    booking.Secondary_Sales_Head__r.email,
                                                                    null, 
                                                                    null,
                                                                    null)
                                                                .withTabs(new List<dfsle.Tab> {
                                                                    secondarySalesHeadTab
                                                                })
                                                                .withEmailSettings(smsdEmailSetting);
                recipientList.add(secondarySalesHead);
                emailToRoleMap.put(booking.Secondary_Sales_Head__r.email +'_'+i,'Secondary Sales Head');
                i=i+1;
            }

            String SalesOpsSub = 'DocuSign Unit # - '+booking.Unit__r.Name+' Booking ID#'+booking.Name+' - Booking for Salesops Review';
            String SalesOpsBody = BookingFormDocusignUtil.getSalesOperationBody(booking.Name,booking.Unit__r.Name);

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
                                                                Label.DocusignSalesOperationsEmail,
                                                                null,
                                                                null,
                                                                null)
                                                            .withTabs(new List<dfsle.Tab> {
                                                                salesopsApproveTab,salesopsDeclineTab
                                                            })
                                                            .withEmailSettings(salesOpsEmailSetting);
            recipientList.add(salesops);
            emailToRoleMap.put(Label.DocusignSalesOperationsEmail +'_'+i,'Sales Ops');
            i=i+1;

            String auditSub = 'DocuSign Unit # - '+booking.Unit__r.Name+' Booking ID#'+booking.Name+' - Booking for Salesops Review';
            String auditBody = BookingFormDocusignUtil.getAuditBody(booking.Name,booking.Unit__r.Name);

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
                                                            Label.Salesops_Assurance_Team,//'Audit Team', Audit descope
                                                            Label.Salesops_Assurance_Email,//Label.DocusignAuditTeamEmail, Audit descope
                                                            null,
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                            auditTeamApproveTab,auditTeamDeclineTab
                                                        })
                                                        .withEmailSettings(auditEmailSetting);
            
            recipientList.add(auditTeam);
            emailToRoleMap.put(Label.DocusignAuditTeamEmail +'_'+i,'Audit Team');
            i=i+1;

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

            dfsle.Recipient sellerRep = dfsle.Recipient.fromSource(
                                                            booking.Seller_Representative__r.name,
                                                            booking.Seller_Representative__r.Email,
                                                            null, 
                                                            null,
                                                            null)
                                                            .withTabs(new List<dfsle.Tab> {
                                                                sellerRepTab,sellerStampTab
                                                                });
            recipientList.add(sellerRep);
            emailToRoleMap.put(booking.Seller_Representative__r.Email +'_'+i,'Seller Representative');
            i=i+1;
			
            //removed Custom Setting from line 449 and moved top of the method 
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
                System.debug('Envelope Id is :'+envelopeId);
                BookingFormDocusignUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap, applicantsSize);
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