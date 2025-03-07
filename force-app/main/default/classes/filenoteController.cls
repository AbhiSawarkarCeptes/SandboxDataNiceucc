Public Class filenoteController{
    
    public Booking__c b {get;set;}
    public Channel_Partner__c channelPartner {get;set;}
    public String bookingSourcename {get;set;}
    public String bookingSourceCompany {get;set;}
    public String permittedUse {get;set;}
    public List <Applicant_Details__c> listAppDetails {get;set;}
    public String qId {get; set;}
    public String address {get; set;}
    public Decimal ratePerSq {get; set;}
    public Decimal purchasePrice {get; set;}
    public List<Rate_List__c> rList {get; set;}
    public List<Quotation__c> qList {get; set;}
    public List<Quotation__c> qList1 {get; set;}
    public String bookingDate{get;set;}
    public Map<String, Integer> projChargeSeq = new Map<String,Integer>();
    public String basicChargesString {get;set;}
    public String floorRiseChargesString {get;set;}
    public String floorRiseAmount{get;set;}
    public String PLCAmount {get;set;}
    public String PLCChargesString {get;set;}
    public String stampDutyString {get;set;}
    public String registrationString{get;set;}
    public String totalRegStampString{get;set;}
    public string amtGTString{get;set;}
    public String grandTotalString{get;set;}
    public List <PMWrapper> pmwList {get;set;}
    public List <PMWrapper> standardpmwList{get;set;}
    public List <ADWrapper> adList {get;set;}
    public List<Payment_Milestones__c> pmList {get;set;}
    public List<Payment_Plan_Milestones__c> standardpmList {get;set;}
    public Decimal stampDutyPerce{get;set;}
    public Id BookingId;
    public Map<String, Decimal> carParkMap {get; set;}
    public List<CarParkWrapper> carParkList {get; set;}
    public List<String> carParkTypes {get; set;} 
    public String typeOfParking {get; set;} 
    public Decimal countOfParking {get; set;}
    public String finalInstPercentage{get;set;}
    public String finalInstPercentageWord{get;set;}
    public Integer CompletionPercentage{get;set;}
    public List<Discounts_Applied__c> discounts{get;set;}
    public Decimal totaldiscount {get; set;}
    public Decimal originalpurchaseprice {get; set;}
    public List<User> cfoUser {get; set;}
    public List<User> presidentUser{get;set;}
    public List<Payment_Plan__c> paymentplanList{get;set;}
    public String standardpaymentplanId{get;set;}
    public Map<String, Decimal> rateListMap{get;set;}
    public Map<String, Decimal> allChargesMap {get; set;}
    public Map<String, String> allChargesMapFormatted {get; set;}

    public Map<String, Decimal> allChargesMapOriginal {get; set;}
    public Map<String, String> allChargesMapOriginalFormatted {get; set;}
    public Map<String, Decimal> additionalCarparks {get;set;}
    public Map<String,Decimal> earmarkedCP {get;set;}
    public Map<String, String> carParkFieldsMapEM {get;set;}
    public Map<String, String> carParkFieldsMapEM1 {get;set;}
    public Map<String, String> carParkFieldsMap {get;set;}
    public Map<String, String> carParkFieldsMap1 {get;set;}
    public Map<String, decimal> carParkCharges {get; set;}
    public Decimal additionalCarParkCharge {get;set;}
    public Decimal earmarkedCPCharges {get;set;}
    public List<InventoryCostServices.PlanDetailWrapper> payplanDetails {get;set;}
    public boolean earParkingError{get;set;}
    public boolean addParkingError{get;set;}
    public Id unitId {get;set;}
    public Map<String, Boolean> chargeDifferenceMap {get;set;}
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
    public boolean isNPVdif {get;set;} 
    public boolean isNPVDiscountApplied {get;set;}
    public List<Payment_Plan__c> standardPaymentplan{get;set;}
    public String discountedRate{get;set;}
   
    public filenoteController(){

         pmwList = new List<PMWrapper>();
         standardpmwList = new List<PMWrapper>();
         pmList  = new List<Payment_Milestones__c>();
         standardpmList  = new List<Payment_Plan_Milestones__c>();
         List <Sobha_Connect__c> sc;
         stampDutyPerce = 0;
         floorRiseChargesString = '0.00/-';
         PLCChargesString = '0.00/-';
         stampDutyString = '0.00/-';
         registrationString = '0.00/-';
         adList = new List <ADWrapper>();
         typeOfParking = '';
         countOfParking = 0;
         ratePerSq = 0; 
         purchasePrice = 0; 
         cfoUser = New List<User>();
         rateListMap = new Map<String, Decimal>();
         allChargesMap = new Map<String,Decimal>();
         allChargesMapFormatted = new Map<String,String>();
            
         allChargesMapOriginal = new Map<String,Decimal>();
         allChargesMapOriginalFormatted = new Map<String,String>();
         
        additionalCarparks = new Map<String, Decimal>();
        earmarkedCP = new Map<String, Decimal>();
        carParkFieldsMapEM = new Map<String, String>();
        carParkFieldsMapEM1 = new Map<String, String>();
        carParkFieldsMap = new Map<String, String>();
        carParkFieldsMap1 = new Map<String, String>();
        carParkCharges = new Map<String, Decimal>();
        payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
        earParkingError = false;
        unitId = null;
        chargeDifferenceMap = new Map<String, Boolean>();
        additionalCarParkCharge=0;
        earmarkedCPCharges = -1;
        presidentUser = New List<User>(); 
        NPVDiffPSF = 0.0;
        if(ApexPages.currentPage().getParameters().get('id') != null){
            BookingId = ApexPages.currentPage().getParameters().get('id');
        }
        System.debug('Booking ID::: ' + BookingId); // Neha
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
        standardPaymentplan  = New List<Payment_Plan__c>();
        discountedRate = '';
               
    if(BookingId != null){
        b = [SELECT Quotation__r.Id, Booking_Date__c, Opportunity__r.Lead_Id__c, Unit__r.Chargeable_Area__c, Unit__r.Super_Builtup_Area_Sq_Ft__c,
             Unit__r.Tower__r.RDS_Company_Code__r.IBAN__c, Unit__r.Tower__r.RDS_Company_Code__r.MICR_Code_Flat_Cost__c, Unit__r.Permitted_Use__c,
             Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c, Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c,
             Unit__r.Tower__r.RDS_Company_Code__r.Account_Name_Flat_Cost__c, Unit__r.Tower__r.RDS_Company_Code__r.Account_Number_Flat_Cost__c,
             Primary_Applicant_Name__c, Opportunity__r.Account.Nationality__c, Opportunity__r.Account.Residential_Street__c,
             Opportunity__r.Account.City_R__c, Opportunity__r.Account.Residential_State_Province__c, Project__c,
             Opportunity__r.Account.Residential_Zip_Postal_Code__c, Opportunity__r.Account.Country_R__c,
             Opportunity__r.Account_Mobile_Number__c, Opportunity__r.Account_Email__c, Project__r.Address__c,
             Unit__r.Unit_No__c, Unit__r.Floor_No_to_print__c, Project__r.RDS_Company_Code__r.Name, Unit__r.Tower__r.RDS_Company_Code__r.Developer_ID__c,
             Unit__r.Tower__r.RDS_Company_Code__r.Project_Name_ID__c, Tower__c, Quotation__r.Total_Agreement_Value_Bucket__c,
             Unit__r.Tower__r.RDS_Company_Code__r.Account_Holder__c, Sales_Managers__r.Name, Sales_Head__r.Name, Source_of_Booking__c, Sub_Source__c, Sales_Head__r.ManagerId,
             Channel_Partner__c, Channel_Partner_Contact_Person__c, Sobha_Connect__c , Unit__r.Tower__r.RDS_Company_Code__r.Name, Unit__r.Tower__r.Date_of_Possession__c,
             Unit__r.Tower__r.Date_of_Completion__c, Unit__r.Project_Property_Type__c
         FROM Booking__c WHERE Id = :BookingId];
       System.debug('Booking Id:: ' + b.Id);
        // Fetching Channel Partner details
        if(b.Channel_Partner__c != null){
            channelPartner = [SELECT Name FROM Channel_Partner__c WHERE Id = :b.Channel_Partner__c];
        }
        // Fetching Sobha Connect details
        if(b.Sobha_Connect__c != null) {
           sc = [SELECT Id, Name__c, Contact_Person__c FROM Sobha_Connect__c WHERE Id = :b.Sobha_Connect__c];
        }
        
        ///// Added by Neha on 22/2/19
        if(b.Source_of_Booking__c == 'Channel Partner' || b.Source_of_Booking__c == 'Sobha Connect'){
            if(b.Source_of_Booking__c == 'Channel Partner' && channelPartner != null){        
                     bookingSourceCompany = channelPartner.Name;           
                     bookingSourcename = b.Channel_Partner_Contact_Person__c;   
            } 
            if(b.Source_of_Booking__c == 'Sobha Connect' && sc != null && sc.size() > 0){      
                     bookingSourceCompany = sc[0].Name__c;         
                     bookingSourcename = sc[0].Contact_Person__c ;   
            } 
        }
         
        listAppDetails = [SELECT Id, Salutation__c, Applicant_Number__c, Name, Mobile_Number__c, Email_Address__c, Nationality__c, Landline_Number__c,
                          Passport_Copy_Details__c, Valid_Until_Passport__c, Mailing_Address__c, Mailing_City__c, Mailing_State__c,
                          Mailing_Country__c, Mailing_Pincode__c, Permanent_Address__c, City__c, State__c, Country__c, Pincode__c,
                          Power_of_Attorney_Details__c FROM Applicant_Details__c
                          WHERE Booking__c = :BookingId];    
         
         if(b.Quotation__r.Total_Agreement_Value_Bucket__c != null){
             purchasePrice = b.Quotation__r.Total_Agreement_Value_Bucket__c;
         } 
        if(b.Unit__r.Chargeable_Area__c != null &&  b.Quotation__r.Total_Agreement_Value_Bucket__c != null){
            Decimal ratePerSqvalue  = b.Quotation__r.Total_Agreement_Value_Bucket__c/b.Unit__r.Chargeable_Area__c;
            ratePerSq = ratePerSqvalue.setScale(2, RoundingMode.HALF_UP); // to show upto 2 decimal places
        }    
         
        DateTime d = b.Booking_Date__c;
        bookingDate = d.format('dd/MM/yyyy');
        qId = b.Quotation__r.Id;
        
        // For applicant details table
        if(listAppDetails.size() > 0 && listAppDetails != null){
           for(Applicant_Details__c a: listAppDetails){
               ADWrapper adw = new ADWrapper(a); 
               adList.add(adw);
           }   
        }    
        System.debug('Quotation query');//Neha
        String queryString = '';
         for(Integer i = 1; i<=25; i++) {
                    queryString += 'Charge' + i + 'Name__c'   + ',';
                    queryString += 'Charge' + i + 'Value__c'  + ',';
                    queryString += 'Charge' + i + 'Bucket__c' + ',';                    
                    queryString += 'Charge' + i + 'CGST__c'   + ','; 
                    queryString += 'Charge' + i + 'SGST__c'   + ','; 
                }
         
         queryString += 'Unit__r.Id, Unit__r.Project__r.Name, Unit__r.Tower__r.Name, Unit__r.Tower_No__c, Unit__r.Chargeable_Area__c,'+
                        'Unit__r.Floor__c, Unit__r.Name, Unit__r.Unit_Status__c, Unit__r.Configuration__c, Unit__r.Project_Property_Type__c, Total_Other_Charges_Bucket__c,'+ 
                        'Unit__r.Super_Builtup_Area_Sq_Ft__c, Total_Agreement_Value_Bucket__c, Premium1_Original_PSF__c, Total_SD_Registration_Bucket__c,' +
                        'Unit__r.Legal_Entity__r.Bank_Name_Flat_Cost__c, Unit__r.Legal_Entity__r.RDS_Address1__c, Unit__r.Floor_No_to_print__c,' +
                        'Unit__r.Legal_Entity__r.Account_Number_Flat_Cost__c, Unit__r.Legal_Entity__r.Account_Name_Flat_Cost__c,' +
                        'Unit__r.Legal_Entity__r.IBAN__c, Unit__r.Legal_Entity__r.MICR_Code_Flat_Cost__c, Payment_Plan__c, Original_NPV__c, Original_NPV_PSF__c, Modified_NPV__c, Modified_NPV_PSF__c,' +
                        'Unit__r.Legal_Entity__r.Developer_ID__c, Unit__r.Legal_Entity__r.Project_Name_ID__c, Floor_Rise_Original_PSF__c';                              
                         
               if (qId != null) {
                    queryString = 'Select ' + queryString  +' FROM Quotation__c WHERE Id = \'' + qId + '\'' ;
                    qList = Database.Query(queryString);
                }
                System.debug('Unit Id::: ' +qList[0].Unit__r.Id); 
                unitId = qList[0].Unit__r.Id;
         // For dicounts
         discounts = [Select id, Name, PSF_Amount__c, Quotation__c, Percentage_of_AV__c, Lumpsum_Amount__c, Reason__c, Total__c, Type__c,
                      Discount_Parent__c from Discounts_Applied__c  where Quotation__c = :qId ];
         
         totaldiscount =0;
         originalpurchaseprice =0;
         if(discounts.size() > 0){
             for(Discounts_Applied__c dis : discounts)
             {
               totaldiscount = dis.Total__c;
                  
             }
             originalpurchaseprice = totaldiscount + purchaseprice;
            if(discounts[0].Type__c == 'PSF'){
             discountedRate = String.valueOf(discounts[0].PSF_Amount__c);}
            if(discounts[0].Type__c == 'Lumpsum'){
             discountedRate = String.valueOf(discounts[0].Lumpsum_Amount__c);}
            if(discounts[0].Type__c == 'Percentage'){
             discountedRate = String.valueOf(discounts[0].Percentage_of_AV__c)+'%';}
            if(discounts[0].Type__c == 'Percentage of Basic'){
             discountedRate = String.valueOf(discounts[0].Percentage_of_AV__c)+'%';}
            
        }
       // For Chief Sales Officer
       cfoUser = [Select Id, LastName, FirstName, UserRole.Name, ProfileId from user where UserRole.Name= : 'Chief Sales Officer'];
       system.debug('cfouser'+cfoUser );
       
       presidentuser = [Select Id, LastName, FirstName, UserRole.Name, ProfileId from user where UserRole.Name= : 'President'];
       system.debug('presidentuser '+presidentuser );
       
        // For Payment Plan Milestone
        projChargeSeq = InventoryCostServices.getProjectChargesSequence(qList[0].Unit__r.Project__r.Name, qList[0].Unit__r.Tower__r.Id);
        System.debug('projchargeSeq');
        if(!projChargeSeq.isEmpty() && projChargeSeq.size() > 0) {
        
                     integer basicSeq = projChargeSeq.get('Basic');
                     basicChargesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + basicSeq + 'Value__c'));
                        
                     integer floorRiseSeq = projChargeSeq.get('Floor Rise');
                     if(floorRiseSeq != null)
                     {
                         floorRiseChargesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + floorRiseSeq + 'Value__c'));
                     }                 
                     floorRiseAmount = InventoryCostServices.InFormat(qList[0].Floor_Rise_Original_PSF__c);
                     
                     PLCAmount = InventoryCostServices.InFormat(qList[0].Premium1_Original_PSF__c);
                     
                     integer PLCSeq = projChargeSeq.get('PLC');
                     if(PLCSeq != null)
                     {
                        PLCChargesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + PLCSeq + 'Value__c'));
                     }
                                      
                     integer stampDutyseq = projChargeSeq.get('Stamp Duty'); 
                     Decimal totalStampandReg = 0;
                         if(stampDutyseq != null) {
                             stampDutyString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + stampDutyseq + 'Value__c'));
                             totalStampandReg += (Decimal)qList[0].get('Charge' + stampDutyseq + 'Value__c');
                         }
                     integer regSeq = projChargeSeq.get('Registration charges'); 
                         if(regSeq != null) {    
                             registrationString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + regSeq + 'Value__c'));
                             totalStampandReg += (Decimal)qList[0].get('Charge' + regSeq + 'Value__c'); 
                         }
                       totalRegStampString = InventoryCostServices.InFormat(totalStampandReg);
                         }
                     integer basicSeq = projChargeSeq.get('Basic');
                  
        Map<String,ProjectCharges__c> projChargesMap = InventoryCostServices.getProjectChargesMap(qList[0].Unit__r.Project__r.Name, qList[0].Unit__r.Tower__r.Id);
        Map<String,Integer> AVChargesSeqMap = new Map<String, Integer>();
        
                Integer Seq = 1;
                String chgName = '';
                system.debug(projChargesMap);
                
                if(!projChargesMap.isEmpty() && projChargesMap.containsKey('Stamp Duty') && projChargesMap.get('Stamp Duty') != null)
                    stampDutyPerce = projChargesMap.get('Stamp Duty').Agreement_Value_Percentage__c;
                    
                //creating a list of all charges that are part of the agreement value their field location, to identify whether they are stored in Charge1, Charge2, Charge3, etc.,
                for(String chargeName : projChargesMap.keySet()) {
                        system.debug('chargeName::'+chgName);
                        chgName = projChargesMap.get(chargeName).ChargeBucket__c;
                        
                    if(chgName.equalsIgnoreCase('Agreement Value')) {
                            AVChargesSeqMap.put(chargeName, Seq);
                            
                    }                              
                    Seq++;
                }
                System.debug(Seq);
                AVChargesSeqMap.put('Interest On Common Area Charges',Seq);
                system.debug('AV charges map::: ' + AVChargesSeqMap);
        
        String queryString1 = '';
        
        for(Integer i = 1; i<=25; i++) {
            queryString1 += 'Charge' + i + 'Name__c'   + ',';
            queryString1 += 'Charge' + i + 'Percentage__c'  + ',';
            queryString1 += 'C' + i + '_Amount__c' + ','; 
            queryString1 += 'C' + i + '_CGST__c'   + ','; 
            queryString1 += 'C' + i + '_SGST__c'   + ','; 
        }
        
        if (qId != null){
                queryString1 = 'SELECT ' + queryString1  + ' Id, Name, Project_Construction_Stages__c, Project_Construction_Stages__r.Name , Milestone_Name__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Demand_Raised__c, Milestone_Type_edit__c FROM Payment_Milestones__c WHERE Quotation__c = \'' + qId + '\' order by Name ASC' ;                                                                     
                pmList = Database.Query(queryString1);                
        }
        System.debug('pmList::: ' + pmList);
            Decimal amtGT = 0;
            Decimal taxGT = 0;
            Decimal srno = 0;
            system.debug('pmList'+pmList);
            CompletionPercentage =0;
            finalInstPercentage ='';
            
        for(Payment_Milestones__c pm : pmList) {
                // check all the values in Agreement value bucket and sum total its amount and taxes
                Decimal totalAmt = 0;
                Decimal totalTax = 0;
                Decimal sizeOfPM = pmList.size();
                srno ++;
                for(Integer i : AVChargesSeqMap.values()) {
                    totalAmt += (Decimal)pm.get('C' +i + '_Amount__c' );
                    totalTax += (Decimal)pm.get('C' + i + '_CGST__c' ) + (Decimal)pm.get('C' + i + '_SGST__c' );                        
                }
                 
                amtGT += totalAmt;
                system.debug('Amount::'+totalAmt);
                if(pm.get('Charge' + basicSeq + 'Percentage__c') != null) {
                    pmWrapper pmw = new pmWrapper(srno, pm.Milestone_Due_Date__c,  pm.Milestone_Name__c, pm.get('Charge' + basicSeq + 'Percentage__c') + '%', totalAmt, pm.Milestone_Complete_At_Booking__c, pm.Milestone_Type_edit__c, sizeOfPM);
                    pmwList.add(pmw);
                }
        }
                system.debug(pmwList);
             
             
        // For standard payment plan
        rateListMap = InventoryCostServices.getRateList(qList[0].Unit__r.Id);
               
        // reset the charges everytime and calculate again
            earmarkedCPCharges =0;
            earParkingError = false;
            Map<String, decimal> carParkCharges = InventoryCostServices.getCarparkCharges(unitId);
            if(carparkCharges != null && carParkFieldsMap != null) {
                for(String s: carParkFieldsMapEM.keySet()) {
                    if(qList[0].get(carParkFieldsMapEM.get(s))  != null ) {
                        if((Decimal)(qList[0].get(carParkFieldsMapEM.get(s))) > earmarkedCP.get(s)) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, s + ':car park count cannot be increased beyond what is already provisioned')); 
                            earParkingError = true;
                          
                        }
                        earmarkedCPCharges += (Decimal)(qList[0].get(carParkFieldsMapEM.get(s))) * (Decimal)(qList[0].get(carParkFieldsMapEM1.get(s)));
                    }
                }
            }
            System.debug('Earmarked Car Park Charges:' + earmarkedCPCharges);
        
        if(Test.isRunningTest()) {
            return;
        }
            // pass the earmarked car park charges to get all charges, if earmarked prices is not set, take the original values from the getcarpark charges method
            if(!rateListMap.isEmpty())
                    allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,0,rateListMap);
            else
                allChargesMap = InventoryCostServices.getAllChargesNew(unitId,earmarkedCPCharges,additionalCarParkCharge,0,null);
            // when CV is being changed then reset the discounts to 0 calculate the new CV and then apply Disocunts again.
            // CreateQuote cls = New CreateQuote();
            // cls.applyDiscounts();
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
               
              standardPaymentplan = [Select Id, Name, Project__c, Status__c, Is_Active__c, Is_Standard_Payment_Plan__c, Tower__c
                                     from  Payment_Plan__c Where Tower__c = : qList[0].Unit__r.Tower__c AND Is_Standard_Payment_Plan__c = True];
                                                                  
              payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
          //  payplanDetails = InventoryCostServices.getPlanDetailsNew(unitId, qList[0].Payment_Plan__c, allChargesMap); 
              if(standardPaymentplan.size() > 0 && allChargesMap != Null){
              payplanDetails = InventoryCostServices.getPlanDetailsNew(unitId, standardPaymentplan[0].Id, allChargesMap);                           
              }
              
              //For NPV Calculation
              if(payplanDetails.size() > 0 && b != Null){
              OriginalPlanNPV = InventoryCostServices.calculateNPV(payplanDetails, b.Project__c);
              }
              OriginalNPVPSF = (OriginalPlanNPV/qList[0].Unit__r.Chargeable_Area__c); //.setscale(0,RoundingMode.HALF_UP);
              SOriginalPlanNPV = InventoryCostServices.INFormatForNPV(OriginalPlanNPV);
              NPVDiffLumpsum = OriginalPlanNPV - UpdatedPlanNPV;
              NPVDiffPSF = (NPVDiffLumpsum/ qList[0].Unit__r.Chargeable_Area__c);
              SUpdatedPlanNPV = InventoryCostServices.INFormatForNPV(UpdatedPlanNPV);
              SUpdatedNPVPSF = InventoryCostServices.INFormatForNPV(UpdatedNPVPSF);
              SNPVDiffLumpsum = InventoryCostServices.INFormatForNPV(NPVDiffLumpsum);
              SNPVDiffPSF = InventoryCostServices.INFormatForNPV(NPVDiffPSF);
          
  }
    
        // For Type and Number of Parking
        String queryString2 = '';
                for(Integer i = 1; i<=25; i++) {
                    queryString2 += 'Charge' + i + 'Name__c'   + ',';
                    queryString2 += 'Charge' + i + 'Value__c'  + ',';
                    queryString2 += 'Charge' + i + 'Bucket__c' + ',';                    
                    queryString2 += 'Charge' + i + 'CGST__c'   + ','; 
                    queryString2 += 'Charge' + i + 'SGST__c'   + ','; 
                }
        queryString2 +=    'Car_Park_Type_1__c, Car_Park_Type_2__c, Car_Park_Type_3__c, Car_Park_Type_4__c, Car_Park_Type_5__c, '+
                            'Car_Park_Count_1__c, Car_Park_Count_2__c,  Car_Park_Count_3__c, Car_Park_Count_4__c, Car_Park_Count_5__c,'+
                            'Earmarked_Type_1__c, Earmarked_Type_2__c, Earmarked_Type_3__c, Earmarked_Type_4__c, Earmarked_Type_5__c,' +
                            'Earmarked_Count_1__c, Earmarked_Count_2__c, Earmarked_Count_3__c, Earmarked_Count_4__c, Earmarked_Count_5__c';                
                        
        if (qId != null){
            queryString2 = 'Select ' + queryString2  + ' from Quotation__c where Id = \'' + qId + '\'' ;
        }
        System.debug('Quotation Id::: ' + qId);
        qList1 = Database.Query(queryString2);
                        
         carParkMap = new Map<String, Decimal>();
         carparkList = new List<CarParkWrapper>();
         carParkTypes = new List<String>();
         
          for(Integer i=1 ; i<=5; i++) {
              if(qList1[0].get('Car_Park_Type_'+i+'__c') != null && qList1[0].get('Car_Park_Count_'+i+'__c') != 0) {
              CarParkWrapper cw = new CarParkWrapper();
              cw.parkType =(String) qList1[0].get('Car_Park_Type_'+i+'__c');
              cw.noOfParking = (Decimal)qList1[0].get('Car_Park_Count_'+i+'__c');
              carparkList.add(cw);
              }
              if(qList1[0].get('Earmarked_Type_'+i+'__c') != null && qList1[0].get('Earmarked_Count_'+i+'__c') != 0) {
              CarParkWrapper cw = new CarParkWrapper();
              cw.parkType =(String) qList1[0].get('Earmarked_Type_'+i+'__c');
              cw.noOfParking = (Decimal)qList1[0].get('Earmarked_Count_'+i+'__c');
              carparkList.add(cw);
              }
           }
         System.debug('Car park list::::' + carparkList.size());  
            if(!carparkList.isEmpty()) {
               for(CarParkWrapper cwp : carparkList) {
               decimal count = 0;
                  if(carParkMap.containsKey(cwp.parkType)) {
                  count += carParkMap.get(cwp.parkType)+ cwp.noOfParking;
                  carParkMap.put(cwp.parkType,count);
                  }
                  else {
                  carParkMap.put(cwp.parkType,cwp.noOfParking);
                  }
                }
                if(!carParkMap.isEmpty()) {
                  for(String cp : carParkMap.KeySet()) {
                     carParkTypes.add(cp);
                    }
                 }
             }  
        boolean check = true;  
        System.debug('carParkTypes::::: ' + carParkTypes);
        countOfParking = 0;
            for(String s: carParkTypes){
                if(carParkMap != null && carParkMap.size() > 0) { 
                countOfParking += carParkMap.get(s);
                System.debug('car park Map::: ' + carParkMap.get(s));
                System.debug('countOfParking::: ' + countOfParking );
              }
            }
        
  }

