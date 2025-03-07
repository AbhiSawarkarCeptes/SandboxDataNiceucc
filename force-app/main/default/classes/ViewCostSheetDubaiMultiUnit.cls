public class ViewCostSheetDubaiMultiUnit{
    
    public String qId {get; set;}
    public List<Quotation__c> qList {get; set;}
    public List<Rate_List__c> rList {get; set;}
    public Date qDate {get; set;}
    public String floorNo {get;set;}
    public String bankAddress {get;set;}
    Map<String, Integer> projChargeSeq = new Map<String,Integer>();
    public String basicChargesString {get;set;}
    public String floorRiseChargesString {get;set;}
    public String floorRiseAmount{get;set;}
    public String PLCAmount {get;set;}
    public String PLCChargesString {get;set;}
    public String stampDutyString {get;set;}
    public String totalKnowledgefeesString {get;set;}
    public String totalDLDfeesString {get;set;}
    public String totalDLDAdminfeesString {get;set;}
    public String registrationString{get;set;}
    public String totalRegStampString{get;set;}
    public string amtGTString{get;set;}
    public String grandTotalString{get;set;}
    public List<PMWrapper> pmwList {get;set;}
    public List<Payment_Milestones__c> pmList {get;set;}
    public Decimal stampDutyPerce{get;set;}
    public List<Quotation__c> qListImage {get; set;} 
    public String PimageURL {get; set;}
    public String PimageURL1 {get; set;}
    public String floorPlan {get;set;}
    public String attachmentId {get; set;}
    public List<ContentDocumentLink> PattchList {get;set;} 
    public List<Unit__c> uList {get;set;} 
    public String chgName{get;set;}
    public String KnowledgefeesString {get;set;}
    public String DLDfeesString {get;set;}
    public String DLDAdminfeesString {get;set;}
    public Decimal totalKnowledgefees{get;set;}
    public Decimal totalDLDfees{get;set;}
    public Decimal totalDLDAdminfees{get;set;}
    public String custEmailId{get;set;}
    public String custName{get;set;}
    public String custMob{get;set;}
    public String addresses{get;set;}
    public Map<String,Decimal> mapOfUnitToDLDPrice{get;set;}
    public List<Unit_For_Quote__c> ufqList{get;set;}
    //public string quoteCreatedBy{get;set;}
    public Map<String,Decimal> mapOfUnitToBasicPrice{get;set;}
    public Map<Id,Decimal> mapOfUnitToBasicPriceAfterDiscount{get;set;}
    public Map<Id,Decimal> mapOfUnitToDLDPriceAfterDiscount{get;set;}
    public ViewCostSheetDubaiMultiUnit(){
        Map<String,String> mapCharges = new Map<String,String>();
        pmwList = new List<PMWrapper>();
        pmList  = new List<Payment_Milestones__c>();
        stampDutyPerce = 0;
        floorRiseChargesString = '0.00/-';
        PLCChargesString = '0.00/-';
        stampDutyString = '0.00/-';
        registrationString = '0.00/-';
        chgName = '';
        KnowledgefeesString ='';
        DLDfeesString='';
        totalKnowledgefees = 0;
        totalDLDfees = 0;
        totalDLDAdminfees =0;
        List<Id> unitIdsTagged = new List<Id>();
        
        qId = ApexPages.currentPage().getParameters().get('qId'); 
        
        String queryString = '';
        for(Integer i = 1; i<=25; i++) {
            queryString += 'Charge' + i + 'Name__c'   + ',';
            queryString += 'Charge' + i + 'Value__c'  + ',';
            queryString += 'Charge' + i + 'Bucket__c' + ',';                               
        }
        
        queryString += 'Name,Is_Discount_Quote__c, Unit__r.Id, Project__r.Name, Unit__r.Typology__c, Tower__r.Name, Tower__r.Cluster__r.Name, Unit__r.Tower_No__c,'+
            'Unit__r.Floor__c, Unit__r.Unit_No__c, Unit__r.Unit_Status__c, Unit__r.No_of_Bedroom__c, Total_Other_Charges_Bucket__c,Unit__r.Store_Unit__c,Unit__r.Store_Area__c,'+ 
            'Unit__r.Super_Builtup_Area_Sq_Ft__c, Total_Agreement_Value_Bucket__c, Premium1_Original_PSF__c, Total_SD_Registration_Bucket__c,' +
            'Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c,Tower__r.UnRegister_Project__c, Tower__r.RDS_Company_Code__r.Favouring__c, Tower__r.RDS_Company_Code__r.RDS_Address1__c, Unit__r.Unit_Type__c,' +
            'Tower__r.RDS_Company_Code__r.Account_Number_Flat_Cost__c, Tower__r.Building_Number__c, Tower__r.RDS_Company_Code__r.Account_Name_Flat_Cost__c, Unit__r.Floor_No_to_print__c,' +                                                                    
            'Tower__r.RDS_Company_Code__r.IBAN__c, Tower__r.RDS_Company_Code__r.MICR_Code_Flat_Cost__c, Payment_Plan__r.Disclaimer__c, Unit__r.Configuration__c, Unit__r.Chargeable_Area__c,' +
            'Tower__r.RDS_Company_Code__r.Developer_ID__c,  Unit__r.Name, Tower__r.RDS_Company_Code__r.Project_Name_ID__c, Floor_Rise_Original_PSF__c, Opportunity__r.AccountId, CreatedDate,CreatedBy.Name,CreatedBy.Email,CreatedBy.CreatedDate ';                              
        
        if (qId != null) {
            queryString = 'Select ' + queryString+',(select id,unit__c,unit__r.Typology__c,Unit__r.Floor__c,Unit__r.Tower_No__c,'+
            'Unit__r.Unit_No__c, Unit__r.Unit_Status__c,Unit__r.Puchase_Price__c,Unit__r.No_of_Bedroom__c,Unit__r.Store_Unit__c,Unit__r.Store_Area__c,Unit__r.Super_Builtup_Area_Sq_Ft__c,'+
            'Unit__r.Unit_Type__c,Unit__r.Floor_No_to_print__c,Unit__r.Configuration__c, Unit__r.Chargeable_Area__c,Unit__r.Name from Unit_For_Quote__r) FROM Quotation__c WHERE Id = \'' + qId + '\'' ;
            qList = Database.Query(queryString);
        }
          /* For showing different name than vfp name while downloading pdf */
          // Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+qList[0].Unit__r.Unit_No__c + '-Quotation.pdf'); 
        
        System.debug('Unit Id::: ' +qList[0].Unit__r.Id);
        ufqList = new List<Unit_For_Quote__c>();
        ufqList.addAll(qList[0].Unit_For_Quote__r);
        system.debug('ufqList---'+ufqList);
        for(Unit_For_Quote__C ufq : ufqList){
            unitIdsTagged.add(ufq.unit__c);
        }
        mapOfUnitToDLDPrice = new Map<String,Decimal>();
        Decimal totalBasicPriceUnitLevel = 0;
        Decimal totalDLDPriceUnitLevel = 0;
        
        List<Rate_List__c> rateList = [Select Id,Unit__c,Rate_List_Bucket__c,  Charge_Cost__c, Type__c, PSF_rate__c,Unit__r.Name, ProjectCharges__r.Name 
        from Rate_List__c
        where Unit__c IN :unitIdsTagged ];
        Map<String,Decimal> mapOfUnitToAgreementPrice = new Map<String,Decimal>();
        mapOfUnitToBasicPrice = new Map<String,Decimal>();
        if(rateList.size() > 0 ) {
            for(Rate_List__c r : rateList)  {
                if(r.ProjectCharges__r.Name =='Knowledge Fees' || r.ProjectCharges__r.Name =='DLD Admin Fees'){
                    if(!mapOfUnitToDLDPrice.containsKey(r.Unit__c)){
                        mapOfUnitToDLDPrice.put(r.Unit__c, 0);
                    }
                    mapOfUnitToDLDPrice.put(r.Unit__c, mapOfUnitToDLDPrice.get(r.Unit__c)+r.Charge_Cost__c);
                    totalDLDPriceUnitLevel += r.Charge_Cost__c;
                }
                if(r.Rate_List_Bucket__c == 'Agreement Value'){
                    if(!mapOfUnitToAgreementPrice.containsKey(r.Unit__c)){
                        mapOfUnitToAgreementPrice.put(r.Unit__c, 0);
                    }
                    mapOfUnitToAgreementPrice.put(r.Unit__c, (mapOfUnitToAgreementPrice.get(r.Unit__c)+r.Charge_Cost__c).setscale(0,RoundingMode.HALF_UP));
                }
                if(r.ProjectCharges__r.Name !='Knowledge Fees' && r.ProjectCharges__r.Name !='DLD Admin Fees'
                && r.ProjectCharges__r.Name !='DLD'){
                    if(!mapOfUnitToBasicPrice.containsKey(r.Unit__c)){
                        mapOfUnitToBasicPrice.put(r.Unit__c, 0);
                    }
                    mapOfUnitToBasicPrice.put(r.Unit__c, (mapOfUnitToBasicPrice.get(r.Unit__c)+r.Charge_Cost__c).setscale(0,RoundingMode.HALF_UP));
                    totalBasicPriceUnitLevel+=r.Charge_Cost__c;
                }
                
                

            }               


        }
      
       
        /*List<Discounts_Applied__c> discountsAppliedList = [SELECT ID,Total__c FROM Discounts_Applied__c WHERE Quotation_c =: qList[0].id];
        decimal totalBasicDiscount = 0;
        For(Discounts_Applied__c da : discountsAppliedList){
            totalBasicDiscount+= da.Total__c;
        }*/
        List<ProjectCharges__c> pcList = [Select Id, Name, 
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
                                                            ProjectCharges__c where Tower__c =: qList[0].tower__c
                                                            and active__c = true];
        for(id unitId : unitIdsTagged){
            for(ProjectCharges__c pc : pcList) {
                if(pc.Active__c && 
                String.isNotBlank(pc.ChargeBucket__c) && pc.ChargeBucket__c.equalsIgnoreCase('Stamp Duty and Registration') && 
                String.isNotBlank(pc.Calculatedas__c) && pc.Calculatedas__c.equalsIgnoreCase('Percentage of Agreement Value')){
                    Decimal AgreementValue = mapOfUnitToAgreementPrice.get(unitId);
                    Decimal amount = ((agreementValue * pc.Agreement_Value_Percentage__c)/100).setscale(0,RoundingMode.HALF_UP);
                    mapOfUnitToDLDPrice.put(unitId, mapOfUnitToDLDPrice.get(unitID)+amount  );
                    totalDLDPriceUnitLevel += amount;        
                }
            }
        }
                
        Decimal totalBasicDiscount = totalBasicPriceUnitLevel- qList[0].Total_Agreement_Value_Bucket__c;
        Decimal totalDLDDiscount = totalDLDPriceUnitLevel - qList[0].Total_SD_Registration_Bucket__c;
        mapOfUnitToBasicPriceAfterDiscount = new Map<Id,Decimal>();
        mapOfUnitToDLDPriceAfterDiscount = new Map<Id,Decimal>();
        for(String uId : unitIdsTagged){
            Decimal IndividualBasicDiscount = 0;
            Decimal IndividualDLDDiscount = 0;
            IndividualBasicDiscount = totalBasicDiscount/(unitIdsTagged.size());
            IndividualDLDDiscount = totalDLDDiscount/(unitIdsTagged.size());
            if(mapOfUnitToBasicPrice.containsKey(uId))
            mapOfUnitToBasicPriceAfterDiscount.put(uId,(mapOfUnitToBasicPrice.get(uId)-IndividualBasicDiscount).setscale(0,RoundingMode.HALF_UP));
            if(mapOfUnitToDLDPrice.containsKey(uId))
            mapOfUnitToDLDPriceAfterDiscount.put(uId,(mapOfUnitToDLDPrice.get(uId)-IndividualDLDDiscount).setscale(0,RoundingMode.HALF_UP));

        }
       Account ac = new Account();
        ac = [select id,name,FirstName,LastName,PersonEmail,PersonMobilePhone from Account where id =: qList[0].Opportunity__r.AccountId];
        if(ac != null){
            custName = ac.name;
            custMob = ac.PersonMobilePhone;
            custEmailId = ac.PersonEmail;
        }
        
        DateTime dT = qList[0].CreatedDate;
        
        qDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        /*     if(qList[0].Unit__r.Floor__c != null & qList[0].Unit__r.Floor__c == 0){
floorNo = 'G';
} else {
floorNo =  String.valueOf(qList[0].Unit__r.Floor__c);
}*/
        
        if(qList[0].Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c != null || qList[0].Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c != ''){
            bankAddress = qList[0].Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c;
            if(qList[0].Tower__r.RDS_Company_Code__r.RDS_Address1__c != null || qList[0].Tower__r.RDS_Company_Code__r.RDS_Address1__c != ''){
                bankAddress += ', ' + qList[0].Tower__r.RDS_Company_Code__r.RDS_Address1__c;
            }
        }             
        
        // For Payment Plan Milestone
        projChargeSeq = InventoryCostServices.getProjectChargesSequence(qList[0].Project__r.Name, qList[0].Tower__r.Id);
        system.debug('projChargeSeq '+projChargeSeq );
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
            system.debug('PLCSeq ::'+PLCSeq );
            if(PLCSeq != null)
            {
                PLCChargesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + PLCSeq + 'Value__c'));
            }
            
            
            //-------------------------------------------------------------------------------------------------------------------- ------------------------------------//
            integer knowledgefeesseq = projChargeSeq.get('Knowledge Fees'); 
            system.debug('knowledgefeesseq ::'+knowledgefeesseq );               
            if(!String.isBlank(String.valueOf(knowledgefeesseq ))) {
                if(qList[0].get('Charge' + knowledgefeesseq + 'Value__c') != Null){
                    KnowledgefeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + knowledgefeesseq + 'Value__c'));                        
                    Decimal temp = (Decimal)qList[0].get('Charge' + knowledgefeesseq + 'Value__c');
                    KnowledgefeesString = String.valueOf(temp.setScale(0));
                  
                    totalKnowledgefees += (Decimal)qList[0].get('Charge' + knowledgefeesseq + 'Value__c');
                    totalKnowledgefees = totalKnowledgefees.setScale(0);
                    system.debug('totalKnowledgefees ::'+totalKnowledgefees );}
            }
            //totalKnowledgefeesString = InventoryCostServices.InFormat(totalKnowledgefees );
            
            integer DLDfeesseq = projChargeSeq.get('DLD'); 
            system.debug('DLDfeesseq ::'+DLDfeesseq );                                  
            if(!String.isBlank(String.valueOf(DLDfeesseq ))) {
                if(qList[0].get('Charge' + DLDfeesseq + 'Value__c') != Null){
                    DLDfeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + DLDfeesseq + 'Value__c'));
                    Decimal temp = (Decimal)qList[0].get('Charge' + DLDfeesseq + 'Value__c');
                    DLDfeesString = String.valueOf(temp.setScale(0));
                  
                    totalDLDfees += (Decimal)qList[0].get('Charge' + DLDfeesseq + 'Value__c');
                    totalDLDfees = totalDLDfees.setScale(0);
                    system.debug('totalDLDfees ::'+totalDLDfees );}
            }
            //totalDLDfeesString =  InventoryCostServices.InFormat(totalDLDfees );  
            
            integer DLDAdminfeesseq = projChargeSeq.get('DLD Admin Fees'); 
            system.debug('DLDAdminfeesseq ::'+DLDAdminfeesseq );                                  
            if(!String.isBlank(String.valueOf(DLDAdminfeesseq ))) {
                if(qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c') != Null){
                    DLDAdminfeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c'));
                    Decimal temp = (Decimal)qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c');
                    DLDAdminfeesString = String.valueOf(temp.setScale(0));
                    totalDLDAdminfees += (Decimal)qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c');
                    totalDLDAdminfees = totalDLDAdminfees.setScale(0);
                    
                    system.debug('totalDLDAdminfees ::'+totalDLDAdminfees );}
            }
            //totalDLDAdminfeesString =  InventoryCostServices.InFormat(totalDLDAdminfees ).setScale(0);     
        }                      
        //------------------------------------------------------------------------------------------------------------------------------------------------//
        
        
        integer basicSeq = projChargeSeq.get('Basic');
        Map<String,ProjectCharges__c> projChargesMap = InventoryCostServices.getProjectChargesMap(qList[0].Project__r.Name, qList[0].Tower__r.Id);
        Map<String,Integer> AVChargesSeqMap = new Map<String, Integer>();
        
        Integer Seq = 1;
        String chgName = '';
        system.debug(projChargesMap);
        system.debug('basicSeq==='+basicSeq);
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
        system.debug(AVChargesSeqMap);
        
        String queryString1 = '';
        
        for(Integer i = 1; i<=25; i++) {
            queryString1 += 'Charge' + i + 'Name__c'   + ',';
            queryString1 += 'Charge' + i + 'Percentage__c'  + ',';
            queryString1 += 'C' + i + '_Amount__c' + ',';                    
            queryString1 += 'C' + i + '_CGST__c'   + ','; 
            queryString1 += 'C' + i + '_SGST__c'   + ','; 
        }
        
        if (qId != null) 
        {
            queryString1 = 'SELECT ' + queryString1  + ' Id, Name, Milestone_Name__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Demand_Raised__c, Milestone_Type_edit__c  FROM Payment_Milestones__c WHERE Quotation__c = \'' + qId + '\' order by Name ASC' ;                                                                     
            pmList = Database.Query(queryString1);
        }
        
        Decimal amtGT = 0;
        Decimal taxGT = 0;
        Decimal sizeOfPM = pmList.size();
        Decimal srno = 0;
        System.debug('Size pf pm::: ' + pmList.size());    
        for(Payment_Milestones__c pm : pmList) {
            // check all the values in Agreement value bucket and sum total its amount and taxes
            Decimal totalAmt = 0;
            Decimal totalTax = 0;
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
        amtGTString = InventoryCostServices.InFormat(amtGT);                  
        decimal tempgrandTotal = (qList[0].Total_Agreement_Value_Bucket__c + qList[0].Total_Other_Charges_Bucket__c).setscale(0,RoundingMode.HALF_UP);
        grandTotalString = InventoryCostServices.InFormat(tempgrandTotal);
        
        ////////// For Images  
        PattchList = new List<ContentDocumentLink>();
        PimageURL = '';
        PimageURL1 = '';
        Id parentRecordId;
        
        if(qId != null){ 
            qListImage = [SELECT Unit__c,Unit__r.Tower__c,Tower__r.UnRegister_Project__c, Opportunity__c, Tower__c, Unit__r.Typology__c, Unit__r.View_Type__c, Unit__r.Direction__c 
                          FROM Quotation__c WHERE Id = :qId];
            System.debug('Quotation Tower Id::: ' + qListImage[0].Unit__r.Tower__c);
            System.debug('Unit Typology:::' + qListImage[0].Unit__r.Typology__c );
        }

        //Shoba_Default_Settings__mdt orgDefaults = Shoba_Default_Settings__mdt.getInstance('Org Defaults');
        List<Shoba_Default_Settings__mdt> orgDefaults = [SELECT Id,MasterLabel,Default_Layout_Object__c from Shoba_Default_Settings__mdt];
        
        String defaultLayoutObject = 'Unit';
        if (orgDefaults.size() > 0) {
            defaultLayoutObject = orgDefaults[0].Default_Layout_Object__c;
        }

        if (defaultLayoutObject == 'Unit') {
            if(qListImage.size() > 0 && qListImage != null){
                uList = [SELECT Id FROM Unit__c 
                         WHERE id IN :unitIdsTagged];
                //System.debug('Unit Layout Id::: ' + uList[0].Id);
                parentRecordId = uList[0].id;
            } 
        } else {
            if(qListImage.size() > 0 && qListImage != null){
                parentRecordId = [SELECT Id, Typology__c FROM Unit_Layout__c 
                     WHERE Tower__c = :qListImage[0].Tower__c AND Typology__c = :ufqList[0].Unit__r.Typology__c][0].id;
            //System.debug('Unit Layout Id::: ' + uList[0].Id);
            }
        }

        if(parentRecordId != null){ 
            PattchList = [SELECT ContentDocumentId, 
                                ContentDocument.Title,
                                ContentDocument.LatestPublishedVersionId
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId IN :unitIdsTagged
                            order by ContentDocument.Title asc];
            System.debug('AttacmentList::'+PattchList);  
        }  
        
                                           
        
        if(!PattchList.isEmpty()) {
            for(ContentDocumentLink a : PattchList) {
                if(defaultLayoutObject == 'Unit' && a.ContentDocument.Title.ContainsIgnoreCase('Unit Layout')) {
                    //PimageURL = '/servlet/servlet.FileDownload?file=' + a.ContentDocumentId;
                    PimageURL = '/sfc/servlet.shepherd/version/download/'+ a.ContentDocument.LatestPublishedVersionId;
                    PimageURL1 = PimageURL;
                    System.debug('PimageURL::: ' + PimageURL);
                } else if (defaultLayoutObject == 'Unit' && a.ContentDocument.Title.ContainsIgnoreCase('Floor Plan')) {
                    floorPlan = '/sfc/servlet.shepherd/version/download/'+ a.ContentDocument.LatestPublishedVersionId;
                }else {
                    if(a.ContentDocument.Title.ContainsIgnoreCase('3')) {
                    PimageURL = '/servlet/servlet.FileDownload?file=' + a.Id;
                    System.debug('PimageURL::: ' + PimageURL);
                    }
                    if(a.ContentDocument.Title.ContainsIgnoreCase('3')) {
                        PimageURL1 = '/servlet/servlet.FileDownload?file=' + a.Id;
                        System.debug('PimageURL1::: ' + PimageURL1);
                    }
                }
                
            }
        }
        
    }
    public pageReference sendQuote(){ 
        
        system.debug('inside sendquoteMethod::');  
        Blob pdf;
        PageReference pageRef = new PageReference('/apex/ViewCostsheetDubaiPDF?qId='+qId);
        pageRef.getParameters().put('qId',qId);
        try {
            pdf = pageRef.getContentAsPdf();
        } catch (VisualforceException e) {
            pdf = Blob.valueOf('Some Text');
        }
        
        string strBookingHtmlBody ;
        string strImageBlob;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        strBookingHtmlBody = 'Dear '+custName+',<br/><br/> Thank you for your interest in '+qList[0].Project__r.Name+'. As requested, the cost sheet of Unit: '+qList[0].Unit__r.name+' in Tower: '+
            qList[0].Tower__r.Name +' of Project '+ qList[0].Project__r.Name +' is attached.' + 
            '<br></br>Please find Attached.<br></br> <br></br> Thanks, <br/> Sobha.';
        
        list<string> lststringtoaddress = new list<string>();
        if( string.isNotBlank(custEmailId))
            lststringtoaddress.add(custEmailId);
        
        if(string.isNotBlank(addresses)){
            for (String eachStr: addresses.split(',')) {
                lststringtoaddress.add(eachStr);
            }
            
        }
        string subject;
        subject = 'Please Find the attached Quotation for project - '+qList[0].Project__r.name+' Unit - '+qList[0].Unit__r.name;
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Quotation.pdf');
        efa.body = pdf;
        
        email.setSubject(subject);
        email.setToAddresses(lststringtoaddress);
        email.setHtmlBody(strBookingHtmlBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        mails.add(email);
        if(!Test.isRunningTest())
            Messaging.sendEmail(mails);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Quotation has been send successfully'));
        
        return null;
        
    }
    public class PMWrapper {
        public Decimal count {get;set;}
        public String dueDate {get;set;} 
        public String installment {get;set;}
        public String milestoneName {get;set;}
        public Decimal amount        {get;set;}
        public String pct           {get;set;}      
        public String amtPayable    {get;set;}
        public String rowStyle      {get;set;}  
        public Decimal sizeOfPM;
        
        public PMWrapper(Decimal srno, Date milestoneDueDate, String msName, String pct, Decimal amt, Boolean milestoneAchieved, String milestoneType, Decimal size) {
            this.count = srno;
            this.installment = '';
            this.milestoneName = msName;
            this.sizeOfPM = size;
            if(milestoneDueDate != null && String.IsNotBlank(milestoneType) && milestoneType == 'Date Linked' && msName == 'On Booking Date'){
                this.dueDate = 'On Booking';
            } else {
                this.dueDate = '-'; 
            }                
            this.pct = pct;
            this.amount =amt.setScale(0);
            //this.amount = String.valueOf(Decimal.valueOf(this.amount).setScale(0));
            if(msName == 'Total') {
                this.rowStyle  = 'font-weight:bold';
            }
            if(milestoneAchieved) {
                this.rowStyle  = 'background-color:#D7BF5E';
            }
            
            if(this.milestoneName == 'On Booking Date'){
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
            if(this.count == 52){
                this.installment = 'Fift-One Installment';              
            }
            if(this.count == 53){
                this.installment = 'Fift-Second Installment';              
            }
            if(this.count == 54){
                this.installment = 'Fift-Third Installment';              
            }
            if(this.count == 55){
                this.installment = 'Fift-Fourth Installment';              
            }
            if(this.count == 56){
                this.installment = 'Fift-Fifth Installment';              
            }
            if(this.count == 57){
                this.installment = 'Fift-Sixth Installment';              
            }
            if(this.count == 58){
                this.installment = 'Fift-Seventh Installment';              
            }
            if(this.count == 59){
                this.installment = 'Fift-Eighth Installment';              
            }
            if(this.count == 60){
                this.installment = 'Fift-Ninth Installment';              
            }   
            if(this.count == this.sizeOfPM && this.milestoneName != 'On Booking Date'){
                this.installment = 'Final Installment';  
            }
        }
    }
}