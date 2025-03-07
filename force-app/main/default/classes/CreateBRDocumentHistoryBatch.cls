public class CreateBRDocumentHistoryBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Set<String> brIds;
    public Map<String, List<BR_Document_Mapping__c>> brToTypesOfDocument;

    public CreateBRDocumentHistoryBatch() {
        brIds = new Set<String>();
        brToTypesOfDocument = new Map<String, List<BR_Document_Mapping__c>>();
        List<BR_Document_Mapping__c> brDocumentMappings = [SELECT Id, Name, Document_Type__c, Expiry_Date__c, File_Title__c 
                                                           FROM BR_Document_Mapping__c
                                                           WHERE Name != NULL AND File_Title__c != NULL ORDER BY NAME];
        for (BR_Document_Mapping__c brDocument : brDocumentMappings) {
            brIds.add(brDocument.Name);
            if (brToTypesOfDocument.containsKey(brDocument.Name)) {
                List<BR_Document_Mapping__c> brDocuments = brToTypesOfDocument.get(brDocument.Name);
                brDocuments.add(brDocument);
                brToTypesOfDocument.put(brDocument.Name, brDocuments);
            } else {
                brToTypesOfDocument.put(brDocument.Name, new List<BR_Document_Mapping__c>{brDocument});
            }
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name FROM Broker_Registration__c WHERE Name IN :brIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Broker_Registration__c> brokerRegistrations) {
        List<ContentDocumentLink> toBeClonedContentDocumentLinks = new List<ContentDocumentLink>();
        Set<Id> processedContentDocumentIds = new Set<Id>();  // To keep track of already processed ContentDocumentIds
        List<Id> brRegistrationIds = new List<Id>();

        for (Broker_Registration__c br : brokerRegistrations) {
            brRegistrationIds.add(br.Id);
            List<BR_Document_Mapping__c> brDocuments = brToTypesOfDocument.get(br.Name);
            if (brDocuments != NULL && brDocuments.size() > 0) {
                Set<String> uniqueFileNames = new Set<String>();
                List<BR_Document_History__c> brDocumentHistoryToCreate = new List<BR_Document_History__c>();
                for (BR_Document_Mapping__c brDoc : brDocuments) {
                    if (uniqueFileNames.add('%' + brDoc.File_Title__c + '%')) {
                    
                    BR_Document_History__c docHis = new BR_Document_History__c();
                    docHis.Broker_Registration__c = br.Id;
                    docHis.Expiry_date__c = brDoc.Expiry_Date__c;
                    docHis.File_Name__c = brDoc.File_Title__c;
                    docHis.File_Type__c = brDoc.Document_Type__c;
                    
                    brDocumentHistoryToCreate.add(docHis);
                    }
                }
                if (brDocumentHistoryToCreate.size() > 0) {
                    insert brDocumentHistoryToCreate;
                }
                if (uniqueFileNames.size() > 0) {
                    List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId, Id, IsDeleted, LinkedEntityId,
                                                                      ShareType, SystemModstamp, Visibility, ContentDocument.Title 
                                                                      FROM ContentDocumentLink 
                                                                      WHERE LinkedEntityId = :br.Id AND 
                                                                      ContentDocument.Title LIKE :uniqueFileNames ORDER BY ContentDocument.CreatedDate DESC];
                    Map<String, List<ContentDocumentLink>> fileNameToContentDocumentLinks = new Map<String, List<ContentDocumentLink>>();

                    for (ContentDocumentLink cdl : contentDocumentLinks) {
                        String fileName = cdl.ContentDocument.Title;
                        if (fileName.length() > 5) {
                            String lastFiveChars = fileName.substring(fileName.length() - 5);
                            Integer dotIndex = lastFiveChars.indexOf('.');
                            if (dotIndex != -1) {
                                fileName = fileName.substring(0, fileName.length() - 5 + dotIndex);
                            }
                        }
                        if (!fileNameToContentDocumentLinks.containsKey(fileName)) {
                        fileNameToContentDocumentLinks.put(fileName, new List<ContentDocumentLink>());
                    }
                    fileNameToContentDocumentLinks.get(fileName).add(cdl);
                    }

                    List<BR_Document_History__c> brDocumentHistory = [SELECT Id, File_Name__c 
                                                                      FROM BR_Document_History__c 
                                                                      WHERE Broker_Registration__c IN :brRegistrationIds];
                    for (BR_Document_History__c brDocHis : brDocumentHistory) {
                        String fileName=brDocHis.File_Name__c;
                        if (fileName.length() > 5) {
                            String lastFiveChars = fileName.substring(fileName.length() - 5);
                            Integer dotIndex = lastFiveChars.indexOf('.');
                            if (dotIndex != -1) {
                                fileName = fileName.substring(0, fileName.length() - 5 + dotIndex);
                            }
                        }
                        if (fileNameToContentDocumentLinks.containsKey(fileName)) {
                        for (ContentDocumentLink cdLink : fileNameToContentDocumentLinks.get(fileName)) {
                        if (cdLink != null) {
                            brDocHis.Document_Link_Id__c = brDocHis.Id;
                            ContentDocumentLink newCdLink = cdLink.clone(false, true, false, false);
                            newCdLink.LinkedEntityId = brDocHis.Id;
                            if (!processedContentDocumentIds.contains(newCdLink.ContentDocumentId)) {
                                processedContentDocumentIds.add(newCdLink.ContentDocumentId);
                                toBeClonedContentDocumentLinks.add(newCdLink);
                            }
                        }
                    }
                        }
                    }
                }
            }
        }

        if (toBeClonedContentDocumentLinks.size() > 0) {
            Database.insert(toBeClonedContentDocumentLinks, false);
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Optional: Code to execute when the batch completes
    }
}
/*public class CreateBRDocumentHistoryBatch implements Database.Batchable<sObject>, Database.Stateful {
    public set<string> brIds;
    public map<string,list<BR_Document_Mapping__c>> brToTypesOfDocument;
    public CreateBRDocumentHistoryBatch(){
        brIds = new set<string>();
        brToTypesOfDocument = new map<string,list<BR_Document_Mapping__c>>();
        list<BR_Document_Mapping__c> brDocumentMappings = [SELECT Id,Name,Document_Type__c,Expiry_Date__c,File_Title__c 
                                                           FROM BR_Document_Mapping__c
                                                           WHERE Name != NULL AND File_Title__c != NULL];
        for(BR_Document_Mapping__c brDocument : brDocumentMappings){
            brIds.add(brDocument.Name);
            if(brToTypesOfDocument.containsKey(brDocument.Name)){
                list<BR_Document_Mapping__c> brDocuments = brToTypesOfDocument.get(brDocument.Name);
                brDocuments.add(brDocument);
                brToTypesOfDocument.put(brDocument.Name,brDocuments);
            }
            else{
                brToTypesOfDocument.put(brDocument.Name,new list<BR_Document_Mapping__c>{brDocument});
            }
        }
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name FROM Broker_Registration__c WHERE Name IN : brIds';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Broker_Registration__c> brokerRegistrations) {
        List<ContentDocumentLink> toBeClonedContentDocumentLinks = new List<ContentDocumentLink>();
        for(Broker_Registration__c br : brokerRegistrations){
            list<BR_Document_Mapping__c> brDocuments = brToTypesOfDocument.get(br.Name);
            if(brDocuments!=NULL && brDocuments.size()>0){
                set<string> uniqueFileNames = new set<string>();
                list<BR_Document_History__c> brDocumentHistoryToCreate = new list<BR_Document_History__c>();
                for(BR_Document_Mapping__c brDoc : brDocuments){
                    uniqueFileNames.add('%'+brDoc.File_Title__c+'%');
                    BR_Document_History__c docHis = new BR_Document_History__c();
                    docHis.Broker_Registration__c = br.Id;
                    docHis.Expiry_date__c = brDoc.Expiry_Date__c;
                    docHis.File_Name__c = brDoc.File_Title__c;
                    docHis.File_Type__c = brDoc.Document_Type__c;
                    brDocumentHistoryToCreate.add(docHis);
                }
                if(brDocumentHistoryToCreate.size()>0){
                    insert brDocumentHistoryToCreate;
                }
                if(uniqueFileNames.size()>0){
                    list<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,
                                                                      ShareType,SystemModstamp,Visibility,ContentDocument.Title 
                                                                      FROM ContentDocumentLink 
                                                                      where LinkedEntityId=:br.Id AND 
                                                                      ContentDocument.Title LIKE : uniqueFileNames];
                    map<string,ContentDocumentLink> fileNameToContentDocumentLink = new map<string,ContentDocumentLink>();
                    
                    for(ContentDocumentLink cdl : contentDocumentLinks){
                        string fileName = cdl.ContentDocument.Title;
                        list<string> fileNameList = fileName.split('.');
                        if(fileNameList.size()>0){
                            fileName = fileNameList[0];
                        }
                        fileNameToContentDocumentLink.put(fileName,cdl);
                    }
                    List<BR_Document_History__c> brDocumentHistory = [SELECT Id,File_Name__c 
                                                              FROM BR_Document_History__c 
                                                              WHERE ID IN : brDocumentHistoryToCreate];
                    for(BR_Document_History__c brDocHis : brDocumentHistory){
                        ContentDocumentLink cdLink = fileNameToContentDocumentLink.get(brDocHis.File_Name__c);
                        if(cdLink!=null){
                            brDocHis.Document_Link_Id__c = brDocHis.Id;
                            cdLink.Id = null;
                            cdLink.LinkedEntityId = brDocHis.Id;
                            toBeClonedContentDocumentLinks.add(cdLink);
                        }
                    }
                }
            }
        }
        
        if(toBeClonedContentDocumentLinks.size() > 0){
            insert toBeClonedContentDocumentLinks;
        }
    }
    public void finish(Database.BatchableContext BC) {
        
    }
}*/