public with sharing class SPADocusignController {

    //@InvocableMethod
    /*public static String validateSPAForSigning(List<Id> bookingIds) {

        try {
            String validationMessage = 'success';
            //Id bookingIdValue = (Id)bookingId;
            //Get the content document links
            List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId IN:bookingIdValue 
                                                    and ContentDocument.title = 'SPA.pdf'];

            if (docList.size() == 0) {
                return 'SPA document is not attached to the Booking Files (Also make sure the file name is SPA.pdf)';
            } else if (docList.size() > 1) {
                return 'More than 1 SPA document is attached to the Booking Files. Please make sure only one SPA file is attached.';
            }
            
            //Get SPA content document
            return validationMessage;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }*/

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
                                        Sales_Head__r.email,
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
                scaleValue = 1.0;
                yOffset = 10;
            //}
        
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
            // Create an Initial Here tab
            
        
        
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
            Integer i = 1;
            for (Applicant_Details__c applicant:applicants) {
    
                //SMS authentication phone numbers
                List<String> smsPhoneNumbers = new List<String>();
                smsPhoneNumbers.add(applicant.Mobile_Number__c);
    
                //Set the authentication
                dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );

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
                    null)
                    .withTabs(new List<dfsle.Tab> {
                      myInitialHereTab,mySignHereTab
                      })
                      .withAuthentication(auth);
                recipientList.add(myRecipient);
    
                i = i+1;
            }
        
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
                Booking__c b = new Booking__c(id=mySourceId, SPA_Docusign_Envelope_Id__c=envelopeId);
                update b;
            }
            /*List<ContentDocument> ConDocList =[SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument where Id =:myDocumentId];
            delete ConDocList; */
        }
    
        public static String docusignEmailBody() {
            return 
            'Dear Customer \n\n'+
            'Greetings from Sobha Realty! \n\n'+
            'We trust this communication finds you well and thank you for booking your unit in project, “Crest Grande”. \n \n'+
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
}