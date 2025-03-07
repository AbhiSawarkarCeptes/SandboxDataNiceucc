global class EnquiryDailyTrackingBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sch) {
        EnquiryDailyTrackingBatch batch = new EnquiryDailyTrackingBatch();
        Database.executebatch(batch, 50);
    }
}