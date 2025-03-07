public with sharing class sendMandateDocuSignHandler 
{
		@InvocableMethod
        public static void sendEnvelopeMethod(List<Id> brokerIds)
        {
            Id mySourceId = brokerIds[0];
            Map<String,String> emailToRoleMap = new Map<String,String>();
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
            
            List<ContentDocumentLink> docList = [SELECT Id, ContentDocumentId,
                                                        ContentDocument.title,
                                                        LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:mySourceId 
                                                    and ContentDocument.title like '%Mandate%' 
                                                Order by ContentDocument.createdDate desc];
            Id myDocumentId = docList[0].ContentDocumentId; // The ID of a document stored in a Salesforce library
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id; 
            //Get Channel Partner Record
            Channel_Partner__c channelPartner =[Select Id, Name, Seller_Representative__c, Seller_Representative__r.Name, Seller_Representative__r.Email  From Channel_Partner__c where Id=:mySourceId];
            
            Decimal scaleValue=1.0;
            Integer yOffset = 10;
            
             // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
            
            //EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='DocuSignMandateLetter'];
            
            //DocuSign Begins
            String sub = 'DocuSign - Mandate Letter - '+channelPartner.Name+'';
            //added by mohit as part of sob -776
            system.debug('subjectlenght' + sub.length());
            if(sub.length() > 100){
                //sub = sub.replace(('DocuSign - Mandate Letter - {!Channel_Partner__c.Name}'), 'Mandate Letter – SOBHA Realty');
                sub = 'Mandate Letter – SOBHA Realty';
            }else{
               // sub = sub.replace(('DocuSign - Mandate Letter - {!Channel_Partner__c.Name}'),'Mandate Letter – SOBHA Realty - ' + channelPartner.Name);
                sub = 'Mandate Letter – SOBHA Realty - ' + channelPartner.Name;
            }
            String body = 'Dear Anuj \n\n'+
                			'This is in reference to the mandate letter document for the registered channel partner '+channelPartner.Name+'. \n\n'+
                            'Request you to please approve the Mandate Letter.'+
                            '\n'+
                            '\n'+
                            'Thanks, \n'+
                            'Sobha Realty</p>\n'; 
            
            dfsle.Recipient.EmailSettings sellerEmailSetting = new dfsle.Recipient.EmailSettings('en', 'English', sub, body);
            
           	dfsle.Tab sellerSignTab = new dfsle.SignHereTab()
                                                .withScale(scaleValue) // 1.5 scale
                                                .withRequired(true) // Signing mandatory
                                                .withAnchor(new dfsle.Tab.Anchor(
                                                                        'sellerrepresentativesign', // Anchor string
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
                                                                    'sellerrepresentativestamp', // Anchor string
                                                                    false, // Do not allow white space in anchor string
                                                                    false, // Anchor string is not case sensitive
                                                                    'right', // Horizontal alignment in relation to the anchor text
                                                                    true, // Ignore if the anchor text is not present in the document
                                                                    true, // Must match the value of the anchor string in its entirety
                                                                    'pixels', // Unit of the x and y offset properties
                                                                    10, // X offset
                                                                    0)
                                                            ); // Y offset
            emailToRoleMap.put(channelPartner.Seller_Representative__r.Email,'Seller Representative');
            dfsle.Recipient sellerRecipient = dfsle.Recipient.fromSource(
                                                            channelPartner.Seller_Representative__r.Name,
                                                            channelPartner.Seller_Representative__r.Email,
                                                            null, 
                                                            null,
                                                            null)
                                                        .withTabs(new List<dfsle.Tab> {
                                                                sellerSignTab,sellerStampTab
                                                            })
                                                        .withEmailSettings(sellerEmailSetting);
            recipientList.add(sellerRecipient);
            
            //Add the signers...
            myEnvelope = myEnvelope.withRecipients(recipientList);
            
            //Send the Envelope
            if(!Test.isRunningTest()) 
            	{
                myEnvelope = dfsle.EnvelopeService.sendEnvelope(myEnvelope,true);
        		}
			String envelopeId = String.valueOf(myEnvelope.docuSignId);
            docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap);
	}
    	Private Static void docusignPostProcessing(String envelopeId,Id bId, Id myDocumentId, Map<String,String> emailToRoleMap) 
        {
            List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c 
                                                                 From dfsle__EnvelopeStatus__c Where dfsle__DocuSignId__c=:envelopeId];
            if (docusignStatusList.size() > 0) {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'Mandate Letter';
            ds.Channel_Partner__c = bId;
            update ds;
            }
            List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
            List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__Email__c,Envelope_Recipient_Type__c From 
                                            dfsle__RecipientStatus__c Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];
			
            
                
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) 
            {
                if (emailToRoleMap.containsKey(rs.dfsle__Email__c)) 
                	{
                        rs.Envelope_Recipient_Type__c = emailToRoleMap.get(rs.dfsle__Email__c);
                        rs.Envelope_Type__c = 'Mandate Letter';
                        rsToUpdateList.add(rs);
                	}
            }                                                        
            			update rsToUpdateList; 
        }
}