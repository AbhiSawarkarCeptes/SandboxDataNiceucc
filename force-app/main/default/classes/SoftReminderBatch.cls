global class SoftReminderBatch  implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  'SELECT Id, Soft_Reminder_Date_Timelinked__c, Soft_Reminder_Sent__c,PropStrength__Application_Booking__c,'+
            'PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,' +
            'PropStrength__Application_Booking__r.PropStrength__Project__c,' +
            'PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c,' +
            'PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email ' +
            'FROM PropStrength__Payment_Plan_Details__c '+
            'WHERE PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c = false AND PropStrength__Is_Milestone_Completed__c = false AND Do_Not_Raise_Demand__c = FALSE AND '+
            'PropStrength__Approval_Status__c != \'Approved\' AND PropStrength__Milestone__r.PropStrength__Milestone_Type__c = \'Time Linked\' AND '+
            'PropStrength__Milestone__r.PropStrength__Is_TimeLinked_Plan__c = true AND '+
            'Soft_Reminder_Date_Timelinked__c = TODAY AND Soft_Reminder_Sent__c = false AND ' +
            'PropStrength__Application_Booking__r.Do_Not_Send_Reminder__c = false AND ' +
            'PropStrength__Application_Booking__r.PropStrength__Project__r.Do_Not_Send_Reminder__c = false';
        system.debug('query::'+query);
        if(!String.isBlank(query)) {
            return Database.getQueryLocator(query);
        } else {
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<PropStrength__Payment_Plan_Details__c> scope) {
        system.debug('scope::'+scope);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String tempId = '';
        List<String> sendTo = new List<String>(); 
        set<Id> towerIds = new set<Id>();
        map<Id,Id> projectMap = new map<Id,Id>();
        List<String> ccList = new List<String>(); 
        Set<Id> bookingIds = new Set<Id>(); 
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
    
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        for(PropStrength__Payment_Plan_Details__c ppd : scope) {
            towerIds.add(ppd.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c);
        }
        if(!towerIds.isEmpty()) {
            for(PropStrength__Tower__c tower : [SELECT Id,PropStrength__Project_Name__c,Do_Not_Send_Reminder__c
                                                FROM PropStrength__Tower__c 
                                                WHERE Do_Not_Send_Reminder__c =: false AND
                                                Id IN: towerIds]) {
                                                    projectMap.put(tower.PropStrength__Project_Name__c,tower.PropStrength__Project_Name__c);
                                                }
        }
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                             FROM EmailTemplate 
                                             WHERE DeveloperName =: 'Soft_Reminder'];
        system.debug('emailTemplate::'+emailTemplate);
        if(!emailTemplate.isEmpty()) {
            tempId = emailTemplate[0].Id;
        }
        if(!projectMap.isEmpty()) {
            for(PropStrength__Payment_Plan_Details__c payment : scope) {
                bookingIds.add(payment.PropStrength__Application_Booking__c);
            }
            if(!bookingIds.isEmpty()) {
                for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,
                                                                   PropStrength__Application__c 
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
                for(PropStrength__Payment_Plan_Details__c ppd : scope) {
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
                for(PropStrength__Payment_Plan_Details__c payment : scope) {
                    if(projectMap.containsKey(payment.PropStrength__Application_Booking__r.PropStrength__Project__c)) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(!sendTo.isEmpty()) {
                            email.setToAddresses(sendTo);
                        }
                        if(!ccList.isEmpty()) {
                            email.setCcAddresses(ccList);
                        }
                        email.setWhatId(payment.id);
                        email.setTargetObjectId(payment.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                        email.setTreatTargetObjectAsRecipient(False);
                        email.saveAsActivity = true;
                        email.setTemplateId(tempId);
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        mails.add(email); 
                    }
                }
                try {
                    if(!mails.isEmpty()) {
                        Messaging.sendEmail(mails);
                        List<PropStrength__Payment_Plan_Details__c> updateList = new List<PropStrength__Payment_Plan_Details__c>();
                        for(PropStrength__Payment_Plan_Details__c payment : scope) {
                            if(projectMap.containsKey(payment.PropStrength__Application_Booking__r.PropStrength__Project__c)) {
                                PropStrength__Payment_Plan_Details__c pay = new PropStrength__Payment_Plan_Details__c();
                                pay.Id = payment.Id;
                                pay.Soft_Reminder_Sent__c = true;
                                updateList.add(pay);
                            }
                        }
                        if(!updateList.isEmpty()) {
                            Update updateList;
                            system.debug('updateList::'+updateList);
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