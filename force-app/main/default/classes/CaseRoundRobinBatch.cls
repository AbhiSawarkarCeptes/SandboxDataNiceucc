global class CaseRoundRobinBatch implements Schedulable, Database.Batchable<sObject>{

    public void execute(SchedulableContext ctx){
        Id batchJobId = Database.executeBatch(this,1);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
		List<Case_Roundrobin_Working_Hours__mdt> workingHoursList = [SELECT Queue_Name__c,Group_Name__c 
                                                                   FROM Case_Roundrobin_Working_Hours__mdt LIMIT 1];
        If(Test.isRunningTest()){
            workingHoursList[0].Queue_Name__c = 'Test';
        }
        String query = 'Select id,CaseNumber,RecordType.developerName,CreatedDate,OwnerId,Origin from case where Owner.Name =\''+String.escapeSingleQuotes(workingHoursList[0].Queue_Name__c) + '\' AND RecordType.developerName IN (\'CRM\',\'Customer_Care\') ORDER BY createdDate ASC';
		System.debug('query:'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
            System.debug('scope:'+scope);
			CaseRoundRobinTriggerHandler.updateCaseOwnerWithGroupMembers(scope,true);
    }   

    global void finish(Database.BatchableContext BC) {
    }
}