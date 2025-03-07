public with sharing class SPADocusignSellerSignature {
    
        @InvocableMethod
        public static void sendEnvelopeMethod(List<Id> bookingIds){
            Id mySourceId = bookingIds[0];
            forForSigningFuture(mySourceId);
        }
    
        @future(callout=true)
        public static void forForSigningFuture(Id mySourceId) {
            //Pass the booking record id
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
                    new dfsle.Entity(mySourceId)
                );
    
            List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:mySourceId 
                                                    and ContentDocument.title like '%SPA%' Order by ContentDocument.createdDate desc];        
            Id myDocumentId = docList[0].ContentDocumentId; // The ID of a document stored in a Salesforce library
    
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
    
            Booking__c booking = [Select id,
                                        Sales_Manager__c,
                                        Sales_Managers__r.name, 
                                        Sales_Managers__r.email, 
                                        Sales_Head__c, 
                                        Sales_Head__r.name,
                                        Sales_Head__r.email ,
                                        CRM_Seller_representative__r.Name,
                                        CRM_Seller_representative__r.Email,
                                        Unit__r.Name
                                    From Booking__c 
                                    where id=:mySourceId limit 1];
            
            List<Applicant_Details__c> sortedApplicants = new List<Applicant_Details__c>();
            List<Applicant_Details__c> applicants = [Select id,name, Email_Address__c, Applicant_Number__c,Mobile_Number__c  
                                                    From Applicant_Details__c
                                                Where Booking__c =:mySourceId ORDER BY Applicant_Signing_Order__c ASC];
    
            Integer applicantsSize = applicants.size();
            Decimal scaleValue = 1.0;
            Integer yOffset = 10;
        
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
            // Create an Initial Here tab
        
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();

            //Set the authentication
            //dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );

            // Create a Sign Here tab
            dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
            .withScale(scaleValue)
            .withRequired(true)
            .withAnchor(new dfsle.Tab.Anchor(
                'sellersigsobha', // Anchor string
                false, // Do not allow white space in anchor string
                false, // Anchor string is not case sensitive
                'left', // Horizontal alignment in relation to the anchor text
                true, // Ignore if the anchor text is not present in the document
                true, // Must match the value of the anchor string in its entirety
                'pixels', // Unit of the x and y offset properties
                0, // X offset
                yOffset)); // Y offset 

            dfsle.SignHereTab.Stamp myStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
            dfsle.Tab myStampTab = new dfsle.SignHereTab().withStamp(myStamp)
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
                0)); // Y offset


                dfsle.Tab myDateSignedTab = new dfsle.DateSignedTab()
                .withAnchor(new dfsle.Tab.Anchor(
                    'sellerdate', // Anchor string
                    false, // Do not allow white space in anchor string
                    false, // Anchor string is not case sensitive
                    'right', // Horizontal alignment in relation to the anchor text
                    true, // Ignore if the anchor text is not present in the document
                    true, // Must match the value of the anchor string in its entirety
                    'pixels', // Unit of the x and y offset properties
                    20, // X offset
                    0)); // Y offset

            // Create a Date Signed tab
            /*dfsle.Tab myDateSignedTab = new dfsle.DateTab()
                .withFormatting(new dfsle.Tab.Formatting(
                    'Helvetica', // Font
                    'default', // Font color
                    14, // 14pt size,
                    true, // Bold
                    false, // Italicc
                    false, // Underline
                    false, // Conceal value
                    false)) // Fixed width
                .withAnchor(new dfsle.Tab.Anchor(
                    'sellerdate', // Anchor string
                    false, // Do not allow white space in anchor string
                    false, // Anchor string is not case sensitive
                    'right', // Horizontal alignment in relation to the anchor text
                    true, // Ignore if the anchor text is not present in the document
                    true, // Must match the value of the anchor string in its entirety
                    'pixels', // Unit of the x and y offset properties
                    10, // X offset
                    0)); // Y offset*/
                

            dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                booking.CRM_Seller_representative__r.Name,
                booking.CRM_Seller_representative__r.Email,
                null, 
                null,
                null)
                .withTabs(new List<dfsle.Tab> {
                    mySignHereTab,myStampTab,myDateSignedTab
                    });
                    //.withAuthentication(auth);
            recipientList.add(myRecipient);
    
                
        
            //Add the signers...
            myEnvelope = myEnvelope.withRecipients(recipientList);
            String sub = booking.Unit__r.Name +' - Crest Grande - Sales and Purchase Agreement (SPA) for Digital Signoff';
            //String body = '<h4>Please Sign the booking form</h4>';
            String body = docusignEmailBody();
            myEnvelope = myEnvelope.withEmail(sub,body);
            // Send the envelope!
            if(!Test.isRunningTest()) {
                myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                    myEnvelope,
                    true
                );
                
                String envelopeId = String.valueOf(myEnvelope.docuSignId);
                Booking__c b = new Booking__c(id=mySourceId, SPA_Docusign_Seller_Envelope_Id__c=envelopeId);
                update b;
            }
    
            /*List<ContentDocument> ConDocList =[SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument where Id =:myDocumentId];
            delete ConDocList; */
        }
    
        public static String docusignEmailBody() {
            return 
            'Dear Seller Representative \n\n'+
            'Please find attached the Sale and Purchase Agreement (“SPA”) signed off by the customer. Please review the same and sign off.\n'+
            '\n'+
            '\n'+
            'Thank you, \n'+
            'Sobha LLC,</p>\n';
        }
    }