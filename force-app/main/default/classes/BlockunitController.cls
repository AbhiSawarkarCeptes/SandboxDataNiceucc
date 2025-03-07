public with sharing class BlockunitController {

    public Block_Unit__c bu{
        get;
        set;
    }   
    public string uid {
        get;
        set;
    }    
    public string qid {
        get;
        set;
    }   
    public string optyid {
        get;
        set;
    }   
    public boolean isSaved {
        get;
        set;
    }
    public boolean isError {
        get;
        set;
    }
  /*  public Receipt__c receiptObj {
        get;
        set;
    }
    public Receipt__c ChequeObj {
        get;
        set;
    }
     public List < Receipt__c > ReceiptDetails {
        get;
        set;
    }
     public List < Receipt__c >receiptlist {
        get;
        set;
    }
    public List < Receipt__c >deletereceiptlist {
        get;
        set;
    }
    public Receipt__c reciept {
        get;
        set;
    }
    public Receipt__c del {
        get;
        set;
    }*/
    public Integer rowIndex 
    {
        get;
        set;
    }
    public List < Unit__c> unitlist 
    {
        get;
        set;
    }
    public List < Quotation__c> quotlist 
    {
        get;
        set;
    }       
    public Quotation__c quot 
    {
        get;
        set;
    }
       public List < Quotation__c> quoteDiscountlist
    {
        get;
        set;
    }     
    public List <Team_Members__c> SOTTeamMembers 
    {
        get;
        set;
    }    
    public List <Team_Members__c> COBTeamMembers 
    {
        get;
        set;
    }      
    public String selectedQuote 
    {
        get;
        set;
    }    
    public String TotalBaseValueBeforeDiscount  
    {
        get;
        set;
    }    
    public String DiscountApplied
    {
        get;
        set;
    }    
    public String BaseValueAfterDiscount
    {
        get;
        set;
    }    
    public List<Receipt__c> ReceiptLstTobeUpdate
    {
        get;set;
    }    
    public List<block_unit__c> BUList
    {
        get;set;
    }   
    public boolean isFalse;
    public List < Opportunity > opplist;
    public Legal_Entity__c le;    
    public String ProjectId{get;set;}
    public Id towerId {get;set;}
    
    public BlockunitController(){
    
        isSaved = false;
        isError = false;
        isFalse = false;
        bu = new Block_Unit__c();
        BUList = new List <Block_Unit__c>();
        unitlist = new List <Unit__c>();
       // quotlist = new List <Quotation__c>();
        rowIndex =0;
        selectedQuote = '';
        opplist = new List <Opportunity>();
        uid = '';
        qid = '';
        optyid = '';
        //receiptObj = new Receipt__c();
        //ChequeObj = new Receipt__c();
        //reciept=new Receipt__c ();
        //deletereceiptlist =new List < Receipt__c >();
        //receiptlist =new List < Receipt__c >();
        
        //SOTTeamMembers = new list<Team_Members__c>();
        //COBTeamMembers = new list<Team_Members__c>();
        //receiptlist.add(reciept);
        
        //ReceiptDetails = new List <Receipt__c>();
        
        //ReceiptLstTobeUpdate = new List<Receipt__c>();
        
        /*if(ApexPages.currentPage().getParameters().get('qid') != '' && ApexPages.currentPage().getParameters().get('qid') != null)
        {
            qid = ApexPages.currentPage().getParameters().get('qid');
            system.debug('qID::'+qid);
        }*/
        
        if(ApexPages.currentPage().getParameters().get('optyid') != '' && ApexPages.currentPage().getParameters().get('optyid') != null)
        {
            optyid = ApexPages.currentPage().getParameters().get('optyid');
            system.debug('OptyID::'+optyid);
        }
        
        if(ApexPages.currentPage().getParameters().get('unitid') != '' && ApexPages.currentPage().getParameters().get('unitid') != null)
        { 
            uid = ApexPages.currentPage().getParameters().get('unitid');
            system.debug('UnitID:: '+uid);
        }
        
        /*if(uid == null || uid == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Put Unit ID in URL.'));
            isError = True;
        }
        else{
            unitlist = [select id,Name,Unit_Status__c,Project__c from Unit__c where id =: uid];
            if(!unitlist.isEmpty() || unitlist.size() != 0){
                if(unitlist[0].Unit_Status__c == 'Available'){
                    bu.Unit__c = uid;
                }    
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select a unit in Available status.'));
                    isError = True;
                }        
            }    
        }*/
               
         if(optyid != '' && optyid != null){
          opplist = [Select Id, Name, Booking__c, Unit__c, Sales_Manager_lookup__c from Opportunity where Id =: optyId and booking__c =: null];  
          system.debug('oppList::: ' + oppList);
          if(opplist.size() > 0)
              {
                  system.debug('OptyList is not empty'+ oppList);
                  bu.Opportunity__c = opplist[0].Id;
                  System.debug('SM id:: ' + oppList[0].Sales_Manager_lookup__c);
                  if(oppList[0].Sales_Manager_lookup__c != null){
                      User u = [SELECT Email, Name FROM USER WHERE Id =:oppList[0].Sales_Manager_lookup__c];
                      System.debug('User u::: ' + u.Email);
                  if(u.Email != null && u.Email != '')
                      bu.Sales_Manager_Email_Id__c = u.Email;
              }
             }
          else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot block unit with this opportunity'));
                isError = True;               
          }  
        }
              
        if(opplist.size() > 0){
          //getquotation();
         // selectedQuote = qid;
         system.debug('Quote Id is not null');
             quotlist = [select id, Name, Quote_Status__c, Booking__c, Unit__c, Unit__r.Unit_Status__c, Opportunity__c, Active_Quotation__c, Level_One_Approver__c, Level_Two_Approver__c
                         from Quotation__c where Opportunity__c =: optyid and Booking__c =: null and Unit__r.Unit_Status__c =: 'Available' AND Active_Quotation__c = true AND  Quote_Status__c = : 'Valid'
                         ORDER BY CreatedDate DESC]; // LIMIT 1
         system.debug('quotlist::: ' +  quotlist);             
        } 
                
        if(uid != '' && uid != null)
        {
            unitlist = [Select Id, Name, Unit_Status__c,Project__c,Tower__c from Unit__c where Id =: uid and Unit_Status__c =: 'Available'];
            if(unitlist.size() > 0)
            {
                bu.Unit__c = unitlist[0].Id;
            }
            else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unit is not Available. You cannot proceed'));
                    isError = True;
          }
        }        
    }    
    
    //add receipt row
    /*public void addReciept()
    {
     
     Receipt__c rec=new Receipt__c();
     receiptlist.add(rec);
     system.debug('receiptlist inside method::::'+receiptlist);
     system.debug('receiptlist inside method size::::'+receiptlist.size());
      
    }*/
    
    //delete receipt row
    /*public void deleteReciept()
    {
       
      system.debug('receiptlist inside method size::::'+receiptlist.size());
      
      rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
      System.debug('row index be deleted ' + rowIndex );
      System.debug('rows to be deleted '+receiptlist[rowIndex]);
      del = receiptlist.remove(rowIndex);
      deletereceiptlist.add(del);
    }*/  
    
     //Create selectlist out of queryresult
    public List < SelectOption > getQuote {
        get {        
            //system.debug('Inside getQuote queryResult' +quotlist);
            //System.debug('Selected Quote::'+selectedQuote);
            List < SelectOption > optns = new List < Selectoption > ();
            optns.add(new SelectOption('', 'Select a Quotation'));
             if(quotlist.size() > 0 && quotlist != null || isError == false)
                {
                    for (Quotation__c obj: quotlist) {
                    optns.add(new SelectOption(obj.Id,obj.Name));                   
                    }                  
                } else {
                    system.debug('No quotations');                  
                }
           return optns;
        }
        set;
    }
    
    public PageReference Save(){        
      //   system.debug('IN SAVE METHOD Selected Quote'+selectedQuote);
         system.debug('IN SAVE METHOD OBJECT IS** '+ bu);
         isFalse = false;  
         isError = false;       
         Savepoint sp = Database.setSavepoint();   
        
         System.debug('selectedQuote::: ' + selectedQuote);
         if(selectedQuote != null && selectedQuote != ''){
             bu.Quotation__c = selectedQuote;                  
             isError = false; 
             System.debug('Quotation::: ' + bu.Quotation__c + ' & isError:: ' + isError); 
         } 
         if(bu.Date_and_Time_of_Unhold_Unit__c < System.Now()){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'You cannot select back Date or Time');
             ApexPages.addMessage(myMsg);
             isError = True;
             return null;         
         }        
               if(!isError){  
                 try{            
                     if(bu.Unit__c != null && bu.Opportunity__c != null)
                     {                     
                         bu.Date_and_Time_of_Hold_Unit__c = System.Now();
                         insert bu;
                         PageReference pgref = new PageReference('/'+bu.Id);
                         return pgref;
                     }
                     else
                     {
                         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'You cannot block the Unit');
                              ApexPages.addMessage(myMsg);
                              isError = True;
                              return null;
                     }                 
                  } catch(Exception ex){
                    Database.rollback(sp);            
                    System.debug('Catch the Exception::'+ex);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in Blocking the Unit.'));
                  }  
                 }         
      /*   else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Opportunity does not have Valid Quotation'));
                isError = True;
            }*/                 
        return null;
    } 
    
    public PageReference Cancel()
    {
        PageReference pgref = new PageReference('/'+bu.Opportunity__c);
        return pgref;
    }    
}