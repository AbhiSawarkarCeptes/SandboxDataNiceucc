public with sharing class ReceiptModule {
    public Map<String, List<PaymentManagementServices.DemandFieldLocationWrapper>> outstandingChargesMap {get;set;}
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
    public List<Opportunity> oppList {get;set;}
    public List<Receipt__c> listOfAdvanceReceipt {get;set;}
    public Boolean isAdvanceRecipt{get;set;}
    public Boolean isReversedReceipt{get;set;}
       
    public ReceiptModule() {
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
        listOfAdvanceReceipt = new List<Receipt__c>();
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
            receiptId = ApexPages.currentPage().getParameters().get('id');
        }
        if(receiptId  != null) {
                List<Receipt__c> rc = new List<Receipt__c>();
            if(receiptId != null) {
             rc = [Select Id, Name, Amount_Rs__c, Mode__c, Receipt_Date__c, Cheque_DD_Date__c, DraweeBank__c,Drawee_Bank_If_Others__c,Tax_Receipt__c,Opportunity__c,Receipt_Number__c,
                    Drawn_in_favour_of__c, Cheque_DD__c, On_Account_Money__c, On_Account_Money_Autocalculated__c, Receipt_status__c,RemarksText__c,Booking__c,Advance_Receipt__c, 
                    Amount_in_Foreign_Currency__c,PAN_no_of_TDS_Deductor__c, PAN_no_of_TDS_Deductee__c, Challan_No__c,TDS_Amount_In_Rs__c,IsTDS_And_NoDemandRaised__c,
                    Currency__c, FOREX__c, Project__c, Demand__c, Project__r.Id,Project_Unit__c,Approval_Status__c,Opportunity_Email_Id__c,Description__c,Is_Reversed_Receipt__c from receipt__c where id =:receiptId ];
            }
            if(rc.size() == 1){
                rmw.r = rc[0];
                if(rmw.r.mode__c.equalsIgnoreCase('Cheque') || rmw.r.mode__c.equalsIgnoreCase('Wire Transfer') ||                 
                rmw.r.mode__c.equalsIgnoreCase('Cash') || rmw.r.mode__c.equalsIgnoreCase('Credit Card') ||
                rmw.r.mode__c.equalsIgnoreCase('Website')){
                    instrumentType = 'ins1';
                } else if (rmw.r.mode__c.equalsIgnoreCase('Credit Note')) {
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
                   if(rmw.r.Is_Reversed_Receipt__c) 
                        isReversedReceipt = true;                    
                    applyReceipt();
                }
            }
        } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please select a receipt to process'));
        }
    }
    
    public void getCustomerDetails() {
       oppList = [Select Name, Id, StageName,Primary_Name__c,Other_Applicants_Name__c, 
                Future_Correspondence_Contact__c,Future_Correspondence_Contact_Name__c, Email__c, 
                Future_Correspondence_Contact_Email__c, Primary_Email__c, Other_Applicants_Email__c,
                Primary_pancard__c, Other_Applicants_Pancard__c
                from Opportunity where Project__c = : rmw.r.Project__c and Unit__c =: rmw.r.Project_Unit__c and S_Active__c = TRUE];
       
        if(oppList.size() == 1) {
            if(String.isNotBlank(oppList[0].Primary_Name__c)) 
                applicantNames = oppList[0].Primary_Name__c;
            if(String.isNotBlank(oppList[0].Other_Applicants_Name__c) && string.IsnotBlank(applicantNames))
                applicantNames += ',' + oppList[0].Other_Applicants_Name__c;
            else if(String.isNotBlank(oppList[0].Other_Applicants_Name__c))
                applicantNames = oppList[0].Other_Applicants_Name__c;
        }
        if(oppList.size() == 1 && !oppList[0].stageName.equalsIgnoreCase('Booking Confirmed')) {
            onlyToken = true;
        } else if(oppList.size() != 1){
            unitError = true;
        } 
   }
    
    public PageReference applyReceipt() {       
        System.debug('Apply receipt:');
            // it will always be adjustment flow. create receipt is handled in a separate controller, no flow for creating and adjusting receipts
        if(adjustmentFlow) {
            if(foreignCurrency && rmw.r.Receipt_status__c != 'Cleared') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Foreign currency cheques can be processed only after the money has been realized & approved by finance'));
                error = true;
                return null;
            } else if(rmw.r.Receipt_Status__c.equalsIgnoreCase('Physical Verification Rejected') || rmw.r.Receipt_Status__c.equalsIgnoreCase('Dishonored') || rmw.r.Receipt_Status__c.equalsIgnoreCase('Cancelled') ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No further processing can be done on this instrument. The instrument is in ' + rmw.r.receipt_status__c + ' status'));
                error = true;
                return null;
            } 
            moneyInHand = rmw.r.On_Account_Money_Autocalculated__c;
            if(moneyInHand == 0) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No further processing can be done on this instrument. The instrument is  fully adjusted'));
                return null;
            }    
            else if(moneyInHand > 0 && rmw.r.Currency__c.equalsIgnoreCase('AED')) {// Indian Rupee changed to AED by Neha on 12/3/19
                    outstandingChargesMap = PaymentManagementServices.getCustomerOutstandingChargeWise(rmw.r.Project_Unit__c);
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
                for(PaymentManagementServices.DemandFieldLocationWrapper dl : outstandingChargesMap.get(o)) {
                    if(dl.rd.get(dl.fieldNametoBePaid) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaid) > (Decimal) dl.d.get(dl.fieldNameO) ||
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
                    }                                    
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
                for(PaymentManagementServices.DemandFieldLocationWrapper dl : outstandingChargesMap.get(o)) {               
                     if(dl.rd.get(dl.fieldNametoBePaid) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaid) >  0 ||
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
                        }
                }
            }
            if(!rdList.isEmpty() && rdList != null) {
                insert rdList;
                rmw.r.On_Account_Money__c = moneyInHand - totalMoneyAllocated;
                update rmw.r;
                rmw.r = [Select Id, Name, Amount_Rs__c, Mode__c, Receipt_Date__c, Cheque_DD_Date__c, DraweeBank__c,Drawee_Bank_If_Others__c,Booking__c,Opportunity__c,
                    Drawn_in_favour_of__c, Cheque_DD__c, On_Account_Money__c, On_Account_Money_Autocalculated__c, Receipt_status__c,RemarksText__c,Tax_Receipt__c,Advance_Receipt__c, 
                    Amount_in_Foreign_Currency__c,PAN_no_of_TDS_Deductor__c, PAN_no_of_TDS_Deductee__c, Challan_No__c,TDS_Amount_In_Rs__c,IsTDS_And_NoDemandRaised__c,Receipt_Number__c,
                    Currency__c, FOREX__c, Project__c,Project__r.Id,Project_Unit__c,Approval_Status__c,Opportunity_Email_Id__c from receipt__c where id =:receiptId ];
                moneyInHand = rmw.r.On_Account_Money__c;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'The allocations have been saved. Remaining money on this instrument is:' + InventoryCostServices.Informat(moneyInHand)));
                if(moneyInHand == 0) {
                    amountAdjusted = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No further processing can be done on this instrument as is has been completely apportioned'));
                } else {
                    outstandingChargesMap = PaymentManagementServices.getCustomerOutstandingChargeWise(rmw.r.Project_Unit__c);
                    if(!outstandingChargesMap.isEmpty() && outstandingChargesMap.size() > 0) {
                        hasPaymentDues = true;
                    }
                if(!hasPaymentDues) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Customer doesnot have any outstanding dues.' ));
                        return null;
                } 
                }
            }
            else{
                boolean isAmountEntered = false;
                if(!outstandingChargesMap.isEmpty() && outstandingChargesMap.size() > 0) {
                    for(String o : outstandingChargesMap.keySet()) {
                        for(PaymentManagementServices.DemandFieldLocationWrapper dl : outstandingChargesMap.get(o)) {
                            if( dl.rd.get(dl.fieldNametoBePaid) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaid) >  0 ||
                                dl.rd.get(dl.fieldNametoBePaidT) != null &&  (Decimal) dl.rd.get(dl.fieldNametoBePaidT) > 0 ) {
                                isAmountEntered = true;        
                            } 
                        }
                    }    
                    if(!isAmountEntered){
                        hasPaymentDues = true;
                    }      
                } 
            }
            return null;           
    }
    
    /////////////////// Below method Added by vikas, if no amount due and on account money is greater than zero then
    ////////////// Create Normal as well as service tax Advanced receipt
    public PageReference advanceReceipt() {
        listOfAdvanceReceipt = new List<Receipt__c>();
        List<Receipt__c> recList = new List<Receipt__c>(); 
        isAdvanceRecipt = false;
        if(rmw.r != null && moneyInHand > 0){
       //// Tax Receipt creation commented by Neha on 15/3/19 
     /*       Decimal taxAmount = moneyInHand * 0.12 ;
            //////// Creating Tax receipt Here ///////////////////
            Receipt__c robjT = new Receipt__c();
            rObjT.Mode__c = rmw.r.Mode__c;
            rObjT.Amount_Rs__c = taxAmount;  /////////  In tax reeipt adding only 12% amount of moneyInHand
            rObjT.Currency__c = rmw.r.Currency__c;
            rObjT.Receipt_Date__c = system.today();
            rObjT.DraweeBank__c = rmw.r.DraweeBank__c;
            rObjT.Cheque_DD_Date__c = system.today();
            rObjT.Cheque_DD__c = rmw.r.Cheque_DD__c;
            if(string.isNotBlank(rmw.r.Drawee_Bank_If_Others__c))
                rObjT.Drawee_Bank_If_Others__c = rmw.r.Drawee_Bank_If_Others__c;
            rObjT.Booking__c = rmw.r.Booking__c;
            rObjT.Opportunity__c = rmw.r.Opportunity__c;
            rObjT.Receipt_Status__c = rmw.r.Receipt_Status__c;
            rObjT.Project_Unit__c = rmw.r.Project_Unit__c;
            rObjT.Project__c = rmw.r.Project__c;    
            rObjT.Advance_Receipt__c = true;
            rObjT.Tax_Receipt__c = true;
            rObjT.Parent_Receipt__c = rmw.r.id;
            rObjT.Drawn_in_favour_of__c = rmw.r.Drawn_in_favour_of__c;
            rObjT.Total_Amount__c = taxAmount;
            recList.add(rObjT);*/
                        
            //////// Creating Installment receipt here ////////////
            Receipt__c robj = new Receipt__c();
            rObj.Mode__c = rmw.r.Mode__c;
            rObj.Amount_Rs__c = moneyInHand;  ////In InstallMent Receipt adding amount MoneyInHand
            rObj.Currency__c = rmw.r.Currency__c;
            rObj.Receipt_Date__c = system.today();
            rObj.DraweeBank__c = rmw.r.DraweeBank__c;
            rObj.Cheque_DD_Date__c = system.today();
            rObj.Cheque_DD__c = rmw.r.Cheque_DD__c;
            if(string.isNotBlank(rmw.r.Drawee_Bank_If_Others__c))
                rObj.Drawee_Bank_If_Others__c = rmw.r.Drawee_Bank_If_Others__c;
            rObj.Booking__c = rmw.r.Booking__c;
            rObj.Opportunity__c = rmw.r.Opportunity__c;
            rObj.Receipt_Status__c = rmw.r.Receipt_Status__c;
            rObj.Project_Unit__c = rmw.r.Project_Unit__c;
            rObj.Project__c = rmw.r.Project__c;    
            rObj.Advance_Receipt__c = true;
            rObj.Parent_Receipt__c = rmw.r.id;
            rObj.Drawn_in_favour_of__c = rmw.r.Drawn_in_favour_of__c;
            rObj.Total_Amount__c = moneyInHand;
            recList.add(rObj);            
            //////////// Updating old Receipt On account money as zero.
            
            rmw.r.Amount_Advanced__c =  moneyInHand;
            update rmw.r;
            rmw.r = [Select Id, Name, Amount_Rs__c, Mode__c, Receipt_Date__c, Cheque_DD_Date__c, DraweeBank__c,Drawee_Bank_If_Others__c,Booking__c,Opportunity__c,Receipt_Number__c,
                    Drawn_in_favour_of__c, Cheque_DD__c, On_Account_Money__c, On_Account_Money_Autocalculated__c, Receipt_status__c,RemarksText__c,Tax_Receipt__c,Advance_Receipt__c, 
                    Amount_in_Foreign_Currency__c,PAN_no_of_TDS_Deductor__c, PAN_no_of_TDS_Deductee__c, Challan_No__c,TDS_Amount_In_Rs__c,IsTDS_And_NoDemandRaised__c,
                    Currency__c, FOREX__c, Project__c,Project__r.Id,Project_Unit__c,Approval_Status__c,Opportunity_Email_Id__c from receipt__c where id =:receiptId ];
                
        }
        if(recList != null && !recList.isEmpty()){
            insert recList;
            isAdvanceRecipt = true;
            
            listOfAdvanceReceipt = [Select Id, Name, Amount_Rs__c, Mode__c, Receipt_Date__c, Cheque_DD_Date__c, DraweeBank__c,Drawee_Bank_If_Others__c,Booking__c,Opportunity__c,
                    Drawn_in_favour_of__c, Cheque_DD__c, On_Account_Money__c, On_Account_Money_Autocalculated__c, Receipt_status__c,RemarksText__c,Tax_Receipt__c,Advance_Receipt__c, 
                    Amount_in_Foreign_Currency__c,PAN_no_of_TDS_Deductor__c, PAN_no_of_TDS_Deductee__c, Challan_No__c,TDS_Amount_In_Rs__c,IsTDS_And_NoDemandRaised__c,Receipt_Number__c,
                    Currency__c, FOREX__c, Project__c,Project__r.Id,Project_Unit__c,Approval_Status__c,Opportunity_Email_Id__c from receipt__c where id IN:recList];
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Advance Receipts created successfully.' ));
            return null;
        }
        return null;
    }
    public class rMainWrapper{
        public Receipt__c r {get;set;}
        
        public rMainWrapper() {
        this.r = new Receipt__c();
        }
    }
}