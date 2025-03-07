public with sharing class SPADocusignDocumentController {
    
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
                                        CRM_Document_Controller__r.Name,
                                        CRM_Document_Controller__r.Email,
                                        Unit__r.Name
                                    From Booking__c 
                                    where id=:mySourceId limit 1];
            
            List<Applicant_Details__c> sortedApplicants = new List<Applicant_Details__c>();
            List<Applicant_Details__c> applicants = [Select id,name, Email_Address__c, Applicant_Number__c,Mobile_Number__c  
                                                    From Applicant_Details__c
                                                Where Booking__c =:mySourceId ORDER BY Applicant_Signing_Order__c ASC];
    
            Integer applicantsSize = applicants.size();
            Decimal scaleValue;
            Integer yOffset = 0;
            /*if (applicantsSize > 3) {
                scaleValue = 0.5;
                yOffset = 10;
            } else {*/
                scaleValue = 0.5;
                yOffset = 10;
            //}
        
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
            // Create an Initial Here tab
        
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();

            dfsle.SignHereTab.Stamp myStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
            dfsle.Tab myStampTab = new dfsle.SignHereTab().withStamp(myStamp)
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

            dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                booking.CRM_Document_Controller__r.Name,
                booking.CRM_Document_Controller__r.Email,
                null, 
                null,
                null)
                .withTabs(new List<dfsle.Tab> {
                        myStampTab
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
                Booking__c b = new Booking__c(id=mySourceId, SPA_Docusign_Doc_ControllerEnvelopeId_c__c=envelopeId);
                update b;
            }
    
            /*List<ContentDocument> ConDocList =[SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument where Id =:myDocumentId];
            delete ConDocList; */
        }
    
        public static String docusignEmailBody() {
            return 
            'Dear Document Controller \n\n'+
            'Please find attached the Sale and Purchase Agreement (“SPA”) signed off by the customer. Please review the same and add stamp.\n'+
            '\n'+
            '\n'+
            'Thank you, \n'+
            'Sobha LLC,</p>\n';
        }
    }