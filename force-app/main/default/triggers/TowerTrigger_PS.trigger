trigger TowerTrigger_PS on PropStrength__Tower__c (after insert,after update) {
    if(trigger.isAfter) {
        if(trigger.isInsert || trigger.isUpdate) {
            TowerTriggerHelper.sendToMobile(trigger.new,Trigger.oldMap);
        }
        if(Trigger.isUpdate) {
            TowerTriggerHelper.sendMailForCompletionCertificate(Trigger.new,Trigger.oldMap);
        }
    }
}