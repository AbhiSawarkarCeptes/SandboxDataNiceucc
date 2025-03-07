public class UnitAutoCancelIntimateCustSch implements Schedulable {
    public void execute(SchedulableContext ctx) {
        UnitAutoCancelIntimateCustBatch batchJob = new UnitAutoCancelIntimateCustBatch();
        Id batchJobId = Database.executeBatch(batchJob, 1);

    }
}