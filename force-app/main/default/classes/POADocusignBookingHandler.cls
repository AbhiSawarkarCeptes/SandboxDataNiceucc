public class POADocusignBookingHandler {

    @InvocableMethod
        public static void sendEnvelopeMethod(List<Id> bookingIds){
            Id mySourceId = bookingIds[0];
            forForSigningFuture(mySourceId);
        }
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
        try {
            Map<String,String> emailToRoleMap = new Map<String,String>();

            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
    
            List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:mySourceId 
                                                AND ContentDocument.title like '%Handover%' 
                                                ORDER BY ContentDocument.createdDate DESC LIMIT 1];

            if(docList.size() > 0){

                Id myDocumentId = docList[0].ContentDocumentId; 
                Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
                Booking__c booking = SPADocusignBookingFormUtil.getBooking(mySourceId);
                List<Applicant_Details__c> applicantList = [SELECT id,name, Email_Address__c, Applicant_Number__c,Mobile_Number__c,POA_Name__c,POA_Email_Id__c,POA_Contact_Number__c  
                                                            FROM Applicant_Details__c
                                                            WHERE Booking__c =:mySourceId];
                if(applicantList.size() > 0){
                    Decimal scaleValue;
                    Integer yOffset = 0;
                    scaleValue = 1.0;
                    yOffset = 10;
                    myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
                    List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
                    List<String> smsPhoneNumbers = new List<String>();
                    Integer i = 1;

                    for (Applicant_Details__c applicants : applicantList) {
                        emailToRoleMap.put(applicants.Email_Address__c,'Applicant');
                        String applPhoneNumber = SPADocusignAddendumUtil.validateAndUpdatePhoneNumber(applicants.Mobile_Number__c);
                        smsPhoneNumbers.add(applPhoneNumber);
                        dfsle.Recipient.Authentication auth = new dfsle.Recipient.Authentication('', false, smsPhoneNumbers );
                        String sub = booking.Cluster__c+' - '+booking.Unit__r.Name+' - Handover documents';
                        String body = 'Dear '+applicants.name+'\n\n'+
                            'Greetings! \n\n'+
                            'Please find the attached Handover documents to be signed. \n\n'+
                            'Should you require any further details, please feel free to contact us. \n\n'+
                            'Regards,\n'+
                            'CRM Team,\n'+
                            'SOBHA Realty\n';
                        
                        dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en','English', sub,body);
                        
                        dfsle.Tab mySignHereTab = new dfsle.SignHereTab().withScale(scaleValue) // 1.5 scale
                            .withRequired(true) // Signing mandatory
                            .withAnchor(new dfsle.Tab.Anchor(
                                applicants.Id, // Anchor string
                                false, // Do not allow white space in anchor string
                                false, // Anchor string is not case sensitive
                                'right', // Horizontal alignment in relation to the anchor text
                                true, // Ignore if the anchor text is not present in the document
                                true, // Must match the value of the anchor string in its entirety
                                'pixels', // Unit of the x and y offset properties
                                0, // X offset
                                yOffset)); // Y offset 
                        
                        dfsle.Recipient myRecipient;
                        myRecipient = dfsle.Recipient.fromSource(
                            applicants.name,
                            applicants.Email_Address__c,
                            null, 
                            applicants.Applicant_Number__c,
                            null
                        ).withTabs(new List<dfsle.Tab> {
                            mySignHereTab
                                }).withAuthentication(auth).withEmailSettings(applicantEmailSetting);
                        recipientList.add(myRecipient);
                        i++;
                    }
                    myEnvelope = myEnvelope.withRecipients(recipientList);
                    String envelopeId = null;
                    //Send the Envelope
                    if(!Test.isRunningTest()) {
                        myEnvelope = dfsle.EnvelopeService.sendEnvelope(myEnvelope,true);
                        envelopeId = String.valueOf(myEnvelope.docuSignId);
                    }

                    envelopeId = String.valueOf(myEnvelope.docuSignId);
                    POADocusignBookingHandler.docusignPostProcessing(envelopeId, mySourceId, emailToRoleMap);
                    
                    Docusign_Result__e event = new Docusign_Result__e();
                    event.MessageToDisplay__c = 'Handover Document sent successfully sent for Docusign.';
                    event.Booking_Id__c = mySourceId;
                    event.User_Id__c = UserInfo.getUserId();
                    EventBus.publish(event);

                }else{

                    Docusign_Result__e event = new Docusign_Result__e();
                    event.MessageToDisplay__c = 'Error sending Handover Document for Docusign - No Applicant Found To Sent Document For SIgnature';
                    event.Booking_Id__c = mySourceId;
                    event.User_Id__c = UserInfo.getUserId();
                    EventBus.publish(event);
                }
            }else{
                Docusign_Result__e event = new Docusign_Result__e();
                event.MessageToDisplay__c = 'Error sending Handover Document for Docusign - Please Upload the Handover Document First Then Sent';
                event.Booking_Id__c = mySourceId;
                event.User_Id__c = UserInfo.getUserId();
                EventBus.publish(event);
            }

        } catch (Exception e) {

            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Error sending Handover Document for Docusign - '+e.getMessage();
            event.Booking_Id__c = mySourceId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }

    public static void docusignPostProcessing(String envelopeId, Id bookingId,Map<String,String> emailToRoleMap) {
        try {
            dfsle__EnvelopeStatus__c docusignStatus = [SELECT Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c FROM dfsle__EnvelopeStatus__c WHERE dfsle__DocuSignId__c=:envelopeId LIMIT 1];
            docusignStatus.Envelope_Type__c = 'Handover';
            docusignStatus.Booking__c = bookingId;
            update docusignStatus; 

            List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
            List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [SELECT id,dfsle__Email__c,dfsle__Sequence__c,Envelope_Recipient_Type__c FROM  dfsle__RecipientStatus__c WHERE dfsle__EnvelopeStatus__c=:docusignStatus.id];
                
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) {
                if (emailToRoleMap.containsKey(rs.dfsle__Email__c+rs.dfsle__Sequence__c)) {
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(rs.dfsle__Email__c+rs.dfsle__Sequence__c);
                    rs.Envelope_Type__c = 'Handover';
                    rsToUpdateList.add(rs);
                }
            }                                                        
            update rsToUpdateList; 
        } catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Document Sent Successfully Post Update in Salesforce not done - '+e.getMessage();
            event.Booking_Id__c = bookingId;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }
    
}