public class SendWelcomeLetterBookingSch implements Schedulable {
    public void execute(SchedulableContext cntx) {
        SendWelcomeLetterBookingBatch batchJob = new SendWelcomeLetterBookingBatch();
        Id batchJobId = Database.executeBatch(batchJob, 1);

    }
}