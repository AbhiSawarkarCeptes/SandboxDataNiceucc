trigger InterimPaymentTrigger on PropStrength__Interim_Payment__c (after insert) {
	if(Trigger.isAfter) {
        if(trigger.isAfter && trigger.isInsert){
            InterimPaymentTriggerHelper.createInterimPaymentRecord(trigger.new);
        } 
    }
}