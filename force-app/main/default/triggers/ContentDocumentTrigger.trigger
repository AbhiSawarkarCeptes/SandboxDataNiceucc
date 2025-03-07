/* Bypass Framework Enabled */
trigger ContentDocumentTrigger on ContentDocument (after insert, before delete) {
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    List<String> objectList = new List<String>();
    objectList.add('Broker_Registration__c');
    
    if (Trigger.isDelete) {
        ContentDocumentTriggerHandler.restrictDeletionOfPaymentRequestFiles(trigger.old);
        ContentDocumentTriggerHandler.restrictDeletionOfFiles(trigger.old, objectList);
    } //Delete Trigger
}