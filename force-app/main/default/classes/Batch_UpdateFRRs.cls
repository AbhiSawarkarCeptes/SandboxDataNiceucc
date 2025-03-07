//TestClass : LegalEntityTriggerTest
public class Batch_UpdateFRRs implements Database.Batchable<SObject>{
    public Set<Id> lEIds;
    public Batch_UpdateFRRs(List<Id> lEIds) {
        this.lEIds = new Set<Id>(lEIds);
    }

    public Batch_UpdateFRRs(Set<Id> lEIds) {
        this.lEIds = lEIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,Receipt__c,Receipt__r.Booking__r.Unit__r.Legal_Entity__c,Project_Name__c FROM Finance_Report_Records__c WHERE Receipt__r.Booking__r.Unit__r.Legal_Entity__c IN: leIds]);
    }
    
    public void execute(Database.BatchableContext BC, List <Finance_Report_Records__c> frrs) {
        Set<Id> scopedLEIds = new Set<Id>();
        for(Finance_Report_Records__c frr : frrs){
            if(String.isNotBlank(frr.Receipt__r?.Booking__r?.Unit__r?.Legal_Entity__c)) scopedLEIds.add(frr.Receipt__r.Booking__r.Unit__r.Legal_Entity__c);
        }
        if(scopedLEIds.isEmpty()) return;
        
        Map<Id,Legal_Entity__c> scopedLEs = new Map<Id,Legal_Entity__c>([SELECT id,Project_Name_id__c FROM Legal_Entity__c WHERE Id IN :scopedLEIds]);
        if(scopedLEs.isEmpty()) return;

        List<Finance_Report_Records__c> frrsToUpdate = new List<Finance_Report_Records__c>();
        for(Finance_Report_Records__c frr : frrs){
            String leId = frr.Receipt__r?.Booking__r?.Unit__r?.Legal_Entity__c;
            if(String.isNotBlank(leId) && scopedLEs.containsKey(leId) && frr.Project_Name__c != scopedLEs.get(leId).Project_Name_id__c){
                frr.Project_Name__c = scopedLEs.get(leId).Project_Name_id__c;
                frrsToUpdate.add(frr);
            }
        }

        if(!frrsToUpdate.isEmpty()) Database.update(frrsToUpdate,false);

    }

    public void finish(Database.BatchableContext BC){}
}