public class RaiseLatePenaltyBatch15DaysScheduler implements Schedulable {
	public void execute(SchedulableContext sc) {
        System.enqueueJob(new RaiseLatePenaltyBatch15Days());
    }
}