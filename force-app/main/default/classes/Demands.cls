public with sharing class Demands {
        public Map<String,List<String>> projectTowerMap {get;set;}
        public String projectName {get;set;}
        public String towername {get;set;}
        public PaginationController.PaginationWrapper pgw;
        public Map<Id,List<DemandManagementServices.DemandWrapper>> customerTowerMap {get;set;}
        public Map<Id, DemandManagementServices.CustomerWrapper> customerWrapperMap {get;set;}
        public List<Id> customerList {get;set;}
        public String groupDemandPreviewId {get;set;}
        public String singleDemandPreviewId {get;set;}
        // params for search on top of the screen
        
        public Boolean quickSearch {get;set;}
        public String customerName {get;set;}
        public String unitName {get;set;}
        public String bookingName {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        
        
        // params for search within each tower
        public Unit__c u {get;set;} // dummy variable for the page block table
        public Boolean narrowResults {get;set;}
        public String sCustomer {get;set;}
        public String sUnit {get;set;}
        public String sBookingName {get;set;}
        public Date sStartDate {get;set;}
        public Date sEndDate {get;set;}
        public List<SelectOption> lstStages {get;set;}
        public Id selectedStage {get;set;}
        
        public Boolean batchStatusBool {get;set;}
        public String batchStatus {get;set;}
        Id batchId;
        public Boolean pollerBool {get;set;}
        
        public Demands() {
            getAllDemands();
            
            quickSearch = false;
            customerName = '';
            unitName = '';
            startDate = null;
            endDate = null;
            batchStatusBool = false;
            pollerBool = false;
            narrowResults =false;
            sCustomer = '';
            sUnit = '';
            sBookingName = '';
            sStartDate = null;
            sEndDate = null;
            selectedStage = null;
            u = new Unit__c();
            pgw = new PaginationController.PaginationWrapper();
            pgw.list_size = 100;
            pgw.counter = 0;
            pgw.total_size = 1000;
        }
        
        
        public void getAllDemands() {
            // this will get the list of all the project and the tower names under which we have pending demands to be raised        
            projectTowerMap = DemandManagementServices.getAllPendingDemands();
            System.debug('get all demands:' + projecttowermap);
            List<String> tt = new List<String>();
        }
        
        public void getCustomersTowerWise() {
            
            customerTowerMap = new Map<Id, List<DemandManagementServices.DemandWrapper>>();
            customerList = new List<Id>();
            List<Id> customerListTemp = new List<Id>();
            customerWrapperMap = new Map<Id, DemandManagementServices.CustomerWrapper>();
            towerName = Apexpages.currentPage().getParameters().get('towerName');
            projectName = Apexpages.currentPage().getParameters().get('projectName');
            System.debug('Tower Name in get customers : ' + towerName + projectName);
            pgw = new PaginationController.PaginationWrapper();
            pgw.list_size = 100;
            pgw.counter = 0;
            customerTowerMap = DemandManagementServices.searchAllPendingDemandsWithGrouping(towerName, projectName, pgw.list_size, pgw.counter); 
            System.debug('customerTowerMap ::: ' + customerTowerMap);
            customerWrapperMap = DemandManagementServices.getCustomerWrapper(customerTowerMap.keySet());
            for(Id custId : customerWrapperMap.keySet()){
                customerListTemp.add(custId);
            }
            customerList.addAll(customerListTemp);
            System.debug('Customer Tower List:' + customerList);
            System.debug('customerWrapperMap:::: ' + customerWrapperMap);
            pgw.total_size = 1000;
            
            quickSearch = false;
            customerName = '';
            unitName = '';
            startDate = null;
            endDate = null;
            
            narrowResults =false;
            sCustomer = '';
            sUnit = '';
            sBookingName = '';
            sStartDate = null;
            sEndDate = null;
            selectedStage = null;
            
            getStagesForTower();
        }
        
        public PageReference showPreview() {
            System.debug('demand preview clicked for unit:' + groupDemandPreviewId); 
            System.debug('demand preview clicked for milestone:' + singleDemandPreviewId);  
            PageReference pageRef = new PageReference('/apex/DemandViewNew');
            pageRef.getParameters().put('mode','preview');
            pageRef.getParameters().put('letterHead','1');
            pageRef.getParameters().put('previewId',groupDemandPreviewId);
            pageRef.getParameters().put('invoiceNumber','NOT GENERATED');
          //  pageRef.getParameters().put('isRaiseDemanddashboard', 'true');
            if(singleDemandPreviewId != null && String.isNotBlank(singleDemandPreviewId)) {
                // user wants to raise demand for a single milestone within a group of milestones which are due
                pageRef.getParameters().put('forMilestone',singleDemandPreviewId);
            } 
            return pageRef;
        }
        
        public void raiseGroupDemand() {
            System.debug('raise group demand clicked for unit:' + groupDemandPreviewId);    
            Set<Id> groupDemandId = new Set<Id>();
            groupDemandId.add(groupDemandPreviewId);
            batchId = DemandManagementServices.raiseGroupDemandKickoffBatch(groupDemandId);
            batchStatusBool = true;
            checkBatchStatus();
        }
        
        public void raisePerMilestoneDemand() {
            System.debug('raise per milestone demand clicked for:' + groupDemandPreviewId + ':for milestone:' + singleDemandPreviewId);     
            Map<Id, List<Id>> unitMilestoneMap = new Map<Id, List<Id>>();
            List<Id> tempList = new List<Id>();
            tempList.add(singleDemandPreviewId);
            unitMilestoneMap.put(groupDemandPreviewId, tempList);
            batchId = DemandManagementServices.raisePerMilestoneDemandKickoffBatch(unitMilestoneMap);
            batchStatusBool = true;
            checkBatchStatus();
        }
        
        public void raiseMultipleDemands() {
            Set<Id> groupDemandId = new Set<Id>();
            Map<Id, List<Id>> unitMilestoneMap = new Map<Id, List<Id>>();
            for(Id unit: CustomerTowerMap.keySet()) {
                if(customerWrapperMap.containsKey(unit)) {
                    if(customerWrapperMap.get(unit).groupSelect) {
                        groupDemandId.add(unit);
                    }
                }
            }
            if(!groupDemandId.isEmpty() && groupDemandId.size() >0 ) {
                groupDemandId.add(groupDemandPreviewId);
                batchId = DemandManagementServices.raiseGroupDemandKickoffBatch(groupDemandId);                
                batchStatusBool = true;
                checkBatchStatus();
            } else {
                // check if per milestone demands were selected
                for(Id unit: CustomerTowerMap.keySet()) {
                    for(DemandManagementServices.demandWrapper d : CustomerTowerMap.get(unit)){
                        if(d.perMilestoneSelect) {
                            if(unitMilestoneMap.containsKey(unit)) {
                                List<Id> tList = new List<Id>();
                                tList.addAll(unitMilestoneMap.get(unit));
                                tList.add(d.pm.Id);
                                unitMilestoneMap.put(unit, tList);
                            }
                            else {
                                List<Id> tempList = new List<Id>();
                                tempList.add(d.pm.Id);
                                unitMilestoneMap.put(unit, tempList);
                            }
                        }
                    }
                }
                if(!unitMilestoneMap.isEmpty() && unitMilestoneMap.size() >0) {
                    batchId = DemandManagementServices.raisePerMilestoneDemandKickoffBatch(unitMilestoneMap);
                    batchStatusBool = true;
                    checkBatchStatus();
                }
            }
            if(groupDemandId.isEmpty()  && unitMilestoneMap.isEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No customers were selected.Please select the customers for raising demands'));
            }
        }
        
        public void checkBatchStatus() {
            AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: batchId];
            batchStatus = job.Status;
            if(batchStatus == 'Completed') {
                pollerBool = false;
                batchStatusBool = false;
                getNextDemands();
            } else {
                pollerBool = true;
            }
        }
        
        public void narrowResults() {
            narrowResults = true;
            System.debug('unit in narrow results::::' + sCustomer + '::' + sUnit + '::' + sBookingName + '::' + sStartDate + '::' +sEndDate);
            customerTowerMap = new Map<Id,List<DemandManagementServices.DemandWrapper>>();
            customerTowerMap = DemandManagementServices.searchSpecificDemands(towerName, projectName, sCustomer, sUnit, sBookingName, sStartDate, sEndDate, selectedStage, null); 
            customerList = new List<Id>();
            List<Id> customerListTemp = new List<Id>();
            customerWrapperMap = new Map<Id, DemandManagementServices.CustomerWrapper>();
            customerWrapperMap = DemandManagementServices.getCustomerWrapper(customerTowerMap.keySet());
            for(Id custId : customerWrapperMap.keySet()){
                customerListTemp.add(custId);
            }
            customerList.addAll(customerListTemp);
            System.debug('Inside narrowResults method customerWrapperMap::: ' + customerWrapperMap);
        }
        
        public void quickSearch() {
            // reinitalize the narrow results to blank
            narrowResults =false;
            sCustomer = '';
            sUnit = '';
            sBookingName = '';
            sStartDate = null;
            sEndDate = null;
            selectedStage = null;
            lstStages = new List<SelectOption>();
            
            towerName = '';
            projectName = '';
            
            // set quick search flag
            quickSearch = true;
            
            System.debug('quickSearch:' + customerName + ':' + unitName + ':'+ bookingName + ':' + startDate + ':' +endDate);
            customerTowerMap = new Map<Id,List<DemandManagementServices.DemandWrapper>>();
            customerTowerMap = DemandManagementServices.searchSpecificDemands(towerName, projectName, customerName, unitName,bookingName, startDate, endDate, selectedStage, null); 
            customerList = new List<Id>();
            List<Id> customerListTemp = new List<Id>();
            customerWrapperMap = new Map<Id, DemandManagementServices.CustomerWrapper>();
            customerWrapperMap = DemandManagementServices.getCustomerWrapper(customerTowerMap.keySet());
            for(Id custId : customerWrapperMap.keySet()){
                customerListTemp.add(custId);
            }
            customerList.addAll(customerListTemp);
        }
        
        public void getStagesForTower() {
            list<Project_Construction_Stages__c> pclist =  [Select Id, Name from Project_Construction_Stages__c where Project__r.Name = : projectName and tower__r.Name = : towerName order by Sequence_No__c asc];
            lstStages = new List<SelectOption>();
            if(pclist != null && !pcList.isEmpty()) {
                lstStages.add(new SelectOption('', '--None--'));
                for(Project_Construction_Stages__c p : pclist) {
                    lstStages.add(new SelectOption(p.Id, p.Name));
                }
            }
            System.debug('lst: stages:' + lstStages);
        }
        
        public void getNextDemands(){
            customerTowerMap = new Map<Id, List<DemandManagementServices.DemandWrapper>>();
            customerList = new List<Id>();
            List<Id> customerListTemp = new List<Id>();
            customerTowerMap = DemandManagementServices.searchAllPendingDemandsWithGrouping(towerName, projectName, pgw.list_size, pgw.counter); 
            System.debug('getNextDemands method customerTowerMap:::: ' + customerTowerMap);
            customerWrapperMap = new Map<Id, DemandManagementServices.CustomerWrapper>();
            customerWrapperMap = DemandManagementServices.getCustomerWrapper(customerTowerMap.keySet());
            for(Id custId : customerWrapperMap.keySet()){
                customerListTemp.add(custId);
            }
            customerList.addAll(customerListTemp);
        }
        
        public PageReference Beginning() { //user clicked beginning
            pgw= PaginationController.Beginning(pgw);
            getNextDemands();
            return null;
        }
        
        public PageReference Previous() { //user clicked previous button
            pgw = PaginationController.Previous(pgw);
            getNextDemands();
            return null;
        }
        
        public PageReference Next() { //user clicked next button
            pgw = PaginationController.Next(pgw);
            getNextDemands();
            return null;
        }
        
        public PageReference End() { //user clicked end
            system.debug('PGW:' + pgw);
            pgw = PaginationController.End(pgw);
            getNextDemands();
            return null;
        }
        
        public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
            system.debug('PGW:' + pgw);
            return(PaginationController.DisablePrevious(pgw));
        }
        
        public Boolean getDisableNext() { //this will disable the next and end buttons
            system.debug('PGW:' + pgw);
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
    }