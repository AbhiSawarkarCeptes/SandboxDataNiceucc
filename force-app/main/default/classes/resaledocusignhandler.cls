public without sharing class resaledocusignhandler  
{
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> resaleIds)
        {
            Id mySourceId = resaleIds[0];
            forForSigningFuture(mySourceId);
        }
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) 
    {
        try {
            Map<String,String> emailToRoleMap = new Map<String,String>();
			Resale_Process__c resale = [Select Id, Name, CRM_Document_Controller__r.Name, CRM_Document_Controller__r.Email, Type_of_Buyer__c, Booking__c, Booking__r.name, Booking__r.Unit__r.Name, Booking__r.Tower__c , Booking__r.Cluster__c, Unit__c, Unit__r.Name from  Resale_Process__c Where Id =:mySourceId order by createddate desc Limit 1];
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
    		String docName = 'Resale Agreement '+resale.Unit__r.Name+'%';
            System.debug('document Name should be: '+docName);
            List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:mySourceId 
                                                    and ContentDocument.title like :docName
                                                Order by ContentDocument.createdDate desc];

            Id myDocumentId = docList[0].ContentDocumentId; // The ID of a document stored in a Salesforce library
    
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
    
            List<Applicant_Details__c> applicants = [Select id,name, Email_Address__c, Applicant_Number__c,Mobile_Number__c,Type_Of_Applicant__c ,Corporate_Stamping_Required__c  From Applicant_Details__c
                                                        Where Booking__c =:resale.Booking__c ORDER BY Applicant_Signing_Order__c ASC];
            Integer applicantsSize = applicants.size();
            Integer i=1;
            Decimal scaleValue;
            Integer yOffset = 0;
            scaleValue = 1.0;
            yOffset = 10;
            Integer j=1;
            List<Buyer__c> buyers = [Select Id, Name, Email__c, Phone_Number__c, Passport_Number__c, Buyer_Type__c  from Buyer__c where Resale_Process__c=:mySourceId];
              
        
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
            
            //Docusign For Appllicants
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
            
            
            //Integer i = 1;
            for (Applicant_Details__c applicant:applicants) {
                emailToRoleMap.put(applicant.Email_Address__c +'_'+i,'Seller');
                
                //SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                String applPhoneNumber = validateAndUpdatePhoneNumber(applicant.Mobile_Number__c);
                smsPhoneNumbers.add(applPhoneNumber);
    
                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );

                String sub = resale.Booking__r.Unit__r.Name +' - '+resale.Booking__r.Cluster__c+' - Seller Email';
                String body = docusignSellerEmailBody();


                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en','English', sub, body);
    
                String anchorString = 'purchasersig' + String.valueOf(i);
                // Create a Sign Here tab
                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
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
                applicantsTabs.add(mySignHereTab);
                
                 //If corporate applicant enable stamping for primary
                if (applicant.Applicant_Number__c == 'Primary Applicant' && applicant.Type_Of_Applicant__c == 'Corporate Purchaser') {
                    dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                .withScale(1.0) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                    'sellerstamp', // Anchor string
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
                                                                null
                                                            )
                                                            .withTabs(applicantsTabs)
                                                            .withAuthentication(auth)
                                                            .withEmailSettings(applicantEmailSetting);
                
                recipientList.add(myRecipient);
                i = i+1;
            }
    
            //buyers
            for (Buyer__c applicant: buyers) {
                emailToRoleMap.put(applicant.Email__c +'_'+i,'Buyer');
                
                //SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                String applPhoneNumber = resaledocusignUtil.validateAndUpdatePhoneNumber(applicant.Phone_Number__c);
                smsPhoneNumbers.add(applPhoneNumber);
    
                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );

                String sub = resale.Booking__r.Unit__r.Name +' - '+resale.Booking__r.Cluster__c+' - buyer Email';
                String body = docusignBuyerEmailBody();

                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en','English',sub,body);
    
                String anchorString = 'buyersign' + String.valueOf(j);
                // Create a Sign Here tab
                List<dfsle.Tab> buyerTabs = new List<dfsle.Tab>();
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
                buyerTabs.add(mySignHereTab);
                 //If corporate applicant enable stamping for primary
                if (applicant.Buyer_Type__c  == 'Primary Applicant' && resale.Type_of_Buyer__c == 'Company') {
                    dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                                .withScale(1.0) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                    'buyerstamp', // Anchor string
                                                                    false, // Do not allow white space in anchor string
                                                                    false, // Anchor string is not case sensitive
                                                                    'right', // Horizontal alignment in relation to the anchor text
                                                                    true, // Ignore if the anchor text is not present in the document
                                                                    true, // Must match the value of the anchor string in its entirety
                                                                    'pixels', // Unit of the x and y offset properties
                                                                    0, // X offset
                                                                    0)
                                                            ); // Y offset

                    buyerTabs.add(corpAppStampTab);
                }
    
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                applicant.name,
                                                                applicant.Email__c,
                                                                null, 
                                                                applicant.Phone_Number__c ,
                                                                null
                                                            )
                                                            .withTabs(buyerTabs)
                                                            .withAuthentication(auth)
                                                            .withEmailSettings(applicantEmailSetting);
                
                recipientList.add(myRecipient);
                i = i+1;
                j=j+1;
            }
            
            String CRMOpsSub = 'DocuSign Unit # - '+resale.Booking__r.Unit__r.Name+' Booking ID#'+resale.Booking__r.name+' - for Resale# '+resale.Name;
            String CRMOpsBody = docusignCRMTeamEmailBody(resale.name);

            dfsle.Recipient.EmailSettings crmEmailSetting = new dfsle.Recipient.EmailSettings('en','English', CRMOpsSub, CRMOpsBody);
            String crmApproveAnchor = 'crmopsapprove';
            String crmDeclineAnchor = 'crmopsdecline';
            dfsle.Tab crmApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            crmApproveAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            dfsle.Tab crmDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            crmDeclineAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            dfsle.Recipient crmops = dfsle.Recipient.fromSource(
                                                                'Resale CRM Ops', 
                                                                Label.Resale_DocuSign_CRM_Ops,
                                                                null,
                                                                null,
                                                                null)
                                                            .withTabs(new List<dfsle.Tab> {
                                                                crmApproveTab,crmDeclineTab
                                                            })
                                                            .withEmailSettings(crmEmailSetting);
                                                            
            recipientList.add(crmops);
            emailToRoleMap.put(Label.Resale_DocuSign_CRM_Ops +'_'+i,'Resale CRM Ops');
            i=i+1;
			
            //Authorized Signatory
            String authsub =resale.Booking__r.Unit__r.Name +' - '+resale.Booking__r.Cluster__c+' - Authorized Signatory Email for Resale# '+resale.Name;
            String authbody = docusignAuthEmailBody(resale.name);
            dfsle.Recipient.EmailSettings authEmailSetting = new dfsle.Recipient.EmailSettings('en','English', authsub,authbody);
            
            String authAnchor = 'authsign';
            // Create a Sign Here tab
            dfsle.Tab authTab = new dfsle.SignHereTab()
                                                .withScale(1.0) // 1.0 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                    authAnchor, // Anchor string
                                                    false, // Do not allow white space in anchor string
                                                    false, // Anchor string is not case sensitive
                                                    'right', // Horizontal alignment in relation to the anchor text
                                                    true, // Ignore if the anchor text is not present in the document
                                                    true, // Must match the value of the anchor string in its entirety
                                                    'pixels', // Unit of the x and y offset properties
                                                    0, // X offset
                                                    0)); // Y offset 

            dfsle.Recipient authEmail = dfsle.Recipient.fromSource('Authorized Signatory', Label.Resale_Authorized_Signatory, null, null, null).withTabs(new List<dfsle.Tab> {authTab}).withEmailSettings(authEmailSetting);
            recipientList.add(authEmail);
            emailToRoleMap.put(Label.Resale_Authorized_Signatory +'_'+i,'Authorized Signatory');
            i=i+1;
            //Authorized Siganatory Ends
            
             //CRM Document Controller
                    String docContSub = resale.Booking__r.Unit__r.Name +' - '+resale.Booking__r.Cluster__c+' - CRM Controller - '+resale.Name;
                    String docContBody = docusignDocumentControllerEmailBody(resale.name);
                    dfsle.Recipient.EmailSettings docContEmailSetting = new dfsle.Recipient.EmailSettings('en','English',docContSub,docContBody);
                    dfsle.SignHereTab.Stamp docControllerStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab docControllerStampTab = new dfsle.SignHereTab().withStamp(docControllerStamp)
                                                                            .withScale(1.0) // 1.5 scale
                                                                            .withRequired(true) // Signing mandatory
                                                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                                'resaledocstamp', // Anchor string
                                                                                false, // Do not allow white space in anchor string
                                                                                false, // Anchor string is not case sensitive
                                                                                'right', // Horizontal alignment in relation to the anchor text
                                                                                true, // Ignore if the anchor text is not present in the document
                                                                                true, // Must match the value of the anchor string in its entirety
                                                                                'pixels', // Unit of the x and y offset properties
                                                                                10, // X offset
                                                                                0));// Y offset
                    emailToRoleMap.put(resale.CRM_Document_Controller__r.Email +'_'+i,'Document Controller');
                    i=i+1;
                    dfsle.Recipient docControllerRecipient = dfsle.Recipient.fromSource(
                                                                                resale.CRM_Document_Controller__r.Name,
                                                                                resale.CRM_Document_Controller__r.Email,
                                                                                null, 
                                                                                null,
                                                                                null)
                                                                                .withTabs(new List<dfsle.Tab> {
                                                                                        docControllerStampTab
                                                                                })
                                                                                .withEmailSettings(docContEmailSetting);
                        														
                    recipientList.add(docControllerRecipient);

            //Add the signers...
            myEnvelope = myEnvelope
                            .withRecipients(recipientList);
                            //.withNotifications(expirySettings );

            //Send the Envelope
            if(!Test.isRunningTest()) {
                myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                    myEnvelope,
                    true
                );
               // String envelopeId = String.valueOf(myEnvelope.docuSignId);
               // Booking__c b = new Booking__c(id=mySourceId, SPA_Docusign_Envelope_Id__c=envelopeId);
               // update b;
            }
                String envelopeId = String.valueOf(myEnvelope.docuSignId);
                System.debug('Envelop Id: '+envelopeId);
            
                Docusign_Result__e event = new Docusign_Result__e();
                event.MessageToDisplay__c = 'Resale document successfully sent for Docusign.';
                event.Booking_Id__c = mySourceId;
                event.User_Id__c = UserInfo.getUserId();
                EventBus.publish(event);
            	docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap, applicantsSize);
            } 
            
        catch (Exception e) 
            {
                Docusign_Result__e event = new Docusign_Result__e();
                event.MessageToDisplay__c = 'Error sending resale document for Docusign - '+e.getMessage();
                event.Booking_Id__c = mySourceId;
                event.User_Id__c = UserInfo.getUserId();
                EventBus.publish(event);
            } 
    }
        public static String docusignSellerEmailBody() {
            return 
            'Dear Customer \n\n'+
				'Greetings from Sobha Realty! \n\n'+
                'We trust this communication finds you well. \n\n'+
                'Attached to this email is the Assignment Agreement for digital signoff via DocuSign, the link for which is valid for seven days from the day of origination of the email. \n\n'+
                'The instructions for signing the document via DocuSign are as below: \n'+
                '<ol>'+
                '<li>Click on Review document and enter the OTP received on your registered mobile number to procced to sign..</li>'+
                '<li>Click on the Start to initiate the signing.</li> '+
                '<li>Draw the Signature and follow the Docusign flow to sign the Document</li>'+
                '<li>Click on Finish once the document is complete.</li></ol>\n'+
                '<ol>'+
                'Best Regards,\n\n'+
                'CRM Team \n'+
                'Sobha Realty</p>\n';
        }

        public static String docusignBuyerEmailBody() {
            return 
            'Dear Customer \n\n'+
				'Greetings from Sobha Realty! \n\n'+
                'We trust this communication finds you well. \n\n'+
                'Attached to this email is the Assignment Agreement for digital signoff via DocuSign, the link for which is valid for seven days from the day of origination of the email. \n\n'+
                'The instructions for signing the document via DocuSign are as below: \n'+
                '<ol>'+
                '<li>Click on Review document and enter the OTP received on your registered mobile number to procced to sign..</li>'+
                '<li>Click on the Start to initiate the signing.</li> '+
                '<li>Draw the Signature and follow the Docusign flow to sign the Document</li>'+
                '<li>Click on Finish once the document is complete.</li></ol>\n'+
                '<ol>'+
                'Best Regards,\n\n'+
                'CRM Team \n'+
                'Sobha Realty</p>\n';
        }
    	public static String docusignAuthEmailBody(String resale)
    	{	
            return 
                'Dear Authorized Signatory \n\n'+
            	'Please find attached the Assignment Agreement signed off by the customer. Please review the same and sign off.\n'+
                'Resale Reference Number  '+resale+'\n'+
            	'\n'+
            	'\n'+
            	'Best Regards,\n\n'+
                'CRM Team \n'+
                'Sobha Realty</p>\n';      
    	}
    public static String docusignCRMTeamEmailBody(String resale)
    	{	
            return 
                'Dear CRM Team \n\n'+
            	'Please find attached the Assignment Agreement signed off by the customer. Please review the same and Approve or Decline.\n'+
            	'Resale Reference Number  '+resale+'\n'+
                '\n'+
            	'\n'+
            	'Best Regards,\n\n'+
                'Sobha Realty</p>\n';      
    	}
    public static String docusignDocumentControllerEmailBody(String resale)
    	{	
            return 
                'Dear CRM Document Controller \n\n'+
            	'Please find the attached Resale Agreement. Please review the same and sign off.\n'+
                'Resale Reference Number  '+resale+'\n'+
            	'\n'+
            	'\n'+
            	'Best Regards,\n\n'+
                'CRM Team \n'+
                'Sobha Realty</p>\n';      
    	}
    Public static void docusignPostProcessing(String envelopeId, Id resaleId, Id myDocumentId, Map<String,String> emailToRoleMap, Integer applicantsSize)
    	{
           // sleep(50);
        
   	    List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c, Resale_Process__c From dfsle__EnvelopeStatus__c Where dfsle__DocuSignId__c=:envelopeId];
		System.debug('docusignPostProcessing'+docusignStatusList+'Time is :'+system.now());
        if (docusignStatusList.size() > 0) 
        {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'Resale process';
            ds.Resale_Process__c  = resaleId;
            update ds; 

            List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
            List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__RoutingOrder__c,Booking__c,dfsle__Email__c,Envelope_Type__c, Envelope_Recipient_Type__c, Resale_Process__c From dfsle__RecipientStatus__c Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];
            Integer i = 1;
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) 
            {
                String drsKey=rs.dfsle__Email__c+'_'+rs.dfsle__RoutingOrder__c;
                if (emailToRoleMap.containsKey(drsKey)) {
                    rs.Resale_Process__c = resaleId;
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(drsKey);
                    rs.Envelope_Type__c = 'Resale process';
                    if (i==applicantsSize) {
                        rs.Last_Applicant__c = true;
                    } else {
                        rs.Last_Applicant__c = false;
                    }
                    rsToUpdateList.add(rs);
                }
                i += 1;
            }                                                        
            update rsToUpdateList;
            system.debug(rsToUpdateList);

        } 
    } 
    
 	Private static String validateAndUpdatePhoneNumber(String phoneNumber) 
        {
        	if (!phoneNumber.startsWith('+')) 
        		{
            		phoneNumber = '+'+phoneNumber;
        		}
        	return phoneNumber;
    	}
    
   /* public static void sleep(Integer secs ) {
        datetime myStartDateTime = datetime.now();
        DateTime newDateTime = myStartDateTime.addSeconds(secs);
        while (datetime.now() < newDateTime ) {
            // sleeping here...sort of
        }
        datetime myEndDateTime = datetime.now();
        System.debug('start:  ' + myStartDateTime ) ;
        System.debug('end:  ' + myEndDateTime) ;
    }  */
    
}