trigger quoteTrigger on Quote__c (before insert, after insert) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            QuoteTriggerHandler.sendForApprover(Trigger.new);
        }
    }
}