Public Class CreateDebitNote{

    Public Demand__c d{get;set;}
    public List<Opportunity> oppList {get;set;}
    public Boolean processComplete {get;set;}
    public Boolean bookingNotConfirm {get;set;}
    public Boolean unitError {get;set;}
    public string applicantNames {get;set;}
    public List<Account_Master__c> accList; //// Added by Neha on 12/6/19
    public List<String> accNameList {get;set;} //// Added by Neha on 12/6/19
    public String accName {get;set;} //// Added by Neha on 12/6/19
    Map<String, Id> accMasterMap; //// Added by Neha on 12/6/19
    Map<String, Id> accMasterMapForTaxRate; //// Added by Neha on 12/6/19
    public Id OppId;

    public CreateDebitNote(){
        
        d = new Demand__c();        
        accList = new List<Account_Master__c>(); //// Added by Neha on 12/6/19
        accNameList = new List<String>(); //// Added by Neha on 12/6/19
        accMasterMap = new Map<String, Id>(); //// Added by Neha on 12/6/19
        accMasterMapForTaxRate = new Map<String, Id>();  //// Added by Neha on 12/6/19       
        oppList = new List<Opportunity>();
        processComplete = false;
        applicantNames = '';
        unitError = false;  
        d.Payment_Towards__c = 'Corporate Account';
   
  ////// Added by Neha on 26/6/19      
        if(ApexPages.currentPage().getParameters().get('OptyId') != null && ApexPages.currentPage().getParameters().get('OptyId') != '')
            OppId = ApexPages.currentPage().getParameters().get('OptyId');
       
        if(OppId != null){  
           Opportunity o = [SELECT Id, Project__c, Unit__c,Booking__c,Booking__r.Status__c,Booking__r.Unit__c,Booking__r.Project__c FROM Opportunity WHERE Id = :OppId];
           
           if(o.Booking__r?.Status__c == 'Cancelled'){
            d.Project__c = o.Booking__r?.Project__c;
            d.Unit__c = o.Booking__r?.Unit__c;
           }else{
            d.Project__c = o.Project__c;
            d.Unit__c = o.Unit__c; 
           }
           
           
           unitSelectionValidation();
        }   
   //// Added by Neha on 12/6/19      
        accList = [SELECT Name, Id, Type__c, Tax_Rate__c FROM Account_Master__c]; 
        if(accList != null){
            for(Account_Master__c a: accList){
                if(a.Type__c == 'Others'){
                    accNameList.add(a.Name);
                    accMasterMap.put(a.Name, a.Id);
                } else if(a.Type__c == 'VAT')
                    accMasterMapForTaxRate.put(a.Tax_Rate__c, a.Id);                   
            }
        }     
    }
    
    public void unitSelectionValidation() {
        System.debug('sfDebug demand d - '+d);
        unitError = false;
        bookingNotConfirm = false;                
        getCustomerDetails();
        if(unitError) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is an issue with customer association for this unit, can\'t proceed with Debit Note processing'));
        } else if(bookingNotConfirm) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Booking is yet to be processed.'));
        } else if (!unitError) {
                          
        }
    }
    
    public void getCustomerDetails() {
        oppList = new List<Opportunity>();
        applicantNames = '';       
       
       if(d.Unit__c != null){ 
           oppList = [Select Name, Id, StageName,Primary_Name__c,Other_Applicants_Name__c, 
                Future_Correspondence_Contact__c,Future_Correspondence_Contact_Name__c, Email__c, 
                Future_Correspondence_Contact_Email__c, Primary_Email__c, Other_Applicants_Email__c,
                Total_Interest_Settled__c,S_Active__c,Booking__r.Unit__c,Booking__r.Project__c,Booking__r.Status__c,
                Total_Waiver__c, Total_Interest_Waiver__c, Project__r.Cheque_Dishonour__c,
                Primary_pancard__c, Other_Applicants_Pancard__c
                from Opportunity where Project__c = :d.Project__c and ((Unit__c = :d.Unit__c AND S_Active__c = true) OR (Booking__r.Unit__c = :d.Unit__c AND Booking__r.Status__c = 'Cancelled')) AND Id = :OppId
                ];
        }
        System.debug('sfDebug retreived Opportunities - ' + oppList);
        
        if(!oppList.isEmpty() && oppList.size() == 1) {
            if(String.isNotBlank(oppList[0].Primary_Name__c)) 
                applicantNames = oppList[0].Primary_Name__c;
            if(String.isNotBlank(oppList[0].Other_Applicants_Name__c) && string.IsnotBlank(applicantNames))
                applicantNames += ',' + oppList[0].Other_Applicants_Name__c;
            else if(String.isNotBlank(oppList[0].Other_Applicants_Name__c))
                applicantNames = oppList[0].Other_Applicants_Name__c;
        }
        if(!oppList.isEmpty() && oppList.size() == 1 && !oppList[0].stageName.equalsIgnoreCase('Booking Confirmed')) {
            bookingNotConfirm = true;
        } else if(oppList.size() != 1 ){
            unitError = true;
        } 
        if(oppList != null && !oppList.isEmpty() && oppList.size() == 1) {
            List<Booking__c> bookList = [Select Id, OwnerId,Quotation__c from Booking__C where opportunity__c = : oppList[0].Id];
            if(bookList != null && !bookList.isEmpty() && bookList.size() == 1) {
                d.Booking__c = bookList[0].Id;
                d.Quotation__c = bookList[0].Quotation__c;
            }
        }        
    }
    
    public PageReference saveDebitNote() {
          Account_Master__c a;
          if(d.Debit_Demanded__c == 0){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Amount'));
               return null;
          }
          if(String.isNotBlank(accName) && accName != null){
              try{
                  a = [SELECT Id FROM Account_Master__c WHERE Name = :accName];
              } catch(Exception e){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select valid Credit Account'));
                   return null;        
              }
          }
          Tax_Slab__c ts = new Tax_Slab__c();
          if(d.Tax_Rate__c != null && String.isNotBlank(d.Tax_Rate__c))
              ts = [select id, name,Tax_Name__c,Tax1_Name__c,Tax1_Code__c,Tax1_Percentage__c,Taxable1_Percentage__c,Tax1_Percentage_on_100__c,Charge_Type__c,Tax2_Name__c,
                    Tax2_Code__c, Tax2_Percentage__c, Taxable2_Percentage__c, Tax2_Percentage_on_100__c from Tax_Slab__c where Tax_Rate__c = :d.Tax_Rate__c LIMIT 1];
          if(d.Payment_Term__c != null){
              if(d.Payment_Term__c == 'Immediate')
                  d.Due_Date__c = System.Today(); 
              else if (d.Payment_Term__c == '10')   
                   d.Due_Date__c = System.Today().addDays(10);
              else if (d.Payment_Term__c == '20')   
                   d.Due_Date__c = System.Today().addDays(20);
              else if (d.Payment_Term__c == '30')   
                   d.Due_Date__c = System.Today().addDays(30);     
          }                
          if(ts.Tax1_Percentage_on_100__c != null && d.Debit_Demanded__c != null)
              d.debit_sgst__c = (d.Debit_Demanded__c*ts.Tax1_Percentage_on_100__c/100);
          if(ts.Tax2_Percentage_on_100__c != null && d.Debit_Demanded__c != null)
              d.debit_cgst__c = (d.Debit_Demanded__c*ts.Tax2_Percentage_on_100__c/100);   
          if(!accMasterMap.isEmpty()){            
                for(String s: accMasterMap.keySet()){
                    if(s.equalsIgnoreCase('Trade Receivable'))
                        d.Total_Amount_with_Tax_Account__c = accMasterMap.get(s);                   
                }
          } 
          if(d.Tax_Rate__c != null){
            if(!accMasterMapForTaxRate.isEmpty()){
                for(String s: accMasterMapForTaxRate.keySet()){
                    if(accMasterMapForTaxRate.containsKey(d.Tax_Rate__c))
                        d.Total_Tax_Account__c = accMasterMapForTaxRate.get(d.Tax_Rate__c);
                } 
            }                              
          }  
      //    if(String.isNotBlank(accName) && accName != null){
           //   Account_Master__c a = [SELECT Id FROM Account_Master__c WHERE Name = :accName];
              if(a.Id != null)
                  d.Total_Amount_Account__c = a.Id;          
         // } 
          if(d.Unit__c != null){
              Unit__c u = [SELECT Tower__c FROM Unit__c where Id = :d.Unit__c];
              if(u.Tower__c != null){
                  Tower__c t = [SELECT Business_Unit__c, Business_Unit_Code__c FROM Tower__c WHERE Id = :u.Tower__c];
                  d.Business_Unit__c = t.Business_Unit__c;
                  d.Business_Unit_Code__c = t.Business_Unit_Code__c;
              }         
          } 
          d.GL_Date__c = System.Today(); // date demand is raised 
          d.Milestone_Name__c = 'Debit Note for ' + d.Debit_Type__c;
          insert d;          
          processComplete = true;
          return new PageReference('/lightning/r/Demand__c/'+d.Id+'/view');
         // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Debit Note created successfully.'));
    }
}