public class brokerRegAgrDocuSignControler {
    @InvocableMethod
    public static void sendEnvelopeMethod(List<Id> brokerRegIds){
        System.debug('innvocable method');
        Id mySourceId = brokerRegIds[0];
        System.debug(mySourceId);
        forForSigningFuture(mySourceId);
    }
    
    @future(callout=true) 
    public static void forForSigningFuture(Id mySourceId) {
        //Pass the broker reg  record id
        // try {
        System.debug('future call');
        Map<String,String> emailToRoleMap = new Map<String,String>();
        List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
        
        dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
        
        /* Attachment att = [SELECT Id, Name, Body, ContentType,LastModifiedDate,BodyLength FROM Attachment WHERE parentId =: mySourceId
and name like '%agreement%' order by createdDate desc];
dfsle.Document myDocument = new dfsle.Document(att.Id, 'File', 1, att.Name, 'pdf', att.BodyLength, att.LastModifiedDate, myS);
*/
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId =:mySourceId 
                                             and ContentDocument.title like '%agreement%'
                                             Order by ContentDocument.createdDate desc];
        if(docList.size() == 0){
            return;
        }
        Id myDocumentId = docList[0].ContentDocumentId; // The ID of a document stored in a Salesforce library
        
        Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
        
        
        //Get Broker Registration Record
        Broker_Registration__c brokerRegRec = [Select Id,Owner.Name,Owner.Email,
                                               list_of_missing_documents__c, Missing_Documents__c,
                                               name, frmBrokerRegistrationName__c,
                                               First_Name__c,
                                               Last_Name__c, 
                                               email__c,
                                               Alternate_Email__c,
                                               CHRM_Manager__c, 
                                               CHRM_Manager__r.name,
                                               CHRM_Manager__r.email,
                                               Witness_Name__c,
                                               Witness_Email_1__c,
                                               Broker_Category__c, recordtype.Name
                                               from Broker_Registration__c where Id=:mySourceId];
        
        //CHRM_Ops Team - part 1
        String chrmopsSub = 'Broker Registration Agreement Approval - '+brokerRegRec.frmBrokerRegistrationName__c ;
        if(brokerRegRec.recordtype.Name=='Renewal'){
            chrmopsSub = 'Renewal Broker Registration Agreement Approval - '+brokerRegRec.frmBrokerRegistrationName__c ;
        }
        system.debug('>>>>chrmopsSub>>'+chrmopsSub.length());
        if(chrmopsSub.length() > 100){
            chrmopsSub = 'Broker Registration Agreement Approval - Sobha Realty';
            if(brokerRegRec.recordtype.Name=='Renewal'){
                chrmopsSub = 'Renewal Broker Registration Agreement Approval - Sobha Realty';
            }
        }
        
