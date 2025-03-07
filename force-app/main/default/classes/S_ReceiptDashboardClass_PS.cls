public with sharing class S_ReceiptDashboardClass_PS {
    public string errorMsg {get;set;}
    public string infavourtoken1 {get;set;}
    public Transient List<PropStrength__Received_Payment__c> objR {get;set;}
    public Transient List<PropStrength__Received_Payment__c> dummyList {get;set;}
    public List<PropStrength__Applicant_Detail__c> listApp {get;set;} 
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
        public Transient PropStrength__Received_Payment__c ReceiptR {get;set;}
        public Transient String otherAppName {get;set;}
        
        public wrapperclass(PropStrength__Received_Payment__c s, Decimal d, Decimal d1, String onmes){           
            ReceiptR = s;
            Amount1 = InventoryCostServices.INFormat(d);
            Amount1 = Amount1.replace('AED','');
            Amount1 = Amount1.replace('/-','');
            Amount2 = InventoryCostServices.INFormat(d1); 
            otherAppName = onmes;          
        }
    }  
       
    public S_ReceiptDashboardClass_PS(){
        errorMsg = '';
        infavourtoken1 ='';
        objR = new List<PropStrength__Received_Payment__c>();  
        showCloseBtn = false;    
        pgw = new PaginationController.PaginationWrapper();
        pgw.list_size = 20;  /// No of records to display on page
        pgw.counter = 0;
        pgw.created_date = '';
        dummyList = new List<PropStrength__Received_Payment__c>();
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
             objR = [SELECT Id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c,              
                    PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, Receipt_Status__c, PropStrength__Payment_Type__c, PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c,
                    PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, PropStrength__Application_Booking__r.Name, PropStrength__Receipt_Reversed__c, Legacy_Data__c,
                    Currency__c, PropStrength__Application_Booking__r.PropStrength__Tower__c From PropStrength__Received_Payment__c
                    WHERE RecordType.Name = 'Payment Received' AND Legacy_Data__c = false AND 
                    (PropStrength__Application_Booking__r.Name Like :search OR PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name Like :search OR PropStrength__Application_Booking__r.PropStrength__Property_Name__c Like :search OR Name Like :search)
                    ORDER BY Name DESC LIMIT 25];
              system.debug('search::: ' + pagination);
            
        }
         else {
             pagination = true;
             objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c, Instrument_Date__c,                 
                PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, Receipt_Status__c, PropStrength__Payment_Type__c, PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c,
                PropStrength__Bank_Name_Auto__c, PropStrength__Description__c, PropStrength__Application_Booking__r.Name, PropStrength__Receipt_Reversed__c, Legacy_Data__c,
                Currency__c, PropStrength__Application_Booking__r.PropStrength__Tower__c From PropStrength__Received_Payment__c                  
                where RecordType.Name = 'Payment Received'  AND Legacy_Data__c = false               
                ORDER BY name DESC limit:pgw.list_size offset:pgw.counter]; 
            
        }
         dummyList = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c,                   
                      PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Payment_Type__c, Business_Unit__c, PropStrength__Application_Booking__r.PropStrength__Tower__c, PropStrength__Application_Booking__r.PropStrength__Status__c,
                      PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, PropStrength__Application_Booking__r.Name, Currency__c, Receipt_Status__c, Legacy_Data__c                    
                      From PropStrength__Received_Payment__c 
                      where RecordType.Name = 'Payment Received'  AND Legacy_Data__c = false
                      ORDER BY name DESC];       
           if(dummyList.size() > 0){
                pgw.total_size = dummyList.size();    
                pgw.last_date =  dummyList[dummyList.size() - 1].name;            
           }
           if(objR.size() > 0){
                pgw.created_date = objR[objR.size() - 1].name;
           }                            
         wrapperscppdList = new List<wrapperclass>();
         Set<Id> bookId = new Set<Id>();
         for (integer i = 0 ; i < objR.size() ; i++){
            if(objR[i].PropStrength__Application_Booking__c != null) {
                bookId.add(objR[i].PropStrength__Application_Booking__c);
            }
         }    
         Map<Id, String> otherApplicantMap = new Map<Id, String>();
         if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, (SELECT Id, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r  WHERE PropStrength__Active__c = true AND PropStrength__Type__c != '1st Applicant') FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];

            for(PropStrength__Application_Booking__c b : bookList) {
                if(b.PropStrength__Applicant_Details__r != null) {
                    String namesOther = '';
                    for(PropStrength__Applicant_Detail__c appDet : b.PropStrength__Applicant_Details__r) {
                        namesOther += appDet.PropStrength__Customer_Name__c;
                    }
                    otherApplicantMap.put(b.Id, namesOther);
                }
            }
         }
         for (integer i = 0 ; i < objR.size() ; i++){
            if(objR[i].PropStrength__Application_Booking__c != null && otherApplicantMap.containsKey(objR[i].PropStrength__Application_Booking__c)) {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0,otherApplicantMap.get(objR[i].PropStrength__Application_Booking__c) ));               
            } else {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0, ''));               
            }
             
         } 
         return null;
    }
    
    public PageReference searchLegacyResult(){
         if(searchByName != '' && searchByName != null){
             pagination = false;
             String search = '%' + searchByName  + '%'; 
             objR = [SELECT Id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c,              
                    PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, Receipt_Status__c, PropStrength__Payment_Type__c, PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c,
                    PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, PropStrength__Application_Booking__r.Name, PropStrength__Receipt_Reversed__c, Legacy_Data__c,
                    Currency__c, PropStrength__Application_Booking__r.PropStrength__Tower__c From PropStrength__Received_Payment__c
                    WHERE RecordType.Name = 'Payment Received' AND
                    (PropStrength__Application_Booking__r.Name Like :search OR PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name Like :search OR PropStrength__Application_Booking__r.PropStrength__Property_Name__c Like :search OR Name Like :search)
                    ORDER BY Name DESC LIMIT 25];
            
        }
         else {
             pagination = true;
             objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c, Instrument_Date__c,                 
                PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, Receipt_Status__c, PropStrength__Payment_Type__c, PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c,
                PropStrength__Bank_Name_Auto__c, PropStrength__Description__c, PropStrength__Application_Booking__r.Name, PropStrength__Receipt_Reversed__c, Legacy_Data__c,
                Currency__c, PropStrength__Application_Booking__r.PropStrength__Tower__c From PropStrength__Received_Payment__c                  
                where RecordType.Name = 'Payment Received'              
                ORDER BY name DESC limit:pgw.list_size offset:pgw.counter]; 
            
        }
         dummyList = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c,                   
                      PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Payment_Type__c, Business_Unit__c, PropStrength__Application_Booking__r.PropStrength__Tower__c, PropStrength__Application_Booking__r.PropStrength__Status__c,
                      PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, PropStrength__Application_Booking__r.Name, Currency__c, Receipt_Status__c, Legacy_Data__c                   
                      From PropStrength__Received_Payment__c 
                      where RecordType.Name = 'Payment Received'                 
                      ORDER BY name DESC];       
           if(dummyList.size() > 0){
                pgw.total_size = dummyList.size();    
                pgw.last_date =  dummyList[dummyList.size() - 1].name;            
           }
           if(objR.size() > 0){
                pgw.created_date = objR[objR.size() - 1].name;
           }                            
         wrapperscppdList = new List<wrapperclass>();
         Set<Id> bookId = new Set<Id>();
         for (integer i = 0 ; i < objR.size() ; i++){
            if(objR[i].PropStrength__Application_Booking__c != null) {
                bookId.add(objR[i].PropStrength__Application_Booking__c);
            }
         }    
         Map<Id, String> otherApplicantMap = new Map<Id, String>();
         if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, (SELECT Id, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r  WHERE PropStrength__Active__c = true AND PropStrength__Type__c != '1st Applicant') FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];

            for(PropStrength__Application_Booking__c b : bookList) {
                if(b.PropStrength__Applicant_Details__r != null) {
                    String namesOther = '';
                    for(PropStrength__Applicant_Detail__c appDet : b.PropStrength__Applicant_Details__r) {
                        namesOther += appDet.PropStrength__Customer_Name__c;
                    }
                    otherApplicantMap.put(b.Id, namesOther);
                }
            }
         }    
         for (integer i = 0 ; i < objR.size() ; i++){
             if(objR[i].PropStrength__Application_Booking__c != null && otherApplicantMap.containsKey(objR[i].PropStrength__Application_Booking__c)) {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0,otherApplicantMap.get(objR[i].PropStrength__Application_Booking__c) ));               
            } else {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0, ''));               
            }
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
        objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, Currency__c,
                PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c, PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c,               
                Receipt_Status__c, PropStrength__Payment_Type__c, PropStrength__Receipt_Reversed__c, Business_Unit__c, Legacy_Data__c,
                PropStrength__Application_Booking__r.PropStrength__Tower__c, PropStrength__Application_Booking__r.PropStrength__Status__c, PropStrength__Application_Booking__r.Name From PropStrength__Received_Payment__c                               
                where RecordType.Name = 'Payment Received'
                ORDER BY name DESC limit:pgw.list_size offset:pgw.counter];
        } else {
            objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, Currency__c,
                PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c, PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c,               
                Receipt_Status__c, PropStrength__Payment_Type__c, PropStrength__Receipt_Reversed__c, Business_Unit__c, Legacy_Data__c,
                PropStrength__Application_Booking__r.PropStrength__Tower__c, PropStrength__Application_Booking__r.PropStrength__Status__c, PropStrength__Application_Booking__r.Name From PropStrength__Received_Payment__c                               
                where RecordType.Name = 'Payment Received' AND Legacy_Data__c = false
                ORDER BY name DESC limit:pgw.list_size offset:pgw.counter];    
        }
         
         wrapperscppdList = new List<wrapperclass>();  
         Set<Id> bookId = new Set<Id>();       
         if(objR.size() > 0){
            pgw.created_date = objR[objR.size() - 1].name;
         }
         for (integer i = 0 ; i < objR.size() ; i++){
            if(objR[i].PropStrength__Application_Booking__c != null) {
                bookId.add(objR[i].PropStrength__Application_Booking__c);
            }
         }    
         Map<Id, String> otherApplicantMap = new Map<Id, String>();
         if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, (SELECT Id, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r  WHERE PropStrength__Active__c = true AND PropStrength__Type__c != '1st Applicant') FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];

            for(PropStrength__Application_Booking__c b : bookList) {
                if(b.PropStrength__Applicant_Details__r != null) {
                    String namesOther = '';
                    for(PropStrength__Applicant_Detail__c appDet : b.PropStrength__Applicant_Details__r) {
                        namesOther += appDet.PropStrength__Customer_Name__c;
                    }
                    otherApplicantMap.put(b.Id, namesOther);
                }
            }
         }
         for (integer i = 0 ; i < objR.size() ; i++){
             if(objR[i].PropStrength__Application_Booking__c != null && otherApplicantMap.containsKey(objR[i].PropStrength__Application_Booking__c)) {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0,otherApplicantMap.get(objR[i].PropStrength__Application_Booking__c) ));               
            } else {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0, ''));               
            }
         }  
        return null;
     }   
     
     public PageReference Previous() { //user clicked previous button
       pgw = PaginationController.Previous(pgw);
       
       if(showLegacyReceipt) {      
       objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c, PropStrength__Receipt_Reversed__c,               
               PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Payment_Type__c, Currency__c, PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, Receipt_Status__c, Legacy_Data__c,
               PropStrength__Application_Booking__r.PropStrength__Tower__c, PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c, PropStrength__Application_Booking__r.Name 
               From PropStrength__Received_Payment__c 
               where RecordType.Name = 'Payment Received'  and name > :pgw.first_limit
               ORDER BY name asc limit:pgw.list_size];
       } else {
           objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c, PropStrength__Receipt_Reversed__c,               
               PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Payment_Type__c, Currency__c, PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, Receipt_Status__c, Legacy_Data__c,
               PropStrength__Application_Booking__r.PropStrength__Tower__c, PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c, PropStrength__Application_Booking__r.Name 
               From PropStrength__Received_Payment__c 
               where RecordType.Name = 'Payment Received'  and name > :pgw.first_limit AND Legacy_Data__c = false
               ORDER BY name asc limit:pgw.list_size];
       }
         
         wrapperscppdList = new List<wrapperclass>();
         Set<Id> bookId = new Set<Id>();
         if(objR.size() > 0){
            pgw.created_date = objR[0].name;
            pgw.first_limit = objR[objR.size() - 1].name;
         }

         for (integer i = 0 ; i < objR.size() ; i++){
            if(objR[i].PropStrength__Application_Booking__c != null) {
                bookId.add(objR[i].PropStrength__Application_Booking__c);
            }
         }    
         Map<Id, String> otherApplicantMap = new Map<Id, String>();
         if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, (SELECT Id, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r  WHERE PropStrength__Active__c = true AND PropStrength__Type__c != '1st Applicant') FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];

            for(PropStrength__Application_Booking__c b : bookList) {
                if(b.PropStrength__Applicant_Details__r != null) {
                    String namesOther = '';
                    for(PropStrength__Applicant_Detail__c appDet : b.PropStrength__Applicant_Details__r) {
                        namesOther += appDet.PropStrength__Customer_Name__c;
                    }
                    otherApplicantMap.put(b.Id, namesOther);
                }
            }
         }
         
         for (integer i = objR.size() - 1 ; i >= 0 ; i--){
             if(objR[i].PropStrength__Application_Booking__c != null && otherApplicantMap.containsKey(objR[i].PropStrength__Application_Booking__c)) {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0,otherApplicantMap.get(objR[i].PropStrength__Application_Booking__c) ));               
            } else {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0, ''));               
            }
         }         
       return null;
     }   
     
     public PageReference Next() { //user clicked next button
        pgw = PaginationController.Next(pgw);
        
        if(showLegacyReceipt) { 
        objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c, 
                PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Payment_Type__c, PropStrength__Receipt_Reversed__c, PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, Legacy_Data__c,
                Currency__c, Receipt_Status__c, PropStrength__Application_Booking__r.PropStrength__Tower__c, PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c, PropStrength__Application_Booking__r.Name
                From PropStrength__Received_Payment__c 
                where RecordType.Name = 'Payment Received'  and name < :pgw.created_date
                ORDER BY name desc limit:pgw.list_size];
        } else {
            objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c, 
                PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Payment_Type__c, PropStrength__Receipt_Reversed__c, PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, Legacy_Data__c,
                Currency__c, Receipt_Status__c, PropStrength__Application_Booking__r.PropStrength__Tower__c, PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c, PropStrength__Application_Booking__r.Name
                From PropStrength__Received_Payment__c 
                where RecordType.Name = 'Payment Received'  and name < :pgw.created_date AND Legacy_Data__c = false
                ORDER BY name desc limit:pgw.list_size];
        }

         wrapperscppdList = new List<wrapperclass>();
         Set<Id> bookId = new Set<Id>();
         if(objR.size() > 0){
                pgw.created_date = objR[objR.size() - 1].name;
                pgw.first_limit = objR[0].name;
         }     
         
         for (integer i = 0 ; i < objR.size() ; i++){
            if(objR[i].PropStrength__Application_Booking__c != null) {
                bookId.add(objR[i].PropStrength__Application_Booking__c);
            }
         }    
         Map<Id, String> otherApplicantMap = new Map<Id, String>();
         if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, (SELECT Id, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r  WHERE PropStrength__Active__c = true AND PropStrength__Type__c != '1st Applicant') FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];

            for(PropStrength__Application_Booking__c b : bookList) {
                if(b.PropStrength__Applicant_Details__r != null) {
                    String namesOther = '';
                    for(PropStrength__Applicant_Detail__c appDet : b.PropStrength__Applicant_Details__r) {
                        namesOther += appDet.PropStrength__Customer_Name__c;
                    }
                    otherApplicantMap.put(b.Id, namesOther);
                }
            }
         }

         for (integer i = 0 ; i < objR.size() ; i++){
             if(objR[i].PropStrength__Application_Booking__c != null && otherApplicantMap.containsKey(objR[i].PropStrength__Application_Booking__c)) {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0,otherApplicantMap.get(objR[i].PropStrength__Application_Booking__c) ));               
            } else {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0, ''));               
            }
         }          
        return null;
     }  
     
     public PageReference End() { //user clicked end
        pgw = PaginationController.End(pgw);
        
        if(showLegacyReceipt) { 
        objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c,               
                PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Payment_Type__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, Currency__c, Receipt_Status__c, PropStrength__Receipt_Reversed__c, Legacy_Data__c,
                PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, PropStrength__Application_Booking__r.PropStrength__Tower__c,               
                PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c, PropStrength__Application_Booking__r.Name From PropStrength__Received_Payment__c                 
                where RecordType.Name = 'Payment Received' 
                ORDER BY name ASC limit:pgw.last_limit];
        } else {
            objR = [Select id, Name, Receipt_Number__c, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c,Instrument_Date__c,               
                PropStrength__Amount__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Payment_Type__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__c, PropStrength__Application_Booking__r.House_Unit_No__c, Currency__c, Receipt_Status__c, PropStrength__Receipt_Reversed__c, Legacy_Data__c,
                PropStrength__Bank_Name_Auto__c,PropStrength__Description__c, PropStrength__Application_Booking__r.PropStrength__Tower__c,               
                PropStrength__Application_Booking__r.PropStrength__Status__c, Business_Unit__c, PropStrength__Application_Booking__r.Name From PropStrength__Received_Payment__c                 
                where RecordType.Name = 'Payment Received'  AND Legacy_Data__c = false
                ORDER BY name ASC limit:pgw.last_limit];
        }
         
         wrapperscppdList = new List<wrapperclass>();   
         Set<Id> bookId = new Set<Id>();                            
         if(objR.size() > 0){
                pgw.created_date = objR[0].name;
                pgw.first_limit = objR[objR.size() - 1].name;
         }   
         
         for (integer i = 0 ; i < objR.size() ; i++){
            if(objR[i].PropStrength__Application_Booking__c != null) {
                bookId.add(objR[i].PropStrength__Application_Booking__c);
            }
         }    
         Map<Id, String> otherApplicantMap = new Map<Id, String>();
         if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, (SELECT Id, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r  WHERE PropStrength__Active__c = true AND PropStrength__Type__c != '1st Applicant') FROM PropStrength__Application_Booking__c WHERE Id IN :bookId];

            for(PropStrength__Application_Booking__c b : bookList) {
                if(b.PropStrength__Applicant_Details__r != null) {
                    String namesOther = '';
                    for(PropStrength__Applicant_Detail__c appDet : b.PropStrength__Applicant_Details__r) {
                        namesOther += appDet.PropStrength__Customer_Name__c;
                    }
                    otherApplicantMap.put(b.Id, namesOther);
                }
            }
         }

         for (integer i = objR.size() - 1; i >= 0; i--){
             if(objR[i].PropStrength__Application_Booking__c != null && otherApplicantMap.containsKey(objR[i].PropStrength__Application_Booking__c)) {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0,otherApplicantMap.get(objR[i].PropStrength__Application_Booking__c) ));               
            } else {
                wrapperscppdList.add(new wrapperclass(objR[i], objR[i].PropStrength__Amount__c, 0, ''));               
            }
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