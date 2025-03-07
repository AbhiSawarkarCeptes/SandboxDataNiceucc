//Test class: WelcomeEmailToSiniyaBookingTest
public class WelcomeEmailSiniyaBookingSch implements Schedulable {
    public void execute(SchedulableContext cntx) {
        WelcomeEmailToSiniyaBookingBatch batchJob = new WelcomeEmailToSiniyaBookingBatch();
        Id batchJobId = Database.executeBatch(batchJob, 1);
    }
}