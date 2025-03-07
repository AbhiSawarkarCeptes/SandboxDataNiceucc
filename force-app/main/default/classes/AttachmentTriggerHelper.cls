public class AttachmentTriggerHelper {
    public static void createFile(List<Attachment> attList) {
        List<ContentVersion> cntVerList = new List<ContentVersion>();

        // Iterate through the inserted attachments
        for (Attachment attachment : attList) {
            // Create a new ContentVersion record
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = attachment.Name;
            contentVersion.VersionData = attachment.Body;
            contentVersion.PathOnClient = attachment.Name;
            cntVerList.add(contentVersion);
        }

        if(!cntVerList.isEmpty()) {
            insert cntVerList;

            Map<Id, ContentDocumentLink> contentDocumentLinksToInsert = new Map<Id, ContentDocumentLink>();

            Map<String, Id> contentVersionIds = new Map<String, Id>();
            for(ContentVersion cv : cntVerList) {
                contentVersionIds.put(cv.Title, cv.Id);
            }

            Map<Id, ContentVersion> contDocMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds.values()]);
            
            for (Attachment attachment : attList) {
                // Create a new ContentDocumentLink record
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.ContentDocumentId = contDocMap.get(contentVersionIds.get(attachment.Name)).ContentDocumentId;
                contentDocumentLink.LinkedEntityId = attachment.ParentId; // Link to the parent record (e.g., Opportunity, Case, etc.)
                contentDocumentLink.Visibility = 'AllUsers'; // Set the visibility as needed
                if(!contentDocumentLinksToInsert.containsKey(attachment.ParentId))
                	contentDocumentLinksToInsert.put(attachment.ParentId, contentDocumentLink);
            }

            // Insert the ContentDocumentLink records
            if (!contentDocumentLinksToInsert.isEmpty()) {
                insert contentDocumentLinksToInsert.values();
            }
        }
    }
}