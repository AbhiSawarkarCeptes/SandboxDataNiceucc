public with sharing class PaymentManagementServices_PS {
    public static Map<String, List<demandFieldLocationWrapper>> getCustomerOutstandingChargeWise(Id unitId){
        String tempQuery = '';
        Map<String, List<demandFieldLocationWrapper>> outstandingChargesMap = new Map<String, List<demandFieldLocationWrapper>>();
        /*for (Integer i = 1; i <= 15; i++) {
            tempQuery += 'Charge_' + i + '_Name__c' + ',';
            tempQuery += 'Charge_' + i + '_Demanded__c' + ',';
            tempQuery += 'Charge_' + i + '_Paid__c' + ',';
            tempQuery += 'Charge_' + i + '_Tax_Demanded__c' + ',';
            tempQuery += 'Charge_' + i + '_Tax_Paid__c' + ',';
            tempQuery += 'Charge_' + i + '_SGST__c' + ',';
            tempQuery += 'Charge_' + i + '_CGST__c' + ',';
            tempQuery += 'Charge_' + i + '_Lookup__r.ChargeBucket__c,';
            tempQuery += 'Charge_' + i + '_Lookup__r.Name,';
            tempQuery += 'Charge_' + i + '_Balance__c,';
            tempQuery += 'Charge_' + i + '_Tax_Balance__c,';
        }*/
        /*if (tempQuery.length() > 0 && tempQuery.substring(tempQuery.length() - 1).equals(','))
            tempQuery = tempQuery.substring(0, tempQuery.length() - 1);*/
       /* String DemandQuery = 'Select Id, Name, PropStrength__Payment_Date__c, Agreement_Value_Demanded_New__c, Service_Tax_on_Agreement_Value_Demanded__c, '+
            ' Agreement_Value_Paid__c,Service_Tax_on_Agreement_Value_Paid__c, '+
            ' Debit_Type__c, Demand_Status__c,'  +
            ' Debit_Tax_Paid__c, Debit_Tax_Demanded__c '+ 
            tempQuery + 
            ' FROM PropStrength__Received_Payment__c where PropStrength__Application_Booking__r.PropStrength__Property__c = :unitId ' +
            ' AND RecordType.Name = \'Payment Due\' AND (PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Unit_Status__c = \'SOLD\' OR PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Unit_Status__c = \'Blocked\') order by name asc' ; //payment due
        */
        //List<PropStrength__Received_Payment__c> dList = Database.Query(DemandQuery);
        /*if(dList != null && dList.size() > 0) {
            for(PropStrength__Received_Payment__c d: dList) {
                System.debug('demand oustanding:' +d);
                /*if(d.Debit_Balance__c != 0 || d.Debit_Tax_Balance__c != 0) {
                    List<demandFieldLocationWrapper> tempList = new List<demandFieldLocationWrapper>();
                    if(outstandingChargesMap.containsKey(d.Debit_Type__c)) {
                        tempList = outstandingChargesMap.get(d.Debit_Type__c);                            
                    } 
                    tempList.add(new demandFieldLocationWrapper(d, 
                                                                'Debit_Demanded__c', 
                                                                'Debit_Paid__c', 
                                                                'Debit_Balance__c',
                                                                'Debit_Amount_Apportioned__c', 
                                                                'Debit_Tax_Demanded__c', 
                                                                'Debit_Tax_Paid__c',
                                                                'Debit_Tax_Balance__c',
                                                                'Debit_Tax_Apportioned__c', 
                                                                'Debit_Charge_Name__c',
                                                                'Total_Interest_Amount_Due__c',
                                                                'Tax_on_Total_Interest_Amount_Due__c',
                                                                'Interest_Amount_Paid__c',
                                                                'Interest_Amount_Waived__c',
                                                                'Tax_on_Interest_Paid__c',
                                                                'Tax_on_Interest_Waived__c',
                                                                0));
                    outstandingChargesMap.put(d.Debit_Type__c, tempList);
                } 
                
                if(d.Agreement_Value_Balance__c != 0 || d.Service_Tax_on_Agreement_Value_Balance__c != 0) {
                    List<demandFieldLocationWrapper> tempList = new List<demandFieldLocationWrapper>();
                    if(outstandingChargesMap.containsKey('Consideration Value')) {
                        tempList = outstandingChargesMap.get('Consideration Value');                            
                    } 
                    tempList.add(new demandFieldLocationWrapper(d, 
                                                                'Agreement_Value_Demanded_New__c', 
                                                                'Agreement_Value_Paid__c', 
                                                                'Agreement_Value_Balance__c',
                                                                'Charge_1_Amount_Apportioned__c', 
                                                                'Service_Tax_on_Agreement_Value_Demanded__c', 
                                                                'Service_Tax_on_Agreement_Value_Paid__c',
                                                                'Service_Tax_on_Agreement_Value_Balance__c',
                                                                'Charge_1_Tax_Apportioned__c', 
                                                                'Charge1Name__c',
                                                                'Total_Interest_Amount_Due__c',
                                                                'Tax_on_Total_Interest_Amount_Due__c', 
                                                                'Interest_Amount_Paid__c',
                                                                'Interest_Amount_Waived__c',
                                                                'Tax_on_Interest_Paid__c',
                                                                'Tax_on_Interest_Waived__c',
                                                                0));
                    outstandingChargesMap.put('Consideration Value', tempList);
                } */
               // String chargeName = '';
                /* for(Integer i = 1; i<=15; i++) {
                    if (d.getSObject('Charge_' + i + '_Lookup__r') != null &&
                        (String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
                        String.isNotBlank((String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
                        (String) d.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != 'Agreement Value') {
                            chargeName = (String) d.getSObject('Charge_' + i + '_Lookup__r').get('Name');
                            if(d.get('Charge_' + i + '_Balance__c') != 0 || d.get('Charge_' + i + '_Tax_Balance__c') != 0) {
                                
                                List<demandFieldLocationWrapper> tempList = new List<demandFieldLocationWrapper>();
                                if(outstandingChargesMap.containsKey(chargeName)) {
                                    tempList = outstandingChargesMap.get(chargeName);
                                } 
                                tempList.add(new demandFieldLocationWrapper(d, 
                                                                            'Charge_' + i + '_Demanded__c',
                                                                            'Charge_' + i + '_Paid__c', 
                                                                            'Charge_' + i +'_Balance__c',
                                                                            'Charge_' + i + '_Amount_Apportioned__c',
                                                                            'Charge_' + i + '_Tax_Demanded__c', 
                                                                            'Charge_' + i + '_Tax_Paid__c',
                                                                            'Charge_' + i + '_Tax_Balance__c',
                                                                            'Charge_' + i + '_Tax_Apportioned__c', 
                                                                            'Charge' + i +'Name__c' ,
                                                                            'Total_Interest_Amount_Due__c',
                                                                            'Tax_on_Total_Interest_Amount_Due__c',
                                                                            'Interest_Amount_Paid__c',
                                                                            'Interest_Amount_Waived__c',
                                                                            'Tax_on_Interest_Paid__c',
                                                                            'Tax_on_Interest_Waived__c',
                                                                            i));
                                outstandingChargesMap.put(chargeName, tempList);
                            }
                        }
                } */                   
            //}
        //}
        /*if(!outstandingChargesMap.isEmpty() && outstandingChargesMap.size() > 0){
            for(String chargeName: outstandingChargesMap.keyset()) {
                for(DemandFieldLocationWrapper d: outstandingChargesMap.get(chargename)) {
                    System.debug('chargeName:' + chargeName + '||Demand:' + d.d.Name + '||demanded is in :' + d.fieldNameD +'||Paid is in:' + d.fieldNameP + '||position integer:' + d.fieldLocation);
                }
            }
        }*/
        return outstandingChargesMap;
    }
    
   /* public static Map<Id,Decimal> getOnAccountMoney(List<Id> oppIdList) {
        //// In Currency, Indian Rupee changed to AED by Neha on 12/3/19
        List<Receipt__c> rList = [Select Id, Currency__c, Foreign_Currency_Type__c , On_Account_Money__c,Opportunity__r.Id,On_Account_Money_Autocalculated__c
                                  from Receipt__c 
                                  where Opportunity__r.Id in : oppIdList 
                                  and Currency__c = 'AED'
                                  and On_Account_Money_Autocalculated__c > 0
                                  and Receipt_Status__c NOT IN('Dishonored', 'Physical Verification Rejected', 'Cancelled')]; //// 'Cancelled' added by Neha on 1/7/19
        Map<Id, Decimal> oppMoneyMap = new Map<Id, Decimal>();
        if(rList.size() > 0) {
            for(Receipt__c r : rList) {
                if(oppMoneyMap.containsKey(r.Opportunity__r.Id)) {
                    oppMoneyMap.put(r.Opportunity__r.Id, oppMoneyMap.get(r.Opportunity__r.Id) + r.On_Account_Money_Autocalculated__c);
                } else {
                    oppMoneyMap.put(r.Opportunity__r.Id, r.On_Account_Money_Autocalculated__c);
                }
            }
        }
        return oppMoneyMap;
    }
    
    public static Decimal getOnAccountMoney(Id oppId) {
        List<Receipt__c> rList = [Select Id, Currency__c, Foreign_Currency_Type__c , On_Account_Money__c,On_Account_Money_Autocalculated__c 
                                  from Receipt__c 
                                  where Opportunity__r.Id  = : oppId 
                                  and Currency__c = 'AED'
                                  and On_Account_Money_Autocalculated__c > 0
                                  and Receipt_Status__c NOT IN('Dishonored', 'Physical Verification Rejected', 'Cancelled')];
        Decimal onAccountMoney = 0;
        if(rList.size() > 0) {
            for(Receipt__c r : rList) {
                if(r.On_Account_Money_Autocalculated__c != null)
                    onAccountMoney += r.On_Account_Money_Autocalculated__c;
            }
        }
        return onAccountMoney;
    }
    
    public static Decimal getRefundAmount(Id oppId) {
        List<Receipt__c> rList = [Select Id, Currency__c, Foreign_Currency_Type__c , On_Account_Money__c,On_Account_Money_Autocalculated__c,Amount_Rs__c 
                                  from Receipt__c 
                                  where Opportunity__r.Id  = : oppId 
                                  and Currency__c = 'AED'
                                  and Amount_Rs__c > 0
                                  and Receipt_Status__c NOT IN('Dishonored', 'Physical Verification Rejected', 'Cancelled')];
        Decimal refundMoney = 0;
        if(rList.size() > 0) {
            for(Receipt__c r : rList) {
                if(r.Amount_Rs__c != null)
                    refundMoney += r.Amount_Rs__c;
            }
        }
        return refundMoney;
    }*/
    
    public class demandFieldLocationWrapper {
        public Demand__c d {get;set;}
        // D- Demanded, P- Paid, O - Outstanding, DT - Tax Demanded, PT - Tax Paid, OT - Tax Outstanding.
        public String fieldNameD {get;set;}
        public String fieldNameP {get;set;}
        public String fieldNameO {get;set;}
        public String fieldNametoBePaid {get;set;}
        
        public String fieldNameDT {get;set;}
        public String fieldNamePT {get;set;}
        public String fieldNameOT {get;set;}
        public String fieldNametoBePaidT {get;set;}
        
        public String chargeName {get;set;}
        
        public String fieldNameIntAmt {get;set;}
        public String fieldNameIntTax {get;set;}
        
        public String fieldNameIntAmtP {get;set;}
        public String fieldNameIntTaxP {get;set;}
        
        public String fieldNameIntAmtW {get;set;}
        public String fieldNameIntTaxW {get;set;}
        
        public Integer fieldLocation {get;set;}
        
        public Receipt_Details__c rd {get;set;}
        
        public demandFieldLocationWrapper (demand__c demand, String fnDemanded, String fnPaid, Integer location){
            d= demand;
            fieldNameD = fnDemanded;
            fieldNameP = fnPaid;
            fieldLocation = location;
            rd = new Receipt_Details__c();
        }
        
        public demandFieldLocationWrapper (demand__c demand, String fnDemanded, String fnPaid, String fnO,String tobePaid, String fnDemandedTax, 
                                           String fnPaidTax,  String fnOT, String toBePaidTax, String cn, String intAmtDue, String intTaxDue, 
                                           String intAmtP, String intAmtW, String intTaxP, String intTaxW, Integer location){
            d= demand;
            // D- Demanded, P- Paid, O - Outstanding, DT - Tax Demanded, PT - Tax Paid, OT - Tax Outstanding.
            fieldNameD = fnDemanded;
            fieldNameP = fnPaid;
            fieldNameO = fnO;
            fieldNametoBePaid = tobePaid;
            
            fieldNameDT = fnDemandedTax;
            fieldNamePT = fnPaidTAx;
            fieldNameOT = fnOT;
            fieldNametoBePaidT = toBePaidTax;
            fieldLocation = location;
            chargeName = cn;
            fieldNameIntAmt = intAmtDue;
            fieldNameIntTax = intTaxDue;
            fieldNameIntAmtP = intAmtP;
            fieldNameIntAmtW = intAmtW;
            fieldNameIntTaxP = intTaxP;
            fieldNameIntTaxW = intTaxW;
            rd = new Receipt_Details__c();
            for(Integer i = 1; i<=15 ; i++) {
                rd.put('Charge_' + i + '_Amount_Apportioned__c' , 0);
                rd.put('Charge_' + i + '_Tax_Apportioned__c' , 0);
                rd.put('Charge' + i + 'Name__c' ,'');
            }
            rd.Debit_Tax_Apportioned__c = 0;
            rd.Debit_Amount_Apportioned__c = 0;
            rd.Debit_Charge_Name__c = '';
            rd.Interest_Amount_Paid__c = 0;
            rd.Interest_Amount_Waived__c = 0;
            rd.Tax_on_Interest_Paid__c = 0;
            rd.Tax_On_Interest_Waived__c = 0;
            System.debug('receipt details in constructor:' + rd);
        }
    }
}