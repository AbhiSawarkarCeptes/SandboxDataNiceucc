/*********************************************************************
* Class Name  :   BrokerLedgerTriggerController
* Description :   Controller class of BrokerLedgerTrigger
* Created Date:   27/11/2023
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 27/11/2023
*********************************************************************/
public class BrokerLedgerTriggerController {
    Public static boolean flag = true;
    //Added by Deepak sharma on 27'Nov to maintain rollup summary on Broker Payment Milestone
    public static void maintainRollUpOnBrokerPaymentMS(List<PropStrength__Broker_Ledger__c> blList, Map<Id, PropStrength__Broker_Ledger__c> blMap, String check) {
        Set<Id> bpmId = new Set<Id>();
        Id brokeragePaidId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        
        if(check == 'Update') {
            for(PropStrength__Broker_Ledger__c bl : blList) {
                if(bl.RecordTypeId == brokeragePaidId) {
                    if(bl.PropStrength__Broker_Payment_Milestone__c != null) {
                        bpmId.add(bl.PropStrength__Broker_Payment_Milestone__c);
                    }
                    if(bl.PropStrength__Broker_Payment_Milestone__c != blMap.get(bl.Id).PropStrength__Broker_Payment_Milestone__c) {
                        bpmId.add(blMap.get(bl.Id).PropStrength__Broker_Payment_Milestone__c);
                    }
                }
            }
        } else {
            for(PropStrength__Broker_Ledger__c bl : blList) {
                if(bl.RecordTypeId == brokeragePaidId) {
                    if(bl.PropStrength__Broker_Payment_Milestone__c != null) {
                        bpmId.add(bl.PropStrength__Broker_Payment_Milestone__c);
                    }
                }
            }
        }
        
        if(!bpmId.isEmpty()) {
            List<PropStrength__Broker_Payment_Milestone__c> bpmRecs = [SELECT Id, (SELECT Id, PropStrength__Paid_Amount__c,PropStrength__Check_No__c,PropStrength__Cheque_No__c FROM PropStrength__Broker_Ledgers__r) FROM PropStrength__Broker_Payment_Milestone__c WHERE Id IN :bpmId];
            List<PropStrength__Broker_Payment_Milestone__c> updateBpmRecs = new List<PropStrength__Broker_Payment_Milestone__c>();
            
            for(PropStrength__Broker_Payment_Milestone__c bpm : bpmRecs) {
                if(!bpm.PropStrength__Broker_Ledgers__r.isEmpty()) {
                    Decimal total = 0;
                    Set<String> setOfCheckNo = new Set<String>();
                    for(PropStrength__Broker_Ledger__c bl : bpm.PropStrength__Broker_Ledgers__r) {
                        if(bl.PropStrength__Paid_Amount__c != null) {
                            total += bl.PropStrength__Paid_Amount__c;
                        }
                        if(bl.PropStrength__Cheque_No__c != null) {
                            System.debug('*--test--'+bl.PropStrength__Cheque_No__c);
                            setOfCheckNo.add(bl.PropStrength__Cheque_No__c);
                        }
                    }
                    System.debug(total+'*--total--'+setOfCheckNo);
                    updateBpmRecs.add(new PropStrength__Broker_Payment_Milestone__c(Id=bpm.Id, PropStrength__Brokerage_Paid__c = total, PropStrength__Check_No__c = string.valueof(setOfCheckNo).replace('{','').replace('}','')));
                }
            }
            
            if(!updateBpmRecs.isEmpty()) {
                update updateBpmRecs;
            }
        }
    }
    
    //Added by Nishank manwani on 10/05/2024 to call approval process on insert
    public static void callApprovalProcessOnInsert(List<PropStrength__Broker_Ledger__c> brokLedList) {
        Id brokDueRecType = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();
        
        for(PropStrength__Broker_Ledger__c bLed : brokLedList) {
            if(bLed.RecordTypeId == brokDueRecType ) {  
                BrokerLedgerTriggerController.callApprovalProcess1(bLed.Id);
            }
        }
    }
    
