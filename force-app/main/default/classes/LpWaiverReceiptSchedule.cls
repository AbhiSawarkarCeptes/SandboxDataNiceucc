global class LpWaiverReceiptSchedule Implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new LpWaiverReceiptBatch());
    }

}