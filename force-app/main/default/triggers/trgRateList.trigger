/* Bypass Framework Enabled */
trigger trgRateList on Rate_List__c (after insert, after update) {

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
        if(RateListTriggerHandler.firstRun){
            Map<Id, Id> rateListMap;
            Set<Id> rIdset = new Set<Id>();     
            
            for(Rate_List__c r : Trigger.new) {
                rIdset.add(r.Id);
            }
            if(!rIdset.isEmpty()) {
                RateListTriggerHandler.updateUnit(rIdSet);
            }
            RateListTriggerHandler.firstRun = false;
        }
    }
}