global with sharing class ScheduleStandLeadNotification implements Schedulable {
    global void execute(SchedulableContext sc) { 
        ID BatchId = Database.executeBatch(new StandLeadNotificationBatch(), 200);
    }
}