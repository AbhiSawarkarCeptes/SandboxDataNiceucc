trigger AttemptTrackingTrigger_PS on Attempt_Tracking__c (before update, after update) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        //Validate Attempt Record - When update attempt record upload at least one file in related List
        AttemptTrackingTriggerHelper.validateAttemptTracking(Trigger.new, Trigger.oldMap);
    }
    if(trigger.isAfter && Trigger.isUpdate && AttemptTrackingTriggerHelper.runOnce()) {
        //When user change the status on Attempt Tracking, New Attempt Tracking Record will be 
        //Created as per Lead Nurturing Metadata and Update Day Tracking Status and Update Lead and Enquiry
        AttemptTrackingTriggerHelper.updateLeadandEnquiry(Trigger.new, Trigger.oldMap);
    }
}