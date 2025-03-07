global class CreateRecieptForAdvancePaymentSchedule Implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CreateReceiptForAdvancePaymentBatch());
    }
}