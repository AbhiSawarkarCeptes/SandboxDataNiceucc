global  class ReleaseDateReminderScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ReleaseDateReminderBatch rdm = new ReleaseDateReminderBatch();
        database.executeBatch(rdm,200);
    }
}