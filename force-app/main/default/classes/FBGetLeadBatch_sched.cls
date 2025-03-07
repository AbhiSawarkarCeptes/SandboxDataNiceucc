global class FBGetLeadBatch_sched implements schedulable {
    
    global void execute(SchedulableContext sc){
         FBGetLeadsBatch b = new FBGetLeadsBatch(); 
         database.executebatch(b,1);
    }

}