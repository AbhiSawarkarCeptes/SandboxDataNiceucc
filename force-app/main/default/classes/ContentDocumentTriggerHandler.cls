public class ContentDocumentTriggerHandler {
    
    Public static void restrictDeletionOfPaymentRequestFiles(List<ContentDocument> oldList){
        
        if(!Content_Document_Setting__c.getInstance().Allow_Payment_Request_file_deletion__c){
            Set<Id> prAssociatedDocIds = new Set<Id>();
            for (ContentDocumentLink docLink : [
                SELECT Id, ContentDocumentId, LinkedEntity.Type
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :Trigger.oldMap.keySet()
            ]) {
                if (docLink.LinkedEntity?.Type == 'Payment_Request__c') {
                    prAssociatedDocIds.add(docLink.ContentDocumentId);
                }
            }
            if (!prAssociatedDocIds.isEmpty()) {
                for (ContentDocument doc : oldList) {
                    if (prAssociatedDocIds.contains(doc.Id)) {
                        doc.addError(
                            'You cannot delete this File.'
                        );
                    }
                }
            }
        }
    }
    
    public static void restrictDeletionOfFiles(List<ContentDocument> oldList, List<String> objectList){
        if(!BrokerFileDeletionSettings__c.getInstance().Allow_File_Deletion__c){
            Set<Id> prAssociatedDocIds = new Set<Id>();
            Boolean isBrokerCatg= false;
            Map<Id, Id> brokerWithCDocMap = new Map<Id, Id>();
            
            for (ContentDocumentLink docLink : [
                SELECT Id, ContentDocumentId, LinkedEntity.Type, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :Trigger.oldMap.keySet()
            ]) {
                system.debug('~~~~Obj: '+docLink.LinkedEntity?.Type);
                if(docLink.LinkedEntity?.Type=='Broker_Registration__c'){
                    isBrokerCatg = true;
                    brokerWithCDocMap.put(docLink.ContentDocumentId, docLink.LinkedEntityId);
                }
                system.debug('~~~~Map: '+brokerWithCDocMap);
                if (objectList.contains(docLink.LinkedEntity?.Type)) {
                    prAssociatedDocIds.add(docLink.ContentDocumentId);
                }
            }
            
            Map<Id, Broker_Registration__c> brokerList = new Map<Id, Broker_Registration__c>([Select Id, Make_Readyonly__c from Broker_Registration__c where Id IN: brokerWithCDocMap.values()]);
            
            if (!prAssociatedDocIds.isEmpty()) {
                for (ContentDocument doc : oldList) {
                    if (prAssociatedDocIds.contains(doc.Id) && !isBrokerCatg) {
                        doc.addError('You cannot delete this File.'); 
                    } else if(isBrokerCatg && brokerWithCDocMap.containsKey(doc.id)){
                        Id brokerId = brokerWithCDocMap.get(doc.id);
                        if(brokerList.containsKey(brokerId) && brokerList.get(brokerId).Make_Readyonly__c){
                            doc.addError('You are not allowed to Delete the files after Audit Approval'); 
                        }
                    }
                }
            }
        }
    }
}