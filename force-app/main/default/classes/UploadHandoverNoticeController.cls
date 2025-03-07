public class UploadHandoverNoticeController {
    Public String towerId;
    Public String getDocName;
    public Integer totalSelectedAttachment                                  {get; set;}
    public Integer attachmentSelected                                       {get; set;}
    public Integer otherAttachmentsSelectionCount                           {get; set;}
    public String fileType                                                  {get; set;}         
    public String fileName                                                  {get; set;}
    public String fileExtention                                             {get; set;}
    public String documentType                                              {get; set;}
    public String counter                                                   {get; set;}
    Public String pageName                                                  {get; set;}
    public Boolean showHide                                                 {get; set;}
    public transient String base64                                          {get; set;}
    public Integer totalAttachmentInserted                                  {get; set;}
    public Id redirectId                                                    {get; set;}
    public List<PropStrength__Tower__c> oneTowerList                        {get; set;}
    
    public UploadHandoverNoticeController(ApexPages.StandardController controller){
        showHide = false;
        oneTowerList = new List<PropStrength__Tower__c>();
        if(apexpages.currentpage().getparameters().get('handoverNoticeId') !=null){
            towerId = apexpages.currentpage().getparameters().get('handoverNoticeId');
            pageName = 'Upload Handover Notice';
        }else if(apexpages.currentpage().getparameters().get('completionNoticeId') !=null){
            towerId = apexpages.currentpage().getparameters().get('completionNoticeId');
            pageName = 'Upload Completion Notice';
        }
        oneTowerList = [Select Id, Send_Handover_Notice__c, Handover_Notice_Sent_Date__c, Completion_Notice_Sent_Date__c, Send_Completion_notice__c From PropStrength__Tower__c WHERE Id =:towerId AND PropStrength__Active__c = TRUE];
        if(!oneTowerList.isEmpty()){
            for(PropStrength__Tower__c towerRec : oneTowerList){
                if(pageName == 'Upload Handover Notice'){
                    if(towerRec.Send_Handover_Notice__c && towerRec.Handover_Notice_Sent_Date__c != null){
                        showHide = false;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot upload doc.'));
                    } else{
                        showHide = true;
                    }
                }else if(pageName == 'Upload Completion Notice'){
                    if(towerRec.Send_Completion_notice__c && towerRec.Completion_Notice_Sent_Date__c != null){
                        showHide = false;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot upload doc.'));
                    } else{
                        showHide = true;
                    }
                }
            }
        }
        totalSelectedAttachment = 0;
        attachmentSelected = 0;
        otherAttachmentsSelectionCount = 0;
        totalAttachmentInserted = 0;
    }
    public PageReference afterAttachmentMessage(){
        if(totalAttachmentInserted == 0 && totalSelectedAttachment == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one attachment.'));
            return null;
        }
        return null; 
    }
    public PageReference saveAttachmentFun(){
        String stringCounter = '';
        if(towerId !=null && otherAttachmentsSelectionCount > 0){
            if(apexpages.currentpage().getparameters().get('handoverNoticeId') !=null){
                addAttachemtOne(towerId,'Unit Handover Commencement' +'-'+fileName+stringCounter,base64,fileType);
            }else if(apexpages.currentpage().getparameters().get('completionNoticeId') !=null){
                addAttachemtTwo(towerId,'Unit Completion Notification' +'-'+fileName+stringCounter,base64,fileType);
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please select document to upload'));
            return null;
        }
        return null;
    }
    public void selectedValues(){
        if(towerId != null){
            redirectId = towerId;
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Offer Id not found!'));
        }        
    }
    
    public void addAttachemtOne(Id parentId, String attachmentName, String body, String contentType){  
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1]; 

        List<PropStrength__Tower__c> towerList = [SELECT Id, (SELECT Id FROM PropStrength__Properties__r) FROM PropStrength__Tower__c WHERE Id = :parentId];
        Set<Id> propId = new Set<Id>();
        Set<Id> bookingId = new Set<Id>();

        if(!towerList.isEmpty() && !towerList[0].PropStrength__Properties__r.isEmpty()) {
            for(PropStrength__Property__c prop: towerList[0].PropStrength__Properties__r) {
                propId.add(prop.Id);
            }

            if(!propId.isEmpty()) {
                Map<Id, PropStrength__Property__c> propMap = new Map<Id, PropStrength__Property__c>([SELECT Id, (SELECT ID FROM PropStrength__Application_Booking__r WHERE PropStrength__Active__c = TRUE ORDER BY CreatedDate DESC LIMIT 1) FROM PropStrength__Property__c WHERE Id IN :propId]);

                if(!propMap.isEmpty()) {
                    for(PropStrength__Property__c prop : propMap.values()) {
                        if(!prop.PropStrength__Application_Booking__r.isEmpty()) {
                            bookingId.add(prop.PropStrength__Application_Booking__r[0].Id);
                        }
                    }
                    if(!bookingId.isEmpty()) {
                        Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id,PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Applicant_Email__c, PropStrength__Customer_Name__c, PropStrength__Type__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE) FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]);
                        Attachment newAttachment = new Attachment(ParentId = parentId, Name = attachmentName, Body = EncodingUtil.Base64Decode(body), ContentType = contentType, IsPrivate = false);
                        Database.SaveResult result = Database.insert(newAttachment,false);

                        List<EmailMessage> newEmailList = new List<EmailMessage>();

                        list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();
                        for(PropStrength__Application_Booking__c b : bookMap.values()){
                            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage(); 
                            if(!b.PropStrength__Applicant_Details__r.isEmpty()) {
                                List<String> sendTo = new List<String>();
                                List<String> sendCc = new List<String>();
                                for(PropStrength__Applicant_Detail__c appDet : b.PropStrength__Applicant_Details__r) {
                                    if(appDet.PropStrength__Applicant_Email__c != null) {
                                        if(appDet.PropStrength__Type__c == '1st Applicant') {
                                            sendTo.add(appDet.PropStrength__Applicant_Email__c);
                                        } else {
                                            sendCc.add(appDet.PropStrength__Applicant_Email__c);
                                        }
                                    }
                                }
                                if(sendTo.size()>0) {
                                    string bodyStr = 'Dear Customer,\n\nWe are pleased to announce that the unit handover process is starting soon. Kindly be prepared for this important step in your property journey.\n\nAttached herewith the Handover Notice for your perusal.\n\nShould you have any queries or require assistance, please don\'t hesitate to contact us. We are committed to ensuring a smooth handover.\n\n\nBest regards,\n\nSobha Realty';
                                    mail.setSubject('Unit Handover Commencement');
                                    mail.setPlainTextBody(bodyStr);
                                    mail.setToAddresses(sendTo);
                                    mail.setCcAddresses(sendCC);
                                    if (owea.size() > 0) {
                                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                                    }
                                    List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
                        
                                    Blob uploadHandoverLetter;
                                    if(!Test.isRunningTest()){
                                        uploadHandoverLetter = newAttachment.Body;   
                                    } else {
                                        uploadHandoverLetter = Blob.valueOf('UnitHandoverCommencement');
                                    }
                                    
                                    Messaging.EmailFileAttachment attachLetter = new Messaging.EmailFileAttachment();                                
                                    attachLetter.setBody(uploadHandoverLetter);
                                    attachLetter.setFileName(newAttachment.Name);
                                    attachLetter.setContentType(newAttachment.ContentType);
                                    attList.add(attachLetter);
                                    
                                    mail.setFileAttachments(attList);
                                    mails.add(mail);
                                    EmailMessage newEmail = new EmailMessage();
                                    newEmail.ToAddress = sendTo[0];
                                    String ccAddresses;
                                    for(Integer i=0; i < sendCc.size(); i++) {
                                        if(i == sendCc.size()-1) {
                                            ccAddresses = sendCc[i];
                                        } else {
                                            ccAddresses = sendCc[i] + ', ';
                                        }
                                    }
                                    newEmail.CcAddress = ccAddresses;
                                    newEmail.Subject = 'Unit Handover Commencement';
                                    newEmail.TextBody = mail.getPlainTextBody();
                                    newEmail.RelatedToId = parentId;
                                    newEmail.Status = '3';
                                    newEmailList.add(newEmail);
                                }
                            }
                        }
                        if(mails.size()>0){
                            try{
                            Messaging.sendEmail(mails);
                            }
                            catch(exception e){}
                        }
                            
                        PropStrength__Tower__c oneTower = new PropStrength__Tower__c(Id = towerId);
                        if(apexpages.currentpage().getparameters().get('handoverNoticeId') !=null){
                            oneTower.Send_Handover_Notice__c = true;
                            oneTower.Handover_Notice_Sent_Date__c = System.Today();
                        }
                        update oneTower;

                        insert newEmailList;

                        List<Attachment> newAttachmentList = new List<Attachment>();

                        for(EmailMessage em : newEmailList) {
                            newAttachmentList.add(new Attachment(ParentId = em.Id, Name = attachmentName, Body = EncodingUtil.Base64Decode(body), ContentType = contentType, IsPrivate = false));
                        }

                        if(!newAttachmentList.isEmpty()) {
                            insert newAttachmentList;
                        }
                        
                        if(!result.isSuccess()){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,''+result.getErrors()));
                        }else{
                            totalAttachmentInserted++;
                        }
                    }
                }
            }
        }
    }
    public void addAttachemtTwo(Id parentId, String attachmentName, String body, String contentType){   
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        List<PropStrength__Tower__c> towerList = [SELECT Id, (SELECT Id FROM PropStrength__Properties__r) FROM PropStrength__Tower__c WHERE Id = :parentId];
        Set<Id> propId = new Set<Id>();
        Set<Id> bookingId = new Set<Id>();

        if(!towerList.isEmpty() && !towerList[0].PropStrength__Properties__r.isEmpty()) {
            for(PropStrength__Property__c prop: towerList[0].PropStrength__Properties__r) {
                propId.add(prop.Id);
            }

            if(!propId.isEmpty()) {
                Map<Id, PropStrength__Property__c> propMap = new Map<Id, PropStrength__Property__c>([SELECT Id, (SELECT ID FROM PropStrength__Application_Booking__r WHERE PropStrength__Active__c = TRUE ORDER BY CreatedDate DESC LIMIT 1) FROM PropStrength__Property__c WHERE Id IN :propId]);

                if(!propMap.isEmpty()) {
                    for(PropStrength__Property__c prop : propMap.values()) {
                        if(!prop.PropStrength__Application_Booking__r.isEmpty()) {
                            bookingId.add(prop.PropStrength__Application_Booking__r[0].Id);
                        }
                    }
                    if(!bookingId.isEmpty()) {
                        Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id,PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Primary_Customer__c, PropStrength__Property__r.PropStrength__House_Unit_No__c, (SELECT Id, PropStrength__Applicant_Email__c, PropStrength__Customer_Name__c, PropStrength__Type__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE) FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId]);
                        Attachment newAttachment = new Attachment(ParentId = parentId, Name = attachmentName, Body = EncodingUtil.Base64Decode(body), ContentType = contentType, IsPrivate = false);
                        Database.SaveResult result = Database.insert(newAttachment,false);
                        
                        List<EmailMessage> newEmailList = new List<EmailMessage>();
                        Set<Id> updateBookList = new Set<Id>();

                        list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();
                
                        List<EmailTemplate> templatelist = [SELECT id,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Building_Completion_Notice' limit 1];
                        
                        Id TempId;
                        if(!templatelist.isEmpty()) {
                            TempId = templatelist[0].id;
                        }
                        for(PropStrength__Application_Booking__c b : bookMap.values()){
                            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage(); 
                            if(!b.PropStrength__Applicant_Details__r.isEmpty()) {
                                List<String> sendTo = new List<String>();
                                List<String> sendCc = new List<String>();
                                for(PropStrength__Applicant_Detail__c appDet : b.PropStrength__Applicant_Details__r) {
                                    if(appDet.PropStrength__Applicant_Email__c != null) {
                                        if(appDet.PropStrength__Type__c == '1st Applicant') {
                                            sendTo.add(appDet.PropStrength__Applicant_Email__c);
                                        } else {
                                            sendCc.add(appDet.PropStrength__Applicant_Email__c);
                                        }
                                    }
                                }
                                if(sendTo.size()>0) {
                                    //string bodyStr = 'Dear Customer,\n\nWe are delighted to inform you that the construction of your unit at '+b.PropStrength__Property__r.PropStrength__House_Unit_No__c+' is now complete. It is with great pleasure that we share this milestone with you.\n\nYour unit has undergone thorough quality checks, and we are confident that it meets our highest standards. We can\'t wait for you to see the finished result.\n\nIn preparation for the upcoming handover, please ensure all necessary documentation and payments are in order. Our team will be in touch soon to coordinate the handover date and guide you through the process.\n\nIf you have any questions or require further information, do not hesitate to reach out to us. Your satisfaction is our top priority.\n\nThank you for entrusting us with your property investment. We look forward to making your new unit your perfect home.\n\n\nBest regards,\n\nSobha Realty';
                                   // mail.setSubject('Unit Completion Notification');
                                   // mail.setPlainTextBody(bodyStr);
                                    mail.setCcAddresses(new List<String>{'helpdesk@sobharealty.com'});
                                    mail.setBccAddresses(new List<String>{'sfnotifications@sobharealty.com'});
                                    mail.setTemplateId(TempId);
                                    mail.setToAddresses(sendTo);
                                    mail.setCcAddresses(sendCC);
                                    mail.setWhatId(b.id);
                                    mail.setTargetObjectId(b.PropStrength__Primary_Customer__c);
                                    mail.setTreatTargetObjectAsRecipient(False);
                                    if (owea.size() > 0) {
                                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                                    }

                                    
                                    List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
                        
                                    Blob uploadHandoverLetter;
                                    if(!Test.isRunningTest()){
                                        uploadHandoverLetter = newAttachment.Body;   
                                    } else {
                                        uploadHandoverLetter = Blob.valueOf('UnitCompletionNotification');
                                    }
                                    
                                    Messaging.EmailFileAttachment attachLetter = new Messaging.EmailFileAttachment();                                
                                    attachLetter.setBody(uploadHandoverLetter);
                                    attachLetter.setFileName(newAttachment.Name);
                                    attachLetter.setContentType(newAttachment.ContentType);
                                    attList.add(attachLetter);
                                    
                                    mail.setFileAttachments(attList);
                                    mails.add(mail);
                                    
                                    updateBookList.add(b.Id);

                                    EmailMessage newEmail = new EmailMessage();
                                    newEmail.ToAddress = sendTo[0];
                                    String ccAddresses;
                                    for(Integer i=0; i < sendCc.size(); i++) {
                                        if(i == sendCc.size()-1) {
                                            ccAddresses = sendCc[i];
                                        } else {
                                            ccAddresses = sendCc[i] + ', ';
                                        }
                                    }
                                    newEmail.CcAddress = ccAddresses;
                                   // newEmail.Subject = 'Unit Handover Commencement';
                                   // newEmail.TextBody = mail.getPlainTextBody();
                                    newEmail.RelatedToId = parentId;
                                    newEmail.Status = '3';
                                    newEmailList.add(newEmail);
                                }
                            }
                        }
                        if(mails.size()>0){
                            try{
                                PropStrength__Tower__c oneTower = new PropStrength__Tower__c(Id = towerId);
                        if(apexpages.currentpage().getparameters().get('completionNoticeId') !=null){
                            oneTower.Send_Completion_notice__c = true;
                            oneTower.Completion_Notice_Sent_Date__c = System.Today();
                        }
                        update oneTower;
                                if(!updateBookList.isEmpty()) {
                                    UploadHandoverNoticeController.updateBookings(updateBookList);
                                }
                            Messaging.sendEmail(mails);
                                
                            }
                            catch(exception e){}
                        }
                            
                        

                        insert newEmailList;

                        List<Attachment> newAttachmentList = new List<Attachment>();

                        for(EmailMessage em : newEmailList) {
                            newAttachmentList.add(new Attachment(ParentId = em.Id, Name = attachmentName, Body = EncodingUtil.Base64Decode(body), ContentType = contentType, IsPrivate = false));
                        }

                        if(!newAttachmentList.isEmpty()) {
                            insert newAttachmentList;
                        }
                        
                        if(!result.isSuccess()){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,''+result.getErrors()));
                        }else{
                            totalAttachmentInserted++;
                        }
                    }
                }
            }
        }
    }  
    
    @Future(Callout=true)
    public static void updateBookings(Set<Id> bookId) {
        List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
        
        for(Id bId : bookId) {
            updateBookList.add(new PropStrength__Application_Booking__c(Id=bId, Building_Completion_Notice_Sent_Date__c = System.now()));
        }
        
        if(!updateBookList.isEmpty()) {
            update updateBookList;
        }
    }
}