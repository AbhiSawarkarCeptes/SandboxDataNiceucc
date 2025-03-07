global class CRDateCalculationqueueable implements Queueable, Database.AllowsCallouts{
	global List<String> frrList = new List<String>();
    global CRDateCalculationqueueable(List<String> frrIdList){
        frrList = new list<String>(frrIdList);
    }
    global void execute(QueueableContext context) { 
        System.debug('frrlist:'+ frrList);
        List<Finance_Report_Records__c> fList = new List<Finance_Report_Records__c>();
        List<Finance_Report_Records__c> frrUpdateList = new List<Finance_Report_Records__c>();
       
        fList = [SELECT Id,Process_CR__c
                 FROM Finance_Report_Records__c 
                 WHERE Id IN : frrList];
        
        for(Finance_Report_Records__c fr : fList){
            fr.Process_CR__c = false;
            frrUpdateList.add(fr);
        }
       
        if(frrUpdateList != null && !frrUpdateList.isEmpty()) 
            Database.SaveResult[] resultLstfrr = Database.update(frrUpdateList);
    }

}