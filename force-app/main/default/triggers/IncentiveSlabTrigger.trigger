trigger IncentiveSlabTrigger on Incentive_Slab__c (Before insert,Before update, Before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.Isafter) {
        if(trigger.isUpdate){
           //IncentiveSlabHelper.updateIncentivesOnBooking(Trigger.new);
        }
    }
    if(Trigger.IsBefore) {
        if(Trigger.isInsert) {
            IncentiveSlabHelper.incentiveSlabValidation(Trigger.new, null);
        } 
        if(Trigger.isUpdate){
           IncentiveSlabHelper.incentiveSlabValidation(Trigger.new, Trigger.oldMap);
        }
    }
}