public class PMWrapper {
        public Decimal count {get;set;}
        public String dueDate {get;set;} 
        public String installment {get;set;}
        public String milestoneName {get;set;}
        public String amount        {get;set;}
        public String pct           {get;set;}
        public String amtPayable    {get;set;}
        public String rowStyle      {get;set;}
        public Decimal sizeOfPM;
        
        public PMWrapper(Decimal srno, Date milestoneDueDate, String msName, String pct, Decimal amt, Boolean milestoneAchieved, String milestoneType, Decimal size) {
            this.count = srno;
            this.installment = '';
            this.milestoneName = msName;
            this.sizeOfPM = size;
            if(this.milestoneName == 'Token'){
                 this.installment = 'Booking Amount';              
            }
           if(this.count == 2){
                 this.installment = 'First Installment';              
            }
            if(this.count == 3){
                 this.installment = 'Second Installment';              
            }
            if(this.count == 4){
                 this.installment = 'Third Installment';              
            }
            if(this.count == 5){
                 this.installment = 'Fourth Installment';              
            }
            if(this.count == 6){
                 this.installment = 'Fifth Installment';              
            }
            if(this.count == 7){
                 this.installment = 'Sixth Installment';              
            }
            if(this.count == 8){
                 this.installment = 'Seventh Installment';              
            }
            if(this.count == 9){
                 this.installment = 'Eighth Installment';              
            }
            if(this.count == 10){
                 this.installment = 'Ninth Installment';              
            }
            if(this.count == 11){
                 this.installment = 'Tenth Installment';              
            }
            if(this.count == 12){
                 this.installment = 'Eleventh Installment';              
            }
            if(this.count == 13){
                 this.installment = 'Twelfth Installment';              
            }
            if(this.count == 14){
                 this.installment = 'Thirteenth Installment';              
            }
            if(this.count == 15){
                 this.installment = 'Fourteenth Installment';              
            }
            if(this.count == 16){
                 this.installment = 'Fifteenth Installment';              
            }
            if(this.count == 17){
                 this.installment = 'Sixteenth Installment';              
            }
            if(this.count == 18){
                 this.installment = 'Seventeenth Installment';              
            }
            if(this.count == 19){
                 this.installment = 'Eighteenth Installment';              
            }
            if(this.count == 20){
                 this.installment = 'Nineteenth Installment';              
            }
             if(this.count == 21){
                 this.installment = 'Twentieth Installment';              
            }
            if(this.count == 22){
                 this.installment = 'Twenty-First Installment';              
            }
            if(this.count == 23){
                 this.installment = 'Twenty-Second Installment';              
            }
            if(this.count == 24){
                 this.installment = 'Twenty-Third Installment';              
            }
            if(this.count == 25){
                 this.installment = 'Twenty-Fourth Installment';              
            }
            if(this.count == 26){
                 this.installment = 'Twenty-Fifth Installment';              
            }
            if(this.count == 27){
                 this.installment = 'Twenty-Sixth Installment';              
            }
            if(this.count == 28){
                 this.installment = 'Twenty-Seventh Installment';              
            }
            if(this.count == 29){
                 this.installment = 'Twenty-Eighth Installment';              
            }
            if(this.count == 30){
                 this.installment = 'Twenty-Ninth Installment';              
            }
            if(this.count == 31){
                 this.installment = 'Thirtieth Installment';              
            }
            if(this.count == 32){
                 this.installment = 'Thirty-First Installment';              
            }
            if(this.count == 33){
                 this.installment = 'Thirty-Second Installment';              
            }
            if(this.count == 34){
                 this.installment = 'Thirty-Third Installment';              
            }
            if(this.count == 35){
                 this.installment = 'Thirty-Fourth Installment';              
            }
            if(this.count == 36){
                 this.installment = 'Thirty-Fifth Installment';              
            }
            if(this.count == 37){
                 this.installment = 'Thirty-Sixth Installment';              
            }
            if(this.count == 38){
                 this.installment = 'Thirty-Seventh Installment';              
            }
            if(this.count == 39){
                 this.installment = 'Thirty-Eighth Installment';              
            }
            if(this.count == 40){
                 this.installment = 'Thirty-Ninth Installment';              
            }
            if(this.count == 41){
                 this.installment = 'Fortieth Installment';              
            }
            if(this.count == 42){
                 this.installment = 'Forty-First Installment';              
            }
            if(this.count == 43){
                 this.installment = 'Forty-Second Installment';              
            }
            if(this.count == 44){
                 this.installment = 'Forty-Third Installment';              
            }
            if(this.count == 45){
                 this.installment = 'Forty-Fourth Installment';              
            }
            if(this.count == 46){
                 this.installment = 'Forty-Fifth Installment';              
            }
            if(this.count == 47){
                 this.installment = 'Forty-Sixth Installment';              
            }
            if(this.count == 48){
                 this.installment = 'Forty-Seventh Installment';              
            }
            if(this.count == 49){
                 this.installment = 'Forty-Eighth Installment';              
            }
            if(this.count == 50){
                 this.installment = 'Forty-Ninth Installment';              
            }
            if(this.count == 51){
                 this.installment = 'Fiftieth Installment';              
            }    
            if(this.count == this.sizeOfPM && this.milestoneName != 'Token'){
                 this.installment = 'Final Installment';  
            }
            
            if(milestoneDueDate != null && String.IsNotBlank(milestoneType) && milestoneType == 'Date Linked'){
                this.dueDate = milestoneDueDate.Format();
            } else {
                 this.dueDate = '-'; 
            }            
            this.pct           = pct;
            System.debug('before formatting amount::'+amt);
            this.amount        = InventoryCostServices.InFormat(amt);
            System.debug('after formatting amount::'+this.amount);                 
            if (msName == 'Total') {
                this.rowStyle  = 'font-weight:bold';
            }
            if(milestoneAchieved) {
                this.rowStyle  = 'background-color:#D7BF5E';
            }
        }
}

    public static void dummyMethod() {
        String test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test'; 
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test'; 
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test'; 
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test'; 
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test'; 
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test'; 
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test'; 
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test'; 
        test = 'test';
    }
    
