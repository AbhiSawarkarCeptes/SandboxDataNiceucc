public without sharing class ViewCostsheetMultiUnitCloneController {
    public Id quoteId {get;set;}
    public Quote__c quote {get;set;}
    public Bank_GL__c bankDetails {get;set;}
    public boolean noPdf {get;set;}
    public String projName {get;set;}
    public String towerName {get;set;}
    public List<Id> propertiesId;
    public List<PropStrength__Property__c> propertyList {get;set;}
    public List<propertyWrapper> propWrapper {get;set;}
    public List<PlanDetailWrapper> pplWrapperList {get;set;}
    public Decimal taxPercent {get;set;}
    private Set<Id> unitPlanId;
    private Set<Id> floorPlanId;
    public List<String> imageUnitPlan {get;set;}
    public List<String> imageFloorPlan {get;set;}
    public Map<String, Decimal> preRegistrationMap {get;set;}
    public Decimal totalPreRegFees {get;set;}
    public Map<String, Decimal> otherchargeMap {get;set;}
    public Boolean showBankDetails {get;set;}
    public QuoteDetailsWrapper quoteDetail {get;set;}
    public String currentTime {get;set;}
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        return tz.getOffset(System.now()) / (1000 * 3600 * 24.0);
    }}
    public ViewCostsheetMultiUnitCloneController() {
        noPdf = false;
        totalPreRegFees = 0.0;
        bankDetails = new Bank_GL__c();
        currentTime = System.now().format('MMM d,yyyy hh:mm a', UserInfo.getTimeZone().getID());
        taxPercent = 0.0;
        preRegistrationMap = new Map<String, Decimal>();
        pplWrapperList = new List<PlanDetailWrapper>();
        propWrapper = new List<propertyWrapper>();
        projName = '';
        showBankDetails = false;
        towerName = '';
        propertiesId = new list<Id>();
        imageUnitPlan = new List<String>();
        imageFloorPlan = new List<String>();
        otherchargeMap = new Map<String, Decimal>();
        quoteId = ApexPages.currentPage().getParameters().get('qId');
        quote = new Quote__c();
        System.debug('quoteId*---'+quoteId);
        propertyList = new List<PropStrength__Property__c>();
        quote = getQuoteDetails(quoteId);
        Id towerId;
        Decimal floorNumber;
        unitPlanId = new Set<Id>();
        floorPlanId = new Set<Id>();
        if(quote.Total_Discount__c != null && quote.Total_Discount__c > 0 && !quote.Quote_is_approved__c) {
            noPdf = true;
        }
        if(!quote.Quote_for_Multi_Properties__c) {
            propertiesId.add(quote.Property__c);
        }
        else{
            propertiesId.addAll(quote.Multi_Properties_Id_s__c.split(','));
        }
        if(!propertiesId.isEmpty()) {
            propertyList = getPropertyDetails(propertiesId);
        }
        if(!propertyList.isEmpty()) {
            taxPercent = propertyList[0].RecordType.Name != 'Commercial - Units' ? 0.0 : propertyList[0].PropStrength__Tower__r.PropStrength__GST_Status__c == 'New GST' ? 0.05 : 0.0;
            projName = propertyList[0].PropStrength__Project_Name__r.Name;
            showBankDetails = propertyList[0].PropStrength__Project_Name__r.RERA_Registered__c;
            towerName = propertyList[0].PropStrength__Tower__r.PropStrength__Tower_Name__c;
            System.debug('---Test--'+propertyList[0].PropStrength__Project_Name__c);
            bankDetails = getBankDetails(propertyList[0].PropStrength__Project_Name__c);
            
        }
        if(propertyList.size() == 1) {
            towerId = propertyList[0].PropStrength__Tower__c;
            floorNumber = propertyList[0].PropStrength__Floor__c != null ? propertyList[0].PropStrength__Floor__r.PropStrength__Floor_Number__c : 0;
            System.debug(towerId+'=======Test 0'+ propertyList[0].PropStrength__Unit_Type__c);
            unitPlanId = getUnitPlan(towerId, propertyList[0].PropStrength__Unit_Type__c);
            floorPlanId = getFloorPlan(towerId, floorNumber, propertyList[0].PropStrength__Unit_Type__c);
            System.debug('=======Test 1'+ unitPlanId);
            System.debug('=======Test 2'+ floorPlanId);
        }
        
        if(quote.Payment_Plan__c != null) {
            for(PropStrength__Payment_Plan_Line_Items__c ppl : getPPL(quote.Payment_Plan__c)) {
                if(ppl.PropStrength__Amount_Percent__c !=  null) {
                    Decimal amount = ppl.PropStrength__Amount_Percent__c * quote.Total_Purchase_Price_Modified__c / 100;
                    pplWrapperList.add(new PlanDetailWrapper(ppl.PropStrength__Payment_Plan_Line_Item_Name__c, ppl.PropStrength__Milestone__r.PropStrength__Milestone_Name__c,ppl.PropStrength__Amount_Percent__c,ppl.PropStrength__Due_After_Days__c,amount, amount * taxPercent));
                }
                else {
                    pplWrapperList.add(new PlanDetailWrapper(ppl.PropStrength__Payment_Plan_Line_Item_Name__c, ppl.PropStrength__Milestone__r.PropStrength__Milestone_Name__c, ppl.PropStrength__Amount_Percent__c,ppl.PropStrength__Due_After_Days__c,ppl.PropStrength__Amount__c, ppl.PropStrength__Amount__c* taxPercent));
                }
            }
        }
        if(!unitPlanId.isEmpty() || !floorPlanId.isEmpty()) {
            Map<String, String> mapOFFileandLink = new Map<String,String>();
            List<ContentDocumentLink> fileContentDocumentList = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                                 FROM ContentDocumentLink WHERE  (LinkedEntityId In :unitPlanId OR LinkedEntityId IN : floorPlanId)];
            for(ContentDocumentLink contentLink : fileContentDocumentList){
                mapOFFileandLink.put(contentLink.ContentDocumentId , contentLink.LinkedEntityId);
            }
            List<ContentVersion> contentVersionList = [Select Id,ContentDocumentId from ContentVersion where ContentDocumentId IN: mapOFFileandLink.keySet()];
            if(fileContentDocumentList.isEmpty()) {
                for(ContentDistribution docLink : [SELECT Id, ContentDocumentId, ContentVersionId, ContentVersion.Title, 
                                                ContentDownloadUrl, ContentVersion.FileType, 
                                                RelatedRecordId 
                                                FROM ContentDistribution 
                                                WHERE RelatedRecordId != null AND 
                                                    (RelatedRecordId =: unitPlanId OR  RelatedRecordId =: floorPlanId)]) {
                    mapOFFileandLink.put(docLink.ContentVersionId , docLink.RelatedRecordId);
                }
                contentVersionList = [Select Id,ContentDocumentId, VersionData, Title  from ContentVersion where Id IN: mapOFFileandLink.keySet()];
            }
            System.debug(unitPlanId+'--mapOFFileandLink**-'+floorPlanId);
            System.debug('mapOFFileandLink**-'+mapOFFileandLink);
            
            for(ContentVersion contRec : contentVersionList){
                String headerUrl = '';
                if(unitPlanId.contains(mapOFFileandLink.get(contRec.ContentDocumentId)) ){
                    headerUrl ='/sfc/servlet.shepherd/version/download/';
                    headerUrl += contRec.id;
                    imageUnitPlan.add(headerUrl);
                    
                } else if(unitPlanId.contains(mapOFFileandLink.get(contRec.Id))) {
                    headerUrl ='data:image/jpeg;base64,';
                    headerUrl += EncodingUtil.base64Encode(contRec.VersionData);
                    imageUnitPlan.add(headerUrl);
                }
                if(floorPlanId.contains(mapOFFileandLink.get(contRec.ContentDocumentId) )) {
                    headerUrl = '/sfc/servlet.shepherd/version/download/';
                    headerUrl += contRec.id;
                    imageFloorPlan.add(headerUrl);
                } else if(floorPlanId.contains(mapOFFileandLink.get(contRec.Id))) {
                    headerUrl = 'data:image/jpeg;base64,';
                    headerUrl += EncodingUtil.base64Encode(contRec.VersionData);
                    imageFloorPlan.add(headerUrl);
                }
            }
            SYstem.debug(imageFloorPlan+'--headerUrl**'+imageUnitPlan);
            List<Attachment> AttachmentList=[SELECT Id, Name, parentId, Body FROM Attachment 
                                        WHERE (parentId In :unitPlanId OR parentId IN : floorPlanId)];
            if(AttachmentList.size()>0) {
                for(Attachment att : AttachmentList) {
                    String headerUrl = '';
                    if(unitPlanId.contains(att.parentId)) {
                        headerUrl ='/servlet/servlet.FileDownload?file=';
                        headerUrl += att.id;
                        // imageUnitPlan.add(headerUrl);
                        
                    }
                    if(floorPlanId.contains(att.parentId)) {
                        headerUrl = '/servlet/servlet.FileDownload?file=';
                        headerUrl += att.id;
                        //  imageFloorPlan.add(headerUrl);
                    }
                }
                System.debug('==Test 3===>'+ imageUnitPlan);
                System.debug('==Test 4===>'+ imageFloorPlan);
            }
        }
        if(quote.DLD_Fees_Modified__c != null) {
            totalPreRegFees += quote.DLD_Fees_Modified__c;
            preRegistrationMap.put('4% Pre-Registration Charges', quote.DLD_Fees_Modified__c);
        }
        for (Integer i = 1 ; i <= 6 ; i++) {
            if(quote.get('Income_Charge_'+i+'__c') != null) {
                String incomeName = (String)quote.get('Income_Charge_'+i+'__c');
                Decimal incomeCharge = (Decimal)quote.get('Income_Charge_'+i+'_Amount__c');
                totalPreRegFees += incomeCharge;
                if(incomeName == 'Transfer Fee') {
                    preRegistrationMap.put('Transfer Fee',incomeCharge);
                }
                else if(incomeName == 'DLD Admin Fees') {
                    preRegistrationMap.put('Oqood Fees',incomeCharge);
                }
                else {
                    preRegistrationMap.put(incomeName,incomeCharge);
                }
            }
            else{
                break;
            }
        }
        if(quote.Other_Charge_1__c != null && quote.Floor_Rise_Modified__c != null) {
            otherchargeMap.put(quote.Other_Charge_1__c, quote.Floor_Rise_Modified__c);
        }
        if(quote.Other_Charge_2__c != null && quote.Premium_1_Modified__c != null) {
            otherchargeMap.put(quote.Other_Charge_2__c, quote.Premium_1_Modified__c);
        }
        if(quote.Other_Charge_3__c != null && quote.Premium_2_Modified__c != null) {
            otherchargeMap.put(quote.Other_Charge_3__c, quote.Premium_2_Modified__c);
        }
        if(quote.Other_Charge_4__c != null && quote.Other_Charge_4_Modified__c != null) {
            otherchargeMap.put(quote.Other_Charge_4__c, quote.Other_Charge_4_Modified__c);
        }
        Decimal dldPercent = ViewCostsheetMultiUnitCloneController.getDlDCharge(propertyList[0].PropStrength__Project_Name__c);
        for(PropStrength__Property__c p : propertyList) {
            Decimal amount = p.PropStrength__Total_Sales_Consideration__c;
            if(quote.Discount_in_Rate_Per_Unit_Area__c != null) {
                amount = amount - (quote.Discount_in_Rate_Per_Unit_Area__c*p.PropStrength__Super_Area__c);
            }
            
            if(quote.Discount__c != null) {
                amount = amount - (amount*quote.Discount__c/100);
            }
            
            for(PropStrength__Property_Charges__c ppCharge : p.PropStrength__Property_Charges__r) {
                if(ppCharge.PropStrength__Type__c == 'Fixed') {
                    amount = amount + ppCharge.PropStrength__Fixed_Charge__c;
                }
                if(ppCharge.PropStrength__Type__c == 'Flexible') {
                    amount = amount + ppCharge.PropStrength__Rate_per_unit_Area__c * p.PropStrength__Super_Area__c;
                }
            }
            Decimal regFees = amount * dldPercent / 100;
            System.debug('====>'+ regFees);
            propWrapper.add(new propertyWrapper(p.PropStrength__Property_Name__c, amount, regFees));
        }
        
    }
    public class QuoteDetailsWrapper {
        public String customerName {get;set;}
        public String customerEmail {get;set;}
        public Date validity {get;set;}
        public String buildNo {get;set;}
        public Decimal floorNo {get;set;}
        public String unitNo {get;set;}
        public String NoOFBedroom {get;set;}
        public String Type {get;set;}
        public Decimal superArea {get;set;}
        public Decimal BSP {get;set;}
        public string developerId {get;set;}
        
        public QuoteDetailsWrapper(String customerName ,String customerEmail, Date validity, String buildNo, Decimal floorNo, String Type, String unitNo, String NoOFBedroom,  Decimal superArea, Decimal BSP, String developerId) {
            this.customerName = customerName;
            this.customerEmail = customerEmail;
            this.validity = validity;
            this.buildNo = buildNo;
            this.floorNo = floorNo;
            this.Type = Type;
            this.unitNo = unitNo;
            this.NoOFBedroom = NoOFBedroom;
            this.superArea = superArea;
            this.BSP = BSP;
            this.developerId = developerId;
        }
    }
    public class propertyWrapper {
        public String proName {get;set;}
        public Decimal purchase {get;set;}
        public Decimal regFees {get;set;}
        
        public propertyWrapper(String proName,Decimal purchase, Decimal regFees) {
            this.proName = proName;
            this.purchase = purchase;
            this.regFees = regFees;
        }
    }
    public class PlanDetailWrapper {
        public String pplName {get;set;}
        public String percent {get;set;}
        public String mileStoneName {get;set;}
        public Decimal amount {get;set;}
        public Decimal tax {get;set;}
        public Date EstimatedDate {get;set;}
        public Decimal total {get;set;}
        
        public PlanDetailWrapper(String pplName, String mileStoneName, Decimal percentage, Decimal dueDate, Decimal amount, Decimal tax) {
            this.pplName = pplName;
            this.mileStoneName = mileStoneName;
            percent = percentage != null ? percentage.setScale(2, System.RoundingMode.HALF_UP)+'%' : '';
            EstimatedDate = System.today().addDays(Integer.valueOf(dueDate));
            this.amount = amount.setScale(2, System.RoundingMode.HALF_UP);
            this.tax = tax.setScale(2, System.RoundingMode.HALF_UP);
            total = (amount + tax).setScale(2, System.RoundingMode.HALF_UP);
        }
    }
    private Quote__c getQuoteDetails(Id qId) {
        list<Quote__c> quoteList = [SELECT Id, Name, Basic_Sale_Price_Modified__c, Basic_Sale_Price_Original__c, DLD_Fees_Modified__c, DLD_Fees_Original__c, Discount_Type__c, Customer_Name__c,Customer_Email__c,
                Discount_in_Rate_Per_Unit_Area__c, Discount_Amount__c, Discount__c, Property__c, Property__r.PropStrength__Property_Name__c,  Property__r.Project__c, Property__r.Project__r.Siniya_Island_Project__c, Quote_for_Multi_Properties__c, 
                Quote_is_approved__c, Total_Discount__c,Multi_Properties__c, Multi_Properties_Id_s__c,Payment_Plan__c, Quote_Validity__c,
                Income_Charge_1__c, Income_Charge_1_Amount__c,Other_Charge_4__c, Floor_Rise_Modified__c, Premium_1_Modified__c, Premium_2_Modified__c, Other_Charge_4_Modified__c,
                Income_Charge_2__c, Income_Charge_2_Amount__c,Total_Purchase_Price_Modified__c, Property__r.PropStrength__Category__c,
                Income_Charge_3__c, Income_Charge_3_Amount__c, Property__r.PropStrength__Unit_Type__c,
                Income_Charge_4__c, Income_Charge_4_Amount__c,
                Income_Charge_5__c, Income_Charge_5_Amount__c, Property__r.PropStrength__Rate_per_unit_area__c,
                Income_Charge_6__c, Income_Charge_6_Amount__c,Property__r.PropStrength__Super_Area__c, Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,
                Property__r.PropStrength__Floor__r.PropStrength__Floor_Number__c, Property__r.PropStrength__Property_Type_Name__c,
                Other_Charge_1__c, Other_Charge_2__c, Other_Charge_3__c, Property__r.PropStrength__Tower__r.RDS_Company_Code__r.Developer_ID__c
                FROM Quote__c 
                WHERE Id =:qId LIMIT 1];
        if(quoteList.size() > 0) {
            Quote__c q = quoteList[0];
            quoteDetail = new QuoteDetailsWrapper(q.Customer_Name__c, q.Customer_Email__c, q.Quote_Validity__c, q.Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, q.Property__r.PropStrength__Floor__r.PropStrength__Floor_Number__c, q.Property__r.PropStrength__Category__c, q.Property__r.PropStrength__Property_Name__c, q.Property__r.PropStrength__Unit_Type__c, q.Property__r.PropStrength__Super_Area__c, q.Property__r.PropStrength__Rate_per_unit_area__c, q.Property__r.PropStrength__Tower__r.RDS_Company_Code__r.Developer_ID__c);
        }
        return quoteList[0];
    }
    
    private List<PropStrength__Property__c> getPropertyDetails (List<Id> propIds) {
        return [SELECT Id, PropStrength__Property_Name__c, PropStrength__Project_Name__c, PropStrength__Project_Name__r.RERA_Registered__c, PropStrength__Property_Type__c, PropStrength__Project_Name__r.Name, PropStrength__Unit_Type__c,
                PropStrength__Property_Type_Name__c, PropStrength__Tower__c, PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Floor__r.PropStrength__Floor_Name__c, 
                PropStrength__Floor__r.PropStrength__Floor_Number__c, Purchase_Price__c,PropStrength__Total_Sales_Consideration__c, RecordType.Name, RecordTypeId,
                PropStrength__Super_Area__c, PropStrength__Rate_per_unit_area__c,PropStrength__Tower__r.PropStrength__GST_Status__c,
                (SELECT Id, PropStrength__Fixed_Charge__c, PropStrength__Other_Charges_Code_Name__c, PropStrength__Rate_per_unit_Area__c, PropStrength__Type__c FROM PropStrength__Property_Charges__r)
                FROM PropStrength__Property__c
                WHERE Id IN :propIds];
    }
    private List<PropStrength__Payment_Plan_Line_Items__c> getPPL(Id pPlan) {
        return [SELECT Id,PropStrength__Payment_Plan_Line_Item_Name__c, PropStrength__Milestone__c, PropStrength__Milestone__r.PropStrength__Milestone_Name__c,PropStrength__Order__c, 
                                                                 PropStrength__Amount_Percent__c, PropStrength__Due_After_Days__c, PropStrength__Amount__c 
                                                                 FROM PropStrength__Payment_Plan_Line_Items__c 
                                                                 WHERE PropStrength__Payment_Plan__c = :pPlan
                                                                 ORDER BY PropStrength__Order__c];
    }
    private Set<Id> getUnitPlan(Id towerId, String unitType) {
        Set<Id> unitPlanId = new Set<Id>();
        for(CS_Unit_plan__c u : [SELECT Id, Tower__c , Unit_Type__c  FROM CS_Unit_plan__c WHERE Tower__c=:towerId AND Unit_Type__c =:unitType]) {
            unitPlanId.add(u.Id);
        }
        return unitPlanId;
    }
    private Set<Id> getFloorPlan(Id towerId, Decimal floorNumber, String unitType) {
        Set<Id> floorPlanId = new Set<Id>();
        for(CS_Floor_Plan__c fp : [SELECT Id, Tower__c, Plan_Floor_From__c, Plan_Floor_To__c, Unit_Type__c FROM CS_Floor_Plan__c WHERE Tower__c =: towerId AND Plan_Floor_From__c <= :floorNumber AND Plan_Floor_To__c >= :floorNumber AND Unit_Type__c =:unitType ]) {
            floorPlanId.add(fp.Id);
        }
        return floorPlanId;
    }
    private Bank_GL__c getBankDetails(Id projId) {
        List<Bank_GL__c> bglList = [SELECT Id,Bank_Account_Type__c, Account_Number__c, Beneficiary__c, IBAN__c, Swift_Code__c, Bank_Name__c, Branch__c, Project__c FROM Bank_GL__c 
                                    WHERE Project__c =:projId 
                                    AND Bank_Account_Type__c = 'Escrow Account'];
        if(bglList.isEmpty()) {
            return null;
        }
        else {
            return bglList[0];
        }
    }
    private static Decimal getDlDCharge(Id proj) {
        List<PropStrength__Income_Charges__c> incomeCharge = InventoryCostServicesMultiUnitClone.getIncomeChargeList(proj);
        for(PropStrength__Income_Charges__c ic : incomeCharge) {
            if(ic.PropStrength__Category__c.contains('DLD Fees')) {
                return ic.Charge__c;
            }
        }
        return 0;
    }
}