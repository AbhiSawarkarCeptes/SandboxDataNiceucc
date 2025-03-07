trigger masterProjectTrigger on Master_Project__c (after insert,after update) {
    if(trigger.isAfter) {
        if(trigger.isInsert || trigger.isUpdate) {
            masterProjectTriggerHelper.sendToMobileMasterProject(trigger.new,Trigger.oldMap);
        }
    }
}