    //Added by Nishank manwani on 10/05/2024 to call approval process on update
    public static void callApprovalProcessOnUpdate(List<PropStrength__Broker_Ledger__c> brokLedList, Map<Id, PropStrength__Broker_Ledger__c> oldBrokLedMap) {
        Id brokDueRecType = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();
        
        for(PropStrength__Broker_Ledger__c bLed : brokLedList) {
            if(bLed.RecordTypeId == brokDueRecType) {
                if(bLed.PropStrength__Approval_Status__c != oldBrokLedMap.get(bLed.Id).PropStrength__Approval_Status__c) {
                    if(bLed.PropStrength__Approval_Status__c == 'Rejected by Audit') {
                        BrokerLedgerTriggerController.callApprovalProcess1(bLed.Id);
                    } else if(bLed.PropStrength__Approval_Status__c == 'Rejected by CHRM Ops' && !System.isBatch() && !System.isFuture() && !System.isqueueable()) {
                        BrokerLedgerTriggerController.callApprovalProcess2(bLed.Id);
                    } else if(bLed.PropStrength__Approval_Status__c == 'Rejected by Accounts' && !System.isBatch() && !System.isFuture() && !System.isqueueable()) {
                        BrokerLedgerTriggerController.callApprovalProcess3(bLed.Id);
                    }
                }
            }
        }
    }   
    
