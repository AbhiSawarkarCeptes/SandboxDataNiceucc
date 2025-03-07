/*********************************************************************
* Class Name  :   IncentivePayoutTriggerHelper
* Description :   Helper Class of IncentivePayoutTrigger
* Created Date:   23/01/2024
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Nishank Manwani
Last Modified By :   Nishank Manwani 23/01/2024
*********************************************************************/
public class IncentivePayoutTriggerHelper {
    //Added By Nishank Manwani on 23-Jan-2024 to calculate Balance Amount after Incentive Paid Record get created
    public static void calculateBalance(List<Incentive_Payouts__c> incPayList) {
        Id incentivePaidRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Paid').getRecordTypeId();
        List<Incentive_Payouts__c> ipRecDue = [SELECT Id, Commission_Paid__c, User_Role__c, Payable_To__c, Amount__c FROM Incentive_Payouts__c WHERE RecordType.Name = 'Incentive Due'];
        Map<String, Decimal> payToAmtMap = new Map<String, Decimal>();
        
        for(Incentive_Payouts__c ipPaid : incPayList) {
            if(ipPaid.RecordTypeId == incentivePaidRecTypeId) {
                if(ipPaid.Payable_To__c != null) {
                    Decimal amt = ipPaid.Amount__c;
                    if(payToAmtMap.containsKey(ipPaid.Payable_To__c)) {
                        amt += payToAmtMap.get(ipPaid.Payable_To__c);
                        payToAmtMap.remove(ipPaid.Payable_To__c);
                        
                    }
                    payToAmtMap.put(ipPaid.Payable_To__c, amt);
                } else if(ipPaid.User_Role__c != null) {
                    Decimal amt = ipPaid.Amount__c;
                    if(payToAmtMap.containsKey(ipPaid.User_Role__c)) {
                        amt += payToAmtMap.get(ipPaid.User_Role__c);
                        payToAmtMap.remove(ipPaid.User_Role__c);
                    }
                    payToAmtMap.put(ipPaid.User_Role__c, amt);
                }
            }
        }
        for(Incentive_Payouts__c ipDue : ipRecDue) {
            if(ipDue.Payable_To__c != null) {
                if(payToAmtMap.containsKey(ipDue.Payable_To__c)) {
                    if(ipDue.Commission_Paid__c != null && ipDue.Commission_Paid__c > 0) {
                        ipDue.Commission_Paid__c += payToAmtMap.get(ipDue.Payable_To__c);
                    } else {
                        ipDue.Commission_Paid__c = payToAmtMap.get(ipDue.Payable_To__c);
                    }
                    ipDue.Balance__c = ipDue.Amount__c - ipDue.Commission_Paid__c;
                }
            } else if(ipDue.User_Role__c != null) {
                if(payToAmtMap.containsKey(ipDue.User_Role__c)) {
                    if(ipDue.Commission_Paid__c != null && ipDue.Commission_Paid__c > 0) {
                        ipDue.Commission_Paid__c += payToAmtMap.get(ipDue.User_Role__c);
                    } else {
                        ipDue.Commission_Paid__c = payToAmtMap.get(ipDue.User_Role__c);
                    }
                    ipDue.Balance__c = ipDue.Amount__c - ipDue.Commission_Paid__c;
                }
            }
        }
        
        update ipRecDue;
    }
    // Added By Gourav Gour 14/05/2024
    public static void verifiedPayableUser(List<Incentive_Payouts__c> incPayList) {
        Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();
        Set<Id> userId = new Set<Id>();
        for(Incentive_Payouts__c rec : incPayList) {
            if(rec.RecordTypeId == incentiveDueRecTypeId && rec.Payable_To__c != null) {
                userId.add(rec.Payable_To__c);
            }
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Deactivated_Date__c FROM User WHERE Id IN :userId]);
        List<String> userRoleToCheck = new List<String>{'Sales Head', 'Sales Director', 'VP Sales', 'CSO Sales'};
            for(Incentive_Payouts__c rec : incPayList) {
                if(rec.RecordTypeId == incentiveDueRecTypeId && rec.Payable_To__c != null 
                   && userMap.containsKey(rec.Payable_To__c) && userMap.get(rec.Payable_To__c).Deactivated_Date__c != null 
                   && userMap.get(rec.Payable_To__c).Deactivated_Date__c.date().daysBetween(System.Today()) >= 40 && rec.User_Role__c != null && userRoleToCheck.contains(rec.User_Role__c)) {
                       rec.Payable_To__c = null;
                   }
            }
    }
    
    //Added By Gourav Gour on 10-May-2024 to send Incentive payouts for Approval
    public static void sendForApproval(List<Incentive_Payouts__c> incPayList, Map<Id, Incentive_Payouts__c> incOldMap) {
        Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();
        Set<Id> recIdForProcess_1 = new Set<Id>();
        Set<Id> recIdForProcess_2 = new Set<Id>();
        Set<Id> recIdForProcess_3 = new Set<Id>();
        for(Incentive_Payouts__c rec : incPayList) {
            if(incOldMap == null && rec.RecordTypeId == incentiveDueRecTypeId && (rec.Approval_Status__c == null || rec.Approval_Status__c.contains('Rejected by Audit'))) {
                recIdForProcess_1.add(rec.Id);
            }
            if(incOldMap != null && rec.RecordTypeId == incentiveDueRecTypeId && rec.Approval_Status__c == 'Rejected by Audit' && rec.Approval_Status__c != incOldMap.get(rec.Id).Approval_Status__c) {
                recIdForProcess_2.add(rec.Id);
            }
            if(incOldMap != null && rec.RecordTypeId == incentiveDueRecTypeId && rec.Approval_Status__c == 'Rejected by Payroll Team' && rec.Approval_Status__c != incOldMap.get(rec.Id).Approval_Status__c) {
                recIdForProcess_3.add(rec.Id);
            }
        }
        for(Id recId : recIdForProcess_1) {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Incentive Payouts: Approval Process On Insert');
            req1.setObjectId(recId);
            req1.setSubmitterId(UserInfo.getUserId());
            req1.setProcessDefinitionNameOrId('Inventive_Approval_Process');
            req1.setSkipEntryCriteria(false);  
            // Approval.ProcessResult result = Approval.process(req1); // commented by Gourav Gour 10/06/2024
        }
        if(!recIdForProcess_2.isEmpty()) {
            // IncentivePayoutTriggerHelper.sendForApprovalProcess(recIdForProcess_2, null); // commented by Gourav Gour 10/06/2024
        }
        if(!recIdForProcess_3.isEmpty()) {
            // IncentivePayoutTriggerHelper.sendForApprovalProcess(null, recIdForProcess_3); // commented by Gourav Gour 10/06/2024
        }
        
    }
    @Future(callout=true)
    public static void sendForApprovalProcess(Set<Id> incRecIds_1, Set<Id> incRecIds_2) {
        if(incRecIds_1 != null) {
            for(Id recId : incRecIds_1) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Incentive Payouts: Approval Process On Insert');
                req1.setObjectId(recId);
                req1.setSubmitterId(UserInfo.getUserId());
                req1.setProcessDefinitionNameOrId('Inventive_Approval_Process');
                req1.setSkipEntryCriteria(false);  
                Approval.ProcessResult result = Approval.process(req1);
            }
        }
        if(incRecIds_2 != null) {
            for(Id recId : incRecIds_2) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Incentive Payouts: Approval Process On Update');
                req1.setObjectId(recId);
                req1.setSubmitterId(UserInfo.getUserId());
                req1.setProcessDefinitionNameOrId('Inventive_Approval_Process_2');
                req1.setSkipEntryCriteria(false);  
                Approval.ProcessResult result = Approval.process(req1);
            }
        }
    }
    
   /* public static void updateNotEligiblePayouts(List<Incentive_Payouts__c> newList, Map<Id,Incentive_Payouts__c> oldMap){
        Set<Id> userIds = new Set<Id>();
        List<Incentive_Payouts__c> updatePayouts  = new List<Incentive_Payouts__c>();
        for(Incentive_Payouts__c payout : newList){
            if((oldMap == null && payout.Payable_To__c != null) || (oldMap != null && payout.Payable_To__c != null && oldMap.get(payout.id).Payable_To__c != payout.Payable_To__c ))
                userIds.add(payout.Payable_To__c);
        }
        if(userIds.size()>0){
            Map<Id, User> usrMap = new Map<Id,User>([select id,Incentive_Eligibility_Cut_Off_Date__c from User where id in :userIds]);
            for(Incentive_Payouts__c payout : newList){
                if(usrMap.containsKey(payout.Payable_To__c) && usrMap.get(payout.Payable_To__c).Incentive_Eligibility_Cut_Off_Date__c  != null && usrMap.get(payout.Payable_To__c).Incentive_Eligibility_Cut_Off_Date__c < System.today()){
                    updatePayouts.add(new Incentive_Payouts__c(id= payout.id, Not_Eligible_for_Payout__c = true));
                }
            }
            
            if(updatePayouts.size() > 0){
                update updatePayouts;
            }
        }
    }*/
}