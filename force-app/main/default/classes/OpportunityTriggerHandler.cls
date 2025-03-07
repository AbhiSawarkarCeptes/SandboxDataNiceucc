/* Handler Class for Opportunity trigger */
public class OpportunityTriggerHandler {
    
    /* Update back Parent Lead - Datahash */
    public static void updateLeadAttemptStatus(List<Opportunity> opportunities){
        try {
            Set<Id> leadIdsToUpdate = new Set<Id>();
            List<Lead> updatedLeads = new List<Lead>();
            Set<Id> opportunityIds = new Set<Id>();
            Map<String,Opportunity> opportunityMap = new Map<String,Opportunity>();
            
            for (Opportunity opp : opportunities) {
                opportunityMap.put(opp.Id, opp);
            }
            
            List<Lead> parentLeadList = [SELECT Id, Last_Call_Attempt_Status__c,
                                         convertedOpportunityId, Lead_Id__c
                                         FROM Lead 
                                         WHERE convertedOpportunityId IN :opportunityMap.KeySet()];
            for(Lead parentLead: parentLeadList) {
                Lead updatedLead = New Lead(Id = parentLead.id);
                Opportunity convertedOpp = opportunityMap.containsKey(parentLead.ConvertedOpportunityId) ? opportunityMap.get(parentLead.ConvertedOpportunityId) : null;
                if(convertedOpp != null) {
                    updatedLead.Last_Call_Attempt_Status__c = convertedOpp.Last_Call_Attempt_Status__c;
                    updatedLead.Call_Attempt_Status__c = convertedOpp.Last_Call_Attempt_Status__c;
                    updatedLeads.add(updatedLead);
                }
            }
            
            // Perform the update on Leads
            if (updatedLeads.size() > 0) {
                Database.update(updatedLeads, FALSE); 
            }
        }
        catch(Exception ex) {
            Error_Log__c trackErrorRec = new Error_Log__c(Class__c = 'OpportunityTriggerhandler -- updateLeadAttemptStatus',Message__c = ex.getmessage());
            database.insert(trackErrorRec, false);
        }
    }
}