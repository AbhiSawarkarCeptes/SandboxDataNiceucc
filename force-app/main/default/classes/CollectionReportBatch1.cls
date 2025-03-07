global class CollectionReportBatch1 implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id,process_cr__c,Booking_No__c from Finance_Report_Records__c where process_cr__c = true';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Finance_Report_Records__c> frrList) {
        System.debug('frrlist:'+ frrList);
        List<Finance_Report_Records__c> frrUpdateList = new List<Finance_Report_Records__c>();
        
        for(Finance_Report_Records__c fr : frrList){
            fr.Process_CR__c = false;
            frrUpdateList.add(fr);
        }
        
        if(frrUpdateList != null && !frrUpdateList.isEmpty()) 
            Database.SaveResult[] resultLstfrr = Database.update(frrUpdateList,false);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}