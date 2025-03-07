global class ProcessBeyondWorkingHourLeads implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Lead WHERE Beyond_Working_Hours__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        for(Lead l : leadList){
            l.Beyond_Working_Hours__c = false;
            l.Lead_Assignment_DateTime__c = system.now();
        }
        try{
            LeadAutoReassignController.skipDuplicateLeadLogic = true;
            Database.update(leadList,false);
        }
        catch(Exception e){
            LeadAutoReassignController.insertErrorLog('','ProcessBeyondWorkingHourLeads','updateLeadAssignmentDateTime',e.getMessage(),e.getStackTraceString());
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}