global class SchedularPPDTimeLinkedBatch implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        PPDTimeLinkedBatch p = new PPDTimeLinkedBatch();
        database.executeBatch(p,1);
    }
}