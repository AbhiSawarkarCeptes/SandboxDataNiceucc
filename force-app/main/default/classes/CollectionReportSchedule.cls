global class CollectionReportSchedule Implements Schedulable{
    static final Integer DEFAULT_SCOPE = 1; 
    Integer scope;

    public CollectionReportSchedule(){
        this.scope = DEFAULT_SCOPE;
    }
    
    public CollectionReportSchedule(Integer scope){
        this.scope = scope == NULL || scope < 1 || scope > 2000 ? DEFAULT_SCOPE : scope ;
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CollectionReportBatch(),this.scope);
    }
}