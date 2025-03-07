public class LedgerManagementServices {
   
    
  
    /*--------------------------------------------------------------  
        METHOD To get ledger details for printing the ledger
        Parameters:- customer [opp Id]
        Returns:- LedgerWrapper
    ----------------------------------------------------------------*/
    
     public static List<LedgerPrintWrapper> getCustomerLedgers(Id oppId) {
        List<Ledger__c> lList = [select id, Name,
                                    Transaction_Date__c,
                                    Amount__c,
                                    Receipt__r.Receipt_No__c,
                                    Receipt__r.Cheque_DD_Date__c,
                                    Opportunity__r.Unit__r.id,
                                    Activity__c,
                                    Receipt__c,
                                    Receipt__r.Name,
                                    Receipt__r.Mode__c,
                                    Receipt__r.Cheque_DD__c, 
                                    Receipt__r.id,
                                    Receipt__r.Receipt_Date__c,
                                    Receipt__r.Receipt_Status__c,
                                    Receipt__r.DraweeBank__c,
                                    Receipt__r.Currency__c,
                                    Receipt__r.Amount_Rs__c,
                                    Receipt__r.Receipt_Number__c,
                                    Receipt__r.Foreign_Currency_Type__c,
                                    Receipt__r.Amount_in_Foreign_Currency__c,
                                    Receipt__r.Project_Unit__r.Name,
                                    Remarks__c,
                                    Opportunity__r.Unit__r.Project__r.Name,
                                    Opportunity__r.Unit__r.Project__r.Id,
                                    Opportunity__r.Name,
                                    Charge_Name__c,
                                    Tax_Ledger__c,
                                    Demand__r.Name,
                                    Demand__r.Id,
                                    Demand__r.Invoice_Date__c,
                                    Demand__r.Due_Date__c,
                                    Demand__r.Payment_Milestones__r.Id,
                                    Demand__r.Payment_Milestones__r.Due_Date__c,
                                    Demand__r.Payment_Milestones__r.Project_Construction_Stages__r.Name,
                                    Demand__r.Payment_Milestones__r.Milestone_Name__c,
                                    Demand__r.Payment_Milestones__r.Milestone_Type_edit__c,
                                    Cancelled__c
                                    from Ledger__c where  Opportunity__c=:oppId 
                                    and Transaction_Date__c <=:system.today() 
                                    order by createdDate asc, Demand__r.Name asc, Activity__c desc                          
                            ];  
                            system.debug('lList.size:::: '+lList.size());  
        Integer count = 0;
        Map<String, Integer> debitMap = new Map<String, Integer>();
        List<LedgerPrintWrapper> lpwList = new List<LedgerPrintWrapper>();
        Map<Integer,Decimal> refNoDebitAmtMap = new Map<Integer,Decimal>();
        Map<Integer,Decimal> refNoCreditAmtMap = new Map<Integer,Decimal>();
        Map<Integer,Integer> refNoCreditCounterMap = new Map<Integer, Integer>();
        for(Ledger__c l : lList) {
                
            if(l.Activity__c.equalsIgnoreCase('Debit') && l.Demand__c != null) {
                    if(!l.Tax_Ledger__c && ! debitMap.containsKey(l.Demand__r.Id + l.Charge_Name__c)) {
                    debitMap.put(l.Demand__r.Id + l.Charge_Name__c, count);
                    refNoDebitAmtMap.put(count,l.Amount__c);
                    count++;
                    }
                 else if(l.Tax_Ledger__c && ! debitMap.containsKey(l.Demand__r.Id + l.Charge_Name__c + ' Tax')){
                    debitMap.put(l.Demand__r.Id + l.Charge_Name__c + ' Tax', count);
                    refNoDebitAmtMap.put(count,l.Amount__c);
                    count++;
                 }
            } 
        }
        System.debug('debitMap:' + debitMap);
        Decimal Balance = 0;
        for(Ledger__c l :lList) {
            if(l.Activity__c.equalsIgnoreCase('Debit') &&  l.Demand__c != null) {
                ledgerPrintWrapper lpw = new LedgerPrintWrapper();
                //ledger 
                lpw.l = l;
                // populating the details of milestone for debit ledger
                if(l.Demand__r.Payment_Milestones__c != null ) {
                    if(l.Demand__r.Payment_Milestones__r.Milestone_Type_edit__c.equals('Date Linked')) {
                            lpw.demandFor = 'Demand For ' + l.Demand__r.Payment_Milestones__r.Milestone_Name__c;
                        if(lpw.demandFor != null)
                            lpw.demandFor = lpw.demandFor.replace(' 0 days from booking date',' Token Amount');
                    } else if(l.Demand__r.Payment_Milestones__r.Milestone_Type_edit__c.equals('Construction Linked')) {
                        String formattedDate = 'NA';
                        if(l.Demand__r.Payment_Milestones__r.Due_Date__c != null) {
                            formattedDate = l.Demand__r.Payment_Milestones__r.Due_Date__c.Format();
                            lpw.demandFor = 'Demand For ' + l.Demand__r.Payment_Milestones__r.Project_Construction_Stages__r.Name + '<br/> completed on ' +  formattedDate;
                        }
                        else
                            lpw.demandFor = 'Demand For ' + l.Demand__r.Payment_Milestones__r.Project_Construction_Stages__r.Name; // flow shouldnt come here ideally
                    } else if(l.Demand__r.Payment_Milestones__r.Milestone_Name__c != null && l.Demand__r.Payment_Milestones__r.Milestone_Type_edit__c.equalsIgnoreCase('On Registration')){
                        lpw.demandFor = 'Demand For Registration';
                    }
                }
                    
                // populating the demand details for debit Ledger
                if(l.Demand__c != null) {
                    lpw.DemandDetails = 'Invoice No:' + l.Demand__r.Name + '<br/> Invoice Date:' + l.Demand__r.Invoice_Date__c.Format() + '<br/> Due Date:' + l.Demand__r.Due_Date__c.Format();
                    lpw.SimplifiedDemandDetails = 'Invoice No:' + l.Demand__r.Name;
                }
                   
                // populating the ref no for debit ledger
                if(debitMap.containsKey(l.Demand__r.Id + l.Charge_Name__c) && !(l.Tax_Ledger__c)) {
                    lpw.refNo = debitMap.get(l.Demand__r.Id + l.Charge_Name__c);
                    lpw.refString = String.valueOf(lpw.refNo);
                } else if(debitMap.containsKey(l.Demand__r.Id + l.Charge_Name__c + ' Tax') && l.Tax_Ledger__c) {
                        lpw.refNo = debitMap.get(l.Demand__r.Id + l.Charge_Name__c + ' Tax');
                    lpw.refString = String.valueOf(lpw.refNo);
                }
                // populating the charge name
                if(l.Tax_Ledger__c)
                    lpw.chargeName = 'Tax on ' + l.Charge_Name__c;
                else 
                    lpw.chargeName = l.CHarge_Name__c;
                // Amount in Rs format
                if(l.Amount__c != null) {
                    lpw.Amount = INFormat(l.Amount__c);
                
                    // Running balance in Rs Format
                    Balance += l.Amount__c;
                    lpw.Balance = INFormat(Balance);
                }
                
                lpwList.add(lpw);
                System.debug('Ledger Wrapper Debit:' + lpw);
            } else if(l.Activity__c.equalsIgnoreCase('Credit')) {
                ledgerPrintWrapper lpw1 = new LedgerPrintWrapper();
                // ledger
                lpw1.l = l;
                
                // payment for details for the credit ledger
                lpw1.paymentFor = 'Payment received against ' + l.Receipt__r.Project_Unit__r.Name + '<br/> Invoice No.:' + l.Demand__r.Name;
                if(String.isNotBlank(l.Remarks__c))
                        lpw1.paymentFor += '--' + l.remarks__c;
                // instrument details for credit ledger
                if(l.Receipt__r.Foreign_Currency_Type__c != null) {
                    lpw1.paymentDetails =   'Type:' + l.Receipt__r.Mode__c + '<br/> Date:' + l.Receipt__r.Cheque_DD_Date__c.Format() + '<br/> Instrument No.' + 
                                                                l.Receipt__r.Cheque_DD__c + '<br/> Bank:' + l.Receipt__r.DraweeBank__c +
                                                                '<br/> Currency:' + l.Receipt__r.Currency__c + 
                                                                '<br/> Amount:' + InFormat(l.Receipt__r.Amount_Rs__c) + 
                                                                '<br/> Original Currency:' + l.Receipt__r.Amount_in_Foreign_Currency__c + ' ' + l.Receipt__r.Foreign_Currency_Type__c +
                                                                '<br/> Receipt No.:' + l.Receipt__r.Receipt_Number__c + 
                                                                '<br/> Status:' + l.Receipt__r.Receipt_Status__c;
                    lpw1.SimplifiedpaymentDetails = 'Instrument No:' + l.Receipt__r.Cheque_DD__c +' '+ 'Bank:' + l.Receipt__r.DraweeBank__c;
                }
                else if (l.Receipt__r.Mode__c != null && l.Receipt__r.Mode__c.equals('TDS')) {
                    lpw1.paymentDetails = 'Type:' + l.Receipt__r.Mode__c + '<br/> Date:' + l.Receipt__r.Cheque_DD_Date__c.Format() + '<br/> Instrument No.' + 
                                                                l.Receipt__r.Cheque_DD__c + 
                                                                '<br/> Currency:' + l.Receipt__r.Currency__c + 
                                                                '<br/> Amount:' + InFormat(l.Receipt__r.Amount_Rs__c) + 
                                                                '<br/> Receipt No.:' + l.Receipt__r.Receipt_Number__c + 
                                                                '<br/> Status:' + l.Receipt__r.Receipt_Status__c;
                    lpw1.SimplifiedpaymentDetails = 'Instrument No:' + l.Receipt__r.Cheque_DD__c +' '+ 'Bank:' + l.Receipt__r.DraweeBank__c;
                }
                else if(l.Receipt__c != null  && !l.Receipt__r.Mode__c.equals('Credit Note')){ // Added by Neha on 5/4/19
                    lpw1.paymentDetails = 'Type:' + l.Receipt__r.Mode__c + '<br/> Date:' + l.Receipt__r.Cheque_DD_Date__c.Format() + '<br/> Instrument No.' + 
                                                                l.Receipt__r.Cheque_DD__c + '<br/> Bank:' + l.Receipt__r.DraweeBank__c +
                                                                '<br/> Currency:' + l.Receipt__r.Currency__c + 
                                                                '<br/> Amount:' + InFormat(l.Receipt__r.Amount_Rs__c) + 
                                                                '<br/> Receipt No.:' + l.Receipt__r.Receipt_Number__c + 
                                                                '<br/> Status:' + l.Receipt__r.Receipt_Status__c;
                    lpw1.SimplifiedpaymentDetails = 'Instrument No:' + l.Receipt__r.Cheque_DD__c +' '+ 'Bank:' + l.Receipt__r.DraweeBank__c;
                } else {
                        lpw1.paymentDetails = l.Remarks__c;
                        lpw1.SimplifiedpaymentDetails = l.Remarks__c;
                }
                // charge name
                if(l.Tax_Ledger__c)
                    lpw1.chargeName =  'Tax on ' + l.Charge_Name__c;
                else 
                    lpw1.chargeName = l.Charge_Name__c;
                // amount
                if(l.Amount__c != null) {
                    lpw1.Amount = INFormat(l.Amount__c);
                    // balance
                    Balance -= l.Amount__c;
                    lpw1.Balance = INFormat(Balance);
                }
                // credit notes don't have demand lookup. They are create a single ledger to offset all the monies of all demands put together
                if(l.Demand__c != null) { 
                //matching the ref no with the debit side reference no. this is used for pairing and color coding the debit and credit demand
                if(debitMap.containsKey(l.Demand__r.Id + l.Charge_Name__c) && !l.Tax_Ledger__c) 
                    lpw1.refNo = debitMap.get(l.Demand__r.Id + l.Charge_Name__c);
                else if(debitMap.containsKey(l.Demand__r.Id + l.Charge_Name__c + ' Tax') && l.Tax_Ledger__c ) 
                        lpw1.refNo = debitMap.get(l.Demand__r.Id + l.Charge_Name__c + ' Tax');
                }        
                    if(refNoCreditAmtMap.containsKey(lpw1.refNo)) {
                        refNoCreditAmtMap.put(lpw1.refNo, refNoCreditAmtMap.get(lpw1.refNo) + l.Amount__c);
                    } else {
                        refNoCreditAmtMap.put(lpw1.refNo,l.Amount__c);
                    }
                    if(refNoCreditCounterMap.containsKey(lpw1.refNo)) {
                        refNoCreditCounterMap.put(lpw1.refNo, refNoCreditCounterMap.get(lpw1.refNo) + 1);
                    } else {
                        refNoCreditCounterMap.put(lpw1.refNo,1);
                    }
                    System.debug('refNoCreditCounterMap:' + refNoCreditCounterMap.get(lpw1.refNo));
                    System.debug('refNoCreditAmtMap:' + refNoCreditAmtMap.get(lpw1.refNo));
                    System.debug('refNoDebitAmtMap:' + refNoDebitAmtMap.get(lpw1.refNo));
                    if(refNoCreditAmtMap.containsKey(lpw1.refNo)) {
                        if(refNoCreditAmtMap.get(lpw1.refNo) >= refNoDebitAmtMap.get(lpw1.refNo) && refNoCreditCounterMap.get(lpw1.refNo) == 1 )
                            lpw1.refString += String.valueOf(lpw1.refNo) + ' (Full Payment)';
                        else if(refNoCreditAmtMap.get(lpw1.refNo) >= refNoDebitAmtMap.get(lpw1.refNo) && refNoCreditCounterMap.get(lpw1.refNo) > 1)
                            lpw1.refString += String.valueOf(lpw1.refNo) + ' (PPC)';
                        else if(refNoCreditAmtMap.get(lpw1.refNo) < refNoDebitAmtMap.get(lpw1.refNo))
                            lpw1.refString += String.valueOf(lpw1.refNo) + ' (PP)'; 
                             
                    } else {
                        lpw1.refString += String.valueOf(lpw1.refNo);
                    }
                // instrument details for credit ledger
                if(l.Receipt__r.Foreign_Currency_Type__c != null) {
                    lpw1.paymentDetails =   'Type:' + l.Receipt__r.Mode__c + '<br/> Date:' + l.Receipt__r.Cheque_DD_Date__c.Format() + '<br/> Instrument No.' + 
                                                                l.Receipt__r.Cheque_DD__c + '<br/> Bank:' + l.Receipt__r.DraweeBank__c +
                                                                '<br/> Currency:' + l.Receipt__r.Currency__c + 
                                                                '<br/> Amount:' + InFormat(l.Receipt__r.Amount_Rs__c) + 
                                                                '<br/> Original Currency:' + l.Receipt__r.Amount_in_Foreign_Currency__c + ' ' + l.Receipt__r.Foreign_Currency_Type__c +
                                                                '<br/> Receipt No.:' + l.Receipt__r.Receipt_Number__c + 
                                                                '<br/> Status:' + l.Receipt__r.Receipt_Status__c;
                    lpw1.SimplifiedpaymentDetails = 'Instrument No:' + l.Receipt__r.Cheque_DD__c +' '+ 'Bank:' + l.Receipt__r.DraweeBank__c;
                }
                else if (l.Receipt__c != null && l.Receipt__r.Mode__c.equals('TDS')) {
                    lpw1.paymentDetails = 'Type:' + l.Receipt__r.Mode__c + '<br/> Date:' + l.Receipt__r.Cheque_DD_Date__c.Format() + '<br/> Instrument No.' + 
                                                                l.Receipt__r.Cheque_DD__c + 
                                                                '<br/> Currency:' + l.Receipt__r.Currency__c + 
                                                                '<br/> Amount:' + InFormat(l.Receipt__r.Amount_Rs__c) + 
                                                                '<br/> Receipt No.:' + l.Receipt__r.Receipt_Number__c + 
                                                                '<br/> Status:' + l.Receipt__r.Receipt_Status__c;
                    lpw1.SimplifiedpaymentDetails = 'Instrument No:' + l.Receipt__r.Cheque_DD__c +' '+ 'Bank:' + l.Receipt__r.DraweeBank__c;
                }                                                
                else if (l.Receipt__c != null && !l.Receipt__r.Mode__c.equals('Credit Note')){
                    lpw1.paymentDetails = 'Type:' + l.Receipt__r.Mode__c + '<br/> Date:' + l.Receipt__r.Cheque_DD_Date__c.Format() + '<br/> Instrument No.' + 
                                                                l.Receipt__r.Cheque_DD__c + '<br/> Bank:' + l.Receipt__r.DraweeBank__c +
                                                                '<br/> Currency:' + l.Receipt__r.Currency__c + 
                                                                '<br/> Amount:' + InFormat(l.Receipt__r.Amount_Rs__c) + 
                                                                '<br/> Receipt No.:' + l.Receipt__r.Receipt_Number__c + 
                                                            '<br/> Status:' + l.Receipt__r.Receipt_Status__c;
                    lpw1.SimplifiedpaymentDetails = 'Instrument No:' + l.Receipt__r.Cheque_DD__c +' '+ 'Bank:' + l.Receipt__r.DraweeBank__c;
                } else {
                        lpw1.paymentDetails = l.Remarks__c;
                        lpw1.SimplifiedpaymentDetails = l.Remarks__c;
                         lpw1.paymentFor = l.Remarks__c;
                }                                           
                
                lpwList.add(lpw1);
                System.debug('Ledger Wrapper Credit:' + lpw1);
            }
            
        }
        return lpwList;
    }
    
    public class LedgerPrintWrapper {
        public Ledger__c l {get;set;}
        public Integer refNo {get;set;}
        public String refString {get;set;}
        public String chargeName {get;set;}
        public String Amount {get;set;}
        public String Balance {get;set;}
        public String DemandFor {get;set;}
        public String paymentFor {get;set;}
        public String demandDetails {get;set;}
        public String paymentDetails {get;set;}
        public String simplifieddemandDetails {get;set;}
        public String simplifiedpaymentDetails {get;set;}
        public LedgerPrintWrapper() {
            l = new ledger__c();
            chargeName = '';
            Amount = '';
            Balance = '';
            demandFor = '';
            paymentFor = '';
            demandDetails = '';
            paymentDetails = '';
            refString = '';
            simplifieddemandDetails = '';
            simplifiedpaymentDetails = '';
        }
    }
    
    
    // method for formatting the currency details to Indian Commas Format
    public static String INFormat(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        if(money == null) {
            return 'NIL';
        }
        Decimal tempMoney = money;
        String m0 = tempMoney.setscale(2,RoundingMode.HALF_UP).toPlainString();
        String decimalPart;
        List<String> tempStr = new List<String>();
        System.debug('Money: M0:' + m0);
        if(String.isNotBlank(m0)) {
                tempStr = m0.split('\\.');
                System.debug('tempStr:' + tempStr);
                if(tempStr != null && tempStr.size() ==2) {
                    decimalPart = tempStr[1];
                }
        }
        String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);
         /*   if(i==2) { // Commented by Neha to convert into Foreign Currency format 
                mF += ',';
            }*/
            if(i==2 || i==5 || i==8 || i==11 || i==14) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        if(String.isNotBlank(decimalPart)) 
            mf = mf + '.'  + decimalPart;
        if(!negative)
            mf = 'AED ' + mf + '/-';
        else
            mf = '- AED ' + mf + '/-';
        return mf;
    }
}