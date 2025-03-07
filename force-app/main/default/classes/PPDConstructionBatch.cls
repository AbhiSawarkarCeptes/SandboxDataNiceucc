global class PPDConstructionBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Set<Id> ppdIds = new Set<Id>(); 
    global Set<Id> payIdset = new Set<Id>(); 
    
    public PPDConstructionBatch(set<Id> ppdIds){
        this.ppdIds = ppdIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(!ppdIds.isEmpty()) {
            return Database.getQueryLocator([SELECT Id,Name,PropStrength__Payment_Due_Date__c,PropStrength__Application_Booking__c,
                                             PropStrength__Application_Booking__r.PropStrength__Project__r.T_link_Demand_Days__c,
                                             PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
                                             PropStrength__Application_Booking__r.PropStrength__Status__c,
                                             PropStrength__Application_Booking__r.PropStrength__Project__c,
                                             PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                             PropStrength__Milestone__r.Milestone_Completion_Approved_On__c,
                                             PropStrength__Application_Booking__r.PropStrength__Project__r.Grace_Days__c,
                                             PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c,
                                             PropStrength__Application_Booking__r.Do_Not_Raise_Demand__c,
                                             PropStrength__Application_Booking__r.PropStrength__Project__r.Do_Not_Raise_Demand__c,
                                             PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Do_Not_Raise_Demand__c
                                             FROM PropStrength__Payment_Plan_Details__c
                                             WHERE Id IN: ppdIds AND
                                             PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c = false AND
                                             PropStrength__Milestone__r.PropStrength__Active__c = true AND
                                             PropStrength__Application_Booking__r.PropStrength__Active__c = true AND
                                             PropStrength__Application_Booking__r.PropStrength__Status__c =: 'Audit Approved' AND
                                             PropStrength__Milestone__r.PropStrength__Is_TimeLinked_Plan__c = false AND
                                             PropStrength__Milestone__r.PropStrength__Milestone_Type__c =:'Construction Linked' AND
                                             PropStrength__Application_Booking__c != null AND
                                             PropStrength__Is_Milestone_Completed__c =: false AND
                                             PropStrength__Approval_Status__c != 'Approved' AND
                                             PropStrength__Payment_Due_Date__c =: Date.today() AND
                                             PropStrength__Milestone__r.Milestone_Completion_Approved_On__c != NULL AND
                                             PropStrength__Milestone__r.PropStrength__Status__c = 'Completed']);
        } else {
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<PropStrength__Payment_Plan_Details__c> scope) {
        system.debug('scope::'+scope);
        Set<Id> ppdIdset = new Set<Id>(); 
        List<PropStrength__Payment_Plan_Details__c> updatePPDList = new List<PropStrength__Payment_Plan_Details__c>();
        List<PropStrength__Received_Payment__c> updatePaymentList = new List<PropStrength__Received_Payment__c>();
        Date budgetDate;
        Decimal rateInterest = 0.00;
        List<Interest_Slab__c> interestSlab = new List<Interest_Slab__c>();
        if(!scope.isEmpty()) {
            for(PropStrength__Payment_Plan_Details__c ppd : scope) {
                if(ppd.PropStrength__Payment_Due_Date__c != null) {
                    budgetDate = ppd.PropStrength__Payment_Due_Date__c;
                }
            }
            if(budgetDate != null) {
                interestSlab = [SELECT Id,Interest__c,Start_Date__c,End_Date__c
                                FROM Interest_Slab__c];
                for(Interest_Slab__c slab : interestSlab) { 
                    if(budgetDate > slab.Start_Date__c && budgetDate < slab.End_Date__c) {
                        rateInterest = slab.Interest__c !=null ? slab.Interest__c :0;
                    }
                }
            }
            for(PropStrength__Payment_Plan_Details__c ppd : scope) {
                if(!(ppd.PropStrength__Application_Booking__r.Do_Not_Raise_Demand__c ||
                    ppd.PropStrength__Application_Booking__r.PropStrength__Project__r.Do_Not_Raise_Demand__c ||
                    ppd.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Do_Not_Raise_Demand__c)) {
                    if(ppd.PropStrength__Payment_Due_Date__c == ppd.PropStrength__Milestone__r.Milestone_Completion_Approved_On__c) {
                        ppd.PropStrength__Is_Milestone_Completed__c = true;
                        //ppd.PropStrength__Rate_of_Interest__c = rateInterest;
                        ppd.PropStrength__Approval_Status__c = 'Approved';
                        ppd.Recurring_Interest_Till_date__c = 0;
                        ppd.Is_Demand_Due__c = TRUE;
                        ppd.PropStrength__Final_Payment_Date__c = ((ppd.PropStrength__Payment_Due_Date__c != null) ? ppd.PropStrength__Payment_Due_Date__c : null)  + 
                            (ppd.PropStrength__Application_Booking__r.PropStrength__Project__r.Grace_Days__c != null ?
                            Integer.valueOf(ppd.PropStrength__Application_Booking__r.PropStrength__Project__r.Grace_Days__c) : 0);
                        updatePPDList.add(ppd);
                    }
                } else if(ppd.PropStrength__Application_Booking__r.Do_Not_Raise_Demand__c ||
                    ppd.PropStrength__Application_Booking__r.PropStrength__Project__r.Do_Not_Raise_Demand__c ||
                    ppd.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Do_Not_Raise_Demand__c) {
                    ppd.Is_Demand_Due__c = TRUE;
                        updatePPDList.add(ppd);
                }
            }
        if(!updatePPDList.isEmpty()) {
            Update updatePPDList;
            system.debug('updatePPDList::'+updatePPDList);
            for(PropStrength__Payment_Plan_Details__c ppd : updatePPDList) {
                if(ppd.PropStrength__Payment_Due_Date__c == ppd.PropStrength__Milestone__r.Milestone_Completion_Approved_On__c) {
                    ppdIdset.add(ppd.Id);
                }
            }
            if(!ppdIdset.isEmpty()) {
                List<PropStrength__Received_Payment__c> paymentList = [SELECT Id,PropStrength__Payment_Date__c,PropStrength__Demand_Email_Sent__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Project__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Project__r.Grace_Days__c
                                                                       FROM PropStrength__Received_Payment__c
                                                                       WHERE PropStrength__Payment_Plan_Detail__c IN: ppdIdset AND
                                                                       PropStrength__Demand_Email_Sent__c =: false AND
                                                                       PropStrength__Application_Booking__r.PropStrength__Project__r.Grace_Days__c != null];
                system.debug('paymentList::'+paymentList);
                if(!paymentList.isEmpty()) {
                    for(PropStrength__Received_Payment__c onePay : paymentList) {
                        if(onePay.PropStrength__Demand_Email_Sent__c == false) {
                            payIdset.add(onePay.Id);
                        }
                    }
                    if(!payIdset.isEmpty()) {
                        sendEmail(payIdset);
                        for(PropStrength__Received_Payment__c onePay : paymentList) {
                            PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c();
                            pay.Id = onePay.Id;
                            pay.PropStrength__Demand_Generation_Date__c = date.today();
                            pay.PropStrength__Demand_Generated__c = true;
                            pay.PropStrength__Demand_Email_Sent__c = true;
                            pay.PropStrength__Demand_Status__c = 'Demand Generated';
                            pay.PropStrength__Actual_Payment_Date__c = (onePay.PropStrength__Payment_Date__c != null ? onePay.PropStrength__Payment_Date__c : null) + 
                                Integer.valueOf(onePay.PropStrength__Application_Booking__r.PropStrength__Project__r.Grace_Days__c);
                            updatePaymentList.add(pay);
                        }
                        if(!updatePaymentList.isEmpty()) {
                            update updatePaymentList;
                            system.debug('updatePaymentList::'+updatePaymentList);
                        }
                    }
                }
            }
        }
    }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public void sendEmail(Set<Id> payIdset) {
        List<PropStrength__Received_Payment__c> updatePaymentList = new List<PropStrength__Received_Payment__c>();
        system.debug('finish::'+payIdset);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<Attachment> insertList = new List<Attachment>();
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
    
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        if(!payIdset.isEmpty()) {
            List<PropStrength__Received_Payment__c> paymentList = [SELECT Id,PropStrength__Payment_Date__c,PropStrength__Application_Booking__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__r.PropStrength__Grace_Days__c
                                                                   FROM PropStrength__Received_Payment__c
                                                                   WHERE Id IN: payIdset AND
                                                                   PropStrength__Demand_Email_Sent__c =: false];
            if(!paymentList.isEmpty()) {
                for(PropStrength__Received_Payment__c pay : paymentList) {
                    bookingIds.add(pay.PropStrength__Application_Booking__c);
                }
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
                if(!applicantListMap.isEmpty()) {
                    for(PropStrength__Received_Payment__c pay : paymentList) {
                        PageReference pdf;
                        pdf =  Page.DemandLetter;
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
                    if(!attachmentMap.isEmpty()) {
                        system.debug('attachmentMap::'+attachmentMap);
                        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                             FROM EmailTemplate 
                                                             WHERE DeveloperName =: 'Demand_Letter_Email'];
                        String tempId = '';
                        if(emailTemplate.Size() > 0)
                        	tempId = emailTemplate[0].Id;
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
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
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            if(!sendTo.isEmpty()) {
                                email.setToAddresses(sendTo);
                            }
                            if(!ccList.isEmpty()) {
                                email.setCcAddresses(ccList);
                            }
                            if (owea.size() > 0) {
                                email.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            email.setWhatId(ppd.id);
                            email.setTargetObjectId(ppd.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                            email.setTreatTargetObjectAsRecipient(False);
                            email.saveAsActivity = true;
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
        }
    }
}