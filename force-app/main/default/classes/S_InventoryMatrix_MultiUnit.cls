public   class S_InventoryMatrix_MultiUnit {
    public Unit__c unit {
        get;
        private set;
    }
    public String selectedTower {
        get;
        set;
    }
    public boolean showGenerateQuoteButton{get;set;}
    public String selectedVal {
        get;
        set;
    }
    public String selectedstatus {
        get;
        set;
    }
    public String SelectedClusterId {
        get;
        set;
    }
    public String SelectedProjectId {
        get;
        set;
    }
    
/*    public String selectedWingId
    {
        get;
        set;
    }*/
    
    public String SelectedProjectOpty {
        get;
        set;
    }
    public Boolean hideQuoteButton {	
        get;	
        set;	
    }
    public String selectedConf {
        get;
        set;
    }    
    public Boolean sold {
        get;
        set;
    }
    public Boolean open {
        get;
        set;
    }
    public Boolean booked {
        get;
        set;
    }
    public Boolean blocked {
        get;
        set;
    }
    public Boolean EOI{
        get;
        set;
    }
    public Boolean reserved {
        get;
        set;
    }
    public Boolean onebhk {
        get;
        set;
    }
    public Boolean twobhk {
        get;
        set;
    }
    public Boolean threebhk {
        get;
        set;
    }
    public Boolean fourbhk {
        get;
        set;
    }
    public Boolean fivebhk {
        get;
        set;
    }
    public Boolean unReleased {
        get;
        set;
    }
    public List < Decimal > floorAscSeqList {
        get;
        set;
    }
    public Map < Decimal, List < unitWrapper >> JMap {
        get;
        set;
    }
    public Map < Decimal, Boolean> JMapIsSelected {
        get;
        set;
    }
    public String oppId {get;set;}
    public  boolean isSalesOps {
        get;
        set;
    }
    public class unitWrapper{
        public Unit__c unit{get;set;}
        public boolean isSelected{get;set;}
        public unitWrapper(Unit__c unit){
            this.Unit = unit;
            this.isSelected = false;

        }
    }
    String projectsent = ApexPages.currentPage().getParameters().get('projectsent');
    String statussent = ApexPages.currentPage().getParameters().get('statussent');
    String towersent = ApexPages.currentPage().getParameters().get('towersent');
    List < String > s = new List < String > ();
    List < User > currentuser = [Select Id,Name,Email,Profile.Name from User where Id=:userinfo.getuserId()];
    Boolean includeLaunchSetup = false;
    //public String selectedVal = ApexPages.currentPage().getParameters().get('optyProject');
    public S_InventoryMatrix_MultiUnit () {
      JMapIsSelected = new Map<Decimal,Boolean>();
      SelectedProjectOpty = ApexPages.currentPage().getParameters().get('optyProject');
      showSelectedUnitsSection = false;
      showGenerateQuoteButton = false;
      listOfUnitSelected =new Set<Unit__c>();
      listOfUnitNameSelected =new Set<String>();
      oppId = ApexPages.currentPage().getParameters().get('oppid');	
      isSalesOps = false;
       /*if(userinfo.getProfileId()  == system.label.Sales_Ops_Profile_Id
       || userinfo.getProfileID() == [select id from profile where name = 'Sales Operation'].id){
            isSalesOps = true;
        }*/
      if (oppId != null) {	
          Opportunity[] oppList = [select id,Unit__r.Unit_Status__c, Booking__r.Status__c from Opportunity where id =:oppId and  (unit__r.Unit_Status__c = 'Available' or unit__c = null) and (Booking__r.status__c = 'Cancelled' or Booking__c = null) ];	
          if (!oppList.isEmpty()) {	
              hideQuoteButton = false;	
          } else {	
              hideQuoteButton = true; 	
          }	
      }

      Inventory_Matrix_Configuration__mdt configMetadata = Inventory_Matrix_Configuration__mdt.getInstance('Record_Visiblity');
      
      List<String> allowedProfiles = configMetadata.Profiles_Allowed__c?.split(',');
      Set<String> allowedProfilesSet = new Set<String>();

      for(String prof : allowedProfiles) 
        allowedProfilesSet.add( prof.trim().toLowerCase() );

      includeLaunchSetup = allowedProfilesSet.contains(currentuser[0].Profile.Name.toLowerCase());
      
  }

  

    public List < SelectOption > getProjects {
        get {
            showGenerateQuoteButton = false;
          //  jMap = new Map < Decimal, List < unitWrapper >> ();
        listOfUnitNameSelected = new set<string>();
        listOfUnitSelected = new Set<unit__c>();
            
            List < SelectOption > optns = new List < Selectoption > ();
            List < Project__c > queryResult = new List < Project__c > ();
            if(SelectedProjectOpty != null) {
                queryResult = [Select Id, Name from Project__c where id =:SelectedProjectOpty and Unavailable_for_Inventory_Matrix__c = false];
                selectedVal = SelectedProjectOpty;
            }
            else {
                if( includeLaunchSetup ) {
                    queryResult = [Select Id, Name from Project__c WHERE Unavailable_for_Inventory_Matrix__c = false];
                } else {
                    queryResult = [Select Id, Name from Project__c WHERE Launch_Setup__c = false  and Unavailable_for_Inventory_Matrix__c = false];
                }
                optns.add(new SelectOption('', 'Select a Project'));
            }
            for (Project__c obj: queryResult) {
                optns.add(new SelectOption(obj.Id, obj.Name));
            }
            return optns;
        }
        set;
    }
    public List < SelectOption > getClusterNames {

        get {
            showGenerateQuoteButton = false;

            set < string > clusterSet = new set < string > ();
            List < SelectOption > ClusterOptions = new List < SelectOption > ();
            ClusterOptions.add(new SelectOption('0', 'Select a Sub Project'));
            if (selectedVal != null ) {
                List <Cluster__c> queryResult = new List<Cluster__c>();
                if( includeLaunchSetup ) {
                    queryResult = [select Id, name, Project__c from Cluster__c Where Project__c = : selectedVal and Unavailable_for_Inventory_Matrix__c = false];
                } else {
                    queryResult = [select Id, name, Project__c from Cluster__c Where Project__c = : selectedVal AND Launch_Setup__c = false and Unavailable_for_Inventory_Matrix__c = false];
                }
                for (Cluster__c c: queryResult) {
                    if (!clusterSet.contains(c.name.tolowercase())) {
                        ClusterOptions.add(new SelectOption(c.Id, c.name));
                    }
                    clusterSet.add(c.name.tolowercase());
                }
            }
            return ClusterOptions;
        }
        set;

    }
   

    public List < SelectOption > getTowers {

        get {
            listOfUnitNameSelected = new set<string>();
            listOfUnitSelected = new Set<unit__c>();
            showGenerateQuoteButton = false;
 
            List < SelectOption > options = new List < Selectoption > ();
            options.add(new SelectOption('', 'Select a Tower'));
            if (SelectedClusterId != null ) {
                List<Tower__c> qResult = new List<Tower__c>();
                
                if( includeLaunchSetup ) {
                    qResult = [Select Id, Name from Tower__c where Cluster__r.id = : SelectedClusterId and Unavailable_for_Inventory_Matrix__c = false order by Name asc];
                } else {
                    qResult = [Select Id, Name from Tower__c where Cluster__r.id = : SelectedClusterId  AND Launch_Setup__c = false  and Unavailable_for_Inventory_Matrix__c = false order by Name asc];
                }
                System.debug('TOwer::: ' + qResult);
                for (Tower__c obj1: qResult) {
                    options.add(new SelectOption(obj1.Id, obj1.Name));
                }
            }
            return options;
        }
        set;
    }  
        
    
 /*   public List <SelectOption> getWings
    {
        get{
            List <SelectOption> options = new List <SelectOption> ();
            options.add(new SelectOption('','Select a Wing'));
            if(selectedTower != null)
            {
                List<Wing__c> qResult = new List <Wing__c> ([Select Id, Name from Wing__c where Tower__r.id = : selectedTower order by Name asc]);
                for (Wing__c obj : qResult)
                {
                    options.add(new SelectOption(obj.id , obj.Name));
                }
            }
            return options;
        }
        set;
    }*/

   public List < SelectOption > getProjectunittype {
        get {
            listOfUnitNameSelected = new set<string>();
            listOfUnitSelected = new Set<unit__c>();
             
            List < SelectOption > unitopt = new List < Selectoption > ();
            unitopt.add(new SelectOption('', 'Select Configuration'));

            if (selectedVal != null && selectedTower != null ) {

                List < Project_Unit_Type__c > conf = new List < Project_Unit_Type__c > ();

                //if( includeLaunchSetup ) {
                    conf = [Select Id, Name from Project_Unit_Type__c Where Project__c = : selectedVal];
                /*} else {
                    conf = [Select Id, Name from Project_Unit_Type__c Where Project__c = : selectedVal  AND Launch_Setup__c = false];
                }*/
                system.debug(' project unit query>>>>>' + conf);

                for (Project_Unit_Type__c unit: conf) {
                   unitopt.add(new SelectOption(unit.Id, unit.Name));
                }
            }
            system.debug('unitopt >>>>' + unitopt);
            return unitopt;
        }
        set;
    }


    public List < Decimal > floorDescSeqList {
        get {
            
            if(selectedTower != towersent || selectedVal != projectsent){
            towersent = selectedTower;
       //     String wingsent = selectedWingId;
            projectsent = selectedVal;
            JMap = new Map < Decimal, List < unitWrapper >> ();
            floorAscSeqList = new List < Decimal > ();
            floorDescSeqList = new List < Decimal > ();
            listOfUnitNameSelected = new set<string>();
        listOfUnitSelected = new Set<unit__c>();
        
         
            //system.debug('towersent ..' + towersent);
            system.debug('projectsent ..' + projectsent);
            Set<String> profileNamesList = new Set<String>{'System Administrator','Sales Operation With Area Update Access','Sales Operation'}; 
			Profile p = [select id,Name from Profile where id=:Userinfo.getProfileid()];
            isSalesOps = false;
            if( profileNamesList.contains(p.Name)){
                isSalesOps = true;
            }

            if (towersent != null && projectsent != null) {
                List < Unit__c > unitlist = new List<Unit__c>();
                
                if( includeLaunchSetup ) {
                    unitlist = [SELECT Id, Name, Floor__c, Configuration__c, Unit_Status__c, Customers__c, Project_Unit_Type__r.Name, Floor_No_to_print__c,Not_Available_for_Sales__c,For_Direct_Sale__c from Unit__c 
                                where Tower__c = :towersent  
                                and Unavailable_for_Inventory_Matrix__c = false
                                and Unit_Status__c != 'Unreleased'
                                order by Floor__c DESC, Name ASC];
                	
                    if(profileNamesList.contains(p.Name)){
                    	unitlist = [SELECT Id, Name, Floor__c, Configuration__c, Unit_Status__c, Customers__c, 
                                    Project_Unit_Type__r.Name, Floor_No_to_print__c,Not_Available_for_Sales__c ,For_Direct_Sale__c
                                    from Unit__c where Tower__c = :towersent  
                                    and Unavailable_for_Inventory_Matrix__c = false  
                                    and Unit_Status__c != 'Unreleased'
                                    order by Floor__c DESC, Name ASC];
                	}
                    
                } else {
                    unitlist = [SELECT Id, Name, Floor__c, Configuration__c, Unit_Status__c, Customers__c, Project_Unit_Type__r.Name, Floor_No_to_print__c,Not_Available_for_Sales__c,For_Direct_Sale__c from Unit__c 
                                where Tower__c = :towersent  and Unavailable_for_Inventory_Matrix__c = false 
                                and Launch_Setup__c = false 
                                and Unit_Status__c != 'Unreleased'
                                order by Floor__c DESC, Name ASC];
                	
                    if(profileNamesList.contains(p.Name)){
                    	unitlist = [SELECT Id, Name, Floor__c, Configuration__c, Unit_Status__c, Customers__c, 
                                    Project_Unit_Type__r.Name, Floor_No_to_print__c,Not_Available_for_Sales__c ,For_Direct_Sale__c
                                    from Unit__c where Tower__c = :towersent  
                                    and Unavailable_for_Inventory_Matrix__c = false 
                                    and Launch_Setup__c = false 
                                    and Unit_Status__c != 'Unreleased'
                                    order by Floor__c DESC, Name ASC];
                	}
                
                }
                System.debug('UNIT LIST:' + unitList);

                for (Unit__c thisUnit: unitList) {
                    if(thisUnit.Unit_Status__c== 'Available' || isSalesOps == true){
                    if (JMap.containsKey((thisUnit.Floor__c))) {
                        JMap.get((thisUnit.Floor__c)).add(new unitWrapper(thisUnit));
                    } else {
                        List < unitWrapper > unitList1 = new List < unitWrapper > ();
                        unitList1.add(new unitWrapper(thisUnit));
                        
                        JMap.put((thisUnit.Floor__c), unitList1);
                        JMapIsSelected.put(thisUnit.Floor__c,false);
                    }
                }
                }

                floorAscSeqList.addAll(JMap.keySet());
                floorAscSeqList.sort();

                for (Integer i = floorAscSeqList.size() - 1; i >= 0; i--) {
                    floorDescSeqList.add(floorAscSeqList.get(i));
                }
                System.debug('FLOOR SEQ:' + floorDescSeqList.size());
                System.debug('J Map:' + JMap);
                

            }
        }
            return floorDescSeqList;
        }
        set;


    }
    public void getClients(){
        listOfUnitNameSelected = new set<string>();
        listOfUnitSelected = new Set<unit__c>();
    }
    public void checkAllUnitsForFloor(){
        showGenerateQuoteButton = true;
        String str = ApexPages.currentPage().getParameters().get('floorId');

        Decimal floorId = Decimal.valueOf(str);
        if(JMap.containsKey(floorId)){
            for(UnitWrapper unitWrap : JMap.get(floorId)){
                if(unitWrap.unit.unit_status__c == 'Hold' || unitWrap.unit.unit_status__c == 'Available' || isSalesOps == true){
                    unitWrap.isSelected = !unitWrap.isSelected;
                    if(unitWrap.isSelected == true){
                       list<payment_request__c> pr = InventoryMatrix_Utility.getPrs(unitIdSelected);
                        if(pr != null && pr.size()>0 && pr[0].ownerId != UserInfo.getUserId()){
                            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'error');
                            ApexPages.addMessage(msg);
                            unitWrap.isSelected = false;
                        }
                        else{
                            listOfUnitSelected.add(unitWrap.unit);
                            listOfUnitNameSelected.add(unitWrap.unit.name);
                        }
                    }else{
                        listOfUnitSelected.remove(unitWrap.unit);
                        listOfUnitNameSelected.remove(unitWrap.unit.name);
                       
                    }
                }
                
            }
            JMapIsSelected.put(floorId,true);
        }
        if(listOfUnitSelected.size() > 0){
            showGenerateQuoteButton = true;
        }else{
            showGenerateQuoteButton = false;
        }
        system.debug( JMap.get(floorId));
        
    }
    public String unitIdSelected { get; set; }
    public Decimal FloorSelected {get;set;}
    public Set<Unit__C> listOfUnitSelected {get;set;}
    public Set<string> listOfUnitNameSelected {get;set;}
    public boolean showSelectedUnitsSection {get;set;}
    public void selectUnitForQuote(){
        
        system.debug('unitIdSelected==='+unitIdSelected);
        system.debug('FloorSelected==='+FloorSelected);
        if(JMap.containsKey(FloorSelected)){
            for(UnitWrapper unitWrap : JMap.get(FloorSelected)){
                if(unitWrap.unit.id == unitIdSelected){
                    
                    
                    system.debug('unit updated'+unitWrap.unit.name);
                    if(unitWrap.isSelected == true){
                        list<payment_request__c> pr = InventoryMatrix_Utility.getPrs(unitIdSelected);
                        string unitAllocatedSM = InventoryMatrix_Utility.getUnitAllocatedSM(unitIdSelected);
                        system.debug('pr ==>'+pr);
                        system.debug('~~~~isSalesOps:'+isSalesOps);
                        system.debug('~~~~pr.size():'+pr.size());
                        //system.debug('~~~~pr[0].ownerId:'+pr[0].ownerId);
                        system.debug('~~~~UserInfo.getUserId():'+UserInfo.getUserId());
                        system.debug('~~~~unitAllocatedSM:'+unitAllocatedSM);
                        if( isSalesOps == false && 
                        (pr.size() == 0 || ( pr.size()>0 && pr[0].ownerId != UserInfo.getUserId())) 
                        && (unitAllocatedSM != UserInfo.getUserId() && !String.isBlank(unitAllocatedSM))){
                            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, unitWrap.unit.name +' is not available for selection as this is put on hold by different user');
                            ApexPages.addMessage(msg);
                            unitWrap.isSelected = false;
                        }
                        else{
                            listOfUnitSelected.add(unitWrap.unit);
                            listOfUnitNameSelected.add(unitWrap.unit.name);
                        }
                                                
                    }else{
                        system.debug('unit updated, i am here to remove');
                        listOfUnitSelected.remove(unitWrap.unit);
                        listOfUnitNameSelected.remove(unitWrap.unit.name);
                       
                    }
                    break;
                }
                
            }
        }
        if(listOfUnitSelected.size() > 0){
            showGenerateQuoteButton = true;
        }else{
            showGenerateQuoteButton = false;
        }
    }
    public void showSelectedUnits(){
        showGenerateQuoteButton = false;
        showSelectedUnitsSection = true; 
        listOfUnitSelected = new Set<Unit__c>();
        listOfUnitNameSelected = new Set<String>();
        for(decimal floorId : jMap.keySet()){
            for(UnitWrapper unitWrap : JMap.get(floorId)){
                
                if(unitWrap.isSelected == true){
                    listOfUnitSelected.add(unitWrap.unit);
                    listOfUnitNameSelected.add(unitWrap.unit.name);
                }
            }
        }
       
    }
    public Pagereference confirmQuoteGenerate(){
        List<string> tempList = new List<String>();
        for(unit__c u : listOfUnitSelected){
            tempList.add(u.id);
        }
        String stringOfUnitSelected =string.join(tempList,',');
        Pagereference pr = new Pagereference('/apex/CreateQuoteMultiUnit?oppId=' +oppId+'&stringOfUnitSelected='+stringOfUnitSelected);
        return pr;
    }
    public void backToInventoryMatrix(){
        showGenerateQuoteButton = true;
        showSelectedUnitsSection = false;
    }
    
}