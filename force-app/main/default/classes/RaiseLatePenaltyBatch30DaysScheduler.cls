public class RaiseLatePenaltyBatch30DaysScheduler implements Schedulable {
	public void execute(SchedulableContext sc) {
        System.enqueueJob(new RaiseLatePenaltyBatch30Days());
    }
}