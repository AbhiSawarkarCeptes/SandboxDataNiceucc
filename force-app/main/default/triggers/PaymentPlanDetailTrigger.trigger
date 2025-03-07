trigger PaymentPlanDetailTrigger on PropStrength__Payment_Plan_Details__c (after update, after insert, before update) {
    if(trigger.isAfter) {
        if(trigger.isUpdate && PaymentPlanDetailTriggerHelper.runOnce()) {
            PaymentPlanDetailTriggerHelper.PPDConstructionLink(trigger.new, trigger.oldMap);
        }
        if(Trigger.isInsert) {
            PaymentPlanDetailTriggerHelper.updateBudgetedDate(Trigger.new);
        }        
    }
    
    if(Trigger.isBefore) {        
        if(Trigger.isUpdate) {
            PaymentPlanDetailTriggerHelper.updatetaxReversal(Trigger.new, Trigger.oldMap);
            PaymentPlanDetailTriggerHelper.updateRateOfInterest(Trigger.new, Trigger.oldMap);
        }
    }
}