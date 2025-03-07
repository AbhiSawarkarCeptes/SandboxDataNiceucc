global class VideoEventNoActionThirdBTSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        VideoEventNoActionThirdReminderBatch evThirdBatch = new VideoEventNoActionThirdReminderBatch(); 
        Database.executeBatch(evThirdBatch, 10);
    }
}