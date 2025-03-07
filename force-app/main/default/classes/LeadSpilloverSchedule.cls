global class LeadSpilloverSchedule Implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchClassToManageLeadSpillOver());
    }
}