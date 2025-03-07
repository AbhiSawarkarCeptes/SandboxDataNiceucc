trigger ApplicationBookingCallDetailTrigger on Application_Booking_Call_Detail__c (after insert,after update, after delete, after undelete) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUndelete) {
            ApplicationBookingCallDetailTrigHelper.updateNumberOnBooking(Trigger.new);
        }
        if(Trigger.isDelete) {
            ApplicationBookingCallDetailTrigHelper.updateNumberOnBooking(Trigger.old);
        }
        if(Trigger.isInsert) {
            ApplicationBookingCallDetailTrigHelper.updateLastNonContDtTime(Trigger.new);
        }
    }
    
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            ApplicationBookingCallDetailTrigHelper.updateNumberOnBookingOnUpd(Trigger.new, Trigger.oldMap);
        }
    }
}