    public static void callApprovalProcess1(Id bLedId) {
        String approvalProcessName = 'Brokerage_Due_Approval_Process';
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval');
        req1.setObjectId(bLedId);
        req1.setSubmitterId(UserInfo.getUserId()); 
        req1.skipentrycriteria = true;
        req1.setProcessDefinitionNameOrId(approvalProcessName);
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    @Future(Callout=true)
    public static void callApprovalProcess2(Id bLedId) {
        String approvalProcessName = 'Brokerage_Due_Approval_Process2';
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval');
        req1.setObjectId(bLedId);
        req1.setSubmitterId(UserInfo.getUserId()); 
        req1.skipentrycriteria = true;
        req1.setProcessDefinitionNameOrId(approvalProcessName);
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    @Future(Callout=true)
    public static void callApprovalProcess3(Id bLedId) {
        String approvalProcessName = 'Brokerage_Due_Approval_Process3';
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval');
        req1.setObjectId(bLedId);
        req1.setSubmitterId(UserInfo.getUserId()); 
        req1.skipentrycriteria = true;
        req1.setProcessDefinitionNameOrId(approvalProcessName);
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    public static void updateVat(List<PropStrength__Broker_Ledger__c> brokLedList, Map<Id, PropStrength__Broker_Ledger__c> oldBrokLedMap){
        Id bpmLedgerDueId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();
        for(PropStrength__Broker_Ledger__c ledger : brokLedList){
            if(ledger.recordTypeId == bpmLedgerDueId && ledger.PropStrength__Service_Tax__c != null && ledger.PropStrength__Service_Tax__c > 0 && ledger.PropStrength__Brokerage_Due_Rs__c != null && ledger.PropStrength__Brokerage_Due_Rs__c != oldBrokLedMap.get(ledger.id).PropStrength__Brokerage_Due_Rs__c ){
                ledger.PropStrength__Service_Tax__c = 0.05*ledger.PropStrength__Brokerage_Due_Rs__c;
            }
        }
        
    }
    
    public static void sendEmailOnHold(List<PropStrength__Broker_Ledger__c> ledgers,map<Id,PropStrength__Broker_Ledger__c> oldMap){
        Set<Id> ledgerIds = new Set<Id>();
        
        for(PropStrength__Broker_Ledger__c ledger : ledgers){
            if(ledger.Hold_BrokerLedger__c != oldMap.get(ledger.id).Hold_BrokerLedger__c && ledger.Hold_BrokerLedger__c){
                ledgerIds.add(ledger.id);
            }
        }
        
        if(!ledgerIds.isEmpty()){
            BrokerLedgerTriggerController.sendMailToQueue(ledgerIds);
        }        
    }
    
    @future
    public static void sendMailToQueue(Set<Id> ledgerIds){
        List<PropStrength__Broker_Ledger__c> ledgerList  = [select PropStrength__Broker_Account__c,Unit_No__c,PropStrength__Total_Brokerage_Due__c,CreatedById,Hold_Reason__c,Hold_by_Demartment__c from  PropStrength__Broker_Ledger__c where id in : ledgerIds];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        List<String> sendTo = new List<String>(); 
        for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Commission_Hold_Release_Account')]) {
            if(u.Email != null) {
                sendTo.add(u.Email);
            }
        }
        
        
        
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
        
        contact con = [SELECT id from contact limit 1];
        if(!ledgerList.isEmpty()){
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Channel_Partner_Email_Template_Html'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            for(PropStrength__Broker_Ledger__c ledger : ledgerList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setWhatId(ledger.Id);
                email.setTargetObjectId(con.Id);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    }
    
    public static void sendForDocusign(List<PropStrength__Broker_Ledger__c> ledgers,map<Id,PropStrength__Broker_Ledger__c> oldMap){ 
        List<PropStrength__Broker_Ledger__c> updateledgers = new List<PropStrength__Broker_Ledger__c>();
        for(PropStrength__Broker_Ledger__c ledger : ledgers){
            if(ledger.PropStrength__Approval_Status__c=='Approved by Audit' && ledger.PropStrength__Approval_Status__c != oldMap.get(ledger.id).PropStrength__Approval_Status__c){
                System.enqueueJob(new DocuSignBrokerLedgerQueueable(ledger.id));       
            }                
        }   
    }
    
    @future(callout=true)
    public static void sendLetterForDocusign(Id ledgerIds, Id myDocumentId){
        try {
            Docusign_Settings__mdt  docusignDefaultSettings = Docusign_Settings__mdt.getInstance('Org_Defaults');
            Map<String,String> emailToRoleMap = new Map<String,String>();
            if(myDocumentId == null){
                return;
            }
            Id myFileId = [SELECT id from ContentVersion where ContentDocumentId =:myDocumentId LIMIT 1].id;
            
            PropStrength__Broker_Ledger__c ledger = BrokerLedgerDocusignUtilClone.getLedger(ledgerIds);
            
            Integer i=1;           
            Decimal scaleValue;
            Integer yOffset = 0;            
            scaleValue = 1.0;
            yOffset = -3;
            
            //Pass the booking record id
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(ledgerIds));
            
            // Add document to the envelope
            myEnvelope = myEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId }));
            
            
            
            List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>();
            
            System.debug('test*----1234');
            if(ledger.PropStrength__Broker_Account__c != null && ledger.PropStrength__Broker_Account__r.Email_ID_1__c != null ) {
                emailToRoleMap.put(ledger.PropStrength__Broker_Account__r.Email_ID_1__c +'_'+i,'POA');
                
                /*  String sub = 'Action Required: Please Sign Invoice via DocuSign';
String body = 'Dear '+ ledger.PropStrength__Broker_Account__r.Name +','+'\n\n'
+'We have attached the invoice for the recent transaction via DocuSign for your signature. Kindly sign the document to allow us to proceed with the payment. '+ '\n\n' 
+ 'If you have any questions, feel free to contact us. '+'\n\n'
+ 'Thank you for your prompt attention.'+ '\n\n'
+ 'Best regards, '+'\n\n'
+'Sobha Realty';*/
                
                String sub = ' Invoice Request for Commission Disbursal – '+ ledger.PropStrength__Broker_Account__r.Name +' - '+ledger.Unit_No__c  + ' - '+ system.today().format();
                String body = 'Dear '+ ledger.PropStrength__Broker_Account__r.Name +','+'\n\n'
                    +'We hope this email finds you well. Please be informed that you are eligible for commission release for Unit '+ 
                    ledger.Unit_No__c + ' currently eligible for '+ ledger.Brokerage_Due_Percentage__c +' percentage.\n\n'
                    +'Kindly fill out the Invoice using the link above.'+'\n\n'
                    
                    + 'We would appreciate your prompt response in submitting the Invoice for timely disbursal of your commission.'+'\n\n'
                    +'Should you have any questions or require further clarification, please do not hesitate to contact your respective Channel Manager '
                    +ledger.Channel_Relationship_Manager__c+ '\n\n'
                    + 'Best regards, '+'\n\n'
                    +'Sobha Realty';
                
                
                
                
                
                
                dfsle.Recipient.EmailSettings applicantEmailSetting = new dfsle.Recipient.EmailSettings('en',
                                                                                                        'English',
                                                                                                        sub,
                                                                                                        body);
                
                String anchorString = 'signhere' ;
                
                List<dfsle.Tab> applicantsTabs = new List<dfsle.Tab>();
                
                // Create a Sign Here tab for applicant
                dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
                    .withScale(1.5) // 1.5 scale
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
                
                // applicantsTabs.add(myInitialHereTab);
                applicantsTabs.add(mySignHereTab);
                
                dfsle.SignHereTab.Stamp corpAppStamp = new dfsle.SignHereTab.Stamp('stamp',null,null,null,null,null,null,null);      
                dfsle.Tab corpAppStampTab = new dfsle.SignHereTab().withStamp(corpAppStamp)
                    .withScale(0.6) // 1.5 scale
                    .withRequired(true) // Signing mandatory
                    .withAnchor(new dfsle.Tab.Anchor(
                        'stamphere', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'right', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset)
                               ); // Y offset
                applicantsTabs.add(corpAppStampTab);

                dfsle.Tab.MergeField myMergeField = new dfsle.Tab.MergeField ( 'PropStrength__Broker_Ledger__c.PropStrength__Broker_Account__r.TRN_Number__c',null,null,true,false);
                
                // dfsle.TextTab textAccount = new dfsle.TextTab('stamp',null,null,null,null,null,null,null); 
                dfsle.Tab textAccount0 = new dfsle.TextTab() 
                    //  .withScale(1.5) // 1.5 scale
                    .withMergeField(myMergeField) 
                    .withRequired(true) // Signing mandatory
                    .withAnchor(new dfsle.Tab.Anchor(
                        'trnnum', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset))
                    .withDataLabel('TRN Number');// 
                applicantsTabs.add(textAccount0); 
                
                dfsle.Tab.MergeField myMergeField2 = new dfsle.Tab.MergeField ( 'PropStrength__Broker_Ledger__c.PropStrength__Broker_Account__r.Bank_Account_Name__c',null,null,true,false);

                dfsle.Tab textAccount = new dfsle.TextTab() 
                    .withRequired(true) // Signing mandatory
                    .withMergeField(myMergeField2) 
                    .withAnchor(new dfsle.Tab.Anchor(
                        'AccountName', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset))
                    .withDataLabel('Account Name Label'); // 
                applicantsTabs.add(textAccount);
                
                dfsle.Tab.MergeField myMergeField3 = new dfsle.Tab.MergeField ( 'PropStrength__Broker_Ledger__c.PropStrength__Broker_Account__r.Bank_Name__c',null,null,true,false);

                dfsle.Tab textAccount2 = new dfsle.TextTab() 
                    //  .withScale(1.5) // 1.5 scale
                    .withRequired(true) // Signing mandatory
                    .withMergeField(myMergeField3) 
                    .withAnchor(new dfsle.Tab.Anchor(
                        'BankName', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset))
                    .withDataLabel('Bank Name Label');// 
                applicantsTabs.add(textAccount2);
                
                dfsle.Tab.MergeField myMergeField4 = new dfsle.Tab.MergeField ( 'PropStrength__Broker_Ledger__c.PropStrength__Broker_Account__r.Bank_Account_Number__c',null,null,true,false);

                dfsle.Tab textAccount3 = new dfsle.TextTab() 
                    //  .withScale(1.5) // 1.5 scale
                    .withRequired(true) // Signing mandatory
                    .withMergeField(myMergeField4) 
                    .withAnchor(new dfsle.Tab.Anchor(
                        'AccountNumber', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset))
                    .withDataLabel('Account Number Label');// 
                applicantsTabs.add(textAccount3);

                dfsle.Tab.MergeField myMergeField5 = new dfsle.Tab.MergeField ( 'PropStrength__Broker_Ledger__c.PropStrength__Broker_Account__r.IBAN_Number__c',null,null,true,false);

                dfsle.Tab textAccount4 = new dfsle.TextTab() 
                    //  .withScale(1.5) // 1.5 scale
                    .withRequired(true) // Signing mandatory
                    .withMergeField(myMergeField5) 
                    .withAnchor(new dfsle.Tab.Anchor(
                        'IBANNumber', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset))
                    .withDataLabel('IBAN Number Label');// 
                applicantsTabs.add(textAccount4);
                
                dfsle.Tab.MergeField myMergeField6 = new dfsle.Tab.MergeField ( 'PropStrength__Broker_Ledger__c.PropStrength__Broker_Account__r.Currency__c',null,null,true,false);

                dfsle.Tab textAccount5 = new dfsle.TextTab() 
                    //  .withScale(1.5) // 1.5 scale
                    .withRequired(true) // Signing mandatory
                    .withMergeField(myMergeField6) 
                    .withAnchor(new dfsle.Tab.Anchor(
                        'Currency1', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset))
                    .withDataLabel('Currency Label');// 
                applicantsTabs.add(textAccount5);
                
                dfsle.Tab.MergeField myMergeField7 = new dfsle.Tab.MergeField ( 'PropStrength__Broker_Ledger__c.PropStrength__Broker_Account__r.Bank_Branch__c',null,null,true,false);
                dfsle.Tab textAccount6 = new dfsle.TextTab() 
                    //  .withScale(1.5) // 1.5 scale
                    .withRequired(true) // Signing mandatory
                    .withMergeField(myMergeField7) 
                    .withAnchor(new dfsle.Tab.Anchor(
                        'Branch1', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset))
                    .withDataLabel('Branch Label');// 
                applicantsTabs.add(textAccount6);
                
                dfsle.Tab.MergeField myMergeField8 = new dfsle.Tab.MergeField ( 'PropStrength__Broker_Ledger__c.PropStrength__Broker_Account__r.Swift_Routing_Sort_Code__c',null,null,true,false);

                dfsle.Tab textAccount7 = new dfsle.TextTab() 
                    //  .withScale(1.5) // 1.5 scale
                    .withRequired(true) // Signing mandatory
                    .withMergeField(myMergeField8) 
                    .withAnchor(new dfsle.Tab.Anchor(
                        'swiftCode', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset))
                    .withDataLabel('Swift Code');// 
                applicantsTabs.add(textAccount7);

                dfsle.Tab textAccount8 = new dfsle.CheckBoxTab() 
                    .withRequired(true) // Signing mandatory
                    .withAnchor(new dfsle.Tab.Anchor(
                        'checkBox', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        5, // X offset
                        yOffset))
                    .withDataLabel('Confirmation Box');// 
                applicantsTabs.add(textAccount8);

                dfsle.Tab myAttachHereTab1 = new dfsle.SignerAttachmentTab()
                .withScale(1.5) // 1.5 scale
                .withRequired(true)
                .withAnchor(new dfsle.Tab.Anchor(
                        'attachHere1', // Anchor string
                        false, // Do not allow white space in anchor string
                        false, // Anchor string is not case sensitive
                        'left', // Horizontal alignment in relation to the anchor text
                        true, // Ignore if the anchor text is not present in the document
                        true, // Must match the value of the anchor string in its entirety
                        'pixels', // Unit of the x and y offset properties
                        0, // X offset
                        yOffset)); // Default height
                applicantsTabs.add(myAttachHereTab1);

                dfsle.Tab myAttachHereTab2 = new dfsle.SignerAttachmentTab()
                .withScale(1.5) // 1.5 scale
                .withRequired(true)
                .withAnchor(new dfsle.Tab.Anchor(
                'attachHere2', // Anchor string
                false, // Do not allow white space in anchor string
                false, // Anchor string is not case sensitive
                'left', // Horizontal alignment in relation to the anchor text
                true, // Ignore if the anchor text is not present in the document
                true, // Must match the value of the anchor string in its entirety
                'pixels', // Unit of the x and y offset properties
                0, // X offset
                yOffset)); // Default height
                applicantsTabs.add(myAttachHereTab2);

                
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                    ledger.id,
                    ledger.PropStrength__Broker_Account__r.Email_ID_1__c,
                    null, 
                    null,
                    null)
                    .withTabs(applicantsTabs)                                                                   
                    .withEmailSettings(applicantEmailSetting);
                
                recipientList.add(myRecipient);
                i = i+1;
            } 
            
            
            
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
            System.debug('test*----1234');
            //Add the signers...
            myEnvelope = myEnvelope
                .withRecipients(recipientList)
                .withNotifications(expirySettings );
            System.debug('test*----123');
            String envelopeId = '';
            if(!Test.isRunningTest()) {
                myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                    myEnvelope,
                    true
                );
                System.debug('test*----');
                envelopeId = String.valueOf(myEnvelope.docuSignId);
                
                
                // Send the envelope!
            }
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Ledger Form sent successfully sent for Docusign.';
            event.Booking_Id__c = ledgerIds;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);           
            BrokerLedgerDocusignUtilClone.docusignPostProcessing(envelopeId, ledgerIds, myDocumentId, emailToRoleMap);
        } 
        catch (Exception e) {
            Docusign_Result__e event = new Docusign_Result__e();
            event.MessageToDisplay__c = 'Error sending ledger Form for Docusign - '+e.getMessage();
            event.Booking_Id__c = ledgerIds;
            event.User_Id__c = UserInfo.getUserId();
            EventBus.publish(event);
        }
    }    
    
    public static void updatePercentValue(List<PropStrength__Broker_Ledger__c> blList, Map<Id, PropStrength__Broker_Ledger__c> blMap) {
        Set<String> setOfBPMIds = new Set<String>();
        for(PropStrength__Broker_Ledger__c BLRec : blList){
            if( blMap == null || ( blMap != null && BLRec.PropStrength__Brokerage_Due_Rs__c != null && 
                                  BLRec.PropStrength__Brokerage_Due_Rs__c != blMap.get(BLRec.Id).PropStrength__Brokerage_Due_Rs__c) ){
                                      if(BLRec.PropStrength__Broker_Payment_Milestone__c != null)
                                          setOfBPMIds.add(BLRec.Id);
                                  }
        }        
        System.debug('setOfBPMIds*---'+setOfBPMIds);
        if(setOfBPMIds.size() > 0){
            List<PropStrength__Broker_Ledger__c> ledgerList  = [Select PropStrength__Broker_Account__c,PropStrength__Brokerage_Due_Rs__c,Unit_No__c,PropStrength__Brokerage_Payable__c,PropStrength__Total_Brokerage_Due__c,CreatedById,Hold_Reason__c,Hold_by_Demartment__c, 
                                                                PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__c from  PropStrength__Broker_Ledger__c where Id in : blList];
            Set<String> setOfBookingIds = new Set<String>();
            List<PropStrength__Broker_Ledger__c> listOfLadgerRec = new List<PropStrength__Broker_Ledger__c>();
            for(PropStrength__Broker_Ledger__c BLRec : ledgerList){
                if(BLRec.PropStrength__Broker_Payment_Milestone__r != null && 
                   BLRec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__c != null){
                       setOfBookingIds.add(BLRec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__c);
                       listOfLadgerRec.add(BLRec);
                   }
            }
            System.debug('setOfBookingIds*--'+setOfBookingIds);
            List<PropStrength__Application_Booking__c> listOfbookingRec = [SELECT Id, PropStrength__Broker_Account__c, Booked_Date__c, PropStrength__Brokerage_Scheme__c,PropStrength__Property_Type__r.PropStrength__Property_Type__c,
                                                                           PropStrength__Revised_Total_Sales_Consideration__c,Total_Payment_Receive_Percent__c,PropStrength__Brokerage_BSP__c,PropStrength__Brokerage_On_Other_Charges__c,PropStrength__Super_Area__c,
                                                                           PropStrength__Brokerage_Scheme__r.name, PropStrength__Brokerage_Scheme__r.PropStrength__Start_Date__c,
                                                                           (SELECT Id,PropStrength__Amount__c from PropStrength__Other_Charges_Opted__r WHERE PropStrength__Other_Charges__r.PropStrength__Brokerage_Applicable__c = true),
                                                                           PropStrength__Brokerage_Scheme__r.PropStrength__End_Date__c,PropStrength__Brokerage_Scheme__r.Percentage_of_POP_Received_Date__c
                                                                           FROM PropStrength__Application_Booking__c WHERE PropStrength__Booking_Through__c = 'Broker' and PropStrength__Active__c = true and PropStrength__Broker_Account__c != null
                                                                           AND Cancellation_Requested__c = false AND Id IN : setOfBookingIds
                                                                          ];
            Map<String, Decimal> mapOfBookingAndBrokerValue = new Map<String, Decimal>();
            for(PropStrength__Application_Booking__c booking : listOfbookingRec){
                Decimal sumOfOtherChargeAmt = 0;
                for(PropStrength__Other_Charges_Opted__c optdRec : booking.PropStrength__Other_Charges_Opted__r){
                    sumOfOtherChargeAmt += optdRec.PropStrength__Amount__c != null ? optdRec.PropStrength__Amount__c : 0 ;
                }
                System.debug('--sumOfOtherChargeAmt--'+sumOfOtherChargeAmt);
                System.debug('--booking.PropStrength__Brokerage_BSP__c--'+booking.PropStrength__Brokerage_BSP__c);
                System.debug('--booking.PropStrength__Brokerage_On_Other_Charges__c--'+booking.PropStrength__Brokerage_On_Other_Charges__c);
                Decimal brokerageBsp = booking.PropStrength__Brokerage_BSP__c != null ? booking.PropStrength__Brokerage_BSP__c : 0;
                Decimal brokerageOtherCharges = booking.PropStrength__Brokerage_On_Other_Charges__c != null ? booking.PropStrength__Brokerage_On_Other_Charges__c : 0;
                System.debug('--brokerageBsp--'+brokerageBsp);
                System.debug('--brokerageOtherCharges--'+brokerageOtherCharges);
                /*Decimal calculatePerValue = (booking.PropStrength__Brokerage_BSP__c != null ? booking.PropStrength__Brokerage_BSP__c : 0 + 
                                             sumOfOtherChargeAmt + 
                                             booking.PropStrength__Brokerage_On_Other_Charges__c != null ? booking.PropStrength__Brokerage_On_Other_Charges__c : 0) ;
                System.debug('--calculatePerValue--'+calculatePerValue);*/
                Decimal superarea = booking.PropStrength__Super_Area__c != null ? booking.PropStrength__Super_Area__c : 0 ;
                Decimal calculatePerValue = brokerageBsp *superarea ;
                
                calculatePerValue += sumOfOtherChargeAmt;
                System.debug('--calculatePerValue--'+calculatePerValue);
                mapOfBookingAndBrokerValue.put(booking.Id, calculatePerValue);
            }
            for(PropStrength__Broker_Ledger__c BLRec : listOfLadgerRec){
                if(mapOfBookingAndBrokerValue.containskey(BLRec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__c)){
                    Decimal result = 0;
                    if(BLRec.PropStrength__Brokerage_Due_Rs__c != null)
                        result = (BLRec.PropStrength__Brokerage_Due_Rs__c  * 100 );
                    
                    Decimal result2 = 0;
                    if(BLRec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__c != null && mapOfBookingAndBrokerValue.containskey(BLRec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__c))
                        result2 = mapOfBookingAndBrokerValue.get(BLRec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__c) == 0 ? 1:mapOfBookingAndBrokerValue.get(BLRec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Booking_ID__c);
                    if(result2 != 0)
                        BLRec.Brokerage_Due_Percentage__c =  result / result2;
                    System.debug(result+'--calculatePerValue--'+BLRec.PropStrength__Brokerage_Payable__c+'*----'+(BLRec.PropStrength__Brokerage_Payable__c  * 100 ));
                }
            }
            if(listOfLadgerRec.size() > 0){
                update listOfLadgerRec;
                flag = false;
            }
        }
    }
    public static void sendEmailOnStatusChange(List<PropStrength__Broker_Ledger__c> blList, Map<Id, PropStrength__Broker_Ledger__c> blMap) {
        Set<String> setOfBLIds = new Set<String>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<PropStrength__Broker_Ledger__c> listOfBLRec = new List<PropStrength__Broker_Ledger__c>();
        for(PropStrength__Broker_Ledger__c brokeRec : blList){
            if(brokeRec.PropStrength__Approval_Status__c == 'Ready for collection' && brokeRec.PropStrength__Approval_Status__c != blMap.get(brokeRec.Id).PropStrength__Approval_Status__c){
                setOfBLIds.add(brokeRec.Id);
                listOfBLRec.add(brokeRec);
            }
        }
        List<String> sendTo = new List<String>(); 
        Contact con = [SElect id from contact limit 1];
        if(setOfBLIds.size() > 0){
            for(PropStrength__Broker_Ledger__c BLRec : [Select PropStrength__Broker_Account__r.Email_ID_1__c from  
                                                        PropStrength__Broker_Ledger__c where Id in : setOfBLIds]){
                                                            sendTo.add(BLRec.PropStrength__Broker_Account__r.Email_ID_1__c);                                                                
                                                        }   
        }
        // List<Ledger_Document_History__c> ListOfDocHisRec = [SELECT id, Broker_Ledger__c, (SELECT Id,name from attachments) from Ledger_Document_History__c WHERE Broker_Ledger__c IN : setOfBLIds AND Document_Type__c = 'Payment Copy'];
        List<Ledger_Document_History__c> ListOfDocHisRec = [SELECT id, Broker_Ledger__c, (SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLinks) from Ledger_Document_History__c WHERE Broker_Ledger__c IN : setOfBLIds AND Document_Type__c = 'Payment Copy'];
        
        Map<String, LIst<Attachment>> listOfAttchmentAndBl = new Map<String, LIst<Attachment>>();
        Set<Id> setOfAttchment = new Set<Id>();
        
        map<Id,list<Id>> parentIdAndContrentDocumnetLink = new map<Id,list<Id>>();
        Map<String, List<ContentDocumentLink> > listOfAttchmentAndBl1 = new Map<String, List<ContentDocumentLink>>();
        Map<String, List<ContentDocument>> listOfAttchmentAndBl2 = new Map<String, List<ContentDocument>>();
        Map<String, List<ContentVersion>> listOfAttchmentAndBl3 = new Map<String, List<ContentVersion>>();
          map<id, ContentVersion> CvWithCd = new map<Id, contentVersion>();
        map<id, ContentVersion> cvs;
        map<id, ContentDocument> documents;
        
        set<Id> contentDocumentIds = new Set<Id>();
        for(Ledger_Document_History__c dovHisRec : ListOfDocHisRec){
            for(ContentDocumentLink attch : dovHisRec.ContentDocumentLinks){
                contentDocumentIds.add(attch.ContentDocumentId);
                if(listOfAttchmentAndBl1.containsKey(dovHisRec.Broker_Ledger__c)){
                    
                    listOfAttchmentAndBl1.get(dovHisRec.Broker_Ledger__c).add(attch);
                }
                else{
                    listOfAttchmentAndBl1.put(dovHisRec.Broker_Ledger__c, new List<ContentDocumentLink>{attch});
                    
                }
                
            }
        }
        if(contentDocumentIds.size()> 0){
             documents = new Map<id,ContentDocument>([SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id in :contentDocumentIds]);
            for(Ledger_Document_History__c dovHisRec : ListOfDocHisRec){
                for(ContentDocumentLink attch :  listOfAttchmentAndBl1.get(dovHisRec.Broker_Ledger__c)){
                    if(listOfAttchmentAndBl2.containsKey(dovHisRec.Broker_Ledger__c)){
                        listOfAttchmentAndBl2.get(dovHisRec.Broker_Ledger__c).add(documents.get(attch.ContentDocumentId));
                    }
                    else {
                        listOfAttchmentAndBl2.put(dovHisRec.Broker_Ledger__c, new List<ContentDocument>{documents.get(attch.ContentDocumentId)});
                    }
                }
                
            }
            
            if(documents.keyset().size()>0){
                 cvs = new Map<id,ContentVersion>([SELECT Id, VersionData, Title, FileExtension,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :documents.keyset()]);
                for(ContentVersion cv : cvs.values()){
                    CvWithCd.put(cv.ContentDocumentId, cv);
                }
                for(Ledger_Document_History__c dovHisRec : ListOfDocHisRec){
                    for(ContentDocument attch :  listOfAttchmentAndBl2.get(dovHisRec.Broker_Ledger__c)){
                        if(listOfAttchmentAndBl3.containsKey(dovHisRec.Broker_Ledger__c)){
                            listOfAttchmentAndBl3.get(dovHisRec.Broker_Ledger__c).add(CvWithCd.get(attch.id));
                        }
                        else {
                            listOfAttchmentAndBl3.put(dovHisRec.Broker_Ledger__c, new List<ContentVersion>{CvWithCd.get(attch.id)});
                        }
                    }
                    
                }
            }
            
            
            
        }
        
        
        
       /* for(Ledger_Document_History__c dovHisRec : ListOfDocHisRec){
            for(Attachment attch : dovHisRec.attachments){
                setOfAttchment.add(attch.Id);
                if(listOfAttchmentAndBl.containskey(dovHisRec.Broker_Ledger__c)){
                    listOfAttchmentAndBl.get(dovHisRec.Broker_Ledger__c).add(attch);
                }
                else
                    listOfAttchmentAndBl.put(dovHisRec.Broker_Ledger__c, new list<Attachment>{attch});
            }
        }*/
        map<Id,Attachment> mapOfIdAttachment = new map<Id,Attachment>([SELECT Id,Body,name from Attachment where Id IN: setOfAttchment]);
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
        
        
        if(!setOfBLIds.isEmpty()){
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'Payment_Confirmation_Brokerage'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            for(PropStrength__Broker_Ledger__c ledger : listOfBLRec) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
                if(listOfAttchmentAndBl3.containskey(ledger.Id)){
                    for(ContentVersion att : listOfAttchmentAndBl3.get(ledger.Id)) {                        
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(att.title+ '.' + att.FileExtension);
                        efa.setBody(att.VersionData); 
                        efalst.add(efa);                        
                        if(!efalst.isEmpty()) {
                            email.setFileAttachments(efalst);
                        }
                    }
                }
                email.setWhatId(ledger.Id);
                email.setTargetObjectId(con.Id);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    }
    
}