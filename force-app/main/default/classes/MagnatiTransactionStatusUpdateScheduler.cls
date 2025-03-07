/**
*  --------------------------------------------------------------------------------------------------------------------------------------
* @Who   : Cloud Desk Pvt.Ltd.
* @What  : CC Avunue to Magnati Payment
* @Why   : Update CCAveune payment to Magnati Payment - Scheduler Class for Retry Mechanism
* @When  : 15-Nov-2023
*  -------------------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class MagnatiTransactionStatusUpdateScheduler implements Schedulable{
    public void execute(SchedulableContext sc) {
        MagnatiTransactionStatusUpdateBatch b = new MagnatiTransactionStatusUpdateBatch(); 
        Database.executeBatch(b, 1);
    }
}