public class ActionRequireController {
    public static Id currentId {get; set;}
    public static Events__c getrelatedTo() {
        Events__c evt = [SELECT Id, Name FROM EVENTS__c WHERE Id =: currentId];
        return evt;
    }
    /*public static String getLastApprovarName() {
        List<ProcessInstanceStep> steps = new List<ProcessInstanceStep>([
            SELECT Actor.Name
            FROM ProcessInstanceStep
            WHERE ProcessInstance.TargetObjectId = :currentId
            ORDER BY SystemModStamp DESC
            LIMIT 1
        ]);
        return ( steps.size() > 0 ) ? steps[0].Actor.Name : null;
    }
    public static List<ApprovalHistory_Control.eventWrap> getApprovalHistory(){
        return  ApprovalHistory_Control.ApprovalHistoryRecords(currentId,'Approved');
    }
    public static List<ApprovalHistory_Control.eventWrap> getApprovalHistoryRejection(){
        return  ApprovalHistory_Control.ApprovalHistoryRecords(currentId,'Rejected');
    }*/
}