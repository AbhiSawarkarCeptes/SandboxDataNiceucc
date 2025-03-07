global class ContentDistributionBatch Implements Database.Batchable<sObject>, Schedulable {
    global List<ContentDocumentLink> start(Database.BatchableContext BC) {
        return [SELECT Id, ContentDocumentId, LinkedEntityId 
                FROM ContentDocumentLink 
                WHERE ContentDocumentId IN (SELECT Id 
                                            FROM ContentDocument 
                                            WHERE CreatedBy.Name = 'Broker Account Site Guest User')];
    }

    public void execute(SchedulableContext context) {
        ContentDistributionBatch batch = new ContentDistributionBatch();
        Database.executeBatch(batch);
    }

    global void execute(Database.BatchableContext BC, List<ContentDocumentLink> scope) {
        List<ContentDocumentLink> createDistribution = new List<ContentDocumentLink>();
        List<ContentDocumentLink> tempCdlList = new List<ContentDocumentLink>();
        Map<Id, BR_Document_History__c> bhMap = new Map<Id, BR_Document_History__c>();
        Set<Id> bhParentId = new Set<Id>();

        for(ContentDocumentLink cd : scope) {
            if(cd.LinkedEntityId != null) {
                String parentName = cd.LinkedEntityId.getSObjectType().getDescribe().getName();
                if(parentName.equalsIgnoreCase('BR_Document_History__c')) {
                    bhParentId.add(cd.LinkedEntityId);
                    tempCdlList.add(cd);
                }
            }
        }

        if(!tempCdlList.isEmpty()) {
            if(!bhParentId.isEmpty()) {
                bhMap = new Map<Id, BR_Document_History__c>([SELECT Id FROM BR_Document_History__c WHERE Id IN :bhParentId AND (Broker_Renewal__r.Modified_by_guest_user__c = true OR Broker_Account__r.Modified_by_guest_user__c = true) AND Content_Distribution_Created__c = FALSE]);
            }

            Map<Id, BR_Document_History__c> updateBrHistory = new Map<Id, BR_Document_History__c>();
            
            for(ContentDocumentLink cd : tempCdlList) {
                String parentName = cd.LinkedEntityId.getSObjectType().getDescribe().getName();
                if(parentName.equalsIgnoreCase('BR_Document_History__c') && !bhMap.isEmpty() && bhMap.containsKey(cd.LinkedEntityId)) {
                    createDistribution.add(cd);
                    if(!updateBrHistory.containsKey(cd.LinkedEntityId)) {
                        updateBrHistory.put(cd.LinkedEntityId, new BR_Document_History__c(Id=cd.LinkedEntityId, Content_Distribution_Created__c = true));
                    }
                }
            }

            if(!createDistribution.isEmpty()) {
                ContentDocumentLinkTriggerHelper.createContentDistribution(createDistribution);
            }
            if(!updateBrHistory.isEmpty()) {
                update updateBrHistory.values();
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        Datetime nextRunTime = System.now().addMinutes(2);
        String cronExp = nextRunTime.format('s m H d M \'?\' yyyy');
        //System.schedule('ContentDistributionBatch_5minutes'+System.now().addDays(Integer.valueof((Math.random() * 100))), cronExp, new ContentDistributionBatch() );
    }
}