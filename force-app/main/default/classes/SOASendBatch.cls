global without sharing class SOASendBatch implements Schedulable, Database.Batchable<sObject> , Database.Stateful{
    
    global Set<Id> OpportunityId = new Set<Id>();
    
    global void execute(SchedulableContext ctx){
        Id batchJobId = Database.executeBatch(this,1);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime todaysDate = System.Now();
        System.debug('todaysDate - '+todaysDate);
        String query = 'SELECT Id,Name,GL_Date__c,Receipt_Date__c,Mode__c,Booking__r.Primary_Applicant_Email__c,IsSOASend__c,Other_Charges_Type__c,Opportunity__c,Opportunity__r.Name,Credit_Card_Charges__c,Receipt_Status__c,' +
        ' Booking__r.Name,Booking__r.Id,Booking__c,Project_Unit__r.Id,Project_Unit__r.Name,Project_Unit__c,Receipt_Clearance_Date__c FROM Receipt__c WHERE Receipt_Status__c = \'Cleared\' AND Booking__r.Current_Status__c = \'Audit Accepted\' AND ' +
        ' Booking__r.Status__c = \'Processed\' AND Receipt_Clearance_Date__c >= LAST_N_DAYS:4 AND ( (Mode__c != \'Credit Note\') OR (Mode__c = \'Credit Note\' AND Demand__c = null ) ) AND Booking__r.Unit__r.Tower__r.Stop_Automatic_Email__c = false AND IsSOASend__c = false ORDER BY Project_Unit__c DESC ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Receipt__c> receiptList) {
        try {
            Set<String> BookingIds = new Set<String>();

            Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
            System.debug(' owaMap '+owaMap); 
            for(OrgWideEmailAddress owa : [SELECT id,DisplayName, Address FROM OrgWideEmailAddress]){
                owaMap.put(owa.Address,owa);
            }

            for (Receipt__c receipt : receiptList) {
                BookingIds.add(receipt.Booking__c);
            }

            Map<String,String> bookingwithEmail = new Map<String,String>();
            for (Applicant_Details__c app : [SELECT Name,Booking__c, Email_Address__c FROM Applicant_Details__c WHERE Booking__c IN: BookingIds ORDER BY Booking__c]) {
                if(bookingwithEmail.get(app.Booking__c) != null){
                    bookingwithEmail.put(app.Booking__c,bookingwithEmail.get(app.Booking__c)+','+app.Email_Address__c);
                }else{
                    bookingwithEmail.put(app.Booking__c,app.Email_Address__c);
                }
            }

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            List<EmailMessage> EmailMessageList = new List<EmailMessage>();
            Map<String,Blob> blobPDFValueMAP = new Map<String,Blob>();

            for (Receipt__c receipt : receiptList) {
                if(!OpportunityId.contains(receipt.Opportunity__c)){
                    OpportunityId.add(receipt.Opportunity__c);
                    PageReference pref = new PageReference('/apex/N_CustomerSOAPage');
                    pref.getParameters().put('Id', receipt.Opportunity__c);
                    pref.getParameters().put('bookingid', receipt.Booking__c);
                    Blob bodypdf;
                    if(!Test.isRunningTest()){
                        bodypdf = pref.getContent();   
                        blobPDFValueMAP.put(receipt.Booking__c,bodypdf);
                    } else {
                        bodypdf = Blob.valueOf('Sobha Incorrect Email Please Ignore this!....');
                    }                           
                    
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                    attach.setBody(bodypdf);
                    attach.setFileName('SOA.pdf');  
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    List<String> toAddresses = new List<String>();
                    List<String> ccAddress = new List<String>();     
                    String toaddressString;    
                    String ccaddressString;    
                    email.setSubject('SOA for ' + (receipt.Project_Unit__c != null ? receipt.Project_Unit__r.Name : 'Your Register Unit'));
                                
                    String body =  'Dear ' + receipt.Opportunity__r.Name+ ',<br/><br/>' +                        
                                'Greetings, <br/><br/>'+
                                'Please find attached the statement of account (SOA) for your unit. <br/><br/>'+
                                'In case of any query, please drop an email to <a href="'+System.Label.collection_email+'">'+ System.Label.collection_email+'. </a><br/><br/>'+
                                'Best Regards,<br/>Sobha Collection Teams<br/>';
                    
                    if(bookingwithEmail.get(receipt.Booking__c) != null){
                        for(String s : bookingwithEmail.get(receipt.Booking__c).split(',')){
                            if(!s.containsIgnoreCase('null')){
                                toAddresses.add(s);
                            }
                        }
                    }
                    
                    if(receipt.Booking__r.Primary_Applicant_Email__c != null && receipt.Booking__r.Primary_Applicant_Email__c != ''){
                        toAddresses.add(receipt.Booking__r.Primary_Applicant_Email__c);
                    }
                    System.debug(' toAddresses '+toAddresses);                
                    ccAddress.add(System.label.CollectionTeamEmail);
                    ccAddress.add('sfnotifications@sobharealty.com');
                    email.setToAddresses(toAddresses);
                    email.setccAddresses(ccAddress);
                    email.setOrgWideEmailAddressId(owaMap.get(System.Label.collection_email).id);
                    email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});   
                    email.setWhatId(receipt.Booking__c);
                    receipt.IsSOASend__c = true;
                    emails.add(email);
                    toaddressString = String.join(toAddresses,';');
                    ccaddressString = String.join(ccAddress,';');
                }
                
            }

            if(System.label.isAllowToSendBulkSOAEmail == 'Send Email'){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,false);
                update receiptList;
            }
        } catch (Exception e) {
            system.debug('exdebug' + e.getMessage() + '////' + e.getLineNumber());
            Error_Log__c logError = new Error_Log__c(Message__c = e.getMessage());
            logError.class__c = 'SOASendBatch';
            insert logError;
        }
        

    }

    global void finish(Database.BatchableContext BC) {

    }
}