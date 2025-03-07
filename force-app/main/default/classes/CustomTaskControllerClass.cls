public with sharing class CustomTaskControllerClass {
    public Task t = new Task();
    public boolean create {get;set;}
    public boolean edit {get;set;}
    public boolean error {get;set;}
    public boolean errorForSave {get;set;}
    private Id whatId = null;
    private Id whoId = null;
    private Id ownerId = null;
    private Id bookId = null; // Added by Neha on 23/4/19
    private String origin = null;
    private ApexPages.StandardController stdController = null;
    private string cancelURL = null;
    private string retURL = null;
    private List <Account> acc = new List < Account > ();
    private Map <String, String> qsMap = new Map < String, String > ();
 
 ///represents the registration status while landing on the page.
    public List<task> listTask{get;set;}
    public List <Demand__c> Demand {get; set;}  // Added by Neha on 24/5/19
    public Boolean ageing {get;set;}
    public Decimal ageingDays;
    public Map<Demand__c, Boolean> demandAgeingMap {get;set;}

    public CustomTaskControllerClass(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.t = (Task) controller.getRecord();
        
        demandAgeingMap = new Map<Demand__c, Boolean>(); 
        create = false;
        edit = false;
        error = false;
        errorForSave = false;     
        ageing = false; 
        ageingDays = 0;
        qsMap = ApexPages.currentPage().getParameters();  
        
        if( qsMap.get('taskType') == 'Meeting' ){
           this.t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Meeting').getRecordTypeId(); 
        } else {
           this.t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collection').getRecordTypeId(); 
        }
        
        if(qsMap.containsKey('origin')) {
            origin = qsMap.get('origin');
        } else {
            origin = 'Default';
        }
     
        // what and are who are present in oppty page task button
        if (qsMap.containsKey('who_id') && qsMap.containsKey('what_id')) {
            whatId = ApexPages.currentPage().getParameters().get('what_id');          
            whoId = ApexPages.currentPage().getParameters().get('who_id');
            ownerId = UserInfo.getUserId();
            bookId = qsMap.get('bookingId'); // Added by Neha on 23/4/19
            create = true;
        } else if (qsMap.containsKey('who_id')) {
            // who is present only on lead page task
            whoId = ApexPages.currentPage().getParameters().get('who_id');
            ownerId = UserInfo.getUserId();
            create = true;
            retURL = '/' + whoId; 
            cancelURL = '/' + whoId;
        } else if (qsMap.containsKey('id')) {
            // if task id is present its an task edit
            edit = true;
        } else {
            // if none are there is an error
            error = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.FATAL, 'Missing Required Parameters');
            ApexPages.addMessage(errorMsg);
        }

        // if we dont know the origin, we set to default.
        // if its coming from any of the custom button on task page, it would have the button name as the origin
        // if an origin is known, then take the url parameters and set it in the value of the task
       if (create) {        
            String objectwhoName = null;
       
            if (String.isNotEmpty(whoId)) {
                objectWhoName = whoId.getSObjectType().getDescribe().getName();
            }
          
           if (objectwhoName == 'Account' || objectwhoName == 'Contact') {
                acc = [Select Name, Id, IsPersonAccount, PersonMobilePhone, PersonContactId from Account where Id = : whoId];
            }
            if (acc.size() == 1 && acc[0].IsPersonAccount) {
                whoId = acc[0].PersonContactId;            
            }        

            if (String.isNotEmpty(whatId))
                t.WhatId = whatId;
            if(String.isNotEmpty(bookId)) /// Added by Neha on 23/4/19
                t.Booking__c = bookId; /// Added by Neha on 23/4/19
            t.OwnerId = ownerId;
            t.whoId = whoId;
            t.activityDate = System.today();
            t.Call_Time__c = System.Now().format('h:mm a');
          
            // if we dont know the origin, we set to default.
            // if its coming from any of the custom button on task page, it would have the button name as the origin
            // if an origin is known, then take the url parameters and set it in the value of the task
            if (!origin.equals('Default')) {
                t.status = qsMap.get('status');
                t.Subject = qsMap.get('subject');
                t.Task_Type__c = qsMap.get('taskType');
                t.priority = 'Normal';
            }       
        }
            
         ///// Added by Neha for call history on 19/4/19   
         if(whatId != null) 
             getCallHistory(whatId);  
             
         ////// Added by Neha to print demand details on 27/5/19
         if(bookId != null)
             getAllPendingDemands(bookId);                   
    }

    public PageReference save() {      
        system.debug('inside save');
        errorForSave = False;
        Pagereference pv = null;
        try {
            if (origin.equals('CompleteTask')) {
                t.status = 'Completed';
            }
            t.Subject = t.Task_Type__c;
           
            if (errorForSave != True) {
                System.debug('in task save:');
                pv = stdController.save();
                System.debug('in task save:1');
            }

            // took a day to figure this out. if the standard controller save is called
            // it handles the validation exceptions and returns a null as page reference
            // doesnt throw DML exception as described in the SF documents
            // check for pv = null and return the same to see the exceptions on UI
            if (pv == null) {
                return null;
            }
            retURL = '/lightning/n/Collection_Dashboard'; // Added by Neha on 29/5/19
            if (String.isNotEmpty(retURL)) {
                pv = new PageReference(retURL);
            } else {
                pv = new PageReference('/' + t.whoId);
            }
            update Demand;
            system.debug('demands are updated');
            return pv;
        } catch (DMLException e) {
            System.debug('DML:' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        } catch (Exception e) {
            System.debug('Ex:' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }              
    }

    public PageReference cancel() {
        Pagereference pv = null;
        cancelURL = '/lightning/n/Collection_Dashboard';  /// Added by Neha on 29/5/19
        if (String.isNotEmpty(cancelURL)) {
            pv = new PageReference(cancelURL);
        } else {
            if (String.isNotEmpty(t.whatId)) {
                cancelURL = '/' + t.whatId;
            } else {
                cancelURL = '/' + t.whoId;
            }
            pv = new PageReference(cancelURL);
        }
        return pv;
    }
 //// Added by Neha on 19/4/19   
    public void getCallHistory(Id optyId){
        listTask = new List<Task>();
        Id collectionId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
        System.debug('Task Collection Record Type Id::: ' + collectionId);
        if(collectionId != null && optyId != null){
            listTask = [SELECT Id, Next_Action_Date__c, Communication_Type__c, Call_Status__c, Description, 
                        Call_Attempt_Status__c, CreatedDate FROM TASK 
                        WHERE RecordTypeId =:collectionId AND WhatId =:optyId ORDER BY CreatedDate DESC]; 
        }
    }
    
    public void getAllPendingDemands(Id bookingId){
    
        Demand = [Select id, Name, Booking__c, Booking__r.Name, Booking__r.Primary_Applicant_Name__c, Booking__r.Unit__r.Name, Booking__r.Opportunity__c, Booking__r.Opportunity__r.Account.Name,
                  Due_Date__c, Invoice_Date__c,  Total_Amount_Balance__c , Overall_Interest_Due__c, Booking__r.Opportunity__r.AccountId, Booking__r.Id, Ageing__c,
                  PTP_Date_1__c, PTP_Date_2__c, PTP_Date_3__c, PTP_Amount_1__c, PTP_Amount_2__c, PTP_Amount_3__c, Total_Tax_Balance__c, Milestone_Name__c
                  From Demand__c 
                  WHERE Booking__c = :bookingId AND (Total_Amount_Balance__c > 0 OR Total_Tax_Balance__c > 0) AND Demand_Status__c != 'Reversed' AND Debit_Type__c != 'Credit Note Reversal' ORDER BY Due_Date__c]; 
        
        for(Demand__c d: Demand){
            if(d.Ageing__c > ageingDays && d.Ageing__c < 180){
                ageingDays = d.Ageing__c;
                demandAgeingMap.put(d, true);
            } else  {
                demandAgeingMap.put(d, false);
            }         
        }       
    }
}