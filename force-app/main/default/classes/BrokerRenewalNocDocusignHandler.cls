/*********************************************************************
 * Class Name  :   BrokerRenewalNocDocusignHandler
 * Description :   Class Used in BrokerRenewalTriggerHelper to send Broker Renewal Noc
 * Created Date:   23/05/2024
 * Authored By :   CloudSteer Technology Pvt Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Gourav Gour 23/05/2024
 *********************************************************************/
public with sharing class BrokerRenewalNocDocusignHandler {
    @future(callout=true)
    public static void forForSigningFuture(Id mySourceId) {
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            Map<String,String> emailToRoleMap = new Map<String,String>();
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();

            //Pass the booking record id
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
        
            Broker_Renewal__c renewRec = BrokerRenewalNOCDocusignUtil.getBrokerRenewal(mySourceId);
            
            Id myDocumentId = BrokerRenewalNOCDocusignUtil.getFileId(mySourceId);  // Noc document Doc Id
            if(myDocumentId == null){
                return;
            }
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;

            Id myDocumentId1 = BrokerRenewalNOCDocusignUtil.getFileId1(mySourceId); // The ID of a document stored in a Salesforce library get agreement doc Id
            if(myDocumentId1 == null){
                return;
            }
            Id myFileId1 = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId1 LIMIT 1].id;

            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId, myFileId1 }));
            
            Integer i=1;
            Decimal scaleValue;
            Integer yOffset;
            scaleValue = 1.0;
            yOffset = 5;

            String sub = 'Signature Request - Registration of '+ renewRec.Name_as_per_trade_license__c;
            String body = BrokerRenewalNOCDocusignUtil.docusignEmailBody(renewRec);

            dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        sub,
                                                                                                        body);
            String anchorString = 'vpSignTab';      
            List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>(); 
            
            String anchorInitialsString = 'sobhainitials';

            dfsle.Tab myInitialHereTab = new dfsle.InitialHereTab()
                                                        .withScale(0.5)
                                                        .withRequired(true) // Signing optional
                                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            anchorInitialsString, // Anchor string
                                                            false, // Do not allow white space in anchor string
                                                            false, // Anchor string is not case sensitive
                                                            'left', // Horizontal alignment in relation to the anchor text
                                                            true, // Ignore if the anchor text is not present in the document
                                                            true, // Must match the value of the anchor string in its entirety
                                                            'pixels', // Unit of the x and y offset properties
                                                            0, // X offset
                                                            22)); // Y offset

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

                applicantsTabs.add(mySignHereTab);    
                applicantsTabs.add(myInitialHereTab);    
                
            dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
            dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                                        .withScale(1.0) // 1.5 scale
                                        .withRequired(true) // Signing mandatory
                                        .withAnchor(new dfsle.Tab.Anchor(
                                                            'vpstamptab', // Anchor string
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

            String emailValue;
            String categoryValue;
            if(renewRec.Al_Siniya_Partner__c) {
                emailValue = system.label.Siniya_Island_Final_Signatory;
                String emailName =  system.label.Siniya_Island_Final_Signatory_Name;
                emailToRoleMap.put(emailValue,'Broker Registration - '+emailName+' SignOff');
                categoryValue = 'Broker Registration - '+emailName+' SignOff' ;
            } else if(renewRec.Broker_Category_Type_Doc__c.contains('UAE')){
                emailValue = system.label.UAE_Category_Email;
                String emailName =  system.label.UAE_Category_Name;
                emailToRoleMap.put(emailValue,'Broker Registration - '+emailName+' SignOff');
                categoryValue = 'Broker Registration - '+emailName+' SignOff' ;
            } else {
                emailValue = System.label.VP_Email;
                emailToRoleMap.put(System.label.VP_Email,'Broker Registration - Ashish Parakh SignOff');
                categoryValue = 'Broker Registration - Ashish Parakh SignOff';
            }

            dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                                                                        categoryValue,
                                                                        emailValue,
                                                                        null, 
                                                                        null,
                                                                        null)
                                                                    .withTabs(applicantsTabs)
                                                                    .withEmailSettings(applicantEmailSetting);
                recipientList.add(myRecipient);

            i = i+1;

           
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
                BrokerRenewalNOCDocusignUtil.docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap);
            }
        } 
        catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e(); event.MessageToDisplay__c = 'Error sending NOC Form for Docusign - '+e.getMessage();
            event.Booking_Id__c = mySourceId;event.User_Id__c = UserInfo.getUserId();EventBus.publish(event);
        }
    }
}