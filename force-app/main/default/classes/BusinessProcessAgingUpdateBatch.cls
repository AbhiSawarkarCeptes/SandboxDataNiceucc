global class BusinessProcessAgingUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {

    global final String query;

    global BusinessProcessAgingUpdateBatch(String query) {
        If(query == null){
            query = 'SELECT Ageing__c,End_Date__c,Status__c,Start_Date__c FROM Business_Process__c WHERE Status__c = \'In Progress\'';
        }
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Business_Process__c> bpUpdateList = new List<Business_Process__c>();

        for (sObject record : scope) {
            
            Business_Process__c bp = (Business_Process__c)record;
			system.debug(record.Id);
            DateTime workStartTime = DateTime.newInstance(bp.Start_Date__c.date(), Time.newInstance(9, 0, 0, 0));
            DateTime workEndTime = DateTime.newInstance(bp.Start_Date__c.date(), Time.newInstance(18, 0, 0, 0));
            workStartTime = workStartTime.addHours(4);
            workEndTime = workEndTime.addHours(4);
            String timeGap = HolidayUtility.calculateBusinessHours(bp.Start_Date__c.addHours(4), System.now().addHours(4), workStartTime, workEndTime);
            bp.Ageing__c = Decimal.valueOf(timeGap);
            bpUpdateList.add(bp);
        }

        if (bpUpdateList.size() > 0) {
            update bpUpdateList;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Your finish logic, if any
    }
}