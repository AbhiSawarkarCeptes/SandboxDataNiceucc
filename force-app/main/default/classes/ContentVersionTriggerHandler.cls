public class ContentVersionTriggerHandler {
    
    public static void afterInsert(List<ContentVersion> newList) {
        linkToRecords(newList);
    }

    public static void linkToRecords(List<ContentVersion> newList) {
        Map<Id,ContentVersion> recordsToLink = new Map<Id,ContentVersion>();

        for(ContentVersion cv : newList) {
            if( String.isNotBlank(cv.Related_Record_ID_fileupload__c) ) 
                recordsToLink.put(cv.ContentDocumentId, cv);
        }

        if( !recordsToLink.isEmpty() ) {
            List<ContentDocumentLink> linksToDelete = new List<ContentDocumentLink>();
            List<ContentDocumentLink> linksToCreate = new List<ContentDocumentLink>();
            for(ContentDocumentLink link : [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :recordsToLink.keySet()
            ]) {
                ContentDocumentLink cloneLink = link.clone();
                cloneLink.LinkedEntityId = recordsToLink.get(link.ContentDocumentId).Related_Record_ID_fileupload__c;
                linksToCreate.add(cloneLink);

                linksToDelete.add(link);
            }

            insert linksToCreate;
            delete linksToDelete;
        }
        
    }
}