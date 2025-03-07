public with sharing class S_CollectionsDashboardNewController_PS{
    
    public string errorMsg {get;set;}    
    public string selectedProjectId {get;set;}
    public string selectedRM {get;set;}  
    public string selectedTowerIdF {get;set;}
    public string selectedProjectIdF {get;set;}
    public string selectedRMF {get;set;}  
    public string selectedTowerId {get;set;}
    public List<PropStrength__Received_Payment__c> objSCPPD3 {get;set;}
    public Set<String> towerNames {get;set;}
    public List <PropStrength__Received_Payment__c> Demand {get; set;} 
    public List <PropStrength__Received_Payment__c> dummyDemand; 
    public Map <String, List <PropStrength__Received_Payment__c>> JMap {get;set;}
    public Map <Id, List<PropStrength__Application_Booking__c>> accBookingMap {get;set;}
    public Map <Id, String> accMap {get;set;}
    public Boolean todayFollowUp {get;set;}
    public Boolean pendingFollowUp {get;set;}
    public Boolean DLDFollowUp {get;set;}
    public String searchByName {get; set;}
    public String followupsearchByName {get; set;}
    public Boolean search {get;set;}
    public Boolean searchfollowUp {get;set;}
    public String selectedRadioOption {get;set;}
    public Boolean radioPanel {get;set;}
    public PaginationController.PaginationWrapper pgw; // Added by Neha on 11/11/19
    public Boolean pagination {get;set;} ///// Added by Neha on 11/11/19
    public Boolean paginationT {get;set;} ///// Added by Neha on 11/11/19
    public Boolean paginationP {get;set;} ///// Added by Neha on 11/11/19
    public Boolean paginationD {get;set;} ///// Added by Neha on 11/11/19
    
    public S_CollectionsDashboardNewController_PS(){
        errorMsg = '';
        objSCPPD3 = new List<PropStrength__Received_Payment__c>();
        towerNames = null; 
        todayFollowUp = false; 
        pendingFollowUp = false;
        DLDFollowUp = false;
        searchByName = '';
        followupsearchByName  = '';
        search = false;
        searchfollowUp = false;
        radioPanel = false;
        
        List<PropStrength__Projects__c> proList = new List<PropStrength__Projects__c>([SELECT Id FROM PropStrength__Projects__c WHERE Name = 'Hartland' LIMIT 1]);
        if(!proList.isEmpty() && proList.size() == 1){
            selectedProjectIdF = proList[0].Id;
            selectedProjectId = proList[0].Id;
        }          
        else {
            selectedProjectId = ''; 
            selectedProjectIdF = '';
        }
        
        pgw = new PaginationController.PaginationWrapper();// Added by Neha on 11/11/19
        pgw.list_size = 10; // Records to display on each page // Added by Neha on 11/11/19
        pgw.counter = 0; // Added by Neha on 28/6/19
        pagination = false; // Added by Neha on 28/6/19
        paginationP = false; // Added by Neha on 28/6/19
        paginationT = false; // Added by Neha on 28/6/19
        paginationD = false; // Added by Neha on 28/6/19
    }
    
    //Get the list of projects to populate the filter on UI
    public list<SelectOption> lstProjects {
        get{
            lstProjects = null;
            list<SelectOption> lstTempProjects = new list<SelectOption>();
            lstTempProjects.add(new SelectOption('', '--Select Project--'));
            for(PropStrength__Projects__c objProj : [select id, name from PropStrength__Projects__c]){
                if(objProj.name != null)
                    lstTempProjects.add(new SelectOption(objProj.id, objProj.name));
            }
            return lstTempProjects;
        }
        set;
    }
    
    public list<SelectOption> lstTowers {
        get{
            lstTowers = null;
            list<SelectOption> lstTempTowers = new list<SelectOption>();
            lstTempTowers.add(new SelectOption('', '--Select Tower--'));           
            for(PropStrength__Tower__c objTower : [SELECT Id, Name, PropStrength__Tower_Name__c from PropStrength__Tower__c WHERE PropStrength__Project_Name__c = :selectedProjectId]){
                if(objTower.name != null)
                    lstTempTowers.add(new SelectOption(objTower.Id, objTower.PropStrength__Tower_Name__c));
            }
            return lstTempTowers;
        }
        set;
    }
    
    //Get the list of RMs for the bookings in the selected project to populate the filter on UI
    public list<SelectOption> getRMs{
        get{
            Set<String> stRMs = new Set<String>();
            errorMsg = '';
            list<SelectOption> lstTempRM = new list<SelectOption>();
            lstTempRM.add(new SelectOption('All', 'Select a Collector'));
            if(selectedTowerId != null && selectedTowerId != ''){                
                objSCPPD3 = [Select Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__r.Name From PropStrength__Received_Payment__c where RecordType.Name = 'Payment Due' AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c = :selectedTowerId AND PropStrength__Application_Booking__r.PropStrength__Project__c = :selectedProjectId];
                if(objSCPPD3 != null && objSCPPD3.size() > 0){
                    for(PropStrength__Received_Payment__c y : objSCPPD3){
                        if(y.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__r.Name != null){
                            stRMs.add(y.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__r.Name);
                        }
                    }
                }
                else
                    errorMsg = 'No RMs found.';
                
                for (String r : stRMs){
                    lstTempRM.add(new SelectOption(r, r));
                }              
            }
            return lstTempRM;
        }
        set;
    }    
    
    public list<SelectOption> lstTowersF{
        get{
            lstTowers = null;
            list<SelectOption> lstTempTowers = new list<SelectOption>();
            lstTempTowers.add(new SelectOption('', '--Select Tower--'));           
            for(PropStrength__Tower__c objTower : [SELECT Id, Name, PropStrength__Tower_Name__c from PropStrength__Tower__c WHERE PropStrength__Project_Name__c = :selectedProjectIdF]){
                if(objTower.name != null)
                    lstTempTowers.add(new SelectOption(objTower.Id, objTower.PropStrength__Tower_Name__c));
            }
            return lstTempTowers;
        }
        set;
    }
    
    //Get the list of RMs for the bookings in the selected project to populate the filter on UI
    public list<SelectOption> getRMsF{
        get{
            Set<String> stRMs = new Set<String>();
            errorMsg = '';
            list<SelectOption> lstTempRM = new list<SelectOption>();
            lstTempRM.add(new SelectOption('All', 'Select a Collector'));
            if(selectedTowerIdF != null && selectedTowerIdF != ''){                
                objSCPPD3 = [Select Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__r.Name From PropStrength__Received_Payment__c where RecordType.Name = 'Payment Due' AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c = :selectedTowerIdF AND PropStrength__Application_Booking__r.PropStrength__Project__c = :selectedProjectIdF];
                if(objSCPPD3 != null && objSCPPD3.size() > 0){
                    for(PropStrength__Received_Payment__c y : objSCPPD3){
                        if(y.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__r.Name != null){
                            stRMs.add(y.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__r.Name);
                        }
                    }
                }
                else
                    errorMsg = 'No RMs found.';
                
                for (String r : stRMs){
                    lstTempRM.add(new SelectOption(r, r));
                }              
            }
            return lstTempRM;
        }
        set;
    }   
    
    public void clearSearch(){                
        searchByName = '';
        getDemandReciepts(); 
    }          
    
    //Perform search and return results for All Due Demands
    public pageReference getDemandReciepts(){   
        system.debug('Inside getDemandReciepts method');
        if(selectedProjectId == null || selectedProjectId == '') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select Project'));  
            return null;   
        }
        if(selectedTowerId == null || selectedTowerId == '') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select Tower')); 
            return null;    
        }
        search = true; 
        pagination = true;      
        getDemands(selectedProjectId, selectedTowerId, selectedRM, searchByName, null, pgw.list_size, pgw.counter);            
        return null;     
    }
    
    ////// Added by Neha on 19/4/19
    //// To get today's follow ups    
    public PageReference gettodayFollowUps(){
        system.debug('Inside getPendingFollowUps::::: ' + selectedRadioOption);
        todayFollowUp = true; 
        pendingFollowUp = false;
        DLDFollowUp = false;
        searchfollowUp = true;
        paginationT = true; 
        paginationP = false;
        paginationD = false;
        getDemands(selectedProjectIdF, selectedTowerIdF, selectedRMF, followupsearchByName, selectedRadioOption, pgw.list_size, pgw.counter); 
        return null;
    }
    
    //// To get pending follow ups    
    public PageReference getPendingFollowUps(){
        system.debug('Inside getPendingFollowUps::: ' + selectedRadioOption);
        pendingFollowUp = true;
        todayFollowUp = false;
        DLDFollowUp = false;
        searchfollowUp = true;
        paginationP = true; 
        paginationD = false;
        paginationT = false;
        getDemands(selectedProjectIdF, selectedTowerIdF, selectedRMF, followupsearchByName, selectedRadioOption, pgw.list_size, pgw.counter);  
        return null;
    }
    
    //// Added by Neha on 28/5/19 for pending DLD charges
    public PageReference getpendingDLDCharges(){   
        system.debug('Inside getpendingDLDCharges:::: ' + selectedRadioOption);      
        searchfollowUp = true;
        DLDFollowUp = true;
        todayFollowUp = false; 
        pendingFollowUp = false;  
        paginationD = true; 
        paginationP = false;
        paginationT = false;
        getDemands(selectedProjectIdF, selectedTowerIdF, selectedRMF, followupsearchByName, selectedRadioOption, pgw.list_size, pgw.counter);  
        return null;  
    } 

    ////// dynamic query for all the views     
    public PageReference getDemands(String selectedProject, String selectedTower, String selectedRM, String searchByName, String selectedRadioOption, Integer listSize, Integer counter){
        system.debug('Inside getDemands method');
        system.debug('selectedProject::: ' + selectedProject);
        system.debug('selectedTower::: ' + selectedTower);
        system.debug('selectedRM::: ' + selectedRM);
        system.debug('searchByName::: ' + searchByName);
        system.debug('selectedRadioOption::: ' + selectedRadioOption);
        system.debug('listSize::: ' + listSize);
        system.debug('counter::: ' + counter);
        
        JMap = new Map <String, List <PropStrength__Received_Payment__c>>();
        accBookingMap = new Map <Id, List<PropStrength__Application_Booking__c>>();
        accMap = new Map <Id, String>();
        Set<String> bookSet = new Set<String>();
        Demand = new List<PropStrength__Received_Payment__c>();
        dummyDemand = new List<PropStrength__Received_Payment__c>(); 
        
        String query = 'Select id, Name, PropStrength__Payment_Date__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Actual_Payment_Date__c, PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c, Milestone_Name__c,PropStrength__Application_Booking__r.PropStrength__Property__r.Name, PropStrength__Application_Booking__r.PropStrength__Property_Name__c, PropStrength__Application_Booking__r.Name, PropStrength__Application_Booking__r.PropStrength__Offer__c, PropStrength__Application_Booking__r.PropStrength__Offer__r.PropStrength__Broker_Account__r.Name, '+
            'PropStrength__Total_Balance__c, PropStrength__Total_Amount_Due_with_Service_Tax__c, PropStrength__Payment_Plan_Detail__r.PropStrength__Age__c, PropStrength__Payment_Plan_Detail__r.Recurring_Interest_Till_date__c, PropStrength__Application_Booking__r.PropStrength__Offer__r.PropStrength__Broker_Account__c, PropStrength__Application_Booking__r.Id, '+
            'PTP_Date_1__c, PTP_Date_2__c, PTP_Date_3__c, PTP_Amount_1__c, PTP_Amount_2__c, PTP_Amount_3__c, PropStrength__Balance__c '+ 
            'From PropStrength__Received_Payment__c '+ 
            'WHERE (PropStrength__Balance__c > 0) AND PropStrength__Is_Reversal_Created__c = false AND Debit_Type__c != \'Credit Note Reversal\' AND RecordType.Name = \'Payment Due\'';       
        
            // OR Total_Tax_Balance__c > 0
        if(selectedProject != null && selectedProject != ''){
            query += 'AND PropStrength__Application_Booking__r.PropStrength__Project__c = :selectedProject ';    
        }
        
        if(selectedTower != null && selectedTower != ''){
            query += 'AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c = :selectedTower ';    
        }
        
        if (selectedRM != null && selectedRM != 'All'){ 
            query += 'AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Collection_Executive__r.Name = :selectedRM '; 
        }                   
        
        if (searchByName != null && searchByName != ''){
            query += ' AND'+
                '(PropStrength__Application_Booking__r.Name Like ' + '\'%' + searchByName + '%\'' + ' OR PropStrength__Application_Booking__r.PropStrength__Offer__r.Name Like ' + '\'%' +searchByName+ '%\'' + ' OR PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name Like ' + '\'%' +searchByName+ '%\'' + ' OR PropStrength__Application_Booking__r.PropStrength__Property_Name__c Like ' + '\'%' +searchByName+ '%\'' + ')'; 
        }      
        
        if(selectedRadioOption != null && selectedRadioOption == 'Pending'){
            query += 'AND PropStrength__Application_Booking__r.Next_Action_Date__c != null AND PropStrength__Application_Booking__r.Next_Action_Date__c < Today AND'+
                '(PropStrength__Application_Booking__r.Last_Call_Attempt_Status__c = \'PTP\' OR PropStrength__Application_Booking__r.Last_Call_Attempt_Status__c = \'Follow Up\')';    
        }         
        
        if(selectedRadioOption != null && selectedRadioOption == 'Today'){
            query += 'AND PropStrength__Application_Booking__r.Next_Action_Date__c != null AND PropStrength__Application_Booking__r.Next_Action_Date__c = Today AND '+
                '(PropStrength__Application_Booking__r.Last_Call_Attempt_Status__c = \'PTP\' OR PropStrength__Application_Booking__r.Last_Call_Attempt_Status__c = \'Follow Up\')';    
        }        
        
        if(selectedRadioOption != null && selectedRadioOption == 'PendingDLD'){
            query = query.replace('AND RecordType.Name = \'Payment Due\'', '');
            query += 'AND PropStrength__Amount_Due_Type__c = \'DLD Fees\' AND RecordType.Name = \'Income Charge Due\'';
        }
        dummyDemand = Database.Query(query+ ' ORDER BY PropStrength__Actual_Payment_Date__c');
        pgw.total_size = dummyDemand.size();
    
        Demand = Database.Query(query + ' ORDER BY PropStrength__Actual_Payment_Date__c limit :listSize offset :counter');   //ORDER BY Due_Date__c
        
        if(Demand != null && Demand.size() > 0){                
            for (PropStrength__Received_Payment__c thisDemand: Demand) {                             
                if (JMap.containsKey((thisDemand.PropStrength__Application_Booking__r.Name))) {
                    JMap.get((thisDemand.PropStrength__Application_Booking__r.Name)).add(thisDemand);
                } else {
                    List <PropStrength__Received_Payment__c> unitD1 = new List <PropStrength__Received_Payment__c> ();
                    unitD1.add(thisDemand);
                    JMap.put((thisDemand.PropStrength__Application_Booking__r.Name), unitD1);
                }
            }       
            
            bookSet = JMap.keySet(); 
            List<PropStrength__Application_Booking__c> bList = [SELECT Id, Name, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Outstanding_Balance__c, PropStrength__Total_Payment_Received__c,  PropStrength__Primary_Customer__c, PropStrength__Primary_Customer__r.Name,  PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Broker_Account__c, PropStrength__Offer__r.PropStrength__Broker_Account__r.Name, PropStrength__Property__r.Name, PropStrength__Property__c, PropStrength__Property_Name__c, 
                                      PropStrength__Total_Paid_Percent__c FROM PropStrength__Application_Booking__c
                                      WHERE Name IN :bookSet]; 
            if(!bList.isEmpty()){
                for(PropStrength__Application_Booking__c b: bList){
                    if(b.PropStrength__Primary_Customer__c != null) {
                        if(accBookingMap.containsKey(b.PropStrength__Primary_Customer__c)){
                            accBookingMap.get(b.PropStrength__Primary_Customer__c).add(b);                      
                        } else {
                            List <PropStrength__Application_Booking__c> bl = new List<PropStrength__Application_Booking__c>();
                            bl.add(b);
                            accMap.put(b.PropStrength__Primary_Customer__c, b.PropStrength__Primary_Customer__r.Name);
                            accBookingMap.put(b.PropStrength__Primary_Customer__c, bl);                             
                        } 
                    }                           
                }        
            }
        } 
        return null;
    }
    
    public PageReference getSearchFollowUps(){ 
        system.debug('Inside getSearchFollowUps method');   
        if(selectedRadioOption == 'Pending')
            getPendingFollowUps();         
        else if(selectedRadioOption == 'Today')
            gettodayFollowUps();        
        else if(selectedRadioOption == 'PendingDLD')
            getpendingDLDCharges();           
        return null;
    } 
    
    ///// To refresh follow up search result   
    public void clearSearchFollowUp(){        
        if(selectedRadioOption != ''  && selectedRadioOption != null && selectedRadioOption == 'Pending'){
            followupsearchByName = '';
            getPendingFollowUps(); 
        } 
        else if(selectedRadioOption != ''  && selectedRadioOption != null && selectedRadioOption == 'Today'){
            followupsearchByName = '';
            gettodayFollowUps();    
        }
        else if(selectedRadioOption != ''  && selectedRadioOption != null && selectedRadioOption == 'PendingDLD'){
            followupsearchByName = '';
            getpendingDLDCharges();
        }  
    }  
    
    public PageReference getRadioPanel(){   
        system.debug('Inside getradiopanel method');              
        if(selectedProjectIdF == null || selectedProjectIdF == '') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select Project'));  
            return null;   
        }
        if(selectedTowerIdF == null || selectedTowerIdF == '') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select Tower')); 
            return null;    
        }        
        radioPanel = true; 
        getSearchFollowUps();
        return null;   
    }
    
    public PageReference Beginning() { 
        pgw = PaginationController.Beginning(pgw);
        getDemands(selectedProjectId, selectedTowerId, selectedRM, searchByName, null, pgw.list_size, pgw.counter);
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        pgw = PaginationController.Previous(pgw);       
        getDemands(selectedProjectId, selectedTowerId, selectedRM, searchByName, null, pgw.list_size, pgw.counter);
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        pgw = PaginationController.Next(pgw);
        getDemands(selectedProjectId, selectedTowerId, selectedRM, searchByName, null, pgw.list_size, pgw.counter);
        return null;
    }
    
    public PageReference End() { //user clicked end
        pgw = PaginationController.End(pgw);
        getDemands(selectedProjectId, selectedTowerId, selectedRM, searchByName, null, pgw.list_size, pgw.counter);
        return null;
    }
    
    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
        return(PaginationController.DisablePrevious(pgw));
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        return(PaginationController.DisableNext(pgw));
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
    
    //// Added by Neha for pagination for Tab 2
    public PageReference BeginningF() { //user clicked beginning
        pgw = PaginationController.Beginning(pgw);
        getDemands(selectedProjectIdF, selectedTowerIdF, selectedRMF, followupsearchByName, selectedRadioOption, pgw.list_size, pgw.counter);
        return null;
    }
    
    public PageReference PreviousF() { //user clicked previous button
        pgw = PaginationController.Previous(pgw);       
        getDemands(selectedProjectIdF, selectedTowerIdF, selectedRMF, followupsearchByName, selectedRadioOption, pgw.list_size, pgw.counter);
        return null;
    }
    
    public PageReference NextF() { //user clicked next button
        pgw = PaginationController.Next(pgw);
        getDemands(selectedProjectIdF, selectedTowerIdF, selectedRMF, followupsearchByName, selectedRadioOption, pgw.list_size, pgw.counter);
        return null;
    }
    
    public PageReference EndF() { //user clicked end
        pgw = PaginationController.End(pgw);
        getDemands(selectedProjectIdF, selectedTowerIdF, selectedRMF, followupsearchByName, selectedRadioOption, pgw.list_size, pgw.counter);
        return null;
    }
    
    public Boolean getDisablePreviousF() { //this will disable the previous and beginning buttons
        return(PaginationController.DisablePrevious(pgw));
    }
    
    public Boolean getDisableNextF() { //this will disable the next and end buttons
        return(PaginationController.DisableNext(pgw));
    }
    
    public Integer getTotal_sizeF() {
        return (PaginationController.getTotal_size(pgw));
    }
    
    public Integer getPageNumberF() {
        return (PaginationController.getPageNumber(pgw));
    }
    
    public Integer getTotalPagesF() {
        return (PaginationController.getTotalPages(pgw));
    } 
}