global class DocumentExpiryNotifierSch implements Schedulable {
    global void execute(SchedulableContext sc) {
        DocumentExpiryNotifierBatch batch = new DocumentExpiryNotifierBatch();
        Database.executeBatch(batch, 100); // Optional, 100 is the batch size
    }
}