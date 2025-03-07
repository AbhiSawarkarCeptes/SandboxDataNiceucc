public with sharing class CreateQuote {
    public Unit__c u {get; set;}
    public Opportunity o {get; set;}
    public Quotation__c q {get;set;}
    public Id unitId {get;set;}
    public Id oppId {get; set;}
    public Project__c proj {get; set;}
    public Cluster__c cluster {get; set;} // Added by Neha on 08/01/2019
    public Id clusterId{get;set;}
    public String quoteValidity {get;set;}
    public String quoteDate {get;set;}
    public Boolean disableGenerateQuote {get;set;} 
    public String quoteFor {get;set;}
    public boolean unitError {get;set;}
    public boolean oppError {get;set;}
    public List<Payment_Plan__c> payPlanList {get;set;}
    public list<SelectOption> lstPlans {get;set;}
    public String selectedPlan {get;set;}
    public Map<String, Decimal> additionalCarparks {get;set;}
    public Map<String,Decimal> earmarkedCP {get;set;}
    public Map<String, String> carParkFieldsMapEM {get;set;}
    public Map<String, String> carParkFieldsMapEM1 {get;set;}
    public Map<String, String> carParkFieldsMap {get;set;}
    public Map<String, String> carParkFieldsMap1 {get;set;}
    public Map<String, decimal> carParkCharges {get; set;}
    public Decimal additionalCarParkCharge {get;set;}
    public Decimal earmarkedCPCharges {get;set;}
    public Boolean isSubventionPlan{get;set;}
    public Boolean isChangePlan{get;set;}
    public Map<String, Boolean> chargeDifferenceMap {get;set;}
    public boolean isContinue{get;set;}
    public string selectedPlanName{get;set;}
    public Boolean editScheduleMode {get;set;}
    public List<InventoryCostServices.PlanDetailWrapper> payplanDetails {get;set;}
    public Boolean validationError {get;set;} 
    public Boolean scheduleEdited {get;set;}
    public String actionType {get;set;}
    public Integer rowNumber {get;set;}
    public Map<Integer, List<PrintChargesWrapper>> printChargesMap {get;set;}
    public Map<Integer, PrintTotalsWrapper> printTotalsMap {get;set;}
    public boolean earParkingError{get;set;}
    public boolean addParkingError{get;set;}
    public boolean discountError{get;set;}
    public boolean discountError2{get;set;}
    public boolean discountError3{get;set;}
    public boolean discountError4{get;set;}
    
    public Decimal OriginalPlanNPV {get;set;}
    public Decimal OriginalNPVPSF {get;set;}
    public Decimal UpdatedPlanNPV {get;set;}
    public Decimal UpdatedNPVPSF {get;set;}
    public Decimal NPVDiffLumpsum {get;set;}
    public Decimal NPVDiffPSF {get;set;}
    
    public String SOriginalPlanNPV {get;set;}
    public String SOriginalNPVPSF {get;set;}
    public String SUpdatedPlanNPV {get;set;}
    public String SUpdatedNPVPSF {get;set;}
    public String SNPVDiffLumpsum {get;set;}
    public String SNPVDiffPSF {get;set;}
    
    public boolean isEditablePlan {get;set;}
    // List of rates that are set as editable at the project level
    public List<String> editableRates {get; set;}
    // Represents the list of rates where currently the edit icon is clicked, this is for opening the rates in input mode
    public Map<String, Boolean> rateSelectedForEditMap {get;set;}
    // Represents the list of rates where the rates have been edited by user, this is for printing the new rates to compare the old vs new
    public Map<String, Boolean> rateEditedMap {get;set;}
    // contains the rate list record to show on UI for editing
    public Map<String, Rate_List__c> rateListForEditing {get;set;}
    // original rate list for reference
    public Map<String, Rate_List__c> rateListOriginal {get;set;}
    // this has the edited rates, we pass this to get charges so that new rates are calculated based on the new PSFs
    public Map<String, Decimal> rateListMap;
    
    public Map<String, List<String>> chargeBucketMap {get;set;}
    public Integer numberOfChargeBuckets {get;set;}
    public Map<String, Decimal> allChargesMap {get; set;}
    public Map<String, String> allChargesMapFormatted {get; set;}
    public Decimal totalDiscount {get;set;}
    
    public Map<String, Decimal> allChargesMapOriginal {get; set;}
    public Map<String, String> allChargesMapOriginalFormatted {get; set;}
    public List<Discount__c> dList {get;set;}
    public boolean isNPVdif {get;set;} 
    public boolean isNPVDiscountApplied {get;set;}
    public boolean isDiscountErrorOnApply {get;set;}
    public boolean isConfirmed {get;set;}
    
    public CreateQuote()
    {  
        
        q = new Quotation__c();  
        for(Integer i = 1;i <=5; i++) {
            q.put('Car_Park_Charge_'+i+'__c', 0);
        }      
        oppId = null;
        unitId = null;
        unitError = false;
        oppError = false;
        additionalCarparks = new Map<String, Decimal>();
        earmarkedCP = new Map<String, Decimal>();
        carParkFieldsMapEM = new Map<String, String>();
        carParkFieldsMapEM1 = new Map<String, String>();
        carParkFieldsMap = new Map<String, String>();
        carParkFieldsMap1 = new Map<String, String>();
        carParkCharges = new Map<String, Decimal>();
        lstPlans = new List<SelectOption>();
        additionalCarParkCharge=0;
        earmarkedCPCharges = -1;
        editableRates = new List<String>();
        rateListForEditing = new Map<String, Rate_List__c>();
        rateListOriginal = new Map<String, Rate_List__c>();
        rateSelectedForEditMap = new Map<String, Boolean>();
        rateEditedMap = new Map<String, Boolean>();
        rateListMap = new Map<String, Decimal>();
        isSubventionPlan = false;
        isChangePlan = false;
        allChargesMap = new Map<String,Decimal>();
        allChargesMapFormatted = new Map<String,String>();
        
        allChargesMapOriginal = new Map<String,Decimal>();
        allChargesMapOriginalFormatted = new Map<String,String>();
        chargeDifferenceMap = new Map<String, Boolean>();
        totalDiscount = 0;
        numberOfChargeBuckets = 0;
        dList = new List<Discount__c>();
        isContinue = false;
        selectedPlanName = '';
        editScheduleMode = false;
        payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
        validationError = false;
        scheduleEdited = false;
        earParkingError = false;
        addParkingError = false;
        discountError = false;
        discountError2 = false;
        discountError3 = false;
        discountError4 = false;
        
        OriginalPlanNPV = 0.0;
        UpdatedPlanNPV = 0.0;
        OriginalNPVPSF = 0.0;
        UpdatedNPVPSF = 0.0;
        NPVDiffLumpsum = 0.0;
        NPVDiffPSF = 0.0;
        // string values of the NPV fields for displaying Rs /-
        SOriginalPlanNPV = '';
        SOriginalNPVPSF = '';
        SUpdatedPlanNPV = '';
        SUpdatedNPVPSF = '';
        SNPVDiffLumpsum = '';
        SNPVDiffPSF = '';
        isNPVdif = false;
        isNPVDiscountApplied = false;  
        isDiscountErrorOnApply = false;
        isConfirmed = false;
        
        if(ApexPages.currentPage().getParameters().containsKey('id'))       
            unitId = (Id)ApexPages.currentPage().getParameters().get('id');    
        if(ApexPages.currentPage().getParameters().containsKey('oppId'))  
            if(ApexPages.currentPage().getParameters().get('oppId') != '')      
            oppId = (Id)ApexPages.currentPage().getParameters().get('oppId'); 
        if(unitId != null) {
            List<String> unitErrorMsg = preCheckUnit(unitId);
            if(unitError) {
                for(String e : unitErrorMsg) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e));
                }
            } else {
                u = InventoryCostServices.getUnitDetails(unitId);
                proj = InventoryCostServices.getProjectDetails(unitId);
                cluster = InventoryCostServices.getClusterDetails(unitId); // Added by Neha on 08/01/2019
                
                System.debug('project:' + proj);
                chargeBucketMap = InventoryCostServices.getChargeBuckets(unitId); 
                System.debug('chargeBucketMap'+chargeBucketMap);
                numberOfChargeBuckets = chargeBucketMap.size();
                if(u != null) {
                    q.Unit__c = u.Id;
                    clusterId = u.Tower__r.Cluster__r.id;
                }
                if(proj != null) {
                    // default to 10 days
                    if(proj.Quotation_Validity__c == null)
                        proj.Quotation_Validity__c = 10;
                    quoteValidity = (System.today().addDays(Integer.valueOf(proj.Quotation_Validity__c))).format();
                    quoteDate = System.today().format();
                }
                payPlanList = InventoryCostServices.getPlanList(u); // u.Floor__c added by Neha on 6/2/19
                if(payPlanList != null && !payplanList.isEmpty()) {
                    for(Payment_Plan__c p : payPlanList) {
                        lstPlans.add(new SelectOption(p.Id, p.Name));
                    }
                    
                }
                carParkCharges = InventoryCostServices.getCarparkCharges(unitId);
                earmarkedCP = InventoryCostServices.getEarmarkedCarparks(unitId);
                if(earmarkedCP != null && earmarkedCP.size() > 0) {
                    Integer i =1;
                    for(String s : earmarkedCP.keyset()) {
                        q.put('Earmarked_Type_'+i+'__c', s);
                        q.put('Earmarked_Count_'+i+'__c', earmarkedCP.get(s));
                        carParkFieldsMapEM.put(s, 'Earmarked_Count_'+i+'__c');
                        q.put('Earmarked_Car_Park_Charge_'+i+'__c', carParkCharges.get(s));
                        carParkFieldsMapEM1.put(s,  'Earmarked_Car_Park_Charge_'+i+'__c');
                        i++;
                    }       
                }
                // additional car parks to chose from
                additionalCarparks = InventoryCostServices.getAdditionalCarParks(proj.Id,clusterId);
                
                if(!additionalCarParks.isEmpty()) {
                    Integer i = 1;
                    for(String s: additionalCarParks.keySet()) {
                        carParkFieldsMap.put(s, 'Car_Park_Count_'+i+'__c');
                        q.put('Car_Park_Type_'+i+'__c', s);
                        q.put('Car_Park_Charge_'+i+'__c', carParkCharges.get(s));
                        carParkFieldsMap1.put(s,  'Car_Park_Charge_'+i+'__c');
                        i++;
                        
                    }
                }
                
                // list of all charges that are marked as editable/overridable at the project charge level. used as a map for iteration
                editableRates = InventoryCostServices.getEditableRates(unitId);
                rateListMap = InventoryCostServices.getRateList(unitId);
                // this is needed for tying the rate list fields to the VF page, it returns the rate list record per charge
                rateListForEditing = InventoryCostServices.getRateListForEditing(unitId);
                rateListOriginal = rateListForEditing.deepClone();
                System.debug('rateListforEditing:' + rateListForEditing);
                System.debug('editableRates:' + editableRates);
                if(editableRates != null && !editableRates.isEmpty()) {
                    for(String s: editableRates) {
                        rateSelectedForEditMap.put(s, false);
                        rateEditedMap.put(s,false);
                    }
                }
                
                
                if(cluster != null){
                    dList = InventoryCostServices.getClusterLevelDiscounts(proj.Id, cluster.Id); // Changed by Neha on 08/01/2019 to get Cluster level discount
                }
            }
        }
        
        if(oppId != null) {
            List<String> oppErrorMsg =  preCheckOpportunity(oppId);
            if(oppError) {
                for(String e : oppErrorMsg) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e));
                }
            } else {
                o = [Select Id, Name, Account.Name, StageName, Sales_Manager__c from Opportunity where Id = :oppId];
                q.Opportunity__c = o.Id;
                quoteFor = o.Name;
            }
        }     
        System.debug('Quotation:' + q);   
    }
    public PageReference checkOppValidation(){ 
        Opportunity[] oppList = [select id,Unit__r.Unit_Status__c, Booking__r.Status__c from Opportunity where id =:q.Opportunity__c and  (unit__r.Unit_Status__c = 'Available' or unit__c = null) and (Booking__r.status__c = 'Cancelled' or Booking__c = null) ];
        if (oppList.isEmpty()) {            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Unit associated with this Opp is not available');
            ApexPages.addMessage(myMsg);
            disableGenerateQuote = true;            
        }  else {
            disableGenerateQuote = false; 
        }
        return null;
    }
 
    public PageReference startQuote() {
        lstPlans = new List<SelectOption>();
        unitError = false;
        oppError = false;
        pageReference pRef = ApexPages.currentPage();
        pRef.getParameters().put('oppId',oppId);
        pRef.getParameters().put('id',unitId);
        unitId = q.Unit__c;
        oppId = q.Opportunity__c;
        if(unitId != null) {
            List<String> unitErrorMsg = preCheckUnit(unitId);
            if(unitError) {
                for(String e : unitErrorMsg) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e));
                }
            } else {
                u = InventoryCostServices.getUnitDetails(unitId);
                proj = InventoryCostServices.getProjectDetails(unitId); 
                System.debug('project:' + proj);
                if(u != null) {
                    q.Unit__c = u.Id;
                    clusterId = u.Tower__r.Cluster__r.id;
                }
                if(proj != null) {
                    // default to 10 days
                    if(proj.Quotation_Validity__c == null)
                        proj.Quotation_Validity__c = 10;
                    quoteValidity = (System.today().addDays(Integer.valueOf(proj.Quotation_Validity__c))).format();
                    quoteDate = System.today().format();
                }
                payPlanList = InventoryCostServices.getPlanList(u); // u.Floor__c added by Neha on 6/2/19
                if(payPlanList != null && !payplanList.isEmpty()) {
                    for(Payment_Plan__c p : payPlanList) {
                        lstPlans.add(new SelectOption(p.Id, p.Name));
                    }
                }
            }
        }
        
        if(oppId != null) {
            List<String> oppErrorMsg =  preCheckOpportunity(oppId);
            if(oppError) {
                for(String e : oppErrorMsg) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e));
                }
            } else {
                o = [Select Id, Name, Account.Name, StageName, Sales_Manager__c from Opportunity where Id = :oppId];
                q.Opportunity__c = o.Id;
                quoteFor = o.Name;
            }
        } 
        return pRef;
    }
    public PageReference cancel() {
        pageReference pRef = ApexPages.currentPage();
        pRef.setRedirect(true);
        System.debug('pageref:' + pRef);
        return pRef;
    }
    public  List<String> preCheckUnit(Id unitId) {
        List<String> errList = new List<String>();
        return errList;
        
    }
    public  List<String> preCheckOpportunity(Id oppId) {
        List<String> errList = new List<String>();
        return errList;
    }
    public PageReference modifyCarPark() {
        // reset the charges everytime and calculate again
        earmarkedCPCharges =0;
        earParkingError = false;
        Map<String, decimal> carParkCharges = InventoryCostServices.getCarparkCharges(unitId);
        if(carparkCharges != null && carParkFieldsMap != null) {
            for(String s: carParkFieldsMapEM.keySet()) {
                if(q.get(carParkFieldsMapEM.get(s))  != null ) {
                    if((Decimal)(q.get(carParkFieldsMapEM.get(s))) > earmarkedCP.get(s)) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, s + ':car park count cannot be increased beyond what is already provisioned')); 
                        earParkingError = true;
                        return null;
                    }
                    earmarkedCPCharges += (Decimal)(q.get(carParkFieldsMapEM.get(s))) * (Decimal)(q.get(carParkFieldsMapEM1.get(s)));
                }
            }
        }
        System.debug('Earmarked Car Park Charges:' + earmarkedCPCharges);
        // pass the earmarked car park charges to get all charges, if earmarked prices is not set, take the original values from the getcarpark charges method
        if(!rateListMap.isEmpty())
            allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,0,rateListMap);
        else
            allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,0,null);
        // when CV is being changed then reset the discounts to 0 calculate the new CV and then apply Disocunts again.
        applyDiscounts();
        if(allChargesMap != null && !allChargesMap.isEmpty()) {
            for(String s: allchargesMap.keyset()) {
                allChargesMapFormatted.put(s, InventoryCostServices.INFormat(allChargesMap.get(s)));
                if(allchargesMap.get(s) != allChargesMapOriginal.get(s)){
                    system.debug('allChargesMapOriginal'+allChargesMapOriginal);
                    chargeDifferenceMap.put(s, true);
                }else{
                    system.debug('allChargesMapOriginal'+allChargesMapOriginal);
                    chargeDifferenceMap.put(s, false);}
            }
        }
        return null;
    }
    
    public PageReference addCarPark() {
        // reset the charges everytime and calculate again
        additionalCarParkCharge =0;
        addParkingError = false;
        Map<String, decimal> carParkCharges = InventoryCostServices.getCarparkCharges(unitId);
        if(carparkCharges != null && carParkFieldsMap != null) {
            for(String s: carParkFieldsMap.keySet()) {
                if(q.get(carParkFieldsMap.get(s))  != null ) {
                    if((Decimal)(q.get(carParkFieldsMap.get(s))) > additionalcarParks.get(s)) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, s + ':car parks selected exceeds the available parking. please select within the available limit')); 
                        addParkingError = true;
                        return null;
                    }
                    additionalCarParkCharge += (Decimal)(q.get(carParkFieldsMap1.get(s))) * (Decimal)(q.get(carParkFieldsMap.get(s)));
                }
            }
        }
        System.debug('Additional Car Park Charges:' + additionalCarParkCharge);
        if(!rateListMap.isEmpty())
            allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,0,rateListMap);
        else
            allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,0,null);
        applyDiscounts();
        if(allChargesMap != null && !allChargesMap.isEmpty()) {
            for(String s: allchargesMap.keyset()) {
                allChargesMapFormatted.put(s, InventoryCostServices.INFormat(allChargesMap.get(s)));
                if(allchargesMap.get(s) != allChargesMapOriginal.get(s)){
                    system.debug('allChargesMapOriginal'+allChargesMapOriginal);
                    chargeDifferenceMap.put(s, true);
                }else{
                    system.debug('allChargesMapOriginal'+allChargesMapOriginal);
                    chargeDifferenceMap.put(s, false);}
            }
        }
        return null;
    }
    public void openForEdit(){
        String editedRate  = Apexpages.currentPage().getParameters().get('editedRate');
        System.debug('edited rate:' + editedRate);
        rateSelectedForEditMap.put(editedRate, true);
    }
    public void applyNewRates(){
        if(editableRates != null && !editableRates.isEmpty()) {
            for(String s: editableRates) {
                // if this rate was in edit mode on apply changes, we assume this rate was edited and mark the same in a map
                if(rateSelectedForEditMap.get(s))
                    rateEditedMap.put(s, true);
                // on apply changes, make the edit mode back to false
                rateSelectedForEditMap.put(s, false);
                
            }
            
            for(String s: rateListForEditing.keySet()) {
                if(rateListForEditing.get(s).PSF_rate__c != null) {
                    rateListMap.put(s+'PSF', rateListForEditing.get(s).PSF_rate__c);
                    rateListMap.put(s, rateListForEditing.get(s).PSF_rate__c * u.Chargeable_Area__c);
                }
            }
        }
        allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,0,rateListMap);
        applyDiscounts();
        if(allChargesMap != null && !allChargesMap.isEmpty()) {
            for(String s: allchargesMap.keyset()) {
                allChargesMapFormatted.put(s, InventoryCostServices.INFormat(allChargesMap.get(s)));
                if(allchargesMap.get(s) != allChargesMapOriginal.get(s))
                    chargeDifferenceMap.put(s, true);
                else
                    chargeDifferenceMap.put(s, false);
            }
        }
    }
    public void planSelect(){
        System.debug('planId:' + selectedPlan);
        Boolean isValid = (selectedPlan InstanceOf ID) ? true : false;
        If(isValid) {
            /////////////// Added By Vikas For subvention payment Plan 
            ///////////// First checking is thr selected plan is subvention type or not.
            Payment_Plan__c pp = [select id,name,Payment_Plan_Editable__c,Subvention_Base_Rate__c,Subvention_Payment_Plan__c from Payment_Plan__c where id =: selectedPlan];
            if(pp != null){
                /////////////////////// If Payment Plan is subvention then adding base rate value from payment plan
                selectedPlanName = pp.name;
                isEditablePlan = pp.Payment_Plan_Editable__c;
                if(pp.Subvention_Payment_Plan__c){
                    rateListForEditing = InventoryCostServices.getRateListForEditing(unitId);
                    
                    for(String s: rateListForEditing.keySet()) {
                        if(rateListForEditing.get(s).PSF_rate__c != null) {
                            if(s.equals('Basic')){
                                rateListForEditing.get(s).PSF_rate__c = pp.Subvention_Base_Rate__c;
                            }
                            rateListMap.put(s+'PSF', rateListForEditing.get(s).PSF_rate__c);
                            rateListMap.put(s, rateListForEditing.get(s).PSF_rate__c * u.Chargeable_Area__c);
                        }
                    }
                    rateListOriginal = rateListForEditing.deepClone();
                    isSubventionPlan = true;
                    isChangePlan = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'You have selected Subvention payment plan, base rates will be reset and the page will render with subvention rates.'));
                }
                else{
                    ////////////////// If change payment plan from Subvention to Normal then roll back base rate value from rate list
                    if(isChangePlan) {
                        rateListForEditing = InventoryCostServices.getRateListForEditing(unitId);
                        rateListOriginal = rateListForEditing.deepClone();
                    }
                    
                    for(String s: rateListForEditing.keySet()) {
                        if(rateListForEditing.get(s).PSF_rate__c != null) {
                            rateListMap.put(s+'PSF', rateListForEditing.get(s).PSF_rate__c);
                            rateListMap.put(s, rateListForEditing.get(s).PSF_rate__c * u.Chargeable_Area__c);
                        }
                    }
                    isSubventionPlan = false;
                    isChangePlan = false;
                }
            }
        }
        // recalculate with the new rate list map since the plan has changed, with 0 total discount. On this new AV apply discount if any again
        if(!rateListMap.isEmpty())
            allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,0,rateListMap);
        else
            allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,0,null);
        if(allChargesMap != null && !allChargesMap.isEmpty()) {
            for(String s: allchargesMap.keyset()) {
                allChargesMapFormatted.put(s, InventoryCostServices.INFormat(allChargesMap.get(s)));
            }
        }
        applyDiscounts();
        // initial values as defined in the rate list of the unit, without any additional parking, rate list modifications and discounts
        Map<String,Decimal> rateListMapOriginal = new Map<String,Decimal>();
        for(String s : rateListMap.keySet()) {
            rateListMapOriginal.put(s, rateListMap.get(s));
        }
        for(String s: rateListOriginal.keySet()) {
            if(rateListOriginal.get(s).PSF_rate__c != null) {
                rateListMapOriginal.put(s+'PSF', rateListOriginal.get(s).PSF_rate__c);
                rateListMapOriginal.put(s, rateListOriginal.get(s).PSF_rate__c * u.Chargeable_Area__c);
            } 
        }
        
        System.debug('ratelist map original values:' + rateListMapOriginal);
        allChargesMapOriginal = InventoryCostServices.getAllChargesNew(unitId,-1    ,0,0,rateListMapOriginal);
        System.debug('Original Charges Value:' + allChargesMapOriginal);
        if(allChargesMapOriginal != null && !allChargesMapOriginal.isEmpty()) {
            for(String s: allChargesMapOriginal.keyset()) {
                allChargesMapOriginalFormatted.put(s, InventoryCostServices.INFormat(allChargesMapOriginal.get(s)));
            }
        }
        System.debug('allChargesMap'+allChargesMap);
        if(allChargesMap != null && !allChargesMap.isEmpty()) {
            for(String s: allchargesMap.keyset()) {
                System.debug('all charge orrig : '+allChargesMapOriginal.get(s));
                if(allchargesMap.get(s) != allChargesMapOriginal.get(s))
                    chargeDifferenceMap.put(s, true);
                else
                    chargeDifferenceMap.put(s, false);
            }
            
        }
        
        System.debug('all charge map : '+ allchargesMap.keyset());
        System.debug('chargeDifferenceMap 11'+chargeDifferenceMap);
    }
    public PageReference applyDiscounts() {
        // reset the discount to 0
        totalDiscount = 0;
        // check for all discounts applied and calculate the individual total and overall total discount
        if(dList != null) {
            boolean isAllApplied = false;
            isDiscountErrorOnApply = false;
            for(Discount__c d : dList) {
                if(d.Applied__c) {
                    isAllApplied = true;
                    if(d.Type__c.equalsIgnoreCase('PSF')) {
                        if(d.PSF_AMount__c == null || d.PSF_AMount__c < 0) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, +'Please select a valid PSF Amount')); 
                            d.Applied__c = false;
                            discountError = true;
                            isDiscountErrorOnApply = true;
                            return null;
                        } else {
                            d.Total__c = (d.PSF_AMount__c * u.Chargeable_Area__c).setscale(2, RoundingMode.HALF_UP);
                            totalDiscount +=d.Total__c;
                        }
                    }
                    if(d.Type__c.equalsIgnoreCase('Lumpsum')) {
                        if(d.Lumpsum_AMount__c == null || d.Lumpsum_AMount__c < 0) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, + 'Please select a valid lumpsum Amount')); 
                            d.Applied__c = false;
                            discountError = true;
                            isDiscountErrorOnApply = true;
                            return null;
                        } else {
                            d.Total__c = d.Lumpsum_AMount__c.setscale(2, RoundingMode.HALF_UP);
                            totalDiscount +=d.Total__c;
                        }
                    }
                    if(d.Type__c.equalsIgnoreCase('User Defined') || d.Type__c.equalsIgnoreCase('NPV Discount')) {
                        if(d.PSF_AMount__C != null && d.Lumpsum_AMount__c != null) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, + 'Please enter either a lumpsum or a PSF amount, do not enter both')); 
                            discountError = true;
                            d.Applied__c = false;
                            isDiscountErrorOnApply = true;
                            return null;
                        }
                        if( (d.PSF_AMount__C == null && d.Lumpsum_AMount__c == null) || (d.PSF_AMount__C <= 0 && d.Lumpsum_AMount__c <= 0)) {
                            d.Applied__c = false;
                            discountError = true;
                            isDiscountErrorOnApply = true;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, + 'Please enter either a lumpsum or a PSF amount')); 
                            return null;
                        }
                        if(d.PSF_AMount__C != null && d.PSF_AMount__C != 0)
                            d.Total__c = (d.PSF_AMount__c * u.Chargeable_Area__c).setscale(2, RoundingMode.HALF_UP);
                        else
                            d.Total__c = d.Lumpsum_AMount__c.setscale(2, RoundingMode.HALF_UP);
                        totalDiscount +=d.Total__c;
                    }
                    if(d.Type__c.equalsIgnoreCase('Percentage of Basic')) {
                        if(d.Percentage_Of_AV__c == null || d.Percentage_Of_AV__c < 0) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, + 'Please select a valid percentage')); 
                            d.Applied__c = false;
                            discountError = true;
                            isDiscountErrorOnApply = true;
                            return null;
                        } else {
                            d.Total__c = ((d.Percentage_Of_AV__c * allChargesMap.get('Basic'))/100).setscale(2, RoundingMode.HALF_UP);
                            totalDiscount +=d.Total__c;
                        }
                    }
                }
            }
            
            // for percentage of Agreement discount, apply the other discounts and arrive at the new agreement value, then do a percentage of that AV
            for(Discount__c d : dList) {
                if(d.applied__c) {
                    isAllApplied = true; 
                    if(d.Type__c.equalsIgnoreCase('Percentage')) {
                        if(d.Percentage_Of_AV__c == null || d.Percentage_Of_AV__c < 0) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, + 'Please select a valid percentage')); 
                            discountError = true;
                            d.Applied__c = false;
                            isDiscountErrorOnApply = true;
                            return null;
                        } else {
                            allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,totalDiscount,rateListMap);
                            d.Total__c = ((d.Percentage_Of_AV__c * allChargesMap.get('Agreement Value AMOUNTTOTAL'))/100).setscale(2, RoundingMode.HALF_UP);
                            totalDiscount +=d.Total__c;
                        }
                    }
                }
            }
            
            if(!isAllApplied){
                discountError = false;
            }
        }
        
        // finally recalculate all charges based on the total discount along with the percentage discount if any given.
        allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,totalDiscount,rateListMap);
        if(allChargesMap != null && !allChargesMap.isEmpty()) {
            for(String s: allchargesMap.keyset()) {
                system.debug('S &&&'+s);
                allChargesMapFormatted.put(s, InventoryCostServices.INFormat(allChargesMap.get(s)));
                if(allchargesMap.get(s) != allChargesMapOriginal.get(s))
                    chargeDifferenceMap.put(s, true);
                else
                    chargeDifferenceMap.put(s, false);
            }
        }
        return null;
    }
    
    public void continueMethod(){
        system.debug('inside continueMethod');
        modifyCarPark();
        addCarPark();
        if(!earParkingError && !addParkingError && !discountError){
            isContinue = true;
            payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
            payplanDetails = InventoryCostServices.getPlanDetailsNew(unitId, selectedPlan, allChargesMap);
            OriginalPlanNPV = InventoryCostServices.calculateNPV(payplanDetails, proj.Id);
            OriginalNPVPSF = (OriginalPlanNPV/u.Chargeable_Area__c); //.setscale(0,RoundingMode.HALF_UP);
            SOriginalPlanNPV = InventoryCostServices.INFormatForNPV(OriginalPlanNPV);
            SOriginalNPVPSF = InventoryCostServices.INFormatForNPV(OriginalNPVPSF);
            system.debug('OriginalNPVPSF::: '+OriginalNPVPSF);
            for(InventoryCostServices.PlanDetailWrapper pdw: payPlanDetails) {
                
            }
            printCharges();
        }
    }
    
    public void editSchedule(){
        editScheduleMode = true;
        // remove the grand total line, its not needed for plan editing
        //payPlanDetails.remove(payPlanDetails.size()-1);
    }  
    
    public void cancelEditSchedule(){
        payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
        payplanDetails = InventoryCostServices.getPlanDetailsNew(unitId, selectedPlan, allChargesMap);
        
        for(InventoryCostServices.PlanDetailWrapper pdw: payPlanDetails) {
            
        }
        scheduleEdited = true;
        editScheduleMode = false;
        validationError = false;
        OriginalPlanNPV = 0.0;
        UpdatedPlanNPV = 0.0;
        OriginalNPVPSF = 0.0;
        UpdatedNPVPSF = 0.0;
        NPVDiffLumpsum = 0.0;
        NPVDiffPSF = 0.0;
        SOriginalPlanNPV = '';
        SOriginalNPVPSF = '';
        SUpdatedPlanNPV = '';
        SUpdatedNPVPSF = '';
        SNPVDiffLumpsum = '';
        SNPVDiffPSF = '';
        OriginalPlanNPV = InventoryCostServices.calculateNPV(payplanDetails, proj.Id);
        OriginalNPVPSF = (OriginalPlanNPV/u.Chargeable_Area__c); //.setscale(0,RoundingMode.HALF_UP);
        SOriginalPlanNPV = InventoryCostServices.INFormatForNPV(OriginalPlanNPV);
        SOriginalNPVPSF = InventoryCostServices.INFormatForNPV(OriginalNPVPSF);
        system.debug('OriginalNPVPSF inside cancel edit::: '+OriginalNPVPSF);
        printCharges();
    }
    // action function to add, remove, clone rows for plan editing
    // action related to the +, ++, --
    public void rowModify(){
        if(actionType.equals('add')){
            System.Debug(payPlanDetails[rowNumber]);
            InventoryCostServices.PlanDetailWrapper ppd = new InventoryCostServices.PlanDetailWrapper(new Payment_Plan_Milestones__c(), new Payment_Milestones__c(), '', 0, '', 0,'', '', '', true,true, payPlanDetails[rowNumber].lstConstructionStages, payPlanDetails[rowNumber].fldMap, false);
            payPlanDetails.add(rowNumber+1, ppd);
            payPlanDetails[rowNumber+1].editedRowStyle = 'Edited';
        } else if(actionType.equals('clone')) {
        } else if(actionType.equals('del')) {
            payPlanDetails.remove(rowNumber);
        }
    }
    
    public void updatePlan(){
        Map<String, String> validationResponse = InventoryCostServices.validateEditedPlan(u, selectedPlan, allChargesMap, payPlanDetails);
        system.debug('update method');
        if(validationResponse != null && validationResponse.containsKey('ERROR')) {
            validationError = true;
            for(String s: validationResponse.keyset()) {
                if(!s.equals('ERROR')) {
                    ApexPages.addMessage((new ApexPages.message(ApexPages.severity.FATAL, validationResponse.get(s))));
                }
            }
        } else {
            payPlanDetails = InventoryCostServices.updatePlanDetails(u, selectedPlan, allChargesMap, payPlanDetails);
            //payPlanDetails.remove(payPlanDetails.size()-1);
            /*for(InventoryCostServices.PlanDetailWrapper pd : payPlanDetails){
integer i=0;
system.debug('print payplandetails here:: '+ i++ + ': '+ pd +'tobe paid:: ' +pd.tobePaid);
}*/
            //////////////////// Calcualting NPV here ///////////////////////////////////////
            UpdatedPlanNPV = InventoryCostServices.calculateNPV(payPlanDetails, proj.Id);
            UpdatedNPVPSF = (UpdatedPlanNPV/ u.Chargeable_Area__c); //.setscale(0,RoundingMode.HALF_UP);
            //system.debug('UpdatedPlanNPV::: '+UpdatedPlanNPV);
            //system.debug('OriginalPlanNPV::: '+OriginalPlanNPV);
            NPVDiffLumpsum = OriginalPlanNPV - UpdatedPlanNPV;
            //system.debug('NPVDiffLumpsum ::: '+NPVDiffLumpsum);
            NPVDiffPSF = (NPVDiffLumpsum/ u.Chargeable_Area__c); //.setscale(0,RoundingMode.HALF_UP);
            SUpdatedPlanNPV = InventoryCostServices.INFormatForNPV(UpdatedPlanNPV);
            SUpdatedNPVPSF = InventoryCostServices.INFormatForNPV(UpdatedNPVPSF);
            SNPVDiffLumpsum = InventoryCostServices.INFormatForNPV(NPVDiffLumpsum);
            SNPVDiffPSF = InventoryCostServices.INFormatForNPV(NPVDiffPSF);
            scheduleEdited = true;
            editScheduleMode = true;
            validationError = false;
            printCharges();
        }
    }
    public void confirmEditSchedule(){
        scheduleEdited = true;
        editScheduleMode = false;
        validationError = false;
        printCharges();
        isConfirmed = true;
        if(OriginalPlanNPV != UpdatedPlanNPV)
            isNPVdif = true;
        if(isNPVdif){ 
            Discount__c dis = new Discount__c();
            dis.Type__c = 'NPV Discount';
            dis.Start_Date__c = system.today();
            dis.Reason__c = 'NPV Discount';
            dis.Project__c = proj.id;
            dis.Editable__c = true;
            dList.add(dis);
        }
    }
    
    public pageReference modifyNPV(){
        isNPVDiscountApplied = false;
        applyDiscounts();
        if(!isDiscountErrorOnApply){
            isNPVDiscountApplied = true;
            //payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
            //payplanDetails = InventoryCostServices.getPlanDetailsNew(unitId, selectedPlan, allChargesMap);
            payplanDetails = InventoryCostServices.updatePlanDetails(u, selectedPlan, allChargesMap, payPlanDetails);
            //payPlanDetails.remove(payPlanDetails.size()-1);
            printCharges();
        }    
        return null;
    }
    
    public void printCharges() {
        printChargesMap = new Map<Integer, List<PrintChargesWrapper>>();
        printTotalsMap = new Map<Integer, PrintTotalsWrapper>();
        Decimal overallAmt = 0;
        Decimal overallTax1 = 0;
        Decimal overallTax2 = 0;
        Integer chargeCount = 1;
        Integer j = 1;
        if(payPlanDetails != null) {
            for(InventoryCostServices.PlanDetailWrapper pdw: payPlanDetails) {
                List<PrintChargesWrapper> temp = new List<PrintChargesWrapper>();
                PrintTotalsWrapper temp1 = new PrintTotalsWrapper();
                if(pdw.pm != null) {
                    
                    for(Integer i =1 ; i <=25; i++) {
                        System.debug('milestone charge:' + i + ':' + pdw.pm.get('Charge' + i+'Name__c'));
                        PrintChargesWrapper p = new PrintChargesWrapper();
                        if((String)pdw.pm.get('Charge' + i+'Name__c') != null && String.isNotBlank( (String)pdw.pm.get('Charge' + i+'Name__c') )) {
                            System.debug('milestone charge inside null check:' + i + ':' + pdw.pm.get('Charge' + i+'Name__c'));
                            p.chargeName = (String)pdw.pm.get('Charge' + i+'Name__c');
                            if(pdw.pm.get('Charge' +i + 'Percentage__c') != null)
                                p.percentage = String.valueOf((Decimal)pdw.pm.get('Charge' +i + 'Percentage__c')) + ' %';
                            else
                                p.percentage = '';
                            if(pdw.pm.get('C' + i + '_Amount__c') != null) {
                                p.Amount = InventoryCostServices.InFormat((Decimal)pdw.pm.get('C' + i + '_Amount__c'));
                                overallAmt += (Decimal)pdw.pm.get('C' + i + '_Amount__c');
                            }
                            else
                                p.Amount = '';
                            if(pdw.pm.get('C' + i + '_SGST__c') != null) {
                                p.Tax1 = InventoryCostServices.InFormat((Decimal)pdw.pm.get('C' + i + '_SGST__c'));
                                overallTax1 += (Decimal)pdw.pm.get('C' + i + '_SGST__c');
                            }
                            else
                                p.Tax1 =  '';
                            if(pdw.pm.get('C' + i + '_CGST__c') != null) {
                                p.Tax2 = InventoryCostServices.InFormat((Decimal)pdw.pm.get('C' + i + '_CGST__c'));
                                overallTax2 += (Decimal)pdw.pm.get('C' + i + '_CGST__c');
                            }
                            else
                                p.Tax2 = '';
                            chargeCount++;
                            temp.add(p);
                        }
                        
                    }
                    printChargesMap.put(j , temp);
                    temp1.overallAmt = InventoryCostServices.Informat(overallAmt);
                    temp1.overallTax1 = InventoryCostServices.Informat(overallTax1);
                    temp1.overallTax2 = InventoryCostServices.Informat(overallTax2);
                    temp1.chargeCount = chargeCount;
                    temp1.milestoneName = pdw.pm.Milestone_Name__c;
                    printTotalsMap.put(j , temp1);
                    j++;
                }
                chargeCount = 1;
                overAllAmt = 0;
                overallTax1 = 0;
                overallTax2 = 0;
            }
        }
    }
    
    
    public PageReference saveQuote(){
        /*if(payPlanDetails == null || payPlanDetails.isEmpty()){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select a valid payment plan')); 
return null;
} */
        q.Payment_Plan__c = selectedPlan;           
        if(allChargesMap.containsKey('Agreement Value AMOUNTTOTAL')) {
            q.Total_Agreement_Value_Bucket__c = allChargesMap.get('Agreement Value AMOUNTTOTAL');
            q.SGST_on_Total_Agreement_Value_Bucket__c = allChargesMap.get('Agreement Value SGSTTOTAL');
            q.CGST_on_Total_Agreement_Value_Bucket__c = allChargesMap.get('Agreement Value CGSTTOTAL');
        }
        if(allChargesMap.containsKey('Other Charges AMOUNTTOTAL')) {
            q.Total_Other_Charges_Bucket__c = allChargesMap.get('Other Charges AMOUNTTOTAL');
            q.CGST_on_Total_Others_Charges_Bucket__c = allChargesMap.get('Other Charges SGSTTOTAL');
            q.SGST_on_Total_Other_Charge_Bucket__c = allChargesMap.get('Other Charges CGSTTOTAL');
        }
        if(allChargesMap.containsKey('Stamp Duty and Registration AMOUNTTOTAL')){
            q.Total_SD_Registration_Bucket__c = allChargesMap.get('Stamp Duty and Registration AMOUNTTOTAL');
            q.SGST_on_Total_SD_Registration_Bucket_del__c = allChargesMap.get('Stamp Duty and Registration SGSTTOTAL');
            q.CGST_on_Total_SD_Registration_Bucket_del__c = allChargesMap.get('Stamp Duty and Registration CGSTTOTAL');
        }   
        if(allChargesMap.containsKey('Society Charges AMOUNTTOTAL')) {
            q.Total_Society_Charges_Bucket__c = allChargesMap.get('Society Charges AMOUNTTOTAL');
            q.SGST_on_Total_Society_Charges_Bucket__c = allChargesMap.get('Society Charges SGSTTOTAL');
            q.CGST_on_Total_Society_Charges_Bucket_del__c = allChargesMap.get('Society Charges CGSTTOTAL');
        }
        Map<String, Integer> pcSeqMap = InventoryCostServices.getProjectChargesSequence(u.Project__r.Name,u.Tower__r.Id);
        Map<String,ProjectCharges__c> projChargesMap = InventoryCostServices.getProjectChargesMap(u.Project__r.Name,u.Tower__r.Id);
        for(String s : pcSeqMap.keyset()){
            if(allChargesMap.containsKey(s)) {
                q.put('Charge'+pcSeqMap.get(s)+'Name__c' ,s);
                q.put('Charge'+pcSeqMap.get(s)+'Value__c' ,allChargesMap.get(s));
                q.put('Charge'+pcSeqMap.get(s)+'Bucket__c' ,projChargesMap.get(s).ChargeBucket__c);
                if(allChargesMap.containsKey(s+' SGST'))
                    q.put('Charge'+pcSeqMap.get(s)+'SGST__c' ,allChargesMap.get(s+' SGST'));
                if(allChargesMap.containsKey(s+' CGST'))
                    q.put('Charge'+pcSeqMap.get(s)+'CGST__c' ,allChargesMap.get(s+' CGST'));
            }
        }
        // saving the parking charge as the last charge in the charge list. 
        // taking the maximum charge sequence and add one to it
        
        q.put('Charge'+ (pcSeqMap.size() + 1) +'Name__c' ,'Car Parking Charges');
        q.put('Charge'+ (pcSeqMap.size() + 1) + 'Value__c' ,allChargesMap.get('Car Parking Charges'));
        q.put('Charge'+ (pcSeqMap.size() + 1) +'Bucket__c' ,'Agreement Value');
        if(allChargesMap.containsKey('Car Parking Charges SGST'))
            q.put('Charge'+ (pcSeqMap.size() + 1) +'SGST__c' ,allChargesMap.get('Car Parking Charges SGST'));
        if(allChargesMap.containsKey('Car Parking Charges CGST'))
            q.put('Charge'+ (pcSeqMap.size() + 1) +'CGST__c' ,allChargesMap.get('Car Parking Charges CGST'));
        
        // save earmarked car parks
        /*Map<String,Decimal> earmarkedCP = InventoryCostServices.getEarmarkedCarparks(unitId);
if(earmarkedCP != null && earmarkedCP.size() > 0) {
Integer i =1;
for(String s : earmarkedCP.keyset()) {
q.put('Earmarked_Type_'+i+'__c', s);
q.put('Earmarked_Count_'+i+'__c', earmarkedCP.get(s));
i++;
}       
}*/
        if(allChargesMap.containsKey('EARMARKED CARPARK CHARGES')){
            q.Earmarked_Total_Amount__c = allChargesMap.get('EARMARKED CARPARK CHARGES');
        }
        if(allChargesMap.containsKey('ADDITIONAL CARPARK CHARGES')){
            q.Additional_CarPark_Amount__c = allChargesMap.get('ADDITIONAL CARPARK CHARGES');
        }
        decimal totalDiscount = 0;
        decimal discountedRateCard = 0;
        /////////////////// Below code Added by Vikas on dated 15/11/17 for storing discounted and original rate list values on quote
        if(!rateListOriginal.isEmpty() && !rateListForEditing.isEmpty()){
            if(rateListOriginal.containsKey('Basic') && rateListForEditing.containsKey('Basic')){
                q.Basic_Original_PSF__c = rateListOriginal.get('Basic').PSF_rate__c;
                q.Basic_D_PSF__c = rateListOriginal.get('Basic').PSF_rate__c;
                if(rateListOriginal.get('Basic').PSF_rate__c != rateListForEditing.get('Basic').PSF_rate__c){
                    q.Basic_D_PSF__c = rateListForEditing.get('Basic').PSF_rate__c;
                    totalDiscount += rateListOriginal.get('Basic').PSF_rate__c - rateListForEditing.get('Basic').PSF_rate__c;
                }
                discountedRateCard += q.Basic_D_PSF__c;
            }
            if(rateListOriginal.containsKey('Floor Rise') && rateListForEditing.containsKey('Floor Rise')){
                q.Floor_Rise_Original_PSF__c = rateListOriginal.get('Floor Rise').PSF_rate__c;
                q.Floor_Rise_D_PSF__c = rateListOriginal.get('Floor Rise').PSF_rate__c;
                if(rateListOriginal.get('Floor Rise').PSF_rate__c != rateListForEditing.get('Floor Rise').PSF_rate__c){
                    q.Floor_Rise_D_PSF__c = rateListForEditing.get('Floor Rise').PSF_rate__c;
                    totalDiscount +=  rateListOriginal.get('Floor Rise').PSF_rate__c - rateListForEditing.get('Floor Rise').PSF_rate__c;
                }
                discountedRateCard += q.Floor_Rise_D_PSF__c;
            }
            if(rateListOriginal.containsKey('PLC') && rateListForEditing.containsKey('PLC')){
                q.Premium1_Original_PSF__c = rateListOriginal.get('PLC').PSF_rate__c;
                q.Premium1_D_PSF__c = rateListOriginal.get('PLC').PSF_rate__c;
                if(rateListOriginal.get('PLC').PSF_rate__c != rateListForEditing.get('PLC').PSF_rate__c){
                    q.Premium1_D_PSF__c = rateListForEditing.get('PLC').PSF_rate__c;
                    totalDiscount +=  rateListOriginal.get('PLC').PSF_rate__c - rateListForEditing.get('PLC').PSF_rate__c;
                }
                discountedRateCard += q.Premium1_D_PSF__c;
            }
        }
        // Basic + PLC + Floor rise discounted rates + any PSF discounts  + any lumpsum discount but we want the PSF value of that as well since are calculating the total rate card
        /*if(q.Discount_PSF__c == null)
q.Discount_PSF__c = 0;
if(q.Discount_Lumpsum__c == null)
q.Discount_Lumpsum__c = 0;
q.Total_Discount_Rates__c = discountedRateCard - q.Discount_PSF__c - ( q.Discount_Lumpsum__c/ u.Chargeable_Area__c);
q.Customer_Discount_PSF__c = totalDiscount + q.Discount_PSF__c + q.Discount_Lumpsum__c/ u.Chargeable_Area__c;*/
        
        
        // if the total discount is with in the threshold of what the SM is allowed Rs 50 PSF no approval required
        // if the total discount is greater than what the SM is allowed Rs 50 PSF and less than what the site head threshold is, then send to site head for approval
        // if the discount is greater than what the site head can approve then send it to the Sales Head for approval
        //Map<String, Id> quoteApproversMap = InventoryCostServices.getApprovers(proj.Id);
        
        
        /*if(totalDiscount > proj.Sales_Manager_Discount__c && totalDiscount <= proj.Site_Head_Discount__c) {
q.Level_One_Approver__c = quoteApproversMap.get('First Level');
q.Approval_Required__c = true;
} else if (totalDiscount > proj.Site_Head_Discount__c) {
q.Level_One_Approver__c = quoteApproversMap.get('Second Level');
q.Approval_Required__c = true;
}
*/
        /******* Below Quotation Approval related changes made by Shailesh on 31.7.2018 *****/
        q.Approval_Required__c = false; // bcz approval process not required
        if(u.Tower__r.Level_1_Approver__c != null)
            q.Level_One_Approver__c = u.Tower__r.Level_1_Approver__c;
        if(u.Tower__r.Level_2_Approver__c != null)
            q.Level_Two_Approver__c = u.Tower__r.Level_2_Approver__c; 
        if(scheduleEdited) {
            q.Payment_Plan_Deviation__c = true;
        }
        if(q.Approval_Required__c){
            q.Quote_Status__c = 'Approval Pending';
        } else {
            q.Quote_Status__c = 'Valid';
            q.Final_Approved_Date__c = system.today(); //  When approval is req., this field is not required
        }
        Decimal totalDiscountApplicable = 0.00;
        if(dList != null){
            for(Discount__c dis : dList){/// u.Chargeable_Area__c
                if(dis.Applied__c){
                    if(dis.Lumpsum_Amount__c != null)
                        totalDiscountApplicable += dis.Lumpsum_Amount__c / u.Chargeable_Area__c;
                    if(dis.PSF_Amount__c != null)
                        totalDiscountApplicable += dis.PSF_Amount__c;
                }
            }
        }
        q.Total_Discount_Applicable__c = totalDiscountApplicable;
        /************************************************************************************/
        q.Token_Amount__c = allChargesMap.get('TOKEN AMOUNT');
        q.ST_Token_Amount__c = allChargesMap.get('TOKEN AMOUNT TAX');
        
        q.Allow_booking_without_full_token__c = true;  //////////////Added by vikas 
        
        ///////Storing Original and modified NPV on Quote //////////////////////
        system.debug('OriginalNPVPSF inside save::: '+OriginalNPVPSF);
        q.Modified_NPV__c = UpdatedPlanNPV;
        q.Modified_NPV_PSF__c = UpdatedNPVPSF.setscale(2,RoundingMode.HALF_UP); 
        q.Original_NPV__c = OriginalPlanNPV;
        q.Original_NPV_PSF__c = OriginalNPVPSF.setscale(2,RoundingMode.HALF_UP); 
        
        ///////////////////////-----------------   End Here   -----------------------------//////////  
        
        System.debug('Quotation Before Insert:' + q);
        Id  qId = null;
        PageReference pref;
        Database.saveResult sr = Database.insert(q);
        
        if(sr.isSuccess()) {
            qId = sr.getId();
            
            /// Insert Discount applied record aganist quotation
            List<Discounts_Applied__c> discountListForInsert = new list<Discounts_Applied__c>();
            if(dList != null){
                for(Discount__c dis : dList){
                    if(dis.Applied__c){
                        Discounts_Applied__c da = new Discounts_Applied__c();
                        da.Lumpsum_Amount__c = dis.Lumpsum_Amount__c;
                        da.Percentage_of_AV__c = dis.Percentage_of_AV__c;
                        da.Project__c = dis.Project__c;
                        da.PSF_Amount__c = dis.PSF_Amount__c;
                        da.Reason__c = dis.Reason__c;
                        da.Total__c = dis.Total__c;
                        da.Type__c = dis.Type__c;
                        da.Quotation__c = q.id;
                        if(dis != null){
                            da.Discount_Parent__c = dis.id;
                        }
                        discountListForInsert.add(da);
                    }
                }
            }
            if(discountListForInsert != null && !discountListForInsert.isEmpty()){
                insert discountListForInsert; 
            }
            
            // insert payment plan
            InventoryCostServices.insertCustomerPaymentPlan(payplanDetails, selectedPlan,proj,u, o,q,allChargesMap);
            
            return new PageReference('/lightning/r/Quotation__c/' + qId + '/view');
        } else {
            // Operation failed, so get all errors                
            for(Database.Error err : sr.getErrors()) {
                System.debug(LoggingLevel.ERROR,    'The following error has occurred.');                    
                System.debug(LoggingLevel.ERROR,    err.getStatusCode() + ': ' + err.getMessage());
                System.debug(LoggingLevel.ERROR,    'Quotation fields that are affected by this error: ' + err.getFields());
            }
            System.debug(LoggingLevel.ERROR,    'Quotation insertion error:');
            ApexPages.addMessage((new ApexPages.message(ApexPages.severity.FATAL,'Quotation Could not be saved')));
            return null;
        }
        
        return null;
    }
    
    public pageReference resetQuote(){
        system.debug('inside resetQuote method::: '+'Unit id : '+u.id + ', oppty id:'+oppId);
        PageReference pageRef;
        pageRef = new PageReference('/apex/createQuote?id='+u.id+'&oppId='+ oppId); 
        pageRef.setRedirect(true);
        return pageRef;
    }     
    
    public class PrintTotalsWrapper {
        public String overallAmt {get;set;}
        public String overallTax1 {get;set;}
        public String overallTax2 {get;set;}
        public Integer chargeCount {get;set;}
        public String milestoneName {get;set;}
    }
    
    public class PrintChargesWrapper {
        public String chargeName {get;set;}
        public String percentage {get;set;}
        public String Amount {get;set;}
        public String Tax1 {get;set;}
        public String Tax2 {get;set;}
    }
}