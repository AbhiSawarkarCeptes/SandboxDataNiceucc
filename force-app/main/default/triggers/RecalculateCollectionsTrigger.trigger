/* Bypass Framework Enabled */
trigger RecalculateCollectionsTrigger on Recalculate_Collections__e (after insert) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    List<String> receiptIds = new List<String>();
    List<String> demandIds = new List<String>();
    
    //Records where recalculations are needed
    for(Recalculate_Collections__e rce : Trigger.new){
        if(String.isNotBlank(rce.Receipt_Id__c)){
            receiptIds.add(rce.Receipt_Id__c);
        }
        if(String.isNotBlank(rce.Demand_Id__c)){
            demandIds.add(rce.Demand_Id__c);
        }
    }
    
    Set<String> recalculationCandidateBookings = new Set<String>();
    
    if(!receiptIds.isEmpty()){
        for(Receipt__c receipt : [SELECT id,Booking__c,Booking__r.Name FROM Receipt__c WHERE Id IN :receiptIds AND Booking__c != NULL]){
            recalculationCandidateBookings.add(receipt.Booking__r.Name);
        }
    }
    
    if(!demandIds.isEmpty()){
        for(Demand__c demand : [SELECT id,Booking__c,Booking__r.Name FROM Demand__c WHERE Id IN :demandIds AND Booking__c != NULL]){
            recalculationCandidateBookings.add(demand.Booking__r.Name);
        }
    }
    
    if(!recalculationCandidateBookings.isEmpty()) CollectionReportControllerV2.dateCalculation(new List<String>(recalculationCandidateBookings));
}