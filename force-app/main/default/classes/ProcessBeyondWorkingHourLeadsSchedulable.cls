public class ProcessBeyondWorkingHourLeadsSchedulable implements Schedulable {
	public void execute(SchedulableContext sc) {
        ProcessBeyondWorkingHourLeads obj = new ProcessBeyondWorkingHourLeads(); 
        Database.executeBatch(obj,50);
    }
}