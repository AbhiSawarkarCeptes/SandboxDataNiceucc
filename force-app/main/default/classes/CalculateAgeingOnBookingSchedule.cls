global class CalculateAgeingOnBookingSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
        CalculateAgeingOnBookingBatch ageing = new CalculateAgeingOnBookingBatch();
        Database.executeBatch(ageing);
    }
}