global class DemandsBatch implements Database.Batchable <sObject>, Database.AllowsCallouts {
    global Set<Id> demandsToBeRaisedIds;
    global Id milestoneId;
    global DemandsBatch(Set<Id> groupDemandsId) {
        demandsToBeRaisedIds = groupDemandsId;
    }
    global List < Unit__c > start(Database.BatchableContext BC) {
        List < Unit__c > uList = new List < Unit__c > ();
        uList = [Select Id, Name from unit__c where Id in : demandsToBeRaisedIds];
        return uList;
    }

    global void execute(Database.BatchableContext BC, List < Unit__c > scope) {
        for(Unit__c unit : scope) {
            System.debug('unit Id:' + unit.Id);
            DemandManagementServices.raiseGroupDemandNew(unit.Id, milestoneId);
        }
    }

    global void finish(Database.BatchableContext BC) {}
}