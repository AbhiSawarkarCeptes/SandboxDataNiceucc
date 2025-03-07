public class BLDocumentHistoryRetriever_PS {
@AuraEnabled(cacheable=true)
    public static List<docWrapper> getLedgerDocumentFileDetails(String recordId) {
        Id recId = Id.valueOf(recordId);
        
        // Query to get the BR_Document_History__c records
        List<Ledger_Document_History__c> ledgerDocHistoryList = [
            SELECT Id, Name, Document_Type__c, Broker_Ledger__c
            FROM Ledger_Document_History__c
            WHERE Broker_Ledger__c = :recId
        ];

        // Extract the IDs of the BR_Document_History__c records
        List<Id> documentHistoryIds = new List<Id>();
        for (Ledger_Document_History__c historyRecord : ledgerDocHistoryList) {
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
        for (Ledger_Document_History__c ledgerDoc : ledgerDocHistoryList) {
            List<ContentDocumentLink> links = documentLinksMap.get(ledgerDoc.Id);
            List<String> fileIds = new List<String>();
            if (links != null) {
                for (ContentDocumentLink link : links) {
                  fileIds.add(link.ContentDocument.LatestPublishedVersionId);
                }
            }
            docWrapperList.add(new docWrapper(
                ledgerDoc.Id,
                ledgerDoc.Name,
                ledgerDoc.Document_Type__c,
                ledgerDoc.Document_Type__c,
                fileIds
            ));
        }

        return docWrapperList;
    }

    public class docWrapper {
        @AuraEnabled
        public Id ledgerDocId { get; set; } 
        
        @AuraEnabled
        public String ledgerDocName { get; set; }

        @AuraEnabled
        public String fileType { get; set; }
  
        @AuraEnabled
        public String baseUrl {get; set;}

        @AuraEnabled
        public String fileName { get; set; }

        @AuraEnabled
        public String fileIds { get; set; }

        public docWrapper(Id ledgerDocId,String ledgerDocName, String fileType, String fileName, List<String> fileIds) {
            this.ledgerDocId = ledgerDocId;
            this.ledgerDocName= ledgerDocName;
            this.fileType = fileType;
            this.fileName = fileName;
            this.fileIds = JSON.serialize(fileIds);
            this.baseUrl = URL.getOrgDomainURL().toExternalForm();
        }
    }
}