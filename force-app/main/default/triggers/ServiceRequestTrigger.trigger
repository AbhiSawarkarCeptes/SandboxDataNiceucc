trigger ServiceRequestTrigger on PropStrength__Service_Request__c (before insert,after insert,after update, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            ServiceRequestTriggerHelper.updateOwner(Trigger.new);
        }
        if(Trigger.isInsert || Trigger.isUpdate) {
            ServiceRequestTriggerHelper.updatePriority(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isUpdate) {
            ServiceRequestTriggerHelper.updateSrClosedDate(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            ServiceRequestTriggerHelper.pushProfileCase(Trigger.new,trigger.oldMap);
        }
        if(Trigger.isInsert) {
            ServiceRequestTriggerHelper.sendAutoMailToCustomer(Trigger.new);
        }
    }
}