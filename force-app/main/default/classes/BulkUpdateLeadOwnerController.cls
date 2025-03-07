public class BulkUpdateLeadOwnerController {
    public List<Lead> selectedLead {get;set;}
    public String inputLeadIds {get;set;}
    public Lead lead {get; set;}
	public ApexPages.StandardSetController setCon {get;set;}
    Public BulkUpdateLeadOwnerController(ApexPages.StandardSetController controller) { 
        lead = [select Id, Stand_Lead_Promoter__c from Lead where Stand_Lead_Promoter__c=null limit 1];
        setCon = controller;
        if(!Test.isRunningTest())
        	selectedLead = setCon.getSelected();
    }
    
    public pagereference save() { 
        if(selectedLead.size()>0){
            Database.executeBatch(new BulkUpdateLeadOwnerBatch(selectedLead,lead.Stand_Lead_Promoter__c),10);
        }
        PageReference pref = new PageReference('/00Q/o');
        return pref;
    }
    
    public pagereference cancel() { 
        PageReference pref = new PageReference('/00Q/o');
        return pref;
    }
}