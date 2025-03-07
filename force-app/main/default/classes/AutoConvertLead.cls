public class AutoConvertLead {
    
    public static void ConvertLead(List<Lead> leadlist, String leadId){
         List<Opportunity> oUpdList = new List<Opportunity> ();
        system.debug('leadId////' + leadlist + '/////' + leadId);
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setDoNotCreateOpportunity(false);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setOwnerId(leadlist[0].Manager__c);
        
        //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        //lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        system.debug('databaseresult' + lc.getOpportunityId() );
        List<Lead> opptyLeadList = [select id,name,ConvertedOpportunityId  from lead where id = : leadId];
        system.debug('opptyLeadList' + opptyLeadList);
        oUpdList.add(new Opportunity(id = opptyLeadList[0].ConvertedOpportunityId, Sales_Manager_lookup__c = leadlist[0].Manager__c));
        if(oUpdList.size() > 0){
            system.debug('oUpdList' + oUpdList);
            update oUpdList;
        }
        
    }
    
}