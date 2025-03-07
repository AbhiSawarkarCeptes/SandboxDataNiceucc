trigger IncentivePayoutTrigger on Incentive_Payouts__c (after insert, after update, before insert) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            IncentivePayoutTriggerHelper.calculateBalance(Trigger.new);
            IncentivePayoutTriggerHelper.sendForApproval(Trigger.new, null); // Added By Gourav on 10/05/2024
        }
        if(Trigger.isUpdate) {
            IncentivePayoutTriggerHelper.sendForApproval(Trigger.new, Trigger.oldMap); // Added By Gourav on 10/05/2024
        }
    }
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            IncentivePayoutTriggerHelper.verifiedPayableUser(Trigger.new);  // Added by Gourav Gour on 14/05/2024
        }
    }
}