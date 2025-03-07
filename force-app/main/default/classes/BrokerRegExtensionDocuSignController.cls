public class BrokerRegExtensionDocuSignController {
    
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
        
        Map<String,String> emailToRoleMap = new Map<String,String>();
        List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
        
        dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
        
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId =:mySourceId 
                                             and ContentDocument.title like '%Extension%'
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
                                               Broker_Category__c, recordtype.Name,
                                               Account_Email__c
                                               from Broker_Registration__c where Id=:mySourceId];
        
        //Nov 2024
        
        String vpsub = 'Signature Request - Extension Letter';
        
        
        system.debug('>>>>vpsub>>'+vpsub);
        
        String VPbody = getEmailBody('Francis');
        system.debug('>>>>VPbody>>'+VPbody);
        
        Integer i=1;
        Decimal scaleValue;
        Integer yOffset = 0;
        scaleValue = 1.0;
        yOffset = 10;
        
        dfsle.Recipient.EmailSettings chrmopsEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                              'English',
                                                                                              vpsub,
                                                                                              VPbody);
       
        
        dfsle.Tab vpSignTab = new dfsle.SignHereTab()
            .withScale(scaleValue) // 1.5 scale
            .withRequired(true) // Signing mandatory
            .withAnchor(new dfsle.Tab.Anchor(
                'vpSignTab', // Anchor string
                false, // Do not allow white space in anchor string
                false, // Anchor string is not case sensitive
                'left', // Horizontal alignment in relation to the anchor text
                true, // Ignore if the anchor text is not present in the document
                true, // Must match the value of the anchor string in its entirety
                'pixels', // Unit of the x and y offset properties
                0, // X offset
                yOffset)); // Y offset 
        
        String VpEmail = 'tejaswini.dharanikota@ceptes.onmicrosoft.com';//[SELECT ID,email FROM Group WHERE DeveloperName ='Sobha_Connect_Queue'].email  ;                                             
        emailToRoleMap.put(VpEmail+i,'Authorized Signatory'); // add email here from Queue- Ayushi
        i=i+1;
        dfsle.Recipient AuthorizedSignatory = dfsle.Recipient.fromSource(
            'Authorized Signatory',
            VpEmail,
            null,
            null,
            null)
            .withTabs(new List<dfsle.Tab> {
                vpSignTab
                    })
            .withEmailSettings(chrmopsEmailSetting);
        
        recipientList.add(AuthorizedSignatory);

        
        
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
        }
        String envelopeId = String.valueOf(myEnvelope.docuSignId);
        try {
            docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap);
        } catch (Exception e) {
            Broker_Registration__c brg = new Broker_Registration__c();
            brg.Id = mySourceId;
            brg.Docusign_Exception_Message__c = 'Extension Exception: '+e.getMessage()+'--'+e.getStackTraceString();
            update brg;
            system.debug('Exception---'+e.getMessage());
            system.debug('Exception---'+e.getStackTraceString());
        }
        
    }
    
    public static String getEmailBody(String Name) {
        return
            'Dear Mr.Francis,\n\nThis is to inform you that the Extension Notice has been generated.\n\n'+
            'Request you to review and Sign the Document. Once Signed, Document is further sent to broker.\n\n'+
            'Thanks\nSobha Realty\n';
    }
    
    Private Static void docusignPostProcessing(String envelopeId,Id bId, Id myDocumentId, Map<String,String> emailToRoleMap) 
    {
        List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c 
                                                             From dfsle__EnvelopeStatus__c Where dfsle__DocuSignId__c=:envelopeId];
        if (docusignStatusList.size() > 0) {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'Broker Registration - Extension';
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
                    rs.Envelope_Type__c = 'Broker Registration - Extension';
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

}