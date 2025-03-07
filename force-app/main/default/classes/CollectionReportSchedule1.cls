global class CollectionReportSchedule1 Implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CollectionReportBatch1());
    }
}