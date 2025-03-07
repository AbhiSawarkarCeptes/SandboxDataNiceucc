global class VideoEventNoActionSecondBTSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        VideoEventNoActionSecondReminderBatch evSecondBatch = new VideoEventNoActionSecondReminderBatch(); 
        Database.executeBatch(evSecondBatch, 10);
    }
}