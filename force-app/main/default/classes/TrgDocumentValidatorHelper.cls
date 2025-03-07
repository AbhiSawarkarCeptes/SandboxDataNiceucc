public class TrgDocumentValidatorHelper {
    public static void updateCDLLinkedEntityId(Map<Id, Document_validator__c> newMap, Map<Id, Document_validator__c> oldMap) {
        
        List<Id> existingLinkedEntityIds = new List<Id>();
        for (Id id : newMap.keySet()) {
            if (newMap.get(id).Approval_status__c == 'Approved' && oldMap.get(id).Approval_status__c != newMap.get(id).Approval_status__c) {
                existingLinkedEntityIds.add(id);
            }
        }

       if (!existingLinkedEntityIds.isEmpty())
       {
        List<ContentDocumentLink> cdlRecords = [
            SELECT LinkedEntityId, Visibility, ShareType, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :existingLinkedEntityIds
        ];

       
        List<ContentDocumentLink> cdlListToInsert = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : cdlRecords) {
            ContentDocumentLink cdlCloneRecord = cdl.clone();
            cdlCloneRecord.LinkedEntityId = newMap.get(cdl.LinkedEntityId).BR_doc_history_id__c; 
            cdlListToInsert.add(cdlCloneRecord);
        }

        
        if (!cdlListToInsert.isEmpty()) {
            insert cdlListToInsert; 
        }

      
        if (!cdlRecords.isEmpty()) {
            delete cdlRecords;
        }
           }
    }
        

}