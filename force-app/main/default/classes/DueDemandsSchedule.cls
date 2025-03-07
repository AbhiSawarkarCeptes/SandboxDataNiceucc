global class DueDemandsSchedule Implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new DueDemandsBatch());
    }
}