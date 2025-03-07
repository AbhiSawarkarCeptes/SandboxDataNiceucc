trigger MilestoneTrigger on PropStrength__Milestone__c (after Update) {
    if(trigger.isAfter) {
        if(trigger.isUpdate && MilestoneTriggerHelper.runOnce()) {
            MilestoneTriggerHelper.updatePPDBudgetedDate(trigger.new, trigger.oldMap);
        }
        if(Trigger.isUpdate) {
            MilestoneTriggerHelper.sendEmailToProjUser(Trigger.new, Trigger.oldMap);
        }
    }
}