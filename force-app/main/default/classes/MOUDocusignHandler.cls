/*********************************************************************
 * Class Name  :   MOUDocusignHandler
 * Description :   Helper Class of Flow Send MOU for Docusign (Flow)
 * Created Date:   24/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 24/01/2024
                        Nishank Manwani 24/05/2024
 *********************************************************************/
public with sharing class MOUDocusignHandler {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> transactionReqIds) {
        Id mySourceId = transactionReqIds[0];

        PropStrength__Transaction_Requests__c updateTr = new PropStrength__Transaction_Requests__c(Id=mySourceId);
        updateTr.MOU_Sent_to_Development_and_Legal_Team__c = true;
        updateTr.MOU_Sent_to_Development_Legal_Date__c = System.Now();
        updateTr.PropStrength__Status__c = 'MOU Sent to Development and Legal Team for Verification';
        update updateTr;
        forForSigningFuture(mySourceId);
    } 
    
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            Map<String,String> emailToRoleMap = new Map<String,String>();    
            Id myDocumentId = MOUDocusignUtil.getFileId(mySourceId);
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;

            PropStrength__Transaction_Requests__c tr = MOUDocusignUtil.getTransactionRequest(mySourceId);
            List<PropStrength__Applicant_Detail__c> applicants = MOUDocusignUtil.getApplicants(tr.PropStrength__Application_Booking__c);

            List<Document__c> companyAuthSign = new List<Document__c>();

            if(tr.PropStrength__Application_Booking__c != null) {
                companyAuthSign = [SELECT Id, RecordType.Name, Authorized_Signatory_1_Email__c, Authorized_Signatory_2_Email__c, 
                                Authorized_Signatory_3_Email__c, Authorized_Signatory_4_Email__c, Authorized_Signatory_5_Email__c 
                                FROM Document__c WHERE Document_Type__c = 'MOU' AND Application_Booking__c = :tr.PropStrength__Application_Booking__c];
            }

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

            //Development Team (Approver)
            String devlopmentSub = 'DocuSign Unit # - '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name+' Booking ID#'+tr.PropStrength__Application_Booking__r.Name+' - Booking for Development Team Review';
            String devlopmentBody = MOUDocusignUtil.getDevelopmentBody(tr.PropStrength__Application_Booking__r.Name,tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name);
            dfsle.Recipient.EmailSettings devlopmentEmailSetting = new dfsle.Recipient.EmailSettings('en','English',devlopmentSub,devlopmentBody);
            
            String devlopmentTeamApproveAnchor = 'devlopmentteamapprove';
            String devlopmentTeamDeclineAnchor = 'devlopmentteamdecline';

            dfsle.Tab devlopmentTeamApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            devlopmentTeamApproveAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            dfsle.Tab devlopmentTeamDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            devlopmentTeamDeclineAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.Development_Team_Email_Docusign__c +'_'+i,'Development Team');
            i=i+1;
            dfsle.Recipient devlopmentTeam = dfsle.Recipient.fromSource(
                                                            'Development Team', 
                                                            tr.PropStrength__Application_Booking__r.Development_Team_Email_Docusign__c,
                                                            null,
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                            devlopmentTeamApproveTab,devlopmentTeamDeclineTab
                                                        })
                                                        .withEmailSettings(devlopmentEmailSetting);
            
            recipientList.add(devlopmentTeam);


            //Legal Team (Approver)
            String legalSub = 'DocuSign Unit # - '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name+' Booking ID#'+tr.PropStrength__Application_Booking__r.Name+' - Booking for Legal Team Review';
            String legalBody = MOUDocusignUtil.getLegalBody(tr.PropStrength__Application_Booking__r.Name,tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name);
            dfsle.Recipient.EmailSettings legalEmailSetting = new dfsle.Recipient.EmailSettings('en','English',legalSub,legalBody);
            
            String legalTeamApproveAnchor = 'legalteamapprove';
            String legalTeamDeclineAnchor = 'legalteamdecline';

            dfsle.Tab legalTeamApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            legalTeamApproveAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            dfsle.Tab legalTeamDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            legalTeamDeclineAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            emailToRoleMap.put(tr.PropStrength__Application_Booking__r.Legal_Team_email_Docusign__c +'_'+i,'Legal Team');
            i=i+1;
            dfsle.Recipient legalTeam = dfsle.Recipient.fromSource(
                                                            'Legal Team', 
                                                            tr.PropStrength__Application_Booking__r.Legal_Team_email_Docusign__c,
                                                            null,
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                            legalTeamApproveTab,legalTeamDeclineTab
                                                        })
                                                        .withEmailSettings(legalEmailSetting);
            
            recipientList.add(legalTeam);

            Integer j = 1;
            Map<Integer, PropStrength__Applicant_Detail__c> authorizedMap = new Map<Integer, PropStrength__Applicant_Detail__c>();
            Integer num=1;
            for (PropStrength__Applicant_Detail__c applicant:applicants)  {
                //authirised signature logic starts here
                authorizedMap.put(num, applicant);
                num++;
            }

            if(tr.PropStrength__Application_Booking__r.POA_Name__c != null && tr.PropStrength__Application_Booking__r.POA_Email_Address__c != null && tr.PropStrength__Application_Booking__r.POA_Mobile_Number__c != null) {
                emailToRoleMap.put(tr.PropStrength__Application_Booking__r.POA_Email_Address__c +'_'+i,'POA');

                String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - Memorandum of Understanding (MOU) for Digital Signoff';
                String body = MOUDocusignUtil.docusignEmailBody(tr.PropStrength__Application_Booking__r.PropStrength__Tower__c);

                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        sub,
                                                                                                        body);
    
                //SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                String applPhoneNumber = MOUDocusignUtil.validateAndUpdatePhoneNumber(tr.PropStrength__Application_Booking__r.POA_Mobile_Number__c);
                smsPhoneNumbers.add(applPhoneNumber);

                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                
                String anchorInitialsString = 'pids' + String.valueOf(j);
                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();

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
    
                String anchorString = 'purchasersig' + String.valueOf(j);
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

                applicantsTabs.add(myInitialHereTab);
                applicantsTabs.add(mySignHereTab);
    
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                        tr.PropStrength__Application_Booking__r.POA_Name__c,
                                                                        tr.PropStrength__Application_Booking__r.POA_Email_Address__c,
                                                                        null, 
                                                                        null,
                                                                        null)
                                                                    .withTabs(applicantsTabs)
                                                                    .withAuthentication(auth)
                                                                    .withEmailSettings(applicantEmailSetting);
                recipientList.add(myRecipient);
                j++;
                i = i+1;
            } else {
                Boolean flagCompany = false;
                Boolean flagCompanyRep = false;
                for(Document__c doc : companyAuthSign) {
                    if(doc.RecordType.Name == 'Company Representative') {
                        flagCompanyRep = true;
                        break;
                    }
                }
                if(!companyAuthSign.isEmpty() && flagCompanyRep) {
                    for(PropStrength__Applicant_Detail__c applicant : authorizedMap.Values()) {
                        if(applicant.PropStrength__Applicant_Acc__r.PropStrength__Account_Type__c == 'Company') {
                            flagCompany = true;
                            break;
                        }
                    }
                }

                if(!flagCompany) {
                    for(PropStrength__Applicant_Detail__c applicant : authorizedMap.Values()) {
                        applicantsSize=i;
                        String toEmailAddress;
                        String anchorString;
                        String phonenumber;

                        emailToRoleMap.put(applicant.PropStrength__Applicant_Email__c +'_'+i,'Applicant');
                        toEmailAddress=applicant.PropStrength__Applicant_Email__c;
                        anchorString = 'purchasersig' + String.valueOf(j);
                        phonenumber=applicant.PropStrength__Applicant_Mobile__c;
                        
                        String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - Memorandum of Understanding (MOU) for Digital Signoff';
                        String body = MOUDocusignUtil.docusignEmailBody(tr.PropStrength__Application_Booking__r.PropStrength__Tower__c);
        
                        dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                                'English',
                                                                                                                sub,
                                                                                                                body);
            
                        //SMS authentication phone numbers
                        List<String> smsPhoneNumbers = new List<String>();
                        String applPhoneNumber = MOUDocusignUtil.validateAndUpdatePhoneNumber(applicant.PropStrength__Applicant_Mobile__c);
                        smsPhoneNumbers.add(applPhoneNumber);
                        //Set the authentication
                        dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );

                        List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                        String anchorInitialsString = 'pids' + String.valueOf(j);
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
                        if (j==1) {
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
                        // applicant.Email_Address__c
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
                        j++;
                        i = i+1;
                    }
                } else {
                    for(Document__c doc : companyAuthSign) {
                        if(doc.RecordType.Name == 'Company Representative') {
                            if(doc.Authorized_Signatory_1_Email__c != null) {
                                applicantsSize=i;
                                String toEmailAddress;
                                String anchorString;

                                emailToRoleMap.put(doc.Authorized_Signatory_1_Email__c +'_'+i,'Applicant');
                                toEmailAddress=doc.Authorized_Signatory_1_Email__c;
                                anchorString = 'purchasersig' + String.valueOf(j);
                                
                                String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - Memorandum of Understanding (MOU) for Digital Signoff';
                                String body = MOUDocusignUtil.docusignEmailBody(tr.PropStrength__Application_Booking__r.PropStrength__Tower__c);
                
                                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                                        'English',
                                                                                                                        sub,
                                                                                                                        body);
                    
                                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                                String anchorInitialsString = 'pids' + String.valueOf(j);
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
                            
                                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                                        'Authorised Signatory '+i,
                                                                                        toEmailAddress,
                                                                                        null, 
                                                                                        null,
                                                                                        null)
                                                                                    .withTabs(applicantsTabs)
                                                                                    .withEmailSettings(applicantEmailSetting);
                                recipientList.add(myRecipient);
                                i = i+1;
                            }
                            if(doc.Authorized_Signatory_2_Email__c != null) {
                                applicantsSize=i;
                                String toEmailAddress;
                                String anchorString;

                                emailToRoleMap.put(doc.Authorized_Signatory_2_Email__c +'_'+i,'Applicant');
                                toEmailAddress=doc.Authorized_Signatory_2_Email__c;
                                anchorString = 'purchasersig' + String.valueOf(j);
                                
                                String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - Memorandum of Understanding (MOU) for Digital Signoff';
                                String body = MOUDocusignUtil.docusignEmailBody(tr.PropStrength__Application_Booking__r.PropStrength__Tower__c);
                
                                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                                        'English',
                                                                                                                        sub,
                                                                                                                        body);
                    
                                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                                String anchorInitialsString = 'pids' + String.valueOf(j);
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
                            
                                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                                        'Authorised Signatory '+i,
                                                                                        toEmailAddress,
                                                                                        null, 
                                                                                        null,
                                                                                        null)
                                                                                    .withTabs(applicantsTabs)
                                                                                    .withEmailSettings(applicantEmailSetting);
                                recipientList.add(myRecipient);
                                i = i+1;
                            }
                            if(doc.Authorized_Signatory_3_Email__c != null) {
                                applicantsSize=i;
                                String toEmailAddress;
                                String anchorString;

                                emailToRoleMap.put(doc.Authorized_Signatory_3_Email__c +'_'+i,'Applicant');
                                toEmailAddress=doc.Authorized_Signatory_3_Email__c;
                                anchorString = 'purchasersig' + String.valueOf(j);
                                
                                String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - Memorandum of Understanding (MOU) for Digital Signoff';
                                String body = MOUDocusignUtil.docusignEmailBody(tr.PropStrength__Application_Booking__r.PropStrength__Tower__c);
                
                                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                                        'English',
                                                                                                                        sub,
                                                                                                                        body);
                    
                                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                                String anchorInitialsString = 'pids' + String.valueOf(j);
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
                            
                                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                                        'Authorised Signatory '+i,
                                                                                        toEmailAddress,
                                                                                        null, 
                                                                                        null,
                                                                                        null)
                                                                                    .withTabs(applicantsTabs)
                                                                                    .withEmailSettings(applicantEmailSetting);
                                recipientList.add(myRecipient);
                                i = i+1;
                            }
                            if(doc.Authorized_Signatory_4_Email__c != null) {
                                applicantsSize=i;
                                String toEmailAddress;
                                String anchorString;

                                emailToRoleMap.put(doc.Authorized_Signatory_4_Email__c +'_'+i,'Applicant');
                                toEmailAddress=doc.Authorized_Signatory_4_Email__c;
                                anchorString = 'purchasersig' + String.valueOf(j);
                                
                                String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - Memorandum of Understanding (MOU) for Digital Signoff';
                                String body = MOUDocusignUtil.docusignEmailBody(tr.PropStrength__Application_Booking__r.PropStrength__Tower__c);
                
                                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                                        'English',
                                                                                                                        sub,
                                                                                                                        body);
                    
                                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                                String anchorInitialsString = 'pids' + String.valueOf(j);
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
                            
                                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                                        'Authorised Signatory '+i,
                                                                                        toEmailAddress,
                                                                                        null, 
                                                                                        null,
                                                                                        null)
                                                                                    .withTabs(applicantsTabs)
                                                                                    .withEmailSettings(applicantEmailSetting);
                                recipientList.add(myRecipient);
                                i = i+1;
                            }
                            if(doc.Authorized_Signatory_5_Email__c != null) {
                                applicantsSize=i;
                                String toEmailAddress;
                                String anchorString;

                                emailToRoleMap.put(doc.Authorized_Signatory_5_Email__c +'_'+i,'Applicant');
                                toEmailAddress=doc.Authorized_Signatory_5_Email__c;
                                anchorString = 'purchasersig' + String.valueOf(j);
                                
                                String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - '+tr.PropStrength__Application_Booking__r.PropStrength__Project__r.Name+' - Memorandum of Understanding (MOU) for Digital Signoff';
                                String body = MOUDocusignUtil.docusignEmailBody(tr.PropStrength__Application_Booking__r.PropStrength__Tower__c);
                
                                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                                        'English',
                                                                                                                        sub,
                                                                                                                        body);
                    
                                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                                String anchorInitialsString = 'pids' + String.valueOf(j);
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
                            
                                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                                        'Authorised Signatory '+i,
                                                                                        toEmailAddress,
                                                                                        null, 
                                                                                        null,
                                                                                        null)
                                                                                    .withTabs(applicantsTabs)
                                                                                    .withEmailSettings(applicantEmailSetting);
                                recipientList.add(myRecipient);
                                i = i+1;
                            }
                        }
                    }
                }
            }

            //Audit - part 2
            String auditSub = 'DocuSign Unit # - '+tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name+' Booking ID#'+tr.PropStrength__Application_Booking__r.Name+' - Booking for Audit Review';
            String auditBody = MOUDocusignUtil.getAuditBody(tr.PropStrength__Application_Booking__r.Name,tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name);
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
            
            Boolean flagSellerRep = false;
            for(Document__c doc : companyAuthSign) {
                if(doc.RecordType.Name == 'Seller Representative') {
                    flagSellerRep = true;
                    break;
                }
            }            
        
            if(tr.PropStrength__Application_Booking__r.Seller_Representative__r.Email != null && !flagSellerRep) {        
                //Seller representative
                String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - Memorandum of Understanding (MOU) for Digital Signoff';
                String body = MOUDocusignUtil.docusignSellerEmailBody();
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
                                                                ); 
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
            }else if(flagSellerRep) {
                for(Document__c doc : companyAuthSign) {
                    if(doc.RecordType.Name == 'Seller Representative') {
                        if(doc.Authorized_Signatory_1_Email__c != null) {
                            String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - Memorandum of Understanding (MOU) for Digital Signoff';
                            String body = MOUDocusignUtil.docusignSellerEmailBody();
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
                                                                            ); 
                            emailToRoleMap.put(doc.Authorized_Signatory_1_Email__c +'_'+i,'Seller Representative');
                            i=i+1;
                            dfsle.Recipient sellerRecipient = dfsle.Recipient.fromSource(
                                                                            'Seller Representative',  
                                                                            doc.Authorized_Signatory_1_Email__c,
                                                                            null, 
                                                                            null,
                                                                            null)
                                                                        .withTabs(new List<dfsle.Tab> {
                                                                                sellerSignTab
                                                                            })
                                                                        .withEmailSettings(sellerEmailSetting);
                            recipientList.add(sellerRecipient);
                        }
                        if(doc.Authorized_Signatory_2_Email__c != null) {
                            String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - Memorandum of Understanding (MOU) for Digital Signoff';
                            String body = MOUDocusignUtil.docusignSellerEmailBody();
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
                                                                            ); 
                            emailToRoleMap.put(doc.Authorized_Signatory_2_Email__c +'_'+i,'Seller Representative');
                            i=i+1;
                            dfsle.Recipient sellerRecipient = dfsle.Recipient.fromSource(
                                                                            'Seller Representative',  
                                                                            doc.Authorized_Signatory_2_Email__c,
                                                                            null, 
                                                                            null,
                                                                            null)
                                                                        .withTabs(new List<dfsle.Tab> {
                                                                                sellerSignTab
                                                                            })
                                                                        .withEmailSettings(sellerEmailSetting);
                            recipientList.add(sellerRecipient);
                        }
                        if(doc.Authorized_Signatory_3_Email__c != null) {
                            String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - Memorandum of Understanding (MOU) for Digital Signoff';
                            String body = MOUDocusignUtil.docusignSellerEmailBody();
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
                                                                            ); 
                            emailToRoleMap.put(doc.Authorized_Signatory_3_Email__c +'_'+i,'Seller Representative');
                            i=i+1;
                            dfsle.Recipient sellerRecipient = dfsle.Recipient.fromSource(
                                                                            'Seller Representative',  
                                                                            doc.Authorized_Signatory_3_Email__c,
                                                                            null, 
                                                                            null,
                                                                            null)
                                                                        .withTabs(new List<dfsle.Tab> {
                                                                                sellerSignTab
                                                                            })
                                                                        .withEmailSettings(sellerEmailSetting);
                            recipientList.add(sellerRecipient);
                        }
                        if(doc.Authorized_Signatory_4_Email__c != null) {
                            String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - Memorandum of Understanding (MOU) for Digital Signoff';
                            String body = MOUDocusignUtil.docusignSellerEmailBody();
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
                                                                            ); 
                            emailToRoleMap.put(doc.Authorized_Signatory_4_Email__c +'_'+i,'Seller Representative');
                            i=i+1;
                            dfsle.Recipient sellerRecipient = dfsle.Recipient.fromSource(
                                                                            'Seller Representative',  
                                                                            doc.Authorized_Signatory_4_Email__c,
                                                                            null, 
                                                                            null,
                                                                            null)
                                                                        .withTabs(new List<dfsle.Tab> {
                                                                                sellerSignTab
                                                                            })
                                                                        .withEmailSettings(sellerEmailSetting);
                            recipientList.add(sellerRecipient);
                        }
                        if(doc.Authorized_Signatory_5_Email__c != null) {
                            String sub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name +' - Memorandum of Understanding (MOU) for Digital Signoff';
                            String body = MOUDocusignUtil.docusignSellerEmailBody();
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
                                                                            ); 
                            emailToRoleMap.put(doc.Authorized_Signatory_5_Email__c +'_'+i,'Seller Representative');
                            i=i+1;
                            dfsle.Recipient sellerRecipient = dfsle.Recipient.fromSource(
                                                                            'Seller Representative',  
                                                                            doc.Authorized_Signatory_5_Email__c,
                                                                            null, 
                                                                            null,
                                                                            null)
                                                                        .withTabs(new List<dfsle.Tab> {
                                                                                sellerSignTab
                                                                            })
                                                                        .withEmailSettings(sellerEmailSetting);
                            recipientList.add(sellerRecipient);
                        }
                    }
                }
            }
            

            String crmSub = tr.PropStrength__Application_Booking__r.PropStrength__Property__r.Name + ' - Memorandum of Understanding (MOU) for Digital Signoff';
            String crmBody = MOUDocusignUtil.docusignDocumentControllerEmailBody();
            dfsle.Recipient.EmailSettings crmDocuStamp = new dfsle.Recipient.EmailSettings('en',
                                                                                                    'English',
                                                                                                    crmSub,
                                                                                                    crmBody);
            
            dfsle.SignHereTab.Stamp crmStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
            dfsle.Tab crmStampTab = new dfsle.SignHereTab().withStamp(crmStamp)
                                                .withScale(1.0) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                    'crmstampsobha', // Anchor string
                                                                    false, // Do not allow white space in anchor string
                                                                    false, // Anchor string is not case sensitive
                                                                    'right', // Horizontal alignment in relation to the anchor text
                                                                    true, // Ignore if the anchor text is not present in the document
                                                                    true, // Must match the value of the anchor string in its entirety
                                                                    'pixels', // Unit of the x and y offset properties
                                                                    10, // X offset
                                                                    0)
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
                MOUDocusignUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap, applicantsSize);
            }
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'MOU Letter sent successfully sent for Docusign.';
            event.Transaction_Request_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        } 
        catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Error sending MOU Letter for Docusign - '+e.getMessage();
            event.Transaction_Request_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }
}