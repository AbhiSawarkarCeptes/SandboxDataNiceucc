public class Broker_Agreement_controller {
    public Account acc {get; set;}
    public String brokerId;
    public String emailSend;
    public String sobhaDesignation {get;set;}
    public String sobhaName {get;set;}
    
    public Broker_Agreement_controller(){
        brokerId = ApexPages.currentPage().getParameters().get('id');
        AuthorisedrepresentativeSOBHAforBrokerDo__mdt  authorisedRepresCM = AuthorisedrepresentativeSOBHAforBrokerDo__mdt.getInstance('Sobha_LLC');
        sobhaDesignation = authorisedRepresCM.Designation__c;
        sobhaName = authorisedRepresCM.Print_name_of_Authorised_Representative__c;
        if(brokerId != null && brokerId != '') {
            acc = [SELECT id, Name,Mobile_No__c, BillingStreet, BillingCity, All_Mandatory_Documents__c,
                   BillingState, BillingCountry, BillingPostalCode,  Email_ID_1__c 
                   FROM Account 
                   WHERE Id = :brokerId];
        }
       
    }
    
    public PageReference backToRecPage(){
        if(brokerId != null && brokerId != ''){
            return new pageReference('/'+brokerId);
        }else {
            return null;            
        }   
    }
    
    public pageReference saveDocFile(){
        if(brokerId != null && brokerId != ''){
            SavePdfAndHtmlToAttachement.doSaveAgreement(brokerId, 'Broker_Agreement');
            return new pageReference('/'+brokerId);
        }    
        return null;
    }
    
    public PageReference saveAndEmail() {
        Set<String> contactEmail = new Set<String>();
        List<Messaging.SingleEmailMessage> emaillist = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
        List<Attachment> att = new List<Attachment>();
        List<EmailTemplate> templatelist;
        Id TempId;
        
        if (brokerId != null) {
            Account account = [SELECT Id, Email_ID_1__c, Email_ID_2__c 
                               FROM Account WHERE Id = :brokerId LIMIT 1];
            String searchTxt = 'Broker_Agreement';
            templatelist = [SELECT Id, Name, DeveloperName 
                            FROM EmailTemplate WHERE DeveloperName = :searchTxt LIMIT 1];
            if (!templatelist.isEmpty()) {
                TempId = templatelist[0].Id;
            }
            
            PageReference p1 = Page.Broker_Agreement;
            String aName = 'Broker_Agreement';
            p1.getParameters().put('id', (String)brokerId); 
            p1.setRedirect(true);
            blob content;
            if (Test.isRunningTest()) {
                content = Blob.valueOf('This is Test');
            } else {
                content = p1.getContentAsPDF(); 
            }
            
            List<Attachment> allAttachment = [SELECT Id, Name 
                                              FROM Attachment WHERE ParentId = :brokerId];
            system.debug('=====allAttachment===='+allAttachment);
            for (Attachment abc : allAttachment) {
                if (abc.Name == 'Broker_Agreement.pdf') {
                    delete abc;
                }
            }
            
            SavePdfAndHtmlToAttachement.doSaveAgreement(brokerId, 'Broker_Agreement');
            
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(aName + '.pdf');
            efa.setBody(content);
            emails.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            emails.setWhatId(brokerId);
            // Check if both Email_ID_1__c and Email_ID_2__c are not blank or null
            if (//!String.isBlank(emailSend) &&
                (account.Email_ID_1__c != null || account.Email_ID_2__c != null)) {
                    List<String> toAddresses = new List<String>();
                    if (account.Email_ID_1__c != null) {
                        toAddresses.add(account.Email_ID_1__c);
                    }
                    if (account.Email_ID_2__c != null) {
                        toAddresses.add(account.Email_ID_2__c);
                    }
                    emails.setToAddresses(toAddresses);
                    List<String> ccList = new List<String>();
                    ccList.add(UserInfo.getUserEmail());
                    emails.setTemplateId(TempId);
                    emails.setCcAddresses(ccList);
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(UserInfo.getUserId());
                    emails.setTreatTargetObjectAsRecipient(false); 
                    emaillist.add(emails);
                    if(!emaillist.isEmpty()){
                        Messaging.sendEmail(emaillist);
                    }
                } else {
                    // Display an error message if either Email_ID_1__c or Email_ID_2__c is blank or null
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Email ID fields must be provided.'));
                }
        } 
        return null;
    }
    
    
}