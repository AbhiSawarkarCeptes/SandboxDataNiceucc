public class N_CustomerSOAControllerUnProce{
        public String oppId;
        public Opportunity Customer {get; set;}
        public List<Demand__c> demandList;
        public List<Receipt__c> receiptList;
        public List<wrapperClass> wrap{get;set;}
        public String towerClusterName {get;set;}
        public Date ledgerDate {get;set;}
        public String agreementValue{get;set;}
        public String area{get;set;}
        public Decimal debitAmount;
        public Decimal creditAmount;
        public String debitAmountString {get;set;}
        public String creditAmountString {get;set;}
        public String debitBalanceString {get;set;}
        public String creditBalanceString {get;set;}        
        public Date dateprint{get;set;}  
        public Decimal totalRegistrationamount{get;set;}
        public Decimal totalRegistrationamountdemand {get;set;}
        public Decimal totalRegistrationamountreceipt {get;set;}          
        public String totalRegistrationamountString {get;set;}  
    
    public N_CustomerSOAControllerUnProce(){     
        ledgerDate = System.today();
        String amount = '';
        debitAmount = 0.0;
        creditAmount = 0.0;   
        agreementValue = '0.0';
        area = '0';
        debitAmountString = '';
        creditAmountString = '';       
        debitBalanceString = '';
        creditBalanceString = ''; 
        dateprint=null;     
        wrap = new List<wrapperClass>();
        totalRegistrationamount = 0.0;
        totalRegistrationamountdemand = 0.0;
        totalRegistrationamountreceipt = 0.0;
        totalRegistrationamountString = '';
        
         if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '')
             oppId = ApexPages.currentPage().getParameters().get('id');
         if(oppId != null && oppId != '') {   
             Customer = [SELECT id, Name, Primary_Email__c, Other_Applicants_Email__c, Primary_Name__c, Other_Applicants_Name__c,
                        Mailing_Address__c, Booking__r.Name, Booking__r.Unit__r.Unit_Status__c, Booking__r.Agreement_Value__c,
                        Project__r.name, Unit__r.Chargeable_Area__c, Booking__r.No_of_Earmarked_Parking__c, Booking__r.Unit__r.Tower__r.Name,             
                        Booking__r.Unit__r.Tower__r.Cluster__r.Name,  Booking__r.Unit__r.Legal_Entity__r.name, 
                        Booking__r.Unit__r.Name, Account.PersonMobilePhone                                                                      
                        FROM Opportunity WHERE id = :oppId];  
                                          
            if(Customer.Booking__r.Agreement_Value__c != null)         
                agreementValue= INFormat(Customer.Booking__r.Agreement_Value__c); 
            
            if(Customer.Unit__r.Chargeable_Area__c != null)     
                area = INFormat(Customer.Unit__r.Chargeable_Area__c); 
                    
            towerClusterName = Customer.Booking__r.Unit__r.Tower__r.Cluster__r.Name + ' ' + Customer.Booking__r.Unit__r.Tower__r.Name;
                 
            demandList = [SELECT Id, Name, Total_Amount_Demanded__c, Demand_Status__c, Milestone_Name__c, GL_Date__c, Due_Date__c, Invoice_Date__c, Debit_Type__c, 
                          Total_Tax_Demanded__c, Createddate, Registration_Collection_Control_Report__c
                          FROM Demand__c 
                          WHERE Booking__r.Opportunity__c = :oppId 
                          ORDER BY Createddate];
                         
            receiptList = [SELECT Id, Name, Project_Unit__r.Name, Mode__c, Cheque_DD_Date__c, GL_Date__c, Cheque_DD__c, DraweeBank__c, 
                           Currency__c, Amount_Rs__c, Receipt_Number__c, Receipt_Status__c, Demand__c, Demand__r.Name, Description__c, Createddate,
                           Registration_Collection_Control_Report__c    
                           FROM Receipt__c 
                           WHERE Booking__r.Opportunity__c = :oppId AND Receipt_Status__c IN('Cleared', 'Processed-Sent for Banking', 'PDC', 'UnProcessed')
                           ORDER BY Createddate];
             
             if(!demandList.isEmpty()){
             
                 for(Demand__c d: demandList){ 
                     String name = '';
                     String detail = '';
                     String paidFor = '';
                     
                    if(d.Total_Amount_Demanded__c != null && d.Total_Tax_Demanded__c != null) {
                        debitAmount += (d.Total_Amount_Demanded__c + d.Total_Tax_Demanded__c);  
                        If(d.Registration_Collection_Control_Report__c != null){
                        amount = INFormat((d.Total_Amount_Demanded__c + d.Total_Tax_Demanded__c) - d.Registration_Collection_Control_Report__c);
                        totalRegistrationamountdemand += d.Registration_Collection_Control_Report__c;
                        }
                        system.debug('totalRegistrationamountdemand ::'+totalRegistrationamountdemand );
                    }
                    if((d.Debit_Type__c == '' || d.Debit_Type__c == null) && String.isNotBlank(d.Milestone_Name__c)){                                    
                        name = 'Demand for ' +  d.Milestone_Name__c;
                        if(d.Milestone_Name__c.containsIgnoreCase('On Completion'))
                            name = 'Demand for ' +  d.Milestone_Name__c.subString(2); 
                        if(d.Milestone_Name__c.containsIgnoreCase('Debit Note for Receipt Rejection'))   
                            name = d.Milestone_Name__c;
                    } else if(d.Debit_Type__c != '' && d.Debit_Type__c != null && String.isNotBlank(d.Milestone_Name__c))
                        name = d.Milestone_Name__c;                                                    
                    if(String.isNotBlank(d.Demand_Status__c) && d.Demand_Status__c == 'Reversed')
                        name += ' <b>-- CANCELLED</b>';                    
                    if(d.Name != '' & d.Name != null)
                        detail = 'Invoice No: ' + d.Name;
                    if(d.Invoice_Date__c != null)    
                        detail += '<br/> Invoice Date: ' + d.Invoice_Date__c.Format();
                    if(d.Due_Date__c != null)
                        detail += '<br/> Due Date: ' + d.Due_Date__c.Format();                   
                    if(d.Debit_Type__c != null && d.Debit_Type__c != '')
                        paidFor = d.Debit_Type__c;
                    else if (d.Debit_Type__c == '' || d.Debit_Type__c == null)
                        paidFor = 'Flat Cost with Tax';
                    wrap.add(new wrapperClass(d.GL_Date__c, name, detail, paidFor, amount, ''));                
                 } 
             }
             if(!receiptList.isEmpty()){
            
                 for(Receipt__c r: receiptList){ 
                    String name = '';
                    String detail = '';
                    if(r.Amount_Rs__c != null){
                        creditAmount += r.Amount_Rs__c;  
                        If(r.Registration_Collection_Control_Report__c != null){
                        amount = InFormat(r.Amount_Rs__c - r.Registration_Collection_Control_Report__c); //Added by Priya on 17 April 2020
                        totalRegistrationamountreceipt += r.Registration_Collection_Control_Report__c;
                        }
                        system.debug('totalRegistrationamountreceipt ::'+totalRegistrationamountreceipt );
                    }               
                    if(r.Mode__c != null && r.Mode__c == 'Credit Note' && r.Demand__c != null && String.isNotBlank(r.Description__c) && r.Description__c.containsIgnoreCase('Credit Note for Demand Rejection'))                         
                        name =  r.Description__c;
                    else if(r.Mode__c != null && r.Mode__c == 'Credit Note' && r.Demand__c == null)
                        name = 'Credit Note'; 
                    else if((r.Mode__c != null && r.Mode__c != 'Credit Note') || r.Mode__c == null || r.Mode__c == '')
                        name =  'Payment received';  
                    if(String.isNotBlank(r.Description__c) && r.Description__c.containsIgnoreCase('Reversed from Actions'))
                        name += ' <b>-- CANCELLED</b>';                                          
                    if(r.Mode__c != null && r.Mode__c != '')
                        detail = 'Type: ' + r.Mode__c;
                    if(r.Cheque_DD_Date__c != null)
                        detail += '<br/> Date: ' + r.Cheque_DD_Date__c.Format();
                    if(r.Cheque_DD__c != null && r.Cheque_DD__c != '')
                        detail += '<br/> Instrument No.: ' + r.Cheque_DD__c;
                    if(r.DraweeBank__c != null && r.DraweeBank__c!= '')    
                        detail += '<br/> Bank: ' + r.DraweeBank__c;
                    if(r.Currency__c != null && r.Currency__c != '')
                        detail += '<br/> Currency: ' + r.Currency__c;
                    if(r.Amount_Rs__c != null) 
                        detail += '<br/> Amount: ' + InFormat(r.Amount_Rs__c);
                    if(r.Receipt_Number__c != null && r.Receipt_Number__c  != '')                         
                        detail += '<br/> Receipt No.: ' + r.Receipt_Number__c;
                    if(r.Receipt_Status__c != null && r.Receipt_Status__c != '') 
                        detail += '<br/> Status: ' + r.Receipt_Status__c;                  
                    If(r.GL_Date__c != Null){
                        dateprint= r.GL_Date__c;
                     }else{
                        dateprint= r.Createddate.Date();               
                    }
                  
                   wrap.add(new wrapperClass(dateprint, name, detail, 'Flat Cost with Tax', '', amount));
                 
                 }
             }
             debitAmountString = INFormat(debitAmount);
             creditAmountString = INFormat(creditAmount);
             if(totalRegistrationamountdemand != null && totalRegistrationamountreceipt != null){
             totalRegistrationamount = totalRegistrationamountdemand + totalRegistrationamountreceipt;
             }
             totalRegistrationamountString = INFormat(totalRegistrationamount);
             if(debitAmount > creditAmount){
                 debitBalanceString = INFormat(debitAmount - creditAmount);
                 creditBalanceString = '';
             } else if(creditAmount > debitAmount){
                 creditBalanceString = INFormat(creditAmount - debitAmount);
                 debitBalanceString = '';
             }                  
             wrap.sort();  
         }                
        }
        
        public class wrapperClass implements Comparable {
            public Date postingDate{get;set;}
            public String milestoneName{get;set;}
            public String detail {get;set;}
            public String chargeName{get;set;}
            public String debit{get;set;}
            public String credit{get;set;}     
            
            public wrapperClass(Date psDate, String msName, String detail, String chName, String debit, String credit){
                this.postingDate = psDate;
                this.detail = detail;
                this.milestonename = msName;
                this.chargeName = chName;
                this.debit = debit;
                this.credit = credit;
            }  
            
           public Integer compareTo(Object ObjToCompare) {
                wrapperClass wrapper = (wrapperClass)(ObjToCompare);
                return sortByDate(wrapper);
            }
            private Integer sortByDate(wrapperClass wrapper) {
                if (this.postingDate > wrapper.postingDate) {
                    return 1;
                }
                if (this.postingDate == wrapper.postingDate) {
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
            mf = mf /*+ '/-'*/;
        else
            mf = '- ' + mf /* + '/-'*/;
        return mf;
    }       
}