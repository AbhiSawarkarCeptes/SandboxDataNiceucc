public class FileUtility {
    public static void copyFile(string sourceId, string targetId){
        List<ContentDocumentLink> cdlList = [
            SELECT Id,ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :sourceId 
        ];
        List<ContentDocumentLink> cdlListToInsert = new List<ContentDocumentLink>();
        for(ContentDocumentLink cdl : cdlList){
            ContentDocumentLink newCDL = new ContentDocumentLink(
                ContentDocumentId = cdl.ContentDocumentId,
                LinkedEntityId = targetId,
                Visibility = 'AllUsers'
            );
            cdlListToInsert.add(newCDL);
        }
        if(cdlListToInsert.size()>0){
            insert cdlListToInsert;
        }
    }
}