public class UnitAutoCancellationProcessSch implements Schedulable {
    public void execute(SchedulableContext ctx) {
        UnitAutoCancellationProcessBatch batchJob = new UnitAutoCancellationProcessBatch();
        Id batchJobId = Database.executeBatch(batchJob, 1);

    }
}