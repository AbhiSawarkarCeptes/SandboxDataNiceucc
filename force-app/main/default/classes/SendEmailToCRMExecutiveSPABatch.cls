global class SendEmailToCRMExecutiveSPABatch implements Database.Batchable<sObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, PropStrength__Total_Paid_Percent__c,PropStrength__Active__c,PropStrength__Property__c,'+
            		   'PropStrength__Primary_Customer__c,PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c,' +
            		   'PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email,PropStrength__Project__r.Customer_Care_Email_ID__c '+
            		   'FROM PropStrength__Application_Booking__c ' +
            		   'WHERE Notification_to_CRM_Executive_for_SPA__c = false AND ( (SPA_Transaction_Exception__c = TRUE) OR (PropStrength__Total_Paid_Percent__c >= 9.5 AND PropStrength__Active__c = true AND ' +
            		   ' PropStrength__Status__c = \'Audit Approved\' AND PropStrength__Property__r.RecordType.Name != \'Plots\' AND '+
                       'PropStrength__Property__r.Floor_Plan_Uploaded__c != null AND PropStrength__Property__r.Unit_Plan_Uploaded__c != null AND PropStrength__Property__r.Area_Confirmation_by_Sales_Ops_Date__c != null AND '+
                       'PropStrength__Property__r.Material_Specification_Uploaded__c != null AND PropStrength__Property__r.District_Plan_Uploaded__c != null AND PropStrength__Project__r.RERA_Registered__c = TRUE AND Pre_Registration_Completed__c = TRUE))';
        System.debug('query--> '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<PropStrength__Application_Booking__c> scope) {
        system.debug('scope::'+scope);
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        set<String> emailAddress = new set<String>(); 
        String tempId = '';
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>();
        if(!scope.isEmpty()) {
            for(PropStrength__Application_Booking__c book : scope) {
                bookingIds.add(book.Id);
            }
            if(!scope.isEmpty()) {
                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     FROM EmailTemplate 
                                                     WHERE DeveloperName =: 'Eligible_for_SPA'];
                if(emailTemplate.size() >0 )
               		 tempId  =  emailTemplate[0].Id;
                for(PropStrength__Application_Booking__c book : scope) {
                    if(book.PropStrength__Project__r.Customer_Care_Email_ID__c != null) {
                       emailAddress.add(book.PropStrength__Project__r.Customer_Care_Email_ID__c); 
                    }
                    if(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__c != null) {
                        sendTo.add(book.PropStrength__Property__r.PropStrength__Tower__r.CRM_Executive__r.Email);
                    }
                }
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                if( !test.isrunningtest())
                    owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: emailAddress limit 1];

                for(PropStrength__Application_Booking__c book : scope) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(!sendTo.isEmpty()) {
                        email.setToAddresses(sendTo);
                    }
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    email.setWhatId(book.id);
                    email.setTargetObjectId(book.PropStrength__Primary_Customer__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.saveAsActivity = true;
                    if(String.isNotBlank(tempId))
                    	email.setTemplateId(tempId);
                    system.debug('sendTo::'+sendTo);
                    system.debug('book.PropStrength__Primary_Customer__c::'+book.PropStrength__Primary_Customer__c);
                    /*if(attachmentMap.containskey(book.Id)){
                        for(Attachment att : attachmentMap.get(book.Id)) {
                            if(att.Name == 'Mou Letter.pdf') {
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName('Mou Letter.pdf');
                                efa.setBody(att.Body);
                                efalst.add(efa);
                            }
                            if(!efalst.isEmpty()) {
                                email.setFileAttachments(efalst);
                            }
                        }
                    }*/
                    mails.add(email); 
                }
                try {
                    if(!mails.isEmpty()){
                        Messaging.sendEmail(mails);
                        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
                        for(PropStrength__Application_Booking__c book : scope) {
                            PropStrength__Application_Booking__c oneBook = new PropStrength__Application_Booking__c();
                            oneBook.Id = book.Id;
                            oneBook.Notification_to_CRM_Executive_for_SPA__c = true;
                            oneBook.Notification_Sent_Date_to_CRM_for_SPA__c = Date.today();
                            bookingList.add(oneBook);
                            trList.add(new PropStrength__Transaction_Requests__c(RecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id));
                        }
                        if(!bookingList.isEmpty()) {
                            update bookingList;
                            insert trList;
                        }
                    }
                } catch(Exception e){
                    System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                    System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}