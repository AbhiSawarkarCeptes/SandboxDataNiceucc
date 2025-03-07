public with sharing class S_ReceiptDashboardClass {
    public string errorMsg {get;set;}
    public string infavourtoken1 {get;set;}
    public Transient List<Receipt__c> objR {get;set;}
    public Transient List<Receipt__c> dummyList {get;set;}
    public List<Applicant_Details__c> listApp {get;set;} 
    public List<Id> bookingids {get;set;} 
    public Transient List < wrapperclass> wrapperscppdList{get; set;}
    public Boolean showCloseBtn {get;set;}
    public PaginationController.PaginationWrapper pgw;
    public String searchByName {get; set;} ///// Added by Neha on 28/6/19
    public Boolean pagination {get;set;} ///// Added by Neha on 28/6/19
    public Boolean showLegacyReceipt {get;set;} /// Added by Neha on 31/12/19
    
    public class wrapperclass{
        public Transient String Amount1{ get; set; }
        public Transient String Amount2{ get; set; }
        public Transient Receipt__c ReceiptR {get;set;}
        
        public wrapperclass(Receipt__c s, Decimal d, Decimal d1){           
            ReceiptR = s;
            Amount1 = InventoryCostServices.INFormat(d);
            Amount1 = Amount1.replace('AED','');
            Amount1 = Amount1.replace('/-','');
            Amount2 = InventoryCostServices.INFormat(d1);           
        }
    }  
       
    public S_ReceiptDashboardClass(){
        errorMsg = '';
        infavourtoken1 ='';
        objR = new List<Receipt__c>();  
        showCloseBtn = false;    
        pgw = new PaginationController.PaginationWrapper();
        pgw.list_size = 20;  /// No of records to display on page
        pgw.counter = 0;
        pgw.created_date = '';
        dummyList = new List<Receipt__c>();
        searchByName = ''; ///// Added by Neha on 28/6/19
        pagination = true; ///// Added by Neha on 28/6/19
        showLegacyReceipt = false;
        
        if(ApexPages.currentPage().getParameters().containsKey('pageName')){
            if(ApexPages.currentPage().getParameters().get('pageName') != null){
                   showCloseBtn = true;
            }
        }
        showAllLegacyReceipts();
    }
    
    public PageReference clearResult(){
        searchByName = '';
        showAllLegacyReceipts();   
        return null;     
    }
    public void showAllLegacyReceipts(){
    system.debug('showLegacyReceipt::: ' + showLegacyReceipt);
        if(showLegacyReceipt){
            searchLegacyResult();        
        } else {
            searchResult();    
        }    
    }
    
    public PageReference searchResult(){
         if(searchByName != '' && searchByName != null){
             pagination = false;
             String search = '%' + searchByName  + '%'; 
             objR = [SELECT Id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c,              
                    Total_Amount__c, Project_Unit__r.Name, Receipt_Status__c, Mode__c, Booking__r.Stage_of_Booking__c, Business_Unit__c,
                    DraweeBank__c,Description__c, On_Account_Money_Autocalculated__c, Booking__r.Name, Is_Reversed_Receipt__c, Legacy_Data__c,
                    Currency__c, Project_Unit__r.Tower__r.Name From Receipt__c
                    WHERE On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared' AND Legacy_Data__c = false AND 
                    (Booking__r.Name Like :search OR Booking__r.Opportunity__r.Name Like :search OR Booking__r.Unit__r.Name Like :search OR Name Like :search)
                    ORDER BY Name DESC LIMIT 25];
              system.debug('search::: ' + pagination);
            
        }
         else {
             pagination = true;
             objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c, Cheque_DD_Date__c,                 
                Total_Amount__c, Project_Unit__r.Name, Receipt_Status__c, Mode__c, Booking__r.Stage_of_Booking__c, Business_Unit__c,
                DraweeBank__c, Description__c, On_Account_Money_Autocalculated__c, Booking__r.Name, Is_Reversed_Receipt__c, Legacy_Data__c,
                Currency__c, Project_Unit__r.Tower__r.Name From Receipt__c                  
                where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared' AND Legacy_Data__c = false               
                ORDER BY name DESC limit:pgw.list_size offset:pgw.counter]; 
            
        }
         dummyList = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c,                   
                      Total_Amount__c, Project_Unit__r.Name, Mode__c, Business_Unit__c, Project_Unit__r.Tower__r.Name, Booking__r.Stage_of_Booking__c,
                      DraweeBank__c,Description__c, On_Account_Money_Autocalculated__c, Booking__r.Name, Currency__c, Receipt_Status__c, Legacy_Data__c                    
                      From Receipt__c 
                      where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared' AND Legacy_Data__c = false
                      ORDER BY name DESC];       
           if(dummyList.size() > 0){
                pgw.total_size = dummyList.size();    
                pgw.last_date =  dummyList[dummyList.size() - 1].name;            
           }
           if(objR.size() > 0){
                pgw.created_date = objR[objR.size() - 1].name;
           }                            
         wrapperscppdList = new List<wrapperclass>();    
         for (integer i = 0 ; i < objR.size() ; i++){
             wrapperscppdList.add(new wrapperclass(objR[i], objR[i].Total_Amount__c, objR[i].On_Account_Money_Autocalculated__c));               
         } 
         return null;
    }
    
    public PageReference searchLegacyResult(){
         if(searchByName != '' && searchByName != null){
             pagination = false;
             String search = '%' + searchByName  + '%'; 
             objR = [SELECT Id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c,              
                    Total_Amount__c, Project_Unit__r.Name, Receipt_Status__c, Mode__c, Booking__r.Stage_of_Booking__c, Business_Unit__c,
                    DraweeBank__c,Description__c, On_Account_Money_Autocalculated__c, Booking__r.Name, Is_Reversed_Receipt__c, Legacy_Data__c,
                    Currency__c, Project_Unit__r.Tower__r.Name From Receipt__c
                    WHERE On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared' AND
                    (Booking__r.Name Like :search OR Booking__r.Opportunity__r.Name Like :search OR Booking__r.Unit__r.Name Like :search OR Name Like :search)
                    ORDER BY Name DESC LIMIT 25];
            
        }
         else {
             pagination = true;
             objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c, Cheque_DD_Date__c,                 
                Total_Amount__c, Project_Unit__r.Name, Receipt_Status__c, Mode__c, Booking__r.Stage_of_Booking__c, Business_Unit__c,
                DraweeBank__c, Description__c, On_Account_Money_Autocalculated__c, Booking__r.Name, Is_Reversed_Receipt__c, Legacy_Data__c,
                Currency__c, Project_Unit__r.Tower__r.Name From Receipt__c                  
                where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared'             
                ORDER BY name DESC limit:pgw.list_size offset:pgw.counter]; 
            
        }
         dummyList = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c,                   
                      Total_Amount__c, Project_Unit__r.Name, Mode__c, Business_Unit__c, Project_Unit__r.Tower__r.Name, Booking__r.Stage_of_Booking__c,
                      DraweeBank__c,Description__c, On_Account_Money_Autocalculated__c, Booking__r.Name, Currency__c, Receipt_Status__c, Legacy_Data__c                   
                      From Receipt__c 
                      where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared'                
                      ORDER BY name DESC];       
           if(dummyList.size() > 0){
                pgw.total_size = dummyList.size();    
                pgw.last_date =  dummyList[dummyList.size() - 1].name;            
           }
           if(objR.size() > 0){
                pgw.created_date = objR[objR.size() - 1].name;
           }                            
         wrapperscppdList = new List<wrapperclass>();    
         for (integer i = 0 ; i < objR.size() ; i++){
             wrapperscppdList.add(new wrapperclass(objR[i], objR[i].Total_Amount__c, objR[i].On_Account_Money_Autocalculated__c));               
         } 
         return null;
    }
    
    
    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons         
       return(PaginationController.DisablePrevious(pgw));
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
       return(PaginationController.DisableNext(pgw));
    }
    
     public PageReference Beginning() { //user clicked beginning
        pgw= PaginationController.Beginning(pgw);
        
        if(showLegacyReceipt) {      
        objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, DraweeBank__c,Description__c, Currency__c,
                Opportunity__r.Primary_Name__c,Cheque_DD_Date__c, Total_Amount__c, Project_Unit__r.Name, Project_Unit__c,               
                Receipt_Status__c, Mode__c, On_Account_Money_Autocalculated__c, Is_Reversed_Receipt__c, Business_Unit__c, Legacy_Data__c,
                Project_Unit__r.Tower__r.Name, Booking__r.Stage_of_Booking__c, Booking__r.Name From Receipt__c                               
                where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared'
                ORDER BY name DESC limit:pgw.list_size offset:pgw.counter];
        } else {
            objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, DraweeBank__c,Description__c, Currency__c,
                Opportunity__r.Primary_Name__c,Cheque_DD_Date__c, Total_Amount__c, Project_Unit__r.Name, Project_Unit__c,               
                Receipt_Status__c, Mode__c, On_Account_Money_Autocalculated__c, Is_Reversed_Receipt__c, Business_Unit__c, Legacy_Data__c,
                Project_Unit__r.Tower__r.Name, Booking__r.Stage_of_Booking__c, Booking__r.Name From Receipt__c                               
                where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared' AND Legacy_Data__c = false
                ORDER BY name DESC limit:pgw.list_size offset:pgw.counter];    
        }
         
         wrapperscppdList = new List<wrapperclass>();         
         if(objR.size() > 0){
            pgw.created_date = objR[objR.size() - 1].name;
         }
         
         for (integer i = 0 ; i < objR.size() ; i++){
             wrapperscppdList.add(new wrapperclass(objR[i], objR[i].Total_Amount__c, objR[i].On_Account_Money_Autocalculated__c));              
         }  
        return null;
     }   
     
     public PageReference Previous() { //user clicked previous button
       pgw = PaginationController.Previous(pgw);
       
       if(showLegacyReceipt) {      
       objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c, Is_Reversed_Receipt__c,               
               Total_Amount__c, Project_Unit__r.Name, Mode__c, Currency__c, DraweeBank__c,Description__c, Receipt_Status__c, Legacy_Data__c,
               On_Account_Money_Autocalculated__c, Project_Unit__r.Tower__r.Name, Booking__r.Stage_of_Booking__c, Business_Unit__c, Booking__r.Name 
               From Receipt__c 
               where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared' and name > :pgw.first_limit
               ORDER BY name asc limit:pgw.list_size];
       } else {
           objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c, Is_Reversed_Receipt__c,               
               Total_Amount__c, Project_Unit__r.Name, Mode__c, Currency__c, DraweeBank__c,Description__c, Receipt_Status__c, Legacy_Data__c,
               On_Account_Money_Autocalculated__c, Project_Unit__r.Tower__r.Name, Booking__r.Stage_of_Booking__c, Business_Unit__c, Booking__r.Name 
               From Receipt__c 
               where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared' and name > :pgw.first_limit AND Legacy_Data__c = false
               ORDER BY name asc limit:pgw.list_size];
       }
         
         wrapperscppdList = new List<wrapperclass>();
         
         if(objR.size() > 0){
            pgw.created_date = objR[0].name;
            pgw.first_limit = objR[objR.size() - 1].name;
         }
         
         for (integer i = objR.size() - 1 ; i >= 0 ; i--){
             wrapperscppdList.add(new wrapperclass(objR[i], objR[i].Total_Amount__c, objR[i].On_Account_Money_Autocalculated__c));               
         }         
       return null;
     }   
     
     public PageReference Next() { //user clicked next button
        pgw = PaginationController.Next(pgw);
        
        if(showLegacyReceipt) { 
        objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c, 
                Total_Amount__c, Project_Unit__r.Name, Mode__c, Is_Reversed_Receipt__c, DraweeBank__c,Description__c, On_Account_Money_Autocalculated__c, Legacy_Data__c,
                Currency__c, Receipt_Status__c, Project_Unit__r.Tower__r.Name, Booking__r.Stage_of_Booking__c, Business_Unit__c, Booking__r.Name
                From Receipt__c 
                where On_Account_Money_Autocalculated__c > 0 AND Receipt_status__c = 'Cleared' and name < :pgw.created_date
                ORDER BY name desc limit:pgw.list_size];
        } else {
            objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Project_Unit__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c, 
                Total_Amount__c, Project_Unit__r.Name, Mode__c, Is_Reversed_Receipt__c, DraweeBank__c,Description__c, On_Account_Money_Autocalculated__c, Legacy_Data__c,
                Currency__c, Receipt_Status__c, Project_Unit__r.Tower__r.Name, Booking__r.Stage_of_Booking__c, Business_Unit__c, Booking__r.Name
                From Receipt__c 
                where On_Account_Money_Autocalculated__c > 0 AND Receipt_status__c = 'Cleared' and name < :pgw.created_date AND Legacy_Data__c = false
                ORDER BY name desc limit:pgw.list_size];
        }

         wrapperscppdList = new List<wrapperclass>();
         
         if(objR.size() > 0){
                pgw.created_date = objR[objR.size() - 1].name;
                pgw.first_limit = objR[0].name;
         }         
         for (integer i = 0 ; i < objR.size() ; i++){
             wrapperscppdList.add(new wrapperclass(objR[i], objR[i].Total_Amount__c, objR[i].On_Account_Money_Autocalculated__c));               
         }          
        return null;
     }  
     
     public PageReference End() { //user clicked end
        pgw = PaginationController.End(pgw);
        
        if(showLegacyReceipt) { 
        objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c,               
                Total_Amount__c, Project_Unit__r.Name, Mode__c, Project_Unit__c, Currency__c, Receipt_Status__c, Is_Reversed_Receipt__c, Legacy_Data__c,
                DraweeBank__c,Description__c, On_Account_Money_Autocalculated__c, Project_Unit__r.Tower__r.Name,               
                Booking__r.Stage_of_Booking__c, Business_Unit__c, Booking__r.Name From Receipt__c                 
                where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared'
                ORDER BY name ASC limit:pgw.last_limit];
        } else {
            objR = [Select id, Name, Receipt_Number__c, Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Primary_Name__c,Cheque_DD_Date__c,               
                Total_Amount__c, Project_Unit__r.Name, Mode__c, Project_Unit__c, Currency__c, Receipt_Status__c, Is_Reversed_Receipt__c, Legacy_Data__c,
                DraweeBank__c,Description__c, On_Account_Money_Autocalculated__c, Project_Unit__r.Tower__r.Name,               
                Booking__r.Stage_of_Booking__c, Business_Unit__c, Booking__r.Name From Receipt__c                 
                where On_Account_Money_Autocalculated__c > 0 AND Receipt_Status__c = 'Cleared' AND Legacy_Data__c = false
                ORDER BY name ASC limit:pgw.last_limit];
        }
         
         wrapperscppdList = new List<wrapperclass>();                               
         if(objR.size() > 0){
                pgw.created_date = objR[0].name;
                pgw.first_limit = objR[objR.size() - 1].name;
         }         
         for (integer i = objR.size() - 1; i >= 0; i--){
             wrapperscppdList.add(new wrapperclass(objR[i], objR[i].Total_Amount__c, objR[i].On_Account_Money_Autocalculated__c));               
         }  
        
        return null;
     }  
     
    public Integer getTotal_size() {
        return (PaginationController.getTotal_size(pgw));
    }   
    
    public Integer getPageNumber() {
         return (PaginationController.getPageNumber(pgw));
    }
    
    public Integer getTotalPages() {
        return (PaginationController.getTotalPages(pgw));
    }        
}