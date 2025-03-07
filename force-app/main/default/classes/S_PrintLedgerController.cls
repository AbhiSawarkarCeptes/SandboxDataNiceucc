public class S_PrintLedgerController {
    public Id oppId {get; set;}
    public String projectImage {
        get;
        set;
    }
    public Opportunity Customer {
        get;
        set;
    }
    public String CRMName {
        get;
        set;
    }
    public String CRMEmail {
        get;
        set;
    }
    public String CRMMobile {
        get;
        set;
    }
    public String bookingDate {
        get;
        set;
    }
    public Decimal chequeDishonour {
        get;
        set;
    }
    public Decimal interestRate {
        get;
        set;
    }
    public String tdsRate {
        get;
        set;
    }
    public Map < String, Decimal > taxRateMap {
        get;
        set;
    }
    public Decimal taxRateBasic {
        get;
        set;
    }
    public Decimal tdsOnCurrent {
        get;
        set;
    }
    public Map < String, Decimal > taxSlabMap {
        get;
        set;
    }
    public Legal_Entity__c le {
        get;
        set;
    }
    public string errMsg {
        get;
        set;
    }
    public string Msg {
        get;
        set;
    }
    public Boolean error {
        get;
        set;
    }
    public Date ledgerDate {
        get;
        set;
    }
    public Map < string, Decimal > chargeAmountMap {
        get;
        set;
    }
    public Map < string, Decimal > otherChargesMap {
        get;
        set;
    }
    public String totalBasicDemanded {
        get;
        set;
    }
    public String totalBasicDue {
        get;
        set;
    }
     public String totalBasicTaxDue {
        get;
        set;
    }
     public String InterestDue {
        get;
        set;
    }
    public String OtherDue {
        get;
        set;
    }
    public String grandtotaldue{
        get;
        set;
    }
    public String totalBasicTaxDemanded {
        get;
        set;
    }
   public String PercentagePaidBasic {
        get;
        set;
    }
    public String PercentagePaidBasicTax {
        get;
        set;
    }
    public String totalBasicPaid {
        get;
        set;
    }
    public String totalBasicTaxPaid {
        get;
        set;
    }
    public String totalBasicOutstanding {
        get;
        set;
    }
    public String totalBasicTaxOutstanding {
        get;
        set;
    }
    
    public String totalDebitDemanded {
        get;
        set;
    }
   public String totalDebitPaid {
        get;
        set;
    }
    public String totalDebitTaxDemanded {
        get;
        set;
    }
    public String totalDebitTaxPaid {
        get;
        set;
    }
    public String totalDebitPercentage {
        get;
        set;
    }
    public String totalDebitPercentageTax {
        get;
        set;
    }
    
    public String totalOtherDemanded {
        get;
        set;
    }
    public String totalOtherTaxDemanded {
        get;
        set;
    }
    public String PercentagePaidOther {
        get;
        set;
    }
    public String PercentagePaidOtherTax {
        get;
        set;
    }
    public String totalOtherPaid {
        get;
        set;
    }
    public String totalOtherTaxPaid {
        get;
        set;
    }
    public String totalOtherOutstanding {
        get;
        set;
    }
    public String totalOtherTaxOutstanding {
        get;
        set;
    }
    public String totalInterest {
        get;
        set;
    }
    public String totalInterestDue {
        get;
        set;
    }
    public String totalInterestPaid {
        get;
        set;
    }
    public String totalInterestSettled {
        get;
        set;
    }
    public String totalInterestWaived {
        get;
        set;
    }
    public String PercentageInterestPaid {
        get;
        set;
    }
    public String gtDemanded {
        get;
        set;
    }
    public String gtPaid {
        get;
        set;
    }
    public String gtPercentage {
        get;
        set;
    }
    public String tdsOnFlatCost {
        get;
        set;
    }
    public String agreementValue {
        get;
        set;
    }
    public String onAccountMoney {
        get;
        set;
    }
    public List<Booking__c> booking {
        get;
        set;
    }
    public Integer carParksAllotted {
        get;
        set;
    }
    public List<LedgerManagementServices.LedgerPrintWrapper> lpwList {
        get;
        set;
    }
    public List<LedgerPrintWrapper> lpwLocalList {
        get;
        set;
    }
    public string ledgerStyle {
        get;
        set;
    }
    public string paymentsStyle {
        get;
        set;
    }
    public string simplifiedledgerStyle {
        get;
        set;
    }
    public string simplifiedpaymentsStyle {
        get;
        set;
    }
    public string type {
        get;
        set;
    }
    public List<Ledger__c> ledgerList {
        get;
        set;
    }
    public List<Ledger__c> lList{
        get;
        set;
    }    
    public string ProjectName {
        get;
        set;
    }
    public string towerClusterName {
        get;
        set;
    }
    public string ProjectUnitName {
        get;
        set;
    }
    public Decimal UnitActualArea {
        get;
        set;
    }
    public Decimal UnitCarpetArea {
        get;
        set;
    }
    public String CustomerPrimaryName {
        get;
        set;
    }
   public String CustomerApplicantName {
        get;
        set;
    }
   public String  CustomerMailingAddress {
        get;
        set;
    }
   public String  CustomerPhone {
        get;
        set;
    }
   public String  CustomerEmail {
        get;
        set;
    }
    public String  CustomerUnitStatus {
        get;
        set;
    }
    public Profile pfile {
        get;
        set;
    }
    public Boolean flag{
        get;
        set;   
    }
    public String refString{
        get;
        set;
    }    
  
    public S_PrintLedgerController() {
        System.debug('In constructor');
        ledgerStyle = 'None';
        paymentsStyle = 'None';
        simplifiedledgerStyle = 'None';
        simplifiedpaymentsStyle = 'None';
        agreementValue ='';
        // This flag is added to show disclaimer when login by Customer Community
        flag=false;        
        Profile pfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String pname = pfile.name;
        system.debug('pfile : ' + pfile );
        system.debug('pname : ' + pname );
        if(pname == 'Customer Community')
        {
            flag = true;
        }
        else
        {
            flag = false;
        }
        system.debug('Flag : ' + flag);
        oppId = (Id)ApexPages.currentPage().getParameters().get('id');
        getLedgerDetails();
    }
    
    public void getLedgerDetails() {
        System.debug('OPPID:' + oppId);
        error = false;
        Msg = '';
        errMsg = '';
        oppId = oppId;
        carParksAllotted = 0;
        totalBasicDemanded = '';
        totalBasicTaxDemanded = '';
        totalBasicOutstanding = '';
        totalBasicTaxOutstanding = '';
        totalOtherDemanded = '';
        totalOtherTaxDemanded = '';
        totalOtherOutstanding = '';
        totalOtherTaxOutstanding = '';
        totalInterest = '';
        totalInterestDue = '';
        totalInterestPaid ='';
        totalInterestWaived = '';
        totalInterestSettled = '';
        PercentageInterestPaid = '';
        agreementValue ='';
        totalBasicPaid = '';
        totalBasicTaxPaid = '';
        PercentagePaidBasic = '';
        PercentagePaidBasicTax = '';
        totalOtherPaid = '';
        totalOtherTaxPaid = '';
        PercentagePaidOther = '';
        PercentagePaidOtherTax = '';
        tdsOnFlatCost = '';
        OnAccountMoney = '';
        gtDemanded = '';
        gtPaid = '';
        gtPercentage = '';
        totalBasicDue = '';
        totalBasicTaxDue = '';
        InterestDue = ''; 
        OtherDue = '';
        grandtotaldue = '';
        otherChargesMap = new Map < string, Decimal >();
        chargeAmountMap = new Map < string, Decimal >();
        
        lpwList = new List<LedgerManagementServices.LedgerPrintWrapper>();
        lpwLocalList = new List<LedgerPrintWrapper>();
        ledgerList  = new List<Ledger__c>();
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '')
        {
            oppId = (Id)ApexPages.currentPage().getParameters().get('id');
        }
        system.debug('oppId:: '+oppId);
        if(ApexPages.currentPage().getParameters().get('type') != null && ApexPages.currentPage().getParameters().get('type') != '')
        {
            type = ApexPages.currentPage().getParameters().get('type');
            if(type == 'payments') {
                paymentsStyle = '';
                simplifiedpaymentsStyle = '';
            } 
        }   
        if(type != 'payments') {
            ledgerStyle = '';
            SimplifiedledgerStyle = '';
        }
        System.debug('Type:' + type + 'Payment Style:' + paymentsStyle + 'Ledger Style:' + ledgerStyle);
        if(oppId != null) {
            ledgerDate = system.today();
            getCustomerDetails();
        } else {
            errMsg = 'Please select a valid customer/opportunity for printing the ledger';
            error = true;
            System.debug('error:' + error);
        }
    }
    
    public void getCustomerDetails() {
                system.debug('inside getcustomerdetails');
                System.debug('OPPID inside customer details:' + oppId);
                lpwLocalList = new List<LedgerPrintWrapper>();
                LedgerPrintWrapper lpwLocal;
                Decimal Balance = 0;
                Decimal TotalDemanded = 0;
                Decimal TotalPaid = 0;
                Decimal TotalDue = 0;
                
                Customer = [select id, Name, Primary_Email__c, Other_Applicants_Email__c,Primary_Name__c, Total_Interest_Waiver__c,Total_Interest__c,Total_Interest_Settled__c,Total_Waiver__c,
                Other_Applicants_Name__c,Mailing_Address__c, Future_Correspondence_Contact__c, Future_Correspondence_Contact_Name__c,Future_Correspondence_Contact_Email__c,
                Project__c, Project__r.name,
                
                Booking__r.Unit__r.Tower__r.Name, Booking__r.Unit__r.Tower__r.Cluster__r.Name,
                Unit__c, Booking__r.Unit__r.Name, Booking__r.Unit__r.Interest__c, Booking__r.Unit__r.Legal_Entity__r.name,
                Booking__r.Unit__r.Legal_Entity__r.RDS_PAN_No__c, Booking__r.Unit__r.Legal_Entity__r.RDS_Service_Tax_No__c, 
                Booking__r.Unit__r.Legal_Entity__r.RDS_Address1__c, Booking__r.Unit__r.Legal_Entity__r.SPV_Bank_Account__c,               
                Account.Correspondence_Address__c, Project__r.Address__c, Account.BillingCity, Account.BillingStreet, 
                Account.BillingState, Account.BillingpostalCode,
                Account.BillingCountry, Account.PersonMobilePhone,                 
                Booking__r.Name, Booking__r.Unit__r.Unit_Status__c,Booking__r.Unit__r.Actual_Area_value__c,Booking__r.Unit__r.Carpet_Area__c,
                Booking__r.Booking_Date__c, Booking__r.Owner.Name, 
                Booking__r.Owner.Email, Booking__r.Owner.Phone,Booking__r.Quotation__c,Booking__r.Quotation__r.Agreement_Value_Quotation__c,
                Booking__r.Quotation__r.Agreement_Value_Discounted_Quotation__c,
                
                Booking__r.TotalAmountDemanded__c,Booking__r.TotalAmountPaid__c,Booking__r.TotalAmountBalance__c,
                Booking__r.TotalTaxDemanded__c,Booking__r.Totaltaxpaid__c,Booking__r.TotalTaxBalance__c,
                
                Booking__r.Total_Agreement_Value_Demanded__c,Booking__r.Total_Agreement_Value_Paid__c,Booking__r.Total_Agreement_Value_Balance__c,Booking__r.Agreement_Value_Paid_Percent__c,
                Booking__r.Total_Service_Tax_Paid__c, Booking__r.Total_Service_Tax_Demanded__c, Booking__r.Total_Service_Tax_Balance__c, Booking__r.Agreement_Value_Tax_Paid_Percent__c,
                
                Booking__r.Total_Other_Charges_Demanded__c,Booking__r.Total_Other_Charges_Paid__c,Booking__r.Total_Other_Charges_Balance__c,Booking__r.Total_Other_Charges_Paid_Percent__c,
                /*Booking__r.Total_Other_Charges_ST_Demanded__c,Booking__r.Total_Other_Charges_ST_Paid__c,Booking__r.Total_Other_Charges_ST_Balance__c,Booking__r.Total_Other_Charges_Paid_Tax_Percent__c,*/                         
                
                Booking__r.Total_Debit_Amt_Demanded__c,Booking__r.Total_Debit_Amt_Paid__c,Booking__r.Total_Debit_Amt_Balance__c,Booking__r.Total_Debit_Percent__c,
                Booking__r.Total_Debit_Tax_Demanded__c,Booking__r.Total_Debit_Tax_Paid__c,Booking__r.Total_Debit_Tax_Balance__c,Booking__r.Total_Debit_Tax_Percent__c,
                
                Project__r.RDS_Company_Code__r.RDS_Company_Code__c, 
                Project__r.RDS_Company_Code__r.RDS_PAN_No__c, Project__r.RDS_Company_Code__r.RDS_Service_Tax_No__c,
                Project__r.RDS_Interest_Rate__c, Project__r.Cheque_Dishonour__c, Project__r.RDS_Company_Code__r.Name, 
                Project__r.RDS_Company_Code__r.SPV_Bank_Account__c, Project__r.RDS_Company_Code__r.RDS_Address1__c,
                Booking__r.Quotation__r.Total_Agreement_Value_Bucket__c
                from Opportunity
                where id = : oppId];
                system.debug('Customer Query:- '+Customer);
        if (Customer != null) {
            ProjectName =  Customer.Project__r.Name;
            towerClusterName = Customer.Booking__r.Unit__r.Tower__r.Name + ',' + Customer.Booking__r.Unit__r.Tower__r.Cluster__r.Name;
            ProjectUnitName = Customer.Booking__r.Unit__r.Name;
            UnitActualArea = Customer.Booking__r.Unit__r.Actual_Area_value__c ; 
            UnitCarpetArea = Customer.Booking__r.Unit__r.Carpet_Area__c;           
            CustomerPrimaryName = Customer.Primary_Name__c;
            CustomerApplicantName =  Customer.Other_Applicants_Name__c;
            CustomerMailingAddress = Customer.Mailing_Address__c ;
            CustomerPhone = Customer.Account.PersonMobilePhone;
            CustomerEmail = Customer.Primary_Email__c ;
            CustomerUnitStatus = Customer.Booking__r.Unit__r.Unit_Status__c;
           
            agreementValue = String.valueOf(Customer.Booking__r.Quotation__r.Total_Agreement_Value_Bucket__c);
            
            totalBasicDemanded = String.valueOf(Customer.Booking__r.Total_Agreement_Value_Demanded__c);
            totalBasicPaid = String.valueOf(Customer.Booking__r.Total_Agreement_Value_Paid__c);
            totalBasicDue = String.valueOf(Customer.Booking__r.Total_Agreement_Value_Balance__c);
            PercentagePaidBasic = String.valueOf(Customer.Booking__r.Agreement_Value_Paid_Percent__c);
            
            System.debug('My::; ' + Customer.Booking__r.Total_Service_Tax_Demanded__c);           
            totalBasicTaxDemanded = String.valueOf(Customer.Booking__r.Total_Service_Tax_Demanded__c.setscale(2,RoundingMode.HALF_UP));
            System.debug('totalBasicTaxDemanded:: ' + totalBasicTaxDemanded);
            totalBasicTaxPaid = String.valueOf(Customer.Booking__r.Total_Service_Tax_Paid__c);
            totalBasicTaxDue = String.valueOf(Customer.Booking__r.Total_Service_Tax_Balance__c);
            PercentagePaidBasicTax = String.valueof(Customer.Booking__r.Agreement_Value_Tax_Paid_Percent__c);
            
            totalOtherDemanded = String.valueOf(Customer.Booking__r.Total_Other_Charges_Demanded__c);
            totalOtherPaid = String.valueOf(Customer.Booking__r.Total_Other_Charges_Paid__c);
            OtherDue = String.valueOf(Customer.Booking__r.Total_Other_Charges_Balance__c);
            PercentagePaidOther =  String.valueof(Customer.Booking__r.Total_Other_Charges_Paid_Percent__c);
            
            totalOtherTaxDemanded = String.valueOf(Customer.Booking__r.Total_Other_Charges_Demanded__c);
            totalOtherTaxPaid = String.valueOf(Customer.Booking__r.Total_Other_Charges_Paid__c); //  + Customer.Booking__r.Total_Society_Charges_Tax_Paid__c // Commented by Neha on 30/5/19 to delete Total_Society_charges_Tax_Paid__c field
            totalOtherTaxOutstanding = String.valueOf(Customer.Booking__r.Total_Other_Charges_Balance__c); //  + Customer.Booking__r.Total_Society_Charges_Tax_Balance__c // Commented by Neha on 30/5/19 to delete Total_Society_Charges_Tax_Balance__c field
         //   PercentagePaidOtherTax =  String.valueof(Customer.Booking__r.Total_Other_Charges_Paid_Tax_Percent__c); //  + Customer.Booking__r.Total_Society_Paid_Tax_Percent__c // Commented by Neha on 30/5/19 to delete Total_Society_Paid_Tax_Percent__c field
            
            totalDebitDemanded = String.valueOf(Customer.Booking__r.Total_Debit_Amt_Demanded__c);
            totalDebitPaid = String.valueOf(Customer.Booking__r.Total_Debit_Amt_Paid__c);
            totalDebitPercentage = String.valueOf(Customer.Booking__r.Total_Debit_Percent__c);
            
            totalDebitTaxDemanded = String.valueOf(Customer.Booking__r.Total_Debit_Tax_Demanded__c);
            totalDebitTaxPaid = String.valueOf(Customer.Booking__r.Total_Debit_Tax_Paid__c);
            totalDebitPercentageTax =  String.valueof(Customer.Booking__r.Total_Debit_Tax_Percent__c);
            
            
            TotalDemanded = (Customer.Booking__r.TotalAmountDemanded__c + Customer.Booking__r.TotalTaxDemanded__c);
            
            TotalPaid = (Customer.Booking__r.TotalAmountPaid__c + Customer.Booking__r.TotalTaxPaid__c);
            
            TotalDue = (Customer.Booking__r.TotalAmountBalance__c + Customer.Booking__r.TotalTaxBalance__c);
                      
            gtDemanded = String.valueOf(TotalDemanded.setscale(2,RoundingMode.HALF_UP));
            gtPaid = String.valueOf(TotalPaid);
            grandtotaldue = String.valueOf(TotalDue);          

            CRMName = Customer.Booking__r.Owner.Name;
            CRMEmail = Customer.Booking__r.Owner.Email;
            CRMMobile = '123456789';             //Customer.Booking__r.Owner.Phone;
            if(Customer.Booking__r.Booking_Date__c != null)
                bookingDate = Customer.Booking__r.Booking_Date__c.format('dd MMM,yyyy');
            
            getledgerPrint();
           if(lpwList.size() > 0)
            { 
               if(lpwList[0].l.id != null){
                    ledgerList = [Select Name,Opportunity__r.Project__r.Project_Image__c From Ledger__c Where id =: lpwList[0].l.id];
                   
                }
            
            }
            OnAccountMoney = InFormat(PaymentManagementServices.getOnAccountMoney(oppId));
         
        } else {
            errMsg = 'Invalid customer: Ledger cannot be printed';
            error = true;
        }
        
        System.debug('Customer Detail:' + customer);
        System.debug('List in Ledger Print:' + lpwLocalList.size());
        
    }
    
    
    public void getledgerPrint() {
            String header = '';
            String Simplifiedheader = '';
            Integer count = 0;
            lpwList = LedgerManagementServices.getCustomerLedgers(oppId);
            String cc='';
            System.debug('lpwList::: ' + lpwList);
            for(LedgerManagementServices.LedgerPrintWrapper lpw : lpwList) {
                if(lpw.refNo == 0)
                    cc = '#FACDCD';
                if(lpw.refNo == 1)
                    cc = '#F8FACD';
                if(lpw.refNo == 2)
                    cc = '#D2FACD';
                if(lpw.refNo == 3)
                    cc = '#CDFAEC';
                if(lpw.refNo == 4)
                    cc = '#ECCDFA';
                if(lpw.refNo == 5)
                    cc = '#F1DB42';
                if(lpw.refNo == 6)
                    cc = '#F04158';
                if(lpw.refNo == 7)
                    cc = '#9BBAF0';
                if(lpw.refNo == 8)
                    cc = '#FFC469';
                if(lpw.refNo == 9)
                    cc = '#79FEC0';
                if(lpw.refNo == 10)
                    cc = '#6BD9F8';
                if(lpw.refNo == 11)
                    cc = '#DFF79F';
                if(lpw.refNo == 12)
                    cc = '#B390C2';
                if(lpw.refNo == 13)
                    cc = '#DBC31D';
                if(lpw.refNo == 14)
                    cc = '#D6CEAA';
                if(lpw.refNo == 15)
                    cc = '#B8FD99';
                if(lpw.refNo == 16)
                    cc = '#FFFDC0';
                if(lpw.refNo == 17)
                    cc = '#D2BC24';
                if(lpw.refNo == 18)
                    cc = '#1CCB75';
                if(lpw.refNo == 19)
                    cc = '#6D997A';
                if(lpw.refNo == 20)
                    cc = '#DED1B6'; 
                if(lpw.refNo == 21)
                    cc = '#FECEA8'; 
                if(lpw.refNo == 22)
                    cc = '#FF847C'; 
                if(lpw.refNo == 23)
                    cc = '#F2F0DF'; 
                if(lpw.refNo == 24)
                    cc = '#7FB8B0';  
                if(lpw.refNo == 25)
                    cc = '#E8591C';  
                if(lpw.refNo == 26)
                    cc = '#B5AC01'; 
                if(lpw.refNo == 27)
                    cc = '#FFFDC0'; 
                if(lpw.refNo == 28)
                    cc = '#457D97'; 
                if(lpw.refNo == 29)
                    cc = '#C0D1C2';
                if(lpw.refNo == 30)
                    cc = '#2E4347';
                if(lpw.refNo == 31)
                    cc = '#BCA297';
                if(lpw.refNo == 32)
                    cc = '#AB526B';
                if(lpw.refNo == 33)
                    cc = '#6B5D4D';
                if(lpw.refNo == 34)
                    cc = '#F77825';
                if(lpw.refNo == 35)
                    cc = '#B9D48B';
                if(lpw.refNo == 36)
                    cc = '#8D2036';    
                if(lpw.refNo == 37)
                    cc = '#94B053';
                if(lpw.refNo == 38)
                    cc = '#82837E'; 
                if(lpw.refNo == 37)
                    cc = '#1F6764';
                if(lpw.refNo == 38)
                    cc = '#92B35A';
                if(lpw.refNo == 39)
                    cc = '#1F6764';
                if(lpw.refNo == 40)
                    cc = '#F2F26F';          
                if(lpw.refNo == 1001)
                    cc = '#F9BA84';
                if(lpw.refNo == 1002)
                    cc = '#E0E05A';
                    
                
                // setting the header to None, makes the display style none at the page.
                // setting the header style to '' makes the tr which contains the 
                // page break element and rowheader element to appear on every page break
                if(ledgerStyle == '') {
                    if (count < 8) { 
                        header = 'None';
                    } else if(Math.mod(count+2,11) == 0) {
                        header = ''; 
                    } else {
                        header = 'None';
                    }
                } else {
                    if (count < 8) { 
                        header = 'None';
                    } else if(Math.mod(count+2,11) == 0) {
                        header = ''; 
                    } else {
                        header = 'None';
                    }
                }
                
                //Added by shailesh for simplified ledger//
                if(simplifiedledgerStyle == '') {
                    if (count < 40) { 
                        Simplifiedheader = 'None';
                    } else if(Math.mod(count+2,42) == 0) {
                        Simplifiedheader = ''; 
                    } else {
                        Simplifiedheader = 'None';
                    }
                } else if(simplifiedpaymentsStyle == ''){
                    if (count < 40) {
                        Simplifiedheader = 'None';
                    } else if(Math.mod(count+2,42) == 0) {
                        Simplifiedheader = ''; 
                    } else {
                        Simplifiedheader = 'None';
                    }
                }
                //ends here//
                
                LedgerPrintWrapper lpwLocal;
                if(lpw.l.Activity__c == 'Credit')
                    lpwLocal = new LedgerPrintWrapper(lpw.l, lpw.chargeName, lpw.Amount, lpw.refNo, lpw.refString, cc, lpw.Balance, lpw.demandFor, lpw.paymentFor, lpw.DemandDetails, lpw.PaymentDetails, header,lpw.simplifiedDemandDetails, lpw.simplifiedPaymentDetails,Simplifiedheader);
                else if(lpw.l.Activity__c == 'Debit' && (ledgerStyle == '' || simplifiedledgerStyle == '' ))
                    lpwLocal = new LedgerPrintWrapper(lpw.l, lpw.chargeName, lpw.Amount, lpw.refNo, lpw.refString, cc, lpw.Balance, lpw.demandFor, lpw.paymentFor, lpw.DemandDetails, lpw.PaymentDetails, header,lpw.simplifiedDemandDetails, lpw.simplifiedPaymentDetails,Simplifiedheader);
                
                lpwLocalList.add(lpwLocal);
                System.debug('Ledger wrapper:' + lpwLocal);
                if(lpw.l.Activity__c == 'Credit'){ 
                    count ++;
                } else if(lpw.l.Activity__c == 'Debit' && (ledgerStyle == '' || simplifiedledgerStyle == '' )){
                    count++;
                } else { //skip counting the debit rows if the type is only payments, it affects the number of rows printed on a page
                    
                }
                cc='';
            }
            //System.debug('List in Ledger Print:' + lpwLocalList.size());
    }
    // method for formatting the currency details to Indian Commas Format
    public static String INFormat(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
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
          /*  if(i==2) {
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
    
        public class LedgerPrintWrapper {
        public Ledger__c l {get;set;}
        public Integer refNo {get;set;}
        public String refString {get;set;}
        public String chargeName {get;set;}
        public String Amount {get;set;}
        public String colorCode {get;set;}
        public String Balance {get;set;}
        public String DemandFor {get;set;}
        public String paymentFor {get;set;}
        public String demandDetails {get;set;}
        public String paymentDetails {get;set;}
        public String simplifieddemandDetails {get;set;}
        public String simplifiedpaymentDetails {get;set;}
        public String header {get;set;}
        public String simplifiedheader {get;set;}
            
        public LedgerPrintWrapper(Ledger__c l, String cName, String Amount, Integer refNo, String refString, String cc, String Balance, String demandFor, String paymentFor, String demandDetails, String paymentDetails, String Header, String simplifiedDemandDetails, String simplifiedPaymentDetails, String Simplifiedheader) {
            this.l = l;
            this.chargeName = cName;
            this.Amount = Amount;
            this.refNo = refNo;
            this.colorCode = cc;
            this.balance = balance;
            this.demandFor = demandFor;
            this.paymentFor = paymentFor;
            this.demandDetails = demandDetails;
            this.paymentDetails = paymentDetails;
            this.simplifieddemandDetails = simplifieddemandDetails;
            this.simplifiedpaymentDetails = simplifiedpaymentDetails;
            this.refString = refString;
            this.header = header;
            this.Simplifiedheader = Simplifiedheader;
        }
    }
    
}