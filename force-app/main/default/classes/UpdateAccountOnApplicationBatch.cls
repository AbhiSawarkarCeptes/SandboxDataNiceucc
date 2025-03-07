public class UpdateAccountOnApplicationBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute 
        return Database.getQueryLocator([select id,Name,Opportunity__r.AccountId,Applicant_Number__c,Account__c 
                               from Applicant_Details__c 
                               where Applicant_Number__c = 'Primary Applicant' 
                               AND Booking__c != NULL 
                               AND Account__c = NULL
                               AND Opportunity__r.AccountId != NULL]);
    }
    public void execute(Database.BatchableContext bc, List<Applicant_Details__c > records){
        // process each batch of records
        for(Applicant_Details__c objApp : records) {
            objApp.Account__c = objApp.Opportunity__r.AccountId;
        }
        
        update records;
    }    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }  
    
}