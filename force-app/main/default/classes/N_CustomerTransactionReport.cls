public class N_CustomerTransactionReport{
    public date fromDate {get;set;}
    public date toDate {get;set;}
    public String unitNo {get;set;}
    public transient List<Demand__c> demandList;
    public transient List<Receipt__c> receiptList;
    public transient List<wrapperClass> wrap{get;set;}
    public transient List<wrapperClass> wrapListToDisplay{get;set;}
    public transient List<wrapperClass> wrapListToDownload{get;set;}
    public String amount;
    public Decimal totalDebitAmount;
    public Decimal totalCreditAmount;
    public String totalDebitAmountString {get;set;}
    public String totalCreditAmountString {get;set;}
    public String debitAmountString;
    public String creditAmountString;
    public String debitBalanceString {get;set;}
    public String creditBalanceString {get;set;}   
    public Boolean details{get;set;}           
    
    public N_CustomerTransactionReport(){               
        details = false;                                   
    }
    
    ///// This report will only contain Demands, Debit Note, Credit Note, Receipts   
    public PageReference getReport(){
        wrap = new list<wrapperClass>();
        wrapListToDisplay = new list<wrapperClass>();
        wrapListToDownload = new list<wrapperClass>();
        amount = '';
        totalDebitAmount = 0.0;
        totalCreditAmount = 0.0;
        String demandCorpCollectionControlReport = '';
        String receiptCorpCollectionControlReport = '';
        String demandRegCollectionControlReport = '';
        String receiptRegCollectionControlReport = '';
        debitAmountString = '';
        creditAmountString = '';   
        totalDebitAmountString = '';
        totalCreditAmountString = '';    
        debitBalanceString = '';
        creditBalanceString = '';    
        details = true;
        /////// Demand Query        
        String dmnQuery = ' SELECT Id, Name, Business_Unit__c, Booking__r.Primary_Applicant_Name__c, Unit__r.Name, Booking__r.Tower__c, GL_Date__c, Booking__r.Name, Booking__r.Stage_of_Booking__c, Booking__r.Sales_Managers__r.Name, Booking__r.Channel_Partner__r.Name, Total_Amount_Account__r.Name,'+
            ' Milestone_Name__c, Booking__r.Booking_Date__c, Debit_Type__c, Total_Amount_Demanded__c, Total_Tax_Demanded__c, Payment_Towards__c, Booking__r.Unit__r.Project_Property_Type__c, Booking__r.Agreement_Value__c, Adjustment_Entry__c, Corporate_Collection_Control_Report__c, Registration_Collection_Control_Report__c '+
            ' FROM Demand__c' ;
        if(fromDate != null && toDate != null){
            dmnQuery += ' WHERE GL_Date__c >= :fromDate AND GL_Date__c <= :toDate';           
        } 
        if(unitNo != null && String.isNotBlank(unitNo)){
            dmnQuery += ' AND Unit__r.Name Like ' + '\'%' + unitNo+ '%\'';
        }    
        demandList = Database.Query(dmnquery + ' ORDER BY GL_Date__c LIMIT 50000');  
        system.debug('demand size:: ' + demandList.size());      
        
        //////// Receipt Query                           
        String rcptQuery = ' SELECT Id, Name, Booking__r.Primary_Applicant_Name__c, Project_Unit__r.Name, Booking__r.Tower__c, Mode__c, Business_Unit__c, GL_Date__c, Booking__r.Name, Booking__r.Stage_of_Booking__c, Booking__r.Agreement_Value__c, Adjustment_Entry__c, Corporate_Collection_Control_Report__c, '+
            ' Currency__c, Amount_Rs__c, Receipt_Number__c, Receipt_Status__c, Demand__c, Demand__r.Name, Description__c, Booking__r.Sales_Managers__r.Name, Booking__r.Channel_Partner__r.Name, DraweeBank__c, Tax_Amount__c, Credit_Note_Amount__c, Debit_Account__r.Name, Registration_Collection_Control_Report__c, '+
            ' On_Account_Money_Autocalculated__c, Booking__r.Booking_Date__c, Bank_Reference_Number__c, Cheque_DD_Date__c, Payment_Towards__c, RemarksText__c, Booking__r.Unit__r.Project_Property_Type__c FROM Receipt__c WHERE Receipt_Status__c IN (\'Cleared\', \'Processed-Sent for Banking\', \'PDC\') ';
        if(fromDate != null && toDate != null){
            rcptQuery += ' AND GL_Date__c >= :fromDate AND GL_Date__c <= :toDate';           
        } 
        if(unitNo != null && String.isNotBlank(unitNo)){
            rcptQuery += ' AND Project_Unit__r.Name Like ' + '\'%' + unitNo+ '%\'';
        }  
        receiptList = Database.Query(rcptQuery + ' ORDER BY GL_Date__c LIMIT 50000');  
        system.debug('receipt size:: ' + receiptList.size());                      
        
        if(!demandList.isEmpty()){
            for(Demand__c d: demandList){ 
                String type = '';
                if(d.Debit_Type__c != '' && d.Debit_Type__c != null)
                    type = d.Debit_Type__c;
                else
                    type = 'Invoice';                
                if(d.Total_Amount_Demanded__c != null && d.Total_Tax_Demanded__c != null) {
                    amount = INFormat(d.Total_Amount_Demanded__c + d.Total_Tax_Demanded__c);
                    debitAmountString = InFormat(d.Total_Amount_Demanded__c + d.Total_Tax_Demanded__c);
                    totalDebitAmount += (d.Total_Amount_Demanded__c + d.Total_Tax_Demanded__c);
                }
                if(d.Corporate_Collection_Control_Report__c != null)
                    demandCorpCollectionControlReport = InFormat(d.Corporate_Collection_Control_Report__c);                   
                if(d.Registration_Collection_Control_Report__c != null)
                    demandRegCollectionControlReport = InFormat(d.Registration_Collection_Control_Report__c);    
                wrap.add(new wrapperClass(d.Business_Unit__c, d.Booking__r.Primary_Applicant_Name__c, d.Unit__r.Name, d.Booking__r.Tower__c, d.Booking__r.Name, d.GL_Date__c, d.Booking__r.Stage_of_Booking__c, '', '', '', amount, '', debitAmountString, type, '', d.name, d.Booking__r.Sales_Managers__r.Name, d.Booking__r.Channel_Partner__r.Name, d.Booking__r.Booking_Date__c.Date(), null, d.Payment_Towards__c, d.Booking__r.Unit__r.Project_Property_Type__c, INFormat(d.Booking__r.Agreement_Value__c), '', d.Milestone_Name__c, '', INFormat(d.Total_Amount_Demanded__c), INFormat(d.Total_Tax_Demanded__c), d.Adjustment_Entry__c, d.Total_Amount_Account__r.Name, demandCorpCollectionControlReport, demandRegCollectionControlReport));                
            } 
        }
        
        if(!receiptList.isEmpty()){
            for(Receipt__c r: receiptList){  
                String type = '';
                String orignalAmount = '';
                if(r.Mode__c != 'Credit Note'){
                    type = 'Receipt';
                    orignalAmount = INFormat(r.Amount_Rs__c);
                }
                else {
                    type = 'Credit Note';  
                    orignalAmount = INFormat(r.Credit_Note_Amount__c);
                }            
                if(r.Amount_Rs__c != null){
                    amount = InFormat(r.Amount_Rs__c);
                    creditAmountString = InFormat(r.Amount_Rs__c);
                    totalCreditAmount += r.Amount_Rs__c;                
                }
                if(r.Corporate_Collection_Control_Report__c != null)
                    receiptCorpCollectionControlReport = InFormat(r.Corporate_Collection_Control_Report__c);                   
                if(r.Registration_Collection_Control_Report__c != null)
                    receiptRegCollectionControlReport = InFormat(r.Registration_Collection_Control_Report__c);                
                wrap.add(new wrapperClass(r.Business_Unit__c, r.Booking__r.Primary_Applicant_Name__c, r.Project_Unit__r.Name, r.Booking__r.Tower__c, r.Booking__r.Name, r.GL_Date__c, r.Booking__r.Stage_of_Booking__c, r.Mode__c, r.Receipt_Status__c, r.Currency__c, amount, creditAmountString, '', type, r.Bank_Reference_Number__c, r.Name, r.Booking__r.Sales_Managers__r.Name, r.Booking__r.Channel_Partner__r.Name, r.Booking__r.Booking_Date__c.Date(), r.Cheque_DD_Date__c, r.Payment_Towards__c, r.Booking__r.Unit__r.Project_Property_Type__c, INFormat(r.Booking__r.Agreement_Value__c), r.DraweeBank__c, r.RemarksText__c, InFormat(r.On_Account_Money_Autocalculated__c), orignalAmount, InFormat(r.Tax_Amount__c), r.Adjustment_Entry__c, r.Debit_Account__r.Name, receiptCorpCollectionControlReport, receiptRegCollectionControlReport));
            }
        }
        
        totalDebitAmountString = INFormat(totalDebitAmount);
        totalCreditAmountString = INFormat(totalCreditAmount);
        if(totalDebitAmount > totalCreditAmount){
            debitBalanceString = INFormat(totalDebitAmount - totalCreditAmount);
            creditBalanceString = '';
        } else if(totalCreditAmount > totalDebitAmount){
            creditBalanceString = INFormat(totalCreditAmount - totalDebitAmount);
            debitBalanceString = '';
        }                  
        wrap.sort(); 
        //// Display only 999 records on page but allow to download upto 99999 records              
        if(wrap != null && wrap.size() > 999 && wrap.size() < 99999){
            for(wrapperClass w: wrap){
                if(wrapListToDisplay != null && wrapListToDisplay.size() < 300){
                    wrapListToDisplay.add(w);                    
                }                   
            }
            wrapListToDownload.addall(wrap);      
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'This report has large number of rows. Please download to see full results.'));
        } else if (wrap != null && wrap.size() > 99999){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'This report has large number of rows. Please select a shorter time duration.'));
        }
        else {
            wrapListToDownload.addall(wrap);
            wrapListToDisplay.addall(wrap);
        }  
        system.debug('display size::: ' + wrapListToDisplay.size());    
        system.debug('download size::: ' + wrapListToDownload.size());
        system.debug('wrap::: ' + wrap.size());           
        return null;       
    }
    
    public class wrapperClass implements Comparable {
        public String buName{get;set;}
        public String customerName{get;set;}
        public String unitNo{get;set;}
        public String buildingName{get;set;}
        public String bookingNumber{get;set;}
        public Date GLDate{get;set;} 
        public String bookingStatus{get;set;}
        public String rcptMode{get;set;}
        public String rcptStatus{get;set;}
        public String currenc{get;set;}
        public String enteredAmount{get;set;}  
        public String credit{get;set;}
        public String debit{get;set;}  
        public String type {get;set;}
        public String docNo {get;set;}
        public String bankRefNo {get;set;}
        public String sm {get;set;}
        public String cp{get;set;}
        public Date bookingDate {get;set;}
        public Date maturityDate {get;set;}
        public String paymentTowards {get;set;}
        public String unitType {get;set;}
        public String purchasePrice {get;set;}
        public String bankName {get;set;}
        public String descr {get;set;}
        public String onAcc {get;set;}
        public String originalAmount {get;set;}
        public String taxAmount {get;set;}
        public Boolean adjustmentEntry {get;set;}
        public String debitAccountName {get;set;}
        public String corpCollection {get;set;}
        public String regCollection {get;set;}
        
        public wrapperClass(String buName, String customerName, String unitNo, String buildingName, String bookingNumber, Date GLDate, String bookingStatus, String rcptMode, String rcptStatus, String currenc, String enteredAmount, String credit, String debit, String type, String bankRefNo, String docNo, String sm, String cp, Date bookingDate, Date maturityDate, String paymentTowards, String unitType, String purchasePrice, String bankName, String descr, String onAcc, String originalAmount, String taxAmount, Boolean adjustmentEntry, String debitAccountName, String corpCollection, String regCollection){
            this.buName = buName ;
            this.customerName = customerName;
            this.unitNo = unitNo;
            this.buildingName = buildingName;
            this.bookingNumber = bookingNumber;
            this.GLDate = GLDate;
            this.bookingStatus = bookingStatus;
            this.rcptMode = rcptMode;
            this.rcptStatus = rcptStatus;
            this.currenc = currenc;
            this.enteredAmount = enteredAmount;
            this.credit = credit;
            this.debit = debit;
            this.type = type;
            this.docNo = docNo;
            this.bankRefNo = bankRefNo;
            this.sm = sm;
            this.cp = cp;
            this.bookingDate = bookingDate;
            this.maturityDate = maturityDate;
            this.paymentTowards = paymentTowards;
            this.unitType = unitType;
            this.purchasePrice = purchasePrice;
            this.bankName = bankName;
            this.descr = descr;
            this.onAcc = onAcc;
            this.originalAmount = originalAmount;
            this.taxAmount = taxAmount;
            this.adjustmentEntry = adjustmentEntry;
            this.debitAccountName = debitAccountName;
            this.corpCollection = corpCollection;
            this.regCollection = regCollection;
        }  
        
        public Integer compareTo(Object ObjToCompare) {
            wrapperClass wrapper = (wrapperClass)(ObjToCompare);
            return sortByDate(wrapper);
        }
        private Integer sortByDate(wrapperClass wrapper) {
            if (this.GLDate > wrapper.GLDate) {
                return 1;
            }
            if (this.GLDate == wrapper.GLDate) {
                return 0;
            }
            return -1;
        }         
    }
    
    public static String INFormat(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        if(money == null) {
            return 'NIL';
        }
        Decimal tempMoney = money;
        String m0 = tempMoney.setscale(0,RoundingMode.HALF_UP).toPlainString();
        String decimalPart;
        List<String> tempStr = new List<String>();
        if(String.isNotBlank(m0)) {
            tempStr = m0.split('\\.');
            if(tempStr != null && tempStr.size() == 2) {
                decimalPart = tempStr[1];
            }
        }
        String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);         
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
            mf = mf;
        else
            mf = '- ' + mf;
        return mf;
    }       
}