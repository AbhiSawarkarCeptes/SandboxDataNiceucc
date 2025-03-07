public class TransactionRequestEmailSend {
    
    @Future(callout=true)
    public static void sendEmailRevisedBookingform(set<Id> propertyIds) {
        Set<Id> bookingIds = new Set<Id>(); 
        List<Attachment> attList = new List<Attachment>();
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        String tempId = '';
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        if(!propertyIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> transactionList = [SELECT Id,PropStrength__Primary_Customer__c,PropStrength__Active__c
                                                                           FROM PropStrength__Application_Booking__c 
                                                                           WHERE PropStrength__Property__c =: propertyIds AND PropStrength__Active__c =: true];
            if(!transactionList.isEmpty()) {
                for(PropStrength__Application_Booking__c tran : transactionList) {
                    bookingIds.add(tran.Id);
                }
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Application_Booking__c tran : transactionList) {
                        PageReference pdf;
                        pdf =  Page.RevisedBookingform;
                        Blob b ;
                        if(Test.isRunningTest()) { 
                          b = blob.valueOf('Unit.Test');
                        } else {
                          b = pdf.getContent();
                        }
                        Attachment att = new Attachment();
                        att.ParentId = tran.Id;
                        att.Name = 'Revised Booking form.pdf';
                        att.Body = b;
                        attList.add(att);
                    }
                    if(!attList.isEmpty()) {
                        insert attList;
                        system.debug('attList::'+attList);
                        for(Attachment oneAtt : [SELECT Id,Name,ParentId, Body FROM Attachment WHERE ParentId IN: bookingIds AND Name =: 'Revised Booking form.pdf' ORDER BY CreatedDate DESC LIMIT 1]) {
                            if(attachmentMap.containskey(oneAtt.ParentId)) {
                                List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                                newPLI.add(oneAtt);
                                attachmentMap.put(oneAtt.ParentId, newPLI);
                            } else {
                                attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                            }
                        }
                    }
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                       if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                           List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                           newPLI.add(appLicant);
                           applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                       } else {
                           applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                       }
                    }
                    List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                         FROM EmailTemplate 
                                                         WHERE DeveloperName =: 'Revised_Booking_form'];
                    tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                    for(PropStrength__Application_Booking__c tran : transactionList) {
                        if(applicantListMap.containskey(tran.Id)) {
                            for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(tran.Id)) {
                                if(applicant.PropStrength__Type__c == '1st Applicant') {
                                    sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                }
                                if(applicant.PropStrength__Type__c != '1st Applicant') {
                                    ccList.add(applicant.PropStrength__Applicant_Email__c);
                                }
                            }
                        }
                    }
                    for(PropStrength__Application_Booking__c tran : transactionList) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(!sendTo.isEmpty()) {
                            email.setToAddresses(sendTo);
                        }
                        if(!ccList.isEmpty()) {
                            email.setCcAddresses(ccList);
                        }
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        email.setWhatId(tran.id);
                        email.setTargetObjectId(tran.PropStrength__Primary_Customer__c);
                        email.setTreatTargetObjectAsRecipient(False);
                        email.saveAsActivity = true;
                        email.setTemplateId(tempId);
                        if(attachmentMap.containskey(tran.Id)){
                            for(Attachment att : attachmentMap.get(tran.Id)) {
                                if(att.Name == 'Revised Booking form.pdf') {
                                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                    efa.setFileName('Revised Booking form.pdf');
                                    efa.setBody(att.Body);
                                    efalst.add(efa);
                                }
                                if(!efalst.isEmpty()) {
                                    email.setFileAttachments(efalst);
                                }
                            }
                        }
                         mails.add(email); 
                    }
                    try {
                        if(!mails.isEmpty()){
                            Messaging.sendEmail(mails);
                        }
                    } catch(Exception e){
                        System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                        System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                    }
                }
            }
        }
    }
    
    @future
    public static void sendEmailDLDCertificate(set<Id> transIds) {
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        Map<Id,ContentVersion> attachmentMap = new Map<Id,ContentVersion>();
        String tempId = '';
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];


        if(!transIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = new List<PropStrength__Application_Booking__c>();
            List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Status__c,PropStrength__Application_Booking__c,
                                                                           PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                           FROM PropStrength__Transaction_Requests__c 
                                                                           WHERE Id =: transIds];
            if(!transactionList.isEmpty()) {
                List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :transIds];
                if(!contDocLinks.isEmpty()) {
                    List<ContentDocument> documents = [SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id = :contDocLinks[0].ContentDocumentId AND Title LIKE :'Initial%' ORDER BY CreatedDate DESC LIMIT 1];
                    if(!documents.isEmpty()) {
                        List<ContentVersion> contentVersions = [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId = :documents[0].Id];
                        if(!contentVersions.isEmpty()) {
                            attachmentMap.put(contDocLinks[0].LinkedEntityId,contentVersions[0]);
                            for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                bookingIds.add(tran.PropStrength__Application_Booking__c);
                            }
                            if(!bookingIds.isEmpty()) {
                                for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                                   FROM PropStrength__Applicant_Detail__c 
                                                                                   WHERE PropStrength__Application__c IN: bookingIds 
                                                                                   AND PropStrength__Active__c =: true 
                                                                                   AND PropStrength__Applicant_Acc__c != null]) {
                                                                                       if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                                                                                           List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                                                                                           newPLI.add(appLicant);
                                                                                           applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                                                                                       } else {
                                                                                           applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                                                                                       }
                                                                                   }
                                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                                     FROM EmailTemplate 
                                                                     WHERE DeveloperName =: 'DLD_Certificate_Uploaded_VF'];
                                tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                                for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                    if(applicantListMap.containskey(tran.PropStrength__Application_Booking__c)) {
                                        for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(tran.PropStrength__Application_Booking__c)) {
                                            if(applicant.PropStrength__Type__c == '1st Applicant') {
                                                sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                            }
                                            if(applicant.PropStrength__Type__c != '1st Applicant') {
                                                ccList.add(applicant.PropStrength__Applicant_Email__c);
                                            }
                                        }
                                    }
                                }
                                ccList.add('helpdesk@sobharealty.com');
                                for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                    if(!sendTo.isEmpty()) {
                                        email.setToAddresses(sendTo);
                                    }
                                    if(!ccList.isEmpty()) {
                                        email.setCcAddresses(ccList);
                                        email.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                                    }
                                    if (owea.size() > 0) {
                                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                                    }
                                    email.setWhatId(tran.Id);
                                    email.setTargetObjectId(tran.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                                    email.setTreatTargetObjectAsRecipient(False);
                                    email.saveAsActivity = true;
                                    email.setTemplateId(tempId);
                                    bookList.add(new PropStrength__Application_Booking__c(Id=tran.PropStrength__Application_Booking__c, Pre_Registration_Completed__c=TRUE));
                                    if(attachmentMap.containskey(tran.Id)){
                                        ContentVersion att = attachmentMap.get(tran.Id);
                                        if(att.Title.contains('Initial')) {
                                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                            efa.setFileName(attachmentMap.get(tran.Id).Title + '.' + attachmentMap.get(tran.Id).FileExtension);
                                            efa.setBody(attachmentMap.get(tran.Id).VersionData);    
                                            efalst.add(efa);
                                        }
                                        if(!efalst.isEmpty()) {
                                            email.setFileAttachments(efalst);
                                        }
                                    }
                                    mails.add(email); 
                                }
                                try {
                                    if(!mails.isEmpty()){
                                        Messaging.sendEmail(mails);
                                        update bookList;
                                    }
                                } catch(Exception e){
                                    System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                                    System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @future
    public static void sendEmailDSPA(set<Id> transIds) {
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        Map<Id,List<ContentVersion>> attachmentMap = new Map<Id,List<ContentVersion>>();
        String tempId = '';
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        if(!transIds.isEmpty()) {
           List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :transIds];
            Map<Id, Id> contLinkIdMap = new Map<Id, Id>();
            if(!contDocLinks.isEmpty()) {
                for(ContentDocumentLink contDocs : contDocLinks) {
                    contLinkIdMap.put(contDocs.ContentDocumentId, contDocs.LinkedEntityId);
                }
            }
            if(!contLinkIdMap.isEmpty()) {
                Map<Id, ContentDocument> documents = new Map<Id, ContentDocument>([SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id IN :contLinkIdMap.keySet() AND (Title LIKE :'%DSPA Letter.pdf%' OR Title LIKE :'%DCR Letter.pdf%')]);
                if(!documents.isEmpty()) {
                    List<ContentVersion> contentVersions = [SELECT Id, VersionData, Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :documents.keySet()];
                    if(!contentVersions.isEmpty()) {
                        for(ContentVersion contVer : contentVersions) {
                            if(attachmentMap.containsKey(contLinkIdMap.get(contVer.ContentDocumentId))) {
                                attachmentMap.get(contLinkIdMap.get(contVer.ContentDocumentId)).add(contVer);
                            } else {
                                attachmentMap.put(contLinkIdMap.get(contVer.ContentDocumentId),new List<ContentVersion>{contVer});
                            }
                        }
                    }
                }
            }
            List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Status__c,PropStrength__Application_Booking__c,
                                                                           PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                           FROM PropStrength__Transaction_Requests__c 
                                                                           WHERE Id =: transIds];
            if(!transactionList.isEmpty()) {
                for(PropStrength__Transaction_Requests__c tran : transactionList) {
                    bookingIds.add(tran.PropStrength__Application_Booking__c);
                }
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                       if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                           List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                           newPLI.add(appLicant);
                           applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                       } else {
                           applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                       }
                    }
                    List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                         FROM EmailTemplate 
                                                         WHERE DeveloperName =: 'DSPA_for_Digi_Sign'];
                    tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                    for(PropStrength__Transaction_Requests__c tran : transactionList) {
                        if(applicantListMap.containskey(tran.PropStrength__Application_Booking__c)) {
                            for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(tran.PropStrength__Application_Booking__c)) {
                                if(applicant.PropStrength__Type__c == '1st Applicant') {
                                    sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                }
                                if(applicant.PropStrength__Type__c != '1st Applicant') {
                                    ccList.add(applicant.PropStrength__Applicant_Email__c);
                                }
                            }
                        }
                    }
                    for(PropStrength__Transaction_Requests__c tran : transactionList) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(!sendTo.isEmpty()) {
                            email.setToAddresses(sendTo);
                        }
                        if(!ccList.isEmpty()) {
                            email.setCcAddresses(ccList);
                        }
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        email.setWhatId(tran.id);
                        email.setTargetObjectId(tran.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                        email.setTreatTargetObjectAsRecipient(False);
                        email.saveAsActivity = true;
                        email.setTemplateId(tempId);
                        if(attachmentMap.containskey(tran.Id)){
                            for(ContentVersion att : attachmentMap.get(tran.Id)) {
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(att.Title + '.' + att.FileExtension);
                                efa.setBody(att.VersionData);
                                efalst.add(efa);
                            }
                            if(!efalst.isEmpty()) {
                                email.setFileAttachments(efalst);
                            }
                        }
                         mails.add(email); 
                    }
                    try {
                        if(!mails.isEmpty()){
                            Messaging.sendEmail(mails);
                            for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                if(tran.PropStrength__Status__c == 'DSPA Executed') {
                                    PropStrength__Application_Booking__c oneTrans = new PropStrength__Application_Booking__c();
                                    oneTrans.Id = tran.PropStrength__Application_Booking__c;
                                    oneTrans.DSPA_Executed__c = true;
                                    oneTrans.DSPA_Execution_Date__c = System.now();
                                    updateList.add(oneTrans);
                                }
                            }
                            if(!updateList.isEmpty()) {
                                update updateList;
                            }
                        }
                    } catch(Exception e){
                        System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                        System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                    }
                }
            }
        }
    }
    
    @future
    public static void sendEmailLegalDSPA(set<Id> transIds) {
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        Map<Id,List<ContentVersion>> attachmentMap = new Map<Id,List<ContentVersion>>();
        String tempId = '';
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
        if(!transIds.isEmpty()) {
            List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :transIds];
            Map<Id, Id> contLinkIdMap = new Map<Id, Id>();
            if(!contDocLinks.isEmpty()) {
                for(ContentDocumentLink contDocs : contDocLinks) {
                    contLinkIdMap.put(contDocs.ContentDocumentId, contDocs.LinkedEntityId);
                }
            }
            if(!contLinkIdMap.isEmpty()) {
                Map<Id, ContentDocument> documents = new Map<Id, ContentDocument>([SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id IN :contLinkIdMap.keySet() AND Title LIKE :'%Signed%']);
                if(!documents.isEmpty()) {
                    List<ContentVersion> contentVersions = [SELECT Id, VersionData, Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :documents.keySet()];
                    if(!contentVersions.isEmpty()) {
                        for(ContentVersion contVer : contentVersions) {
                            if(attachmentMap.containsKey(contLinkIdMap.get(contVer.ContentDocumentId))) {
                                attachmentMap.get(contLinkIdMap.get(contVer.ContentDocumentId)).add(contVer);
                            } else {
                                attachmentMap.put(contLinkIdMap.get(contVer.ContentDocumentId),new List<ContentVersion>{contVer});
                            }
                        }
                    }
                }
            }
           /* for(Attachment oneAtt : [SELECT Id,Name,ParentId, Body FROM Attachment WHERE ParentId IN: transIds AND Name LIKE '%DSPA%' ORDER BY CreatedDate DESC LIMIT 1]) {
                if(attachmentMap.containskey(oneAtt.ParentId)) {
                    List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                    newPLI.add(oneAtt);
                    attachmentMap.put(oneAtt.ParentId, newPLI);
                } else {
                    attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                }
            }
            for(Attachment oneAtt : [SELECT Id,Name,ParentId, Body FROM Attachment WHERE ParentId IN: transIds AND Name LIKE '%DCR%' ORDER BY CreatedDate DESC LIMIT 1]) {
                if(attachmentMap.containskey(oneAtt.ParentId)) {
                    List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                    newPLI.add(oneAtt);
                    attachmentMap.put(oneAtt.ParentId, newPLI);
                } else {
                    attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                }
            }*/
            List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Status__c,PropStrength__Application_Booking__c,
                                                                           PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                           FROM PropStrength__Transaction_Requests__c 
                                                                           WHERE Id =: transIds];
            if(!transactionList.isEmpty()) {
                for(PropStrength__Transaction_Requests__c tran : transactionList) {
                    bookingIds.add(tran.PropStrength__Application_Booking__c);
                }
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                       if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                           List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                           newPLI.add(appLicant);
                           applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                       } else {
                           applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                       }
                    }
                    List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                         FROM EmailTemplate 
                                                         WHERE DeveloperName =: 'Executed_DSPA'];
                    tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                    for(PropStrength__Transaction_Requests__c tran : transactionList) {
                        if(applicantListMap.containskey(tran.PropStrength__Application_Booking__c)) {
                            for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(tran.PropStrength__Application_Booking__c)) {
                                if(applicant.PropStrength__Type__c == '1st Applicant') {
                                    sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                }
                                if(applicant.PropStrength__Type__c != '1st Applicant') {
                                    ccList.add(applicant.PropStrength__Applicant_Email__c);
                                }
                            }
                        }
                    }
                    for(PropStrength__Transaction_Requests__c tran : transactionList) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(!sendTo.isEmpty()) {
                            email.setToAddresses(sendTo);
                        }
                        if(!ccList.isEmpty()) {
                            email.setCcAddresses(ccList);
                        }
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        email.setWhatId(tran.id);
                        email.setTargetObjectId(tran.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                        email.setTreatTargetObjectAsRecipient(False);
                        email.saveAsActivity = true;
                        email.setTemplateId(tempId);
                        if(attachmentMap.containskey(tran.Id)){
                            for(ContentVersion att : attachmentMap.get(tran.Id)) {
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(att.Title + '.' + att.FileExtension);
                                efa.setBody(att.VersionData);
                                efalst.add(efa);
                                
                                if(!efalst.isEmpty()) {
                                    email.setFileAttachments(efalst);
                                }
                            }
                        }
                         mails.add(email); 
                    }
                    try {
                        if(!mails.isEmpty()){
                            Messaging.sendEmail(mails);
                            for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                if(tran.PropStrength__Status__c == 'DSPA Executed') {
                                    PropStrength__Application_Booking__c oneTrans = new PropStrength__Application_Booking__c();
                                    oneTrans.Id = tran.PropStrength__Application_Booking__c;
                                    oneTrans.DSPA_Executed__c = true;
                                    oneTrans.DSPA_Execution_Date__c = System.now();
                                    updateList.add(oneTrans);
                                }
                            }
                            if(!updateList.isEmpty()) {
                                update updateList;
                            }
                        }
                    } catch(Exception e){
                        System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                        System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                    }
                }
            }
        }
    }
    
    @future
    public static void sendEmailSPA(set<Id> transIds) {
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        Map<Id,ContentVersion> attachmentMap = new Map<Id,ContentVersion>();
        String tempId = '';
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
        List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :transIds];

        if(!contDocLinks.isEmpty()) {
            List<ContentDocument> documents = [SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id = :contDocLinks[0].ContentDocumentId AND Title LIKE :'%Signed%' ORDER BY CreatedDate DESC LIMIT 1];
            if(!documents.isEmpty()) {
                List<ContentVersion> contentVersions = [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId = :documents[0].Id];
                if(!contentVersions.isEmpty()) {
                    if(!transIds.isEmpty()) {
                        attachmentMap.put(contDocLinks[0].LinkedEntityId,contentVersions[0]);
                        
                        List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.POA_Email_Address__c,
                                                                                       PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                                       FROM PropStrength__Transaction_Requests__c 
                                                                                       WHERE Id =: transIds];
                        if(!transactionList.isEmpty()) {
                            for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                bookingIds.add(tran.PropStrength__Application_Booking__c);
                            }
                            if(!bookingIds.isEmpty()) {
                                for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                                   FROM PropStrength__Applicant_Detail__c 
                                                                                   WHERE PropStrength__Application__c IN: bookingIds 
                                                                                   AND PropStrength__Active__c =: true 
                                                                                   AND PropStrength__Applicant_Acc__c != null]) {
                                                                                       if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                                                                                           List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                                                                                           newPLI.add(appLicant);
                                                                                           applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                                                                                       } else {
                                                                                           applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                                                                                       }
                                                                                   }
                                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                                     FROM EmailTemplate 
                                                                     WHERE DeveloperName =: 'Executed_SPA'];
                                tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                                for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                    if(tran.PropStrength__Application_Booking__r.POA_Email_Address__c == null && applicantListMap.containskey(tran.PropStrength__Application_Booking__c)) {
                                        for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(tran.PropStrength__Application_Booking__c)) {
                                            if(applicant.PropStrength__Type__c == '1st Applicant') {
                                                sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                            }
                                            if(applicant.PropStrength__Type__c != '1st Applicant') {
                                                ccList.add(applicant.PropStrength__Applicant_Email__c);
                                            }
                                        }
                                    } else {
                                        sendTo.add(tran.PropStrength__Application_Booking__r.POA_Email_Address__c);
                                    }
                                }
                                for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                    if(!sendTo.isEmpty()) {
                                        email.setToAddresses(sendTo);
                                    }
                                    if(!ccList.isEmpty()) {
                                        email.setCcAddresses(ccList);
                                    }
                                    //email.setSubject('test');
                                    if (owea.size() > 0) {
                                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                                    }
                                    email.setWhatId(tran.id);
                                    email.setTargetObjectId(tran.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                                    email.setTreatTargetObjectAsRecipient(False);
                                    email.saveAsActivity = true;
                                    email.setTemplateId(tempId);
                                    if(attachmentMap.containskey(tran.Id)){
                                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                        efa.setFileName(attachmentMap.get(tran.Id).Title + '.' + attachmentMap.get(tran.Id).FileExtension);
                                        efa.setBody(attachmentMap.get(tran.Id).VersionData);
                                        efalst.add(efa);
                                        if(!efalst.isEmpty()) {
                                            email.setFileAttachments(efalst);
                                        }
                                    }
                                    mails.add(email); 
                                }
                                try {
                                    if(!mails.isEmpty()){
                                        Messaging.sendEmail(mails);
                                        /*for(PropStrength__Transaction_Requests__c tran : transactionList) {
PropStrength__Application_Booking__c oneTrans = new PropStrength__Application_Booking__c();
oneTrans.Id = tran.PropStrength__Application_Booking__c;
oneTrans.SPA_Executed__c = true;
oneTrans.SPA_Execution_Date__c = Date.Today();
updateList.add(oneTrans);
}
if(!updateList.isEmpty()) {
update updateList;
}*/
                                    }
                                } catch(Exception e){
                                    System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                                    System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @future
    public static void sendEmailMOU(set<Id> transIds) {
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        Map<Id,ContentVersion> attachmentMap = new Map<Id,ContentVersion>();
        String tempId = '';
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
            List<PropStrength__Transaction_Requests__c> updateTranList = new List<PropStrength__Transaction_Requests__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
        List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :transIds];
        if(!contDocLinks.isEmpty()) {
            List<ContentDocument> documents = [SELECT Id, Title, FileExtension, ContentSize FROM ContentDocument WHERE Id = :contDocLinks[0].ContentDocumentId AND Title LIKE :'%Signed%' ORDER BY CreatedDate DESC LIMIT 1];
            if(!documents.isEmpty()) {
                List<ContentVersion> contentVersions = [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId = :documents[0].Id];
                if(!contentVersions.isEmpty()) {
        if(!transIds.isEmpty()) {
                attachmentMap.put(contDocLinks[0].LinkedEntityId,contentVersions[0]);
            
            List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Application_Booking__c,
                                                                           PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                           FROM PropStrength__Transaction_Requests__c 
                                                                           WHERE Id =: transIds];
            if(!transactionList.isEmpty()) {
                for(PropStrength__Transaction_Requests__c tran : transactionList) {
                    bookingIds.add(tran.PropStrength__Application_Booking__c);
                }
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                       if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                           List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                           newPLI.add(appLicant);
                           applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                       } else {
                           applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                       }
                    }
                    List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                             FROM EmailTemplate 
                                                             WHERE DeveloperName =: 'Executed_MOU'];
                    tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                    for(PropStrength__Transaction_Requests__c tran : transactionList) {
                        if(applicantListMap.containskey(tran.PropStrength__Application_Booking__c)) {
                            for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(tran.PropStrength__Application_Booking__c)) {
                                if(applicant.PropStrength__Type__c == '1st Applicant') {
                                    sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                }
                                if(applicant.PropStrength__Type__c != '1st Applicant') {
                                    ccList.add(applicant.PropStrength__Applicant_Email__c);
                                }
                            }
                        }
                    }
                    for(PropStrength__Transaction_Requests__c tran : transactionList) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(!sendTo.isEmpty()) {
                            email.setToAddresses(sendTo);
                        }
                        if(!ccList.isEmpty()) {
                            email.setCcAddresses(ccList);
                        }
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        email.setWhatId(tran.id);
                        email.setTargetObjectId(tran.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                        email.setTreatTargetObjectAsRecipient(False);
                        email.saveAsActivity = true;
                        email.setTemplateId(tempId);
                        if(attachmentMap.containskey(tran.Id)){
                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                            efa.setFileName(attachmentMap.get(tran.Id).Title + '.' + attachmentMap.get(tran.Id).FileExtension);
                            efa.setBody(attachmentMap.get(tran.Id).VersionData);
                            efalst.add(efa);
                            if(!efalst.isEmpty()) {
                                email.setFileAttachments(efalst);
                            }
                        }
                         mails.add(email); 
                    }
                    try {
                        if(!mails.isEmpty()){
                            Messaging.sendEmail(mails);
                            /*for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                PropStrength__Transaction_Requests__c oneTrans = new PropStrength__Transaction_Requests__c();
                                oneTrans.Id = tran.Id;
                                oneTrans.MOU_Sent_for_Final_Approval__c = true;
                                oneTrans.MOU_Sent_for_Final_Approval_Date__c = Date.Today();
                                updateTranList.add(oneTrans);
                                
                                PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c();
                                book.Id = tran.PropStrength__Application_Booking__c;
                                book.MOU_Executed__c = true;
                                book.MOU_Execution_Date__c = Date.today();
                                updateList.add(book);
                            }
                            if(!updateList.isEmpty()) {
                                update updateTranList;
                            }
                            if(!updateList.isEmpty()) {
                                update updateList;
                            }*/
                        }
                    } catch(Exception e){
                        System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                        System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                    }
                }
            }
        }
                }
            }
        }
        
    }
    
    @future
    public static void sendEmailLegalMOU(set<Id> transIds) {
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        Map<Id,Attachment> attachmentMap = new Map<Id,Attachment>();
        String tempId = '';
        List<PropStrength__Transaction_Requests__c> updateList = new List<PropStrength__Transaction_Requests__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
        Attachment atts = [SELECT Id,Name,ParentId, Body 
                                  FROM Attachment 
                                  WHERE ParentId IN: transIds 
                                   ORDER BY CreatedDate DESC LIMIT 1];
        if(!transIds.isEmpty()) {
            if(atts != null) {
                attachmentMap.put(atts.ParentId,atts);
            }
            List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Application_Booking__c,
                                                                           PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                           FROM PropStrength__Transaction_Requests__c 
                                                                           WHERE Id =: transIds];
            if(!transactionList.isEmpty()) {
                for(PropStrength__Transaction_Requests__c tran : transactionList) {
                    bookingIds.add(tran.PropStrength__Application_Booking__c);
                }
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                       if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                           List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                           newPLI.add(appLicant);
                           applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                       } else {
                           applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                       }
                    }
                    List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                             FROM EmailTemplate 
                                                             WHERE DeveloperName =: 'MOU_for_Digi_Sign'];
                    tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                    for(PropStrength__Transaction_Requests__c tran : transactionList) {
                        if(applicantListMap.containskey(tran.PropStrength__Application_Booking__c)) {
                            for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(tran.PropStrength__Application_Booking__c)) {
                                if(applicant.PropStrength__Type__c == '1st Applicant') {
                                    sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                }
                                if(applicant.PropStrength__Type__c != '1st Applicant') {
                                    ccList.add(applicant.PropStrength__Applicant_Email__c);
                                }
                            }
                        }
                    }
                    for(PropStrength__Transaction_Requests__c tran : transactionList) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(!sendTo.isEmpty()) {
                            email.setToAddresses(sendTo);
                        }
                        if(!ccList.isEmpty()) {
                            email.setCcAddresses(ccList);
                        }
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        email.setWhatId(tran.id);
                        email.setTargetObjectId(tran.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                        email.setTreatTargetObjectAsRecipient(False);
                        email.saveAsActivity = true;
                        email.setTemplateId(tempId);
                        if(attachmentMap.containskey(tran.Id)){
                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                            efa.setFileName(atts.Name);
                            efa.setBody(attachmentMap.get(tran.Id).Body);
                            efalst.add(efa);
                            if(!efalst.isEmpty()) {
                                email.setFileAttachments(efalst);
                            }
                        }
                         mails.add(email); 
                    }
                    try {
                        if(!mails.isEmpty()){
                            Messaging.sendEmail(mails);
                            for(PropStrength__Transaction_Requests__c tran : transactionList) {
                                PropStrength__Transaction_Requests__c oneTrans = new PropStrength__Transaction_Requests__c();
                                oneTrans.Id = tran.Id;
                                oneTrans.MOU_Sent_to_Customer_for_Digi_Sign__c = true;
                                oneTrans.MOU_Sent_to_Customer_for_Digi_Sign_Date__c = System.Now();
                                updateList.add(oneTrans);
                            }
                            if(!updateList.isEmpty()) {
                                update updateList;
                            }
                        }
                    } catch(Exception e){
                        System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                        System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                    }
                }
            }
        }
    }
}