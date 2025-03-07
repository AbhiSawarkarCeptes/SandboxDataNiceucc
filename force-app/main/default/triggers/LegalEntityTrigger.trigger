/* Bypass Framework Enabled */
trigger LegalEntityTrigger on Legal_entity__c (after update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    Set<Id>     leIds = new Set<Id>();
    for(Legal_Entity__c le : trigger.new){
        if(le.Project_Name_id__c != trigger.oldmap.get(le.id).Project_Name_id__c){
            leIds.add(le.id);
        }
    }
    
    if(Feature_Flag__mdt.getAll().containsKey('UPDATE_FRR_IN_BATCH_ON_LE_UPDATE') && Feature_Flag__mdt.getInstance('UPDATE_FRR_IN_BATCH_ON_LE_UPDATE').Active__c && (!System.isFuture() && !System.isScheduled() && !System.isQueueable() && !System.isBatch())){
        Database.executeBatch(new Batch_UpdateFRRs(leIds));
    }else{
        List<Finance_Report_Records__c> frrList = [SELECT Id,Receipt__c,Receipt__r.Booking__r.Unit__r.Legal_Entity__c FROM Finance_Report_Records__c WHERE Receipt__r.Booking__r.Unit__r.Legal_Entity__c IN: leIds];
        if(!frrList.isEmpty()){
            for(Finance_Report_Records__c frr : frrList){
                if(frr.Receipt__r.Booking__r.Unit__r.Legal_Entity__c != null){
                    frr.Project_Name__c = trigger.newMap.get(frr.Receipt__r.Booking__r.Unit__r.Legal_Entity__c).Project_Name_id__c;
                    
                }
            }
            update frrList;
            
        }
    }   
}