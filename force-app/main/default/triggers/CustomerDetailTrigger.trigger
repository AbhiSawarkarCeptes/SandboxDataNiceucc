trigger CustomerDetailTrigger on PropStrength__Customer_Detail__c (after insert) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            CustomerDetailTriggerHelper.concateFieldsToFirstChild(trigger.new);
            CustomerDetailTriggerHelper.createTaskOnTr(Trigger.new);
        }
    }
}