global with sharing class AccountBrokerRegFormEmailController {
    global static Id currentId {get;set;}
    public static list<string> mandatoryFileList {get;set;} 
    public static list<String> optionalFiles {get;set;}
    public static String registrationlink {get;set;}
    public static String mailSentDate {get;set;}
    public static String createdDate {get;set;}
    public static String commentstext {get;set;}
    public static Boolean showLinkActiveContent {get;set;}
    public static Boolean isMissingDocument {get;set;}
    
    
    public static Account getrelatedTo() {
        
        Account acc = [SELECT Id, Name,  Owner.Name,Missing_Documents__c, list_of_missing_documents__c, PropStrength__Broker_Approval_Status__c, Broker_Created_Date__c, Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.Name, Comments__c,  Broker_Sub_Type__c, Broker_Category__c, PropStrength__Broker_Type__c FROM Account WHERE Id = :currentId];
        DateTime currentDateTime = DateTime.now();
        mailSentDate =formatDateTime(currentDateTime);
        if(acc.Broker_Created_Date__c!=null){
            createdDate=formatDateTime(acc.Broker_Created_Date__c);  
        }
        showLinkActiveContent = true;
        if(acc.Missing_Documents__c != null) {
            isMissingDocument = true;
        }
        if(acc.list_of_missing_documents__c != null) {
            isMissingDocument = true;
        }
        mandatoryFileList = new list<string>();
        optionalFiles = new list<String>();
        registrationlink = System.Label.BRF_site_Link+'?id='+acc.Id;
        String category = '';
        category  = acc.Broker_Sub_Type__c != null ? category + acc.Broker_Sub_Type__c : category;
        if(!category.contains('Broker')) {
            category  = acc.Broker_Category__c != null ? category +' '+ acc.Broker_Category__c : category;
        }
        if(category != ''){
            getMandatoryFiles(category);    
        }
        
        return acc;
    }
    public static Broker_Renewal__c getrelatedRecordTo() {
        
        Broker_Renewal__c broker = [SELECT Id, Name, Name_as_per_trade_license__c, Missing_Documents__c, list_of_missing_documents__c, Owner.Name, Comments__c,  Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.Name,  CreatedDate, Broker_Sub_Type__c, Broker_Category__c, Broker_Type__c FROM Broker_Renewal__c WHERE Id = :currentId];
        DateTime currentDateTime = DateTime.now();
        mailSentDate =formatDateTime(currentDateTime);
        if(broker.CreatedDate!=null){
            createdDate=formatDateTime(broker.CreatedDate);  
        }
        showLinkActiveContent = true;
        if(broker.Missing_Documents__c != null) {
            isMissingDocument = true;
        }
        if(broker.list_of_missing_documents__c != null) {
            isMissingDocument = true;
        }
        mandatoryFileList = new list<string>();
        optionalFiles = new list<String>();
        registrationlink = System.Label.BRF_site_Link+'?id='+broker.Id;
        String category = '';
        category  = broker.Broker_Sub_Type__c != null ? category + broker.Broker_Sub_Type__c : category;
        if(!category.contains('Broker')) {
            category  = broker.Broker_Category__c != null ? category +' '+ broker.Broker_Category__c : category;
        }        
        if(category != ''){
            getMandatoryFiles(category);    
        }
        
        return broker;
    }

    public static list<String> getMandatoryFiles(String brokerCat) {
        system.debug(brokerCat);
        //list<string> mandatoryFileList = new list<string>();
        List<brokerCategoryMandatoryFiles__mdt> mandatoryFile = [SELECT Id,Label, MasterLabel,MandatoryFiles__c,OptionalFiles__c  FROM brokerCategoryMandatoryFiles__mdt WHERE Label = :brokerCat];
        //mandatoryFileList.addAll(mandatoryFile);
        for(brokerCategoryMandatoryFiles__mdt file: mandatoryFile){
            for(string st : file.MandatoryFiles__c.split(',')){
                mandatoryFileList.add(st);
            }
            // Process Optional Files
            if(file.OptionalFiles__c!=null){
                for (String optFile : file.OptionalFiles__c.split(',')) {
                    optionalFiles.add(optFile);
                }    
            }
            
        }
        
        system.debug(mandatoryFileList);
        
        return mandatoryFileList;
    }  
    public Static String formatDateTime(DateTime dt) {
        return dt.format('dd/MM/yyyy hh:mm a', 'Asia/Dubai');
    }

    
    @InvocableMethod
    public static void emailToCRMExpiryNotification (List<Account> accList) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accListUpdate = new List<Account>();
        for(Account acc : accList) {
            accIds.add(acc.Id);
            accListUpdate.add(new Account(Id =acc.Id, Show_Send_Renewal_Link_Button__c = true));
        }
        if(!accIds.isEmpty()) {
            AccountBrokerRegFormEmailController.sendEmail(accIds);
        }
        if(!accListUpdate.isEmpty()) {
            update accListUpdate;
        }
        
    }
    @Future(callout=true)
    public static void sendEmail(Set<Id> accId) {
        Account acc = [SELECT Id, Name, Al_Siniya_Partner__c, Channel_Relationship_Manager__c, X15_Days_Expire_Notification_Date__c, X30_Days_Expire_Notification_Date__c, X60_Days_Expire_Notification_Date__c, Email_ID_1__c, Mobile_No__c,OwnerId, Channel_Relationship_Manager__r.Email, Channel_Relationship_Manager__r.Name FROM Account WHERE Id IN :accId LIMIT 1]; 
        List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
        String expyDay = acc.X15_Days_Expire_Notification_Date__c == System.today() ? '15 Days' : acc.X30_Days_Expire_Notification_Date__c == System.today() ? '30 Days' : acc.X60_Days_Expire_Notification_Date__c == System.today() ? '60 Days' : '';
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :System.Label.Siniya_Island_Customer_Comm_Email AND IsVerified = true LIMIT 1];  
        List<String> emailAddress = new List<String>();
        Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
        String st = String.valueOf(acc.Channel_Relationship_Manager__r.Email);
        emailAddress.add(st);
        if(acc.Al_Siniya_Partner__c) {
            emails.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        emails.setWhatId(acc.Id);
        emails.setToAddresses(emailAddress);
        emails.setSaveAsActivity(true); 
        emails.setTargetObjectId(acc.OwnerId);
        emails.setTreatTargetObjectAsRecipient(false); 
        emails.setSubject('Renew Broker Account '+ acc.Name );
        emails.setHtmlBody('Dear ' + acc.Channel_Relationship_Manager__r.Name+ ',<br/> <br/> This to inform you that the below mentioned broker is above to Expired in '+expyDay+'.<br/> <br/>'+ 
                          'Account Name - ' + acc.Name + '<br/>' + 'Email -' + acc.Email_ID_1__c + '<br/>' + 'Mobile Number - ' + acc.Mobile_No__c +
                          '<br/> <br/> Account link - '+ URL.getOrgDomainURL().toExternalForm() + '/lightning/r/Account/' + acc.Id+'/view'+ 
                          '<br/> <br/>Renew the broker account. <br/> <br/>Thank you for your attention. <br/><br/> Best regards, <br/><br/> Sobha Reality ');
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