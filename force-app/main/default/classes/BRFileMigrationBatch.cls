global class BRFileMigrationBatch implements Database.Batchable<sObject>, Database.Stateful  {

    private integer limitParam;
    
    public BRFileMigrationBatch() {
        
    }
    
    public BRFileMigrationBatch(integer limitParam) {
        this.limitParam = limitParam;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query;
        if(limitParam == 0) {
            query = 'Select id,legacy_broker_Id__c from Account where legacy_broker_Id__c != NULL';
        }
        else {
            String limitQuery = ' LIMIT ' + limitParam;
            query = 'Select id,legacy_broker_Id__c from Account where legacy_broker_Id__c != NULL' + limitQuery;
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        for(Account account : scope){
            FileUtility.copyFile(account.legacy_broker_Id__c, account.id);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}