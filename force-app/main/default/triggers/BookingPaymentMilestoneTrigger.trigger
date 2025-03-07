trigger BookingPaymentMilestoneTrigger on PropStrength__Broker_Payment_Milestone__c (before insert, after insert) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            System.debug(Trigger.new[0].PropStrength__Broker_Service_Tax__c);
            BookingPaymentMilestoneTriggerHelper.updateCGST(Trigger.new);
        }
    } 
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
           // BookingPaymentMilestoneTriggerHelper.createLadger(Trigger.new);
        }
    }
}