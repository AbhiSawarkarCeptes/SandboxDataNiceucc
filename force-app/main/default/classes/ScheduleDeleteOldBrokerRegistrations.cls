global class ScheduleDeleteOldBrokerRegistrations implements Schedulable {
    global void execute(SchedulableContext SC) {
        DeleteOldBrokerRegistrationsBatch batch = new DeleteOldBrokerRegistrationsBatch();
        Database.executeBatch(batch);
    }
}