        String chrmopsBody = getCHRMOpsBody(brokerRegRec.frmBrokerRegistrationName__c);
        Integer i=1;
        Decimal scaleValue;
        Integer yOffset = 0;
        scaleValue = 1.0;
        yOffset = 10;
        
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
                'right', // Horizontal alignment in relation to the anchor text
                true, // Ignore if the anchor text is not present in the document
                true, // Must match the value of the anchor string in its entirety
                'pixels', // Unit of the x and y offset properties
                0, // X offset
                5)); // Y offset
        dfsle.Tab chrmopsTeamDeclineTab = new dfsle.DeclineTab()
            .withAnchor(new dfsle.Tab.Anchor(
                chrmopsTeamDeclineAnchor, // Anchor string
                false, // Do not allow white space in anchor string
                false, // Anchor string is not case sensitive
                'right', // Horizontal alignment in relation to the anchor text
                true, // Ignore if the anchor text is not present in the document
                true, // Must match the value of the anchor string in its entirety
                'pixels', // Unit of the x and y offset properties
                0, // X offset
                5)); // Y offset
        String chrmOpsEmail = [SELECT ID,email FROM Group WHERE DeveloperName ='Sobha_Connect_Queue'].email  ;                                             
        emailToRoleMap.put(chrmOpsEmail+i,'chrmops Team'); // add email here from Queue- Ayushi
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
        
        String broksub = 'Sobha Realty Registration - '+brokerRegRec.frmBrokerRegistrationName__c; //Ayushi will update
        if(brokerRegRec.recordtype.Name=='Renewal'){
            broksub = 'Sobha Realty Renewal Registration - '+brokerRegRec.frmBrokerRegistrationName__c;
        }
        if(broksub.length() > 100){
            broksub = 'Sobha Realty Registration';
            if(brokerRegRec.recordtype.Name=='Renewal'){
                broksub = 'Sobha Realty Renewal Registration';
            }
        }
        String brbody = docusignbrokerEmailBody(brokerRegRec); //Ayushi will update method for email body
        
        dfsle.Recipient.EmailSettings brokerEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                             'English',
                                                                                             broksub,
                                                                                             brbody);
        dfsle.Tab brokerInitialsTab = new dfsle.InitialHereTab()
            .withScale(0.5)
            .withRequired(true) // Signing optional
            .withAnchor(new dfsle.Tab.Anchor(
                'brokerinitialsds', // Anchor string
                false, // Do not allow white space in anchor string
                false, // Anchor string is not case sensitive
                'right', // Horizontal alignment in relation to the anchor text
                true, // Ignore if the anchor text is not present in the document
                true, // Must match the value of the anchor string in its entirety
                'pixels', // Unit of the x and y offset properties
                0, // X offset
                0)); // Y offset
        
        dfsle.Tab brokerSignTab = new dfsle.SignHereTab()
            .withScale(scaleValue) // 1.5 scale
            .withRequired(true) // Signing mandatory
            .withAnchor(new dfsle.Tab.Anchor(
                'brokersignsobha', // Anchor string
                false, // Do not allow white space in anchor string
                false, // Anchor string is not case sensitive
                'left', // Horizontal alignment in relation to the anchor text
                true, // Ignore if the anchor text is not present in the document
                true, // Must match the value of the anchor string in its entirety
                'pixels', // Unit of the x and y offset properties
                0, // X offset
                yOffset)
                       ); // Y offset 
        
        emailToRoleMap.put(brokerRegRec.Email__c+i,'broker');
        i=i+1;
        if (brokerRegRec.Broker_Category__c.containsIgnoreCase('Individual')) {
            dfsle.Recipient brokerRecipient = dfsle.Recipient.fromSource(
                'broker',
                brokerRegRec.Email__c,
                null, 
                null,
                null)
                .withTabs(new List<dfsle.Tab> {
                    brokerSignTab,brokerInitialsTab
                        })
                .withEmailSettings(brokerEmailSetting);
            recipientList.add(brokerRecipient);
        } else {
            dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
            dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                .withScale(1.0) // 1.5 scale
                .withRequired(true) // Signing mandatory
                .withAnchor(new dfsle.Tab.Anchor(
                    'brokerStamp', // Anchor string
                    false, // Do not allow white space in anchor string
                    false, // Anchor string is not case sensitive
                    'right', // Horizontal alignment in relation to the anchor text
                    true, // Ignore if the anchor text is not present in the document
                    true, // Must match the value of the anchor string in its entirety
                    'pixels', // Unit of the x and y offset properties
                    0, // X offset
                    0)
                           ); // Y offset
            
            dfsle.Recipient brokerRecipient = dfsle.Recipient.fromSource(
                'broker',
                brokerRegRec.Email__c,
                null, 
                null,
                null)
                .withTabs(new List<dfsle.Tab> {
                    brokerSignTab,brokerInitialsTab,corpAppStampTab
                        })
                .withEmailSettings(brokerEmailSetting);
            recipientList.add(brokerRecipient);
        }
        
        
        //Witness - part 3
        if (brokerRegRec.Witness_Email_1__c != null) {
            dfsle.Recipient.EmailSettings witnessEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                  'English',
                                                                                                  broksub,
                                                                                                  brbody);
            
            dfsle.Tab witnessSignTab = new dfsle.SignHereTab()
                .withScale(scaleValue) // 1.5 scale
                .withRequired(true) // Signing mandatory
                .withAnchor(new dfsle.Tab.Anchor(
                    'Brokerregwitness1', // Anchor string
                    false, // Do not allow white space in anchor string
                    false, // Anchor string is not case sensitive
                    'left', // Horizontal alignment in relation to the anchor text
                    true, // Ignore if the anchor text is not present in the document
                    true, // Must match the value of the anchor string in its entirety
                    'pixels', // Unit of the x and y offset properties
                    0, // X offset
                    yOffset)
                           ); // Y offset
            
            emailToRoleMap.put(brokerRegRec.Witness_Email_1__c+i,'Broker Registration Witness');
            i=i+1;
            dfsle.Recipient witnessRecipient = dfsle.Recipient.fromSource(
                'witness',
                brokerRegRec.Witness_Email_1__c,
                null, 
                null,
                null)
                .withTabs(new List<dfsle.Tab> {
                    witnessSignTab
                        })
                .withEmailSettings(witnessEmailSetting);
            recipientList.add(witnessRecipient);
        }
        //part 3 ends
        
        // Add document to the envelope
        myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
        // Create an Initial Here tab
        
        Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
        Integer expiryDays = Integer.valueOf(docusignDefaultSettings.SPA_Expiry_Days__c); // ayushi needs to update here, create one more field for broker Reg
        //(date + exipiry days) - today;
        
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
            .withRecipients(recipientList);
        //.withNotifications(expirySettings );
        
        //Send the Envelope
        if(!Test.isRunningTest()) {
            myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                myEnvelope,
                true
            );
            String envelopeId = String.valueOf(myEnvelope.docuSignId);
            /*Booking__c b = new Booking__c(id=mySourceId, SPA_Docusign_Envelope_Id__c=envelopeId);
update b;*/
        }
        String envelopeId = String.valueOf(myEnvelope.docuSignId);
        try {
            docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap);
        } catch (Exception e) {
            Broker_Registration__c brg = new Broker_Registration__c();
            brg.Id = mySourceId;
            brg.Docusign_Exception_Message__c = 'Agreement Exception: '+e.getMessage()+'--'+e.getStackTraceString();
            update brg;
            system.debug('Exception---'+e.getMessage());
            system.debug('Exception---'+e.getStackTraceString());
        }
        
        /* Docusign_Result__e event = new Docusign_Result__e();
event.MessageToDisplay__c = 'SPA sent successfully for Docusign.';
event.Booking_Id__c = mySourceId;
event.User_Id__c = UserInfo.getUserId();
EventBus.publish(event);*/
        //} 
        /*catch (Exception e) {
Docusign_Result__e event = new Docusign_Result__e();
event.MessageToDisplay__c = 'Error sending SPA for Docusign - '+e.getMessage();
event.Booking_Id__c = mySourceId;
event.User_Id__c = UserInfo.getUserId();
EventBus.publish(event);
}*/
        try {
            sendCollateralMail(brokerRegRec);
            sendOwnerMail(brokerRegRec);
                }
        catch(Exception ex) {
            Error_Log__c trackErrorRec = new Error_Log__c(Class__c = 'brokerRegAgrDocusignController--sendCollateralMail',Message__c = ex.getmessage());
            System.debug('ex.getMessage()::::'+ex.getMessage());
            System.debug('trackErrorRec::::'+ex.getStackTraceString());
            database.insert(trackErrorRec, false);
        }
        
    }
    
    
    public static String docusignbrokerEmailBody(Broker_Registration__c brokerRegRec) {
        String missingdocument;
        if(brokerRegRec.list_of_missing_documents__c=='' || brokerRegRec.list_of_missing_documents__c==null){
            //if(brokerRegRec.Missing_Documents__c=='' || brokerRegRec.Missing_Documents__c==null){
            missingdocument='None';
        }else{
            missingdocument=brokerRegRec.list_of_missing_documents__c;
            //missingdocument=brokerRegRec.Missing_Documents__c;
        }
        return 
            'Dear '+brokerRegRec.frmBrokerRegistrationName__c+ '\n\n'+
            'I hope this email finds you well.\n'+
            'The registration agreement is ready for your signature.\n'+
            'Please find the link below to digitally sign the agreement using DocuSign:\n\n'+ 
            'Additionally, kindly provide the following documents which are awaited:\n'+
            missingdocument+'\n\n'+
            'Please do not hesitate to contact me regarding any questions or issues that you encounter. We are here to assist you.\n'+
            '<b>Please send the list of missing documents (if any) to '+brokerRegRec.Owner.email+'</b>\n\n'+
            'Thank you for your cooperation. \n'+
            'Best regards,\n'+
            brokerRegRec.Owner.name;
        
    }
    
    
    public static String getCHRMOpsBody(String Name) {
        return
            'Dear CHRM Ops Team,\n\nThis is to inform you that the Agreement signed with Broker Registration-'+Name+' has been generated. \n\n'+
            'Request you to review and approve the Agreement .Once appproved, Agreement is further sent to broker for sign.\n\nThanks\nSobha Realty\n';
    }
    Private Static void docusignPostProcessing(String envelopeId,Id bId, Id myDocumentId, Map<String,String> emailToRoleMap) 
    {
        List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c 
                                                             From dfsle__EnvelopeStatus__c Where dfsle__DocuSignId__c=:envelopeId];
        if (docusignStatusList.size() > 0) {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'Broker Registration - Agreement';
            ds.Docusign_Broker_Registration__c = bId;
            update ds;
        }
        List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
        List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__Email__c,dfsle__Sequence__c,Envelope_Recipient_Type__c From 
                                                                       dfsle__RecipientStatus__c Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];
        
        
        if(docusignReceipentStatusList.size()>0)  {  
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) 
            {
                system.debug('rs.dfsle__Email__c---'+rs.dfsle__Email__c);
                system.debug('emailToRoleMap---'+emailToRoleMap.keySet());
                system.debug('emailToRoleMap---'+emailToRoleMap.containsKey(rs.dfsle__Email__c));
                if (emailToRoleMap.containsKey(rs.dfsle__Email__c+rs.dfsle__Sequence__c)) 
                {
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(rs.dfsle__Email__c+rs.dfsle__Sequence__c);
                    rs.Envelope_Type__c = 'Broker Registration - Agreement';
                    rs.Docusign_Broker_Registration__c = bId;
                    rsToUpdateList.add(rs);
                    system.debug('rs-----'+rs);
                }
            }    
        }
        if(rsToUpdateList.size()>0){
            update rsToUpdateList;
        }
        
    }
    
      public static void sendCollateralMail(Broker_Registration__c brokerRegRec){
        Set<String> brokerCategorySet = new Set<String>{'Broker - RERA','Broker - Intnl','Broker - UAE'};
            if(brokerCategorySet.contains(brokerRegRec.Broker_Category__c)){
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: System.Label.BR_no_reply_email];
                List<String> CcAddresses = new List<String>{System.Label.SF_Notifications};
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setUseSignature(false);
                email.setSaveAsActivity(true);
                email.setSubject('Sobha Realty- Commission Slab');
                email.setOrgWideEmailAddressId(owea.get(0).Id);
 
                String[] toAddresses = new String[] {brokerRegRec.email__c};
                    if(brokerRegRec.Alternate_Email__c != null) {
                        toAddresses.add(brokerRegRec.Alternate_Email__c);
                    }
                    email.setToAddresses(toAddresses);
                    email.setCcAddresses(CcAddresses);
                System.debug('CcAddresses'+CcAddresses);
                String emailBody = '<html><body>';
                emailBody += 'Dear Channel Partner,<br/><br/>';
                emailBody += 'Greetings from Sobha Realty!<br/><br/>';
                emailBody += 'Please refer to the attached collateral for commission slab.<br/><br/>';
                emailBody += 'Happy Selling!<br/><br/>';
                emailBody += 'Best Regards,<br/>';
                emailBody += '<b>Channel Operations</b></body></html>';
                email.setHtmlBody(emailBody);
                StaticResource sr = [Select  Name, Id, Body From StaticResource where Name = 'CRFCommissionCollateralAttachment'];
                Blob tempBlob = sr.Body;
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setBody(tempBlob);
                efa.setFileName('Commission Slab.png');
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {email};
                    Messaging.sendEmail(emailList);  
            }
        
        
    }
    
    
   public static void sendOwnerMail(Broker_Registration__c brokerRegRec) {
    Set<String> brokerCategorySet = new Set<String>{'Broker - RERA','Broker - Intnl','Broker - UAE', 'Sobha Connect - UAE - Company', 'Sobha Connect - Intnl - Company'};
    if (brokerCategorySet.contains(brokerRegRec.Broker_Category__c)) {
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: System.Label.BR_no_reply_email];
        List<String> toAddresses = new List<String>();
        List<String> CcAddresses = new List<String>{System.Label.SF_Notifications};
        
        // Add the alternate email only if it is not null
        if (brokerRegRec.Alternate_Email__c != null) {
            toAddresses.add(brokerRegRec.Alternate_Email__c);
        }

        // Proceed only if there are addresses to add
        if (!toAddresses.isEmpty()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setUseSignature(false);
            email.setSaveAsActivity(true);
            email.setSubject('Agreement created & Sent for Signature');
            email.setOrgWideEmailAddressId(owea.get(0).Id);
            email.setToAddresses(toAddresses);
            email.setCcAddresses(CcAddresses);
            System.debug('CcAddresses'+CcAddresses);

            String emailBody = '<html><body>';
            emailBody += 'Dear Channel Partner,<br/><br/>';
            emailBody += 'Greetings from Sobha Realty!<br/><br/>';
            emailBody += 'This is to inform you that Broker Agreement has been sent to the registered email address ' + brokerRegRec.email__c + ' for your signature.<br/><br/>';
            emailBody += 'Kindly sign the agreement using the link.<br/><br/>';
            emailBody += 'In case you need any assistance, please contact your respective Channel Manager.<br/><br/>';
            emailBody += 'Best Regards,<br/>';
            emailBody += '<b>Channel Operations</b></body></html>';
            email.setHtmlBody(emailBody);

            Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {email};
            Messaging.sendEmail(emailList);  
        } else {
            System.debug('No valid alternate email address found for broker registration record.');
        }
    }
}

}