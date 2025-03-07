global class X_SyncScheduler implements Schedulable {
    X_SyncBatch syncBatch;
        
    public X_SyncScheduler(X_SyncBatch syncBatch){
        this.syncBatch = syncBatch;
    }
    
    public X_SyncScheduler(){
        this.syncBatch = new X_SyncBatch();
    }
    
	global void execute(SchedulableContext sc){
        if(!Test.isRunningTest()) Database.executeBatch(this.syncBatch,1);
    }

}