public class TriggerDemandHandler {
  public static void cleanUpLedgersAfterReversal(List<Id> dList){
      System.debug('i am dlist'+dList);
        List<Demand__c> dm = new List<Demand__c>();
        DescribeSObjectResult describeResult = Demand__c.getSObjectType().getDescribe();  
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName() + ' where id IN:dList'; //' + '\'' + dList[0] + '\'';
        system.debug('query::'+query);
        dm = Database.query( query );
        List<Receipt_Details__c> rdList = new List<Receipt_Details__c>();
        List<Receipt_Details__c> rdListForDelete = new List<Receipt_Details__c>();
        rdList = [select Id, Name from Receipt_Details__c where Demand__c IN :dList];
        System.debug('i am rdList-->'+rdList);
        List<Ledger__c> leg = new List<Ledger__c>();
        List<Ledger__c> legForInsert = new List<Ledger__c>();
        List<Ledger__c> legForUpdate = new List<Ledger__c>();
        leg = [select id,name, Charge_Name__c, Activity__c,Amount__c,Transaction_Date__c,Receipt_Details__c,Cancelled__c,Remarks__c,Demand__c,Receipt__c,
               Tax_Ledger__c, Opportunity__c, Demand__r.Invoice_Number__c from Ledger__c where Demand__c IN :dList and Activity__c = 'Debit'];
        
        if(!rdList.isEmpty()){
            for(Receipt_Details__c rd : rdList){
                rdListForDelete.add(rd); 
            }
            List<Ledger__c> llist = new List<Ledger__c>();
            llist = [Select Id from Ledger__c where Receipt_Details__c in :rdList];
            if(!llist.isEmpty() && llist.size() > 0) 
                delete llist;
            if(!rdListForDelete.isEmpty()){
                delete rdListForDelete; 
            }
        }
        
        if(!leg.isEmpty()){
            for(Ledger__c l : leg){
                Ledger__c lNew = new Ledger__c();
                lNew = l.clone(false,false,false,false);
                lNew.Activity__c = 'Credit';
                lNew.Remarks__c = l.Demand__r.Invoice_Number__c + '--DEMAND CANCELLATION CREDIT';
                lNew.Cancelled__c = true;
                legForInsert.add(lnew); 
                
                l.Remarks__c = l.Demand__r.Invoice_Number__c + '--DEMAND CANCELLATION CREDIT';
                l.Cancelled__c = true;                
                legForUpdate.add(l);
            }
            if(!legForInsert.isEmpty()){
                insert legForInsert;
            }
            if(!legForUpdate.isEmpty()){
                update legForUpdate;
            }
        }
        
        List<System_Log__c> sloglist = new List<System_Log__c>();
        set<id> pmList = new set<id>();
        List<Demand__c> dmListForUpdate = new List<Demand__c>();
        for(Demand__c d : dm) {
            if(string.isNotBlank(d.Remarks__c) && !d.remarks__c.equals('Reversed from Actions')){
                System_Log__c sLogs = new System_Log__c();
                sLogs.Action__c = 'Reverse Demand';
                sLogs.Booking__c = d.Booking__C;
                sLogs.Opportunity__c = d.OpportunityFormula__c;
                sLogs.Object_Name__c = 'Demand';
                sLogs.Record_Id__c = d.id;
                sLogs.Remarks__c = 'Reversed from the Data loader';
                sLogs.Payment_Milestones__c = d.Payment_Milestones__c; 
                sloglist.add(sLogs); 
            }
            ///// Commented by Neha on 17/6/19 as we don't want to roll back values to 0      
            /*   for(Integer i =1; i<=15; i++) {
d.put('Charge_' + i + '_Paid__c', 0);
d.put('Charge_' + i + '_Demanded__c', 0);
d.put('Charge_' + i + '_Tax_Demanded__c', 0);
d.put('Charge_' + i + '_Tax_Paid__c', 0);
d.put('Charge_' + i + '_SGST__c', 0);
d.put('Charge_' + i + '_CGST__c', 0); 
}*/
            //  d.put('Charge_1_Service_Tax__c', 0);
            //    d.put('Agreement_Value_Demanded_New__c', 0);
            d.put('Agreement_Value_Paid__c', 0);
            //   d.put('Service_Tax_on_Agreement_Value_Demanded__c', 0);
            d.put('Service_Tax_on_Agreement_Value_Paid__c', 0);
            //   d.put('Stamp_Duty_Demanded_New__c', 0);
            //   d.put('Registration_Charges_Demanded_New__c', 0);
            d.put('Stamp_Duty_Paid__c', 0);
            d.put('Registration_Charges_Paid__c', 0);
            //    d.put('Total_Other_Charges_Demanded_New__c', 0);
            //    d.put('Total_Other_Charges_Tax_Demanded_New__c', 0);
            d.put('Total_Other_Charges_Paid_New__c', 0);
            d.put('Total_Other_Charges_Tax_Paid_New__c', 0);
            //   d.put('Total_Society_Charges_Demanded__c', 0);
            //  d.put('Total_Society_Charges_Tax_Demanded__c', 0);
            d.put('Total_Society_Charges_Paid__c', 0);
            d.put('Total_Society_Charges_Tax_Paid__c', 0);
            //  d.put('Debit_Demanded__c', 0);
            //  d.put('Debit_Tax_Demanded__c', 0);
            d.put('Debit_Paid__c', 0);
            d.put('Debit_Tax_Paid__c', 0);
            //    d.put('Debit_SGST__c', 0);
            //   d.put('Debit_CGST__c', 0);
            d.put('Interest_On_Paid_Amount__c', 0);
            d.put('Total_Interest_Amount_Paid__c', 0);
            //  d.put('Total_Interest_Amount_Waived__c', 0);
            d.put('Tax_On_Interest_On_Paid_Amount__c', 0);
            d.put('Total_Interest_Tax_Paid__c', 0);
            //   d.put('Total_Interest_Tax_Waived__c', 0);
            dmListForUpdate.add(d); 
            pmList.add(d.Payment_Milestones__c); 
        }
        
        if(!sloglist.isEmpty()){
            insert sloglist;
        }
        if(!dmListForUpdate.isEmpty()){
            List<Id> dId = new List<Id>();
            update dmListForUpdate;
            for(Demand__c dd : dmListForUpdate){
                dId.add(dd.id);
            }
            rollUpsFieldsToTheirBuckets(dId);
        }
        if(!pmList.isEmpty()){
            List<Payment_Milestones__c> pmListForupdate = new List<Payment_Milestones__c>();
            for(Payment_Milestones__c pm : [select id,name,is_demand_raised__c,Demand_Raised__c,Invoice_Due_Date__c,Invoice_Date__c from Payment_Milestones__c where id IN :pmList]){
                pm.is_demand_raised__c = false;
                pm.Demand_Raised__c = true; 
                pm.Invoice_Date__c = null;
                pm.Invoice_Due_Date__c = null;
                pmListForupdate.add(pm); 
            }
            
            if(!pmListForupdate.isEmpty()){
                update pmListForupdate;
            }
        }                       
    } 
  public static void rollUpsFieldsToTheirBuckets(List<Id> dIdList) {
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
        String DemandQuery = 'Select Id, Name,Remarks__c,Descriptions__c, Agreement_Value_Paid__c, Service_Tax_on_Agreement_Value_Paid__c, Debit_Demanded__c, Debit_Tax_Demanded__c, Debit_SGST__c, Debit_CGST__c, Debit_Tax_Paid__c, Debit_Paid__c, Charge_1_Service_Tax__c,' + tempQuery + ' from Demand__c where id in :dIdList';
        List<Demand__c> dList = Database.Query(DemandQuery);
        if(dList != null && dList.size() > 0) {
            for(Demand__c d : dList) {
                d.Agreement_Value_Demanded_New__c = 0;
                d.Service_Tax_on_Agreement_Value_Demanded__c = 0;
                d.Total_Amount_Demanded__c = 0;
                d.Total_Amount_Paid__c = 0;
                d.Total_Tax_Demanded__c = 0;
                d.Total_tax_paid__c = 0;
                d.Debit_Tax_Demanded__c =0;
                
                d.Total_Other_Charges_Demanded_New__c = 0;
                d.Total_Other_Charges_Paid_New__c = 0;
                d.Total_Other_Charges_Tax_Demanded_New__c=0;
                d.Total_Other_Charges_Tax_Paid_New__c = 0;
                
                d.Total_Society_Charges_Demanded__c = 0;
                d.Total_Society_Charges_Paid__c = 0;
                d.Total_Society_Charges_Tax_Demanded__c = 0;
                d.Total_Society_Charges_Tax_Paid__c = 0;
                d.Stamp_Duty_Demanded_New__c = 0;
                d.Stamp_Duty_Paid__c = 0;
                
                for(Integer i = 1; i <= 15; i++){
                    d.put('Charge_'+i +'_Tax_Demanded__c', 0) ;
                }
                if(d.Agreement_Value_Paid__c != 0) {
                    d.Total_Amount_Paid__c += d.Agreement_Value_Paid__c;
                }
                if(d.Service_Tax_on_Agreement_Value_Paid__c != 0) {
                    d.Total_tax_paid__c += d.Service_Tax_on_Agreement_Value_Paid__c;
                }
                // these are for debit note roll up
                if(d.Debit_Demanded__c != 0) {
                    d.Total_Amount_Demanded__c += d.Debit_Demanded__c;
                }
                if(d.Debit_SGST__c != 0) {
                    d.Debit_Tax_Demanded__c += d.Debit_SGST__c;
                }
                if(d.Debit_CGST__c != 0) {
                    d.Debit_Tax_Demanded__c += d.Debit_CGST__c;
                }
                if(d.Debit_Tax_Demanded__c != 0) {
                    d.Total_Tax_Demanded__c += d.Debit_Tax_Demanded__c;
                }
                if(d.Debit_Paid__c != 0) {
                    d.Total_Amount_Paid__c += d.Debit_Paid__c;
                }                    
                if(d.Debit_Tax_Paid__c != 0) {
                    d.Total_tax_paid__c += d.Debit_Tax_Paid__c;
                }
                if(d.Charge_1_Service_Tax__c != null){
                    d.Charge_1_Tax_Demanded__c = d.Charge_1_Tax_Demanded__c + d.Charge_1_Service_Tax__c;
                }      
                if(d.Remarks__c != null){
                    d.Descriptions__c = d.Remarks__c.length() > 240  ? d.Remarks__c.substring(0, 240)  : d.Remarks__c;
                }             
                // these are fields in AV bucket
                for( Integer i= 1; i <= 15; i++) {
                    if(d.get('Charge_' + i + '_SGST__c') != null ) {
                        d.put('Charge_'+i +'_Tax_Demanded__c', (Decimal) d.get('Charge_'+i +'_Tax_Demanded__c') + (Decimal) d.get('Charge_' + i + '_SGST__c'));
                    }
                    if(d.get('Charge_' + i + '_CGST__c') != null ) {
                        d.put('Charge_'+i +'_Tax_Demanded__c', (Decimal) d.get('Charge_'+i +'_Tax_Demanded__c')  + (Decimal) d.get('Charge_' + i + '_CGST__c'));
                    }
                    
                    if (d.getSObject('Charge_' + i + '_Lookup__r') != null &&
                        (String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
                        String.isNotBlank((String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
                        (String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Agreement Value') {
                            if(d.get('Charge_' + i + '_Demanded__c') != null) {
                                d.Agreement_Value_Demanded_New__c += (Decimal) d.get('Charge_' + i + '_Demanded__c');
                                d.Total_Amount_Demanded__c += (Decimal) d.get('Charge_' + i + '_Demanded__c');
                            }
                            
                            if(d.get('Charge_' + i + '_Tax_Demanded__c') != null) {
                                d.Service_Tax_on_Agreement_Value_Demanded__c += (Decimal) d.get('Charge_' + i + '_Tax_Demanded__c');
                                d.Total_Tax_Demanded__c += (Decimal) d.get('Charge_' + i + '_Tax_Demanded__c');
                            }
                        }
                    // these are fields in Society Charges bucket
                    /*         if (d.getSObject('Charge_' + i + '_Lookup__r') != null &&
(String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
String.isNotBlank((String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
(String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Society Charges') {
if(d.get('Charge_' + i + '_Demanded__c') != null) {
d.Total_Society_Charges_Demanded__c += (Decimal) d.get('Charge_' + i + '_Demanded__c');
d.Total_Amount_Demanded__c += (Decimal) d.get('Charge_' + i + '_Demanded__c');
}
if(d.get('Charge_' + i + '_Paid__c') != null) {
d.Total_Society_Charges_Paid__c += (Decimal) d.get('Charge_' + i + '_Paid__c');
d.Total_Amount_Paid__c += (Decimal) d.get('Charge_' + i + '_Paid__c');
}

if(d.get('Charge_' + i + '_Tax_Demanded__c') != null) {
d.Total_Society_Charges_Tax_Demanded__c += (Decimal) d.get('Charge_' + i + '_Tax_Demanded__c');
d.Total_Tax_Demanded__c += (Decimal) d.get('Charge_' + i + '_Tax_Demanded__c');
}
if(d.get('Charge_' + i + '_Tax_Paid__c') != null) {
d.Total_Other_Charges_Tax_Paid_New__c += (Decimal) d.get('Charge_' + i + '_Tax_Paid__c');
d.Total_tax_paid__c += (Decimal) d.get('Charge_' + i + '_Tax_Paid__c');
}
}*/
                    
                    // these are fields in Other Charges bucket
                    /*      if (d.getSObject('Charge_' + i + '_Lookup__r') != null &&
(String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
String.isNotBlank((String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
(String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Other Charges') {
if(d.get('Charge_' + i + '_Demanded__c') != null) {
d.Total_Other_Charges_Demanded_New__c +=  (Decimal) d.get('Charge_' + i + '_Demanded__c');
d.Total_Amount_Demanded__c += (Decimal) d.get('Charge_' + i + '_Demanded__c');
}
if(d.get('Charge_' + i + '_Paid__c') != null) {
d.Total_Other_Charges_Paid_New__c += (Decimal) d.get('Charge_' + i + '_Paid__c');
d.Total_Amount_Paid__c += (Decimal) d.get('Charge_' + i + '_Paid__c');
}

if(d.get('Charge_' + i + '_Tax_Demanded__c') != null) {
d.Total_Other_Charges_Tax_Demanded_New__c += (Decimal) d.get('Charge_' + i + '_Tax_Demanded__c');
d.Total_Tax_Demanded__c += (Decimal) d.get('Charge_' + i + '_Tax_Demanded__c');
}
if(d.get('Charge_' + i + '_Tax_Paid__c') != null) {
d.Total_Other_Charges_Tax_Paid_New__c += (Decimal) d.get('Charge_' + i + '_Tax_Paid__c');
d.Total_tax_paid__c += (Decimal) d.get('Charge_' + i + '_Tax_Paid__c');
}                        
}*/
                    
                    // these are fields in SDR bucket
                    if (d.getSObject('Charge_' + i + '_Lookup__r') != null &&
                        (String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
                        String.isNotBlank((String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
                        (String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Stamp Duty and Registration') {
                            if(d.get('Charge_' + i + '_Demanded__c') != null) {
                                d.Stamp_Duty_Demanded_New__c += (Decimal) d.get('Charge_' + i + '_Demanded__c');
                                d.Total_Amount_Demanded__c += (Decimal) d.get('Charge_' + i + '_Demanded__c');
                            }
                            if(d.get('Charge_' + i + '_Paid__c') != null) {
                                d.Stamp_Duty_Paid__c +=(Decimal)  d.get('Charge_' + i + '_Paid__c');
                                d.Total_Amount_Paid__c += (Decimal) d.get('Charge_' + i + '_Paid__c');
                            }
                        }
                    
                }
                d.Service_Tax_on_Agreement_Value_Demanded__c = d.Service_Tax_on_Agreement_Value_Demanded__c.setscale(0,RoundingMode.HALF_UP);
                d.Total_Tax_Demanded__c = d.Total_Tax_Demanded__c.setscale(0,RoundingMode.HALF_UP);
                d.Total_Society_Charges_Tax_Demanded__c = d.Total_Society_Charges_Tax_Demanded__c.setscale(0,RoundingMode.HALF_UP);
                d.Total_Other_Charges_Tax_Demanded_New__c = d.Total_Other_Charges_Tax_Demanded_New__c.setscale(0,RoundingMode.HALF_UP);
            }
            update dList;
        }         
    }
}