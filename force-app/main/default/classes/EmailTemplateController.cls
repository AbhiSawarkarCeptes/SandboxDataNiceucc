public with sharing class EmailTemplateController {
    @AuraEnabled
    public static List<String> getEmailAddress(String searchKeyWrd){
        List<String> emailAddress = new List<String>();
        if(searchKeyWrd == '') {
            List<Contact> conList = [SELECT Id, email FROM Contact WHERE email != null];
            for(Contact con : conList) {
                if(!emailAddress.contains(con.email)) {
                    emailAddress.add(con.email);
                }
            }
        }
        else {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            List<Contact> conList = [SELECT Id, email FROM Contact WHERE email LIKE :searchKeyWrd];
            for(Contact con : conList) {
                if(!emailAddress.contains(con.email)) {
                    emailAddress.add(con.email);
                }
            }
        }
        emailAddress.add('+ New Email Address');
        return emailAddress;
    }

    @AuraEnabled
    public static string sendEmail(String emailDetails, String contentDocumentId){
        List<EmailDetailWrapper> emailDetailList = new List<EmailDetailWrapper>();
        List<Object> eDetails = (List<Object>) JSON.deserializeUntyped(emailDetails);
        Set<String> emailaddress = new Set<String>();
      	for (Object obj : eDetails) {
            Map<String, Object> email = (Map<String, Object>) obj;
            EmailDetailWrapper edw = new EmailDetailWrapper();
            if(email.get('To') != null && email.get('To') != '') {
                edw.To = new List<String>();
                if(String.valueOf(email.get('To')).contains(',')) {
                    emailaddress.add(String.valueOf(email.get('To')).split(',')[0]);
                    edw.To.addAll(String.valueOf(email.get('To')).split(','));
                }
                else{
                    emailaddress.add(String.valueOf(email.get('To')));
                    edw.To.add(String.valueOf(email.get('To')));
                }
            }
            if(email.get('Cc') != null && email.get('Cc') != '') {
                edw.Cc = new List<String>();
                if(String.valueOf(email.get('Cc')).contains(',')) {
                    edw.Cc.addAll(String.valueOf(email.get('Cc')).split(','));
                }
                else{
                    edw.Cc.add(String.valueOf(email.get('Cc')));
                }
            }
            if(email.get('Bcc') != null  && email.get('Bcc') != '') {
                edw.Bcc = new List<String>();
                if(String.valueOf(email.get('Bcc')).contains(',')) {
                    edw.Bcc.addAll(String.valueOf(email.get('Bcc')).split(','));
                }
                else{
                    edw.Bcc.add(String.valueOf(email.get('Bcc')));
                }
            }
            if(email.get('EmailSubject') != null  && email.get('EmailSubject') != '') {
                edw.EmailSubject = String.valueOf(email.get('EmailSubject'));
            }
            if(email.get('EmailBody') != null  && email.get('EmailBody') != '') {
                edw.EmailBody = String.valueOf(email.get('EmailBody'));
            }
            emailDetailList.add(edw);
        }
        Map<String, Id> emailVsContactId = new Map<String, Id>();
        if(!emailaddress.isEmpty()) {
            emailVsContactId = getCotactIdFromEmail(emailaddress);
        }
        if(!emailVsContactId.keySet().isEmpty() && !emailDetailList.isEmpty()) {
            for(EmailDetailWrapper e : emailDetailList) {
                if(e.To.size() > 0) {
                    e.contactId = emailVsContactId.containsKey(e.To[0]) ? emailVsContactId.get(e.To[0]) : null;
                }
            }
            String st = sendEmails(emailDetailList, contentDocumentId);
            return st;
        }
        return 'Error';
    }
    public static Map<String, Id> getCotactIdFromEmail(Set<String> emailAddress) {
        Map<String, Id> mapToReturn = new Map<String, Id>();
        List<Contact> conList = [SELECT Id, Email FROM Contact WHERE Email IN :emailAddress];
        for(Contact c : conList) {
            mapToReturn.put(c.Email, c.Id);
        }
        return mapToReturn;
    }
    @AuraEnabled
    public static ContentVersion uploadFile(String fileName, String fileBody) {
        ContentVersion cv = new ContentVersion(
            Title = fileName,
            VersionData = EncodingUtil.base64Decode(fileBody),
            PathOnClient = fileName
        );
        insert cv;
        ContentVersion cv1 = [SELECT Id, Title, ContentDocumentId  FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        System.debug('=====> Chekc'+ cv1);
        System.debug('=====> Chekc'+ cv1.ContentDocumentId);
        return cv1;
    }

    public static String sendEmails(List<EmailDetailWrapper> emailDetailList, String contentDocumentId) {
        List<Contact> conRec = [SELECT Id FROM Contact LIMIT 1];
        List<Messaging.SingleEmailMessage> emailList = new  List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress LIMIT 1]; 
        ContentVersion doc = new ContentVersion();
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        if(contentDocumentId != '' && contentDocumentId != null) {
            doc = [SELECT VersionData, Title,  FileExtension FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
            attachment.setFileName(doc.Title);
            attachment.setBody(doc.VersionData);
            attachment.setContentType('application/pdf');
        }            

        for(EmailDetailWrapper emailWrapper : emailDetailList){
            List<String> emailAddress = new List<String>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            emailAddress.addAll(emailWrapper.To);
            emails.setOrgWideEmailAddressId(owea.get(0).Id);
            System.debug('Email Id--->1234   '+attachment);
            if(attachment.getBody() != null) {
                emails.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
            }
            if(emailWrapper.contactId != null) {
                System.debug('Email Id--->12'+emailWrapper.contactId);
                emails.setTargetObjectId(Id.valueOf(emailWrapper.contactId));
            }
            else{
                System.debug('Email Id--->'+conRec[0].Id);
                emails.setTargetObjectId(conRec[0].Id);
            }
            if(emailWrapper.Cc != null && !emailWrapper.Cc.isEmpty()) {
                emails.setCcAddresses(emailWrapper.Cc);
            }
            if(emailWrapper.Bcc != null && !emailWrapper.Bcc.isEmpty()) {
                emails.setBccAddresses(emailWrapper.Bcc);
            }
            if(emailWrapper.EmailSubject != null && emailWrapper.EmailSubject != '') {
                emails.setSubject(emailWrapper.EmailSubject);
            }
            if(emailWrapper.EmailBody != null && emailWrapper.EmailBody != '') {
                emails.setHtmlBody(emailWrapper.EmailBody );
            }
            emails.setToAddresses(emailAddress);
            emails.setSaveAsActivity(true); 
            emails.setTreatTargetObjectAsRecipient(false); 
            System.debug('--------------->'+ emails);
            emailList.add(emails);
        }
        try{
            if(emailList != null && emailList.size()>0 ) {
                System.debug('--------------->'+ emailList);
                Messaging.sendEmail(emailList);
            }
            return 'Success';
        } catch(Exception ex){
            system.debug('===========Exception ============'+ex.getmessage());
            system.debug('===========Exception ============'+ex.getlinenumber());
            return String.valueOf(ex.getlinenumber());
        }
        
    }
    public class EmailDetailWrapper {
        public List<String> To;
        public List<String> Cc;
        public List<String> Bcc;
        public String EmailSubject;
        public String EmailBody;
        public Id contactId;
    }
}