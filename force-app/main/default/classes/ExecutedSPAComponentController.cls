public with sharing class ExecutedSPAComponentController 
{
	 @auraEnabled
    public static void sendSPAdocument(Id bookId)
    {
        Booking__c booking =[Select Id, Name, Unit__r.Name, Project__r.Name from Booking__c where Id=:bookId];
        list<String> applicantEmails = new list<String>();
        string applicantNames='';
        ContentDocumentLink doclink = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType FROM ContentDocumentLink 
                                              WHERE LinkedEntityId =:bookId and ContentDocument.title like 'SPA -%' 
                                              Order by ContentDocument.createdDate desc Limit 1];
        ContentVersion cversion = [SELECT VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId = :doclink.ContentDocumentId AND IsLatest = true];
		for(Applicant_Details__c applicants : [Select id,Salutation__c, name, Email_Address__c From Applicant_Details__c Where Booking__c =:bookId ])
        {
            applicantEmails.add(applicants.Email_Address__c);
            if(applicantNames=='')
            {
                applicantNames=applicants.Salutation__c+' '+applicants.Name;
            }
            else
            {
                applicantNames=applicantNames+', ' +applicants.Salutation__c+' '+applicants.Name;
            }
        }
        System.debug('applicantEmails:'+applicantEmails);
        List<String> ccEmailIds=new List<String>();
        List<Additional_SPA_Recipient__mdt> mcs = Additional_SPA_Recipient__mdt.getAll().values();
        system.debug(mcs);
        for(Additional_SPA_Recipient__mdt asrm : mcs)
        {
          ccEmailIds.add(asrm.email__c);
        }
        string emailSubject='Executed SPA Docusign '+booking.Unit__r.Name +' - '+booking.Project__r.Name;
		EmailTemplate bEmailTemplate = [SELECT Id, name, developerName, Subject, Body FROM EmailTemplate WHERE developerName = 'Completed_SPA_Template' limit 1];
        bEmailTemplate.Subject = bEmailTemplate.Subject.replace('{!EmailSubject}', emailSubject);
        bEmailTemplate.Body = bEmailTemplate.Body.replace('{!Applicants}', applicantNames);
        Messaging.SingleEmailMessage emlSend = new Messaging.SingleEmailMessage();
        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Blob fileData = cversion.VersionData;
		Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
		emlAtt.setFilename(doclink.ContentDocument.title+'.'+cversion.FileExtension);
		emlAtt.setBody(fileData);
        fileAttachments.add(emlAtt);
        
        emlSend.setToAddresses(applicantEmails);
        emlSend.setCcAddresses(ccEmailIds);
        emlSend.setSubject(bEmailTemplate.Subject);
        emlSend.setPlainTextBody(bEmailTemplate.body);
        emlSend.setsaveAsActivity(false);
        emlSend.setFileAttachments(fileAttachments);
        List<Messaging.SendEmailResult>  allEmailResult = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emlSend});
        System.debug('Email sent successfully');
        //return 'Success';
    }
}