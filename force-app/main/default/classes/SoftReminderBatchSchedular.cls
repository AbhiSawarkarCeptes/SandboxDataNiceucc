global class SoftReminderBatchSchedular implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        SoftReminderBatch p = new SoftReminderBatch();
        database.executeBatch(p,1);
    }
}