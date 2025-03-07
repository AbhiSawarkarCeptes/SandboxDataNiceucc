public class LedgerDocumentHistoryTriggerController {
    //Added by Nishank on 18-Sept-2024 to update cheque number on Broker Ledger
    public static void updateChequeNumber(List<Ledger_Document_History__c> ldhList, Map<Id, Ledger_Document_History__c> oldLdhMap) {
        List<PropStrength__Broker_Ledger__c> updateLedgerList = new List<PropStrength__Broker_Ledger__c>();

        for(Ledger_Document_History__c ldh : ldhList) {
            if(oldLdhMap == null && ldh.Document_Number__c != null && ldh.Document_Type__c == 'Cheque Number') {
                updateLedgerList.add(new PropStrength__Broker_Ledger__c(Id=ldh.Broker_Ledger__c, Cheque_Number__c = ldh.Document_Number__c));
            } else if(oldLdhMap != null && ldh.Document_Number__c != null && ldh.Document_Type__c == 'Cheque Number' && (oldLdhMap.get(ldh.Id).Document_Type__c != ldh.Document_Type__c || oldLdhMap.get(ldh.Id).Document_Number__c != ldh.Document_Number__c)) {
                updateLedgerList.add(new PropStrength__Broker_Ledger__c(Id=ldh.Broker_Ledger__c, Cheque_Number__c = ldh.Document_Number__c));
            }
        }

        if(!updateLedgerList.isEmpty()) {
            update updateLedgerList;
        }
    }
}