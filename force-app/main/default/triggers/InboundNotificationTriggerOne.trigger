trigger InboundNotificationTriggerOne on VCC1__Inbound_Notification__c(after insert) {
    if(Trigger.isInsert) {
        if(Trigger.isAfter) {
            InboundNotificationTriggerOneHelper.createEnquiry(Trigger.new);
        }
    }
}