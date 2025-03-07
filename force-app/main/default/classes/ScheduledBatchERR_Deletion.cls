//Test class : TestSRCustomer
public class ScheduledBatchERR_Deletion implements Schedulable,Database.Batchable<sObject>{

    //Schedulable
    public void execute(SchedulableContext sc){
        Database.executeBatch(new ScheduledBatchERR_Deletion(),2000);
    }
    
    //Batchable
    public Database.QueryLocator start(Database.BatchableContext bc){
        DateTime dtNow = System.now();
        return Database.getQueryLocator('SELECT id FROM External_Reference_Register__c WHERE Entry_Expiration_DateTime__c <= :dtNow');
    }
    
    public void execute(Database.BatchableContext bc, List<External_Reference_Register__c> errs){Database.delete(errs,false);}
    
    public void finish(Database.BatchableContext bc){}
}