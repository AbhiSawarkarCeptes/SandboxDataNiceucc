global class LeadOwnerReassign implements Database.Batchable <sObject>,Database.AllowsCallouts{
    Public String Query;
    
    public LeadOwnerReassign() {
        Query = 'Select id,name,Presales_Agent__c, OwnerId,owner.Name,Owner_Profile__c,createddate from Lead where  Owner_Profile__c = \'\' and Owner.Name != \'Careers Lead\' and Owner.Name != \'Unassigned Leads\' order by createddate desc ';
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<Lead> scope){
           //SocialMediaLeadServices.getFBleads(scope);
         //  LeadUtility.leadOwnerReassign(scope);
          List<Lead> llst = new List<Lead>();
         for(Lead lead : scope){
             if(lead.Presales_Agent__c != null){
                 if(lead.Presales_Agent__c != lead.OwnerId){
                     lead.OwnerId = lead.Presales_Agent__c;
                 }
             }
             llst.add(lead);
        }
        upsert llst;
    }
    
    global void finish(Database.BatchableContext info){     
    }  
}