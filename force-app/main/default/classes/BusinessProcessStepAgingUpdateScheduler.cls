global class BusinessProcessStepAgingUpdateScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BusinessProcessStepAgingUpdateBatch processBatch = new BusinessProcessStepAgingUpdateBatch(null);
        Database.executeBatch(processBatch);
        BusinessProcessAgingUpdateBatch processBatch1 = new BusinessProcessAgingUpdateBatch(null);
        Database.executeBatch(processBatch1);
    }
}