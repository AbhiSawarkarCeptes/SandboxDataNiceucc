global class LeadAssignmentToAgentsScheduler implements Schedulable {
    
    
    global static void scheduleMe(String CRON_EXP){
      System.schedule('LeadAssignment'+System.now(),CRON_EXP,new LeadAssignmentToAgentsScheduler()); 
    }
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new LeadAssignmentToAgents());
    } 
    
}