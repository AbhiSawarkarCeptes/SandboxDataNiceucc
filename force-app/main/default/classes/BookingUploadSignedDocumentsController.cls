public without sharing class BookingUploadSignedDocumentsController {
    
    @AuraEnabled
    public static ResponseWrapper getApplicationDetails(String bookingId){
        try {
            Booking__c bookingObject = [SELECT ID,Booking_Date__c,Project_Name__c,Name,Unit__r.Name,Signed_Status__c,booking_form_uploaded__c FROM Booking__c where id =: bookingId];
            List<Applicant_Details__c> applicationDetails = [SELECT   Name,Type_Of_Applicant__c,Applicant_Number__c,Subtype_Of_Applicant__c,Visa_Copy__c,Passport_Copy__c,ID,National_Id_Verified__c,Non_Residency_Letter_Verified__c,
            Other_Documents_Verified__c,Passport_Copy_of_Authorized_Verified__c,Passport_Verified__c,Power_Of_Attorney_Verified__c,Registration_License_Verified__c,Visa_Copy_Verified__c,Certificate_of_Good_Standing_Verified__c,Certificate_Of_Incorporation_Verified__c,Emirates_Id_Verified__c,Memoradum_Articles_Verified__c,National_Id_Uploaded__c,Non_Residency_Letter_Uploaded__c,Other_Documents_Uploaded__c,Passport_Copy_of_Authorized_Uploaded__c,
            Passport_Uploaded__c,Power_Of_Attorney_Uploaded__c,Registration_License_Uploaded__c,Visa_Copy_Uploaded__c,
            Certificate_of_Good_Standing_Uploaded__c,Certificate_Of_Incorporation_Uploaded__c,Emirates_Id_Uploaded__c,
            Memoradum_Articles_Uploaded__c,Emirates_ID_of_Authorized_Uploaded__c,Letter_of_undertaking_uploaded__c,
            Visa_copy_of_Authorized_Uploaded__c,Trade_License_Uploaded__c,Passport_Copy_Of_Attorney_Uploaded__c
             FROM Applicant_Details__c WHERE booking__c =: bookingid];
            ResponseWrapper response = new ResponseWrapper();
            response.bookingObj = bookingObject;
            response.applicationDetails = applicationDetails;
            response.disableSignedBookingFormUpload = bookingObject.booking_form_uploaded__c ;
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public Booking__c bookingObj;
        @AuraEnabled
        public List<Applicant_Details__c> applicationDetails;
        @AuraEnabled
        public boolean disableSignedBookingFormUpload;
    }
    
    @AuraEnabled
    public static Applicant_Details__c getApplicantDetails (string applicantId){
        return [select Id, Subtype_Of_Applicant__c, Applicant_Number__c from Applicant_Details__c where Id =: applicantId];
    }
    
    @AuraEnabled
    public static void updateContentDocumentTitle (string fileName,string applicantId,string bookingId){
        ContentDocument doc = [select Id from ContentDocument where CreatedById =: Userinfo.getUserId() order by CreatedDate desc limit 1];
        doc.Title = fileName;
        update doc;
        if(fileName == 'Signed Booking Form'){
            update new booking__c(id = bookingId, booking_form_uploaded__c= true);
        }
        String likeText = '%' + fileName + '%';
        List<ContentDocumentLink> cdlList = [select id,contentDocumentId from ContentDocumentLink WHEre LinkedEntityId = : bookingId and contentDocumentId !=: doc.id and 
        contentDocument.title like :likeText];
        List<ContentDocument> contentdocToDelete = new List<ContentDocument>();
        for(ContentDocumentLink cdl : cdlList){
            contentdocToDelete.add(new contentDocument(id = cdl.contentDocumentId));
        }
        delete contentdocToDelete;
        if(applicantId != null){
            system.debug('fileName==='+fileName);
            Applicant_Details__c applicationDetailToUpdate = new Applicant_Details__c(id = applicantId);
            if(fileName.contains('Passport Copy of Authorized Signatory')){
                applicationDetailToUpdate.Passport_Copy_of_Authorized_Uploaded__c = true;
            }
            else if(fileName.contains('Passport Copy of Authorized Attorney')){
                applicationDetailToUpdate.Passport_Copy_Of_Attorney_Uploaded__c = true;
            }else if(fileName.contains('Power of Attorney')){
                applicationDetailToUpdate.Power_Of_Attorney_Uploaded__c = true;
            }else if(fileName.contains('Trade License')){
                applicationDetailToUpdate.Trade_License_Uploaded__c =  true;
            }else if(fileName.contains('Visa Copy of Authorized Signatory')){
                applicationDetailToUpdate.Visa_copy_of_Authorized_Uploaded__c =  true;
            }else if(fileName.contains('Visa Copy')){
                applicationDetailToUpdate.Visa_Copy_Uploaded__c = true;
            }else if(fileName.contains('Others')){
                applicationDetailToUpdate.Other_Documents_Uploaded__c = true;
            }else if(fileName.contains('Emirates Id')){
                applicationDetailToUpdate.Emirates_Id_Uploaded__c =  true;
            }else if(fileName.contains('Non-residency Letter')){
                applicationDetailToUpdate.Non_Residency_Letter_Uploaded__c =  true;
            }else if(fileName.contains('National Id')){
                applicationDetailToUpdate.National_Id_Uploaded__c =  true;
            }else if(fileName.contains('Registration License')){
                applicationDetailToUpdate.Registration_License_Uploaded__c =  true;
            }else if(fileName.contains('Passport Copy')){
                applicationDetailToUpdate.Passport_Uploaded__c=  true;
            }else if(fileName.contains('Memorandum')){
                applicationDetailToUpdate.Memoradum_Articles_Uploaded__c =  true;
            }else if(fileName.contains('Certificate of Incorporation')){
                applicationDetailToUpdate.Certificate_Of_Incorporation_Uploaded__c =  true;
            }else if(fileName.contains('Certificate of Good Standing and Certificate of Incumbency')){
                applicationDetailToUpdate.Certificate_of_Good_Standing_Uploaded__c =  true;
            }else if(fileName.contains('Letter of undertaking')){
                applicationDetailToUpdate.Letter_of_undertaking_uploaded__c=  true;
            }else if(fileName.contains('Emirates ID of Authorized Signatory')){
                applicationDetailToUpdate.Emirates_ID_of_Authorized_Uploaded__c =  true;
            }
            update applicationDetailToUpdate;
        }
        
    }
    
    public static void trackUploadDocumentsClick(string bookingId, string userName, string msg){	
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 	
        mail.setSubject('Upload Documents Button Clicked'); 	
        mail.setHtmlBody('Booking Id: '+bookingId+ ' | '+'User Name: '+userName+ ' | '+'Message: '+msg);	
        mail.setToAddresses(new list<string>{'vamsi.modepalli@sobharealty.com','vishnu.prasad@sobharealty.com'});	
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    @AuraEnabled
    public static void sendEmail(string bookingId, string templateDeveloperName){
        string msg='';
        boolean triggerEmail = false;
        User currentUser = [Select Id,Name, Email, ManagerId, Manager.Email from User where Id =: UserInfo.getUserId() LIMIT 1];
        Booking__c bk = [select id,Name,Submitter__r.email,Unit__r.name,Primary_Applicant_Name__c,Signed_Status__c from Booking__c where id =: bookingId];
        List<Id> ContentDocumentIds = new List<Id>();
        for(ContentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: bookingId]){
            ContentDocumentIds.add(CDLink.ContentDocumentId); 
        }
        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN:ContentDocumentIds AND title='Signed Booking Form'];
        
        if(cvList.size()>0 && bk.Signed_Status__c == null){
            bk.Signed_Status__c = 'Booking Form Uploaded';
            bk.Signed_Date__c = system.now();
            bk.Submitter__c = UserInfo.getUserId();	
            bk.Submitter_Manager__c = currentUser.ManagerId;	
            msg='Booking Form Uploaded';
            triggerEmail = true;
        }	
        else{	
            msg='Booking Form Not Uploaded';	
        }
        
        if(bk.Signed_Status__c == 'Resubmit to Submitter'){
            bk.Signed_Status__c = 'Resubmitted for Document Verification';
            triggerEmail = true;
        }
        
        update bk;
        BookingUploadSignedDocumentsController.trackUploadDocumentsClick(bk.Name,currentUser.Name,msg);
        if(triggerEmail){
            EmailTemplate e = [select id, HtmlValue, Subject from EmailTemplate where DeveloperName =: templateDeveloperName];
            
            string body = e.HtmlValue;
            body = body.replace('#UnitID#', bk.Unit__r.name);
            body = body.replace('#BookingID#', bk.name);
            body = body.replace('#CustomerName#', bk.Primary_Applicant_Name__c);
            
            string subject = e.Subject;
            subject = subject.replace('#UnitID#', bk.Unit__r.name);
            subject = subject.replace('#BookingID#', bk.name);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setSubject(subject); 
            mail.setHtmlBody(body);
            
            list<string> toAddress = new list<string>();
            list<string> ccAddress = new list<string>();
            
            if(templateDeveloperName == 'Booking_Form_Submitted'){
                toAddress.add('salesops@sobharealty.com');
                ccAddress.add(currentUser.Email);
            }
            if(templateDeveloperName == 'Booking_Form_Submitted_SM'){
                toAddress.add(currentUser.Email);
                ccAddress.add(currentUser.Manager.Email);
            }
            
            mail.setToAddresses(toAddress);
            mail.setCcAddresses(ccAddress);
            mail.setSaveAsActivity(false); 
            if(!Test.isRunningTest())
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    @InvocableMethod
    public static void updateSBEUser(List<Id> bookingIds) {
        updateSBEUser(bookingIds[0]);
    }
    
    @AuraEnabled
    public static void updateSBEUser(String bookingId) {
        
        String sbfUserId;
        List<GroupMember> queueUsers = [SELECT UserOrGroupId 
                                        from GroupMember 
                                        where Group.Name = 'SBF Queue'];
        
        List<String> queueUsersIds = new List<String>();
        for (GroupMember gm:queueUsers) {
            queueUsersIds.add(gm.UserOrGroupId);
        }
        
        Sobha_Settings__c cs = Sobha_Settings__c.getInstance();
        String sbfUser = cs.SBF_Last_Used_User__c;
        
        Integer queueSize = queueUsersIds.size();
        Integer indexOfUserId = queueUsersIds.indexOf(sbfUser);
        System.debug('queueSize :: '+queueSize + '     ::::: indexOfUserId :: '+indexOfUserId);
        if(queueSize == 0) return;
        Integer indexOfUser = 0;
        if (indexOfUserId == queueSize -1) {
            sbfUserId = queueUsersIds.get(0);
        } else {
            sbfUserId = queueUsersIds.get(indexOfUserId + 1);
        }
        Sobha_Settings__c obj = Sobha_Settings__c.getOrgDefaults();
        obj.SBF_Last_Used_User__c = sbfUserId;
        update obj;
        System.debug('sbfUserId ::'+sbfUserId);
        
        list<Booking__c> booking = [Select id,SBF_Assigned_To__c From Booking__c where id=:bookingId and SBF_Assigned_To__c = null];
        if (booking.size() > 0) {
            booking[0].SBF_Assigned_To__c = sbfUserId;
            update booking[0];
        }
    }
    
}