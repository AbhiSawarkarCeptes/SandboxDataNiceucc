public class ReceiptModulePSController {
    public Map<String, List<PaymentManagementServices_PS.DemandFieldLocationWrapper>> outstandingChargesMap {get;set;}
    public String receiptId {get;set;}
    public rMainWrapper rmw {get; set;}
    public string instrumentType {get;set;}
    public Boolean foreignCurrency {get;set;}
    public Boolean adjustmentFlow {get;set;}
    public Boolean onlyToken {get;set;}
    public Boolean unitError {get;set;}
    public Boolean hasDues {get;set;}
    public Boolean debug {get;set;}
    public Boolean adjustBtnDisable {get;set;}
    public string applicantNames {get;set;}
    public Boolean hasPaymentDues {get;set;}
    public Decimal moneyInHand {get;set;}
    public Boolean error {get;set;}
    public Boolean amountAdjusted {get;set;}
    public Decimal totalMoneyAllocated {get;set;}
    public List<PropStrength__Applicant_Detail__c> oppList {get;set;}
    public List<PropStrength__Received_Payment__c> listOfAdvanceReceipt {get;set;}
    public Boolean isAdvanceRecipt{get;set;}
    public Boolean isReversedReceipt{get;set;}
    
    public ReceiptModulePSController() {
        onlyToken = false;
        unitError = false;
        hasPaymentDues = false;
        adjustmentFlow = false;
        moneyInHand = 0;
        foreignCurrency = false;
        applicantNames ='';
        debug=false;
        adjustBtnDisable = false;
        error = false;
        isAdvanceRecipt = false;
        isReversedReceipt = false;
        
        rmw = new rMainWrapper();
        listOfAdvanceReceipt = new List<PropStrength__Received_Payment__c>();
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
            receiptId = ApexPages.currentPage().getParameters().get('id');
        }
        if(receiptId  != null) {
            List<PropStrength__Received_Payment__c> rc = new List<PropStrength__Received_Payment__c>();
            if(receiptId != null) {
                rc = [Select Id, Name, PropStrength__Amount__c, PropStrength__Payment_Type__c, PropStrength__Payment_Date__c, Instrument_Date__c, PropStrength__Bank_Name__c,Drawee_Bank_If_Others__c,
                      Drawn_in_favour_of__c, Instrument_Number__c, Receipt_Status__c,Remarks__c,PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Property__c,
                      Amount_in_Foreign_Currency__c,
                      Currency__c, FOREX__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name,PropStrength__Application_Booking__r.PropStrength__Project__r.Id,PropStrength__Application_Booking__r.PropStrength__Property_Name__c,
                      PropStrength__Payment_Status__c,PropStrength__Is_Reversal_Created__c from PropStrength__Received_Payment__c where id =:receiptId AND (RecordType.Name = 'Payment Received' OR RecordType.Name = 'Income Charge Received') ]; 
            }
            if(rc.size() == 1){
                rmw.r = rc[0];
                if(rmw.r.PropStrength__Payment_Type__c.equalsIgnoreCase('Cheque') || rmw.r.PropStrength__Payment_Type__c.equalsIgnoreCase('Wire Transfer') ||                 
                   rmw.r.PropStrength__Payment_Type__c.equalsIgnoreCase('Cash') || rmw.r.PropStrength__Payment_Type__c.equalsIgnoreCase('Credit Card') ||
                   rmw.r.PropStrength__Payment_Type__c.equalsIgnoreCase('Website')){
                       instrumentType = 'ins1';
                   } else if (rmw.r.PropStrength__Payment_Type__c.equalsIgnoreCase('Credit Note')) {
                       instrumentType = 'ins3';
                   } else {
                       instrumentType = 'error';
                   }
                adjustmentFlow = true;
                getCustomerDetails();
                if(rmw.r.Currency__c != null && !rmw.r.Currency__c.equalsIgnoreCase('AED'))// Indian Rupee changed to AED by Neha on 12/3/19
                    foreignCurrency = true;
                if(unitError) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Unable to process this receipt due a data issue: Please contact administrator' ));
                } else {
                    if(rmw.r.PropStrength__Is_Reversal_Created__c) 
                        isReversedReceipt = true;                    
                    applyReceipt();
                }
            }
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please select a receipt to process'));
        }
    }
    
    public void getCustomerDetails() {
        oppList = [Select Name, Id,PropStrength__Customer_Name__c, PropStrength__Application__r.PropStrength__Status__c, 
                   PropStrength__Applicant_Acc__r.Email, PropStrength__Applicant_Acc__r.PropStrength__Income_Tax_permanent_Account_No__c
                   from PropStrength__Applicant_Detail__c where PropStrength__Application__c = : rmw.r.PropStrength__Application_Booking__c and PropStrength__Active__c = TRUE];
        
        if(!oppList.isEmpty()) {
            Integer i = 0;
            for(PropStrength__Applicant_Detail__c appDet : oppList) {
                if(String.isNotBlank(appDet.PropStrength__Customer_Name__c) && i == 0) 
                    applicantNames = appDet.PropStrength__Customer_Name__c;
                if(i > 0 && String.isNotBlank(appDet.PropStrength__Customer_Name__c))
                    applicantNames += ',' + appDet.PropStrength__Customer_Name__c;
                i++;
            }
        } else {
            unitError = true;
        }
        if(!oppList.isEmpty() && !oppList[0].PropStrength__Application__r.PropStrength__Status__c.equalsIgnoreCase('Approved')) {
            onlyToken = true;
        } 
        /*else if(oppList.size() != 1){
unitError = true;
} */
    }
    
    public PageReference applyReceipt() {       
        System.debug('Apply receipt:');
        // it will always be adjustment flow. create receipt is handled in a separate controller, no flow for creating and adjusting receipts
        if(adjustmentFlow) {
            if(rmw.r.Receipt_Status__c != null && foreignCurrency && rmw.r.Receipt_Status__c != 'Cleared') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Foreign currency cheques can be processed only after the money has been realized & approved by finance'));
                error = true;
                return null;
            } else if(rmw.r.Receipt_Status__c != null && (rmw.r.Receipt_Status__c.equalsIgnoreCase('Physical Verification Rejected') || rmw.r.Receipt_Status__c.equalsIgnoreCase('Dishonored') || rmw.r.Receipt_Status__c.equalsIgnoreCase('Cancelled') )) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No further processing can be done on this instrument. The instrument is in ' + rmw.r.Receipt_Status__c + ' status'));
                error = true;
                return null;
            } 
            // moneyInHand = rmw.r.On_Account_Money_Autocalculated__c;
            if(moneyInHand == 0) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No further processing can be done on this instrument. The instrument is  fully adjusted'));
                return null;
            }    
            else if(moneyInHand > 0 && rmw.r.Currency__c.equalsIgnoreCase('AED')) {// Indian Rupee changed to AED by Neha on 12/3/19
                outstandingChargesMap = PaymentManagementServices_PS.getCustomerOutstandingChargeWise(rmw.r.PropStrength__Application_Booking__r.PropStrength__Property__c);
                if(!outstandingChargesMap.isEmpty() && outstandingChargesMap.size() > 0) {
                    hasPaymentDues = true;
                }
                if(!hasPaymentDues) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Customer doesnot have any outstanding dues' ));
                    return null;
                } 
            }
        } 
        return null;
    }
    
    public PageReference saveReceipt() {
        totalMoneyAllocated = 0;
        amountAdjusted = false;
        Boolean calcError = false;
        hasPaymentDues = false;
        List<Receipt_Details__c> rdList = new List<Receipt_Details__c>();
        for(String o : outstandingChargesMap.keySet()) {
            for(PaymentManagementServices_PS.DemandFieldLocationWrapper dl : outstandingChargesMap.get(o)) {
                //Commented by Deepak because the "PaymentManagementServices_PS.getCustomerOutstandingChargeWise" code is commented.
                /*if(dl.rd.get(dl.fieldNametoBePaid) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaid) > (Decimal) dl.d.get(dl.fieldNameO) ||
dl.rd.get(dl.fieldNametoBePaidT) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaidT) > (Decimal) dl.d.get(dl.fieldNameOT) ||
((Decimal) dl.rd.get(dl.fieldNameIntTaxP) + (Decimal) dl.rd.get(dl.fieldNameIntTaxW) ) > (Decimal) dl.d.get(dl.fieldNameIntTax) ||
((Decimal) dl.rd.get(dl.fieldNameIntAmtP) + (Decimal) dl.rd.get(dl.fieldNameIntAmtW) ) > (Decimal) dl.d.get(dl.fieldNameIntAmt)
) {
ApexPages.addMessage((new ApexPages.message(ApexPages.severity.FATAL, 'The amount paid is greater than the amount balance for charge:' + o+ ' in ' + dl.d.Invoice_Number__c)));
calcError = true;
hasPaymentDues = true;
} else {                        
System.debug('Field name to be  paid:' + dl);
totalMoneyAllocated += (Decimal) dl.rd.get(dl.fieldNametoBePaid) + (Decimal) dl.rd.get(dl.fieldNametoBePaidT) + (Decimal) dl.rd.get(dl.fieldNameIntAmtP) + (Decimal) dl.rd.get(dl.fieldNameIntTaxP); 
}   */                                 
            }
        }
        if(!calcError) {
            if(totalMoneyAllocated > moneyInHand) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The amount allocated ' + InventoryCostServices.InFormat(totalMoneyAllocated) + 
                                                           ' is greater than the amount left in this instrument ' + InventoryCostServices.Informat(moneyInHand)));
                calcError = true;
                hasPaymentDues = true;
                return null;
            }
        } else {            
            return null;
        } 
        for(String o : outstandingChargesMap.keySet()) {
            for(PaymentManagementServices_PS.DemandFieldLocationWrapper dl : outstandingChargesMap.get(o)) {  
                //Commented by Deepak because the "PaymentManagementServices_PS.getCustomerOutstandingChargeWise" code is commented.
                /*if(dl.rd.get(dl.fieldNametoBePaid) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaid) >  0 ||
dl.rd.get(dl.fieldNametoBePaidT) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaidT) > 0 ||
dl.rd.get(dl.fieldNameIntTaxP) != null &&  (Decimal) dl.rd.get(dl.fieldNameIntTaxP) > 0 || 
dl.rd.get(dl.fieldNameIntAmtP) != null &&  (Decimal) dl.rd.get(dl.fieldNameIntAmtP) > 0 ||
dl.rd.get(dl.fieldNameIntAmtW) != null &&  (Decimal) dl.rd.get(dl.fieldNameIntAmtW) > 0 ||
dl.rd.get(dl.fieldNameIntTaxW) != null &&  (Decimal) dl.rd.get(dl.fieldNameIntTaxW) > 0 ) {
System.debug('Demand wrapper:' + dl);
dl.rd.Status__c = 'Valid';
dl.rd.Transaction_Date__c = system.today();
dl.rd.Demand__c = dl.d.Id;
dl.rd.Total_Amount_Apportined__c = (Decimal) dl.rd.get(dl.fieldNametoBePaid) + (Decimal) dl.rd.get(dl.fieldNameIntAmtP); 
dl.rd.Total_Tax_Apportioned__c = (Decimal) dl.rd.get(dl.fieldNametoBePaidT) + (Decimal) dl.rd.get(dl.fieldNameIntTaxP);
dl.rd.Charges_Apportioned__c = (Decimal) dl.rd.get(dl.fieldNametoBePaid);
dl.rd.Taxes_Apportioned__c = (Decimal) dl.rd.get(dl.fieldNametoBePaidT);
dl.rd.Receipts__c = rmw.r.Id;
dl.rd.put(dl.chargeName, o);
rdList.add(dl.rd);
System.debug('RD post creating the details record:' + dl.rd);
}*/
            }
        }
        if(!rdList.isEmpty() && rdList != null) {
            // insert rdList;
            // rmw.r.On_Account_Money__c = moneyInHand - totalMoneyAllocated;
            /*update rmw.r;
            rmw.r = [Select Id, Name, PropStrength__Amount__c, PropStrength__Payment_Type__c, PropStrength__Payment_Date__c, Instrument_Date__c, PropStrength__Bank_Name__c,Drawee_Bank_If_Others__c,PropStrength__Application_Booking__c,
                     Drawn_in_favour_of__c, Instrument_Number__c, Receipt_Status__c,Remarks__c, 
                     Amount_in_Foreign_Currency__c,
                     Currency__c, FOREX__c, PropStrength__Application_Booking__r.PropStrength__Project__c,PropStrength__Application_Booking__r.PropStrength__Project__r.Name,PropStrength__Application_Booking__r.PropStrength__Project__r.Id,PropStrength__Application_Booking__r.PropStrength__Property_Name__c,PropStrength__Payment_Status__c from PropStrength__Received_Payment__c where id =:receiptId AND (RecordType.Name = 'Payment Received' OR RecordType.Name = 'Income Charge Received') ];
            // moneyInHand = rmw.r.On_Account_Money__c;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'The allocations have been saved. Remaining money on this instrument is:' + InventoryCostServices.Informat(moneyInHand)));
            if(moneyInHand == 0) {
                amountAdjusted = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No further processing can be done on this instrument as is has been completely apportioned'));
            } else {
                outstandingChargesMap = PaymentManagementServices_PS.getCustomerOutstandingChargeWise(rmw.r.PropStrength__Application_Booking__r.PropStrength__Property_Name__c);
                if(!outstandingChargesMap.isEmpty() && outstandingChargesMap.size() > 0) {
                    hasPaymentDues = true;
                }
                if(!hasPaymentDues) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Customer doesnot have any outstanding dues.' ));
                    return null;
                } 
            }*/
        }
        else{
            boolean isAmountEntered = false;
            if(!outstandingChargesMap.isEmpty() && outstandingChargesMap.size() > 0) {
                //Commented by Deepak because the "PaymentManagementServices_PS.getCustomerOutstandingChargeWise" code is commented.
                /* for(String o : outstandingChargesMap.keySet()) {
for(PaymentManagementServices_PS.DemandFieldLocationWrapper dl : outstandingChargesMap.get(o)) {
if( dl.rd.get(dl.fieldNametoBePaid) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaid) >  0 ||
dl.rd.get(dl.fieldNametoBePaidT) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaidT) > 0 ) {
isAmountEntered = true;        
} 
}
}    
if(!isAmountEntered){
hasPaymentDues = true;
}     */ 
            } 
        }
        return null;           
    }
    
    public PageReference advanceReceipt() {
        listOfAdvanceReceipt = new List<PropStrength__Received_Payment__c>();
        List<PropStrength__Received_Payment__c> recList = new List<PropStrength__Received_Payment__c>(); 
        isAdvanceRecipt = false;
        if(rmw.r != null && moneyInHand > 0){
            PropStrength__Received_Payment__c robj = new PropStrength__Received_Payment__c();
            rObj.PropStrength__Payment_Type__c = rmw.r.PropStrength__Payment_Type__c;
            rObj.PropStrength__Amount__c = moneyInHand;  
            rObj.Currency__c = rmw.r.Currency__c;
            rObj.PropStrength__Payment_Date__c = system.today();
            rObj.PropStrength__Bank_Name__c = rmw.r.PropStrength__Bank_Name__c;
            rObj.Instrument_Date__c = system.today();
            rObj.Instrument_Number__c = rmw.r.Instrument_Number__c;
            if(string.isNotBlank(rmw.r.Drawee_Bank_If_Others__c))
                rObj.Drawee_Bank_If_Others__c = rmw.r.Drawee_Bank_If_Others__c;
            rObj.PropStrength__Application_Booking__c = rmw.r.PropStrength__Application_Booking__c;
            rObj.Receipt_Status__c = rmw.r.Receipt_Status__c;
            // rObj.Advance_Receipt__c = true;
            // rObj.Parent_Receipt__c = rmw.r.id;
            rObj.Drawn_in_favour_of__c = rmw.r.Drawn_in_favour_of__c;
            // rObj.Total_Amount__c = moneyInHand;
            recList.add(rObj);            
            
            // rmw.r.Amount_Advanced__c =  moneyInHand;
            update rmw.r;
            rmw.r = [Select Id, Name, PropStrength__Amount__c, PropStrength__Payment_Type__c, PropStrength__Payment_Date__c, Instrument_Date__c, PropStrength__Bank_Name__c,Drawee_Bank_If_Others__c,PropStrength__Application_Booking__c,
                     Drawn_in_favour_of__c, Instrument_Number__c, Receipt_Status__c,Remarks__c, 
                     Amount_in_Foreign_Currency__c,
                     Currency__c, FOREX__c, PropStrength__Application_Booking__r.PropStrength__Project__c,PropStrength__Application_Booking__r.PropStrength__Project__r.Name,PropStrength__Application_Booking__r.PropStrength__Project__r.Id,PropStrength__Application_Booking__r.PropStrength__Property_Name__c,PropStrength__Payment_Status__c from PropStrength__Received_Payment__c where id =:receiptId AND (RecordType.Name = 'Payment Received' OR RecordType.Name = 'Income Charge Received')];
            
        }
        if(recList != null && !recList.isEmpty()){
            insert recList;
            isAdvanceRecipt = true;
            
            listOfAdvanceReceipt = [Select Id, Name, PropStrength__Amount__c, PropStrength__Payment_Type__c, PropStrength__Payment_Date__c, Instrument_Date__c, PropStrength__Bank_Name__c,Drawee_Bank_If_Others__c,PropStrength__Application_Booking__c,
                                    Drawn_in_favour_of__c, Instrument_Number__c, Receipt_Status__c,Remarks__c, 
                                    Amount_in_Foreign_Currency__c,
                                    Currency__c, FOREX__c, PropStrength__Application_Booking__r.PropStrength__Project__c,PropStrength__Application_Booking__r.PropStrength__Project__r.Name,PropStrength__Application_Booking__r.PropStrength__Project__r.Id,PropStrength__Application_Booking__r.PropStrength__Property_Name__c,PropStrength__Payment_Status__c from PropStrength__Received_Payment__c where id IN:recList AND (RecordType.Name = 'Payment Received' OR RecordType.Name = 'Income Charge Received')];
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Advance Receipts created successfully.' ));
            return null;
        }
        return null;
    }
    public class rMainWrapper{
        public PropStrength__Received_Payment__c r {get;set;}
        
        public rMainWrapper() {
            this.r = new PropStrength__Received_Payment__c();
        }
    }
}