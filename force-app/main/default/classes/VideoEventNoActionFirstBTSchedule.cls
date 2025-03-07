global class VideoEventNoActionFirstBTSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        VideoEventNoActionFirstReminderBatch evFirstBatch = new VideoEventNoActionFirstReminderBatch(); 
        Database.executeBatch(evFirstBatch, 10);
    }
}