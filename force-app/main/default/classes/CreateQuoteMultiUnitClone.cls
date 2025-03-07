public with sharing class CreateQuoteMultiUnitClone {
    public String Comments {get; set;}
    public String stringOfPropertySelected {get; set;}
    public List<String> propertyIds;
    public List<PropStrength__Property__c> propertyList {get;set;}
    public Id projId {get;set;}
    public String ProjName {get;set;}
    public Id enquiryId {get;set;}
    public PropStrength__Request__c enquiryRec {get;set;}
    public Quote__c q {get;set;}
    public String selectedPlan {get;set;}
    public String selectedPlanName {get;set;}
    public Decimal basicOrginalPrice {get;set;}
    public Decimal totalPurchaseOrginalPrice {get;set;}
    public Decimal totalPurchaseModifiedPrice {get;set;}
    public Decimal basicModifiedPrice {get;set;}
    public Decimal dLdOriginalPrice {get;set;}
    public Decimal totalDLdOriginalPrice {get;set;}
    public Decimal totalDLdTaxPrice {get;set;}
    public Decimal totalDLdModifiedPrice {get;set;}
    public Decimal dLdModifiedPrice {get;set;}
    public Decimal dldCharge;
    public String discountType {get;set;}
    public Decimal psfAmount {get;set;}
    public Map<String, Decimal> chargeMap {get; set;}
    public list<SelectOption> lstPlans {get;set;}
    public Decimal lumpsum {get;set;}
    public Decimal percent {get;set;}
    public boolean applyDiscount {get;set;}
    public Decimal totalSquareFeet {get;set;}
    public Decimal totalDiscount {get;set;}
    public Decimal discountPurchase {get;set;}
    public Decimal discountReg {get;set;}
    public boolean isContinue {get;set;}
    public List<PropStrength__Payment_Plan__c> payPlanList {get;set;}
    public boolean disableGenerateQuote {get;set;}
    public Decimal SOriginalPlanNPV {get; set;}
    public Decimal SUpdatedPlanNPV {get; set;}
    public Decimal SDiscount {get; set;}
    public Decimal SOriginalNPVPSF {get; set;}
    public Decimal SUpdatedNPVPSF {get; set;}
    public Decimal SDiscountPSF {get; set;}
    public List<PlanDetailWrapper> pplWrapperList {get;set;}
    public Decimal taxPercent {get;set;}
    public List<incomeChageDetails> incomeChargeList{get;set;}
    public Decimal totalDLdModTaxPrice {get;set;}
    public Boolean showDiscountPanel {get;set;}
    public Decimal maxDiscountPercent;

    public CreateQuoteMultiUnitClone() {
        chargeMap = new Map<String, Decimal>();
        selectedPlanName ='';
        maxDiscountPercent = 0.0;
        totalDLdTaxPrice = 0.0;
        taxPercent = 0.0;
        incomeChargeList = new list<incomeChageDetails>();
        totalPurchaseModifiedPrice = 0;
        SOriginalPlanNPV = 0;
        pplWrapperList = new List<PlanDetailWrapper>();
        SUpdatedPlanNPV = 0;
        SDiscount = 0;
        SOriginalNPVPSF = 0;
        SUpdatedNPVPSF = 0;
        SDiscountPSF = 0;
        enquiryRec = new PropStrength__Request__c();
        propertyIds = new List<String>(); 
        payPlanList = new List<PropStrength__Payment_Plan__c>();
        lstPlans = new List<SelectOption>();
        propertyList = new List<PropStrength__Property__c>();
        stringOfPropertySelected = '';
        disableGenerateQuote = false;
        projId = null;
        totalDLdOriginalPrice = 0.0;
        basicOrginalPrice = 0;
        basicModifiedPrice = 0;
        dLdOriginalPrice = 0;
        totalDLdModTaxPrice = 0.0;
        dLdModifiedPrice = 0;
        dldCharge = 0;
        discountType = '';
        q = new Quote__c();
        psfAmount = 0;
        enquiryId = null;
        lumpsum = 0;
        percent = 0;
        totalSquareFeet = 0;
        applyDiscount = false;
        discountPurchase = 0;
        totalDiscount = 0;
        discountReg = 0;
        isContinue = false;
        enquiryId = q.Enquiry__c;
        showDiscountPanel = true;
		String roleName =  '';
        List<UserRole> ListroleName =  [SELECT Id, Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() LIMIT 1];
        if(ListroleName.Size() > 0)
            roleName = ListroleName[0].Name;
        if(roleName.containsIgnoreCase('Sales Manager')) {
            showDiscountPanel = false;
        }
    }

    public PageReference cancel() {
        pageReference pRef = ApexPages.currentPage();
        pRef.setRedirect(true);
        return pRef;
    }
    
    public pageReference resetQuote(){
        PageReference pageRef;
        pageRef = new PageReference('/apex/CreateQuoteMultiUnitClone?idList='+stringOfPropertySelected); 
        pageRef.setRedirect(true);
        return pageRef;
    }  
    
    public pageReference applyDiscounts() {
        System.debug(basicModifiedPrice+'-**---*----'+basicOrginalPrice);
        System.debug(totalDLdModifiedPrice+'-**---*----'+totalDLdOriginalPrice);
        basicModifiedPrice = basicOrginalPrice;
        System.debug(dLdModifiedPrice+'-**---*------'+dLdOriginalPrice);
        dLdModifiedPrice = dLdOriginalPrice;
        boolean flag = true;
        if(discountType == '') {
            flag = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, +'Please Enter Discount type'));
        }
        if(psfAmount < 0) {
            flag = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, +'Please select a valid PSF Amount'));
        }
        if(lumpsum < 0) {
            flag = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, +'Please select a valid Lumpsum Amount'));
        }
        if(percent < 0) {
            flag = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, +'Please select a valid Percent'));
        }
        else if(percent > maxDiscountPercent) {
            flag = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, +'Discount Percent should not be greater than '+maxDiscountPercent));
        }
        if( (psfAmount > 0 && lumpsum > 0 ) || (psfAmount > 0 && percent > 0 ) || (percent > 0 && lumpsum > 0)) {
            flag = false;
            psfAmount = 0;
            lumpsum = 0;
            percent = 0;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, +'Please select only one type of discount'));
        }
        
        System.debug(flag+'**----**'+applyDiscount);
        Decimal maxDiscount = (basicModifiedPrice * maxDiscountPercent) / 100;
        if(flag && applyDiscount) {
            if(psfAmount > 0 ) {
                System.debug(psfAmount+'**----**'+totalSquareFeet);
                basicModifiedPrice = basicModifiedPrice - psfAmount*totalSquareFeet;
            }
            if(lumpsum > 0) {
                System.debug(basicModifiedPrice+'**----**'+lumpsum);
                basicModifiedPrice = basicModifiedPrice - lumpsum; 
                System.debug(basicModifiedPrice+'**----**'+lumpsum);
            }
            if(percent > 0 && percent <= 100) { 
                Decimal amount = basicModifiedPrice * percent / 100;
                System.debug(basicModifiedPrice+'----amount*---'+amount);
                basicModifiedPrice = basicModifiedPrice - amount;   
                System.debug('amount*---'+basicModifiedPrice);
            }
        }
        System.debug('basicModifiedPrice*----'+basicModifiedPrice);
        System.debug('basicOrginalPrice--> '+basicOrginalPrice);
        System.debug('basicModifiedPrice--> '+basicModifiedPrice);
        discountPurchase = basicOrginalPrice - basicModifiedPrice;
        System.debug('discountPurchase--> '+discountPurchase);
        if(totalPurchaseModifiedPrice == totalPurchaseOrginalPrice )
        	totalPurchaseModifiedPrice -= discountPurchase;
        System.debug('totalPurchaseModifiedPrice--> '+totalPurchaseModifiedPrice);
        System.debug('dldCharge--> '+dldCharge);            
        dLdModifiedPrice = totalPurchaseModifiedPrice * dldCharge / 100;
        System.debug('dLdModifiedPrice--> '+dLdModifiedPrice);
        System.debug('dLdOriginalPrice--> '+dLdOriginalPrice);
        totalDLdModifiedPrice =  totalDLdOriginalPrice - (dLdOriginalPrice - dLdModifiedPrice);
        System.debug('totalDLdModifiedPrice--> '+totalDLdModifiedPrice);
        System.debug('totalDLdTaxPrice--> '+totalDLdTaxPrice);
        totalDLdModTaxPrice = totalDLdTaxPrice;
        System.debug('totalDLdModTaxPrice--> '+totalDLdModTaxPrice);
        discountReg = dLdOriginalPrice - dLdModifiedPrice;
        System.debug('discountReg--> '+discountReg);
        if(discountPurchase > maxDiscount) {
            Decimal psfA = (maxDiscount / totalSquareFeet).setScale(2, System.RoundingMode.HALF_UP);
            basicModifiedPrice = basicOrginalPrice;
            totalPurchaseModifiedPrice = totalPurchaseOrginalPrice;
            discountPurchase = 0;
            discountReg = 0;
            dLdModifiedPrice = dLdOriginalPrice;
            totalDLdModTaxPrice = totalDLdTaxPrice;
            totalDLdModifiedPrice =  totalDLdOriginalPrice;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, +'Discount should not be greater than '+maxDiscountPercent+'% . You may select PSF upto '+ psfA+'. OR Lumpsum Upto '+ maxDiscount+' .OR Percent upto '+maxDiscountPercent+'%'));
        }
        System.debug('discountPurchase--> '+discountPurchase);
        System.debug('discountReg--> '+discountReg);
       // totalDiscount = discountReg + discountPurchase;
        totalDiscount = discountPurchase;
        System.debug('totalDiscount--> '+totalDiscount);
        return null;
    }

    public pageReference continueMethod() {
        isContinue = true;
        SOriginalPlanNPV = totalPurchaseOrginalPrice;
        SUpdatedPlanNPV = totalPurchaseModifiedPrice;
        SDiscount = totalDiscount; 
        SOriginalNPVPSF = totalSquareFeet != 0 ? (totalPurchaseOrginalPrice / totalSquareFeet).setScale(2, System.RoundingMode.HALF_UP) : 0;
        SUpdatedNPVPSF = totalSquareFeet != 0 ? (totalPurchaseModifiedPrice / totalSquareFeet).setScale(2, System.RoundingMode.HALF_UP) : 0;
        SDiscountPSF = totalSquareFeet != 0 ? (totalDiscount / totalSquareFeet).setScale(2, System.RoundingMode.HALF_UP) : 0;
        Boolean isValid = (selectedPlan InstanceOf ID) ? true : false;
        List<PropStrength__Payment_Plan_Line_Items__c> pplList = new List<PropStrength__Payment_Plan_Line_Items__c>();
        pplWrapperList = new List<PlanDetailWrapper>();
        if(isValid) {
            pplList = InventoryCostServicesMultiUnitClone.getPPL(selectedPlan);
        }
        if(!pplList.isEmpty()) {
            for(PropStrength__Payment_Plan_Line_Items__c ppl : pplList) {
                if(ppl.PropStrength__Amount_Percent__c !=  null) {
                    Decimal amount = ppl.PropStrength__Amount_Percent__c * totalPurchaseModifiedPrice / 100;
                    pplWrapperList.add(new PlanDetailWrapper(ppl.PropStrength__Milestone__r.PropStrength__Milestone_Name__c, ppl.PropStrength__Amount_Percent__c,ppl.PropStrength__Due_After_Days__c,amount, amount * taxPercent));
                }
                else {
                    pplWrapperList.add(new PlanDetailWrapper(ppl.PropStrength__Milestone__r.PropStrength__Milestone_Name__c, ppl.PropStrength__Amount_Percent__c,ppl.PropStrength__Due_After_Days__c,ppl.PropStrength__Amount__c, ppl.PropStrength__Amount__c * taxPercent));
                }
            }
        }
        return null;
    }
    public PageReference startQuote() {
        enquiryId = q.Enquiry__c;
        if(enquiryId != null) {
            enquiryRec = InventoryCostServicesMultiUnitClone.getEnquiry(enquiryId);
        }
        stringOfPropertySelected = ApexPages.currentPage().getParameters().get('idList');
        if(stringOfPropertySelected == null)return null;
        propertyIds = stringOfPropertySelected.split(',');
        if(!propertyIds.isEmpty()) {
            basicOrginalPrice = 0;
            basicModifiedPrice = 0;
            dLdOriginalPrice = 0;
            dLdModifiedPrice = 0;
            propertyList = [SELECT Id,Name,PropStrength__Property_Name__c, PropStrength__Tower__c, PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Project_Name__c, 
                            PropStrength__Project_Name__r.Name, PropStrength__Floor__c, PropStrength__Floor__r.Name, PropStrength__Floor__r.PropStrength__Floor_Name__c, 
                            PropStrength__Floor__r.PropStrength__Floor_Number__c, PropStrength__Total_Sales_Consideration__c, PropStrength__Super_Area__c, DLD_Admin_Fees__c,
                            PropStrength__Unit_Type__c,PropStrength__Tower__r.PropStrength__GST_Status__c,RecordTypeId, RecordType.Name, PropStrength__Project_Name__r.NPV__c,
                            (SELECT Id, PropStrength__Fixed_Charge__c, PropStrength__Other_Charges_Code_Name__c, PropStrength__Rate_per_unit_Area__c, PropStrength__Type__c FROM PropStrength__Property_Charges__r)
                            FROM PropStrength__Property__c 
                            WHERE Id IN :propertyIds ];
                if(!propertyList.isEmpty()) {
                    taxPercent = propertyList[0].RecordType.Name != 'Commercial - Units' ? 0.0 : propertyList[0].PropStrength__Tower__r.PropStrength__GST_Status__c == 'New GST' ? 0.05 : 0.0;
                    projId = propertyList[0].PropStrength__Project_Name__c;
                    ProjName = propertyList[0].PropStrength__Project_Name__r.Name;
                    maxDiscountPercent = propertyList[0].PropStrength__Project_Name__r.NPV__c != null ? propertyList[0].PropStrength__Project_Name__r.NPV__c : 5;
                    totalSquareFeet = 0;
                    for(PropStrength__Property__c prop :  propertyList) {
                        if(prop.PropStrength__Total_Sales_Consideration__c != null) {
                            basicOrginalPrice +=  prop.PropStrength__Total_Sales_Consideration__c;
                        }
                        if(prop.PropStrength__Super_Area__c != null) {
                            totalSquareFeet += prop.PropStrength__Super_Area__c;
                        }  
                    }
                    for(PropStrength__Property__c prop :  propertyList) {
                        for(PropStrength__Property_Charges__c ppCharge : prop.PropStrength__Property_Charges__r) {
                            if(ppCharge.PropStrength__Type__c == 'Fixed') {
                                if(!chargeMap.containsKey(ppCharge.PropStrength__Other_Charges_Code_Name__c)) {
                                    chargeMap.put(ppCharge.PropStrength__Other_Charges_Code_Name__c, 0);
                                }
                                chargeMap.put(ppCharge.PropStrength__Other_Charges_Code_Name__c, chargeMap.get(ppCharge.PropStrength__Other_Charges_Code_Name__c) + ppCharge.PropStrength__Fixed_Charge__c);
                            }
                            if(ppCharge.PropStrength__Type__c == 'Flexible') {
                                if(!chargeMap.containsKey(ppCharge.PropStrength__Other_Charges_Code_Name__c)) {
                                    chargeMap.put(ppCharge.PropStrength__Other_Charges_Code_Name__c, 0);

                                }
                                Decimal amt = ppCharge.PropStrength__Rate_per_unit_Area__c * prop.PropStrength__Super_Area__c;
                                chargeMap.put(ppCharge.PropStrength__Other_Charges_Code_Name__c, chargeMap.get(ppCharge.PropStrength__Other_Charges_Code_Name__c) + amt);
                            }
                        } 
                    }
                    basicModifiedPrice = basicOrginalPrice;
                    totalPurchaseOrginalPrice = basicOrginalPrice;
                    for(String chargeName : chargeMap.keySet()) {
                        totalPurchaseOrginalPrice += chargeMap.get(chargeName);
                    }
                    totalPurchaseModifiedPrice = totalPurchaseOrginalPrice;
                    payPlanList = InventoryCostServicesMultiUnitClone.getPlanList(propertyList[0].PropStrength__Project_Name__c);
                    if(payPlanList != null && !payplanList.isEmpty()) {
                        selectedPlan = payPlanList[0].Id;
                        selectedPlanName = payPlanList[0].Name;
                        for(PropStrength__Payment_Plan__c p : payPlanList) {
                            lstPlans.add(new SelectOption(p.Id, p.Name));
                    }
                    List<PropStrength__Income_Charges__c> incomeChargesList = new List<PropStrength__Income_Charges__c>();
                    incomeChargesList = InventoryCostServicesMultiUnitClone.getIncomeChargeList(propertyList[0].PropStrength__Project_Name__c);
                    if(!incomeChargesList.isEmpty()) {
                        for(PropStrength__Income_Charges__c rec : incomeChargesList) {
                            if(rec.PropStrength__Category__c.contains('DLD Fees')) {
                                dldCharge = rec.Charge__c;
                                dLdOriginalPrice = totalPurchaseOrginalPrice * rec.Charge__c / 100;
                                dLdModifiedPrice = dLdOriginalPrice;
                            }
                            else {
                                Decimal amt =  rec.PropStrength__Amount__c;
                                Decimal tx =  propertyList[0].RecordType.Name != 'Commercial - Units' ? 0.0 : rec.PropStrength__Service_Tax__c/100;
                                if(rec.PropStrength__Type__c == 'Fixed') {
                                    amt *= propertyList.size();
                                    incomeChargeList.add(new incomeChageDetails(rec.Name, amt , tx * amt));
                                }
                                if(rec.PropStrength__Type__c == 'Flexible') {
                                    amt *= totalSquareFeet;
                                    incomeChargeList.add(new incomeChageDetails(rec.Name, amt, tx * amt));
                                }                                
                            }
                        }
                    }
                    totalDLdOriginalPrice = dLdOriginalPrice; 
                    totalDLdTaxPrice = 0.0;
                    for(incomeChageDetails st : incomeChargeList) {
                        totalDLdOriginalPrice += st.amount;
                        totalDLdTaxPrice += st.tax;
                    }
                    totalDLdModifiedPrice = totalDLdOriginalPrice;
                    totalDLdModTaxPrice = totalDLdTaxPrice;
                }
            }
        }
        return null;
    }

    public PageReference createQuote() {
        if(propertyList.size() == 1) {
            q.Property__c = propertyList[0].Id;
            q.Quote_for_Multi_Properties__c = false;
        }
        else if(propertyList.size() > 1) {
            String propName = '';
            for(PropStrength__Property__c prop : propertyList) {
                propName += prop.PropStrength__Property_Name__c+', ';
            }
            q.Multi_Properties__c = propName;
            q.Multi_Properties_Id_s__c = stringOfPropertySelected;
            q.Quote_for_Multi_Properties__c = true;
        }
        q.Payment_Plan__c = selectedPlan;
        q.Discount_Type__c = discountType;
        q.Total_Discount__c = totalDiscount > 0 ? totalDiscount : null;
        q.Discount_in_Rate_Per_Unit_Area__c = psfAmount > 0 ? psfAmount : null;
        q.Discount_Amount__c = lumpsum > 0 ? lumpsum : null;
        q.Discount__c = percent > 0 ? percent : null;
        q.Basic_Sale_Price_Original__c = basicOrginalPrice > 0 ? basicOrginalPrice : null;
        q.Basic_Sale_Price_Modified__c = basicModifiedPrice > 0 ? basicModifiedPrice : null;
        q.DLD_Fees_Original__c = dLdOriginalPrice > 0 ? dLdOriginalPrice : null;
        q.DLD_Fees_Modified__c = dLdModifiedPrice > 0 ? dLdModifiedPrice : null;
        Integer i = 1;
        for(String st : chargeMap.keySet()) {
            if(i == 5) {
                break;
            }
            q.put('Other_Charge_'+i+'__c', st);
            if(i == 1) {
                q.put('Floor_Rise_Original__c', chargeMap.get(st));
                q.put('Floor_Rise_Modified__c', chargeMap.get(st));
            }
            if(i == 2) {
                q.put('Premium_1_Original__c', chargeMap.get(st));
                q.put('Premium_1_Modified__c', chargeMap.get(st));
            }
            if(i == 3) {
                q.put('Premium_2_Original__c', chargeMap.get(st));
                q.put('Premium_2_Modified__c', chargeMap.get(st));
            }
            if(i == 4) {
                q.put('Other_Charge_4_Original__c', chargeMap.get(st));
                q.put('Other_Charge_4_Modified__c', chargeMap.get(st));  
            }
            i++; 
        } 
        i = 1;
        for(incomeChageDetails ic : incomeChargeList) {
            if(i == 6) {
                break;
            }
            q.put('Income_Charge_'+i+'__c', ic.name);
            q.put('Income_Charge_'+i+'_Amount__c', ic.amount);
            i++;    
        }
        insert q;
        PageReference pageRef;
        pageRef = new PageReference('/'+q.Id); 
        pageRef.setRedirect(true);
        return pageRef;
    }  
    public void planSelect() {
        for(SelectOption op : lstPlans) {
            if(op.getValue() == selectedPlan) {
                selectedPlanName = op.getLabel();
            }
        }
        Boolean isValid = (selectedPlan InstanceOf ID) ? true : false;
    }

    public class PlanDetailWrapper {
        public String percent {get;set;}
        public String mileStoneName {get;set;}
        public Decimal amount {get;set;}
        public Decimal tax {get;set;}
        public Date EstimatedDate {get;set;}
        public Decimal total {get;set;}

        public PlanDetailWrapper(String mileStoneName, Decimal percentage, Decimal dueDate, Decimal amount, Decimal tax) {
            this.mileStoneName = mileStoneName;
            percent = percentage != null ? percentage.setScale(2, System.RoundingMode.HALF_UP)+'%' : '';
            EstimatedDate = System.today().addDays(Integer.valueOf(dueDate));
            this.amount = amount.setScale(2, System.RoundingMode.HALF_UP);
            this.tax = tax.setScale(2, System.RoundingMode.HALF_UP);
            total = (amount + tax).setScale(2, System.RoundingMode.HALF_UP);
        }
    }
    
    public class incomeChageDetails{
        public String name {get;set;}
        public Decimal amount {get;set;}
        public Decimal tax {get;set;}
        public incomeChageDetails(String name, Decimal amount, Decimal tax) {
            this.name = name;
            this.amount = amount;
            this.tax = tax;
        }
    }
}