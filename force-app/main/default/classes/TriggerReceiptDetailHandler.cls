public with sharing class TriggerReceiptDetailHandler {

    public static boolean afterUpdateTriggerFirstRun = true;
    public static boolean afterInsertTriggerFirstRun = true;
    
    public static void creditToDemands(Set<Id> rdIdSet) {
        String tempQuery ='';
        for (Integer i = 2; i <= 15; i++) {
            tempQuery += 'Charge_' + i + '_Amount_Apportioned__c' + ',';
            tempQuery += 'Charge_' + i + '_Tax_Apportioned__c' + ',';
        }
        if (tempQuery.length() > 0 && tempQuery.substring(tempQuery.length() - 1).equals(','))
            tempQuery = tempQuery.substring(0, tempQuery.length() - 1);
        List<Receipt_Details__c> rdList = new List<Receipt_Details__c>();
        
        String rdQuery = 'Select Id, Name,Debit_Amount_Apportioned__c, Debit_Tax_Apportioned__c, Interest_on_late_amount_paid__c, Tax_On_Interest_on_Late_Amount_Paid__c,Interest_Amount_Paid__c,Interest_Amount_Waived__c,Tax_on_Interest_Paid__c,Tax_On_Interest_Waived__c, Demand__c, Demand__r.Id,Charge_1_Amount_Apportioned__c, Charge_1_Tax_Apportioned__c,' + tempQuery + 
                            ' from Receipt_Details__c where id in :rdIdSet';
        System.debug('rdQuery:' + rdQuery);
        
        rdList = Database.Query (rdQuery);
        Set<Id> demandIdSet = new Set<Id>();
        if(rdList != null) {
            for(Receipt_details__c rd : rdList){
                demandIdSet.add(rd.Demand__c);
            }
        
            List<Demand__c> dList = new List<Demand__c>();
            String tempQuery1 = '';
            for (Integer i = 1; i <= 15; i++) {
                tempQuery1 += 'Charge_' + i + '_Paid__c' + ',';
                tempQuery1 += 'Charge_' + i + '_Tax_Paid__c' + ',';
            }
            if (tempQuery1.length() > 0 && tempQuery1.substring(tempQuery1.length() - 1).equals(','))
                tempQuery1 = tempQuery1.substring(0, tempQuery1.length() - 1);
            String demandQuery = 'Select Id, Name,Debit_Paid__c, Debit_Tax_Paid__c, Agreement_Value_Paid__c, Service_Tax_on_Agreement_Value_Paid__c,Interest_On_Paid_Amount__c,Tax_On_Interest_On_Paid_Amount__c,Total_Interest_Amount_Paid__c,Total_Interest_Amount_Waived__c,Total_Interest_Tax_Paid__c,Total_Interest_Tax_Waived__c,' + tempQuery1 + 
                                ' from Demand__c where id in :demandIdSet';
            dList = Database.Query (demandQuery);
            
            Map<Id, Demand__c> dMap = new Map<Id, Demand__c>();
            if(dlist != null && !dList.isEmpty()) {
                for(Demand__c d : dList){
                    dMap.put(d.Id, d);
                }
                for(Receipt_Details__c rd : rdList) {
                    System.debug('rd: in receipt details credit to demands trigger:' + rd);
                    Demand__c d = dMap.get(rd.Demand__r.Id);
                    if(rd.Interest_on_late_amount_paid__c != null)
                        d.Interest_On_Paid_Amount__c += rd.Interest_on_late_amount_paid__c;
                    if(rd.Tax_On_Interest_on_Late_Amount_Paid__c != null)
                        d.Tax_On_Interest_On_Paid_Amount__c += rd.Tax_On_Interest_on_Late_Amount_Paid__c;                    
                    if(rd.Interest_Amount_Paid__c != null)
                        d.Total_Interest_Amount_Paid__c += rd.Interest_Amount_Paid__c;
                    if(rd.Tax_on_Interest_Paid__c != null)
                        d.Total_Interest_Tax_Paid__c += rd.Tax_on_Interest_Paid__c; 
                    if(rd.Interest_Amount_Waived__c != null)
                        d.Total_Interest_Amount_Waived__c += rd.Interest_Amount_Waived__c;
                    if(rd.Tax_On_Interest_Waived__c != null){
                        d.Total_Interest_Tax_Waived__c += rd.Tax_On_Interest_Waived__c;
                    }
                    if(rd.Debit_Amount_Apportioned__c != null){
                        d.Debit_Paid__c += rd.Debit_Amount_Apportioned__c;
                    }
                    if(rd.Debit_Tax_Apportioned__c != null)
                        d.Debit_Tax_Paid__c += rd.Debit_Tax_Apportioned__c;
                        
                    if(rd.Charge_1_Amount_Apportioned__c != null)
                        d.Agreement_Value_Paid__c += rd.Charge_1_Amount_Apportioned__c;
                    if(rd.Charge_1_Tax_Apportioned__c != null){
                        d.Service_Tax_on_Agreement_Value_Paid__c += rd.Charge_1_Tax_Apportioned__c;
                    }
                    for(Integer i = 2; i<=15; i++) {
                     System.debug('Inside for loop');
                        if((Decimal) rd.get('Charge_' + i + '_Amount_Apportioned__c') != null)
                            d.put('Charge_' + i + '_Paid__c', (Decimal) d.get('Charge_' + i + '_Paid__c') + (Decimal) rd.get('Charge_' + i + '_Amount_Apportioned__c'));
                        if((Decimal) rd.get('Charge_' + i + '_Tax_Apportioned__c') != null){
                            d.put('Charge_' + i + '_Tax_Paid__c', (Decimal) d.get('Charge_' + i + '_Tax_Paid__c') + (Decimal) rd.get('Charge_' + i + '_Tax_Apportioned__c'));
                           System.debug('Charge_' + i + '_Tax_Paid__c' + ':::: ' + 'Charge_' + i + '_Tax_Paid__c');
                        }
                    }
                }
                update dList;
            }
        }
        
    }

    public static void debitFromDemands(Set<Id> rdIdSet) {
        String tempQuery ='';
        for (Integer i = 1; i <= 15; i++) {
            tempQuery += 'Charge_' + i + '_Amount_Apportioned__c' + ',';
            tempQuery += 'Charge_' + i + '_Tax_Apportioned__c' + ',';
        }
        if (tempQuery.length() > 0 && tempQuery.substring(tempQuery.length() - 1).equals(','))
            tempQuery = tempQuery.substring(0, tempQuery.length() - 1);
        List<Receipt_Details__c> rdList = new List<Receipt_Details__c>();
        String rdQuery = 'Select Id, Name,Debit_Amount_Apportioned__c, Debit_Tax_Apportioned__c,Interest_on_late_amount_paid__c, Tax_On_Interest_on_Late_Amount_Paid__c,Interest_Amount_Paid__c,Interest_Amount_Waived__c,Tax_on_Interest_Paid__c,Tax_On_Interest_Waived__c, Demand__c, Demand__r.Id,' + tempQuery + 
                            ' from Receipt_Details__c where id in :rdIdSet';
        rdList = Database.Query (rdQuery);
        Set<Id> demandIdSet = new Set<Id>();
        Map<Id, List<Receipt_Details__c>> demandReceiptMap = new Map<Id, List<Receipt_Details__c>>();
        if(rdList != null && !rdList.isEmpty()) {
            for(Receipt_details__c rd : rdList){
                demandIdSet.add(rd.Demand__c);
                List<Receipt_Details__c> tempList = new List<Receipt_Details__c>();
                if(demandReceiptMap.containsKey(rd.Demand__r.Id)) {
                    tempList = demandReceiptMap.get(rd.Demand__r.Id);
                } 
                tempList.add(rd);
                demandReceiptMap.put(rd.Demand__r.Id,tempList);
            }
        
            List<Demand__c> dList = new List<Demand__c>();
            String tempQuery1 = '';
            for (Integer i = 1; i <= 15; i++) {
                tempQuery1 += 'Charge_' + i + '_Paid__c' + ',';
                tempQuery1 += 'Charge_' + i + '_Tax_Paid__c' + ',';
            }
            if (tempQuery1.length() > 0 && tempQuery1.substring(tempQuery1.length() - 1).equals(','))
                tempQuery1 = tempQuery1.substring(0, tempQuery1.length() - 1);
            String demandQuery = 'Select Id, Name,Debit_Paid__c, Debit_Tax_Paid__c, Agreement_Value_Paid__c, Service_Tax_on_Agreement_Value_Paid__c,Interest_On_Paid_Amount__c,Tax_On_Interest_On_Paid_Amount__c,Total_Interest_Amount_Paid__c,Total_Interest_Amount_Waived__c,Total_Interest_Tax_Paid__c,Total_Amount_Paid__c, Total_Interest_Tax_Waived__c,' + tempQuery1 + 
                                ' from Demand__c where id in :demandIdSet';
            dList = Database.Query (demandQuery);
            
            Map<Id, Demand__c> dMap = new Map<Id, Demand__c>();
            if(dlist != null) {
                for(Demand__c d : dList){
                    dMap.put(d.Id, d);
                }
                for(Id dId : demandReceiptMap.keySet()) {
                    Demand__c d = dMap.get(dId);
                    for(Receipt_Details__c rd : demandReceiptMap.get(dId)) {
                        if(rd.Interest_on_late_amount_paid__c != null)
                            d.Interest_On_Paid_Amount__c -= rd.Interest_on_late_amount_paid__c;
                        if(rd.Tax_On_Interest_on_Late_Amount_Paid__c != null)
                            d.Tax_On_Interest_On_Paid_Amount__c -= rd.Tax_On_Interest_on_Late_Amount_Paid__c;
                        if(rd.Interest_Amount_Paid__c != null)
                            d.Total_Interest_Amount_Paid__c -= rd.Interest_Amount_Paid__c;
                        if(rd.Tax_on_Interest_Paid__c != null)
                            d.Total_Interest_Tax_Paid__c -= rd.Tax_on_Interest_Paid__c; 
                        if(rd.Interest_Amount_Waived__c != null)
                            d.Total_Interest_Amount_Waived__c -= rd.Interest_Amount_Waived__c;
                        if(rd.Tax_On_Interest_Waived__c != null)
                            d.Total_Interest_Tax_Waived__c -= rd.Tax_On_Interest_Waived__c;
                        if(rd.Debit_Amount_Apportioned__c != null)
                            d.Debit_Paid__c -= rd.Debit_Amount_Apportioned__c;
                        if(rd.Debit_Tax_Apportioned__c != null)
                            d.Debit_Tax_Paid__c -= rd.Debit_Tax_Apportioned__c;
                        if(rd.Charge_1_Amount_Apportioned__c != null)
                            d.Agreement_Value_Paid__c -= rd.Charge_1_Amount_Apportioned__c;
                   ///// Added by Neha on 17/6/19                            
                        if(rd.Charge_1_Tax_Apportioned__c != null)
                            d.Service_Tax_on_Agreement_Value_Paid__c -= rd.Charge_1_Tax_Apportioned__c;
                        for(Integer i =2; i<=15; i++) {
                            if((Decimal) rd.get('Charge_' + i + '_Amount_Apportioned__c') != null)
                                d.put('Charge_' + i + '_Paid__c', (Decimal) d.get('Charge_' + i + '_Paid__c') - (Decimal) rd.get('Charge_' + i + '_Amount_Apportioned__c'));
                            if((Decimal) rd.get('Charge_' + i + '_Tax_Apportioned__c') != null)
                                d.put('Charge_' + i + '_Tax_Paid__c', (Decimal) d.get('Charge_' + i + '_Tax_Paid__c') - (Decimal) rd.get('Charge_' + i + '_Tax_Apportioned__c'));
                        }
                        System.debug('Amount on demand ' + d.Name + ' after deducting receipt details:' + rd.Name + ':' + d);
                    }
                }                
                update dList;
            }
        }        
    }

    public static void createCreditLedgers(Set<Id> rdIdSet) {
        String tempQuery ='';
        for (Integer i = 1; i <= 15; i++) {
            tempQuery += 'Charge_' + i + '_Amount_Apportioned__c' + ',';
            tempQuery += 'Charge_' + i + '_Tax_Apportioned__c' + ',';
            tempQuery += 'Charge' + i + 'Name__c' + ',';
        }
        if (tempQuery.length() > 0 && tempQuery.substring(tempQuery.length() - 1).equals(','))
            tempQuery = tempQuery.substring(0, tempQuery.length() - 1);
        List<Receipt_Details__c> rdList = new List<Receipt_Details__c>();
        String rdQuery = 'Select Id, Name,Debit_Charge_Name__c, Debit_Amount_Apportioned__c, Debit_Tax_Apportioned__c, Demand__c,Receipts__r.Opportunity__c, Transaction_Date__c,Receipts__c, Receipts__r.Id,' + tempQuery + 
                            ' from Receipt_Details__c where id in :rdIdSet';
        rdList = Database.Query (rdQuery);
        Set<Id> demandIdSet = new Set<Id>();
        List<Ledger__c> llist = new List<Ledger__c>();
        if(rdList != null) {
            for(Receipt_details__c rd : rdList) {
                if(rd.Debit_Amount_Apportioned__c != null && rd.Debit_Amount_Apportioned__c != 0) {
                    Ledger__c l = new Ledger__c();
                        l.Charge_Name__c = rd.Debit_Charge_Name__c;
                        l.Amount__c = rd.Debit_Amount_Apportioned__c;
                        l.Activity__c = 'Credit';
                        l.Demand__c = rd.Demand__c;
                        l.Receipt__c = rd.Receipts__r.Id;
                        l.Receipt_Details__c = rd.Id;
                        l.Opportunity__c = rd.Receipts__r.Opportunity__c;
                        l.Transaction_Date__c = rd.Transaction_Date__c;
                        llist.add(l);
                }
                if(rd.Debit_Tax_Apportioned__c != null && rd.Debit_Tax_Apportioned__c != 0) {
                    Ledger__c l = new Ledger__c();
                        l.Charge_Name__c = rd.Debit_Charge_Name__c;
                        l.Amount__c = rd.Debit_Tax_Apportioned__c;
                        l.Activity__c = 'Credit';
                        l.Demand__c = rd.Demand__c;
                        l.Receipt__c = rd.Receipts__r.Id;
                        l.Receipt_Details__c = rd.Id;
                        l.Opportunity__c = rd.Receipts__r.Opportunity__c;
                        l.Transaction_Date__c = rd.Transaction_Date__c;
                        l.Tax_ledger__c = true;
                        l.Transaction_Date__c = rd.Transaction_Date__c;
                        llist.add(l);
                }
                if(rd.Charge_1_Amount_Apportioned__c != null && rd.Charge_1_Amount_Apportioned__c != 0) {
                    Ledger__c l = new Ledger__c();
                        l.Charge_Name__c = 'Flat Cost';
                        l.Amount__c = rd.Charge_1_Amount_Apportioned__c;
                        l.Activity__c = 'Credit';
                        l.Demand__c = rd.Demand__c;
                        l.Receipt__c = rd.Receipts__r.Id;
                        l.Receipt_Details__c = rd.Id;
                        l.Opportunity__c = rd.Receipts__r.Opportunity__c;
                        l.Transaction_Date__c = rd.Transaction_Date__c;
                        llist.add(l);
                }
                if(rd.Charge_1_Tax_Apportioned__c != null && rd.Charge_1_Tax_Apportioned__c != 0) {
                    Ledger__c l = new Ledger__c();
                        l.Charge_Name__c = 'Flat Cost';
                        l.Amount__c = rd.Charge_1_Tax_Apportioned__c;
                        l.Activity__c = 'Credit';
                        l.Demand__c = rd.Demand__c;
                        l.Receipt__c = rd.Receipts__r.Id;
                        l.Receipt_Details__c = rd.Id;
                        l.Opportunity__c = rd.Receipts__r.Opportunity__c;
                        l.Transaction_Date__c = rd.Transaction_Date__c;
                        l.Tax_ledger__c = true;
                        llist.add(l);
                }
                for(Integer i =2; i<=15; i++) {
                    if( rd.get('Charge_' + i + '_Amount_Apportioned__c') != null &&  (Decimal) rd.get('Charge_' + i + '_Amount_Apportioned__c') != 0) {
                        Ledger__c l = new Ledger__c();
                            l.Charge_Name__c = (String) rd.get('Charge' + i + 'Name__c');
                            l.Amount__c =  (Decimal) rd.get('Charge_' + i + '_Amount_Apportioned__c') ;
                            l.Activity__c = 'Credit';
                            l.Demand__c = rd.Demand__c;
                            l.Receipt__c = rd.Receipts__r.Id;
                            l.Receipt_Details__c = rd.Id;
                            l.Opportunity__c = rd.Receipts__r.Opportunity__c;
                            l.Transaction_Date__c = rd.Transaction_Date__c;
                            l.Tax_ledger__c = true;
                            llist.add(l);
                    }
                    if( rd.get('Charge_' + i + '_Tax_Apportioned__c') != null &&  (Decimal) rd.get('Charge_' + i + '_Tax_Apportioned__c') != 0) {
                        Ledger__c l = new Ledger__c();
                            l.Charge_Name__c = (String) rd.get('Charge' + i + 'Name__c');
                            l.Amount__c =  (Decimal) rd.get('Charge_' + i + '_Tax_Apportioned__c') ;
                            l.Activity__c = 'Credit';
                            l.Demand__c = rd.Demand__c;
                            l.Receipt__c = rd.Receipts__r.Id;
                            l.Receipt_Details__c = rd.Id;
                            l.Opportunity__c = rd.Receipts__r.Opportunity__c;
                            l.Transaction_Date__c = rd.Transaction_Date__c;
                            l.Tax_ledger__c = true;
                            llist.add(l);
                    }
                }
                
            }
            if(!llist.isEmpty() && llist.size() > 0) {
                insert llist;
            }
            
        }
    }
    public static void deleteCreditLedgers(Set<Id> rdIdSet) {
        List<Ledger__c> llist = new List<Ledger__c>();
        llist = [Select Id from Ledger__c  where Receipt_Details__c in :rdIdSet];
        if(!llist.isEmpty() && llist.size() > 0) {
            delete llist;
        }
    }
    
    public static void cleanupLedgersAftercancellation(Set<Id> rdIdSet) {
        // update all the ledgers as cancelled
        List<Ledger__c> llist = new List<Ledger__c>();
        List<Ledger__c>  newLedgerslist = new List<Ledger__c>();
        List<Ledger__c>  debitLedgers = new List<Ledger__c>();
        llist = [Select Id, Charge_Name__c, Amount__c, Demand__c, Demand__r.Id, Receipt__r.Cheque_DD__c, Opportunity__c,Tax_Ledger__c from Ledger__c  
                 where Receipt_Details__c in :rdIdSet];
        Set<Id> affectedDemandIds = new Set<Id>();
        if(!llist.isEmpty() && llist.size() > 0) {
            for(Ledger__c l : llist) {
                l.cancelled__c = true;
                l.Remarks__c =  'APPORTIONMENT REVERSAL';
                
                System.debug('Existing Credit Ledger to be reversed:' +l);
                Ledger__c ld = new Ledger__c();
                ld.Charge_Name__c = l.Charge_Name__c;
                ld.Amount__c = l.Amount__c;
                ld.Activity__c = 'Debit';
                ld.Demand__c = l.Demand__c;
                ld.Opportunity__c = l.Opportunity__c;
                ld.Transaction_Date__c = system.today();
                ld.Tax_Ledger__c = l.Tax_Ledger__c;
                ld.Remarks__c = 'Receipt No : ' + l.Receipt__r.Cheque_DD__c + ' rejected on  ' + system.now().format('dd/MM/yyyy');
                newLedgerslist.add(ld);
            }
            update llist;
            insert newLedgerslist;            
        }
    }
}