public class VideoUploadRequestController {
    public static Id currentId {get; set;}
    public static Events__c getrelatedTo() {
        Events__c evt = [SELECT Id, Name FROM EVENTS__c WHERE Id =: currentId];
        return evt;
    }
}