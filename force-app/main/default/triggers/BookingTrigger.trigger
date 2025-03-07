/* Bypass Framework Added */
trigger BookingTrigger on Booking__c (after insert, after update) {
  /* public static Boolean hasFired = false;
    if (Trigger.isAfter && !BookingTriggerHandlerCtr.firstcall) {
        if (Trigger.isInsert){
              hasFired = true;
             BookingTriggerHandlerCtr.afterInsert(Trigger.new);
        }
        else if(Trigger.isUpdate) {
             BookingTriggerHandlerCtr.afterUpdate(Trigger.new, Trigger.oldMap);
        } 
    }*/
}