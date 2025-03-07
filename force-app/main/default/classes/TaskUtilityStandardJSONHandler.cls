public class TaskUtilityStandardJSONHandler { 
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
    public static Map<String, Map<String, List<String>>> getDependentPicklistValues(String dependentFieldApiNameL1, String dependentFieldApiNameL2) {
    
        Map<String, Map<String, List<String>>> result = new Map<String, Map<String, List<String>>>();
        
        // Get L1 -> L2 dependent values
        result.put('L1toL2', getDependentValues('Call_Attempt_Status__c', dependentFieldApiNameL2));
        
        // Get L2 -> L3 dependent values
        //result.put('L2toL3', getDependentValues(dependentFieldApiNameL2, dependentFieldApiNameL3));
        
        return result;
    }
/*
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, List<String>>> getCRMDependentPicklistValues(String dependentFieldApiNameL2, String dependentFieldApiNameL3) {
    System.debug('dependentFieldApiNameL2:' +dependentFieldApiNameL2);
    System.debug('dependentFieldApiNameL3:' +dependentFieldApiNameL3);        
    
    Map<String, Map<String, List<String>>> result = new Map<String, Map<String, List<String>>>();
        
        // Get L1 -> L2 dependent values
        result.put('L1toL2', getDependentValues('CRM_Call_Disposition1__c', dependentFieldApiNameL2));
        
        // Get L2 -> L3 dependent values
        result.put('L2toL3', getDependentValues(dependentFieldApiNameL2, dependentFieldApiNameL3));
        
        return result;
    }
    */
    private static Map<String, List<String>> getDependentValues(String controllingFieldApiName, String dependentFieldApiName) {

     System.debug('controllingFieldApiName:' +controllingFieldApiName);
    System.debug('dependentFieldApiName:' +dependentFieldApiName);      

        Schema.DescribeFieldResult dependent = Schema.SObjectType.Task.fields.getMap().get(dependentFieldApiName).getDescribe();
        Schema.DescribeFieldResult controlling = Schema.SObjectType.Task.fields.getMap().get(controllingFieldApiName).getDescribe();
        
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
    public static String updateTask(String taskId, String callDispositionL1, String callDispositionL2) {
        system.debug('callDispositionL1:-'+callDispositionL1);
        system.debug('callDispositionL2:-'+callDispositionL2);
    
        try {
            // Validate input parameters
            if (String.isBlank(taskId) || String.isBlank(callDispositionL1) || String.isBlank(callDispositionL2)) {
                throw new AuraHandledException('All parameters are required');
            }

            List<Task> taskRecords = [SELECT Id,Call_Attempt_Status__c,Sub_Dispositions__c,WhoId FROM Task WHERE Id = :taskId LIMIT 1];
            if (taskRecords.isEmpty()) {
                throw new AuraHandledException('Task record not found');
            }
            
            Task taskRecord = taskRecords[0];
            system.debug('taskrecord:-'+taskRecord);
            
            // Update fields only if values have changed
            if (taskRecord.Call_Attempt_Status__c != callDispositionL1 || 
                taskRecord.Sub_Dispositions__c != callDispositionL2) {
                    
                taskRecord.Call_Attempt_Status__c = callDispositionL1;
                taskRecord.Sub_Dispositions__c = callDispositionL2;
                update taskRecord;
            } else {
                return 'No changes detected - Task not updated';
            }
            
            //get and store tag id based on call disposition
            String tagIdString = getTagId(callDispositionL1, callDispositionL2);
                              
                if (taskRecord.Call_Attempt_Status__c != null && tagIdString != null) {                
                    List<String> tagIds = tagIdString.split(',');
  
                for (String tagId : tagIds) {
                     NiceAPIUpdateDisposition.postToUpdateDisposition(taskRecord.Id, taskRecord.Call_Attempt_Status__c, tagId);
                     }
            
                //NiceAPIUpdateDisposition.postToUpdateDisposition(taskRecord.Id, taskRecord.Calling_ID__c, tagId);            
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
    public static String getTagId(String callDispositionL1, String callDispositionL2) {
    
    List<String> tagIds = new List<String>();

    // Query for Call Disposition values
    if (callDispositionL1 != null && callDispositionL2 != null) {
        List<Nice_Calling_List_Disposition_Mapping__mdt> callDispositionRecords = [
            SELECT Tag_Id__c
            FROM Nice_Calling_List_Disposition_Mapping__mdt
            WHERE Call_Attempt_Status__c = :callDispositionL1
            AND Sub_Dispositions__c = :callDispositionL2
        ];
        for (Nice_Calling_List_Disposition_Mapping__mdt record : callDispositionRecords) {
            if (record.Tag_Id__c != null) {
                tagIds.add(record.Tag_Id__c);
            }
        }
    }
/*
    // Query for CRM Call Disposition values
    if (crmcallDispositionL1 != null && crmcallDispositionL2 != null && crmcallDispositionL3 != null) {
        List<Nice_Calling_List_Disposition_Mapping__mdt> crmDispositionRecords = [
            SELECT Tag_Id__c
            FROM Nice_Calling_List_Disposition_Mapping__mdt
            WHERE CRM_Call_Disposition1__c = :crmcallDispositionL1
            AND CRM_Call_Disposition2__c = :crmcallDispositionL2
            AND CRM_Call_Disposition3__c = :crmcallDispositionL3
        ];
        for (Nice_Calling_List_Disposition_Mapping__mdt record : crmDispositionRecords) {
            if (record.Tag_Id__c != null) {
                tagIds.add(record.Tag_Id__c);
            }
        }
    }
*/
    System.debug('Collected Tag Ids: ' + tagIds);

    // Return all Tag Ids as a comma-separated string (or null if empty)
    return tagIds.isEmpty() ? null : String.join(tagIds, ',');
}

}
