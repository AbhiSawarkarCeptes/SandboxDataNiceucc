public class N_CustomerSOAController{
        public String oppId;
        public String bookingId;
        public Opportunity Customer {get; set;}
        public Booking__c bookingRecord {get; set;}
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
        public String registrationamount{get;set;}
    
    public N_CustomerSOAController(){     
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
        wrap = new List<wrapperClass>();
        
         if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '')
             oppId = ApexPages.currentPage().getParameters().get('id');
             bookingId = ApexPages.currentPage().getParameters().get('bookingid');
         if(oppId != null && oppId != '') {   
             Customer = [SELECT id, Name,Other_Applicant_Mobile_Number__c, Primary_Email__c, Other_Applicants_Email__c, Primary_Name__c,Primary_Phone__c, Other_Applicants_Name__c,
                        Mailing_Address__c,Permanent_Address__c,Booking__r.Name, Booking__r.Unit__r.Unit_Status__c, Booking__r.Agreement_Value__c,
                        Project__r.name, Unit__r.Chargeable_Area__c, Booking__r.No_of_Earmarked_Parking__c, Booking__r.Unit__r.Tower__r.Name,             
                        Booking__r.Unit__r.Tower__r.Cluster__r.Name,  Booking__r.Unit__r.Legal_Entity__r.name,Unit__r.Booking__r.Registration_Amount_Paid__c,  
                        Booking__r.Unit__r.Name, Account.PersonMobilePhone,Unit__r.Project_Unit_Type__r.Name                                                                     
                        FROM Opportunity WHERE id = :oppId];  
            
            if(!Test.isRunningTest()){
                bookingRecord = [ SELECT Id,Name,Unit__r.Unit_Status__c,Agreement_Value__c,No_of_Earmarked_Parking__c,Unit__r.Tower__r.Name,Unit__r.Legal_Entity__r.name,Registration_Amount_Paid__c,(SELECT id,Registration_Collection_Control_Report__c,Is_Reversed_Receipt__c,Receipt_Status__c FROM Receipts__r WHERE Receipt_Status__c = 'Cleared' AND Is_Reversed_Receipt__c = false) FROM Booking__c WHERE Id =: bookingId ];
            }
                                          
            if(Customer.Booking__r.Agreement_Value__c != null)         
                agreementValue= INFormat(Customer.Booking__r.Agreement_Value__c); 
            
            if(Customer.Unit__r.Chargeable_Area__c != null)     
                area = INFormat(Customer.Unit__r.Chargeable_Area__c); 
             
           /*Removed to add Title Deeds in Registration amount
           if(bookingRecord.Registration_Amount_Paid__c != null){     
              registrationamount = INFormat(bookingRecord.Registration_Amount_Paid__c);
           }*/

           if(!Test.isRunningTest() && !bookingRecord.Receipts__r.isEmpty()){//Added to add Title Deeds in Registration amount
              registrationamount = INFormat(getRegistrationAmountFor(bookingRecord.Receipts__r));
           } 
 
                    
            towerClusterName = Customer.Booking__r.Unit__r.Tower__r.Cluster__r.Name + ' ' + Customer.Booking__r.Unit__r.Tower__r.Name;
                 
            demandList = [SELECT Id, Name, Total_Amount_Demanded__c, Demand_Status__c, Milestone_Name__c, GL_Date__c, Due_Date__c, Invoice_Date__c, Debit_Type__c, Payment_Milestones__c,
                          Total_Tax_Demanded__c,Installment__c  FROM Demand__c WHERE Debit_Type__c != 'DLD Charges' AND  
                          Other_Charges_Type__c NOT IN ('Title Deed Charges','Plot title Deed','Mortgage Fees','Title Deed Fees (Plots)','Title Deed Fees (Units)','Title Deed Fees (Villas)','Pre-registration to Pre-Title deed','Pre-registration to pre-title deed (completed projects)')  
                          AND Booking__r.Opportunity__c = :oppId 
                          ORDER BY GL_Date__c];
                         
            receiptList = [SELECT Id, Name, Project_Unit__r.Name, Mode__c, Cheque_DD_Date__c, GL_Date__c, Cheque_DD__c, DraweeBank__c,
                           Currency__c, Amount_Rs__c, Receipt_Number__c, Receipt_Status__c, Demand__c, Demand__r.Name, Description__c,Registration_Collection_Control_Report__c,Debit_Account__r.Name
                           FROM Receipt__c 
                           WHERE (Booking__r.Opportunity__c = :oppId AND Receipt_Status__c IN('Cleared') AND Mode__c !='Credit Note' ) or (Booking__r.Opportunity__c = :oppId AND Receipt_Status__c IN('Cleared')) ORDER BY GL_Date__c];
             
             if(!demandList.isEmpty()){
                 for(Demand__c d: demandList){ 
                     String name = '';
                     String detail = '';
                     String paidFor = '';
                    if(d.Total_Amount_Demanded__c != null && d.Total_Tax_Demanded__c != null) {
                        debitAmount += (d.Total_Amount_Demanded__c + d.Total_Tax_Demanded__c);  
                        amount = INFormat((Decimal)d.Total_Amount_Demanded__c + (Decimal)d.Total_Tax_Demanded__c);
                    }
                    if((d.Debit_Type__c == '' || d.Debit_Type__c == null)  && String.isNotBlank(d.Milestone_Name__c)){                                    
                        name = 'Demand for ' +  d.Installment__c+' / ' + d.Milestone_Name__c ;
                    if(d.Milestone_Name__c.containsIgnoreCase('On Completion'))
                            name = 'Demand for ' +  d.Milestone_Name__c.subString(2)+' / ' + d.Installment__c; 
                        if(d.Milestone_Name__c.containsIgnoreCase('Debit Note for Receipt Rejection'))   
                            name = d.Milestone_Name__c;
                    } else if(d.Debit_Type__c != '' && d.Debit_Type__c != null && String.isNotBlank(d.Milestone_Name__c))
                        name = d.Milestone_Name__c + (d.Installment__c != null ? (+' / ' + d.Installment__c) : '');
                        if(d.Debit_Type__c == 'Interest Charges' || d.Debit_Type__c == 'Cheque Bounce')
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
                    if(r.Amount_Rs__c != null ){
                        creditAmount += r.Amount_Rs__c- (r.Registration_Collection_Control_Report__c != null ? r.Registration_Collection_Control_Report__c : 0);  
                        amount = InFormat((Decimal)(r.Amount_Rs__c- (r.Registration_Collection_Control_Report__c != null ? r.Registration_Collection_Control_Report__c : 0)).setScale(3,RoundingMode.UNNECESSARY));
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
                                  
                    wrap.add(new wrapperClass(r.GL_Date__c, name, detail, 'Flat Cost with Tax', '', amount));
                 }
             }
             debitAmountString = INFormat((Decimal)debitAmount);
            
             creditAmountString = INFormat((Decimal)creditAmount);
             
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
        String m0 = tempMoney.setscale(0,RoundingMode.HALF_EVEN).toPlainString();
        String decimalPart;
        List<String> tempStr = new List<String>();
       if(String.isNotBlank(m0)) {
             tempStr = m0.split('\\.');
          if(tempStr != null && tempStr.size() == 2) {
            decimalPart = tempStr[1];
       }
      }
       String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_EVEN))).reverse();
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

   private static Decimal getRegistrationAmountFor(List<Receipt__c> receipts){
        Decimal retVal = 0.0;
        for(Receipt__c r : receipts){
            if(r?.Registration_Collection_Control_Report__c != NULL) retVal += r.Registration_Collection_Control_Report__c;
        }
        return retVal;
   }
}