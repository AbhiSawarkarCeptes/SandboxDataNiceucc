public class SendHandoverNotificationCntrl {
    public String recId;
    public String objectName = null;
    public Boolean isError {get;set;}
    public Boolean showBtn {get;set;}

    public SendHandoverNotificationCntrl() {
        recId = ApexPages.currentPage().getParameters().get('id'); 
        isError = false;
        showBtn = false;
        if(recId != null && recId != '' && recId.length() >= 15 && recId.length() <= 18) {
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            for (String objName : globalDescribe.keySet()) {
                if(objName.containsIgnoreCase('propstrength')) {
                    Schema.SObjectType objectType = globalDescribe.get(objName);
                    Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
                    String keyPrefix = objDescribe.getKeyPrefix();
                    if (keyPrefix != null && keyPrefix.startsWith(recId.substring(0,3))) {
                        objectName = objName;
                        break;
                    }
                }
            }

            if(objectName == null || (objectName != 'propstrength__tower__c' && objectName != 'propstrength__application_booking__c')) {
                isError = true;
                showBtn = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please Enter Record Id of either Application/Booking Or Tower Object');
                ApexPages.addMessage(myMsg);
            }
        } else {
            isError = true;
            showBtn = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please Enter valid Record Id');
            ApexPages.addMessage(myMsg);
        }
    }

    public void sendLetter() {
        if(objectName == 'propstrength__tower__c') {
            List<PropStrength__Tower__c> towerList = [SELECT Id, (SELECT Id FROM PropStrength__Properties__r) FROM PropStrength__Tower__c WHERE Id = :recId AND PropStrength__Completion_Certificate_Date__c = null AND PropStrength__Completion_Certificate_Received__c = false];

            if(!towerList.isEmpty()) {
                PropStrength__Tower__c tower = towerList[0];
                if(!tower.PropStrength__Properties__r.isEmpty()) {
                    List<PropStrength__Property__c> propList = [SELECT Id, 
                                                                (SELECT Id FROM PropStrength__Application_Booking__r 
                                                                WHERE PropStrength__Active__c = TRUE ORDER BY CreatedDate DESC) 
                                                                FROM PropStrength__Property__c WHERE Id IN :tower.PropStrength__Properties__r 
                                                                AND PropStrength__Completion_Certificate_Date__c = null AND PropStrength__Completion_Certificate_Received__c = false];

                    if(!propList.isEmpty()) {
                        Map<Id, Id> propBookMap = new Map<Id, Id>();

                        for(PropStrength__Property__c property : propList) {
                            if(!property.PropStrength__Application_Booking__r.isEmpty()) {
                                propBookMap.put(property.Id, property.PropStrength__Application_Booking__r[0].Id);
                            }
                        }

                        if(!propBookMap.isEmpty()) {
                            List<PropStrength__Application_Booking__c> bookingList = [SELECT Id, PropStrength__Property__c  
                                                                                    FROM PropStrength__Application_Booking__c WHERE Id IN :propBookMap.values() AND PropStrength__Completion_Certificate_Date__c = null 
                                                                                    AND PropStrength__Completion_Certificate_Received__c = false];

                            if(!bookingList.isEmpty()) {
                                List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
                                List<PropStrength__Property__c> updatePropertyList = new List<PropStrength__Property__c>();

                                for(PropStrength__Application_Booking__c booking : bookingList) {
                                    SendHandoverNotificationCntrl.sendMailToCustomer(booking.Id);
                                    updateBookList.add(new PropStrength__Application_Booking__c(Id=booking.Id, PropStrength__Completion_Certificate_Received__c= true, PropStrength__Completion_Certificate_Date__c = System.Today()));
                                    updatePropertyList.add(new PropStrength__Property__c(Id=booking.PropStrength__Property__c, PropStrength__Completion_Certificate_Received__c= true, PropStrength__Completion_Certificate_Date__c = System.Today()));
                                }

                                PropStrength__Tower__c tow = new PropStrength__Tower__c(Id=recId, PropStrength__Completion_Certificate_Date__c = System.Today(), PropStrength__Completion_Certificate_Received__c = true);
                                update tow;

                                if(!updateBookList.isEmpty()) {
                                    update updateBookList;
                                }
                                if(!updatePropertyList.isEmpty()) {
                                    update updatePropertyList;
                                }

                                isError = true;
                                showBtn = true;
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Completion Certifcate sent');
                                ApexPages.addMessage(myMsg);
                            } else {
                                isError = true;
                                showBtn = true;
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Completion Certifcate already sent');
                                ApexPages.addMessage(myMsg);
                            }
                        }
                    } else {
                        isError = true;
                        showBtn = true;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Completion Certifcate already sent');
                        ApexPages.addMessage(myMsg);
                    }
                }
            } else {
                isError = true;
                showBtn = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Completion Certifcate already sent');
                ApexPages.addMessage(myMsg);
            }
        } else if(objectName == 'propstrength__application_booking__c') {
            List<PropStrength__Application_Booking__c> bookingList = [SELECT Id, PropStrength__Property__c  
                                                                    FROM PropStrength__Application_Booking__c WHERE Id = :recId AND PropStrength__Completion_Certificate_Date__c = null 
                                                                    AND PropStrength__Completion_Certificate_Received__c = false];
            if(!bookingList.isEmpty()) {
                SendHandoverNotificationCntrl.sendMailToCustomer(recId);

                PropStrength__Application_Booking__c updBook = new PropStrength__Application_Booking__c(Id=recId, PropStrength__Completion_Certificate_Received__c= true, PropStrength__Completion_Certificate_Date__c = System.Today());
                update updBook;

                PropStrength__Property__c updProp = new PropStrength__Property__c(Id=bookingList[0].PropStrength__Property__c, PropStrength__Completion_Certificate_Received__c= true, PropStrength__Completion_Certificate_Date__c = System.Today());
                update updProp;

                isError = true;
                showBtn = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Completion Certifcate sent');
                ApexPages.addMessage(myMsg);
            } else {
                isError = true;
                showBtn = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Completion Certifcate already sent');
                ApexPages.addMessage(myMsg);
            }
        }
    }

    public PageReference cancelLetter() {
        return new PageReference('/'+recId);   
    }

    @Future(Callout=true)
    public static void sendMailToCustomer(String bookId) {
        if(bookId != null) {
            PropStrength__Application_Booking__c book = [SELECT Id, PropStrength__Primary_Customer__c, 
                                                        (SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE)  
                                                        FROM PropStrength__Application_Booking__c WHERE Id = :bookId];

            List<String> toAddList = new List<String>();
            for(PropStrength__Applicant_Detail__c appDet : book.PropStrength__Applicant_Details__r) {
                toAddList.add(appDet.PropStrength__Applicant_Email__c);
            }

            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

                
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();

            if(!toAddList.isEmpty()) {
                String TempId;
                String searchTxt = 'CompletionCertificate';
                List<EmailTemplate> templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
                if(!templatelist.isEmpty()) {
                    TempId = templatelist[0].id;
                }
                PageReference p1 =  Page.CompletionCertificate;
                String aName = 'CompletionCertificate';
                p1.getParameters().put('id',(String)bookId); 
                p1.setRedirect(true);
                blob content;
                if(test.IsRunningTest())
                    content= Blob.valueOf('This is Test');    
                else
                    content= p1.getContentAsPDF(); 
                
                System.debug(p1);
                
                List<Attachment> allAttachment = new List<Attachment>();
                allAttachment = [SELECT Id, Name FROM Attachment WHERE parentid =: bookId];
                for(Attachment abc : allAttachment){
                    if(abc.Name == 'CompletionCertificate.pdf'){
                        delete abc;
                    }
                }
                
                SavePdfAndHtmlToAttachement.doSaveReceipt(bookId, 'CompletionCertificate');
                
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(aName+'.pdf');
                efa.setBody(content);
                emails.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                emails.setWhatId(bookId);
                emails.setToAddresses(toAddList); 
                emails.setTemplateId(TempId);
                emails.setSaveAsActivity(true); 
                emails.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                emails.setTreatTargetObjectAsRecipient(false); 
                if (owea.size() > 0) {
                    emails.setOrgWideEmailAddressId(owea.get(0).Id);
                }

                emaillist.add(emails);
                try{
                    if(emaillist != null && emaillist.size()>0 ) {
                        Messaging.sendEmail(emaillist);
                    }
                } catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }
        }
    }
}