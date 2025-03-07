global class CollectionReportBatch implements Database.Batchable<sObject>{
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID,Name FROM Booking__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Booking__c> bookingList) {
        List<Finance_Report_Records__c> frrToUpdate = new List<Finance_Report_Records__c>();
        Map<String,Finance_Report_Records__c> frrMap = new Map<String,Finance_Report_Records__c>();
        List<Finance_Report_Records__c> frrList = new List<Finance_Report_Records__c>();
        List<string> bId = new List<String>();
        
        for(Booking__c b : bookingList){
            bId.add(b.name);
        }
        
        frrList = [select id,process_cr__c,Booking_No__c from Finance_Report_Records__c where Booking_No__c IN : bid ORDER BY LastmodifiedDate DESC];
        System.debug('i am frrList'+frrList);
        
        for(Finance_Report_Records__c fr : frrList){
            if(!frrMap.containsKey(fr.Booking_No__c)){
                frrMap.put(fr.Booking_No__c,fr);
            }
        }
        
        for(Finance_Report_Records__c frr : frrMap.values()){
            frr.Process_CR__c = true;
            frrToUpdate.add(frr);
            
        }
        System.debug('I am frrmap:'+frrMap.values());
        
        if(frrToUpdate != null){
            List<Database.SaveResult> results = Database.update(frrToUpdate, false);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}