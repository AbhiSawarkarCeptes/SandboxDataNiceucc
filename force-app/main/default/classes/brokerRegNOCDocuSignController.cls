public with sharing class brokerRegNOCDocuSignController {
        @InvocableMethod
            public static void sendEnvelopeMethod(List<Id> brokerRegIds){
                Id mySourceId = brokerRegIds[0];
                forForSigningFuture(mySourceId);
            }
        
            @future(callout=true)
            public static void forForSigningFuture(Id mySourceId) {
                //Pass the broker reg  record id
                try {
                    system.debug('~~~Inside Future');
                Map<String,String> emailToRoleMap = new Map<String,String>();
                List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
    
                dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
                                                                                new dfsle.Entity(mySourceId)
                                                                            );
        		//Get Broker Registration Record
                Broker_Registration__c brokerRegRec = [Select Id, name, frmBrokerRegistrationName__c,First_Name__c, Is_UAE_Category__c,
                                                         Last_Name__c, email__c, CHRM_Manager__c, Owner.Name, recordtype.Name,
                                                         CHRM_Manager__r.email , Broker_Category__c, createdDate, Email_Category_Email_Address__c, Email_Category__c
                                                         from Broker_Registration__c where Id=:mySourceId];
                String agreementName = 'Agreement - '+brokerRegRec.Broker_Category__c+'.pdf'; 
                String nocName = 'NOC - '+brokerRegRec.Broker_Category__c+'.pdf';
                List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId =:mySourceId 
                                                    and  ContentDocument.title =:nocName
                                                    Order by ContentDocument.createdDate desc];
                if(docList.size() == 0){
                    return;
                }
                Id myDocumentId = docList[0].ContentDocumentId; // The ID of a document stored in a Salesforce library
        
                Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
                
                List<ContentDocumentLink> agreementList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId =:mySourceId 
                and  ContentDocument.title =:agreementName
                Order by ContentDocument.createdDate desc];
                if(agreementList.size() == 0){
                    return;
                }
                Id myDocumentId1 = agreementList[0].ContentDocumentId; // The ID of a document stored in a Salesforce library

                Id myFileId1 = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId1 LIMIT 1].id;

                
                
                Integer i=1;
                Decimal scaleValue;
                Integer yOffset = 0;
                scaleValue = 1.0;
                yOffset = 10;
                //String vpsub = 'Signature Request - Registration of ' + brokerRegRec.First_Name__c + ' ' + brokerRegRec.Last_Name__c;
                String vpsub = 'Signature Request - Registration of ' + brokerRegRec.frmBrokerRegistrationName__c;
                if(brokerRegRec.recordtype.Name=='Renewal'){
                    vpsub = 'Signature Request - Renewal Registration of ' + brokerRegRec.frmBrokerRegistrationName__c;
                }
                if(vpsub.length() > 100){
                    vpsub = 'Signature Request - Registration - Sobha Realty';
                    if(brokerRegRec.recordtype.Name=='Renewal'){
                        vpsub = 'Signature Request - Renewal Registration - Sobha Realty';
                    }
                }
                String vpbody = docusignbrokerEmailBody(brokerRegRec); //Ayushi will update method for email body
    
                dfsle.Recipient.EmailSettings vpEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        vpsub,
                                                                                                        vpbody);
    
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
                                                                            yOffset)
                                                                ); // Y offset 

                dfsle.SignHereTab.Stamp vpStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                dfsle.Tab vpStampTab = new dfsle.SignHereTab().withStamp(vpStamp)
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
                                                                        10, // X offset
                                                                        0)
                                                                ); // Y offset
    
                String emailValue;
                String categoryValue;
                /*if (brokerRegRec.Email_Category__c) {
                    emailValue = brokerRegRec.Email_Category_Email_Address__c;
                    emailToRoleMap.put(brokerRegRec.Email_Category_Email_Address__c,'Broker Registration - Email Category SignOff');
                    categoryValue = 'Broker Registration - Email Category SignOff'; */
                if(brokerRegRec.Is_UAE_Category__c){
                    emailValue = system.label.UAE_Category_Email;
                    String emailName =  system.label.UAE_Category_Name;
                    /*if(brokerRegRec.recordtype.Name=='Renewal'){
                        emailToRoleMap.put(emailValue,'Broker Renewal Registration - Email Category SignOff');
                        //categoryValue = 'Broker Renewal Registration - Email Category SignOff';
                    } else { */
                        emailToRoleMap.put(emailValue,'Broker Registration - Email Category SignOff');
                        categoryValue = emailName;
                    system.debug('~~~Catg:'+categoryValue);
                    //}
                } else {
                    emailValue = System.label.VP_Email;
                    /*if(brokerRegRec.recordtype.Name=='Renewal'){
                        emailToRoleMap.put(System.label.VP_Email,'Broker Registration - Ashish Parakh SignOff');
                        //categoryValue = 'Broker Renewal Registration - Ashish Parakh SignOff';
                    } else {*/
                        emailToRoleMap.put(System.label.VP_Email,'Broker Registration - Ashish Parakh SignOff');
                        categoryValue = 'Broker Registration - Ashish Parakh SignOff';
                    //}
                }
                
                i=i+1;
                dfsle.Recipient vpRecipient = dfsle.Recipient.fromSource(
                                                                categoryValue,
                                                                emailValue,
                                                                null, 
                                                                null,
                                                                null)
                                                            .withTabs(new List<dfsle.Tab> {
                                                                vpSignTab,vpStampTab
                                                                })
                                                            .withEmailSettings(vpEmailSetting);
                recipientList.add(vpRecipient);
    
                // Add document to the envelope
                myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId,myFileId1 }));
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
                    docusignPostProcessing(envelopeId, mySourceId, myDocumentId, emailToRoleMap);
                
                    /*Docusign_Result__e event = new Docusign_Result__e();
                    event.MessageToDisplay__c = 'Broker Registration-NOC Docusign Form sent successfully for Docusign.';
                    event.Broker_Registration_Id__c = mySourceId;
                    event.User_Id__c = UserInfo.getUserId();
                    EventBus.publish(event);*/
                    
                } catch (Exception e) {
                    Broker_Registration__c brg = new Broker_Registration__c();
                    brg.Id = mySourceId;
                    brg.Docusign_Exception_Message__c = 'NOC Exception: '+e.getMessage()+'--'+e.getStackTraceString();
                    update brg;
                    system.debug('Exception---'+e.getMessage());
                    system.debug('Exception---'+e.getStackTraceString());
                    /*Docusign_Result__e event = new Docusign_Result__e();
                    event.MessageToDisplay__c = 'Error sending NOC for Docusign - '+e.getMessage();
                    event.Broker_Registration_Id__c = mySourceId;
                    event.User_Id__c = UserInfo.getUserId();
                    EventBus.publish(event);*/
                }
            }
        
    
            public static String docusignbrokerEmailBody(Broker_Registration__c brokerRegRec) {
                String recipientName;
                if(brokerRegRec.Is_UAE_Category__c){
                    recipientName = system.label.UAE_Category_Name;
                } else {
                    recipientName = system.label.VP_First_Name+' '+system.label.VP_Last_Name;
                }
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                String url = baseUrl + '/' + brokerRegRec.id;
                return 
                '<p> Dear '+recipientName+' ,</p> '+
                 '<p>'+
                 'Please be informed that the agreement and NOC for the registration of '+brokerRegRec.frmBrokerRegistrationName__c+' is ready for Signature. Please find the details below.'+
                '</p>   '+
                
          
            '<table border="1" >'+
                '<tr>'+
                    '<td>Broker Name</td>'+
                    '<td>'+brokerRegRec.frmBrokerRegistrationName__c+'</td> '+                 
                '</tr>'+
                 '<tr>'+
                    '<td>Broker Category</td>'+
                    '<td>'+brokerRegRec.Broker_Category__c+'</td>'+
                    
                '</tr>'+
                '<tr>'+
                    '<td>Created Date</td>'+
                   '<td>'+brokerRegRec.createdDate+'</td>'+
                    
                '</tr> '+
                    '<tr>'+
                    '<td>CHRM</td>'+
                   '<td>'+brokerRegRec.Owner.Name+'</td>'+
                '</tr>'+
                 '<tr>'+
                   '<td>Status</td>'+
                    '<td>Awaiting VP signature</td>'+                  
                '</tr>'+
                '<tr>'+
                    '<td>Audit History</td>'+
                    '<td>Request Approved by Audit</td>'+                   
                '</tr>'+
            '</table>'+
                '<p>'+
                    'Kindly find the docuSign links for your signature above(Click Review Document). </p>'+
                //'<p>'+
                //'<a href="'+ url+'">Click here</a> to approve/reject in salesforce  </p>'+
                ''+
              '<p>Thank you.</p>'+
            '<p>Best regards,</p>'+
            '<p>Salesforce</p>';
            }
    
          
        Private Static void docusignPostProcessing(String envelopeId,Id bId, Id myDocumentId, Map<String,String> emailToRoleMap) 
            {
                List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c 
                                                                        From dfsle__EnvelopeStatus__c 
                                                                        Where dfsle__DocuSignId__c=:envelopeId 
                                                                        order by createdDate asc];
                if (docusignStatusList.size() > 0) {
                    dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
                    ds.Envelope_Type__c = 'Broker Registration - NOC';
                    ds.Docusign_Broker_Registration__c = bId;
                    update ds;
                }
                List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
                List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__Email__c,dfsle__Sequence__c,Envelope_Recipient_Type__c 
                                                                                From dfsle__RecipientStatus__c 
                                                                                Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];
                
                
                    
                for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) 
                {
                    system.debug('rs.dfsle__Email__c---'+rs.dfsle__Email__c);
                    system.debug('emailToRoleMap---'+emailToRoleMap.keySet());
                    system.debug('emailToRoleMap---'+emailToRoleMap.containsKey(rs.dfsle__Email__c));
                    if (emailToRoleMap.containsKey(rs.dfsle__Email__c)) 
                        {
                            rs.Envelope_Recipient_Type__c = emailToRoleMap.get(rs.dfsle__Email__c);
                            rs.Envelope_Type__c = 'Broker Registration - NOC';
                            rs.Docusign_Broker_Registration__c = bId;
                            rsToUpdateList.add(rs);
                            system.debug('rs-----'+rs);
                        }
                }                                                        
                update rsToUpdateList; 
            }

            
    }