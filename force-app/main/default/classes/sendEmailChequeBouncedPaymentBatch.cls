global class sendEmailChequeBouncedPaymentBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Set<Id> payIds = new Set<Id>(); 
    global Set<Id> bookingIds = new Set<Id>(); 
    
    public sendEmailChequeBouncedPaymentBatch(set<Id> payIds,set<Id> bookingIds) {
        this.payIds = payIds;
        this.bookingIds = bookingIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(!payIds.isEmpty()) {
            return Database.getQueryLocator([SELECT Id,PropStrength__Payment_Date__c,PropStrength__Application_Booking__c,
                                             PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                             PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
                                             PropStrength__Application_Booking__r.PropStrength__Project__c,
                                             PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c, RecordType.Name
                                             FROM PropStrength__Received_Payment__c
                                             WHERE Id IN: payIds AND 
                                             PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c = false AND
                                             PropStrength__Application_Booking__c IN: bookingIds AND
                                             PropStrength__Demand_Email_Sent__c =: true]);
        } else {
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<PropStrength__Received_Payment__c> existingList) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<Attachment> insertList = new List<Attachment>();
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        String fromaddress = '';
        String owdId = '';
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        if(!bookingIds.isEmpty()) {
            for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c 
                                                               FROM PropStrength__Applicant_Detail__c 
                                                               WHERE PropStrength__Application__c IN: bookingIds 
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
        }
        if(!existingList.isEmpty()) {
            for(PropStrength__Received_Payment__c pay : existingList) {
                fromaddress = pay.PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c;
                PageReference pdf;
                if(pay.RecordType.Name == 'Payment Due'){
                    pdf = Page.DemandLetter;
                }else if(pay.RecordType.Name == 'Income Charge Due') {
                   pdf = Page.TransferChargeNotice; 
                }
                
                if (pdf != null) {
                    pdf.getParameters().put('id', pay.Id); // Replace 'id' with the actual parameter name
                }
                Blob b ;
                   if(Test.isRunningTest()){
                       b = blob.valueOf('Unit.Test');
                   }else{
                       b = pdf.getContent();
                   }
                Attachment att = new Attachment();
                att.ParentId = pay.Id;
                att.Name = 'Demand Letter.pdf';
                att.Body = b;
                insertList.add(att);
            }
            if(!insertList.isEmpty()) {
                insert insertList;
                system.debug('insertList::'+insertList);
                for(Attachment oneAtt : insertList) {
                    if(attachmentMap.containskey(oneAtt.ParentId)) {
                        List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                        newPLI.add(oneAtt);
                        attachmentMap.put(oneAtt.ParentId, newPLI);
                    } else {
                        attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                    }
                }
            }
            if(!attachmentMap.isEmpty() && !applicantListMap.isEmpty()) {
                system.debug('attachmentMap::'+attachmentMap);
                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     FROM EmailTemplate 
                                                     WHERE DeveloperName =: 'Cheque_Bounced_Charges_Demand_to_Customer'];
                String tempId = '';
                if(emailTemplate.size() > 0)
                	 tempId = emailTemplate[0].Id;
                for(PropStrength__Received_Payment__c ppd : existingList) {
                    if(applicantListMap.containskey(ppd.PropStrength__Application_Booking__c)){
                        for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.PropStrength__Application_Booking__c)) {
                            if(applicant.PropStrength__Type__c == '1st Applicant') {
                                sendTo.add(applicant.PropStrength__Applicant_Email__c);
                            }
                            if(applicant.PropStrength__Type__c != '1st Applicant') {
                                ccList.add(applicant.PropStrength__Applicant_Email__c);
                            }
                        }
                    }
                }
                if(!String.isBlank(fromaddress)) {
                    List<OrgWideEmailAddress> orgwd = new List<OrgWideEmailAddress>([select id, Address from OrgWideEmailAddress where Address =: fromaddress LIMIT 1]);
                    if(!orgwd.isEmpty()) {
                        owdId = orgwd[0].Id;
                    }
                }
                for(PropStrength__Received_Payment__c ppd : existingList) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(!sendTo.isEmpty()) {
                        email.setToAddresses(sendTo);
                    }
                    if(!ccList.isEmpty()) {
                        email.setCcAddresses(ccList);
                    }
                    if(!String.isBlank(owdId)) {
                        email.setOrgWideEmailAddressId(owdId);
                    }
                    email.setWhatId(ppd.id);
                    email.setTargetObjectId(ppd.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    email.saveAsActivity = true;
                    if(String.isNotBlank(tempId))
                    	email.setTemplateId(tempId);
                    if(attachmentMap.containskey(ppd.Id)){
                        for(Attachment att : attachmentMap.get(ppd.Id)) {
                            if(att.Name == 'Demand Letter.pdf') {
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName('Demand Letter.pdf');
                                efa.setBody(att.Body);
                                efalst.add(efa);
                            }
                            if(!efalst.isEmpty()) {
                                email.setFileAttachments(efalst);
                            }
                        }
                    }
                    mails.add(email); 
                }
                try {
                    if(!mails.isEmpty()){
                        Messaging.sendEmail(mails);
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