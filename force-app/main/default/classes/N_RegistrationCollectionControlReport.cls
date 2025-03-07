public class N_RegistrationCollectionControlReport{
    public date fromDate {get;set;}
    public date toDate {get;set;}
    public String unitNo {get;set;}
    public List<Demand__c> demandList;
    public List<Receipt__c> receiptList;
    public List<Registration_Payment_Account__c> regList;
    public List<wrapperClass> wrap{get;set;}
    public List<wrapperClass> wrapListToDisplay{get;set;}
    public List<wrapperClass> wrapListToDownload{get;set;}
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
    
    public N_RegistrationCollectionControlReport(){               
        details = false;                                   
    }
    
    ///// This report will only contain Debit Note, Credit Note, Receipts and Registration Payment      
    public PageReference getReport(){
        wrap = new list<wrapperClass>();
        wrapListToDisplay = new list<wrapperClass>();
        wrapListToDownload = new list<wrapperClass>();
        amount = '';
        totalDebitAmount = 0.0;
        totalCreditAmount = 0.0;   
        debitAmountString = '';
        creditAmountString = '';   
        totalDebitAmountString = '';
        totalCreditAmountString = '';    
        debitBalanceString = '';
        creditBalanceString = '';    
        details = true;
        /////// Demand Query        
        String dmnQuery = ' SELECT Id, Name, Business_Unit__c, Booking__r.Primary_Applicant_Name__c, Unit__r.Name, Booking__r.Tower__c, GL_Date__c, Booking__r.Name, Booking__r.Stage_of_Booking__c, Payment_Towards__c, Total_Amount_Account__r.Name,'+
            ' Registration_Collection_Control_Report__c, Total_Amount_Demanded__c, Total_Tax_Demanded__c, Voucher_Number__c FROM Demand__c WHERE Registration_Collection_Control_Report__c > 0 AND Debit_Type__c != null AND Debit_Type__c != \'\' ';
        if(fromDate != null && toDate != null){
            dmnQuery += ' AND GL_Date__c >= :fromDate AND GL_Date__c <= :toDate';           
        } 
        if(unitNo != null && String.isNotBlank(unitNo)){
            dmnQuery += ' AND Unit__r.Name Like ' + '\'%' + unitNo+ '%\'';
        }    
        demandList = Database.Query(dmnquery + ' ORDER BY GL_Date__c LIMIT 50000');   
        system.debug('demand size::: ' + demandList.size());        
        //////// Receipt Query                           
        String rcptQuery = ' SELECT Id, Name, Booking__r.Primary_Applicant_Name__c, Project_Unit__r.Name, Booking__r.Tower__c, Mode__c, Business_Unit__c, GL_Date__c, Booking__r.Name, Booking__r.Stage_of_Booking__c, '+
            ' Currency__c, Amount_Rs__c, Receipt_Number__c, Receipt_Status__c, Demand__c, Demand__r.Name, Description__c, Voucher_Number__c, Payment_Towards__c, Debit_Account__r.Name, '+
            ' Registration_Collection_Control_Report__c, Bank_Reference_Number__c FROM Receipt__c WHERE Registration_Collection_Control_Report__c > 0 AND Receipt_Status__c IN (\'Cleared\', \'Processed-Sent for Banking\', \'PDC\') ';
        if(fromDate != null && toDate != null){
            rcptQuery += ' AND GL_Date__c >= :fromDate AND GL_Date__c <= :toDate';           
        } 
        if(unitNo != null && String.isNotBlank(unitNo)){
            rcptQuery += ' AND Project_Unit__r.Name Like ' + '\'%' + unitNo+ '%\'';
        }  
        receiptList = Database.Query(rcptQuery + ' ORDER BY GL_Date__c LIMIT 50000');   
        system.debug('receipt size::: ' + receiptList.size());     
        ////// Registration Payment Account Query
        String regQuery = ' SELECT Id, Name, Amount__c, Booking__r.Primary_Applicant_Name__c, Unit__r.Name, Booking__r.Tower__c, Booking__r.Name, Booking__r.Stage_of_Booking__c, Business_Unit__c, GL_Date__c FROM Registration_Payment_Account__c';
        if(fromDate != null && toDate != null){
            regQuery += ' WHERE GL_Date__c >= :fromDate AND GL_Date__c <= :toDate';           
        } 
        if(unitNo != null && String.isNotBlank(unitNo)){
            regQuery += ' AND Unit__r.Name Like ' + '\'%' + unitNo+ '%\'';
        }  
        regList = Database.Query(regQuery + ' ORDER BY GL_Date__c LIMIT 50000');
        system.debug('Registration payment size::: ' + regList.size());                                                                    
        if(!demandList.isEmpty()){
            for(Demand__c d: demandList){                 
                if(d.Total_Amount_Demanded__c != null && d.Total_Tax_Demanded__c != null) {
                    amount = INFormat(d.Total_Amount_Demanded__c + d.Total_Tax_Demanded__c);
                }
                debitAmountString = InFormat(d.Registration_Collection_Control_Report__c);
                if(d.Registration_Collection_Control_Report__c != null)
                    totalDebitAmount += d.Registration_Collection_Control_Report__c;
                wrap.add(new wrapperClass(d.Business_Unit__c, d.Booking__r.Primary_Applicant_Name__c, d.Unit__r.Name, d.Booking__r.Tower__c, d.Booking__r.Name, d.GL_Date__c, d.Booking__r.Stage_of_Booking__c, '', '', '', amount, '', debitAmountString, 'Debit Note', d.Voucher_Number__c, '', d.Payment_Towards__c, d.Total_Amount_Account__r.Name));                
            } 
        }
        
        if(!receiptList.isEmpty()){
            for(Receipt__c r: receiptList){  
                String type = '';
                if(r.Mode__c != 'Credit Note')
                    type = 'Receipt';
                else
                    type = 'Credit Note';              
                if(r.Amount_Rs__c != null){
                    amount = InFormat(r.Amount_Rs__c);
                }               
                creditAmountString = InFormat(r.Registration_Collection_Control_Report__c);
                if(r.Registration_Collection_Control_Report__c != null)
                    totalCreditAmount += r.Registration_Collection_Control_Report__c;                
                wrap.add(new wrapperClass(r.Business_Unit__c, r.Booking__r.Primary_Applicant_Name__c, r.Project_Unit__r.Name, r.Booking__r.Tower__c, r.Booking__r.Name, r.GL_Date__c, r.Booking__r.Stage_of_Booking__c, r.Mode__c, r.Receipt_Status__c, r.Currency__c, amount, creditAmountString, '', type, r.Voucher_Number__c, r.Bank_Reference_Number__c, r.Payment_Towards__c, r.Debit_Account__r.Name));
            }
        }
        if(!regList.isEmpty()){
            for(Registration_Payment_Account__c r: regList){                
                if(r.Amount__c != null){
                    amount = InFormat(r.Amount__c);
                    totalDebitAmount += r.Amount__c;
                }                                                              
                wrap.add(new wrapperClass(r.Business_Unit__c, r.Booking__r.Primary_Applicant_Name__c, r.Unit__r.Name, r.Booking__r.Tower__c, r.Booking__r.Name, r.GL_Date__c, r.Booking__r.Stage_of_Booking__c, '', '', '', amount, '', amount, 'Transfer', r.Name,'', '', ''));
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
                if(wrapListToDisplay != null && wrapListToDisplay.size() < 999){
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
        public String paymentTowards {get;set;}
        public String debitAccountName {get;set;}
        
        public wrapperClass(String buName, String customerName, String unitNo, String buildingName, String bookingNumber, Date GLDate, String bookingStatus, String rcptMode, String rcptStatus, String currenc, String enteredAmount, String credit, String debit, String type, String docNo, String bankRefNo, String paymentTowards, String debitAccountName){
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
            this.paymentTowards = paymentTowards;
            this.debitAccountName = debitAccountName;
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