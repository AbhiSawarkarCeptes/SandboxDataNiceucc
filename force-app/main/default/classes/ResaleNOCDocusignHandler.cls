public without sharing class ResaleNOCDocusignHandler 
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
            Resale_Process__c resale = [Select Id, Name, CRM_Document_Controller__c, CRM_Document_Controller__r.Name,Booking__r.Name, CRM_Document_Controller__r.email, Booking__c, Booking__r.Unit__r.Name, Booking__r.Tower__c , Booking__r.Cluster__c, Unit__c, Unit__r.Name from  Resale_Process__c Where Id =:mySourceId order by createddate desc Limit 1];
            String docName = 'NOC for resale '+resale.Unit__r.Name+'%';
            System.debug('resale noc doc name: '+docName);
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
    
            List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:mySourceId 
                                                    and ContentDocument.title like :docName
                                                Order by ContentDocument.createdDate desc];

            Id myDocumentId = docList[0].ContentDocumentId; // The ID of a document stored in a Salesforce library
    
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
    
            //Get Resale Record
            
            
          
            Integer i=1;
            Decimal scaleValue;
            Integer yOffset = 0;
            scaleValue = 1.0;
            yOffset = 10;
            Integer j=1;
            
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
            
            //Docusign For Appllicants
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();

            String AuditOpsSub = 'DocuSign Unit # - '+resale.Booking__r.Unit__r.Name+' Booking ID#'+resale.Booking__r.name+' - for Resale# '+resale.Name+ ' - Audit Approval';
            String AuditOpsBody = docusignAuditEmailBody(resale.name);

            dfsle.Recipient.EmailSettings AuditEmailSetting = new dfsle.Recipient.EmailSettings('en','English', AuditOpsSub, AuditOpsBody);
            String AuditApproveAnchor = 'auditapprove';
            String AuditDeclineAnchor = 'auditdecline';
            dfsle.Tab AuditApproveTab = new dfsle.ApproveTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            AuditApproveAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            dfsle.Tab AuditDeclineTab = new dfsle.DeclineTab()
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            AuditDeclineAnchor, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'right', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            5)); // Y offset
            dfsle.Recipient Auditops = dfsle.Recipient.fromSource(
                                                                'Resale Audit', 
                                                                Label.Resale_Audit_Signatory,
                                                                null,
                                                                null,
                                                                null)
                                                            .withTabs(new List<dfsle.Tab> {
                                                                AuditApproveTab,AuditDeclineTab
                                                            })
                                                            .withEmailSettings(AuditEmailSetting);
                                                            
            recipientList.add(Auditops);
            emailToRoleMap.put(Label.Resale_Audit_Signatory +'_'+i,'Resale Audit');
            i=i+1;
            
            //Authorized Signatory
            String authsub =resale.Booking__r.Unit__r.Name +' - '+resale.Booking__r.Cluster__c+' - Authorized Signatory NOC Email for Resale# '+resale.Name;
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
                    String docContSub = resale.Booking__r.Unit__r.Name +' - '+resale.Booking__r.Cluster__c+' - CRM Controller NOC Email for Resale# '+resale.Name;
                    String docContBody = docusignDocumentControllerEmailBody(resale.Name);
                    dfsle.Recipient.EmailSettings docContEmailSetting = new dfsle.Recipient.EmailSettings('en','English',docContSub,docContBody);
                    dfsle.SignHereTab.Stamp docControllerStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                    dfsle.Tab docControllerStampTab = new dfsle.SignHereTab().withStamp(docControllerStamp)
                                                                            .withScale(1.0) // 1.5 scale
                                                                            .withRequired(true) // Signing mandatory
                                                                            .withAnchor(new dfsle.Tab.Anchor(
                                                                                'crmstamp', // Anchor string
                                                                                false, // Do not allow white space in anchor string
                                                                                false, // Anchor string is not case sensitive
                                                                                'right', // Horizontal alignment in relation to the anchor text
                                                                                true, // Ignore if the anchor text is not present in the document
                                                                                true, // Must match the value of the anchor string in its entirety
                                                                                'pixels', // Unit of the x and y offset properties
                                                                                10, // X offset
                                                                                0)); // Y offset
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
              
            }
                String envelopeId = String.valueOf(myEnvelope.docuSignId);
                docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap);
            
                Docusign_Result__e event = new Docusign_Result__e();
                event.MessageToDisplay__c = 'Resale NOC document successfully sent for Docusign.';
                event.Booking_Id__c = mySourceId;
                event.User_Id__c = UserInfo.getUserId();
                EventBus.publish(event);
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

        
    	public static String docusignAuthEmailBody(String resale){	
            return 
                'Dear Authorized Signatory \n\n'+
            	'Please find the attached Resale NOC. The same has been reviewd by audit and ready for sign off.\n'+
                'Resale Reference Number  '+resale+'\n'+
            	'\n'+
            	'\n'+
            	'Best Regards,\n\n'+
                'CRM Team \n'+
                'Sobha Realty</p>\n';      
    	}

        public static String docusignAuditEmailBody(String resale){	
            return 
                'Dear Audit Signatory \n\n'+
            	'Please find the attached Resale NOC. Please review the same and approved.\n'+
                'Resale Reference Number  '+resale+'\n'+
            	'\n'+
            	'\n'+
            	'Best Regards,\n\n'+
                'CRM Team \n'+
                'Sobha Realty</p>\n';      
    	}
    
    public static String docusignDocumentControllerEmailBody(String resale)
    	{	
            return 
                'Dear CRM Document Controller \n\n'+
            	'Please find the attached Resale NOC. Please review the same and sign off.\n'+
                'Resale Reference Number  '+resale+'\n'+
            	'\n'+
            	'\n'+
            	'Best Regards,\n\n'+
                'CRM Team \n'+
                'Sobha Realty</p>\n';      
    	}
    public static void docusignPostProcessing(String envelopeId, Id resaleId, Id myDocumentId, Map<String,String> emailToRoleMap) 
    {
        //sleep(50); // Donot push this method production, required only in sandbox
        List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c, Resale_Process__c From dfsle__EnvelopeStatus__c Where dfsle__DocuSignId__c=:envelopeId];

        if (docusignStatusList.size() > 0) 
        {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'Resale NOC';
            ds.Resale_Process__c  = resaleId;
            update ds; 

            List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
            List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__RoutingOrder__c,Booking__c,dfsle__Email__c,Envelope_Type__c, Envelope_Recipient_Type__c, Resale_Process__c From dfsle__RecipientStatus__c Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) 
            {
                String drsKey=rs.dfsle__Email__c+'_'+rs.dfsle__RoutingOrder__c;
                if (emailToRoleMap.containsKey(drsKey)) {
                    rs.Resale_Process__c = resaleId;
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(drsKey);
                    rs.Envelope_Type__c = 'Resale NOC';
                    rsToUpdateList.add(rs);
                }
            }                                                        
            update rsToUpdateList;
            system.debug(rsToUpdateList);

        }
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
    } */

}