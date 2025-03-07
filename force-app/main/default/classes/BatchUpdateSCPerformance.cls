global class BatchUpdateSCPerformance implements Database.Batchable <sObject>,Schedulable{
 global List < Sobha_Connect__c> start(Database.BatchableContext BC) {
    return [SELECT ID FROM Sobha_Connect__c ];
 }
 global void execute(SchedulableContext sc)
    {
        database.executebatch(new BatchUpdateSCPerformance(),100);
        
    }
 global void execute(Database.BatchableContext BC, List < Sobha_Connect__c > scope) {
    BatchUpdateCPPerformance.calculateSalesForCurrentAndLastYear(new List<Channel_Partner__c>(), scope);
    BatchUpdateCPPerformance.calculateNoOfSites(new List<Channel_Partner__c>(), scope);
     update scope;
 }

 global void finish(Database.BatchableContext BC) {}
}