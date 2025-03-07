/* Bypass Framework Enabled */
trigger BusinessProcessStepTrigger on Business_Process_Step__c (before update,after Insert,before Insert, after update) {

    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    If(trigger.isUpdate && trigger.isBefore){
        BusinessProcessStepTriggerHandler.openNextStep(trigger.new,trigger.oldMap);
        BusinessProcessStepTriggerHandler.updateBusinessProcess(trigger.new,trigger.oldMap);
    }
    If(trigger.isUpdate && trigger.isAfter){
        BusinessProcessStepTriggerHandler.sendEmailNotificationUpdate(trigger.new,trigger.oldMap);
        BusinessProcessStepTriggerHandler.statusChangeEmail(trigger.new,trigger.oldMap);
    }
    If(trigger.isInsert && trigger.isAfter){
        BusinessProcessStepTriggerHandler.sendEmailNotificationInsert(trigger.new);
    }
    
}