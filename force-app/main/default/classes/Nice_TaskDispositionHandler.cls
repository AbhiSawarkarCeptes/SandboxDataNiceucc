/******************************************************
	Class : Nice_TaskDispositionHandler
    Test Class : Nice_TaskDispositionHandlerTest
    Purpose : NICE - Apex class handles publishing platform events, retrieving dependent picklist values, updating task records with call disposition details, and fetching a Tag ID based on disposition mappings.
    Author : Artee Varma
*******************************************************/

public class Nice_TaskDispositionHandler {
    @AuraEnabled
    public static void publishEvent(String jsonString){
        EventWrapper wrapper = (EventWrapper)JSON.deserialize(jsonString, EventWrapper.class);
        if (String.isBlank(jsonString)) {
            throw new AuraHandledException('no json found');
        }
        try {
            Task_NICE_Event__e event = new Task_NICE_Event__e(
                Event_Type__c = wrapper.Event_Type,
            Task_Id__c = wrapper.Task_Id,
            UserId__c = wrapper.UserId
                );
            System.debug('wrapper.UserId=> ' +  wrapper.UserId);
            System.debug('wrapper.Task_Id=> ' +  wrapper.Task_Id);
            
            EventBus.publish(event);
            System.debug('Task LWC published!');
        } catch (Exception e) {
            throw new AuraHandledException('Failed to publish Task NICE Event: ' + e.getMessage());
        }
    }
    class EventWrapper{
        @AuraEnabled
        public String Task_Id;
        @AuraEnabled
        public String UserId;
        @AuraEnabled
        public String Event_Type;
    }
    
    @AuraEnabled
    // String crmcallDispositionL1, String crmcallDispositionL2, String crmcallDispositionL3
    public static String updateTask(String taskId, String callDispositionL1, String callDispositionL2, String callDispositionL3, String updatedTaskComment ) {
      
        try {
            Task__c taskRecord = [SELECT Id,Calling_ID__c FROM Task__c WHERE Id = :taskId LIMIT 1];
            taskRecord.Call_Disposition_L1__c = callDispositionL1;
            taskRecord.Call_Disposition_L2__c = callDispositionL2;
            taskRecord.Call_Disposition_L3__c = callDispositionL3;

            /* Added by Ashwini form CRM Call disposition */
            taskRecord.Notes__c = updatedTaskComment;
           
            Update taskRecord;
            
            //get and store tag id based on call disposition
            //callDispositionL1, callDispositionL2, callDispositionL3
            String tagId = getTagId(callDispositionL1, callDispositionL2, callDispositionL3);
        	System.debug('tag id==> ' + tagId);
            
            if(taskRecord.Calling_ID__c != null && tagId != null){
                Nice_DispositionAPI.postToUpdateDisposition(taskRecord.Id, taskRecord.Calling_ID__c, tagId);
                return 'Task updated successfully and called Update Disposition API!';
            } else{
                System.debug('Unable to call Update Disposition API as Calling Id or Tag Id is missing!');
                return null;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error updating Task: ' + e.getMessage());
        }
    }
    
    // Method to fetch TagId based on dependent picklist values
    //String callDispositionL1, String callDispositionL2, String callDispositionL
    public static String getTagId(String callDispositionL1, String callDispositionL2, String callDispositionL3) {
      
        List<Nice_Calling_List_Disposition_Mapping__mdt> nice_cd_metadataRecords = new List<Nice_Calling_List_Disposition_Mapping__mdt>();
        
        // Query for Call Disposition values
        if (!String.isBlank(callDispositionL1) && !String.isBlank(callDispositionL2) && !String.isBlank(callDispositionL3)) {
            nice_cd_metadataRecords = [
            SELECT Id, Label, Call_Disposition_L1__c, Call_Disposition_L2__c, Call_Disposition_L3__c, Tag_Id__c
            FROM Nice_Calling_List_Disposition_Mapping__mdt
            WHERE Call_Disposition_L1__c = :callDispositionL1
            AND Call_Disposition_L2__c = :callDispositionL2
            AND Call_Disposition_L3__c = :callDispositionL3
            LIMIT 1
        ];
        }
    	
        // Return TagId if a matching record is found
        if (!nice_cd_metadataRecords.isEmpty()) {
            System.debug('Returned Tag Id: ' + nice_cd_metadataRecords[0].Tag_Id__c);
            return nice_cd_metadataRecords[0].Tag_Id__c;
        } else {
            System.debug('Returned Tag Id: Else ' );
            return null;
        }
    }


    /*Added by Ashwini to send tag id when call disposition fields changed manually from org*/
    public class TaskUpdateRequest {
    @InvocableVariable(required=true)
    public String taskId;

    @InvocableVariable(required=true)
    public String callingId;

    @InvocableVariable(required=true)
    public String tagId;
    }

    //refrenced in flow: Nice_UpdatetagIds.
      @InvocableMethod
    public static List<String> sendTagIdOnTaskUpdate(List<TaskUpdateRequest> requests) {
        List<String> responses = new List<String>();

        for (TaskUpdateRequest request : requests) {
            if (request.callingId != null && request.tagId != null) {
                Nice_DispositionAPI.postToUpdateDisposition(request.taskId, request.callingId, request.tagId);
                responses.add('Task updated successfully and called Update Disposition API!');
            } else {
                System.debug('Unable to call Update Disposition API as Calling Id or Tag Id is missing!');
                responses.add(null);
            }
        }
        return responses;
    }

    /*Added by Ashwini to send tag id when call disposition fields changed manually from org*/

}