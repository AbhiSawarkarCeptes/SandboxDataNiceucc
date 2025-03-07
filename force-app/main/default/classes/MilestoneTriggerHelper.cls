public class MilestoneTriggerHelper {
    private static Boolean isRun = true;
    
    public static void updatePPDBudgetedDate(List<PropStrength__Milestone__c> newList, Map<Id, PropStrength__Milestone__c> oldMap) {
        Map<Id, PropStrength__Milestone__c> milestoneMap = new Map<Id, PropStrength__Milestone__c>();
        List<PropStrength__Payment_Plan_Details__c> updateList = new List<PropStrength__Payment_Plan_Details__c>();
        for(PropStrength__Milestone__c mile : newList) {
            if(mile.PropStrength__Status__c == 'Completed' && mile.PropStrength__Active__c &&
               mile.PropStrength__Status__c != oldMap.get(mile.Id).PropStrength__Status__c &&
               mile.Milestone_Completion_Approved_On__c != null &&
               mile.Milestone_Completion_Approved_On__c != oldMap.get(mile.Id).Milestone_Completion_Approved_On__c) {
                milestoneMap.put(mile.Id,mile);
            }
        }
        if(!milestoneMap.isEmpty()) {
            List<PropStrength__Payment_Plan_Details__c> ppdList = [SELECT Id,PropStrength__Payment_Due_Date__c,PropStrength__Milestone__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c
                                                                   FROM PropStrength__Payment_Plan_Details__c
                                                                   WHERE PropStrength__Milestone__c IN: milestoneMap.keySet() AND
                                                                   PropStrength__Application_Booking__r.Do_Not_Raise_Demand__c =: false AND
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__r.Do_Not_Raise_Demand__c =: false AND
                                                                  PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Do_Not_Raise_Demand__c =: false];
            if(!ppdList.isEmpty()) {
                for(PropStrength__Payment_Plan_Details__c ppd : ppdList) {
                    PropStrength__Payment_Plan_Details__c updatePPD = new PropStrength__Payment_Plan_Details__c();
                    updatePPD.Id = ppd.Id;
                    if(milestoneMap.containsKey(ppd.PropStrength__Milestone__c) && milestoneMap.get(ppd.PropStrength__Milestone__c).PropStrength__Actual_Completed_Date__c <= System.Today()) {
                    updatePPD.PropStrength__Payment_Due_Date__c = milestoneMap.get(ppd.PropStrength__Milestone__c).Milestone_Completion_Approved_On__c;
                    }
                    updatePPD.CLP_Milestone_Raised__c = true; //Comment add by deepak sharma don't comment because this line is using in PaymentPlanDetailTriggerHelper > PPDConstructionLink method 
                    updateList.add(updatePPD);
                }
                if(!updateList.isEmpty()) {
                    update updateList;
                }
            }
        }
    }
    
    //Added by deepak sharma on 17 august 2023 to send email to Account executive, DLD executive and audit executive when status is completed and Milestone Completion Approved On is not null
    public static void sendEmailToProjUser(List<PropStrength__Milestone__c> newList, Map<Id, PropStrength__Milestone__c> oldMap) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        Set<String> fromAddress = new Set<String>();
        
        Set<Id> msId = new Set<Id>();
        
        for(PropStrength__Milestone__c ms : newList) {
            if(ms.PropStrength__Project__c != null && ms.PropStrength__Status__c == 'Completed' && ms.Milestone_Completion_Approved_On__c != null && (ms.PropStrength__Status__c != oldMap.get(ms.Id).PropStrength__Status__c || ms.Milestone_Completion_Approved_On__c != oldMap.get(ms.Id).Milestone_Completion_Approved_On__c)) {
                msId.add(ms.Id);
            }
        }
        
        if(!msId.isEmpty()) {
            List<PropStrength__Milestone__c> msList = [SELECT Id, PropStrength__Project__r.Customer_Care_Email_ID__c, PropStrength__Project__r.Accounts_Executive__c, PropStrength__Project__r.DLD_Executive__c, PropStrength__Project__r.Audit_Executive__c, PropStrength__Project__r.Accounts_Executive__r.Email, PropStrength__Project__r.DLD_Executive__r.Email, PropStrength__Project__r.Audit_Executive__r.Email FROM PropStrength__Milestone__c WHERE Id IN :msId];
            for(PropStrength__Milestone__c ms : msList) {
                if(ms.PropStrength__Project__r.Customer_Care_Email_ID__c != null) {
                    fromAddress.add(ms.PropStrength__Project__r.Customer_Care_Email_ID__c);
                }
                if(ms.PropStrength__Project__r.Accounts_Executive__c != null && ms.PropStrength__Project__r.Accounts_Executive__r.Email != null) {
                    sendTo.add(ms.PropStrength__Project__r.Accounts_Executive__r.Email);
                }
                if(ms.PropStrength__Project__r.DLD_Executive__c != null && ms.PropStrength__Project__r.DLD_Executive__r.Email != null) {
                    sendTo.add(ms.PropStrength__Project__r.DLD_Executive__r.Email);
                }
                if(ms.PropStrength__Project__r.Audit_Executive__c != null && ms.PropStrength__Project__r.Audit_Executive__r.Email != null) {
                    sendTo.add(ms.PropStrength__Project__r.Audit_Executive__r.Email);
                }
            }
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName =: 'NotificationtoTeamsonMilestoneCompletion'];
            String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if(!fromAddress.isEmpty()) {
                if(!test.isrunningtest())
                    owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: fromAddress limit 1];
            }
            
            for(PropStrength__Milestone__c ms : msList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(!sendTo.isEmpty()) {
                    email.setToAddresses(sendTo);
                }
                if(owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                System.debug(ms.Id);
                email.setWhatId(ms.Id);
                email.setTargetObjectId(ms.PropStrength__Project__r.Audit_Executive__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.saveAsActivity = true;
                email.setTemplateId(tempId);
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
    
    public static boolean runOnce(){
        if(isRun){
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }
}