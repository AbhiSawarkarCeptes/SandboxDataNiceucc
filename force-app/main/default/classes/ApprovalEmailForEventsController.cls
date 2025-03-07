public  class ApprovalEmailForEventsController {
    public static Id currentId {get;set;}
    public static integer numberOfHoursElapsed {get;set;}
    public static boolean escalationEmail {get;set;}
	public static String getCurrentUserName(){
        return UserInfo.getFirstName()+' '+UserInfo.getLastName();
    }

	public static Events__c getrelatedTo() {
        Events__c evt =  [Select id,campaign_code__c,Event_Approved_status__c,start_time_of_the_event__C,end_time_of_the_event__C,Venue_Video_Shoot__c,No_Of_Pax_Attending__c,User_1__r.Name,User_2__r.Name,User_3__r.Name,Email_Last_Triggered_Time__c,Name,Next_Approver__c,Next_Approver__r.name,City_Country__c,Country__c,createdby.name,approval_request_submitted_time__c,Date_Of_Event__c,Sales_VP__r.name,Sales_Director__r.name,Owner.Name,Remaining_Days_in_Event__c,Channel_Relationship_Manager__r.name,Channel_Relationship_Head__r.name,Marketing_Support_Required_Brochures_etc__c,Channel_Partner__c,Channel_Partner__r.name,End_Date_Of_Event__c,Type_Of_road_show__c,
        recordtypeId,recordtype.name,
        (SELECT Id, LastActor.Name FROM ProcessInstances order by createddate desc limit 1)
         FROM EVENTS__c where id=:currentId]; 
        
         if(evt.approval_request_submitted_time__c != null){
         numberOfHoursElapsed = (evt.approval_request_submitted_time__c.date()).daysbetween((system.today()));
         numberOfHoursElapsed = numberOfHoursElapsed*24;
         }
        return evt;
    }
    public static String getLastApprovarName() {
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
    }
}