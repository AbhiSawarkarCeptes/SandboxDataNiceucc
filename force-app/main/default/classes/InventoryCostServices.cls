public with sharing class InventoryCostServices {
    public static Unit__c  getUnitDetails(Id unitId){
        List<Unit__c> unit = [Select Id, Name,Project__r.Name,Project__r.Id, Tower__r.Name, Tower__r.Id,Tower__r.Cluster__r.id,Tower__r.Level_1_Approver__c,  Tax_Rate_Basic__c, OC_Received__c,
                                                            Tower__r.Level_2_Approver__c, Floor__c,Carpet_Area__c, Chargeable_Area__c , Carpet_Area_in_Sq_Mts__c, Enclosed_Balcony_in_Sq_Mtrs__c, Cupboard_Area_in_Sq_Mtrs__c, Configuration__c,Puchase_Price__c
                                                                     from Unit__c where Id = :unitId];
        if(unit.size() ==1) {
            return unit[0];
        } else {
            return null;
        }       
    }
    
    public static Project__c  getProjectDetails(Id unitId){
        List<Unit__c> unit = [Select Id, Name,Project__r.Name, Project__r.Id, Tower__r.Name, Floor__c, Carpet_Area__c, 
                              Tower__r.Cluster__r.Id, Tower__r.Cluster__r.Name  From Unit__c Where Id = :unitId];
        if(unit.size() ==1) {                                                            
            List<Project__c> projList = [Select Id, Name, Address__c,Quotation_Validity__c, Sales_Manager_Discount__c, Site_Head_Discount__c     ,Sales_Head_Discount__c
                                    from Project__c where Id =: unit[0].Project__r.Id ];
            if(projList.size() ==1) {
                return projList[0];
            } else {
                return null;
            }
        }else {
            return null;
        }        
    }
 ///// Added by Neha Starts Here on 08/01/19 to get Cluster level Discounts   
    public static Cluster__c  getClusterDetails(Id unitId){
        List<Unit__c> unit = [Select Id, Name, Project__r.Name,Project__r.Id, Tower__r.Name, Floor__c, Carpet_Area__c, 
                              Tower__r.Cluster__r.Id, Tower__r.Cluster__r.Name From Unit__c Where Id = :unitId];
        if(unit.size() == 1) {                                                            
            List <Cluster__c> clusterList = [Select Id, Name, Project__c  From Cluster__c Where Id =: unit[0].Tower__r.Cluster__r.Id];                                           
            if(clusterList.size() == 1) {
                return clusterList[0];
            } else {
                return null;
            }
        } else {
            return null;
        }       
    }
    
    public static List<Discount__c> getClusterLevelDiscounts(Id projectId, Id clusterId) {
            List <Discount__c> dList = new List<Discount__c>();
            dList = [Select Id, Name, Special_Discount__c, Type__c, Applied__c, Start_Date__c, End_Date__c, Editable__c, Lumpsum_Amount__c, PSF_Amount__c, Percentage_of_AV__c, Reason__c, Project__c, Total__c  
                     From Discount__c Where Project__c = :projectId AND Cluster__c = :clusterId and start_date__c <= TODAY and (end_date__c = null OR end_date__c >= TODAY)];
            List <Discount__c> newDiscountList = new List <Discount__c>();
           // only special users can see special offers
           User u = getLoggedInUserDetails();
           for(Discount__c d: dList){
               if(d.Special_Discount__c){
                   if(u.Special_Payment_Plan_Visible__c){
                       newDiscountList.add(d);
                     }
               } else {
                   newDiscountList.add(d);              
               }           
           }
            return newDiscountList;
    } 
 ///// Added by Neha Ends Here on 08/01/19 to get Cluster level Discounts      
  
 public static List<Payment_Plan__c> getPlanList(Unit__c unitObj) {
      
    Id projId = unitObj.Project__r.Id;
    Id tId = unitObj.Tower__r.Id;
    Decimal floorNo = unitObj.Floor__c;
    List<Payment_Plan__c> planList = [Select Id, Name, Subvention_Payment_Plan__c,Is_Access_Restricted__c, Subvention_Base_Rate__c  from Payment_Plan__c where project__r.Id = : projId and tower__r.Id = :tId and IS_Active__c = true 
    and( (Min_Purchase_Price__c <= :unitObj.Puchase_Price__c
    AND Max_Purchase_Price__c>=: unitObj.Puchase_Price__c)
     ) ]; //Changed by Neha on 6/2/19
    List<Payment_Plan__c> unitPlanList = [Select Id, Name, Subvention_Payment_Plan__c,Is_Access_Restricted__c, Subvention_Base_Rate__c  from Payment_Plan__c where project__r.Id = : projId and tower__r.Id = :tId and IS_Active__c = true 
    and (Min_Purchase_Price__c = NULL
    AND Max_Purchase_Price__c= NULL)]; // Added by Neha on 6/2/19
    List<Payment_Plan__c> newPlanList = new List<Payment_Plan__c>();
    // only special users can see access restricted plans
    User u = getLoggedInUserDetails();
    for(Payment_Plan__c p : planList) {
            if(p.Is_Access_Restricted__c) {
                if(u.Special_Payment_Plan_Visible__c)
                    newPlanList.add(p);
            } else {
                newPlanList.add(p);
            }           
    }
    if(newPlanList.size() == 0){
    for(Payment_Plan__c p1 : unitPlanList) {
            if(p1.Is_Access_Restricted__c) { 
                if(u.Special_Payment_Plan_Visible__c)                   
                    newPlanList.add(p1);
            } else {
                newPlanList.add(p1);
            }           
      }
    }
    return newPlanList;
}
    
    public static User getLoggedInUserDetails() {
            List<User> uList = [Select Id, Name, Special_Payment_Plan_Visible__c from User where Id = :UserInfo.getUserId()];
            return uList[0];
    }
 
     public static List<Project_Construction_Stages__c> getConstructionStagesForTower(Id projId, Id tId) {
        List<Project_Construction_Stages__c> psList = [Select Id, Name from Project_Construction_Stages__c where Project__r.Id = : projId and tower__r.Id = : tId order by Sequence_No__c asc];
        return psList;
    }
    
    public static Map<String,Project_Construction_Stages__c> getConstructionStagesByName(Id projId) {
        Map<String,Project_Construction_Stages__c> pstageMap = new Map<string,Project_Construction_Stages__c>();
        List<Project_Construction_Stages__c> psList = [Select Id, Name, Planned_date_of_completion__c,Actual_date_of_completion__c from Project_Construction_Stages__c where Project__r.Id = : projId];
        for(Project_Construction_Stages__c p : psList) {
            pstageMap.put(p.Name, p);
        }
        return pstageMap;
    }
    
    public static Map<Id,Project_Construction_Stages__c> getConstructionStagesById(Id projId, Id towerId) {
        Map<Id,Project_Construction_Stages__c> pstageMap = new Map<Id,Project_Construction_Stages__c>([Select Id, Name, Planned_date_of_completion__c,Actual_date_of_completion__c 
                                                                                                        from Project_Construction_Stages__c 
                                                                                                        where Project__r.Id = : projId 
                                                                                                        and tower__r.Id = : towerId]);
        return pstageMap;
    }
    public static Map<String, Tax_Slab__c> getTaxRates() {
             Map<String, Tax_Slab__c> taxslabsMap = new Map<String, Tax_Slab__c>();
             List<Tax_Slab__c> tsList = new List<Tax_Slab__c>();
             tsList = [Select Id, Name, Tax_Name__c, Tax1_Name__c, Tax1_Percentage_on_100__c, Tax1_Percentage__c, Taxable1_Percentage__c,
                                                    Tax2_Name__c, Tax2_Percentage_on_100__c, Tax2_Percentage__c, Taxable2_Percentage__c,
                                                    From_Date__c, To_Date__c, Tax_Rate__c from Tax_Slab__c 
                                                    where 
                                                    From_Date__c <= TODAY and (To_Date__c >= TODAY OR To_Date__c = null)];
            if(!tsList.isEmpty()) {
                for(Tax_Slab__c ts: tsList) {
                    taxslabsMap.put(ts.Tax_Rate__c, ts);
                }
            }                                       
            return taxslabsMap;
    }
    public static Map<String, Tax_Slab__c> getTaxRatesForProjectCharges(Id unitId) {
            Map<String, Tax_Slab__c> taxslabsMap = getTaxRates();
        System.debug('outside : gettaxrate');       
            Unit__c u = getUnitDetails(unitId);
            Map<String, Tax_Slab__c> chargeTaxRate = new Map<String, Tax_Slab__c>();    
            if(u != null && taxslabsMap!= null && taxslabsMap.size() >= 1) {
                System.debug('gettaxrate');
                System.debug('taxslabsMap='+taxslabsMap);
                Map<String, ProjectCharges__c> projChargeMap  = getProjectChargesMap(u.Project__r.Name,u.Tower__r.Id);
                System.debug('projChargeMap='+projChargeMap);
                for(String s: projChargeMap.keySet()) {
                     System.debug('s value is : '+s);
                    System.debug('taxslabsMap key set is : '+taxslabsMap.keySet());
                    if(taxslabsMap.containsKey(projChargeMap.get(s).tax_rate__c)) {
                        System.debug('s value is : '+s);
                        System.debug('s value is : '+taxslabsMap.get( projChargeMap.get(s).tax_rate__c));
                        chargeTaxRate.put(s, taxslabsMap.get( projChargeMap.get(s).tax_rate__c ) );
                    }
                }
                // check if OC received.
                if(u.OC_Received__c) {
                    // no tax on basic
                    for(String s: projChargeMap.keySet()) {
                        if(projChargeMap.get(s).ChargeBucket__c != null && projChargeMap.get(s).ChargeBucket__c == 'Agreement Value')
                            chargeTaxRate.put(s, taxSlabsMap.get('GST 0%'));
                    }
                } else if (u.Tax_Rate_Basic__c != null) {
                    // this must be a below 50 sq.mt unit and hence has special tax rate, override the tax at unit level.
                    for(String s: projChargeMap.keySet()) {
                        if(projChargeMap.get(s).ChargeBucket__c != null && projChargeMap.get(s).ChargeBucket__c == 'Agreement Value')
                            chargeTaxRate.put(s, taxslabsMap.get( u.Tax_Rate_Basic__c));
                    }
                }
            }
            return chargeTaxRate;
    }
    public static Map<String,Decimal> getRateList(Id unitId) {
        Map<String,Decimal> chargeRateMap = new Map<String,Decimal>();
        List<Rate_List__c> rateList = [Select Id,  Charge_Cost__c, Type__c, PSF_rate__c,Unit__r.Name, ProjectCharges__r.Name 
                                            from Rate_List__c
                                            where Unit__c = :unitId];
                                
        if(rateList.size() > 0 ) {
            for(Rate_List__c r : rateList)  {
                    chargeRateMap.put(r.ProjectCharges__r.Name, r.Charge_Cost__c);
                    if(String.isNotBlank(r.Type__c) && r.Type__c.equalsIgnoreCase('PSF'))
                    chargeRateMap.put(r.ProjectCharges__r.Name + 'PSF', r.PSF_rate__c);  
            }                       
            
        }
        return chargeRateMap;
    }
    
    public static Map<String,Rate_List__c> getRateListForEditing(Id unitId) {
        Map<String,Rate_List__c> chargeRateMap = new Map<String,Rate_List__c>();
        List<Rate_List__c> rateList = [Select Id,  Charge_Cost__c, Type__c, PSF_rate__c,Unit__r.Name, ProjectCharges__r.Name, 
                                       Do_not_consider_for_rate_change__c, Rate_List_Bucket__c From Rate_List__c
                                            where Unit__c = :unitId];
                                
        if(rateList.size() > 0) {
            for(Rate_List__c r : rateList)  {
                    if(String.isNotBlank(r.Type__c) && r.Type__c.equalsIgnoreCase('PSF'))
                    chargeRateMap.put(r.ProjectCharges__r.Name, r);  
            }                       
            
        }
        return chargeRateMap;
    }
    
    public static List<ProjectCharges__c> getProjectChargesDefined(String ProjectName,Id towerId) {
        List<ProjectCharges__c> projCharges = [Select Id, Name, 
                                                            Active__c,
                                                            Calculatedas__c,
                                                            ChargeBucket__c,
                                                            Taxable__c,
                                                            SGST__c,
                                                            CGST__c,
                                                            IGST__c,
                                                            Tax_Rate__c,
                                                            Agreement_Value_Percentage__c,
                                                            editable__c
                                                             from 
                                                            ProjectCharges__c where Tower__c =:towerId
                                                            and active__c = true];//Project__r.Name = :projectName
        return projCharges;
   }
   
   public static Map<String, ProjectCharges__c> getProjectChargesMap(String ProjectName,Id towerId) {
        List<ProjectCharges__c> projCharges = [Select Id, Name, 
                                                            Active__c,
                                                            Calculatedas__c,
                                                            ChargeBucket__c,
                                                            Taxable__c,
                                                            SGST__c,
                                                            CGST__c,
                                                            IGST__c,
                                                            Tax_Rate__c,
                                                            Agreement_Value_Percentage__c,
                                                            editable__c
                                                             from 
                                                            ProjectCharges__c where Tower__c =:towerId
                                                            and active__c = true
                                                            order by Code_Formula__c asc];//Project__r.Name = :projectName Code__c 
        Map<String, ProjectCharges__c> projChargeMap = new Map<String,ProjectCharges__c>();                                                    
        for(ProjectCharges__c pc: projCharges){
                projChargeMap.put(pc.Name, pc);
        }                 
        return projChargeMap;
   }
   
   public static Map<String, Integer> getProjectChargesSequence(String ProjectName,Id towerId) {
        List<ProjectCharges__c> projCharges = [Select Id, Name, 
                                                            Active__c,
                                                            Calculatedas__c,
                                                            ChargeBucket__c,
                                                            Taxable__c,
                                                            SGST__c,
                                                            CGST__c,
                                                            IGST__c,
                                                            Tax_Rate__c,
                                                            Agreement_Value_Percentage__c,
                                                            editable__c
                                                             from 
                                                            ProjectCharges__c where Tower__c =:towerId
                                                            and Active__c = true
                                                            order by Code_Formula__c asc];//Project__r.Name = :projectName Code__c
        Integer count = 1;
        Map<String, Integer> projChargeSeq = new Map<String,Integer>();                                                    
        for(ProjectCharges__c pc: projCharges){
                projChargeSeq.put(pc.Name, count);
                count++;
        }                                       
        return projChargeSeq;
   }
   
    public static Legal_Entity__c getLegalEntityDetails(Id unitId, Id pId, Id tId) {
        Legal_Entity__c le = new Legal_Entity__c();
        Id leId = null;
        List<Unit__c> pu = [Select Id, Name, Legal_Entity__r.Id from Unit__c where Id = : unitId];
        if(pu != null && pu.size() > 0) {
            leId =pu[0].Legal_Entity__r.Id; 
           
        }
        if(leId == null) {
            List<Tower__c> t = [Select Id, Name, RDS_Company_Code__r.Id from Tower__c where Id = : tId];
                if(t != null && t.size() > 0){
                    leId = t[0].RDS_Company_Code__r.Id;
                }
                if(leId == null){
                    if(pId != null){
                        List<Project__c> p = [Select Id, Name, RDS_Company_Code__r.Id from Project__c where Id = : pId];
                        if(p != null && p.size() > 0)
                            leId = p[0].RDS_Company_Code__r.Id;
                    }
                }
        }
        if(leId != null) {
            le = [Select Name,Account_Name_Flat_Cost__c, Account_Number_Flat_Cost__c, Bank_Name_Flat_Cost__c,
                            Branch_Name_Flat_Cost__c,IFSC_Code_Flat_Cost__c, MICR_Code_Flat_Cost__c,
                            RDS_PAN_No__c,RDS_Company_Name__c,Account_Name_Service_Tax__c,Account_Number_Service_tax__c, 
                            Bank_Name_Service_tax__c,Branch_Name_Service_Tax__c, IFSC_Code_Service_Tax__c, MICR_Code_Service_Tax__c, 
                            RDS_Service_Tax_No__c,RDS_Address1__c,RDS_Address2__c, RDS_City__c, RDS_Pin_Code__c, CIN__c,
                            Account_Name_Other_Charges__c,Account_Number_Other_Charges__c,Bank_Name_Other_Charges__c,Branch_Name_Other_Charges__c,
                            IFSC_Code_Other_Charges__c,MICR_Code_Other_Charges__c,Account_Name_Other_Charges_Tax__c,Account_Number_Other_Charges_Tax__c,
                            Bank_Name_Other_Charges_Tax__c,Branch_Name_Other_Charges_Tax__c,IFSC_Code_Other_Charges_Tax__c,
                            MICR_Code_Other_Charges_Tax__c,GST__c,SPV_Bank_Account__c,RDS_Status__c,RDS_TDS_Circle__c,RDS_Phone__c,
                            RDS_Company_ID__c,RDS_Company_Code__c, IBAN__c, IBAN_Tax__c, Favouring__c
                            FROM Legal_Entity__c where Id = : leId];
        }
        return le;
    }
   
   /////////////////// Below method Added by Vikas for returning approvers team members 
   public static Map<String,Id> getApprovers(Id projId) {
          List<Team_Members__c> tmList = [Select User__c,Approver_Type__c, IsActive__c from Team_Members__c where Team__r.Team_Type__c like 'Sales Approvers Team%' and Team__r.Project__c = : projId];
          Map<String,Id> quoteApproversMap = new Map<String,Id>();
          for(Team_Members__c tm : tmList) {
              quoteApproversMap.put(tm.Approver_Type__c, tm.User__c);
          }
          return quoteApproversMap;
   }      
   
    /** returns all the charges based on the rateList, the
    ** tax slab for each slab and computed value after adding the tax slabs
    **/
    public static Map<String,Decimal> getAllCharges(Id unitId, Decimal additionalCarParkCharges, Decimal discountLumpsum, Map<String,Decimal> rateListMap){
        
        List<Unit__c> unit = [Select Id, Project__r.Name,Project__r.Id,Tower__r.Id from Unit__c where Id = :unitId];
        ProjectCharges__c basicChargeDetails = new ProjectCharges__c();
      
        if(unit != null && unit.size() ==1 ) {
            Map<String, Decimal> allChargesMap = new Map<String,Decimal>();
            Map<String, ProjectCharges__c> projChargesMap = getProjectChargesMap(unit[0].Project__r.Name,unit[0].Tower__r.Id);
            Map<String, Tax_Slab__c> chargeTaxMap =  getTaxRatesForProjectCharges(unit[0].Id);
            basicChargeDetails = projChargesMap.get('Basic');
            
            ProjectCharges__c carParkCharge = new ProjectCharges__c();
            carParkCharge.Name = 'Car Parking Charges';
            carParkCharge.ChargeBucket__c = basicChargeDetails.ChargeBucket__c;
            carParkCharge.Tax_Rate__c = basicChargeDetails.Tax_Rate__c;
            carParkCharge.Active__c = true;
            projChargesMap.put('Car Parking Charges' , carParkCharge);
            chargeTaxMap.put('Car Parking Charges', chargeTaxMap.get('Basic')); 
      
            if(rateListMap == null )
                    rateListMap = getRateList(unitId);
                else
                    System.debug('Using edited rates:' + rateListMap);
            Map<String, List<String>> chargeBucketMap = new Map<String, List<String>>();
            Decimal grandTotalAmount = 0;
            Decimal grandTotalTax = 0;
            
            Map<String, Decimal> earMarkedCP = getEarmarkedCarparks(unitId);
            Map<String, Decimal> carparkCharges = getCarParkCharges(unitId);
            Decimal earMarkedCharge = 0;
            if(!earMarkedCP.isEmpty() && !carparkCharges.isEmpty()) {
                    for(String s: earMarkedCP.keySet()) {
                        if(carparkCharges.containskey(s))
                            earMarkedCharge += carparkCharges.get(s) * earMarkedCP.get(s);
                    }
            }
            allChargesMap.put('EARMARKED CARPARK CHARGES', earMarkedCharge);
            allChargesMap.put('ADDITIONAL CARPARK CHARGES', additionalCarParkCharges);
            rateListMap.put('Car Parking Charges', earMarkedCharge + additionalCarParkCharges);
        
            for(ProjectCharges__c pc : projChargesMap.values()) {
                    // group them by bucket and get the bucket totals.
                    Decimal sgst = 0;
                    Decimal cgst = 0;
                    allChargesMap.putAll(rateListMap);
                    
                    if(pc.Active__c) {
                        System.debug('pc:' + pc);
                        System.debug('tax rate for ' + pc.Name + '==>' + chargeTaxMap.get(pc.Name));
                        if(rateListMap.containsKey(pc.Name) ) {
                            rateListMap.get(pc.Name);
                            if(String.isNotBlank(pc.Tax_Rate__c)) {
                                sgst = (rateListMap.get(pc.Name) * chargeTaxMap.get(pc.Name).Tax2_Percentage__c * chargeTaxMap.get(pc.Name).Taxable2_Percentage__c)/10000;
                                cgst = (rateListMap.get(pc.Name) * chargeTaxMap.get(pc.Name).Tax1_Percentage__c * chargeTaxMap.get(pc.Name).Taxable1_Percentage__c)/10000;
                                allChargesMap.put(pc.Name, rateListMap.get(pc.Name));
                                allChargesMap.put(pc.Name+' SGST', sgst);
                                allChargesMap.put(pc.Name+' CGST', cgst);
                                allChargesMap.put(pc.Name+' TAXTOTAL', sgst+cgst);
                            } else {
                                   allChargesMap.put(pc.Name, rateListMap.get(pc.Name));
                                allChargesMap.put(pc.Name+' SGST', sgst);
                                allChargesMap.put(pc.Name+' CGST', cgst);
                                allChargesMap.put(pc.Name+' TAXTOTAL', sgst+cgst);
                            }
                            
                            // create a map with the bucket name as the key and list of charges under that bucket for grouping and printing.
                            if(chargeBucketMap.containsKey(pc.ChargeBucket__c)) {
                                List<String> tempList = new List<String>();
                                tempList.addAll(chargeBucketMap.get(pc.ChargeBucket__c));
                                tempList.add(pc.Name);
                                chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                            }
                            else {
                                List<String> tempList = new List<String>();
                                tempList.add(pc.Name);
                                chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                            }
                            if(allChargesMap.containsKey(pc.ChargeBucket__c+' AMOUNTTOTAL')) {
                                allChargesMap.put(pc.ChargeBucket__c+' AMOUNTTOTAL' , allChargesMap.get(pc.ChargeBucket__c + ' AMOUNTTOTAL') + rateListMap.get(pc.Name));
                                allchargesMap.put(pc.ChargeBucket__c+' TAXAMOUNTTOTAL', allChargesMap.get(pc.ChargeBucket__c + ' TAXAMOUNTTOTAL') + sgst + cgst );
                                allchargesMap.put(pc.ChargeBucket__c+' SGSTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' SGSTTOTAL') + sgst);
                                allchargesMap.put(pc.ChargeBucket__c+' CGSTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' CGSTTOTAL') + cgst);
                            }   else {
                                allChargesMap.put(pc.ChargeBucket__c+' AMOUNTTOTAL' , rateListMap.get(pc.Name));
                                allchargesMap.put(pc.ChargeBucket__c+' TAXAMOUNTTOTAL', sgst + cgst );
                                allchargesMap.put(pc.ChargeBucket__c+' SGSTTOTAL', sgst);
                                allchargesMap.put(pc.ChargeBucket__c+' CGSTTOTAL', cgst );
                            }
                        } 
                    }
            }
            // we want to run through the entire list of project charges and calculate charges under all buckets where ratelists are defined.
            // now the only charge bucket that is not calculated is stamp duty since it doesn't have a ratelist
            Decimal agreementValue = 0;
                Decimal sgst = 0;
                Decimal cgst = 0;
                // recalculating the agreement value bucket by applying discounts
            if(allChargesMap.containsKey('Agreement Value AMOUNTTOTAL')) {
                    agreementValue = allChargesMap.get('Agreement Value AMOUNTTOTAL');
                    System.debug('Agreement Value:' + agreementValue + '::' + 'Discount Lumpsum:' + discountLumpsum);
                    if(discountLumpsum != 0) {
                        allChargesMap.put('Agreement Value AMOUNTTOTAL', agreementValue - discountLumpsum);
                        // reduce the discount amount from the Basic charges also
                        allChargesMap.put('Basic', allChargesMap.get('Basic') - discountLumpsum);
                        Decimal bAmt = allChargesMap.get('Basic'); 
                        Decimal sg = (bAmt * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000;
                        Decimal cg = (bAmt * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000;
                        allChargesMap.put('Basic'+' SGST', sg);
                        allChargesMap.put('Basic'+' CGST', cg);
                        allChargesMap.put('Basic'+' TAXTOTAL', sg+cg);
                        agreementValue = allChargesMap.get('Agreement Value AMOUNTTOTAL');
                        
                        if(basicChargeDetails != null) {
                            Decimal sgst1 = (agreementValue * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000;
                            Decimal cgst1 = (agreementValue * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000;
                            allChargesMap.put('Agreement Value TAXAMOUNTTOTAL', sgst1 + cgst1);
                            allChargesMap.put('Agreement Value SGSTTOTAL', sgst1);
                            allChargesMap.put('Agreement Value CGSTTOTAL', cgst1);
                        }
                    }
                    allChargesMap.put('TOTAL DISCOUNT', discountLumpsum);
                }
            for(ProjectCharges__c pc : projChargesMap.values()) {
                    if(pc.Active__c && 
                                String.isNotBlank(pc.ChargeBucket__c) && pc.ChargeBucket__c.equalsIgnoreCase('Stamp Duty and Registration') && 
                                String.isNotBlank(pc.Calculatedas__c) && pc.Calculatedas__c.equalsIgnoreCase('Percentage of Agreement Value')){
                                Decimal amount = ((agreementValue * pc.Agreement_Value_Percentage__c)/100).round(System.RoundingMode.CEILING);
                                // Integer reminder = Math.mod(Integer.valueOf(amount),100);
                                // Integer tobeAdded = 100 - reminder;
                                //Integer tobeAdded = 200;
                                //amount += toBeAdded;
                                allChargesMap.put(pc.Name, amount );
                                
                                if(String.isNotBlank(pc.Tax_Rate__c)) {
                                    sgst = (rateListMap.get(pc.Name) * chargeTaxMap.get(pc.Name).Tax2_Percentage__c * chargeTaxMap.get(pc.Name).Taxable2_Percentage__c)/10000;
                                    cgst = (rateListMap.get(pc.Name) * chargeTaxMap.get(pc.Name).Tax1_Percentage__c * chargeTaxMap.get(pc.Name).Taxable1_Percentage__c)/10000;
                                    allChargesMap.put(pc.Name, rateListMap.get(pc.Name));
                                    allChargesMap.put(pc.Name+' SGST', sgst);
                                    allChargesMap.put(pc.Name+' CGST', cgst);
                                    allChargesMap.put(pc.Name+' TAXTOTAL', sgst+cgst);
                                } else {
                                        allChargesMap.put(pc.Name+' SGST', sgst);
                                    allChargesMap.put(pc.Name+' CGST', cgst);
                                    allChargesMap.put(pc.Name+' TAXTOTAL', sgst+cgst);
                                }
                                if(allChargesMap.containsKey(pc.ChargeBucket__c+' AMOUNTTOTAL') ) {
                                    allChargesMap.put(pc.ChargeBucket__c+' AMOUNTTOTAL' , allChargesMap.get(pc.ChargeBucket__c+' AMOUNTTOTAL') + amount);
                                    allchargesMap.put(pc.ChargeBucket__c+' TAXAMOUNTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' TAXAMOUNTTOTAL') + sgst + cgst );
                                    allchargesMap.put(pc.ChargeBucket__c+' SGSTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' SGSTTOTAL') + sgst);
                                    allchargesMap.put(pc.ChargeBucket__c+' CGSTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' CGSTTOTAL') + cgst);
                                }   else {
                                    allChargesMap.put(pc.ChargeBucket__c+' AMOUNTTOTAL' , amount);
                                    allchargesMap.put(pc.ChargeBucket__c+' TAXAMOUNTTOTAL', sgst + cgst );
                                    allchargesMap.put(pc.ChargeBucket__c+' SGSTTOTAL', sgst);
                                    allchargesMap.put(pc.ChargeBucket__c+' CGSTTOTAL', cgst );
                                }
                                
                                if(chargeBucketMap.containsKey(pc.ChargeBucket__c)) {
                                    List<String> tempList = new List<String>();
                                    tempList.addAll(chargeBucketMap.get(pc.ChargeBucket__c));
                                    tempList.add(pc.Name);
                                    chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                                }
                                else {
                                    List<String> tempList = new List<String>();
                                    tempList.add(pc.Name);
                                    chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                                }
                    }   
            }
            for(String s :allChargesMap.keySet()) {
                    if(s.contains(' AMOUNTTOTAL')) {
                        grandTotalAmount += allChargesMap.get(s);
                    } else if(s.contains(' TAXAMOUNTTOTAL')) {
                        grandTotalTax += allchargesMap.get(s);
                    }
            }
            allChargesMap.put('GRAND TOTAL AMOUNT', grandTotalAmount);
            allChargesMap.put('GRAND TOTAL TAX', grandTotalTax);
            allChargesMap.put('GRAND TOTAL', grandTotalAmount + grandTotalTax);
            for(String s: chargeBucketMap.keyset()) {
                System.debug(s + ':' + chargeBucketMap.get(s));
            }
            return allChargesMap;
        } else {
            // throw exception
            return null;
        }
    }
    
    
    /** returns all the charges based on the rateList, the
    ** tax slab for each slab and computed value after adding the tax slabs
    **/
    public static Map<String,Decimal> getAllChargesNew(Id unitId, Decimal modifiedEMCPCharges, Decimal additionalCarParkCharges, Decimal discountLumpsum, Map<String,Decimal> rateListMap){
        
        List<Unit__c> unit = [Select Id, Project__r.Name,Project__r.Id,Tower__r.Id from Unit__c where Id = :unitId];
        ProjectCharges__c basicChargeDetails = new ProjectCharges__c();
       
        if(unit != null && unit.size() ==1 ) {
            Map<String, Decimal> allChargesMap = new Map<String,Decimal>();
            Map<String, ProjectCharges__c> projChargesMap = getProjectChargesMap(unit[0].Project__r.Name,unit[0].Tower__r.Id);
             System.debug('projChargesMap='+projChargesMap);
            Map<String, Tax_Slab__c> chargeTaxMap =  getTaxRatesForProjectCharges(unit[0].Id);
            basicChargeDetails = projChargesMap.get('Basic');
            System.debug('basicChargeDetails='+basicChargeDetails);
            ProjectCharges__c carParkCharge = new ProjectCharges__c();
            carParkCharge.Name = 'Car Parking Charges';
            carParkCharge.ChargeBucket__c = basicChargeDetails.ChargeBucket__c;
            carParkCharge.Tax_Rate__c = basicChargeDetails.Tax_Rate__c;
            carParkCharge.Active__c = true;
            projChargesMap.put('Car Parking Charges' , carParkCharge);
            chargeTaxMap.put('Car Parking Charges', chargeTaxMap.get('Basic'));
            if(rateListMap == null )
                    rateListMap = getRateList(unitId);
                else
                    System.debug('Using edited rates:' + rateListMap);
            Map<String, List<String>> chargeBucketMap = new Map<String, List<String>>();
            Decimal grandTotalAmount = 0;
            Decimal grandTotalTax = 0;
            
            Map<String, Decimal> earMarkedCP = getEarmarkedCarparks(unitId);
            Map<String, Decimal> carparkCharges = getCarParkCharges(unitId);
            Decimal earMarkedCharge = 0;
            if(modifiedEMCPCharges == -1) {
                if(!earMarkedCP.isEmpty() && !carparkCharges.isEmpty()) {
                        for(String s: earMarkedCP.keySet()) {
                            if(carparkCharges.containskey(s))
                                earMarkedCharge += carparkCharges.get(s) * earMarkedCP.get(s);
                        }
                }
            } else {
                    earMarkedCharge = modifiedEMCPCharges;
            }
            allChargesMap.put('EARMARKED CARPARK CHARGES', earMarkedCharge);
            allChargesMap.put('ADDITIONAL CARPARK CHARGES', additionalCarParkCharges);
            rateListMap.put('Car Parking Charges', earMarkedCharge + additionalCarParkCharges);
        	System.debug('1='+allChargesMap.keySet());
            for(ProjectCharges__c pc : projChargesMap.values()) {
                    // group them by bucket and get the bucket totals.
                    Decimal sgst = 0;
                    Decimal cgst = 0;
               	   System.debug('rateListMap='+rateListMap);
                    allChargesMap.putAll(rateListMap);
                    System.debug('2='+allChargesMap.keySet());
                    if(pc.Active__c) {
                        System.debug('pc:' + pc);
                        System.debug('tax rate for ' + pc.Name + '==>' + chargeTaxMap.get(pc.Name));
                        if(rateListMap.containsKey(pc.Name) ) {
                            System.debug('rateListMap.get(pc.Name) : '+rateListMap.get(pc.Name));
                            rateListMap.get(pc.Name);
                            if(String.isNotBlank(pc.Tax_Rate__c)) {
                                sgst = ((rateListMap.get(pc.Name) * chargeTaxMap.get(pc.Name).Tax2_Percentage__c * chargeTaxMap.get(pc.Name).Taxable2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                cgst = ((rateListMap.get(pc.Name) * chargeTaxMap.get(pc.Name).Tax1_Percentage__c * chargeTaxMap.get(pc.Name).Taxable1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                System.debug('pc.Name : '+pc.Name);
                                System.debug('rateListMap.get(pc.Name) : '+rateListMap.get(pc.Name));
                                allChargesMap.put(pc.Name, rateListMap.get(pc.Name));
                                allChargesMap.put(pc.Name+' SGST', sgst);
                                allChargesMap.put(pc.Name+' CGST', cgst);
                                allChargesMap.put(pc.Name+' TAXTOTAL', sgst+cgst);
                            } else {
                                System.debug('pc.Name 2: '+pc.Name);
                                System.debug('rateListMap.get(pc.Name) 2: '+rateListMap.get(pc.Name));
                                   allChargesMap.put(pc.Name, rateListMap.get(pc.Name));
                                allChargesMap.put(pc.Name+' SGST', sgst);
                                allChargesMap.put(pc.Name+' CGST', cgst);
                                allChargesMap.put(pc.Name+' TAXTOTAL', sgst+cgst);
                            }
                            System.debug('3='+allChargesMap.keySet());
                            // create a map with the bucket name as the key and list of charges under that bucket for grouping and printing.
                            if(chargeBucketMap.containsKey(pc.ChargeBucket__c)) {
                                List<String> tempList = new List<String>();
                                tempList.addAll(chargeBucketMap.get(pc.ChargeBucket__c));
                                tempList.add(pc.Name);
                                chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                            }
                            else {
                                List<String> tempList = new List<String>();
                                tempList.add(pc.Name);
                                chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                            }
                            if(allChargesMap.containsKey(pc.ChargeBucket__c+' AMOUNTTOTAL')) {
                                allChargesMap.put(pc.ChargeBucket__c+' AMOUNTTOTAL' , allChargesMap.get(pc.ChargeBucket__c + ' AMOUNTTOTAL') + rateListMap.get(pc.Name));
                                allchargesMap.put(pc.ChargeBucket__c+' TAXAMOUNTTOTAL', allChargesMap.get(pc.ChargeBucket__c + ' TAXAMOUNTTOTAL') + sgst + cgst );
                                allchargesMap.put(pc.ChargeBucket__c+' SGSTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' SGSTTOTAL') + sgst);
                                allchargesMap.put(pc.ChargeBucket__c+' CGSTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' CGSTTOTAL') + cgst);
                            }   else {
                                allChargesMap.put(pc.ChargeBucket__c+' AMOUNTTOTAL' , rateListMap.get(pc.Name));
                                allchargesMap.put(pc.ChargeBucket__c+' TAXAMOUNTTOTAL', sgst + cgst );
                                allchargesMap.put(pc.ChargeBucket__c+' SGSTTOTAL', sgst);
                                allchargesMap.put(pc.ChargeBucket__c+' CGSTTOTAL', cgst );
                            }
                            System.debug('4='+allChargesMap.keySet());
                        } 
                    }
            }
            // we want to run through the entire list of project charges and calculate charges under all buckets where ratelists are defined.
            // now the only charge bucket that is not calculated is stamp duty since it doesn't have a ratelist
            Decimal agreementValue = 0;
                Decimal sgst = 0;
                Decimal cgst = 0;
                // recalculating the agreement value bucket by applying discounts
            if(allChargesMap.containsKey('Agreement Value AMOUNTTOTAL')) {
                    agreementValue = allChargesMap.get('Agreement Value AMOUNTTOTAL');
                    System.debug('Agreement Value:' + agreementValue + '::' + 'Discount Lumpsum:' + discountLumpsum);
                    if(discountLumpsum != 0) {
                        allChargesMap.put('Agreement Value AMOUNTTOTAL', agreementValue - discountLumpsum);
                        // reduce the discount amount from the Basic charges also
                        allChargesMap.put('Basic', allChargesMap.get('Basic') - discountLumpsum);
                        Decimal bAmt = allChargesMap.get('Basic'); 
                        Decimal sg = ((bAmt * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                        Decimal cg = ((bAmt * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                         System.debug('pc.Name : 3');
                         System.debug('rateListMap.get(pc.Name) : 3 ');
                        allChargesMap.put('Basic'+' SGST', sg);
                        allChargesMap.put('Basic'+' CGST', cg);
                        allChargesMap.put('Basic'+' TAXTOTAL', sg+cg);
                        agreementValue = allChargesMap.get('Agreement Value AMOUNTTOTAL');
                        
                        if(basicChargeDetails != null) {
                            Decimal sgst1 = ((agreementValue * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                            Decimal cgst1 = ((agreementValue * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                            allChargesMap.put('Agreement Value TAXAMOUNTTOTAL', sgst1 + cgst1);
                            allChargesMap.put('Agreement Value SGSTTOTAL', sgst1);
                            allChargesMap.put('Agreement Value CGSTTOTAL', cgst1);
                        }
                    }
                    allChargesMap.put('TOTAL DISCOUNT', discountLumpsum);
                }
            System.debug('5='+allChargesMap.keySet());
            for(ProjectCharges__c pc : projChargesMap.values()) {
                    if(pc.Active__c && 
                                String.isNotBlank(pc.ChargeBucket__c) && pc.ChargeBucket__c.equalsIgnoreCase('Stamp Duty and Registration') && 
                                String.isNotBlank(pc.Calculatedas__c) && pc.Calculatedas__c.equalsIgnoreCase('Percentage of Agreement Value')){
                                Decimal amount = ((agreementValue * pc.Agreement_Value_Percentage__c)/100).round(System.RoundingMode.CEILING);
                                //System.debug('Stamp Duty Amount::'+amount);
                                // Integer reminder = Math.mod(Integer.valueOf(amount),100);
                                // Integer tobeAdded = 100 - reminder;
                                //Integer tobeAdded = 200;
                                //amount += toBeAdded;
                                allChargesMap.put(pc.Name, amount );
                                
                                if(String.isNotBlank(pc.Tax_Rate__c)) {
                                    System.debug('pc.Name : 4'+pc.Name);
                         			System.debug('rateListMap.get(pc.Name) : 4 '+rateListMap.get(pc.Name));
                                    sgst = ((rateListMap.get(pc.Name) * chargeTaxMap.get(pc.Name).Tax2_Percentage__c * chargeTaxMap.get(pc.Name).Taxable2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                    cgst = ((rateListMap.get(pc.Name) * chargeTaxMap.get(pc.Name).Tax1_Percentage__c * chargeTaxMap.get(pc.Name).Taxable1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                    allChargesMap.put(pc.Name, rateListMap.get(pc.Name));
                                    allChargesMap.put(pc.Name+' SGST', sgst);
                                    allChargesMap.put(pc.Name+' CGST', cgst);
                                    allChargesMap.put(pc.Name+' TAXTOTAL', sgst+cgst);
                                } else {
                                        allChargesMap.put(pc.Name+' SGST', sgst);
                                    allChargesMap.put(pc.Name+' CGST', cgst);
                                    allChargesMap.put(pc.Name+' TAXTOTAL', sgst+cgst);
                                }
                                if(allChargesMap.containsKey(pc.ChargeBucket__c+' AMOUNTTOTAL') ) {
                                    allChargesMap.put(pc.ChargeBucket__c+' AMOUNTTOTAL' , allChargesMap.get(pc.ChargeBucket__c+' AMOUNTTOTAL') + amount);
                                    allchargesMap.put(pc.ChargeBucket__c+' TAXAMOUNTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' TAXAMOUNTTOTAL') + sgst + cgst );
                                    allchargesMap.put(pc.ChargeBucket__c+' SGSTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' SGSTTOTAL') + sgst);
                                    allchargesMap.put(pc.ChargeBucket__c+' CGSTTOTAL', allChargesMap.get(pc.ChargeBucket__c+' CGSTTOTAL') + cgst);
                                }   else {
                                    allChargesMap.put(pc.ChargeBucket__c+' AMOUNTTOTAL' , amount);
                                    allchargesMap.put(pc.ChargeBucket__c+' TAXAMOUNTTOTAL', sgst + cgst );
                                    allchargesMap.put(pc.ChargeBucket__c+' SGSTTOTAL', sgst);
                                    allchargesMap.put(pc.ChargeBucket__c+' CGSTTOTAL', cgst );
                                }
                                
                                if(chargeBucketMap.containsKey(pc.ChargeBucket__c)) {
                                    List<String> tempList = new List<String>();
                                    tempList.addAll(chargeBucketMap.get(pc.ChargeBucket__c));
                                    tempList.add(pc.Name);
                                    chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                                }
                                else {
                                    List<String> tempList = new List<String>();
                                    tempList.add(pc.Name);
                                    chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                                }
                    }   
            }
            System.debug('6='+allChargesMap.keySet());
            for(String s :allChargesMap.keySet()) {
                System.debug('allchargesmap = '+s);
            }
            for(String s :allChargesMap.keySet()) {
                    if(s.contains(' AMOUNTTOTAL')) {
                        grandTotalAmount += allChargesMap.get(s);
                    } else if(s.contains(' TAXAMOUNTTOTAL')) {
                        grandTotalTax += allchargesMap.get(s);
                    }
            }
            allChargesMap.put('GRAND TOTAL AMOUNT', grandTotalAmount);
            allChargesMap.put('GRAND TOTAL TAX', grandTotalTax);
            allChargesMap.put('GRAND TOTAL', grandTotalAmount + grandTotalTax);
            for(String s: chargeBucketMap.keyset()) {
                    System.debug(s + ':' + chargeBucketMap.get(s));
            }
            return allChargesMap;
        } else {
            // throw exception
            return null;
        }
    }
    
    
    public static Map<String,List<String>> getChargeBuckets(Id unitId){
        
        List<Unit__c> unit = [Select Id, Project__r.Name,Project__r.Id,Tower__r.Id from Unit__c where Id = :unitId];
        
        if(unit.size() ==1 ) {
            List<ProjectCharges__c> projChargesList = getProjectChargesDefined(unit[0].Project__r.Name,unit[0].Tower__r.Id);
            Map<String, List<String>> chargeBucketMap = new Map<String, List<String>>();
            for(ProjectCharges__c pc : projChargesList) {
                    if(pc.Active__c) {
                        System.debug('pc:' + pc);
                        if(chargeBucketMap.containsKey(pc.ChargeBucket__c)) {
                            List<String> tempList = new List<String>();
                            tempList.addAll(chargeBucketMap.get(pc.ChargeBucket__c));
                            tempList.add(pc.Name);
                            chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                        }
                        else {
                            List<String> tempList = new List<String>();
                            tempList.add(pc.Name);
                            chargeBucketMap.put(pc.ChargeBucket__c, tempList);
                        }
                            
                    } 
                }
              
           if(chargeBucketMap.containsKey('Agreement Value') ){ 
                    List<String> tempList = new List<String>();
                    tempList=   chargeBucketMap.get('Agreement Value');
                    tempList.add('Car Parking Charges');
                    chargeBucketMap.put('Agreement Value', tempList);
                }
            
            return chargeBucketMap;
        } else {
            // throw exception
            return null;
        }
    } 
    
    public static List<String> getEditableRates(Id unitId){
        
        List<Unit__c> unit = [Select Id, Project__r.Name,Project__r.Id,Tower__r.Id from Unit__c where Id = :unitId and box_price__c != true];
        
        if(unit.size() ==1 ) {
            List<ProjectCharges__c> projChargesList = getProjectChargesDefined(unit[0].Project__r.Name,unit[0].Tower__r.Id);
            List<String> editableRates = new List<String>();
            for(ProjectCharges__c pc : projChargesList) {
                    if(pc.Active__c && pc.editable__c) {
                        System.debug('pc:' + pc);
                        editableRates.add(pc.Name);
                    } 
                }
            return editableRates;
        } else {
            // throw exception
            return null;
        }
    } 
    // method for getting the car park charges defined at the project level
    public static Map<String, Decimal>  getCarParkCharges(String unitId){
        String tempQuery = '';
        Map<String, Decimal> carParkChargeMap = new Map<String,Decimal>();
        For(Integer i=1;i<=5; i++) {
                TempQuery += 'Project__r.Car_Park_Type_'+i+ '__c,';
                TempQuery += 'Project__r.Charge_Value_'+i+ '__c,';
        }
        // remove the    character only if its a comma.
        if(tempQuery.length() > 0 && tempQuery.substring(tempQuery.length() -1).equals(','))
            tempQuery = tempQuery.substring(0,tempQuery.length() -1);
            String queryString = 'Select Id, Project__r.Name,Project__r.Id,'
                                    + tempQuery  + ' from Unit__c where  Id =' + '\'' + unitId + '\'' ;
            System.debug('Query formed in get plan details:' + queryString);
        
        List<Unit__c> unit = Database.Query(queryString);
        if(unit.size() ==1 ) {
                // the charges of various car park types from the project record in a map
                if(String.isNotBlank(unit[0].Project__r.Car_Park_Type_1__c))
                    carParkChargeMap.put(unit[0].Project__r.Car_Park_Type_1__c, unit[0].Project__r.Charge_Value_1__c);
                if(String.isNotBlank(unit[0].Project__r.Car_Park_Type_2__c))
                    carParkChargeMap.put(unit[0].Project__r.Car_Park_Type_2__c, unit[0].Project__r.Charge_Value_2__c);
                if(String.isNotBlank(unit[0].Project__r.Car_Park_Type_3__c))
                    carParkChargeMap.put(unit[0].Project__r.Car_Park_Type_3__c, unit[0].Project__r.Charge_Value_3__c);
                if(String.isNotBlank(unit[0].Project__r.Car_Park_Type_4__c))
                    carParkChargeMap.put(unit[0].Project__r.Car_Park_Type_4__c, unit[0].Project__r.Charge_Value_4__c);
                if(String.isNotBlank(unit[0].Project__r.Car_Park_Type_5__c))
                    carParkChargeMap.put(unit[0].Project__r.Car_Park_Type_5__c, unit[0].Project__r.Charge_Value_5__c);
        }
        System.debug('getCarparkCharges:' + carParkChargeMap);
        return carParkChargeMap;
            
    }
    // method for getting the earmarked car parks defined at the unit level
    public static Map<String, Decimal>  getEarmarkedCarParks(String unitId){
        String tempQuery = '';
        Map<String, Decimal> earmarkedCarParks = new Map<String,Decimal>();
        For(Integer i=1;i<=5; i++) {
                TempQuery += 'Car_Park_Type_'+i+ '__c,';
                TempQuery += 'Car_Park_Count_'+i+ '__c,';
        }
        // remove the last character only if its a comma.
        if(tempQuery.length() > 0 && tempQuery.substring(tempQuery.length() -1).equals(','))
            tempQuery = tempQuery.substring(0,tempQuery.length() -1);
            String queryString = 'Select Id, Project__r.Name,Project__r.Id,'
                                    + tempQuery  + ' from Unit__c where  Id =' + '\'' + unitId + '\'' ;
            System.debug('Query formed in get plan details:' + queryString);
        
        List<Unit__c> unit = Database.Query(queryString);
        if(unit.size() ==1 ) {
                // the charges of various car park types from the project record in a map
                if(String.isNotBlank(unit[0].Car_Park_Type_1__c))
                    earmarkedCarParks.put(unit[0].Car_Park_Type_1__c, unit[0].Car_Park_Count_1__c);
                if(String.isNotBlank(unit[0].Car_Park_Type_2__c))
                    earmarkedCarParks.put(unit[0].Car_Park_Type_2__c, unit[0].Car_Park_Count_2__c);
                if(String.isNotBlank(unit[0].Car_Park_Type_3__c))
                    earmarkedCarParks.put(unit[0].Car_Park_Type_3__c, unit[0].Car_Park_Count_3__c);
                if(String.isNotBlank(unit[0].Car_Park_Type_4__c))
                    earmarkedCarParks.put(unit[0].Car_Park_Type_4__c, unit[0].Car_Park_Count_4__c);
                if(String.isNotBlank(unit[0].Car_Park_Type_5__c))
                    earmarkedCarParks.put(unit[0].Car_Park_Type_5__c, unit[0].Car_Park_Count_5__c);
        }
        System.debug('getEarmarkedCarParks:' + earmarkedCarParks);
        return earmarkedCarParks;
            
    }
    // get a count of all available additional car parks at project level
    public static  Map<String,Decimal> getAdditionalCarParks(string pId, string cId) {
            List<Car_Park__c> cpList = [Select Id, Name, Category__c, Status__c, Type__c from Car_Park__c where status__c = 'Available' and Project__C =: pId];//and Cluster__c =: cId
            Map<String, Decimal> additionalCarparkMap = new Map<String, Decimal>();
            if(cpList != null) {
                for(Car_Park__c cp : cpList) {
                    if(additionalCarparkMap.containsKey(cp.Type__c)) {
                            System.debug('existing parking type condition:' + cp.Type__c + ':' + additionalCarParkMap.get(cp.Type__c));
                        Decimal count = additionalCarParkMap.get(cp.Type__c);
                        count += 1;
                        additionalCarparkMap.put(cp.Type__c, count);
                    } else {
                        additionalCarparkMap.put(cp.Type__c, 1);
                    }
                }
            }
            System.debug('additionalCarParks:' + additionalCarparkMap);
            return additionalCarparkMap;
    }
 
    public static List<PlanDetailWrapper> getPlanDetailsNew (String unitId, String planId, Map<String,Decimal> allChargesMap) {
            System.debug('inside plandetailsnew'+allChargesMap);
            List<PlanDetailWrapper> pdList = new List<PlanDetailWrapper>();
            List<Unit__c> unit = [Select Id, Project__r.Name, Tower__r.Name, Tower__r.Id , Project__r.Id from Unit__c where Id = :unitId];
            list<Project_Construction_Stages__c> pclist = getConstructionStagesForTower(unit[0].Project__r.Id, unit[0].Tower__r.Id);
            List<SelectOption> lstStages = new List<SelectOption>();
                if(pclist != null && !pcList.isEmpty()) {
                    lstStages.add(new SelectOption('', '--None--'));
                    for(Project_Construction_Stages__c p : pclist) {
                        lstStages.add(new SelectOption(p.Id, p.Name));
                    }
            }
            System.debug('lst: stages:' + lstStages);
            System.debug('pclist:' + pcList);
            if(unit != null && unit.size() == 1) {
                
                Map<String,ProjectCharges__c> projChargesMap = getProjectChargesMap(unit[0].Project__r.Name, unit[0].Tower__r.Id);
                Map<String, Tax_Slab__c> chargeTaxMap = getTaxRatesForProjectCharges(unit[0].Id);
                String tempQuery = '';
                for(Integer i = 1; i<=25; i++) {
                    tempQuery += 'Charge'+i+'Type__c' + ',';
                    tempQuery += 'Charge'+i+'Name__c' + ',';
                    tempQuery += 'Charge'+i+'Value__c' + ',';
                }
                // remove the last character only if its a comma.
            if(tempQuery.length() > 0 && tempQuery.substring(tempQuery.length() -1).equals(','))
                tempQuery = tempQuery.substring(0,tempQuery.length() -1);
                String queryString = 'Select Id, Name, Number_Of_Days_Plan__c, Time_Period__c, MilestoneNumber__c, Token_Amount_Milestone__c, Is_Combination_Milestone__c, Project_Construction_Stages__c, Payment_Plan__r.No_GST_On_Token__c,Token_Amount__c,Project_Construction_Stages__r.Name, Plan_Milestone_Type__c,Add_Token_GST__c, Deduct_Token__c,Milestone_Name_picklist__c,Is_Possession_Milestone__c, ' 
                                        + tempQuery  + ' from Payment_Plan_Milestones__c where  Payment_Plan__c =' + '\'' + planId + '\' order by milestonenumber__c asc' ;
                System.debug('Query formed in get plan details:' + queryString);
                
                Map<String, Integer> pcSeqMap = getProjectChargesSequence(unit[0].Project__r.Name, unit[0].Tower__r.Id);
                Map<Id,Project_Construction_Stages__c> pstageMap = getConstructionStagesById(unit[0].Project__r.Id,unit[0].Tower__r.Id);    
                
                ProjectCharges__c basicChargeDetails = new ProjectCharges__c();
                Integer basicChargeSeq = 0;
                if(pcSeqMap.containsKey('Basic')) {
                    basicChargeSeq = pcSeqMap.get('Basic');
                }
                List<Payment_Plan_Milestones__c> ppmList = Database.Query(queryString);
                system.debug('ppmList:' + ppmList);
                
                Decimal amount = 0;
                Decimal sgst = 0;
                Decimal cgst = 0;
                Decimal amount1 = 0;
                Decimal sgst1 = 0;
                Decimal cgst1 = 0;
                Decimal basicAmount = 0;
                Decimal basicSGST = 0;
                Decimal basicCGST = 0;
                Decimal Taxtotal = 0;
                Decimal total = 0;
                String tobePaid = '';
                Decimal overallTaxtotal = 0;
                Decimal overallAmountTotal = 0;
                Decimal overallTotal = 0;
                Decimal overallPercentage = 0;
                Integer count = 0;
                Decimal amountForTaxCalculation = 0;
                Decimal amountForTaxCalculationB = 0;
                Boolean basicMilestone = false;
                Boolean otherChargesMilestone = false;
                Boolean allowedEdit = True;    // Changed by Neha on 05/01/19 to TRUE to allow editing of all payment milestone 
                ProjectCharges__c chargeDetail;
                
                String chargeName = '';
                String percentage ='';
                Decimal value=0;
                Integer srno = 1;// Added by Neha on 26/3/19
                String type = '';
                if(ppmList != null && ppmList.size() > 0) {
                    // get the basic charge record from project charges record
                    if(projChargesMap.containsKey('Basic'))
                        basicChargeDetails = projChargesMap.get('Basic');
                    for(Payment_Plan_Milestones__c ppm : ppmList) {
                        Payment_Milestones__c pm = new Payment_Milestones__c();
                        pm.Time_Period__c = ppm.Time_Period__c; /////// Added by Neha on 5/2/19
                        pm.Number_Of_Days__c = ppm.Number_Of_Days_Plan__c;
                        pm.Milestone_Type_Text__c = ppm.Plan_Milestone_Type__c;
                        pm.Milestone_Type_edit__c = ppm.Plan_Milestone_Type__c;
                        pm.Project_Construction_Stages__c = ppm.Project_Construction_Stages__c;
                        pm.Is_Combination_Milestone__c = ppm.Is_Combination_Milestone__c;
                        pm.Add_Token_GST__c = ppm.Add_Token_GST__c;
                        pm.Deduct_Token__c = ppm.Deduct_Token__c;
                        pm.Is_Possession_Milestone__c = ppm.Is_Possession_Milestone__c;                      
                        
                        if(String.isNotBlank(ppm.Plan_Milestone_Type__c) && ppm.Plan_Milestone_Type__c.equals('Date Linked')) {
                        Date milestoneDueDate = null;
                        Date completionDate = null; 
                        Boolean IsMilestoneAchieved = False;
                  ///// Added by Neha on 4/2/19 Starts Here 
                   if(ppm.Number_Of_Days_Plan__c != null && ppm.Time_Period__c != null){    
                        if(ppm.Time_Period__c == 'Days'){ 
                            milestoneDueDate = System.today().addDays(Integer.valueOf(ppm.Number_Of_Days_Plan__c));
                        }
                        else {
                            milestoneDueDate = System.today().addDays(Integer.valueOf(ppm.Number_Of_Days_Plan__c)*30);
                        }
                     }
                ///// Added by Neha on 4/2/19 Ends Here  
                
             ///// Added by Neha on 15/3/19 Starts Here for Combination milestone               
                        if(ppm.Is_Combination_Milestone__c == true){
                          Project_Construction_Stages__c pStage = pstageMap.get(ppm.Project_Construction_Stages__c);   
                          if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c > milestoneDueDate){
                            completionDate = pStage.Actual_date_of_completion__c;
                        } else if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c <= milestoneDueDate) {
                            completionDate = milestoneDueDate;
                            IsMilestoneAchieved = True;
                        } else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c > milestoneDueDate){
                            completionDate = pStage.Planned_date_of_completion__c;
                        } else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c <= milestoneDueDate){
                            completionDate = milestoneDueDate;                        
                        } else{
                            completionDate = milestoneDueDate;
                        }
                            pm.Milestone_Due_Date__c = completionDate;
                            pm.Invoice_Due_Date__c = completionDate;
                        } else {
                            pm.Milestone_Due_Date__c = milestoneDueDate;
                            pm.Invoice_Due_Date__c = milestoneDueDate;
                        }  
        ///// Added by Neha on 15/3/19 Starts Here for Combination milestone                 
                           
       ////// Added by Neha Starts Here To include Combination Payment Milestone on 04/01/19               
                     if(ppm.Is_Combination_Milestone__c == false && ppm.Number_Of_Days_Plan__c != null && ppm.Number_Of_Days_Plan__c != 0 && ppm.Time_Period__c != null) {  // Changed by Neha on 4/2/19
                            toBePaid = ppm.Number_Of_Days_Plan__c + ' ' + ppm.Time_Period__c + ' ' + ppm.Milestone_Name_picklist__c;  // Changed by Neha on 4/2/19                      
                        } 
                        else if (ppm.Is_Combination_Milestone__c == false){
                             toBePaid = ppm.Milestone_Name_picklist__c;  
                        }
                        else {
                        Project_Construction_Stages__c pStage1 = pstageMap.get(ppm.Project_Construction_Stages__c);
                             toBePaid = 'On ' + pStage1.Name + ' (or) ' + ppm.Number_Of_Days_Plan__c + ' ' + ppm.Time_Period__c + ' from booking date - whichever is later'; // Changed by Neha on 4/2/19
                        }                                                
                        pm.Milestone_Name__c = toBePaid; 
      ////// Added by Neha Ends Here To include Combination Payment Milestone on 04/01/19 
      //// Added by Neha on 19/3/19
                        if(IsMilestoneAchieved) {
                            pm.Demand_Raised__c = True;
                            pm.Milestone_Complete_at_booking__c = True;
                        }
                        else
                            pm.Demand_Raised__c = False;                               
                        
                    } else if(String.isNotBlank(ppm.Plan_Milestone_Type__c) && ppm.Plan_Milestone_Type__c.equals('Construction Linked')) {
                        Date completionDate = null;
                        Boolean IsMilestoneAchieved = False;
                        Project_Construction_Stages__c pStage = pstageMap.get(ppm.Project_Construction_Stages__c);
                        if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c > System.today())
                            completionDate = pStage.Actual_date_of_completion__c;
                        else if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c <= System.today()) {
                            // if milestone is already achieved, then we can raise the demands for CLP only after flat is registrated. Registration is required only post 10% demand is generated.
                            // 10% is collected within the first 30 days. Hence setting the dates for CLP as 60 day from date of booking
                            completionDate = system.today();
                            IsMilestoneAchieved = True;
                        }
                        else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c > System.today())
                            completionDate = pStage.Planned_date_of_completion__c;
                        else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c <= System.today())
                            completionDate = system.today();
                        // this may not right, but ideally the code shouldnt come in here if the data is set correctly. 
                        if (completionDate == null)
                            completionDate = system.today().addDays(365);
                        ////// Added by Neha on 5/2/19 Starts Here 
                        if(ppm.Number_Of_Days_Plan__c != null && ppm.Time_Period__c != null)   
                        if(ppm.Time_Period__c == 'Days'){    
                            pm.Milestone_Due_Date__c = completionDate.addDays(Integer.valueOf(ppm.Number_Of_Days_Plan__c));
                            pm.Invoice_Due_Date__c = completionDate.addDays(Integer.valueOf(ppm.Number_Of_Days_Plan__c));
                          } else {
                               pm.Milestone_Due_Date__c = completionDate.addDays(Integer.valueOf(ppm.Number_Of_Days_Plan__c)*30);
                               pm.Invoice_Due_Date__c = completionDate.addDays(Integer.valueOf(ppm.Number_Of_Days_Plan__c)*30);
                          }
                        ////// Added by Neha on 5/2/19 Ends Here 
    ////// Added by Neha Starts Here To include Payment Milestone after Completion/Possession on 04/01/19                     
                     if(ppm.Number_Of_Days_Plan__c == 0 || ppm.Number_Of_Days_Plan__c == null){
                          toBePaid =  'On ' + pStage.Name;  //ppm.Number_Of_Days_Plan__c + ' days after Stage: ' +
                     }  
                     else {   
                        toBePaid = ppm.Number_Of_Days_Plan__c + ' ' + ppm.Time_Period__c + ' from ' + pStage.Name;  //Changed by Neha on 4/2/19
                     } 
    ////// Added by Neha Ends Here To include Payment Milestone after Completion/Possession on 04/01/19                     
                    
                        if(tobePaid.length() > 254)
                                pm.Milestone_Name__c = toBePaid.substring(0,254);
                            else
                                pm.Milestone_Name__c = toBePaid;
                        //setting the demand due flag if the milestone is already acheived at the time of generating the quotation
                        if(IsMilestoneAchieved) {
                            pm.Demand_Raised__c = True;
                            pm.Milestone_Complete_at_booking__c = True;
                        }
                        else
                            pm.Demand_Raised__c = False;
                    } else if(String.isNotBlank(ppm.Plan_Milestone_Type__c) && ppm.Plan_Milestone_Type__c.equals('On Registration')){
                            pm.Milestone_Name__c = 'On Registration';
                            toBePaid = 'On Registration';
                            // 10% is collected within the first 30 days. Hence setting the dates for registration demand as 60th day 
                            pm.Milestone_Due_Date__c =  System.today().addDays(60);
                            pm.Invoice_Due_Date__c =  System.today().addDays(60);
                    } else {
                            pm.Milestone_Name__c = ppm.Name;
                            toBePaid = ppm.Name;
                    }
                     pm.Installment__c = getinstallmentDetails(srno, ppmList.size(), toBePaid);// Added by Neha on 26/3/19
                     srno++; // Added by Neha on 26/3/19
                    Integer j=1;
                    basicMilestone = false;
                    otherChargesMilestone = false;
                    allowedEdit = true; //Changed by Neha on 05/01/19 to TRUE to allow editing of all payment milestone 
                    Map<String,String> fldMap = new Map<String,String>();
                    
                    // charge specific logic.
                    for(Integer i = 1; i<=25; i++) {           
                            if(String.isNotBlank((String)ppm.get('Charge'+i+'Name__c')) && projChargesMap.containsKey( (String)ppm.get('Charge'+i+'Name__c')) ) {
                                chargeName = (String)ppm.get('Charge'+i+'Name__c');
                                System.debug(Logginglevel.ERROR, 'i:' + i +'j:' + j +  ':charge name    :' +  (String)ppm.get('Charge'+i+'Name__c') );
                                pm.put('Charge'+j+'Name__c', ppm.get('Charge'+i+'Name__c') );
                                
                                if(projChargesMap.containsKey( (String)ppm.get('Charge'+i+'Name__c') )) {
                                    pm.put('Charge_'+j+'_Lookup__c',projChargesMap.get( (String)ppm.get('Charge'+i+'Name__c') ).Id);
                                }
                                // basic charges calculation. here we need to account for Token Amount , deduct token, add GST etc.,
                                if( ((String)ppm.get('Charge'+i+'Name__c')).equalsIgnoreCase('Basic') && ppm.get('Charge'+i+'Value__c') != null && (Decimal)ppm.get('Charge'+i+'Value__c') != 0) {
                                    value = (Decimal)ppm.get('Charge'+i+'Value__c');
                                    type = (String)ppm.get('Charge'+i+'Type__c');
                                    // this amount is the overall amount for total consideration value which is the total of all the values in agreement value bucket * percentage of that milestone
                                    // we take the way the milestone split is done for basic and assume rest are split the same way [rest - Floor rise, Premiums , Car Park charges etc.,]
                                    amount = 0;
                                    // basic amount represents the split only basic charge for each milestone. calculating this here to use in the insert payment plan logic.
                                    basicAmount = 0;
                                    if(String.isNotBlank(type) && type.equalsIgnoreCase('Percentage')) {
                                        // if percentage , calculate the amount
                                         amount = (value * allChargesMap.get('Agreement Value AMOUNTTOTAL'))/100;
                                         basicAmount = (value * allChargesMap.get('Basic'))/100;
                                    } else {
                                        // amount , calculate the percentage
                                        amount = value;
                                        value =  (amount/ allChargesMap.get('Agreement Value AMOUNTTOTAL')*100).setscale(2,RoundingMode.HALF_UP);
                                        basicAmount = amount;                           
                                    }
                                    // if deduct token milestone, deduct the token amount from the calculated amount and recalculate the percentage
                                    if(ppm.Deduct_Token__c && ppm.Token_Amount__c!=null) {
                                        amount = amount - ppm.Token_Amount__c;
                                        basicAmount = basicAmount - ppm.Token_Amount__c;
                                        value =  (amount/ allChargesMap.get('Agreement Value AMOUNTTOTAL')*100).setscale(2,RoundingMode.HALF_UP);
                                        // in case of deduct token milestone set it as amount milestone so that the absolute value is taken into consideration when editing the schedule.
                                        ppm.put('Charge'+i+'Type__c', 'Amount');
                                    }
                                    if(ppm.Payment_Plan__r.No_GST_On_Token__c && count ==0) {
                                        // if first milestone (token milestone) and no gst on token flag is set, then don't calculate tax on this milestone
                                        sgst = 0;
                                        cgst = 0;
                                        basicSGST = 0;
                                        basicCGST = 0;
                                    } else if(ppm.Add_Token_GST__c && ppm.Deduct_Token__c && ppm.Token_Amount__c != null) {
                                        // add token GST milestone, then we need to add the token amount's GST to this milestone. So change the amount before calculating taxes
                                        // we make a assumption here that this will be enabled only on the deduct token milestone.
                                        amountForTaxCalculation = amount + ppm.Token_Amount__c;
                                        amountForTaxCalculationB = basicAmount + ppm.Token_Amount__c;
                                        if(basicchargeDetails != null) {
                                            sgst = ((amountForTaxCalculation * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                            basicSGST = ((amountForTaxCalculationB * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                        }
                                        if(basicchargeDetails != null) {
                                            cgst = ((amountForTaxCalculation * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                            basicCGST = ((amountForTaxCalculationB * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                        }
                                    } else {
                                        // rest all milestones, calculate tax on the amount of that milestone.
                                        if(basicchargeDetails != null) {
                                            System.debug('amount : '+amount);
                                            System.debug('chargeTaxMap : '+chargeTaxMap);
                                            System.debug('chargeTaxMap.get : '+chargeTaxMap.get('Basic'));
                                            System.debug('chargeTaxMap.get : '+chargeTaxMap.get('Basic').Taxable2_Percentage__c);
                                            System.debug('chargeTaxMap.get : '+chargeTaxMap.get('Basic').Tax2_Percentage__c);
                                            sgst = ((amount* chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                            basicSGST  = ((basicAmount* chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                        }
                                        if(basicchargeDetails != null) {
                                            cgst = ((amount* chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                            basicCGST  = ((basicAmount* chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                        }
                                        
                                    }
                                    pm.put('C'+j+'_cgst__c',basicCGST);
                                    pm.put('C'+j+'_sgst__c',basicSGST);
                                    pm.put('C'+j+'_amount__c',basicAmount);
                                    pm.put('Charge'+j+'Percentage__c', value);
                                    if(ppm.Token_Amount_Milestone__c) {//count ==0
                                            allChargesMap.put('TOKEN AMOUNT', amount); // basicAmount changed to amount by Neha on 26/3/19
                                            allChargesMap.put('TOKEN AMOUNT TAX', sgst + cgst); // basicSGST + basicCGST changed to by Neha on 26/3/19
                                            allChargesMap.put('TOKEN AMOUNT PERCENTAGE', value);
                                    }
                                    basicMilestone = true;
                                    taxTotal = sgst + cgst;
                                    total = amount + taxTotal;
                                    overallAmountTotal += amount;
                                    overallTaxTotal += taxTotal;
                                    overallTotal += total;
                                overallPercentage += value;
                                percentage = String.valueOf(value) + '%';
                                fldMap.put('CHARGETYPE', 'Charge'+j+'Type__c');
                                fldMap.put('CHARGEAMT', 'C'+j+'_amount__c');
                                fldMap.put('CHARGEPCT', 'Charge'+j+'Percentage__c');
                                
                                }
                                // for rest of the 14 charges
                                if(  (String)ppm.get('Charge'+i+'Name__c') != 'Basic' ) {
                                    // for rest of the charges the details of amount tax has to be calculated.
                                    pm.put('Charge'+j+'Percentage__c',(Decimal)ppm.get('Charge'+i+'Value__c'));
                                    chargeDetail = projChargesMap.get((String)ppm.get('Charge'+i+'Name__c'));                                  
                                    amount1 = (allChargesMap.get(chargeName) * (Decimal)ppm.get('Charge'+i+'Value__c') )/100;
                                    pm.put('C'+j+'_Amount__c',amount1);
                                    if( chargeDetail != null && chargeTaxMap.containsKey(chargeName))
                                        sgst1= ((amount1* chargeTaxMap.get(chargeName).Taxable2_Percentage__c * chargeTaxMap.get(chargeName).Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                    if(chargeDetail != null && chargeTaxMap.containsKey(chargeName))
                                        cgst1 = ((amount1* chargeTaxMap.get(chargeName).Taxable1_Percentage__c * chargeTaxMap.get(chargeName).Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                    pm.put('C'+j+'_sgst__c', sgst1);
                                    pm.put('C'+j+'_cgst__c', cgst1);
                                    otherChargesMilestone = true;
                                    
                                }
                                j++;
                            } else {
                                System.debug('Inside else:' + j + ':charge name :' +  (String)ppm.get('Charge'+i+'Name__c')  );
                            }
                            
                            amount1 =0;
                            cgst1 =0;
                            sgst1 = 0;
                            chargeDetail = null;
                            
                        }
                        if(allChargesMap.containsKey('Car Parking Charges') && (Decimal)pm.get('Charge'+basicChargeSeq+'Percentage__c') != null) {
                                pm.put('Charge'+j+'Name__c', 'Car Parking Charges' );
                            if(!ppm.Token_Amount_Milestone__c) {//count != 0
                                pm.put('Charge'+j+'Percentage__c',(Decimal)ppm.get('Charge'+basicChargeSeq+'Value__c'));
                                pm.put('C'+j+'_Amount__c', (allChargesMap.get('Car Parking Charges') * (Decimal)ppm.get('Charge'+basicChargeSeq+'Value__c'))/100);
                                 // populating the Basic charge lookup for Interest On Common Area Charges, this is required for demand calculation.
                                pm.put('Charge_'+j+'_Lookup__c',projChargesMap.get( 'Basic' ).Id);
                                pm.put('C'+j+'_sgst__c', ((allChargesMap.get('Car Parking Charges') * (Decimal)ppm.get('Charge'+basicChargeSeq+'Value__c')/100 * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP));
                                pm.put('C'+j+'_cgst__c', ((allChargesMap.get('Car Parking Charges') * (Decimal)ppm.get('Charge'+basicChargeSeq+'Value__c')/100 * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP));
                            } else {
                                  
                            }
                        }
                        // if basic charges are present in this milestone and no other charges are present and if the milestone is completed at the time of booking and then allow editing by Sales Manager
                     // Commented by Neha on 05/01/19 to allow editing of all payment milestone 
                     /*   if(basicMilestone && pm.Milestone_Complete_at_booking__c)             
                                allowedEdit = true;                                
                            else if (basicMilestone && ppm.Plan_Milestone_Type__c.equals('Date Linked')){
                             System.debug('Insijjjjjjjjjjjjjjjjjjjjjj');
                                allowedEdit = true;
                                }*/
                        pdList.add(new PlanDetailWrapper(ppm, pm, tobePaid, value, percentage, amount, InFormat(amount),InFormat(taxTotal),inFormat(total),basicMilestone, allowedEdit, lstStages, fldMap, pm.Milestone_Complete_at_booking__c));
                        count ++;
                        percentage = '';
                        value = 0;
                        amount =0;
                        cgst = 0;
                        sgst = 0;
                        taxTotal = 0;
                        tobePaid = '';                       
                    }
                    // the final line item is just the totals;
                    pdList.add(new PlanDetailWrapper(null,null, 'Grand Total',overallPercentage, string.valueOf(overallPercentage) +'%', overallAmountTotal,  InFormat(overallAmountTotal),InFormat(overallTaxTotal),inFormat(overallTotal), true, false, NULL, NULL, false));
                }
            }
            System.debug('pdList:' + pdList);
            return pdList;
    }
    
    public static Map<String,String> validateEditedPlan(Unit__c u , String planId, Map<String,Decimal> allChargesMap, List<PlanDetailWrapper> ppdList){
        
        Map<String, Integer> pcSeqMap = getProjectChargesSequence(u.Project__r.Name,u.Tower__r.Id);
        System.debug('seqMap::'+pcSeqMap);
            Map<String, String> validationMap  = new Map<String,String>();
            Integer basicChargeSeq = 0;
            if(pcSeqMap.containsKey('Basic')) {
                basicChargeSeq = pcSeqMap.get('Basic');
            }
            Integer errorCount = 0;
            Integer count = 1;
            Decimal Amount = 0;
            Decimal Percentage = 0;
        if(ppdList != null && !ppdList.isEmpty()) {
            for(PlanDetailWrapper pd : ppdList) {
                System.debug(LoggingLevel.ERROR, 'pd in update plan:' + pd);
                if(pd.basicMilestone && pd.pm != null && pd.ppm != null) {
                    if(pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') == 'Percentage' && pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') == NULL) {
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '-Please populate the percentage \n');
                        errorCount ++;
                    } else if(pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') == 'Amount' && pd.milestoneAmount == NULL) {
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '-Please populate the amount \n');
                        errorCount ++;
                    }
                    // calculate the milestone names, due dates again if the user the has edited them
                    // Added by Neha on 8/5/19                   
                    if(pd.ppm.Milestone_Name_Picklist__c == Null) {
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '- Please enter the Milestone Name \n');
                        errorCount ++;
                    }
                    if(pd.pm.Time_Period__c == Null) {
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '- Please enter the Offset Type \n');
                        errorCount ++;
                    }
                    if(pd.pm.Number_Of_Days__c == NULL) {
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '- Please enter the Days Offset \n');
                        errorCount ++;
                    }
                    /// Added by Neha on 5/2/19 to make Time period mandatory
                    
                   // Commented by Neha on 05/01/19 to allow editing of all payment milestone  
                    /*else if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && !pd.pm.Milestone_Type_edit__c.equals('Date Linked') && pd.allowedEdit) {
                            // the requirement is that only date linked milestones can be selected when milestones are modified, so adding this extra validation to accommodate that
                            validationMap.put('ERROR', 'TRUE');
                         validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '- Milestone can be modified only to sales linked milesones, No other milestone type selection is allowed \n');
                         errorCount ++;
                    }*/
           // Added by Neha on 6/2/19 Starts Here       
                    if(String.isNotBlank(pd.ppm.Milestone_Name_Picklist__c) && pd.ppm.Milestone_Name_Picklist__c.equalsIgnoreCase('from booking date') && String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Construction Linked') && pd.pm.Is_Combination_Milestone__c == false) {
                         validationMap.put('ERROR', 'TRUE');
                         validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '- If Milestone is \'from booking date\', then Milestone Type should be \'Date Linked\'\n');
                         errorCount ++;
                    } 
                    if(String.isNotBlank(pd.ppm.Milestone_Name_Picklist__c) && pd.ppm.Milestone_Name_Picklist__c.equalsIgnoreCase('<<Construction Stage Name>>') && String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Date Linked') && pd.pm.Is_Combination_Milestone__c == false) {
                         validationMap.put('ERROR', 'TRUE');
                         validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '- If Milestone is \'Construction Stage Name\', then Milestone Type should be \'Construction Linked\'\n');
                         errorCount ++;
                    }                 
         // Added by Neha on 6/2/19 ENds Here         
           // Added by Neha on 28/1/19 Starts here to add validation on Milestone Type
           // If Milestone Type is 'Date Linked', then Construction Stage must be blank        
                    if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Date Linked') && String.isNotBlank(pd.pm.Project_Construction_Stages__c) && pd.pm.Is_Combination_Milestone__c == false) {
                         validationMap.put('ERROR', 'TRUE');
                         validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '- If Milestone Type is \'Date Linked\', then Construction Stage must be blank \n');
                         errorCount ++;
                    }
          // If Milestone Type is 'Construction Linked', then Construction Stage is mandatory                 
                    if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Construction Linked') && String.isBlank(pd.pm.Project_Construction_Stages__c)) {
                         validationMap.put('ERROR', 'TRUE');
                         validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '- If Milestone Type is \'Construction Linked\', then Construction Stage is mandatory\n');
                         errorCount ++;
                    } 
         // Added by Neha on 28/1/19 Ends here                       
                    
                    else if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Construction Linked')) {
                            String stage = pd.pm.Project_Construction_Stages__c;
                            Boolean isValid = (stage InstanceOf ID) ? true : false;
                            if(!isValid) {
                                validationMap.put('ERROR', 'TRUE');
                            validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '-Please select a valid construction stage \n');
                            errorCount ++;
                            }
                    } else if (String.isBlank(pd.pm.Milestone_Type_edit__c) || (!pd.pm.Milestone_Type_edit__c.equals('Construction Linked') &&  !pd.pm.Milestone_Type_edit__c.equals('Date Linked') && !pd.pm.Milestone_Type_edit__c.equals('On Registration'))){
                            validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '- Please select a date linked or construction linked milestone type \n');
                        errorCount ++;
                    } 
                    // if there is an error, there is no need to go this step of tallying the data as the input data is incomplete
                    if(!validationMap.containsKey('ERROR')) {
                            // sum up the numbers and see if it adds up to 100% of the TCV
                            System.debug('Tallying the amount and percentages post edit:' + 'basicChargeSeq:' +basicChargeSeq + ':'+ pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') + ':' + (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') );
                            if(pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') == 'Percentage') {
                            // if percentage , calculate the amount
                            amount += ((Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') * allChargesMap.get('Agreement Value AMOUNTTOTAL'))/100;
                            percentage += (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c');
                            } else {
                                // amount , calculate the percentage
                            amount += pd.milestoneAmount;
                            percentage +=  (amount/ allChargesMap.get('Agreement Value AMOUNTTOTAL')*100).setscale(2,RoundingMode.HALF_UP);
                            }
                    
                    }
                    count ++;
               }
            }
            if(!validationMap.containsKey('ERROR')) {
                if(Math.abs(amount - allChargesMap.get('Agreement Value AMOUNTTOTAL')) > 100) {
                    validationMap.put('ERROR', 'TRUE');
                    if(amount > allChargesMap.get('Agreement Value AMOUNTTOTAL')) {
                        validationMap.put('MESSAGE-' + errorCount, 'There is an excess of ? ' +  Informat(Math.abs(amount - allChargesMap.get('Agreement Value AMOUNTTOTAL'))) );
                        errorCount ++;
                        validationMap.put('MESSAGE-' + errorCount, 'Percentages add up to: ' +  percentage );
                    }
                    else {
                        validationMap.put('MESSAGE-' + errorCount, 'There is an shortfall of ? ' +  InFormat(Math.abs(amount - allChargesMap.get('Agreement Value AMOUNTTOTAL'))) );
                        errorCount ++;
                        validationMap.put('MESSAGE-' + errorCount, 'Percentages add up to: ' +  percentage  );
                    }
                    
                }
            }
            
        } else {
            validationMap.put('ERROR', 'TRUE');
            validationMap.put('MESSAGE-' + errorCount, 'Invalid payment plan definition');
        }
        System.debug(LoggingLevel.ERROR, validationMap);
        
        return validationMap;
   }
   
   public static List<PlanDetailWrapper> updatePlanDetails(Unit__c u , String planId, Map<String,Decimal> allChargesMap, List<PlanDetailWrapper> ppdList){
        
        Map<String,ProjectCharges__c> projChargesMap = getProjectChargesMap(u.Project__r.Name,u.Tower__r.Id);
        Map<String, Integer> pcSeqMap = getProjectChargesSequence(u.Project__r.Name,u.Tower__r.Id);
            Map<Id,Project_Construction_Stages__c> pstageMap = getConstructionStagesById(u.Project__r.Id,u.Tower__r.Id);    
            Map<String, Tax_Slab__c> chargeTaxMap = getTaxRatesForProjectCharges(u.Id);
            List<PlanDetailWrapper> pdList = new List<PlanDetailWrapper>();
            ProjectCharges__c basicChargeDetails = new ProjectCharges__c();
            if(projChargesMap.containsKey('Basic'))
                basicChargeDetails = projChargesMap.get('Basic');             
            // create a new project charge for parking and copy the basic charge details into it.
        ProjectCharges__c carParkCharge = new ProjectCharges__c();
        carParkCharge.Name = 'Car Parking Charges';
        carParkCharge.ChargeBucket__c = basicChargeDetails.ChargeBucket__c;
        carParkCharge.Tax_Rate__c = basicChargeDetails.Tax_Rate__c;
        carParkCharge.Active__c = true;
        projChargesMap.put('Car Parking Charges' , carParkCharge);
        chargeTaxMap.put('Car Parking Charges', chargeTaxMap.get('Basic'));
        System.debug('getProjectChargesMap:: ' + projChargesMap);   
            Integer Seq =1;
            Map<String, Integer> AVChargesSeqMap = new Map<String,Integer>();
            //creating a list of all charges that are part of the agreement value their field location, to identify whether they are stored in Charge1, Charge2, Charge3, etc.,
            for(String chargeName : projChargesMap.keySet()) {
                if(projChargesMap.get(chargeName).ChargeBucket__c.equalsIgnoreCase('Agreement Value')) {
                    if(!projChargesMap.get(chargeName).Name.equalsIgnoreCase('Basic') && !projChargesMap.get(chargeName).Name.equalsIgnoreCase('Car Parking Charges')) {
                        AVChargesSeqMap.put(chargeName, Seq);
                    } 
                    if(allChargesMap.containsKey('Car Parking Charges') && allChargesMap.get('Car Parking Charges') != 0 && projChargesMap.get(chargeName).Name.equalsIgnoreCase('Car Parking Charges')) 
                        AVChargesSeqMap.put(chargeName, Seq);
                }
                Seq++;
            }
        
            System.debug('AV Seq Map:' + AVChargesSeqMap);
            Integer basicChargeSeq = 0;
            if(pcSeqMap.containsKey('Basic')) {
                basicChargeSeq = pcSeqMap.get('Basic');
            }
            Decimal amount = 0;
            Decimal sgst = 0;
            Decimal cgst = 0;
            Decimal amount1 = 0;
            Decimal sgst1 = 0;
            Decimal cgst1 = 0;
            Decimal basicAmount = 0;
            Decimal basicSGST = 0;
            Decimal basicCGST = 0;
            Decimal Taxtotal = 0;
            Decimal total = 0;
            String tobePaid = '';
            Decimal overallTaxtotal = 0;
            Decimal overallAmountTotal = 0;
            Decimal overallTotal = 0;
            Decimal overallPercentage = 0;
            Integer count = 0;
            Decimal amountForTaxCalculation = 0;
            Decimal amountForTaxCalculationB = 0;
            Decimal CalculatedPercentage; 
            String percentage = '';
            Decimal tokenAmount = 0;
            Integer srno = 1;
            ppdList.remove(ppdList.size()-1);
        if(ppdList != null && !ppdList.isEmpty()) {
            for(PlanDetailWrapper pd : ppdList) {
                System.debug('pd in update plan:' + pd);
                // if a new row has been added populate the names of the charges in the appropriate field locations.
                if(pd.editedRowStyle == 'Edited') {
                    pd.pm.put('Charge'+basicChargeSeq+ 'Name__c', 'Basic');
                    pd.pm.put('Charge_'+basicChargeSeq +'_Lookup__c',projChargesMap.get( 'Basic').Id);
                    for(String s :  AVChargesSeqMap.keySet()) {
                        pd.pm.put('Charge'+AVChargesSeqMap.get(s)+ 'Name__c', s);
                        Integer j = AVChargesSeqMap.get(s);
                        if(projChargesMap.containsKey( s) ) {
                          pd.pm.put('Charge_'+j +'_Lookup__c',projChargesMap.get( s).Id);
                        }
                    }                    
                }
                if(pd.basicMilestone && pd.pm != null && pd.ppm != null && pd.pm.get('Charge'+basicChargeSeq+ 'Name__c') == 'Basic') {
                    if(pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') == 'Percentage') {
                        // if percentage , calculate the amount
                        amount = ((Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') * allChargesMap.get('Agreement Value AMOUNTTOTAL'))/100;
                            basicAmount = ((Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') * allChargesMap.get('Basic'))/100;
                            // when the milestone is edited, if basic percentage is altered all the other charges that forms the Agreeement Value bucket should also be set to the same percentage
                            system.debug('avgmap::'+AVChargesSeqMap);
                            system.debug('avgmapValues::'+AVChargesSeqMap.values());
                            for(Integer seq0 :  AVChargesSeqMap.values()) {
                                System.debug('Inside AV Charges Seq loop:' + pd.pm + '::Charge'+seq0+ 'Name__c');
                                pd.pm.put('Charge'+seq0+'Percentage__c',(Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c'));
                                Decimal chargeAmount = 0;
                                system.debug('seq is: '+seq0);
                                System.debug('chargeAmount:::' + pd);
                                chargeAmount = ((Decimal)pd.pm.get('Charge'+seq0+'Percentage__c') * allChargesMap.get((String)pd.pm.get('Charge'+seq0+ 'Name__c')))/100;
                                pd.pm.put('C'+seq0+'_amount__c',chargeAmount);
                                ProjectCharges__c chargeDetails = new ProjectCharges__c();
                                if(projChargesMap.containsKey((String)pd.pm.get('Charge'+seq0+ 'Name__c')))
                                    chargeDetails = projChargesMap.get((String)pd.pm.get('Charge'+seq0+ 'Name__c'));
                                Decimal chargeCGST= 0;
                                Decimal chargeSGST = 0;
                                if(chargeDetails != null) {
                                    chargeCGST  = ((chargeAmount * chargeTaxMap.get(chargeDetails.Name).Taxable1_Percentage__c * chargeTaxMap.get(chargeDetails.Name).Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                }
                                if(chargeDetails != null) {
                                    chargeSGST  = ((chargeAmount* chargeTaxMap.get(chargeDetails.Name).Taxable2_Percentage__c * chargeTaxMap.get(chargeDetails.Name).Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                }
                                pd.pm.put('C'+seq0+'_sgst__c',chargeSGST);
                                   pd.pm.put('C'+seq0+'_cgst__c',chargeCGST);
                            }
                    } else {
                        // amount , calculate the percentage
                        amount = pd.milestoneAmount;
                        calculatedPercentage =  (amount/ allChargesMap.get('Agreement Value AMOUNTTOTAL')*100).setscale(2,RoundingMode.HALF_UP);
                        pd.pm.put('Charge'+basicChargeSeq+'Percentage__c',calculatedPercentage);
                        basicAmount = amount;
                        
                        // when the milestone is edited, if basic  is altered and set as amount, all the other charges that forms the Agreeement Value bucket should be set to 0
                            for(Integer seq1 :  AVChargesSeqMap.values()) {
                                pd.pm.put('Charge'+seq1+'Percentage__c',0);
                                pd.pm.put('C'+seq1+'_amount__c',0);
                                pd.pm.put('C'+seq1+'_sgst__c',0);
                            pd.pm.put('C'+seq1+'_cgst__c',0);
                            }
                    }
                        if(pd.ppm.Payment_Plan__r.No_GST_On_Token__c && count ==0) {
                            // if first milestone (token milestone) and no gst on token flag is set, then don't calculate tax on this milestone
                            sgst = 0;
                            cgst = 0;
                            basicSGST = 0;
                            basicCGST = 0;
                            // if the user has edited the first milestone then the token amount would change, then in the deduct token milestone we would have to add the tax for the updated token amount
                            tokenAmount = amount;
                        } else if(pd.ppm.Add_Token_GST__c && pd.ppm.Deduct_Token__c) {
                            // add token GST milestone, then we need to add the token amount's GST to this milestone. So change the amount before calculating taxes
                            // we make a assumption here that this will be enabled only on the deduct token milestone.
                            amountForTaxCalculation = amount + tokenAmount;
                            amountForTaxCalculationB = basicAmount +tokenAmount;
                            if(basicchargeDetails != null) {
                                sgst = ((amountForTaxCalculation * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                basicSGST = ((amountForTaxCalculationB * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                            }
                            if(basicchargeDetails != null) {
                                cgst = ((amountForTaxCalculation * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                basicCGST = ((amountForTaxCalculationB * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                            }
                        } else {
                            // rest all milestones, calculate tax on the amount of that milestone.
                            if(basicchargeDetails != null) {
                                sgst = ((amount* chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                basicSGST  = ((basicAmount* chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                            }
                            if(basicchargeDetails != null) {
                                cgst = ((amount* chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                basicCGST  = ((basicAmount* chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                            }
                            
                        }
                        pd.pm.put('C'+basicChargeSeq+'_cgst__c',basicCGST);
                        pd.pm.put('C'+basicChargeSeq+'_sgst__c',basicSGST);
                        pd.pm.put('C'+basicChargeSeq+'_amount__c',basicAmount);
                        
                        taxTotal = sgst + cgst;
                        total = amount + taxTotal;
                        overallAmountTotal += amount;
                        overallTaxTotal += taxTotal;
                        overallTotal += total;
                        overallPercentage += (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c');
                        percentage = String.valueOf((Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c')) + '%';
                            if(count == 0) {
                             allChargesMap.put('TOKEN AMOUNT', amount);  // basicAmount changed to amount by Neha on 26/3/19
                             allChargesMap.put('TOKEN AMOUNT TAX', sgst + cgst); //basicSGST + basicCGST changed to sgst + cgst by Neha on 26/3/19
                             allChargesMap.put('TOKEN AMOUNT PERCENTAGE', (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c'));
                        }
                    // calculate the milestone names, due dates again if the user the has edited them
                    if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Date Linked')) {
                            Date milestoneDueDate = null;
                            Date completionDate = null; 
                            Boolean IsMilestoneAchieved = False;
                 /// Edited by Neha on 28/1/19 Starts Here
                        if(pd.pm.Number_Of_Days__c != null && pd.pm.Time_Period__c != null) { //&& pd.pm.Number_Of_Days__c != 0
                    ///// Added by Neha on 5/2/19      
                          if(pd.pm.Time_Period__c == 'Days'){
                            milestoneDueDate = System.today().addDays(Integer.valueOf(pd.pm.Number_Of_Days__c));
                          } else {
                            milestoneDueDate = System.today().addDays(Integer.valueOf(pd.pm.Number_Of_Days__c)*30);
                          }                          
                        } 
      ///// Added by Neha on 15/3/19 Starts Here for Combination milestone               
                        if(pd.pm.Is_Combination_Milestone__c == true){
                          Project_Construction_Stages__c pStage = pstageMap.get(pd.pm.Project_Construction_Stages__c);   
                          if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c > milestoneDueDate){
                            completionDate = pStage.Actual_date_of_completion__c; 
                        } else if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c <= milestoneDueDate) {
                            completionDate = milestoneDueDate;
                            IsMilestoneAchieved = True;
                        } else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c > milestoneDueDate){
                            completionDate = pStage.Planned_date_of_completion__c;
                        } else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c <= milestoneDueDate){
                            completionDate = milestoneDueDate;                        
                        } else{
                            completionDate = milestoneDueDate;
                        }
                         pd.pm.Milestone_Due_Date__c = completionDate;
                         pd.pm.Invoice_Due_Date__c = completionDate;
                       } else {
                          pd.pm.Milestone_Due_Date__c = milestoneDueDate;
                          pd.pm.Invoice_Due_Date__c = milestoneDueDate;
                       }  
        ///// Added by Neha on 15/3/19 Starts Here for Combination milestone                    
                    ////// Added by Neha on 05/02/19 Starts Here To include Combination Payment Milestone       
                        if(pd.pm.Is_Combination_Milestone__c == false && pd.pm.Number_Of_Days__c != null && pd.pm.Number_Of_Days__c != 0 && pd.pm.Time_Period__c != null && pd.ppm.Milestone_Name_Picklist__c != null){    
                            toBePaid = pd.pm.Number_Of_Days__c + ' ' + pd.pm.Time_Period__c + ' ' + pd.ppm.Milestone_Name_Picklist__c; // Changed by Neha on 5/2/19
                        } else if (pd.pm.Is_Combination_Milestone__c == false){
                            toBePaid = pd.ppm.Milestone_Name_Picklist__c;
                        } else if(pd.pm.Is_Combination_Milestone__c == true && pd.pm.Number_Of_Days__c != null && pd.pm.Time_Period__c != null && pd.pm.Project_Construction_Stages__c != null){
                            Project_Construction_Stages__c pStage = pstageMap.get(pd.pm.Project_Construction_Stages__c);
                           toBePaid = 'On ' + pStage.Name + ' (or) ' + pd.pm.Number_Of_Days__c + ' ' + pd.pm.Time_Period__c + ' from booking date - whichever is later';  
                        } 
                ///// Added by Neha on 5/2/19 Ends Here                           
                /// Edited by Neha on 28/1/19 Ends Here
         
                        pd.pm.Milestone_Name__c = toBePaid;
                        pd.pm.Milestone_type_text__c = pd.pm.Milestone_Type_edit__c;
                    } else if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Construction Linked')) {
                        Date completionDate = null;
                        Boolean IsMilestoneAchieved = False;
                        Project_Construction_Stages__c pStage = pstageMap.get(pd.pm.Project_Construction_Stages__c);
                        if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c > System.today())
                            completionDate = pStage.Actual_date_of_completion__c; 
                        else if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c <= System.today()) {
                                // for all milestones which are completed when quotation/booking is being created, they can be charged only post registration
                                // CLPs can be raised only post registration, registration happens post collection of 10%. 10% is collected within 30 days
                                // then registration charges, 20% flat cost milestone on registration and CLP payments of already raised slabs happens together. to allow some leeway to the customer
                                // these demands are given a 30 day due date. Hence payment is expected to come within 60th day [30 days post raising it]
                            completionDate = system.today();
                            IsMilestoneAchieved = True;
                        }    
                        else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c > System.today())
                            completionDate = pStage.Planned_date_of_completion__c;
                        else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c <= System.today())
                            completionDate = system.today();
                        // this may not right, but ideally the code shouldnt come in here if the data is set correctly. 
                        if (completionDate == null)
                            completionDate = system.today().addDays(365);
                       ////// Added by Neha on 5/2/19 Starts Here
                       if(pd.pm.Number_Of_Days__c != null && pd.pm.Time_Period__c != null) { 
                         if(pd.pm.Time_Period__c == 'Days') {   
                            pd.pm.Milestone_Due_Date__c = completionDate.addDays(Integer.valueOf(pd.pm.Number_Of_Days__c)); 
                            pd.pm.Invoice_Due_Date__c = completionDate.addDays(Integer.valueOf(pd.pm.Number_Of_Days__c)); 
                         } else {
                            pd.pm.Milestone_Due_Date__c = completionDate.addDays(Integer.valueOf(pd.pm.Number_Of_Days__c)*30);
                            pd.pm.Invoice_Due_Date__c = completionDate.addDays(Integer.valueOf(pd.pm.Number_Of_Days__c)*30);
                         }                      
                       }
               /////// Added by Neha on 5/2/19 Ends Here        
               ////// Added by Neha on 28/1/19 Starts Here To include Payment Milestone after Completion/Possession                    
                     if(pd.pm.Number_Of_Days__c == 0 || pd.pm.Number_Of_Days__c == null){
                          toBePaid =  'On ' + pStage.Name;  //ppm.Number_Of_Days_Plan__c + ' days after Stage: ' +
                      }  
                     else {   
                        toBePaid = pd.pm.Number_Of_Days__c + ' ' + pd.pm.Time_Period__c + ' from ' + pStage.Name;  //Format: 6 months from completion // Changed by Neha on 5/2/19
                      } 
              ////// Added by Neha on 28/1/19 Ends Here To include Payment Milestone after Completion/Possession                          
                        
                        if(tobePaid.length() > 254)
                                pd.pm.Milestone_Name__c = toBePaid.substring(0,254);
                            else
                                pd.pm.Milestone_Name__c = toBePaid;
                        //setting the demand due flag if the milestone is already acheived at the time of generating the quotation
                        if(IsMilestoneAchieved) {
                            pd.pm.Demand_Raised__c = True;
                            pd.pm.Milestone_Complete_at_booking__c = True;
                        }
                        else
                            pd.pm.Demand_Raised__c = False;
                    } else if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('On Registration')){
                            pd.pm.Milestone_Name__c = 'On Registration';
                            toBePaid = 'On Registration';
                            pd.pm.Milestone_Due_Date__c = System.today().addDays(60);
                            pd.pm.Invoice_Due_Date__c = System.today().addDays(60);
                    } else {
                            // shouldn't enter this else
                            pd.pm.Milestone_Name__c = 'Error';
                            tobepaid = 'Error';
                    }
                    pd.pm.Installment__c = getinstallmentDetails(srno, ppdList.size(), toBePaid);// Added by Neha on 26/3/19
                    srno++; // Added by Neha on 26/3/19                    
                    pdList.add(new PlanDetailWrapper(pd.ppm,pd.pm, tobePaid, (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c'), percentage, amount, InFormat(amount),InFormat(taxTotal),inFormat(total),pd.basicMilestone, pd.allowedEdit, pd.lstConstructionStages, pd.fldMap, pd.pm.Milestone_Complete_at_booking__c));
                        
                } else {
                    pdList.add(pd);
                }
                    percentage = '';
                amount =0;
                cgst = 0;
                sgst = 0;
                taxTotal = 0;
                tobePaid = '';
                count ++;   
            }
            // the final line item is just the totals;
              /*  for(Integer i=0; i>pdList.size(); i++){
                    if(pdList[i].tobePaid == 'Grand Total'){
                        pdList.remove(i);
                    }
                }*/
                pdList.add(new PlanDetailWrapper(null,null, 'Grand Total',overallPercentage, string.valueOf(overallPercentage) +'%', overallAmountTotal, InFormat(overallAmountTotal),InFormat(overallTaxTotal),inFormat(overallTotal), true,false, NULL, NULL, false));
        }
        for(PlanDetailWrapper pdd : pdList){
            system.debug('pdItem print by vikas:::: '+pdd);
        }
        return pdList;
   }
   public static void insertCustomerPaymentPlan(List<PlanDetailWrapper> pwdList, Id planId, Project__c p, Unit__c u, Opportunity o, quotation__c q, Map<String, Decimal> allChargesMap){
        List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
        if(pwdList != null &&  !pwdList.isEmpty()) {
            for(PlanDetailWrapper pw :pwdList) {
                if(pw.pm != null) {
                    pw.pm.Quotation__c  = q.Id;
                    pmList.add(pw.pm);
                }
            }
            insert pmList;
        }
   }
 
    public static List<Discount__c> getProjectLevelDiscounts(Id projectId) {
            List<Discount__c> dList = new List<Discount__c>();
            dList = [Select Id, Name, Type__c, Applied__c, Start_Date__c, End_Date__c, Editable__c, Lumpsum_Amount__c, PSF_Amount__c, Percentage_of_AV__c, Reason__c from Discount__c where Project__c = :projectId and start_date__c <= TODAY and (end_date__c = null OR end_date__c >= TODAY) ];
            return dList;
    }   
    
    // calculate NPV of the money based on the payment plan
    public static Decimal calculateNPV(List<planDetailWrapper> pwList , Id projId){
            Decimal NPV = 0.0;
            Decimal NPVDayRate = 0;
            Integer daysBetween =0; 
            Decimal NPVofMoney = 0.0;
            Decimal TotalNPV = 0.0;
            List<Project__c> p = [Select Id, Address__c, NPV__c , Name from Project__c where Id =: projId ];      
            //system.debug('p size:: '+ p.size());   
            if(p.size() == 1) {
                NPV = p[0].NPV__c;
                NPVDayRate = (NPV/365/100).setscale(18, RoundingMode.HALF_UP) + 1;
            }
            System.debug('NPV:' + NPV + NPVDayRate);
            if(NPV != 0) {
                for(PlanDetailWrapper pw : pwList) {
                    NPVOfMoney =  0.0;
                 //   System.debug('plan wrapper list:' + pw);
                    if(pw.pm.Milestone_Due_Date__c != null) {
                        daysBetween = system.today().DaysBetween(pw.pm.Milestone_Due_Date__c);
                        System.debug('Days between:' + daysBetween);
                        NPVofMoney = pw.milestoneAmount/NPVDayRate.pow(daysBetween);
                        System.debug('NPV of money:' + NPVOfMoney);
                        TotalNPV = TotalNPV + NPVofMoney;
                    }
                }
              //  System.debug('Total NPV:' + TotalNPV);
            
            }
            return (TotalNPV.setscale(0,RoundingMode.HALF_UP));
    }
    
    // method for formatting the currency details to Indian Commas Format
    public static String INFormat(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        Decimal tempMoney = money;
        String m0 = tempMoney.setscale(2,RoundingMode.HALF_UP).toPlainString();
        String decimalPart;
        List<String> tempStr = new List<String>();
        if(String.isNotBlank(m0)) {
            tempStr = m0.split('\\.');
            if(tempStr != null && tempStr.size() == 2) {
              decimalPart = tempStr[1];
            }
        }        
        //String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String m1 = tempStr[0].reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);
         /*   if(i==2) { // Commented by Neha on 11/01/19
                mF += ',';
            }*/
            if(i==2 || i==5 || i==8 || i==11 || i==14) { // Changed by Neha on 11/01/19 to convert in Dubai commas format
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        if(String.isNotBlank(decimalPart)) 
           mf = mf + '.'  + decimalPart;
        
        if(!negative)
            mf =  mf;
        else
            mf = '- ' + mf;
          return mf;
    }
    
    public static String INFormatForNPV(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        Decimal tempMoney = money;
        String m0 = tempMoney.setscale(3,RoundingMode.HALF_UP).toPlainString();
        String decimalPart;
        List<String> tempStr = new List<String>();
        if(String.isNotBlank(m0)) {
            tempStr = m0.split('\\.');
            if(tempStr != null && tempStr.size() == 2 ) {
              decimalPart = tempStr[1];
            }
        }
        
        String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);
        /*    if(i==2) { // Commented by Neha on 11/01/19
                mF += ',';
            } */
            if(i==2 || i==5 || i==8 || i==11 || i==14) { // Changed by Neha on 11/01/19 to convert in Dubai commas format
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        if(String.isNotBlank(decimalPart)) 
           mf = mf + '.'  + decimalPart;
        
        if(!negative)
            mf =  mf;
        else
            mf = '- ' + mf;
          return mf;
    }
 // Method Added by Neha on 11/01/19 Starts Here for formatting the currency details to Dubai Commas Format
 // No decimals, Rounded up.   
    public static String INFormatR(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        String m1 = String.valueOf(math.abs(money.setscale(0, RoundingMode.HALF_UP))).reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i, i+1);        
            if(i==2 || i==5 || i==8 || i==11 || i==14) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }   
        if(!negative)
            mf =  mf;
        else
            mf = '- ' + mf;
          return mf;
    }  
  // Method Added by Neha on 11/01/19 Ends Here for formatting the currency details to Dubai Commas Format
     
    ///// Below method Added by Neha on 26/3/19 to print Installment on ViewDemand
    public static String getinstallmentDetails(Decimal j, Decimal sizeOfPM, String milestoneName){
    
    String installmentName;
    
        if(milestoneName == 'On Booking date'){
            installmentName = 'Booking Amount';
        }
        else if(j == 2){
            installmentName = 'First Installment';              
        }
        else if(j == 3){
             installmentName = 'Second Installment';              
        }
        else if(j == 4){
             installmentName = 'Third Installment';              
        }
        else if(j == 5){
             installmentName = 'Fourth Installment';              
        }
        else if(j == 6){
             installmentName = 'Fifth Installment';              
        }
        else if(j == 7){
             installmentName = 'Sixth Installment';              
        }
        else if(j == 8){
             installmentName = 'Seventh Installment';              
        }
        else if(j == 9){
             installmentName = 'Eighth Installment';              
        }
        else if(j == 10){
             installmentName = 'Ninth Installment';              
        }
        else if(j == 11){
             installmentName = 'Tenth Installment';              
        }
        else if(j == 12){
             installmentName = 'Eleventh Installment';              
        }
        else if(j == 13){
             installmentName = 'Twelfth Installment';              
        }
        else if(j == 14){
             installmentName = 'Thirteenth Installment';              
        }
        else if(j == 15){
             installmentName = 'Fourteenth Installment';              
        }
        else if(j == 16){
             installmentName = 'Fifteenth Installment';              
        }
        else if(j == 17){
             installmentName = 'Sixteenth Installment';              
        }
        else if(j == 18){
             installmentName = 'Seventeenth Installment';              
        }
        if(j == 19){
             installmentName = 'Eighteenth Installment';              
        }
        else if(j == 20){
             installmentName = 'Nineteenth Installment';              
        }
        else if(j == 21){
             installmentName = 'Twentieth Installment';              
        }
        else if(j == 22){
             installmentName = 'Twenty-First Installment';              
        }
        else if(j == 23){
             installmentName = 'Twenty-Second Installment';              
        }
        else if(j == 24){
             installmentName = 'Twenty-Third Installment';              
        }
        else if(j == 25){
             installmentName = 'Twenty-Fourth Installment';              
        }
        else if(j == 26){
             installmentName = 'Twenty-Fifth Installment';              
        }
        else if(j == 27){
             installmentName = 'Twenty-Sixth Installment';              
        }
        else if(j == 28){
             installmentName = 'Twenty-Seventh Installment';              
        }
        else if(j == 29){
             installmentName = 'Twenty-Eighth Installment';              
        }
        else if(j == 30){
             installmentName = 'Twenty-Ninth Installment';              
        }
        else if(j == 31){
             installmentName = 'Thirtieth Installment';              
        }
        else if(j == 32){
             installmentName = 'Thirty-First Installment';              
        }
        else if(j == 33){
             installmentName = 'Thirty-Second Installment';              
        }
        else if(j == 34){
             installmentName = 'Thirty-Third Installment';              
        }
        else if(j == 35){
             installmentName = 'Thirty-Fourth Installment';              
        }
        else if(j == 36){
             installmentName = 'Thirty-Fifth Installment';              
        }
        else if(j == 37){
             installmentName = 'Thirty-Sixth Installment';              
        }
        else if(j == 38){
             installmentName = 'Thirty-Seventh Installment';              
        }
        else if(j == 39){
             installmentName = 'Thirty-Eighth Installment';              
        }
        else if(j == 40){
             installmentName = 'Thirty-Ninth Installment';              
        }
        else if(j == 41){
             installmentName = 'Fortieth Installment';              
        }
        else if(j == 42){
             installmentName = 'Forty-First Installment';              
        }
        else if(j == 43){
             installmentName = 'Forty-Second Installment';              
        }
        else if(j == 44){
             installmentName = 'Forty-Third Installment';              
        }
        else if(j == 45){
             installmentName = 'Forty-Fourth Installment';              
        }
        else if(j == 46){
             installmentName = 'Forty-Fifth Installment';              
        }
        else if(j == 47){
             installmentName = 'Forty-Sixth Installment';              
        }
        else if(j == 48){
             installmentName = 'Forty-Seventh Installment';              
        }
        else if(j == 49){
             installmentName = 'Forty-Eighth Installment';              
        }
        else if(j == 50){
             installmentName = 'Forty-Ninth Installment';              
        }
        else if(j == 51){
             installmentName = 'Fiftieth Installment';              
        }
        if(j == sizeOfPM && milestoneName != 'On Booking date'){
             installmentName = 'Final Installment';  
        }    
    return installmentName; 
    }
    
    
    public class PlanDetailWrapper {
            public Payment_Plan_Milestones__c ppm {get;set;}
            public Payment_Milestones__c pm {get;set;}
            public String Amount {get;set;}
            public String tax {get;set;}
            public String total {get;set;}
            public String percentage {get;set;}
            public Decimal percentageDecimal {get;set;}
            public Decimal milestoneAmount {get;set;}
            public String toBePaid {get;set;}
            public Boolean basicMilestone {get;set;}
            public Boolean allowedEdit {get;set;}
            public List<SelectOption> lstConstructionStages {get;set;}
            public String editedRowStyle {get;set;}
            public map<String,String> fldMap {get;set;}
            public String completedMilestoneColor {get;set;}
            
        public PlanDetailWrapper(Payment_Plan_Milestones__c ppm1, Payment_Milestones__c pm1, String tobePaid, Decimal value, String percentage, Decimal amt, String Amount, String tax, String total, Boolean basicMilestone,Boolean ae, List <SelectOption> listStage, Map <String, String> fm, Boolean cm) {
                this.ppm = ppm1;
                this.pm = pm1;
                this.tobePaid = tobePaid;
                this.amount = amount;
                this.tax = tax;
                this.percentage = percentage;
                this.percentageDecimal = value;
                this.total = total;
                this.basicMilestone = basicMilestone;
                this.allowedEdit = ae;
                this.editedRowStyle = '';
                this.milestoneAmount = amt;
                lstConstructionStages = new List<SelectOption>();
                if(listStage != null)   this.lstConstructionStages.addAll(listStage);
                
                fldMap = new Map<String,String>();              
                    if (fm != null && !fm.isEmpty()) this.fldMap.putAll(fm);
                if(cm)
                    this.completedMilestoneColor = 'background-color:#D7BF5E';
        }
        
        public PlanDetailWrapper(Payment_Plan_Milestones__c ppm1, Payment_Milestones__c pm1, String tobePaid, Decimal value, String percentage, Decimal amt, String Amount, String tax, String total, Boolean basicMilestone, List <SelectOption> listStage, Map <String, String> fm, Boolean cm) {
                this.ppm = ppm1;
                this.pm = pm1;
                this.tobePaid = tobePaid;
                this.amount = amount;
                this.tax = tax;
                this.percentage = percentage;
                this.percentageDecimal = value;
                this.total = total;
                this.basicMilestone = basicMilestone;
                this.editedRowStyle = '';
                this.milestoneAmount = amt;
                lstConstructionStages = new List<SelectOption>();
                if(listStage != null)   this.lstConstructionStages.addAll(listStage);
                
                fldMap = new Map<String,String>();              
                    if (fm != null && !fm.isEmpty()) this.fldMap.putAll(fm);
                if(cm)
                    this.completedMilestoneColor = 'background-color:#D7BF5E';
        }
    }
}