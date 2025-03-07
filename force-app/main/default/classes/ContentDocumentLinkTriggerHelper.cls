/*********************************************************************
 * Class Name  :   ContentDocumentLinkTriggerHelper
 * Description :   Helper class of ContentDocumentLinkTrigger
 * Created Date:   13/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History :
Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 13/02/2024
     *********************************************************************/
public without sharing class ContentDocumentLinkTriggerHelper {
    public static void updateTR(List<ContentDocumentLink> cdList) {
        List<PropStrength__Transaction_Requests__c> updateTransactionReq = new List<PropStrength__Transaction_Requests__c>();
        set<Id> cdId = new Set<Id>();
        for(ContentDocumentLink cd: cdList){
            String parentName = cd.LinkedEntityId.getSObjectType().getDescribe().getName();
            system.debug('object name::: ' + parentName);
            if(parentName.equalsIgnoreCase('PropStrength__Transaction_Requests__c')){
                cdId.add(cd.ContentDocumentId);
            }
        }
        
        if(!cdId.isEmpty()) {
            List<ContentDocumentLink> cdl = [SELECT ContentDocumentId, LinkedEntityId, ContentDocument.title FROM ContentDocumentLink WHERE ContentDocumentId IN :cdId];
            Set<Id> trIds = new Set<Id>();
            for(ContentDocumentLink cd: cdl){
                if(cd.LinkedEntityId != null){
                    trIds.add(cd.LinkedEntityId);
                }
            }
            Map<Id, PropStrength__Transaction_Requests__c> trMap = new Map<Id, PropStrength__Transaction_Requests__c>();
            if(!trIds.isEmpty()) {
                trMap = new Map<Id, PropStrength__Transaction_Requests__c>([SELECT Id, RecordType.Name FROM PropStrength__Transaction_Requests__c WHERE Id IN :trIds]);
            }
            if(!cdl.isEmpty() && cdl != null && cdl.size() > 0 && !trMap.isEmpty()) {
                for(ContentDocumentLink cd: cdl){
                    if(cd.LinkedEntityId != null && trMap.containsKey(cd.LinkedEntityId) && trMap.get(cd.LinkedEntityId).RecordType.Name == 'Title Deed Process'){
                        String parentName = cd.LinkedEntityId.getSObjectType().getDescribe().getName();
                        system.debug('object name::: ' + parentName);
                        if(parentName.equalsIgnoreCase('PropStrength__Transaction_Requests__c') && cd.ContentDocument.title.containsIgnoreCase('CertificateOfComplet')){
                            updateTransactionReq.add(new PropStrength__Transaction_Requests__c(DSR_Submitted_to_DLD__c = true, Id = cd.LinkedEntityId));
                        }
                    }
                }
                
                if(!updateTransactionReq.isEmpty()){
                    update updateTransactionReq;
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 05/02/2024 to clone File In Site Visit object
    public static void cloneFileInSiteVisit(List<ContentDocumentLink> cdList) {
        set<Id> cdId = new Set<Id>();
        for(ContentDocumentLink cd: cdList){
            String parentName = cd.LinkedEntityId.getSObjectType().getDescribe().getName();
            system.debug('object name::: ' + parentName);
            if(parentName.equalsIgnoreCase('Visitor_Registration__c')){
                cdId.add(cd.ContentDocumentId);
            }
        }
        
        System.debug('cdId****');
        System.debug(cdId);
        
        if(!cdId.isEmpty()) {
            List<ContentVersion> contList = [SELECT Id, ContentDocumentId, Title, VersionData, PathOnClient FROM ContentVersion WHERE ContentDocumentId IN :cdId];
            Map<Id, ContentVersion> contDocMp = new Map<Id, ContentVersion>();
            
            for(ContentVersion cv : contList) {
                contDocMp.put(cv.ContentDocumentId, cv);
            }
            
            System.debug('contDocMp****');
            System.debug(contDocMp);
            
            List<ContentDocumentLink> cdl = [SELECT ContentDocumentId, LinkedEntityId, ContentDocument.title FROM ContentDocumentLink WHERE ContentDocumentId IN :cdId];
            Set<Id> vrIds = new Set<Id>();
            for(ContentDocumentLink cd: cdl){
                if(cd.LinkedEntityId != null){
                    vrIds.add(cd.LinkedEntityId);
                }
            }
            Map<Id, Visitor_Registration__c> vrMap = new Map<Id, Visitor_Registration__c>();
            List<ContentVersion> cntVerList = new List<ContentVersion>();
            if(!vrIds.isEmpty()) {
                vrMap = new Map<Id, Visitor_Registration__c>([SELECT Id, Site_Visit_Form__c FROM Visitor_Registration__c WHERE Id IN :vrIds]);
            }
            System.debug('vrMap****');
            System.debug(vrMap);
            
            if(!cdl.isEmpty() && cdl != null && cdl.size() > 0 && !vrMap.isEmpty()) {
                for(ContentDocumentLink cd: cdl){
                    if(cd.LinkedEntityId != null && vrMap.containsKey(cd.LinkedEntityId) && vrMap.get(cd.LinkedEntityId).Site_Visit_Form__c != null){
                        String parentName = cd.LinkedEntityId.getSObjectType().getDescribe().getName();
                        system.debug('object name::: ' + parentName);
                        if(parentName.equalsIgnoreCase('Visitor_Registration__c')){
                            ContentVersion contentVersion = new ContentVersion();
                            contentVersion.Title = contDocMp.get(cd.ContentDocumentId).Title;
                            contentVersion.VersionData = contDocMp.get(cd.ContentDocumentId).VersionData;
                            contentVersion.PathOnClient = contDocMp.get(cd.ContentDocumentId).PathOnClient;
                            cntVerList.add(contentVersion);
                        }
                    }
                }
                
                if(!cntVerList.isEmpty()) {
                    System.debug('cntVerList****');
                    System.debug(cntVerList);
                    
                    insert cntVerList;
                    
                    List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();
                    
                    Map<String, Id> contentVersionIds = new Map<String, Id>();
                    for(ContentVersion cv : cntVerList) {
                        contentVersionIds.put(cv.Title, cv.Id);
                    }
                    
                    System.debug('contentVersionIds****');
                    System.debug(contentVersionIds);
                    
                    Map<Id, ContentVersion> contDocMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds.values()]);
                    
                    System.debug('contDocMap****');
                    System.debug(contDocMap);
                    
                    for(ContentDocumentLink cd: cdl){
                        if(cd.LinkedEntityId != null && vrMap.containsKey(cd.LinkedEntityId) && vrMap.get(cd.LinkedEntityId).Site_Visit_Form__c != null){
                            String parentName = cd.LinkedEntityId.getSObjectType().getDescribe().getName();
                            system.debug('object name::: ' + parentName);
                            if(parentName.equalsIgnoreCase('Visitor_Registration__c')){
                                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                                contentDocumentLink.ContentDocumentId = contDocMap.get(contentVersionIds.get(contDocMp.get(cd.ContentDocumentId).Title)).ContentDocumentId;
                                contentDocumentLink.LinkedEntityId = vrMap.get(cd.LinkedEntityId).Site_Visit_Form__c; // Link to the parent record (e.g., Opportunity, Case, etc.)
                                contentDocumentLink.Visibility = 'AllUsers'; // Set the visibility as needed
                                contentDocumentLinksToInsert.add(contentDocumentLink);
                            }
                        }
                    }
                    
                    System.debug('contentDocumentLinksToInsert****');
                    System.debug(contentDocumentLinksToInsert);
                    
                    if (!contentDocumentLinksToInsert.isEmpty()) {
                        insert contentDocumentLinksToInsert;
                    }
                }
            }
        }
    }
    
    //Create ContentDistribution
    public static void createContentDistribution(List<ContentDocumentLink> newCDList) {
        List<ContentDistribution> contentDistributionListToInsert = new List<ContentDistribution>();
        Map<String, String> contentDocIdToRelatedRecordId = new Map<String, String>();
        Map<String, String> contentDocIdToContentVersionId = new Map<String, String>();
        for(ContentDocumentLink cdlRecord : newCDList) {
            if(cdlRecord.ContentDocumentId != null && cdlRecord.LinkedEntityId != null) {
                Id relatedRecId =  cdlRecord.LinkedEntityId;
                System.debug('===> relatedRecId ' + relatedRecId);
                String objAPIName = relatedRecId.getSObjectType().getDescribe().getName();
                if(objAPIName == 'Related_Approvers__c' ||
                    objAPIName == 'PropStrength__Projects__c' ||
                    objAPIName == 'PropStrength__Property__c' ||
                    objAPIName == 'Cluster__c' ||
                    objAPIName == 'Events__c' ||
                    objAPIName == 'Sobha_Event__c' ||
                    objAPIName == 'Account' ||
                    objAPIName == 'Broker_Renewal__c' ||
                   objAPIName == 'CS_Unit_plan__c' ||
                   objAPIName == 'CS_Floor_Plan__c' ||
                    objAPIName == 'BR_Document_History__c' ||
                    objAPIName == 'PropStrength__Transaction_Requests__c' ||
                objAPIName == 'PropStrength__Application_Booking__c') {
                    contentDocIdToRelatedRecordId.put(cdlRecord.ContentDocumentId, cdlRecord.LinkedEntityId);
                }
            }
        }
        if(!contentDocIdToRelatedRecordId.keyset().isEmpty()) {
            for(ContentVersion cv : [SELECT Id, ContentDocumentId 
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN: contentDocIdToRelatedRecordId.keySet()]) {
                contentDocIdToContentVersionId.put(cv.ContentDocumentId, cv.Id);
            }
        }
        if(!contentDocIdToContentVersionId.keyset().isEmpty()) {
            for(string contentDocId : contentDocIdToContentVersionId.keySet()) {
                ContentDistribution cd = new ContentDistribution(Name = 'PublicShare');
                cd.RelatedRecordId = contentDocIdToRelatedRecordId.containskey(contentDocId) ? contentDocIdToRelatedRecordId.get(contentDocId) : null;
                cd.ContentVersionId = contentDocIdToContentVersionId.get(contentDocId);
                contentDistributionListToInsert.add(cd);
            }
        }
        if(!contentDistributionListToInsert.isEmpty()) {
            try {
                insert contentDistributionListToInsert;
            } catch(Exception e) {
                System.debug('===> Error ' + e.getMessage());
            }
        }
    }
    
    //Added by Nishank Manwani on 18-Sept-2024 to create same file on Ledger document history object
    public static void createFileOnLedgerDocHistory(List<ContentDocumentLink> cdlList) {
        List<ContentDocumentLink> linksToLdh = new List<ContentDocumentLink>();
        Map<String, ContentDocument> nameCDMap = new Map<String, ContentDocument>();
        Map<String, ContentDocumentLink> nameCDLMap = new Map<String, ContentDocumentLink>();
        List<String> existedDocument = new List<String>();
        Set<Id> contentDocumentIds = new Set<Id>();
        Set<Id> ledgerIds = new Set<Id>();
        List<Ledger_Document_History__c> ldhToInsert = new List<Ledger_Document_History__c>();
        
        for (ContentDocumentLink link : cdlList) {
            if (link.LinkedEntityId.getSObjectType() == PropStrength__Broker_Ledger__c.SObjectType) {
                ledgerIds.add(link.LinkedEntityId);
                contentDocumentIds.add(link.ContentDocumentId);
            }
        }
        
        Map<Id, ContentDocument> documents = new Map<Id, ContentDocument>([
            SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocumentIds
        ]);
        if(!ledgerIds.isEmpty()){
            
            List<ContentDocumentLink> cdlLists = [SELECT Id,ContentDocument.Title, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId In :ledgerIds];
            for (ContentDocumentLink doc : cdlLists) {
                existedDocument.add(doc.LinkedEntityId +''+doc.ContentDocument.Title);
            }
            
            Map<Id, Ledger_Document_History__c> relatedLdhRecs = new Map<Id, Ledger_Document_History__c>();
            Map<Id, Ledger_Document_History__c> tempMap = new Map<Id, Ledger_Document_History__c>([
            SELECT Id, Broker_Ledger__c FROM Ledger_Document_History__c WHERE Document_Type__c = 'Invoice' AND Broker_Ledger__c IN :ledgerIds
        ]);
            
            if(!tempMap.isEmpty()) {
                for(Id recId : tempMap.keySet()) {
                    if(tempMap.get(recId).Broker_Ledger__c != null) {
                        relatedLdhRecs.put(tempMap.get(recId).Broker_Ledger__c, tempMap.get(recId));
                    }
                }
            }
            Integer i = 1;
            for (ContentDocumentLink link : cdlList) {
                ContentDocument doc = documents.get(link.ContentDocumentId);
                if(doc!= null) {
                    System.debug(i + ' =======>'+ doc.Title);
                    System.debug(i + ' =======>'+ nameCDMap);
                    System.debug(i + ' =======>'+ existedDocument);
                }
                if (doc != null && doc.Title.containsIgnoreCase('invoice') && relatedLdhRecs.containsKey(link.LinkedEntityId)) {
                    linksToLdh.add(new ContentDocumentLink(
                        LinkedEntityId = relatedLdhRecs.get(link.LinkedEntityId).Id,
                        ContentDocumentId = link.ContentDocumentId,
                        ShareType = 'V'
                        ));
                }
                else if(doc != null && (!doc.Title.containsIgnoreCase('invoice') && !doc.Title.containsIgnoreCase('CertificateOfCompletion') && !existedDocument.contains(link.LinkedEntityId+'Cancelled Cheque Copy'))) {
                    ldhToInsert.add(new Ledger_Document_History__c(Broker_Ledger__c = link.LinkedEntityId, Document_Type__c = 'Cancelled Cheque Copy'));
                    nameCDMap.put(link.LinkedEntityId+'Cancelled Cheque Copy', new ContentDocument(Id=link.ContentDocumentId, Title = 'Cancelled Cheque Copy'));
                    nameCDLMap.put(link.LinkedEntityId+'Cancelled Cheque Copy', link);
                } else if(doc != null && (!doc.Title.containsIgnoreCase('invoice') && !doc.Title.containsIgnoreCase('CertificateOfCompletion') && !existedDocument.contains(link.LinkedEntityId+'Bank Account Screenshot'))) {
                    ldhToInsert.add(new Ledger_Document_History__c(Broker_Ledger__c = link.LinkedEntityId, Document_Type__c = 'Bank Account Screenshot'));
                    nameCDMap.put(link.LinkedEntityId+'Bank Account Screenshot', new ContentDocument(Id=link.ContentDocumentId, Title = 'Bank Account Screenshot'));
                    nameCDLMap.put(link.LinkedEntityId+'Bank Account Screenshot', link);
                }
            }
            if (!ldhToInsert.isEmpty()) {
                insert ldhToInsert;
            }
            if (!nameCDMap.values().isEmpty()) {
                update nameCDMap.values();
            }
            for(Ledger_Document_History__c rec : ldhToInsert) {
                if(nameCDLMap.containskey(rec.Broker_Ledger__c+''+rec.Document_Type__c)) {
                    linksToLdh.add(new ContentDocumentLink(
                        LinkedEntityId = rec.Id,
                        ContentDocumentId = nameCDLMap.get(rec.Broker_Ledger__c+''+rec.Document_Type__c).ContentDocumentId,
                        ShareType = 'V'
                    ));
                }
            }
            if (!linksToLdh.isEmpty()) {
                insert linksToLdh;
            }
        }
    }
}