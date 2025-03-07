global class DemandsBatchPerMilestone implements Database.Batchable <sObject>, Database.AllowsCallouts {
    global Map<Id,List<Id>> unitMilestoneMap;
    global Set<Id> pmIdSet = new Set<Id>();
    global DemandsBatchPerMilestone(Map<Id,List<Id>> umMap) {
        unitMilestoneMap = umMap;
        for(Id u : umMap.keyset()) {
          for(Id p : umMap.get(u)) {
            pmIdSet.add(p);
          }
        }
        System.debug('unit milestone map in initialize batch:' + unitMilestoneMap);
    }
    global List < Payment_Milestones__c > start(Database.BatchableContext BC) {
        List < Payment_Milestones__c > pList = new List < Payment_Milestones__c > ();
        System.debug('unitMap in start:' + unitMilestoneMap);
        pList = [Select Id, Name, Quotation__r.Unit__r.Id from Payment_Milestones__c where Id in : pmIdSet];
        
        return pList;
    }

    global void execute(Database.BatchableContext BC, List < Payment_Milestones__C > scope) {
        for(Payment_Milestones__C pm : scope) {
            System.debug('Milestone Id:' + pm.Id);
            DemandManagementServices.raiseGroupDemandNew(pm.Quotation__r.Unit__r.Id, pm.Id);
        }
    }
    global void finish(Database.BatchableContext BC) {}
}