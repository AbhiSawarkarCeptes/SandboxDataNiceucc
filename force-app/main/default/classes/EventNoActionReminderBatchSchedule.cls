global class EventNoActionReminderBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        EventNoActionReminderBatch evBatch = new EventNoActionReminderBatch(); 
        Database.executeBatch(evBatch, 10);
    }
}