/* Bypass Framework Enabled */
trigger trgDemand on Demand__c (after insert, after update, before delete, after undelete) {

    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
    if(bypassSettingInstance.Bypass_All__c || bypassSettingInstance.Bypass_All_Triggers__c || bypassSettingInstance.Bypass_Demand_Trigger__c){ 
        System.debug('Inside ByPass Setting Triggered ->'+bypassSettingInstance);
        return; 
    }
    
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
            
    if(Trigger.isInsert && Trigger.isAfter){
        List<Id> dIdList = new List<Id>();
        for(Demand__c d : trigger.new) {
            dIdList.add(d.Id);
        } 
        TriggerDemandHandler.rollUpsFieldsToTheirBuckets(dIdList);
        createDebitLedgers(dIdList);
    }
    
    Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];
    if(Trigger.isUpdate && Trigger.isAfter) {
        List<Id> dIdList = new List<Id>();
        List<Id> dIdListForReverse = new List<id>();
        Map<Id, List<Demand__c>> bookDemandMap = new Map<Id, List<Demand__c>>();
        for(Demand__c d : trigger.new) {
            dIdList.add(d.Id);
            if(string.isNotBlank(d.Demand_Status__c) && d.Demand_Status__c.equals('Reversed')){
                If(string.isNotBlank(trigger.oldMap.get(d.Id).Demand_Status__c) && !trigger.oldMap.get(d.Id).Demand_Status__c.equals('Reversed'))
                    dIdListForReverse.add(d.Id); 
                else if(string.isBlank(trigger.oldMap.get(d.Id).Demand_Status__c))
                    dIdListForReverse.add(d.Id);                        
            }
        }
        system.debug('d list::: ' + dIdListForReverse);
        if(checkRecursion.isFirstRun()){ 
            TriggerDemandHandler.rollUpsFieldsToTheirBuckets(dIdList);
            system.debug('i am didlist'+dIdListForReverse);
            if(dIdListForReverse.size() > 0){
                TriggerDemandHandler.cleanUpLedgersAfterReversal(dIdListForReverse);
            }
        }               
    }
    
    if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)) {
        
        if (TriggerFinanceReportRecordHandler.afterUpdateTriggerDemandFirstRun) {
            List<Id> demandsIds = new List<id>();
            for (Demand__c r:Trigger.new) {
                demandsIds.add(r.Id);
            }
            List<Finance_Report_Records__c> frrrecordsList = new List<Finance_Report_Records__c>();
            List<Id> frrIdsList = new List<id>();
            frrrecordsList = [SELECT ID 
                              FROM Finance_Report_Records__c
                              WHERE Demand__c 
                              IN :demandsIds];
            if(frrrecordsList.size()>0){
            for(Finance_Report_Records__c frr : frrrecordsList){
                frrIdsList.add(frr.Id);
            }
            
            TriggerFinanceReportRecordHandler.updateFRR(frrIdsList);
            TriggerFinanceReportRecordHandler.afterUpdateTriggerDemandFirstRun = false;
            }
        }
        
        if(TPMDemandHandler.afterUpdateTriggerDemandFirstRun == true){
            TPMDemandHandler.afterUpdateTriggerDemandFirstRun = false;
            List<Demand__C> demandsList = new List<Demand__c>();
            for (Demand__c r:Trigger.new) {
                if(tpmMetaData.Active__c == true){
                	demandsList.add(r); 
                    TPMDemandHandler.createDemandTPM(demandsList);
                }   
            }
            
        }
    }
    
    public static void createDebitLedgers(List<Id> dIdlist){
        String tempQuery = '';
        for (Integer i = 1; i <= 15; i++) {
            tempQuery += 'Charge_' + i + '_Name__c' + ',';
            tempQuery += 'Charge_' + i + '_Demanded__c' + ',';
            tempQuery += 'Charge_' + i + '_Paid__c' + ',';
            tempQuery += 'Charge_' + i + '_Tax_Demanded__c' + ',';
            tempQuery += 'Charge_' + i + '_Tax_Paid__c' + ',';
            tempQuery += 'Charge_' + i + '_SGST__c' + ',';
            tempQuery += 'Charge_' + i + '_CGST__c' + ',';
            tempQuery += 'Charge_' + i + '_Lookup__r.ChargeBucket__c,';
            
        }
        if (tempQuery.length() > 0 && tempQuery.substring(tempQuery.length() - 1).equals(','))
            tempQuery = tempQuery.substring(0, tempQuery.length() - 1);
        String DemandQuery = 'Select Id, Name,Agreement_Value_Demanded_New__c,charge_1_lookup__r.Name,booking__r.Opportunity__c, Service_Tax_on_Agreement_Value_Demanded__c, Agreement_Value_Paid__c,Service_Tax_on_Agreement_Value_Paid__c,Debit_Demanded__c,Debit_Tax_Demanded__c,Debit_SGST__c, Debit_CGST__c,Debit_Paid__c,Debit_Type__c,Invoice_Date__c,' + tempQuery + ' from Demand__c where id in :dIdList';
        List<Demand__c> dList = new List<Demand__c>();
        dList = Database.Query(demandQuery);
        List <Ledger__c> llist = new List<Ledger__c>();
        for(Demand__c d: dList) {
            system.debug('d.Agreement_Value_Demanded_New__c '+d.Agreement_Value_Demanded_New__c);
            if(d.Agreement_Value_Demanded_New__c != 0) {
                Ledger__c l = new Ledger__c();
                l.Charge_Name__c = 'Flat Cost';
                l.Amount__c = d.Agreement_Value_Demanded_New__c;
                l.Activity__c = 'Debit';
                l.Demand__c = d.Id;
                l.Opportunity__c = d.Booking__r.Opportunity__c;
                l.Transaction_Date__c = d.Invoice_Date__c;
                llist.add(l);
            }
            if(d.Service_Tax_on_Agreement_Value_Demanded__c != 0) {
                Ledger__c l = new Ledger__c();
                l.Charge_Name__c = 'Flat Cost';
                l.Amount__c = d.Service_Tax_on_Agreement_Value_Demanded__c;
                l.Activity__c = 'Debit';
                l.Demand__c = d.Id;
                l.Opportunity__c = d.Booking__r.Opportunity__c;
                l.Transaction_Date__c = d.Invoice_Date__c;
                l.Tax_Ledger__c = true;
                llist.add(l);
            }
            if(d.Debit_Demanded__c != 0) {
                Ledger__c l = new Ledger__c();
                l.Charge_Name__c = d.Debit_Type__c;
                l.Amount__c = d.Debit_Demanded__c;
                l.Activity__c = 'Debit';
                l.Demand__c = d.Id;
                l.Opportunity__c = d.Booking__r.Opportunity__c;
                l.Transaction_Date__c = d.Invoice_Date__c;
                llist.add(l);
            }
            if(d.Debit_Tax_Demanded__c != 0) {
                Ledger__c l = new Ledger__c();
                l.Charge_Name__c = d.Debit_Type__c;
                l.Amount__c = d.Debit_Tax_Demanded__c;
                l.Activity__c = 'Debit';
                l.Demand__c  = d.Id;
                l.Opportunity__c = d.Booking__r.Opportunity__c;
                l.Transaction_Date__c = d.Invoice_Date__c;
                l.Tax_Ledger__c = true;
                llist.add(l);
            }
            for( Integer i= 1; i <=15; i++) {
                if (d.getSObject('Charge_' + i + '_Lookup__r') != null &&
                    (String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
                    String.isNotBlank((String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
                    (String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != 'Agreement Value') {
                        if(d.get('Charge_' + i + '_Demanded__c') != null && (Decimal) d.get('Charge_' + i + '_Demanded__c') != 0) {
                            Ledger__c l = new Ledger__c();
                            l.Charge_Name__c = (String) d.getSObject('Charge_' + i + '_Lookup__r').get('Name');
                            l.Amount__c = (Decimal) d.get('Charge_' + i + '_Demanded__c');
                            l.Activity__c = 'Debit';
                            l.Demand__c = d.Id;
                            l.Opportunity__c = d.Booking__r.Opportunity__c;
                            l.Transaction_Date__c = d.Invoice_Date__c;
                            llist.add(l);
                        }
                        
                        if(d.get('Charge_' + i + '_Tax_Demanded__c') != null && (Decimal) d.get('Charge_' + i + '_Tax_Demanded__c') != 0) {
                            Ledger__c l = new Ledger__c();
                            l.Charge_Name__c = (String) d.getSObject('Charge_' + i + '_Lookup__r').get('Name');
                            l.Amount__c = (Decimal) d.get('Charge_' + i + '_Tax_Demanded__c');
                            l.Activity__c = 'Debit';
                            l.Demand__c = d.Id;
                            l.Opportunity__c = d.Booking__r.Opportunity__c;
                            l.Transaction_Date__c = d.Invoice_Date__c;
                            l.Tax_Ledger__c = true;
                            llist.add(l);
                        }
                    }
            }
        }
        if(!llist.isEmpty() && llist.size() > 0) {
            insert llist;
        }
    }

    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){//added for SOB-1944
        if(Trigger.isInsert){
            X_XSD_Util.processInit(Trigger.oldMap,Trigger.newMap);
        }
        
        List<Recalculate_Collections__e> rcEvents =  new List<Recalculate_Collections__e>();
        for(Demand__c demand : Trigger.new){
            rcEvents.add(new Recalculate_Collections__e(Demand_Id__c = demand.Id));
        }
        if(!rcEvents.isEmpty()) EventBus.publish(rcEvents);
    }
}