public class SPALetterController {
    public boolean displayPopup {get; set;} 
    public String toEmail {get;set;}
    public String ccEmail {get;set;}
    public List<Attachment> attachmentList{get;set;}
    public String transIds = null; 
    public String msg {get;set;}
    public Boolean showButton {get;set;}
    public String framesrc {get; set;}
    public List<PropStrength__Transaction_Requests__c> transactionRequestList {get;set;}
    //public String email1{get;set;}
    //public String email2{get;set;}
    
    public SPALetterController() {
        transIds = ApexPages.currentPage().getParameters().get('Id');
        msg = '';
        //email1 = '';
        //email2 = '';
        showButton = false;
        transMethod();
    }
    
    public void transMethod() {
        if(!String.isBlank(transIds)) {
            transactionRequestList = [SELECT Id,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,PropStrength__Application_Booking__r.POA_Email_Address__c,
                                      PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c
                                      FROM PropStrength__Transaction_Requests__c 
                                      WHERE Id =: transIds 
                                      AND RecordType.Name =: 'SPA Process' 
                                      AND PropStrength__Application_Booking__r.SPA_Executed__c =: false
                                      AND PropStrength__Application_Booking__r.SPA_Execution_Date__c =: null
                                      AND SPA_Created__c = false];
            if(transactionRequestList.isEmpty()) {
                showButton = false;
                msg = 'SPA Already Generated.';
            } else {
                showButton = true;
                if(transIds != null && transIds != '') {
                    framesrc = '/apex/SPA_Light?id='+transIds;
                } 
            }
        }
    }
    
    public void EmailSPALetter() { 
        if(!transactionRequestList.isEmpty()) {
            //OrgWideEmailAddress owea = new OrgWideEmailAddress();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if(!test.isRunningTest())
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c limit 1];
            System.debug(ccEmail+'--test---'+toEmail);
            String url = '/apex/SPALetter?Id=' + transIds;
            PageReference rateProfile = new PageReference(url);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment(); //create attachment
            attachment.setFileName('SPA Letter.pdf');
            if(!test.isRunningTest())
                attachment.setBody(rateProfile.getContentAsPDF());
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
            if(!test.isRunningTest())
                message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
            message.setSubject('SPA Letter');
            message.setHTMLBody('Hi Letter HERE'); 
            if(String.isNotBlank(toEmail))
                message.setToAddresses( toEmail.split(',')  );
            //if(owea != null && owea.size() > 0)
            //  message.setOrgWideEmailAddressId(owea[0].Id);
            if(String.isNotBlank(ccEmail))
                message.setCcAddresses(ccEmail.split(',')); 
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
            closePopup();
        }
    }
    
    Public pageReference SaveAndEmailPdf() {
        if(!transactionRequestList.isEmpty()) {
            System.debug('transactionRequestList::' + transactionRequestList);
            List<Attachment> insertList = new List<Attachment>();
            List<PropStrength__Transaction_Requests__c> updateTranList = new List<PropStrength__Transaction_Requests__c>();
            Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
            for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                               FROM PropStrength__Applicant_Detail__c 
                                                               WHERE PropStrength__Application__c =: transactionRequestList[0].PropStrength__Application_Booking__c 
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
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                 owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c limit 1];
            system.debug('*****owea****'+owea);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            PageReference pdf;
            pdf =  Page.SPALetter;
            pdf.getParameters().put('id',(String)transactionRequestList[0].id); 
            pdf.setRedirect(true);
            Blob b ;
            if(!Test.isRunningTest())
                b= pdf.getContent();
            else
                b= blob.valueOf('Unit.Test');
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('SPA Letter.pdf');
            efa.setBody(b); 
            // Create the email attachment
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            String addresses;
            List<String> sendTo = new List<String>();
            List<String> ccList = new List<String>();
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                             FROM EmailTemplate 
                                                             WHERE DeveloperName =: 'SPA_for_Digi_Sign'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            for(PropStrength__Transaction_Requests__c ppd : transactionRequestList) {
                if(ppd.PropStrength__Application_Booking__r.POA_Email_Address__c == null && applicantListMap.containskey(ppd.PropStrength__Application_Booking__c)){
                    for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.PropStrength__Application_Booking__c)) {
                        if(applicant.PropStrength__Type__c == '1st Applicant') {
                            sendTo.add(applicant.PropStrength__Applicant_Email__c);
                        }
                        if(applicant.PropStrength__Type__c != '1st Applicant') {
                            ccList.add(applicant.PropStrength__Applicant_Email__c);
                        }
                    }
                } else {
                    sendTo.add(ppd.PropStrength__Application_Booking__r.POA_Email_Address__c);
                }
            }
            if(sendTo != null && sendTo.size() >0) {
                email.setToAddresses(sendTo);
            }
            email.setWhatId(transactionRequestList[0].id);
            email.setTargetObjectId(transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
            email.setTreatTargetObjectAsRecipient(False);
            email.saveAsActivity = true;
            if(ccList != null && ccList.size() >0) {
                email.setCcAddresses(ccList);
            } 
            
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            email.setTemplateId(tempId);
            mails.add(email);
            system.debug(mails+'************');
            
            if(!Test.isRunningTest())
                System.debug('goooooooooo');
            try{
                Messaging.sendEmail(mails);
                msg = 'Email Send Successfully.';
                for(PropStrength__Transaction_Requests__c tran : transactionRequestList) {
                    Attachment att = new Attachment();
                    att.ParentId = tran.Id;
                    att.Name = 'SPA Letter.pdf';
                    att.Body = b;
                    insertList.add(att);
                    
                    PropStrength__Transaction_Requests__c trans = new PropStrength__Transaction_Requests__c();
                    trans.Id = tran.Id;
                    trans.SPA_Created__c  = true;
                    trans.SPA_Sent_to_Customer_for_Digi_Sign__c  = true;
                    trans.PropStrength__Status__c = 'SPA Sent to Customer for Digital Signature';
                    trans.SPA_Sent_to_Customer_for_Digi_Sign_Date__c = System.Now();
                    updateTranList.add(trans);
                }
                if(!insertList.isEmpty()) {
                    insert insertList;
                    system.debug('insertList::'+insertList);
                }
                if(!updateTranList.isEmpty()) {
                    update updateTranList;
                    system.debug('updateTranList::'+updateTranList);
                }
            }catch (exception ex){
                msg = String.valueOf(ex.getMessage());
            }
            return new pageReference('/'+transIds);
        }
        //email1 = '';
        //email2 = '';
        return null;
    }
    
    public pagereference docancel(){
        return new pageReference('/'+transIds);
    }
    
    public String getChooserender() {
        System.debug('View*-*-*- ' + ApexPages.currentPage().getParameters().get('view'));
        if (ApexPages.currentPage().getParameters().get('view') != null){
            System.debug('html*-*-*-');
            return null;
        }        
        else {
            System.debug('pdf*-*-*-');
            return 'pdf';
        }
    }
    
    public void showPopup() { 
        displayPopup = true;     
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }    
}