public class brDocumentHistoryRetriever_Renewal {
@AuraEnabled(cacheable=true)
    public static List<docWrapper> getBRDocumentFileDetails(String recordId) {
        Id recId = Id.valueOf(recordId);
        
        // Query to get the BR_Document_History__c records
        List<BR_Document_History__c> brDocHistoryList = [
            SELECT Id, Name,File_Name__c, File_Type__c
            FROM BR_Document_History__c
            WHERE Broker_Renewal__c = :recId
        ];

        // Extract the IDs of the BR_Document_History__c records
        List<Id> documentHistoryIds = new List<Id>();
        for (BR_Document_History__c historyRecord : brDocHistoryList) {
            documentHistoryIds.add(historyRecord.Id);
        }

        // Query ContentDocumentLink object using the extracted IDs as LinkedEntityId
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.FileType, ContentDocument.Title,ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :documentHistoryIds
            ORDER BY ContentDocument.CreatedDate DESC
        ];

        // Map to hold all ContentDocumentLinks for each LinkedEntityId
        Map<Id, List<ContentDocumentLink>> documentLinksMap = new Map<Id, List<ContentDocumentLink>>();

        for (ContentDocumentLink link : contentDocumentLinks) {
            if (!documentLinksMap.containsKey(link.LinkedEntityId)) {
                documentLinksMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
            }
            documentLinksMap.get(link.LinkedEntityId).add(link);
        }

        // List to store the docWrapper objects
        List<docWrapper> docWrapperList = new List<docWrapper>();

        // Populate the docWrapperList with the document details
        for (BR_Document_History__c brDoc : brDocHistoryList) {
            List<ContentDocumentLink> links = documentLinksMap.get(brDoc.Id);
            List<String> fileIds = new List<String>();
            if (links != null) {
                for (ContentDocumentLink link : links) {
                  fileIds.add(link.ContentDocument.LatestPublishedVersionId);
                }
            }
            docWrapperList.add(new docWrapper(
                brDoc.Id,
                brDoc.Name,
                brDoc.File_Type__c,
                brDoc.File_Name__c,
                fileIds
            ));
        }

        return docWrapperList;
    }

    public class docWrapper {
        @AuraEnabled
        public Id brDocId { get; set; } 
        
        @AuraEnabled
        public String brDocName { get; set; }

        @AuraEnabled
        public String fileType { get; set; }
  
        @AuraEnabled
        public String baseUrl {get; set;}

        @AuraEnabled
        public String fileName { get; set; }

        @AuraEnabled
        public String fileIds { get; set; }

        public docWrapper(Id brDocId,String brDocName, String fileType, String fileName, List<String> fileIds) {
            this.brDocId = brDocId;
            this.brDocName=brDocName;
            this.fileType = fileType;
            this.fileName = fileName;
            this.fileIds = JSON.serialize(fileIds);
            this.baseUrl = URL.getOrgDomainURL().toExternalForm();
        }
    }
}