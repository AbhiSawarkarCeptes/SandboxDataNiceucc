public with sharing class RateListTriggerHandler {

    public static boolean firstRun = true;

    public static void updateUnit(Set<Id> rlId){
        Map<String, Integer> projChargeSeq;
        Map<Id, List<Rate_List__c>> rateMap = new Map<Id, List<Rate_List__c>>();
        Map<Id, Map<String, Decimal>> unitprojChargeSeq = new Map<Id, Map<String, Integer>>();
        Unit__c updateUnit; 
        List<Unit__c> updateUnitList = new List<Unit__c>();     
        Decimal count = 0;
        Decimal agreementvalue = 0;
        Decimal DLDamount = 0;
        List <Rate_List__c> rlList = [SELECT Id, Unit__c, Unit__r.Project__r.Name, Unit__r.Tower__c, Charge_Cost__c, ProjectCharges__r.Name, Rate_List_Bucket__c FROM Rate_List__c WHERE Id IN :rlId];
        if(!rlList.isEmpty()) {
            for(Rate_List__c r : rlList) {
                if(rateMap.containsKey(r.Unit__c)) {
                    rateMap.get(r.Unit__c).add(r);
                }
                else {
                    list<rate_list__c> tempList = new List<rate_List__c>();
                    tempList.add(r);
                    rateMap.put(r.Unit__c, tempList);
                }
            }
        }
        if(rateMap != null){
            List<Unit__c> unitList = [SELECT Project__r.Name, Tower__c, Charge_1_Name__c, Charge_2_Name__c, Charge_3_Name__c,
                                            Charge_4_Name__c, Charge_5_Name__c, Charge_6_Name__c, Charge_7_Name__c, Charge_1_Amount__c, Charge_2_Amount__c,
                                            Charge_3_Amount__c, Charge_4_Amount__c, Charge_5_Amount__c, Charge_6_Amount__c, Charge_7_Amount__c
                                            FROM Unit__c WHERE Id IN :rateMap.KeySet()];
            for(Unit__c u : unitList) {
                if(rateMap.containsKey(u.Id)) {
                    projChargeSeq = InventoryCostServices.getProjectChargesSequence(u.Project__r.Name, u.Tower__c);
                    for(Rate_List__c r : rateMap.get(u.Id)) {
                        //if(!projChargeSeq.containsKey('DLD')) {  
                            if(projChargeSeq.containsKey(r.ProjectCharges__r.Name))
                            {
                                 count = projChargeSeq.get(r.ProjectCharges__r.Name);
                                 system.debug('count:'+count);
                                 u.put('Charge_'+count+'_Amount__c', r.Charge_Cost__c);  
                                 u.put('Charge_'+count+'_Name__c', r.ProjectCharges__r.Name); 
                                 u.put('Charge_'+count+'_Bucket__c', r.Rate_List_Bucket__c);                                
                            }
                       // }
                          
                   }      
                }
                updateUnitList.add(u);
            }
            
            if(updateUnitList != null)
                update updateUnitList;
        }      
    } 
}