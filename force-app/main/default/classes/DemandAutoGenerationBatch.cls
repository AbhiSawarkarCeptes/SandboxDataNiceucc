global class DemandAutoGenerationBatch implements Schedulable, Database.Batchable<sObject> , Database.Stateful{

    public void execute(SchedulableContext ctx){
        Id batchJobId = Database.executeBatch(this,1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name,Booking__c,Demand__c,Error_Message__c,Is_Demand_Raised__c,Milestone_Name__c,Payment_Milestones__c,Raise_Demand_Date__c,Skip_Auto_Demand_Generation__c,Unit__c FROM Raise_Demand_Tracker__c WHERE Is_Demand_Raised__c = false AND Payment_Milestones__r.is_demand_raised__c = false AND Skip_Auto_Demand_Generation__c = false AND Demand__c = null ORDER BY Name';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Raise_Demand_Tracker__c> RDTList) {
        System.debug('RDTList '+RDTList);
        Map<String,String> paymentMilestonesId = new Map<String,String>();
        Set<String> Payment_MilestonesMap = new Set<String>();
        Set<String> demandIds = new Set<String>();
        List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
        
        for(Raise_Demand_Tracker__c rdt : RDTList){
            paymentMilestonesId.put(rdt.Id,rdt.Payment_Milestones__c);
            Payment_MilestonesMap.add(rdt.Payment_Milestones__c);
        }
        try {
            System.debug('paymentMilestonesId -> '+Payment_MilestonesMap);
            List<Demand__c> DemandInserted = DemandGeneratorManager.createMultipleDemand(Payment_MilestonesMap);
            String returnResult = null;
            
            if (DemandInserted.size() > 0) {
                for (Demand__c demand : DemandInserted) {
                    demandIds.add(demand.Id);
                }
                
                if(System.label.isAllowToSendAutoDemandRaiseEmail == 'Send Email'){
                	returnResult = DemandGeneratorManager.sendDemandToCustomer(demandIds);
                }else{
                    returnResult = 'Email Sending Not Allowed';
                }
                for (Demand__c demand : DemandInserted) {
                    for (Raise_Demand_Tracker__c rdt : RDTList) {
                        if(rdt.Payment_Milestones__c == demand.Payment_Milestones__c){
                            rdt.is_demand_raised__c = true;
                            rdt.Demand__c = demand.Id;
                            rdt.Error_Message__c = returnResult;
                        }
                    }
                }
                
                update RDTList;
                
                for (String pmId : Payment_MilestonesMap) {
                    Payment_Milestones__c pm = new Payment_Milestones__c();
                    pm.Id = pmId;
                    pm.is_demand_raised__c = true;
                    pmList.add(pm);
                    
                }
                update pmList;
            }
        } catch (Exception e) {
            for (Raise_Demand_Tracker__c rdt : RDTList) {
                rdt.is_demand_raised__c = false;
                rdt.Error_Message__c = 'Time : '+System.Now()+ ' - Error :'+e.getMessage() + ' - Line number :' +e.getLineNumber() + 'Stack Trace :' +e.getStackTraceString();
            }   
            update RDTList;
        }

    }

    global void finish(Database.BatchableContext BC) {}

    @InvocableMethod(label='retryAutoRaisedDemand' description='It will retry to create or if demand is their it will retry sending Demand To Customer' category='All')
    public static void retryAutoRaisedDemand(List<Raise_Demand_Tracker__c> RDTList){
        System.debug('RDTList '+RDTList);
        
        Map<String,String> paymentMilestonesId = new Map<String,String>();
        Set<String> Payment_MilestonesMap = new Set<String>();
        Set<String> demandIds = new Set<String>();
        Set<String> demandToOnlySend = new Set<String>();

        List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();

        for(Raise_Demand_Tracker__c rdt : RDTList){
            System.debug('RDT -->'+rdt);
            System.debug('RDT -->'+rdt.Demand__c);
            if(rdt.Demand__c == null){
                paymentMilestonesId.put(rdt.Id,rdt.Payment_Milestones__c);
                Payment_MilestonesMap.add(rdt.Payment_Milestones__c);
            }else{
                demandToOnlySend.add(rdt.Demand__c);
            }
        }
        try {
            System.debug('paymentMilestonesId -> '+Payment_MilestonesMap);
            List<Demand__c> DemandInserted = new List<Demand__c>();
            if(Payment_MilestonesMap.size() > 0){
                DemandInserted = DemandGeneratorManager.createMultipleDemand(Payment_MilestonesMap);
            }
            String returnResult = null;
            
            if (DemandInserted.size() > 0) {
                for (Demand__c demand : DemandInserted) {
                    demandIds.add(demand.Id);
                }
                
                if(System.label.isAllowToSendAutoDemandRaiseEmail == 'Send Email'){
                	returnResult = DemandGeneratorManager.sendDemandToCustomer(demandIds);
                }else{
                    returnResult = 'Email Sending Not Allowed';
                }
                for (Demand__c demand : DemandInserted) {
                    for (Raise_Demand_Tracker__c rdt : RDTList) {
                        if(rdt.Payment_Milestones__c == demand.Payment_Milestones__c){
                            rdt.is_demand_raised__c = true;
                            rdt.Demand__c = demand.Id;
                            rdt.Error_Message__c = returnResult;
                        }
                    }
                }
                
                update RDTList;
                
                for (String pmId : Payment_MilestonesMap) {
                    Payment_Milestones__c pm = new Payment_Milestones__c();
                    pm.Id = pmId;
                    pm.Invoice_Date__c = System.Today();
                    pm.is_demand_raised__c = true;
                    pmList.add(pm);
                    
                }
                update pmList;
            }
            if(demandToOnlySend.size() > 0){
                if(System.label.isAllowToSendAutoDemandRaiseEmail == 'Send Email'){
                	returnResult = DemandGeneratorManager.sendDemandToCustomer(demandToOnlySend);
                }else{
                    returnResult = 'Email Sending Not Allowed';
                }
                for (String dmnd : demandToOnlySend) {
                    for (Raise_Demand_Tracker__c rdt : RDTList) {
                        if(rdt.Demand__c == dmnd){
                            rdt.is_demand_raised__c = true;
                            rdt.Error_Message__c = returnResult;
                        }
                    }
                }
                
                update RDTList;
            }
        } catch (Exception e) {
            for (Raise_Demand_Tracker__c rdt : RDTList) {
                rdt.is_demand_raised__c = false;
                rdt.Error_Message__c = 'Time : '+System.Now()+ ' - Error :'+e.getMessage() + ' - Line number :' +e.getLineNumber() + 'Stack Trace :' +e.getStackTraceString();
            }   
            update RDTList;
        }
    }
    
}