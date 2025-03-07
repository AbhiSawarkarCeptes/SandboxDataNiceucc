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
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, List<String>>> getDependentPicklistValues(String dependentFieldApiNameL2, String dependentFieldApiNameL3) {
        
        Map<String, Map<String, List<String>>> result = new Map<String, Map<String, List<String>>>();
        
        // Get L1 -> L2 dependent values
        result.put('L1toL2', getDependentValues('Call_Disposition_L1__c', dependentFieldApiNameL2));
        
        // Get L2 -> L3 dependent values
        result.put('L2toL3', getDependentValues(dependentFieldApiNameL2, dependentFieldApiNameL3));
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, List<String>>> getCRMDependentPicklistValues(String dependentFieldApiNameL2, String dependentFieldApiNameL3) {
        
        Map<String, Map<String, List<String>>> result = new Map<String, Map<String, List<String>>>();
        
        // Get L1 -> L2 dependent values
        result.put('L1toL2', getDependentValues('CRM_Call_Disposition1__c', dependentFieldApiNameL2));
        
        // Get L2 -> L3 dependent values
        result.put('L2toL3', getDependentValues(dependentFieldApiNameL2, dependentFieldApiNameL3));
        
        return result;
    }
    
    private static Map<String, List<String>> getDependentValues(String controllingFieldApiName, String dependentFieldApiName) {
        
        Schema.DescribeFieldResult dependent = Schema.SObjectType.Task__c.fields.getMap().get(dependentFieldApiName).getDescribe();
        Schema.DescribeFieldResult controlling = Schema.SObjectType.Task__c.fields.getMap().get(controllingFieldApiName).getDescribe();
        
        List<Schema.PicklistEntry> controlEntries = controlling.getPicklistValues();
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        
        Map<String, List<String>> dependentPicklistValues = new Map<String, List<String>>();
        
        for (Schema.PicklistEntry entry : dependent.getPicklistValues()) {
            if (entry.isActive()) {
                List<String> base64chars =
                    String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                
                for (Integer index = 0; index < controlEntries.size(); index++) {
                    if (index >= controlEntries.size()) break;  // Ensure index is valid
                    
                    String controlValue = controlEntries[index].getLabel();
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod(index, 6);
                    
                    // Ensure bitIndex is within bounds
                    if (bitIndex >= base64chars.size()) {
                        System.debug('Skipping index due to out-of-bounds: ' + bitIndex);
                        continue;
                    }
                    
                    if ((base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0) continue;
                    
                    if (!dependentPicklistValues.containsKey(controlValue)) {
                        dependentPicklistValues.put(controlValue, new List<String>());
                    }
                    dependentPicklistValues.get(controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
    
    @AuraEnabled
    public static String updateTask(String taskId, String callDispositionL1, String callDispositionL2, String callDispositionL3, String crmcallDispositionL1, String crmcallDispositionL2, String crmcallDispositionL3, String updatedTaskComment ) {
      
        try {
            Task__c taskRecord = [SELECT Id,Calling_ID__c FROM Task__c WHERE Id = :taskId LIMIT 1];
           
            taskRecord.Call_Disposition_L1__c = callDispositionL1;
            taskRecord.Call_Disposition_L2__c = callDispositionL2;
            taskRecord.Call_Disposition_L3__c = callDispositionL3;

            /* Added by Ashwini form CRM Call disposition */
            taskRecord.CRM_Call_Disposition1__c = crmcallDispositionL1;
            taskRecord.CRM_Call_Disposition2__c = crmcallDispositionL2;
            taskRecord.CRM_Call_Disposition3__c = crmcallDispositionL3;
            /* Added by Ashwini form CRM Call disposition */
            taskRecord.Notes__c = updatedTaskComment;
           
            Update taskRecord;
            
            //get and store tag id based on call disposition
            String tagId = getTagId(callDispositionL1, callDispositionL2, callDispositionL3, crmcallDispositionL1, crmcallDispositionL2, crmcallDispositionL3);
        	
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
    public static String getTagId(String callDispositionL1, String callDispositionL2, String callDispositionL3,
    String crmcallDispositionL1, String crmcallDispositionL2, String crmcallDispositionL3) {
      
        List<Nice_Calling_List_Disposition_Mapping__mdt> nice_cd_metadataRecords = new List<Nice_Calling_List_Disposition_Mapping__mdt>();
        
        // Query for Call Disposition values
        if (!String.isBlank(callDispositionL1) && !String.isBlank(callDispositionL2) && !String.isBlank(callDispositionL3)) {
            System.debug('Hi m in first if');
            nice_cd_metadataRecords = [
            SELECT Id, Label, Call_Disposition_L1__c, Call_Disposition_L2__c, Call_Disposition_L3__c, Tag_Id__c
            FROM Nice_Calling_List_Disposition_Mapping__mdt
            WHERE Call_Disposition_L1__c = :callDispositionL1
            AND Call_Disposition_L2__c = :callDispositionL2
            AND Call_Disposition_L3__c = :callDispositionL3
            LIMIT 1
        ];
        }
         /* Added by Ashwini form CRM Call disposition */
        // If no record was found, query for CRM Call Disposition values
            if (!String.isBlank(crmcallDispositionL1) && !String.isBlank(crmcallDispositionL2) && !String.isBlank(crmcallDispositionL3)) {
                System.debug('Hi m in Second if');
                nice_cd_metadataRecords = [
            SELECT Id, Label, CRM_Call_Disposition1__c, CRM_Call_Disposition2__c, CRM_Call_Disposition3__c, Tag_Id__c
            FROM Nice_Calling_List_Disposition_Mapping__mdt
            WHERE CRM_Call_Disposition1__c = :crmcallDispositionL1
            AND CRM_Call_Disposition2__c = :crmcallDispositionL2
            AND CRM_Call_Disposition3__c = :crmcallDispositionL3
            LIMIT 1
        ];  
         /* Added by Ashwini form CRM Call disposition */
    }
            // Return TagId if a matching record is found
            if (!nice_cd_metadataRecords.isEmpty()) {
                System.debug('Returned Tag Id: ' + nice_cd_metadataRecords[0].Tag_Id__c);
                return nice_cd_metadataRecords[0].Tag_Id__c;
            } else {
                return null;
            }
        }
}