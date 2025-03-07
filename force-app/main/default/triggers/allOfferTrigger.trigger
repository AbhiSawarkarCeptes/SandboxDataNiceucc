trigger allOfferTrigger on PropStrength__Offer__c (before update,after insert, before delete, after undelete, after update){
    if(Trigger.isAfter) {
        if(Trigger.isUndelete || Trigger.isInsert) {
            allOfferTriggerHelper.updateCountOnAdvtMarket(Trigger.new, Trigger.newMap, 'Insert');
        }
        if(Trigger.isUpdate) {
            allOfferTriggerHelper.updateCountOnAdvtMarketOnUp(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            allOfferTriggerHelper.errorMsg(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete) {
            allOfferTriggerHelper.updateCountOnAdvtMarket(Trigger.old, Trigger.oldMap, 'Delete');
        }
    }
}