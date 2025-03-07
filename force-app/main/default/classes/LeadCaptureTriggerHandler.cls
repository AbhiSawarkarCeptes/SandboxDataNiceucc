public class LeadCaptureTriggerHandler {
    public static void onBeforeInsertUpdate(List<Lead_Capture__c> leadCaptures) {
        LeadCaptureValidator.validateEndDate(leadCaptures);
    }
}