global class BusinessProcessStepAgingUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {

    global final String query;

    global BusinessProcessStepAgingUpdateBatch(String query) {
        if(query == null){
            query = 'SELECT Accepted_Time__c,Final_Assigned_Time__c,Final_Accepted_Time__c,Completed_Time__c,Status__c,owner.Type,owner.Name,ownerId FROM Business_Process_Step__c WHERE Status__c = \'Open\'';
        }
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Business_Process_Step__c> bpsUpdateList = new List<Business_Process_Step__c>();

        for (sObject record : scope) {
            Business_Process_Step__c bps = (Business_Process_Step__c)record;
            if (bps.Final_Assigned_Time__c != null) {
                DateTime workStartTime = DateTime.newInstance(bps.Final_Assigned_Time__c.date(), Time.newInstance(9, 0, 0, 0));
                DateTime workEndTime = DateTime.newInstance(bps.Final_Assigned_Time__c.date(), Time.newInstance(18, 0, 0, 0));
                workStartTime = workStartTime.addHours(4);
                workEndTime = workEndTime.addHours(4);
                String timeGap = HolidayUtility.calculateBusinessHours(bps.Final_Assigned_Time__c.addHours(4), System.now().addHours(4), workStartTime, workEndTime);
                bps.Aging__c = Decimal.valueOf(timeGap);
                bpsUpdateList.add(bps);
            }
        }

        if (bpsUpdateList.size() > 0) {
            update bpsUpdateList;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Your finish logic, if any
    }
}