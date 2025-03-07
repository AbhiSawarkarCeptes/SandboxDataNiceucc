public class TaskUtilityJSONHandler { 
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
                    String controlValue = controlEntries[index].getLabel();
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod(index, 6);
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
    public static String updateTask(String taskId, String callDispositionL1, String callDispositionL2, String callDispositionL3, String crmcallDispositionL1, String crmcallDispositionL2, String crmcallDispositionL3) {
        system.debug('callDispositionL1:-'+callDispositionL1);
        system.debug('callDispositionL2:-'+callDispositionL2);
        system.debug('callDispositionL3:-'+callDispositionL3);
        system.debug('crmcallDispositionL1:-'+crmcallDispositionL1);
        system.debug('crmcallDispositionL2:-'+crmcallDispositionL2);
        system.debug('crmcallDispositionL3:-'+crmcallDispositionL3);
        try {            
            Task__c taskRecord = [SELECT Id,Calling_ID__c FROM Task__c WHERE Id = :taskId LIMIT 1];
            system.debug('taskrecord:-'+taskRecord);           
            taskRecord.Call_Disposition_L1__c = callDispositionL1;
            taskRecord.Call_Disposition_L2__c = callDispositionL2;
            taskRecord.Call_Disposition_L3__c = callDispositionL3;
            taskRecord.CRM_Call_Disposition1__c = crmcallDispositionL1;
            taskRecord.CRM_Call_Disposition2__c = crmcallDispositionL2;
            taskRecord.CRM_Call_Disposition3__c = crmcallDispositionL3;          
            
            Update taskRecord;
            
            //get and store tag id based on call disposition
            String tagId = getTagId(callDispositionL1, callDispositionL2, callDispositionL3, crmcallDispositionL1, crmcallDispositionL2, crmcallDispositionL3);
            System.debug('tag id==>' + tagId);
            if(taskRecord.Calling_ID__c != null && tagId != null){                
                NiceAPIUpdateDisposition.postToUpdateDisposition(taskRecord.Id, taskRecord.Calling_ID__c, tagId);            
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
    public static String getTagId(String callDispositionL1, String callDispositionL2, String callDispositionL3, String crmcallDispositionL1, String crmcallDispositionL2, String crmcallDispositionL3) {
        
        List<Nice_Calling_List_Disposition_Mapping__mdt> nice_cd_metadataRecords = [
            SELECT Id,Label, Call_Disposition_L1__c, Call_Disposition_L2__c, Call_Disposition_L3__c, CRM_Call_Disposition1__c, CRM_Call_Disposition2__c, CRM_Call_Disposition3__c, Tag_Id__c
            FROM Nice_Calling_List_Disposition_Mapping__mdt
            WHERE (Call_Disposition_L1__c = :callDispositionL1
            AND Call_Disposition_L2__c = :callDispositionL2
            AND Call_Disposition_L3__c = :callDispositionL3)
            OR (CRM_Call_Disposition1__c = :crmcallDispositionL1
            AND CRM_Call_Disposition2__c = :crmcallDispositionL2
            AND CRM_Call_Disposition3__c = :crmcallDispositionL3)

            LIMIT 1            
        ];
        System.debug('nice_cd_metadataRecords' + nice_cd_metadataRecords);
        // Return TagId if a matching record is found
        if (!nice_cd_metadataRecords.isEmpty()) {
            system.debug('returned tag id' + nice_cd_metadataRecords[0].Tag_Id__c);
            return nice_cd_metadataRecords[0].Tag_Id__c;
        } else {           
            return null;
        }
    }
}