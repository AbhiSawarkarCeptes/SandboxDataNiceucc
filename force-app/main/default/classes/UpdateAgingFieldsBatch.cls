public class UpdateAgingFieldsBatch implements Database.Batchable<sObject>, Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query receipts that need to be updated
        return Database.getQueryLocator([SELECT Id,Audit_Aging__c,Account_Aging__c,Audit_Approval_Status__c FROM Receipt__c WHERE Audit_Approval_Status__c = 'Under Approval' OR Audit_Approval_Status__c = 'Rejected']);
    }

    public void execute(Database.BatchableContext BC, List<Receipt__c> scope) {
        for(Receipt__c recpObj : scope){
            if(recpObj.Audit_Approval_Status__c == 'Rejected'){
                recpObj.Account_Aging__c = recpObj.Account_Aging__c != null ? recpObj.Account_Aging__c +1 : 1;
            }
            else if(recpObj.Audit_Approval_Status__c == 'Under Approval'){
                recpObj.Audit_Aging__c = recpObj.Audit_Aging__c != null ? recpObj.Audit_Aging__c +1 : 1;
            }
        }
        update scope;



       /* List<Receipt__c> receiptsToUpdate = new List<Receipt__c>();

        for (Receipt__c receipt : scope) {
            Integer auditAging = 0;
            Integer accountAging = 0;
            Datetime lastChangeDate = null;

            if (receipt.Audit_History__c != null) {
              List<String> auditEntries = receipt.Audit_History__c.split('\n');
                for (String entry : auditEntries) {
                    List<String> parts = entry.split(' ');
                    if (parts.size() >= 9) {
                        try {
                            Datetime changeDate = Datetime.parse(parts[7] + ' ' + parts[8]);
                            if (lastChangeDate != null) {
                                if (parts[5] == 'Approval') {
                                    auditAging += changeDate.date().daysBetween(lastChangeDate.date());
                                } else if (parts[5] == 'Rejected') {
                                    accountAging += changeDate.date().daysBetween(lastChangeDate.date());
                                }
                            }
                            lastChangeDate = changeDate;
                        } catch (Exception e) {
                            System.debug('Error parsing date/time: ' + e.getMessage());
                        }
                    }
                }
            }

            receipt.Audit_Aging__c = auditAging;
            receipt.Account_Aging__c = accountAging;
            receiptsToUpdate.add(receipt);
        }

        if (!receiptsToUpdate.isEmpty()) {
            update receiptsToUpdate;
        }*/
    }

    public void finish(Database.BatchableContext BC) {
        // Execute any post-processing logic if needed
    }
}