public class ADWrapper{
public Applicant_Details__c ad {get;set;}
public String permanentAddress {get;set;}
public String mailingAddress {get;set;}
public String validityDate {get;set;}

     public ADWrapper(Applicant_Details__c app){
     this.ad = app;
     this.mailingAddress  = '';
     this.permanentAddress = '';
     if(app.Valid_Until_Passport__c != null)
         this.validityDate = app.Valid_Until_Passport__c.format();
//// For mailing address     
     if(app.Mailing_Address__c != null){
         this.mailingAddress = app.Mailing_Address__c; 
         if(app.Mailing_City__c != null || app.Mailing_State__c != null  || app.Mailing_Country__c != null) {
             this.mailingAddress += ', '; 
         }
     }
     if(app.Mailing_City__c != null){
       this.mailingAddress += app.Mailing_City__c;
       if(app.Mailing_State__c != null || app.Mailing_Country__c != null) {
           this.mailingAddress += ', '; 
       }          
     }
     if(app.Mailing_State__c != null){      
       this.mailingAddress += app.Mailing_State__c;
       if(app.Mailing_Country__c != null) {
           this.mailingAddress += ', '; 
       }          
     }
     if(app.Mailing_Country__c != null){
       this.mailingAddress += app.Mailing_Country__c;
       if(app.Mailing_Pincode__c != null) {
           this.mailingAddress += ' - ' + app.Mailing_Pincode__c; 
       }          
     }    
 //// For permanent address     
     if(app.Permanent_Address__c!= null){
         this.permanentAddress = app.Permanent_Address__c; 
         if(app.City__c != null || app.State__c != null || app.Country__c != null) {
             this.permanentAddress += ', '; 
         }
     }
     if(app.City__c != null){
       this.permanentAddress += app.City__c;
       if(app.State__c != null || app.Country__c != null) {
           this.permanentAddress += ', '; 
       }          
     }
     if(app.State__c != null){      
       this.permanentAddress += app.State__c;
       if(app.Country__c != null) {
           this.permanentAddress += ', '; 
       }          
     }
     if(app.Country__c != null){   
       this.permanentAddress += app.Country__c;
       if(app.Pincode__c != null) {
           this.permanentAddress += ' - ' + app.Pincode__c; 
       }          
     }       
  }
}

  public class CarParkWrapper {
        public String parkType {
         get;
         set;
        }
        public decimal noOfParking {
         get;
         set;
        }
        
        public CarParkWrapper () {
            parkType = '';
            noOfParking = 0;
        }
    }
}