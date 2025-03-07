public with sharing class BrokerRegistrationSendToBroker {
    public BrokerRegistrationSendToBroker() {
        
    }
    
    @AuraEnabled
    public static String sendAgreementAndNOCToBroker(Id recordId){
        String returnState = 'No';
        EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate  Where DeveloperName ='BrokerExecutedDocs_brokerReg'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Contact> deleteCons = new List<Contact>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@sobharealty.com'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        /*List<Broker_Registration__c> newList = [Select id,First_Name__c,CHRM_Manager_Email__c,createdby.Name,createdby.Email,Last_Name__c,Email__c,Status__c From Broker_Registration__c
Where id =:recordId]; */
        Broker_Registration__c reg = [Select id,First_Name__c, owner.Name, owner.email, Alternate_Email__c, CHRM_Manager_Email__c,createdby.Name,createdby.Email,Last_Name__c,Email__c,Status__c, Parent_Record__c From Broker_Registration__c
                                      Where id =:recordId];
        List<Broker_Registration__c> borkerUpdateList = new List<Broker_Registration__c>();
        List<Id> brIdlist = new List<Id>();
        //for(Broker_Registration__c reg : newList){
        if(reg.Status__c == 'Executed Agreement sent to CRHM'){
            String fName = reg.First_Name__c;
            String lName = reg.First_Name__c+'1';
            //String lName = reg.Last_Name__c;
            if(fName!=null && fName.length()>40){
                fName= fName.substring(0, 40);
            }
            if(reg.Last_Name__c!=null){
                lName = reg.Last_Name__c;
                if(lName.length()>80){
                    lName=lName.substring(0, 80);
                }
            }
            Contact dummyContact = new Contact(FirstName = fName, LastName = lName, Email = reg.Email__c);
            insert dummyContact;
            deleteCons.add(dummyContact);
            
            string[] mailCC = new string[]{};
                if(reg.Alternate_Email__c!=null){
                    mailCC.add(reg.Alternate_Email__c);
                }
            if(!mailCC.isEmpty()){
                email.setCcAddresses(mailCC);
            }
            
            //send an email to Ashish parakh along with agreement and noc attached
            
            email.setTargetObjectId(dummyContact.Id);
            email.setTemplateId(et.id);//Replace TEMPLATEID with salesforce email template id
            email.whatId = reg.Id;
            //email.setOrgWideEmailAddressId(owea.get(0).Id);
            //email.setOrgWideEmailAddressId(createdbyId);
            email.setReplyTo(reg.CHRM_Manager_Email__c);
            email.setSenderDisplayName(reg.owner.Name);
            
            List<Messaging.EmailFileAttachment> attach = new List<Messaging.EmailFileAttachment>();
            
            List<ContentDocumentLink> cdl1 = [Select Id, ContentDocument.LatestPublishedVersion.VersionData,contentdocument.FileExtension from ContentDocumentLink where LinkedEntityId =: reg.Id AND ContentDocument.Title like '%NOC%' Order by ContentDocument.createdDate desc];                            
            if(cdl1.size() > 0){
                Blob b = cdl1[0].ContentDocument.LatestPublishedVersion.VersionData;
                system.debug('bodydebug' + b +'//////'+ cdl1[0].ContentDocument.LatestPublishedVersion.VersionData);   
                Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment(); 
                attach1.setFileName('NOC'+'.'+cdl1[0].contentdocument.FileExtension);
                attach1.setBody(b);
                attach.add(attach1);
            }
            List<ContentDocumentLink> cdl2 = [Select Id, ContentDocument.LatestPublishedVersion.VersionData,contentdocument.FileExtension from ContentDocumentLink where LinkedEntityId =: reg.Id AND ContentDocument.Title like '%Agreement%' Order by ContentDocument.createdDate desc];
            if(cdl2.size() > 0){
                Blob b = cdl2[0].ContentDocument.LatestPublishedVersion.VersionData;
                system.debug('bodydebug' + b +'//////'+ cdl2[0].ContentDocument.LatestPublishedVersion.VersionData);   
                Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();  
                attach2.setFileName('Agreement'+'.'+cdl2[0].contentdocument.FileExtension);
                attach2.setBody(b);
                attach.add(attach2);
            }
            StaticResource stres = [SELECT Name, Body FROM StaticResource WHERE Name = 'Sobha_Realty_Circular'];
            Blob b = stres.Body;
            Messaging.EmailFileAttachment attach3 = new Messaging.EmailFileAttachment();  
            attach3.setFileName('Sobha Realty Circular.pdf');
            attach3.setBody(b);
            attach.add(attach3);
            
            email.setFileAttachments(attach);
            
            mails.add(email);
            
            Broker_Registration__c br = new Broker_Registration__c();
            br.status__c = 'Executed Agreement sent to broker';
            br.id = recordId;
            borkerUpdateList.add(br);
            brIdlist.add(br.Id);
            if(reg.Parent_Record__c!=null){
                Broker_Registration__c pbr = new Broker_Registration__c();
                pbr.Renewal_Status__c = 'Renewal Completed';
                pbr.Id = reg.Parent_Record__c;
                borkerUpdateList.add(pbr);
                brIdlist.add(pbr.Id);
            }
            //upsert br;
        }
        //}
        try {
            if(borkerUpdateList.size()>0){
                update borkerUpdateList;
                sendExecutedAgreementEmails(brIdlist);
            }
            Messaging.sendEmail(mails);
            delete deleteCons;
            return 'yes';
        } catch(Exception e) {
            Error_Log__c trackErrorRec = new Error_Log__c(Class__c = 'brokerRegistrationSendToBroker',Message__c = e.getmessage());
            database.insert(trackErrorRec, false);
            system.debug('~~~Catch Exception: '+e.getMessage());
            return 'No';
        }
        
    }
    
    @future
    public static void sendExecutedAgreementEmails(List<Id> brokerRegRecIds) {
        // Query the broker records using the list of Ids
        List<Broker_Registration__c> brokerRegRecs = [SELECT Id, Broker_Category__c, Alternate_Email__c, email__c 
                                                      FROM Broker_Registration__c 
                                                      WHERE Id IN :brokerRegRecIds];
        
        Set<String> brokerCategorySet = new Set<String>{'Broker - RERA','Broker - Intnl','Broker - UAE','Sobha Connect - UAE - Company','Sobha Connect - Intnl - Company'};
            
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        for (Broker_Registration__c brokerRegRec : brokerRegRecs) {
            if (brokerCategorySet.contains(brokerRegRec.Broker_Category__c)) {
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: System.Label.BR_no_reply_email];
                List<String> toAddresses = new List<String>();
                List<String> CcAddresses = new List<String>{System.Label.SF_Notifications};
                
                // Add the alternate email only if it is not null
                if (brokerRegRec.Alternate_Email__c != null) {
                    toAddresses.add(brokerRegRec.Alternate_Email__c);
                }
                
                if (!toAddresses.isEmpty()) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setUseSignature(false);
                    email.setSaveAsActivity(true);
                    email.setSubject('Agreement created & Sent for Signature');
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                    email.setToAddresses(toAddresses);
                    email.setCcAddresses(CcAddresses);
                    
                    String emailBody = '<html><body>';
                    emailBody += 'Dear Channel Partner,<br/><br/>';
                    emailBody += 'Greetings from Sobha Realty!<br/><br/>';
                    emailBody += 'This is to inform you that Broker Agreement has been sent to the registered email address ' + brokerRegRec.email__c + ' for your signature.<br/><br/>';
                    emailBody += 'Kindly sign the agreement using the link.<br/><br/>';
                    emailBody += 'In case you need any assistance, please contact your respective Channel Manager.<br/><br/>';
                    emailBody += 'Best Regards,<br/>';
                    emailBody += '<b>Channel Operations</b></body></html>';
                    email.setHtmlBody(emailBody);
                    emailList.add(email);
                }
            }
        }
        
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }
}