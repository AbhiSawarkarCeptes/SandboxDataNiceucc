global class X_MasterDataLoadBatch implements Database.Batchable<Sobject>,Database.Stateful,Database.RaisesPlatformEvents{
    global String jobName;
    
    //INTERFACE METHODS
    public static void runTheBatch(String jobName,Integer scope){
        if(String.isBlank(jobName) || scope == null || scope < 1) return;
        Database.executeBatch(new X_MasterDataLoadBatch(jobName),scope);
    }
    
    public static void runTheBatch(String jobName){
        runTheBatch(jobName,1);
    }
    
    //CONSTRUCTOR
    private X_MasterDataLoadBatch(String jobName){
        this.jobName = jobName;
    }
    
    //BATCH METHODS
    public Database.QueryLocator start(Database.BatchableContext dBC){
        return Database.getQueryLocator([SELECT id,Name,Job_Name__c,Unit_Name__c,Xpedeon_Phase_Code__c,Xpedeon_Customer_Name__c,Xpedeon_Customer_Code__c,
                                         Xpedeon_Project_Code__c,Xpedeon_Unit_Type__c,Loaded__c,Booking_Name__c FROM Xpedeon_Data_Dump__c 
                                         WHERE Job_Name__c = :this.jobName AND Loaded__c = FALSE]);
    }
    
    public void execute(Database.BatchableContext dBC,List<Xpedeon_Data_Dump__c> xdds){
        List<Xpedeon_Data_Dump__c> customerMasterXdds = new List<Xpedeon_Data_Dump__c>();
        List<Xpedeon_Data_Dump__c> projectCodeXdds = new List<Xpedeon_Data_Dump__c>();
        List<Xpedeon_Data_Dump__c> unitTypeXdds = new List<Xpedeon_Data_Dump__c>();
        List<Xpedeon_Data_Dump__c> projectCodeUnitXdds = new List<Xpedeon_Data_Dump__c>();
        List<Xpedeon_Data_Dump__c> phaseCodeXdds = new List<Xpedeon_Data_Dump__c>();
        
        System.debug('execute xdds - '+xdds);
        
        for(Xpedeon_Data_Dump__c xdd : xdds){
            System.debug('execute xdd - '+xdd);
            if(xdd.Job_Name__c == 'Customer Master'){
                customerMasterXdds.add(xdd);
            }
            if(xdd.Job_Name__c == 'Project Code'){
                projectCodeXdds.add(xdd);
            }
            if(xdd.Job_Name__c == 'Unit Type'){
                unitTypeXdds.add(xdd);
            }
            if(xdd.Job_Name__c == 'Project Code Unit'){
                projectCodeUnitXdds.add(xdd);
            }
            if(xdd.Job_Name__c == 'Phase Code'){
                phaseCodeXdds.add(xdd);
            }
        }
        System.debug('execute customerMasterXdds - '+customerMasterXdds);
        System.debug('execute projectCodeXdds - '+projectCodeXdds);
        System.debug('execute unitTypeXdds - '+unitTypeXdds);
        System.debug('execute phaseCodeXdds - '+phaseCodeXdds);
        
        if(!customerMasterXdds.isEmpty())customerMasterJob(customerMasterXdds);
        if(!projectCodeXdds.isEmpty()) projectCodeJob(projectCodeXdds);
        if(!unitTypeXdds.isEmpty()) unitTypeJob(unitTypeXdds);
        if(!projectCodeUnitXdds.isEmpty()) projectCodeUnitJob(projectCodeUnitXdds);
        if(!phaseCodeXdds.isEmpty()) phaseCodeJob(phaseCodeXdds);
        
    }
    
    public void finish(Database.BatchableContext dBC){
        
    }
    
    //HELPER METHODS
    void customerMasterJob(List<Xpedeon_Data_Dump__c> xdds){
        //Map<String,Xpedeon_Data_Dump__c> unitNameToXdd = new Map<String,Xpedeon_Data_Dump__c>();
        Map<String,Xpedeon_Data_Dump__c> bookingNameToXdd = new Map<String,Xpedeon_Data_Dump__c>();
        for(Xpedeon_Data_Dump__c xdd : xdds){
            //unitNameToXdd.put(xdd.Unit_Name__c,xdd);
            bookingNameToXdd.put(xdd.Booking_Name__c,xdd);
        }
        
        String logs = '';
        List<Xpedeon_Customer_Master__c> xcms = new List<Xpedeon_Customer_Master__c>();
        //Map<Id,Xpedeon_Data_Dump__c> unitIdToXdd = new Map<Id,Xpedeon_Data_Dump__c>();
        Map<Id,Xpedeon_Data_Dump__c> bookingIdToXdd = new Map<Id,Xpedeon_Data_Dump__c>();
        //for(Booking__c booking : [SELECT id,(SELECT id FROM ApplicantDetails__r WHERE Applicant_Number__c = 'Primary Applicant'),Unit__c,Unit__r.Name,Opportunity__c,Opportunity__r.AccountId FROM Booking__c WHERE Unit__r.Name IN :unitNameToXdd.keySet() AND Status__c = 'Processed']){
        for(Booking__c booking : [SELECT id,Name,(SELECT id FROM ApplicantDetails__r WHERE Applicant_Number__c = 'Primary Applicant'),Unit__c,Unit__r.Name,Opportunity__c,Opportunity__r.AccountId FROM Booking__c WHERE Name IN :bookingNameToXdd.keySet()]){
            //Xpedeon_Data_Dump__c xdd = unitNameToXdd.get(booking.Unit__r.Name);
            Xpedeon_Data_Dump__c xdd = bookingNameToXdd.get(booking.Name);
            
            if(booking.ApplicantDetails__r.size() != 1){
                logs += ('\n'+xdd.Name + ' : ' + booking.Name + ' -> ' + booking.ApplicantDetails__r.size());
                continue;
            }
            
            Xpedeon_Customer_Master__c xcm = new Xpedeon_Customer_Master__c(
                Xpedeon_Customer_Code__c = xdd.Xpedeon_Customer_Code__c,
                Xpedeon_Customer_Name__c = xdd.Xpedeon_Customer_Name__c,
                Applicant_Details__c = booking.ApplicantDetails__r[0].Id,
                Booking__c = booking.Id,
                Unit__c = booking.Unit__c,
                Opportunity__c = booking.Opportunity__c,
                Account__c = booking.Opportunity__r.AccountId
            );
            
            xcms.add(xcm);
            //unitIdToXdd.put(booking.Unit__c,xdd);
            bookingIdToXdd.put(booking.Id,xdd);
        }
        
        if(xcms.isEmpty()) return;
        
        Database.SaveResult[] dbSRs = Database.insert(xcms,false);
        for(Xpedeon_Customer_Master__c xcm : xcms){
            //Xpedeon_Data_Dump__c xdd = unitIdToXdd.get(xcm.Unit__c);
            Xpedeon_Data_Dump__c xdd = bookingIdToXdd.get(xcm.Booking__c);
            xdd.Loaded__c = (xcm.Id != NULL);
        }
        
        Database.update(bookingIdToXdd.values(),false);
        
        //if(String.isBlank(logs)) Database.insert(new Error_Log__c(Message__c = 'X_MasterDataLoadBatch Customer Master load Error Logs : \n\n'+logs),false);
    }
    
    void projectCodeJob(List<Xpedeon_Data_Dump__c> xdds){
        Map<String,Xpedeon_Data_Dump__c> unitNameToXdd = new Map<String,Xpedeon_Data_Dump__c>();
        for(Xpedeon_Data_Dump__c xdd : xdds){
            unitNameToXdd.put(xdd.Unit_Name__c,xdd);
        }
        
        Map<Id,Xpedeon_Data_Dump__c> towerIdToXdd = new Map<Id,Xpedeon_Data_Dump__c>();
        Set<Tower__c> updatedTowers = new Set<Tower__c>();
        for(Unit__c unit : [SELECT id,Name,Tower__c,Tower__r.Xpedeon_Project_Code__c FROM Unit__c WHERE Name IN :unitNameToXdd.keySet()]){
            System.debug('projectCodeJob unit - '+unit.Name+' - '+unit.Tower__c);
            Xpedeon_Data_Dump__c xdd = unitNameToXdd.get(unit.Name);
            Tower__c tower = new Tower__c(Id = unit.Tower__c,Xpedeon_Project_Code__c = xdd.Xpedeon_Project_Code__c);
            towerIdToXdd.put(tower.Id,xdd);
            updatedTowers.add(tower);
        }
        
        if(updatedTowers.isEmpty()) return;
        
        Database.SaveResult[] dbSRs = Database.update(new List<Tower__c>(updatedTowers),false);
        for(Database.SaveResult dbSR : dbSRs){
            Xpedeon_Data_Dump__c xdd = towerIdToXdd.get(dbSR.getId());
            xdd.Loaded__c = dbSR.isSuccess();
            System.debug('xdd - '+xdd);
        }
        System.debug('towerIdToXdd.values().size() - '+towerIdToXdd.values().size());
        System.debug('towerIdToXdd.values() - '+towerIdToXdd.values());
        //Database.update(new List<Xpedeon_Data_Dump__c>(new Set<Xpedeon_Data_Dump__c>(towerIdToXdd.values())),false);
        Database.update(towerIdToXdd.values(),false);
    }
    
    void unitTypeJob(List<Xpedeon_Data_Dump__c> xdds){
        Map<String,Xpedeon_Data_Dump__c> unitNameToXdd = new Map<String,Xpedeon_Data_Dump__c>();
        for(Xpedeon_Data_Dump__c xdd : xdds){
            unitNameToXdd.put(xdd.Unit_Name__c,xdd);
        }
        
        Map<Id,Xpedeon_Data_Dump__c> unitIdToXdd = new Map<Id,Xpedeon_Data_Dump__c>();
        Set<Unit__c> updatedUnits = new Set<Unit__c>();
        for(Unit__c unit : [SELECT id,Name,Xpedeon_Unit_Type__c FROM Unit__c WHERE Name IN :unitNameToXdd.keySet()]){
            Xpedeon_Data_Dump__c xdd = unitNameToXdd.get(unit.Name);
            unit.Xpedeon_Unit_Type__c = xdd.Xpedeon_Unit_Type__c;
            updatedUnits.add(unit);
            unitIdToXdd.put(unit.Id,xdd);
        }
        
        if(updatedUnits.isEmpty()) return;
        
        Database.SaveResult[] dbSRs = Database.update(new List<Unit__c>(updatedUnits),false);
        for(Database.SaveResult dbSR : dbSRs){
            Xpedeon_Data_Dump__c xdd = unitIdToXdd.get(dbSR.getId());
            xdd.Loaded__c = dbSR.isSuccess();
        }
        
        Database.update(unitIdToXdd.values(),false);
    }
    
    void projectCodeUnitJob(List<Xpedeon_Data_Dump__c> xdds){//Project Code in Unit
        Map<String,Xpedeon_Data_Dump__c> unitNameToXdd = new Map<String,Xpedeon_Data_Dump__c>();
        for(Xpedeon_Data_Dump__c xdd : xdds){
            unitNameToXdd.put(xdd.Unit_Name__c,xdd);
        }
        
        Map<Id,Xpedeon_Data_Dump__c> unitIdToXdd = new Map<Id,Xpedeon_Data_Dump__c>();
        Set<Unit__c> updatedUnits = new Set<Unit__c>();
        for(Unit__c unit : [SELECT id,Name,Xpedeon_Phase_Code__c,Xpedeon_Project_Code__c FROM Unit__c WHERE Name IN :unitNameToXdd.keySet()]){
            Xpedeon_Data_Dump__c xdd = unitNameToXdd.get(unit.Name);
            unit.Xpedeon_Project_Code__c = xdd.Xpedeon_Project_Code__c;
            updatedUnits.add(unit);
            unitIdToXdd.put(unit.Id,xdd);
        }
        
        if(updatedUnits.isEmpty()) return;
        
        Database.SaveResult[] dbSRs = Database.update(new List<Unit__c>(updatedUnits),false);
        for(Database.SaveResult dbSR : dbSRs){
            Xpedeon_Data_Dump__c xdd = unitIdToXdd.get(dbSR.getId());
            xdd.Loaded__c = dbSR.isSuccess();
        }
        
        Database.update(unitIdToXdd.values(),false);
    }
    
    void phaseCodeJob(List<Xpedeon_Data_Dump__c> xdds){
        Map<String,Xpedeon_Data_Dump__c> unitNameToXdd = new Map<String,Xpedeon_Data_Dump__c>();
        for(Xpedeon_Data_Dump__c xdd : xdds){
            unitNameToXdd.put(xdd.Unit_Name__c,xdd);
        }
        
        Map<Id,Xpedeon_Data_Dump__c> unitIdToXdd = new Map<Id,Xpedeon_Data_Dump__c>();
        Set<Unit__c> updatedUnits = new Set<Unit__c>();
        for(Unit__c unit : [SELECT id,Name,Xpedeon_Phase_Code__c FROM Unit__c WHERE Name IN :unitNameToXdd.keySet()]){
            Xpedeon_Data_Dump__c xdd = unitNameToXdd.get(unit.Name);
            unit.Xpedeon_Phase_Code__c = xdd.Xpedeon_Phase_Code__c;
            updatedUnits.add(unit);
            unitIdToXdd.put(unit.Id,xdd);
        }
        
        if(updatedUnits.isEmpty()) return;
        
        Database.SaveResult[] dbSRs = Database.update(new List<Unit__c>(updatedUnits),false);
        for(Database.SaveResult dbSR : dbSRs){
            Xpedeon_Data_Dump__c xdd = unitIdToXdd.get(dbSR.getId());
            xdd.Loaded__c = dbSR.isSuccess();
        }
        
        Database.update(unitIdToXdd.values(),false);
    }
}