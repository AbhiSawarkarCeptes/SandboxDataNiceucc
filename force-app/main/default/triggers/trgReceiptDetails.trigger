/* Bypass Framework Enabled */
trigger trgReceiptDetails on Receipt_Details__c (before delete, after undelete, after insert, after update) {

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    if (trigger.isAfter && trigger.isInsert) {
            Set<Id> rdIdset = new Set<Id>();
        for (Receipt_Details__c objReceipt: trigger.new) {
            // credit all the demand records for each receipt detail
            rdIdset.add(objReceipt.Id);
        }
        if (TriggerReceiptDetailHandler.afterInsertTriggerFirstRun) {
            TriggerReceiptDetailHandler.creditToDemands(rdIdSet);
            TriggerReceiptDetailHandler.createCreditLedgers(rdIdSet);
            TriggerReceiptDetailHandler.afterInsertTriggerFirstRun = false;
        }
        
    }
    if (trigger.isAfter && trigger.isUndelete) {
            Set<Id> rdIdset = new Set<Id>();
        for (Receipt_Details__c objReceipt: trigger.new) {
            if(objReceipt.Status__c == 'Valid') {
                // credit all the demand records for each receipt detail
                rdIdset.add(objReceipt.Id);
            }
        }
        if(rdidset != null) {
            TriggerReceiptDetailHandler.creditToDemands(rdIdSet);
            TriggerReceiptDetailHandler.createCreditLedgers(rdIdSet);
        }
    }
    if (trigger.isAfter && trigger.isUpdate) {
            Set<Id> rdIdset = new Set<Id>();
        for (Receipt_Details__c objReceipt: trigger.new) {
            if(objReceipt.Status__c == 'Cancelled' && trigger.oldmap.get(objReceipt.id).Status__c == 'Valid') {
            // debit all the demand records for each receipt detail
                rdIdset.add(objReceipt.Id);
            }
            
        }
        if(rdIdset != null) {
            // cancelled happens in case of cheque bounce, make all the ledgers void and recreate debit ledgers
            if (TriggerReceiptDetailHandler.afterUpdateTriggerFirstRun) {
                TriggerReceiptDetailHandler.cleanupLedgersAftercancellation(rdIdSet);
                TriggerReceiptDetailHandler.debitFromDemands(rdIdSet);
                TriggerReceiptDetailHandler.afterUpdateTriggerFirstRun = false;
            }
        }
    }
    if (trigger.isBefore && trigger.isDelete) {
            Set<Id> rdIdset = new Set<Id>();
        for (Receipt_Details__c objReceipt: trigger.old) {
            if(objReceipt.Status__c == 'Valid') {
                rdIdset.add(objReceipt.Id);
            }
        }
        if(rdIdSet != null) {  
            TriggerReceiptDetailHandler.debitFromDemands(rdIdSet);
            TriggerReceiptDetailHandler.deleteCreditLedgers(rdIdSet);
        }
    }
}