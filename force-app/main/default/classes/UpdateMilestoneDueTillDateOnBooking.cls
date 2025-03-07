public class UpdateMilestoneDueTillDateOnBooking implements Schedulable {
	public void execute(SchedulableContext sc) {
        Integer batchSize = Integer.valueOf(System.Label.UpdateMilestoneDueTillDateOnBookingBatchSize);
        UpdateMilestoneDueTillDateOnBookingBatch obj = new UpdateMilestoneDueTillDateOnBookingBatch(); 
        Database.executeBatch(obj,batchSize);
    }
}