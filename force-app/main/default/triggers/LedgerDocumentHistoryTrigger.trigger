trigger LedgerDocumentHistoryTrigger on Ledger_Document_History__c (after insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            LedgerDocumentHistoryTriggerController.updateChequeNumber(Trigger.new, null);
        }
        if(Trigger.isUpdate) {
            LedgerDocumentHistoryTriggerController.updateChequeNumber(Trigger.new, Trigger.oldMap);
        }
    }
}