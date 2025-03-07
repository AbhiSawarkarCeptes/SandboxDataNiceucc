trigger ProjectTrigger_PS on PropStrength__Projects__c (after insert,after update, before insert,before update) {
    if(trigger.isAfter) {
        if(trigger.isInsert || trigger.isUpdate) {
            ProjectTriggerHelper.sendToMobile(trigger.new,Trigger.oldMap);
        } 
    }
     if(trigger.isbefore) {
        if(trigger.isInsert || trigger.isUpdate) {
            ProjectTriggerHelper.convertRichTextToText(trigger.new,Trigger.oldMap);
        }
    }
}