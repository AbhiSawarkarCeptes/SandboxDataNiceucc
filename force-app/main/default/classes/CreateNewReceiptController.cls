public without sharing class CreateNewReceiptController{
    public rMainWrapper rmw {get; set;}
    public  string instrumentType {get;set;}
    public List < SelectOption > entityOptions {get;set;}
    public transient String entitySelected {get;set;}
    public List<Opportunity> oppList {get;set;}
    public Boolean onlyToken {get;set;}
    public Boolean unitError {get;set;}
    public Boolean processComplete {get;set;}
    public Boolean debug {get;set;}    
    public Boolean error {get;set;}
    public Boolean Optyerror {get;set;}
    public Boolean receiptSaved {get;set;}
    public Id rmId {get;set;}
    public List<Receipt__c> recList{get;set;}
    public List<Receipt__c> last3MonthRecList{get;set;}
    public Boolean isDupe{get;set;}
    public transient string applicantNames {get;set;}
    public Id OppId;
    List<Account_Master__c> am; // Added by Neha on 17/6/19
    public List<String> accNameList {get;set;}  // Added by Neha on 17/6/19 for Credit Note
    public transient String accName {get;set;} // Added by Neha on 17/6/19 for Credit Note
    Map<String, Id> accMasterMap; // Added by Neha on 17/6/19 for Credit Note
    Map<String, Id> accMasterMapForTaxRate; 
    public transient String Isoppty{get;set;}
    
    public CreateNewReceiptController () {
        rmw = new rMainWrapper();
        am = new List<Account_Master__c>(); // Added by Neha on 17/6/19
        accNameList = new List<String>(); // Added by Neha on 17/6/19 for Credit Note
        accName = ''; // Added by Neha on 17/6/19 for Credit Note
        accMasterMap = new Map<String, Id>(); // Added by Neha on 17/6/19 for Credit Note
        accMasterMapForTaxRate = new Map<String, Id>();  
        onlyToken = false;
        unitError = false;
        processComplete = false;
        isDupe = false;
        error = false;
        Optyerror = false;
        applicantNames ='';
        debug=false;
        receiptSaved = false;
        rmId = null;       
        recList = new List<Receipt__c>();
        last3MonthRecList = new List<Receipt__c>();
        Isoppty = ''; 
        
        if(ApexPages.currentPage().getParameters().get('OptyId') != null && ApexPages.currentPage().getParameters().get('OptyId') != '')
            OppId = ApexPages.currentPage().getParameters().get('OptyId');
        Isoppty = ApexPages.currentPage().getParameters().get('Isoppty');   //Added by Priya on 15 April 2020
        
        if(OppId != null){  
            Opportunity o = [SELECT Id, Project__c, Booking__c, stageName, Unit__c FROM Opportunity WHERE Id = :OppId];
            rmw.r.Project__c = o.Project__c;
            rmw.r.Project_Unit__c = o.Unit__c;
            
            if(Isoppty == 'true' && o.Booking__c != Null){
                Optyerror = True;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please create receipt on the booking of opportunity'));               
            }
            
            if(Optyerror == false){           
                unitSelectionValidation();}
            
        }
        
        /// Added by Neha on 12/6/19      
        am = [SELECT Name, Id, Type__c, Tax_Rate__c FROM Account_Master__c]; 
        if(am != null){
            for(Account_Master__c a: am){
                if(a.Type__c == 'Others'){
                    accMasterMap.put(a.Name, a.Id);
                    accNameList.add(a.Name);
                    system.debug('accNameList::: ' + accNameList);
                }  else if(a.Type__c == 'VAT')
                    accMasterMapForTaxRate.put(a.Tax_Rate__c, a.Id);                   
            }                         
        }                
    }
    
    public void selectInstrument() {
        if(rmw.r.mode__c.equalsIgnoreCase('Cheque') || rmw.r.mode__c.equalsIgnoreCase('Wire Transfer') || rmw.r.mode__c.equalsIgnoreCase('Website') || rmw.r.mode__c.equalsIgnoreCase('Credit Card')) {
            instrumentType = 'ins1';
        } else if (rmw.r.mode__c.equalsIgnoreCase('Cash')) {
            instrumentType = 'ins2';
        } else if (rmw.r.mode__c.equalsIgnoreCase('Credit Note')) {
            instrumentType = 'ins3';
        } else {
            instrumentType = 'error';
        }
        rmw.r.Receipt_Date__c = system.today();
    }
    
    public void  getEntityDetails() {
        entityOptions = new List<SelectOption>();
        List<unit__c> uList = [select id,name,Tower__c from unit__c where id =: rmw.r.Project_Unit__c];
        Legal_Entity__c le = InventoryCostServices.getLegalEntityDetails(rmw.r.Project_Unit__c, rmw.r.Project__c, uList[0].Tower__c);
        entityOptions.add(new SelectOption('','--None--'));
        if(le != null && le.Account_Name_Flat_Cost__c != null) {
            entityOptions.add(new SelectOption('Flat Cost |' +  le.Account_Name_Flat_Cost__c +'|'+ le.Bank_Name_Flat_Cost__c + '|' /*+ le.Account_Number_Flat_Cost__c*/,'Flat Cost |' + le.Account_Name_Flat_Cost__c + '|' + le.Bank_Name_Flat_Cost__c + '|' /*+ le.Account_Number_Flat_Cost__c*/));
        }
        if(le != null && le.Account_Name_Service_Tax__c != null) {
            entityOptions.add(new SelectOption('Service Tax |' + le.Account_Name_Service_Tax__c + '|' + le.Bank_Name_Service_tax__c + '|' + le.Account_Number_Service_tax__c,'Service Tax |' + le.Account_Name_Service_Tax__c + '|' + le.Bank_Name_Service_tax__c + '|' + le.Account_Number_Service_tax__c));
        }
        if(le != null && le.Account_Name_Other_Charges__c != null) {
            entityOptions.add(new SelectOption('Other Charges |' + le.Account_Name_Other_Charges__c + '|' + le.Bank_Name_Other_Charges__c + '|' + le.Account_Number_Other_Charges__c,'Other Charges |' + le.Account_Name_Other_Charges__c + '|' + le.Bank_Name_Other_Charges__c + '|' + le.Account_Number_Other_Charges__c));
        }
        if(le != null && le.Account_Name_Other_Charges_Tax__c != null) {
            entityOptions.add(new SelectOption('Other Charges Service Tax |' + le.Account_Name_Other_Charges_Tax__c + '|' + le.Bank_Name_Other_Charges_Tax__c + '|' + le.Account_Number_Other_Charges_Tax__c,'Other Charges Service Tax |' + le.Account_Name_Other_Charges_Tax__c + '|' + le.Bank_Name_Other_Charges_Tax__c + '|' + le.Account_Number_Other_Charges_Tax__c));
        }
    }
    
    public void getCustomerDetails() {
        If(Isoppty != 'true'){
            oppList = [Select Name, Id, StageName, Primary_Name__c, Other_Applicants_Name__c, 
                       Email__c, Future_Correspondence_Contact_Email__c, Primary_Email__c, Other_Applicants_Email__c                                                             
                       from Opportunity where Project__c = : rmw.r.Project__c and Unit__c =: rmw.r.Project_Unit__c and Status__c ='Active' LIMIT 10];       
            if(oppList.size() == 1) {
                if(String.isNotBlank(oppList[0].Primary_Name__c)) 
                    applicantNames = oppList[0].Primary_Name__c;
                if(String.isNotBlank(oppList[0].Other_Applicants_Name__c) && string.IsnotBlank(applicantNames))
                    applicantNames += ', ' + oppList[0].Other_Applicants_Name__c;
                else if(String.isNotBlank(oppList[0].Other_Applicants_Name__c))
                    applicantNames = oppList[0].Other_Applicants_Name__c;
            }
            if(oppList.size() == 1 && !oppList[0].stageName.equalsIgnoreCase('Booking Confirmed')) {
                onlyToken = true;
                rmw.r.Token_Amount_Receipt__c = true;
            } else if(oppList.size() != 1){
                unitError = true;
            } 
            if(oppList != null && oppList.size() == 1) {
                List<Booking__c> bookList = [Select Id, OwnerId from Booking__c where opportunity__c = :oppList[0].Id or Opportunity__c = :oppList[0].Id];
                if( bookList != null && bookList.size() == 1) {
                    rmId = bookList[0].ownerId;
                    rmw.r.Booking__c = bookList[0].Id;
                }
            }  
        }else{            
            oppList = [Select Name, Id, StageName, Primary_Name__c, Other_Applicants_Name__c, 
                       Email__c, Future_Correspondence_Contact_Email__c, Primary_Email__c, Other_Applicants_Email__c                                                             
                       from Opportunity where Id = : OppId ];       
            if(oppList.size() == 1) {
                
                if(String.isNotBlank(oppList[0].Name)) 
                    applicantNames = oppList[0].Name;
                if(String.isNotBlank(oppList[0].Other_Applicants_Name__c) && string.IsnotBlank(applicantNames))
                    applicantNames += ', ' + oppList[0].Other_Applicants_Name__c;
                else if(String.isNotBlank(oppList[0].Other_Applicants_Name__c))
                    applicantNames = oppList[0].Other_Applicants_Name__c;
            }
            
            if(oppList.size() == 1 && !oppList[0].stageName.equalsIgnoreCase('Booking Confirmed')) {
                onlyToken = true;
                rmw.r.Token_Amount_Receipt__c = true;
            } else if(oppList.size() != 1){
                unitError = true;
            } 
            
            system.debug('oppList  '+oppList );
            if(oppList != null && oppList.size() == 1) {
                List<Booking__c> bookList = [Select Id, Name, OwnerId, Opportunity__c, Opportunity__r.Name from Booking__c where Opportunity__r.Name = : 'Dummy Opp for Booking'];
                system.debug('bookList '+bookList );
                if( bookList != null && bookList.size() == 1) {
                    rmId = bookList[0].ownerId;
                    rmw.r.Booking__c = bookList[0].Id;
                }
            }        
            
        } 
    }
    
    public void unitSelectionValidation() {
        unitError = false;
        onlyToken = false;
        rmw.r.Token_Amount_Receipt__c = false;
        error = false;
        
        getCustomerDetails();
        
        if(unitError) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is an issue with customer association for this unit, can\'t proceed with receipt processing'));
        } else if(onlyToken) {
            rmw.r.Opportunity__c = oppList[0].Id;
            If(Isoppty != 'true'){
                getEntityDetails();}
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Booking is yet to be processed. The money will be put on Account till then'));
        } else if (!unitError) {
            rmw.r.Opportunity__c = oppList[0].Id;
            rmw.r.Adjustment_Customer__c = oppList[0].Id;
            If(Isoppty != 'true'){
                getEntityDetails();}
        }
        
    }
    
    public PageReference applyReceipt() {  
        system.debug('Amount'+rmw.r.Amount_Rs__c);
        boolean isError = false;
        Account_Master__c a = new Account_Master__c();
        if(rmw.r.DraweeBank__c == 'Other' && rmw.r.Mode__c != 'Cash'){ // Mode added by Neha on 15/2/19
            if(rmw.r.Drawee_Bank_If_Others__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Drawee Bank(If Others)'));
                isError = true;
                return null;
            }             
        }  
        ///// Validation changed by Neha on 30/5/19 as Post dated cheques are allowed   
        if(rmw.r.mode__c.equalsIgnoreCase('Cheque')) {
            if(rmw.r.Cheque_DD_Date__c < system.today().addDays(-90)) { // || rmw.r.Cheque_DD_Date__c > system.today().addDays(1) // Changed by Neha on 30/5/19
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Instrument date has to be between 90 days ago from today to ahead of today'));
                error = true;
                return null;
            }
        } 
        if(rmw.r.mode__c.equalsIgnoreCase('Credit Card') || rmw.r.mode__c.equalsIgnoreCase('Credit Note')) {
            if(rmw.r.Cheque_DD_Date__c > system.today()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Instrument date cannot be a future date'));
                error = true;
                return null;
            }
        } 
        if(rmw.r.Mode__c == 'Credit Note' && accName != null && accName != ''){
            try{
                a = [SELECT Id FROM Account_Master__c WHERE Name = :accName];
            } catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a valid Debit Account'));
                error = true;
                return null;    
            }
        }        
        
        //// In case of Cash, Cheque, Website, Wire Transfer, Credit Card: GL date and Debit Account will be manually selected by finance team
        //// on Finance Dashboard. But in case of Credit Note, we have to give these 2 options on this page.         
        if(isError == false){     
            error = false; 
            Id rId;
            Receipt__c rt = new Receipt__c();
            rt = rmw.r;
            if(rt.Mode__c != 'Credit Note')
                rt.Receipt_Status__c = 'UnProcessed';
            if(rt.Mode__c == 'Credit Note'){
                rt.Receipt_Status__c = 'Cleared';
                rt.Physically_Cheque_Received__c = true;
                rt.Banking__c = 'Payment Successful';
                rt.Reason_for_rejection_new__c = 'Accepted';
            }                   
            else{
                system.debug('amount'+rmw.r.Amount_Rs__c);
                rt.On_Account_Money__c = rmw.r.Amount_Rs__c;
                
            }            
            if(rt.Mode__c != 'Credit Note')
                rt.Drawn_In_Favour_Of__c =  entitySelected;                        
            if (oppList[0].Primary_Email__c != null && oppList[0].Primary_Email__c != '' && String.isBlank(rt.Opportunity_Email_Id__c))
                rt.Opportunity_Email_Id__c = oppList[0].Primary_Email__c;
            
            ///// Added by Neha on 12/6/19 to tag credit account on Receipt
            if(!accMasterMap.isEmpty()){                
                for(String s: accMasterMap.keySet()){
                    if(s.equalsIgnoreCase('Trade Receivable'))
                        rt.Credit_Account__c = accMasterMap.get(s);
                }                
            } 
            ///// Added by Neha on 17/6/19 to tag debit account selected manually on credit note 
            if(rt.Mode__c == 'Credit Note' && a.Id != null)
                rt.Debit_Account__c = a.Id;                
            
            if(rt.Mode__c == 'Credit Note' && rt.Credit_Note_Amount__c != null && rt.Tax_Rate__c != null){                                           
                if(!accMasterMapForTaxRate.isEmpty()){
                    for(String s: accMasterMapForTaxRate.keySet()){
                        if(accMasterMapForTaxRate.containsKey(rt.Tax_Rate__c))
                            rt.Tax_Debit_Account__c = accMasterMapForTaxRate.get(rt.Tax_Rate__c);
                    } 
                } 
                Tax_Slab__c ts = new Tax_Slab__c(); 
                ts = [SELECT Id, Name, Tax1_Percentage_on_100__c, Tax2_Percentage_on_100__c
                      FROM Tax_Slab__c WHERE Tax_Rate__c = :rt.Tax_Rate__c]; 
                if(ts != null)                         
                    rt.Tax_Amount__c = (rt.Credit_Note_Amount__c*ts.Tax1_Percentage_on_100__c/100) + (rt.Credit_Note_Amount__c*ts.Tax2_Percentage_on_100__c/100); 
                rt.Amount_Rs__c = rt.Credit_Note_Amount__c + rt.Tax_Amount__c;                                                                                      
            }
            //// Added by Neha on 12/6/19
            if(rmw.r.Project_Unit__c != null){                
                Unit__c u = [SELECT Tower__r.Business_Unit__c, Tower__r.Business_Unit_Code__c FROM Unit__c where Id = :rmw.r.Project_Unit__c];
                rt.Business_Unit__c = u.Tower__r.Business_Unit__c;
                rt.Business_Unit_Code__c = u.Tower__r.Business_Unit_Code__c;
            }
            if(rt.Currency__c != null && rt.Currency__c != 'AED'){
                rt.Amount_in_Foreign_Currency__c = rt.Amount_Rs__c;
                rt.Foreign_Currency_Type__c = rt.Currency__c;
            }
            rt.Total_Amount__c = rt.Amount_Rs__c;
            try { 
            system.debug('rt.booking'+rt.booking__c);
            system.debug('rt value'+rt); 
                Database.SaveResult r = Database.insert(rt);
                if(r.isSuccess()){
                    rId = r.getId();
                    PageReference newpage = new Pagereference('/lightning/r/Receipt__c/' + rId + '/view'); // Added by Neha on 15/2/19
                    return newpage;
                }    
            } catch (Exception e) {
                ApexPages.addMessages(e);
                return null;
            }
            if(!onlyToken) {
                processComplete = true;
            }
            receiptSaved = true;
        }  
        return null;
    }
    
    //////////--------------------------- Below method Added by vikas for check duplicate receipt -----------------////////////
    public pageReference checkDupeList() {
        boolean error = false;     
        
        if(recList.size() > 0){
            isDupe = false;      
            recList.clear();
        }
        last3MonthRecList = [select id, name, Cheque_DD_Date__c, DraweeBank__c, Description__c, Drawee_Bank_If_Others__c, Cheque_DD__c, Drawn_in_favour_of__c, Currency__c, Amount_Rs__c, Receipt_Status__c, 
                             TDS_Amount_In_Rs__c, IsTDS_And_NoDemandRaised__c, RemarksText__c 
                             from Receipt__c where Receipt_Date__c = LAST_90_DAYS and DraweeBank__c = :rmw.r.DraweeBank__c and Cheque_DD__c = :rmw.r.Cheque_DD__c];
        
        if(last3MonthRecList.size() > 0) {                   
            if(rmw.r.DraweeBank__c == 'Other'){
                if(rmw.r.Drawee_Bank_If_Others__c == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Drawee Bank(If Others)'));
                    error = true;
                }
                else{
                    for(Receipt__c rec : last3MonthRecList){
                        if(rec.Drawee_Bank_If_Others__c == rmw.r.Drawee_Bank_If_Others__c && rec.Cheque_DD__c == rmw.r.Cheque_DD__c)
                            recList.add(rec);
                    }
                }
            }    
            else{         
                for(Receipt__c rec : last3MonthRecList){
                    recList.add(rec);
                }            
            }     
        }          
        if(recList.size() > 0){
            isDupe = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,recList.size()+' Duplicate Receipts Found'));
        }
        if(recList.size() == 0 && error == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Duplicate Receipts Found'));
        }            
        return null;
    }
    //////////////////// ----------------------- vikas added method end here ----------------------------//////////////////////////
    
    public class rMainWrapper{
        public Receipt__c r {get;set;}
        
        public rMainWrapper() {
            this.r = new Receipt__c();
        }
    }
}