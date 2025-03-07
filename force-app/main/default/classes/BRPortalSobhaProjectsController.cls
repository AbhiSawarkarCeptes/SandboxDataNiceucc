public without sharing class BRPortalSobhaProjectsController {
    @AuraEnabled
    public static List<PropStrength__Property__c> getUnits(List<String> projectId, List<String> config, 
                                                            List<String> area, List<String> price, 
                                                            List<String> propertyType, List<String> subProjects, 
                                                            List<String> unitTypes, List<String> floors, 
                                                            List<String> unitNames, List<String> variants, 
                                                            List<String> areas, List<String> prices) {
        System.debug('===> projectId ' + projectId);
        System.debug('===> subProjects ' + subProjects);
        System.debug('===> config ' + config);
        System.debug('===> unitTypes ' + unitTypes);
        System.debug('===> variants ' + variants);
        System.debug('===> floors ' + floors);
        System.debug('===> unitNames ' + unitNames);
        System.debug('===> area ' + area);
        System.debug('===> areas ' + areas);
        System.debug('===> price ' + price);
        System.debug('===> prices ' + prices);
        System.debug('===> propertyType ' + propertyType);
        List<PropStrength__Property__c> propertyList = new List<PropStrength__Property__c>();
        String query = 'SELECT Id, Name, PropStrength__Project_Name__c, PropStrength__Project_Name__r.Name, PropStrength__Unit_Type__c, ' + 
                            'Variant__c, PropStrength__Tower__c, PropStrength__Tower__r.Name, PropStrength__Floor_Number__c, ' + 
                            'PropStrength__Project_Name__r.Master_Project__c, PropStrength__Project_Name__r.Master_Project__r.Name, ' + 
                            'PropStrength__Super_Area__c, PropStrength__Total_Sales_Consideration__c FROM PropStrength__Property__c ' + 
                            'WHERE PropStrength__Unit_Status__c = \'Available\' AND PropStrength__Project_Name__r.Hide_From_3rd_Party__c = false AND ' + 
                            'PropStrength__Project_Name__r.Master_Project__r.Hide_From_3rd_Party__c = false AND For_Direct_Sale__c = false AND PropStrength__Project_Name__c != null ';
        if(projectId.size()>0) {
            String masterName = '';
            for(String str : projectId) {
                str = str.trim();
                masterName += '\'' + str + '\',';
            }
            if(!String.isBlank(masterName)) {
                masterName = masterName.removeEND(',');
                System.debug('===> masterName ' + masterName);
                masterName = '(' + masterName + ')';
                query += ' AND PropStrength__Project_Name__r.Master_Project__r.Name IN ' + masterName;      
            }
        }
        if(area.size() > 0 && areas.size() > 0) {
            areas.addAll(area);
        } else if(area.size()>0) {
            areas = new List<String>();
            areas.addAll(area);
        }
        System.debug('===> price ' + price);
        if(price.size()>0 && prices.size()>0) {
            prices.addAll(price);
        } else if(price.size()>0) {
            prices = new List<String>();
            prices.addAll(price);
        }
        System.debug('===> prices ' + prices);
        if(prices.size()>0) {
            System.debug('===> prices ' + prices);
            String tempPriceStr = '';
            for(string pr : prices) {
                if(pr.contains('Above 10')) {
                    List<string> priceList = pr.split(' ');
                    Double priceVal = Double.valueOf(priceList[1]);
                    priceVal = priceVal * 1000000;
                    tempPriceStr += ' (PropStrength__Total_Sales_Consideration__c > '+ priceVal + ') OR';
                } else {
                    List<String> priceList = pr.split(' ');
                    if(priceList.size() > 5) {
                        Double fromPrice = Double.valueOf(priceList[1]);
                        fromPrice = fromPrice * 1000000;
                        Double toPrice = Double.valueOf(priceList[5]);
                        toPrice = toPrice * 1000000;
                        tempPriceStr += ' (PropStrength__Total_Sales_Consideration__c >= ' + fromPrice + ' AND PropStrength__Total_Sales_Consideration__c <= ' + toPrice + ') OR';
                    }
                }
            }
            if(tempPriceStr != '') {
                tempPriceStr = tempPriceStr.removeEnd('OR');
                tempPriceStr = ' AND (' + tempPriceStr + ') ';
                query += tempPriceStr;
            }
        }
        if(areas.size()>0) {
            System.debug('===> areas ' + areas);
            string tempStr = '';
            for(string ar : areas) {
                if(ar.contains('Above 6000')) {
                    List<String> areaList = ar.split(' ');
                    double areaVal = double.valueOf(areaList[1]);
                    tempStr += ' (PropStrength__Super_Area__c > '+ areaVal + ') OR';
                } else {
                    List<string> areaList = ar.split(' ');
                    if(areaList.size() > 2) {
                        double fromArea = double.valueOf(areaList[0]);
                        double toArea = double.valueOf(areaList[2]);
                        tempStr += ' (PropStrength__Super_Area__c >= '+ fromArea +' AND PropStrength__Super_Area__c <= '+ toArea + ') OR';
                    }
                }
            }
            if(tempStr != '') {
                tempStr = tempStr.removeEnd('OR');
                tempStr = ' AND (' + tempStr + ') ';
                query += tempStr;
            }
        }
        if(propertyType.size()>0) {
            String recName = '';
            String othersFilterPropType = '';
            for(String str : propertyType) {
                str = str.trim();
                if(!str.containsIgnoreCase('Others')) {
                    recName += '\'' + str + '\',';
                } else if(str.containsIgnoreCase('Others')) {
                    othersFilterPropType += '\'' + str + '\',';
                }
            }
            Boolean flag = true;
            if(!String.isBlank(othersFilterPropType)) {
                othersFilterPropType = othersFilterPropType.removeEND(',');
                System.debug('===> othersFilterPropType ' + othersFilterPropType);
                if(String.isBlank(recName)) {
                    othersFilterPropType = '(\'Apartment\',\'Villas\')';
                } else if(!String.isBlank(recName)){
                    if(recName.containsIgnoreCase('Apartment') && recName.containsIgnoreCase('Villas')) {
                        flag = false;
                    } else if(recName.containsIgnoreCase('Apartment')) {
                        othersFilterPropType = '(\'Villas\')';
                    } else if(recName.containsIgnoreCase('Villas')) {
                        othersFilterPropType = '(\'Apartment\')';
                    }
                }
                if(flag) {
                    query += ' AND (NOT (RecordType.Name IN ' + othersFilterPropType + '))';      
                }
            }
            if(flag && !String.isBlank(recName)) {
                recName = recName.removeEND(',');
                System.debug('===> recName ' + recName);
                recName = '(' + recName + ')';
                query += ' AND RecordType.Name IN ' + recName;      
            }
        }
        if(subProjects.size()>0) {
            String subName = '';
            for(String str : subProjects) {
                str = str.trim();
                subName += '\'' + str + '\',';
            }
            if(!String.isBlank(subName)) {
                subName = subName.removeEND(',');
                System.debug('===> subName ' + subName);
                subName = '(' + subName + ')';
                query += ' AND PropStrength__Project_Name__r.Name IN ' + subName;      
            }
        }
        if(config.size() > 0 && unitTypes.size() > 0) {
            unitTypes.addAll(config);
        } else if(config.size()>0) {
            unitTypes = new List<String>();
            unitTypes.addAll(config);
        }
        System.debug('===> unitTypes ' + unitTypes);
        if(unitTypes.size()>0) {
            String uName = '';
            for(String str : unitTypes) {
                str = str.trim();
                uName += '\'' + str + '\',';
            }
            if(!String.isBlank(uName)) {
                uName = uName.removeEND(',');
                System.debug('===> uName ' + uName);
                uName = '(' + uName + ')';
                query += ' AND PropStrength__Unit_Type__c IN ' + uName;      
            }
        }
        if(floors.size()>0) {
            String flName = '';
            for(String str : floors) {
                str = str.trim();
                flName += '' + str + ',';
            }
            if(!String.isBlank(flName)) {
                flName = flName.removeEND(',');
                System.debug('===> flName ' + flName);
                flName = '(' + flName + ')';
                query += ' AND PropStrength__Floor_Number__c IN ' + flName;
            }
        }
        if(unitNames.size()>0) {
            String unit_Name = '';
            for(String str : unitNames) {
                str = str.trim();
                unit_Name += '\'' + str + '\',';
            }
            if(!String.isBlank(unit_Name)) {
                unit_Name = unit_Name.removeEND(',');
                System.debug('===> unit_Name ' + unit_Name);
                unit_Name = '(' + unit_Name + ')';
                query += ' AND Name IN ' + unit_Name;      
            }
        }
        if(variants.size()>0) {
            String variName = '';
            for(String str : variants) {
                str = str.trim();
                variName += '\'' + str + '\',';
            }
            if(!String.isBlank(variName)) {
                variName = variName.removeEND(',');
                System.debug('===> variName ' + variName);
                variName = '(' + variName + ')';
                query += ' AND Variant__c IN ' + variName;
            }
        }
        query += ' ORDER BY CreatedDate DESC LIMIT 2499';
        System.debug('===> Query: ' + query);
        propertyList = Database.query(query);
        System.debug('===> propertyList: ' + propertyList);
        System.debug('===> propertyList Size : ' + propertyList.size());
        return propertyList;
    }

    @AuraEnabled
    public static List<Master_Project__c> getAllProjects() {
        return [SELECT Id, Name, Project_Code__c, Logo_URL__c, 
                    (SELECT Id, Name, Project_Image__c, 
                    PropStrength__Location__c, PropStrength__Description__c, 
                    X3D_Tour__c 
                    FROM Projects__r 
                    WHERE PropStrength__Active__c = true AND 
                        Hide_From_3rd_Party__c = false) 
                    FROM Master_Project__c 
                    WHERE Hide_From_3rd_Party__c = false ORDER BY CreatedDate DESC LIMIT 999];
        //return [select Id, Name, (select Id,Name,X3D_Tour__c from Clusters__r order by Name ASC) from Project__c order by Name ASC];
    }
    
    @AuraEnabled
    public static SubProjectDetails getSubProjectDetails(String subProjectId) {
        List<String> imgURLs = new List<String>();
        SubProjectDetails details = new SubProjectDetails();
        if(!String.isBlank(subProjectId)) {
            PropStrength__Projects__c subProj = [SELECT Id, MAHA_RERA_No__c, Name, X3D_Tour__c, PropStrength__Description__c, 
                                                    Project_Address__c, Project_Image__c, 
                                                    (SELECT Id, Name, Amenity_Name__c FROM Aminities__r) 
                                                    FROM PropStrength__Projects__c 
                                                    WHERE Id =: subProjectId AND 
                                                        PropStrength__Active__c = true];
            if(subProj != null) {
                details.name = subProj.Name;
                details.description = subProj.PropStrength__Description__c;
                details.location = subProj.Project_Address__c;
                List<Amenity__c> amenities = new List<Amenity__c>();
                Set<String> uniqueAmenities = new Set<String>();
                for(Amenity__c am : subProj.Aminities__r) {
                    if(!uniqueAmenities.contains(am.Amenity_Name__c)){
                        uniqueAmenities.add(am.Amenity_Name__c);
                        amenities.add(am);
                    }
                }
                details.amenities = amenities;
                details.projectImage = subProj.Project_Image__c;
                details.threeDTour = subProj.X3D_Tour__c;
                details.subProjectId = subProj.Id;
                details.reraNumber = subProj.MAHA_RERA_No__c;
            }
            Set<String> typoLogySet = new Set<String>();
            String typology = '';
            Integer i = 0;
            for(PropStrength__Property__c u : [SELECT Id, Name, PropStrength__Unit_Type__c, 
                                                PropStrength__Total_Sales_Consideration__c 
                                                FROM PropStrength__Property__c 
                                                WHERE PropStrength__Project_Name__c =: subProjectId AND 
                                                    PropStrength__Total_Sales_Consideration__c != null 
                                                    ORDER BY PropStrength__Total_Sales_Consideration__c ASC LIMIT 49999]) {
                if(!String.isBlank(u.PropStrength__Unit_Type__c) && 
                    !typoLogySet.contains(u.PropStrength__Unit_Type__c)) {
                    typology += u.PropStrength__Unit_Type__c + ' | ';
                    typoLogySet.add(u.PropStrength__Unit_Type__c);
                }
                if(i == 0) {
                    Decimal startPrice = u.PropStrength__Total_Sales_Consideration__c;
                    startPrice = startPrice / 1000000;
                    startPrice = startPrice.setScale(2);
                    details.startingPrice = string.valueOf(startPrice) + 'M AED';
                }
                i++;
            }
            typology = typology.removeEND('| ');
            details.typology = typology;
            for(ContentDistribution cd : [SELECT Id, ContentVersion.FileType, 
                                            ContentDownloadUrl,RelatedRecord.Name 
                                            FROM ContentDistribution 
                                            WHERE RelatedRecordId =: subProjectId AND 
                                                ContentVersion.Title LIKE 'Portal_%' 
                                                ORDER BY Createddate DESC]) {
                System.debug('===> cd ' + cd.ContentVersion.FileType);
                if(cd.ContentVersion.FileType == 'JPEG' || 
                    cd.ContentVersion.FileType == 'JPG' || 
                    cd.ContentVersion.FileType == 'GIF' || 
                    cd.ContentVersion.FileType == 'PNG' || 
                    cd.ContentVersion.FileType == 'SVG') {
                    imgURLs.add(cd.ContentDownloadUrl);
                }
            }
            details.imageURLs = imgURLs;
        }
        return details;
    }
    
    public class SubProjectDetails {
        @AuraEnabled public String subProjectId;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String threeDTour;
        @AuraEnabled public String typology;
        @AuraEnabled public String startingPrice;
        @AuraEnabled public String location;
        @AuraEnabled public String projectImage;
        @AuraEnabled public List<Amenity__c> amenities;
        @AuraEnabled public List<String> imageURLs;
        @AuraEnabled public String reraNumber;
    }
    
    @AuraEnabled
    public static string createQuotation(String unitId, String customerName, String customerEmail) {
        System.debug(unitId);
        System.debug(customerName);
        System.debug(customerEmail);
        List<Quote__c> quoteList = new List<Quote__c>();
        String quoteURL = '';
        try {
            if(!String.isEmpty(unitId)) {
                //PropStrength__Property__c
                quoteList = [SELECT Id, Name, Customer_Name__c, Customer_Email__c, Quote_Validity__c,CreatedDate  FROM Quote__c WHERE Property__c =: unitId ORDER BY CreatedDate DESC LIMIT 1];
            }
            if(!quoteList.isEmpty()) {
                Quote__c q = new Quote__c();
                q.Id = quoteList[0].Id;
                q.Customer_Name__c = customerName;
                q.Customer_Email__c = customerEmail;
                q.Quote_Validity__c = quoteList[0].CreatedDate.Date().addMonths(2);
                update q;
                quoteURL = 'Success++';
                quoteURL += 'apex/ViewCostsheetMultiUnitClone?qId=' + q.Id;
            }
            else {
                System.debug(unitId);
                List<PropStrength__Property__c> propList = [SELECT Id, PropStrength__Tower__c,Name, PropStrength__Super_Area__c, PropStrength__Tower__r.PropStrength__Tower_Name__c,PropStrength__Project_Name__c, PropStrength__Total_Sales_Consideration__c,
                                                        RecordType.Name, 
                                                        (SELECT Id, PropStrength__Fixed_Charge__c, PropStrength__Other_Charges_Code_Name__c, PropStrength__Rate_per_unit_Area__c, PropStrength__Type__c FROM PropStrength__Property_Charges__r)
                                                        FROM PropStrength__Property__c WHERE Id =: unitId];
                List<PropStrength__Income_Charges__c> incomeChargesList = new List<PropStrength__Income_Charges__c>();
                List<incomeChageDetails> incomeChargeList = new List<incomeChageDetails>();
                
                if(!propList.isEmpty()) {
                    if(propList[0].PropStrength__Tower__c != null) {
                        System.debug(propList[0].PropStrength__Tower__c);
                        String towerId = propList[0].PropStrength__Tower__c;
                        List<PropStrength__Payment_Plan__c> ppList = [SELECT Id, PropStrength__Tower__c FROM PropStrength__Payment_Plan__c WHERE PropStrength__Tower__c =: towerId ORDER BY CreatedDate DESC LIMIT 1];
                        if(ppList.isEmpty()) {
                            quoteURL = 'Error++';
                            quoteURL += 'Please Maintain Standard Payment Plan On Tower : '+propList[0].PropStrength__Tower__r.PropStrength__Tower_Name__c;
                            return quoteURL;
                        } 
                        incomeChargesList = InventoryCostServicesMultiUnitClone.getIncomeChargeList(propList[0].PropStrength__Project_Name__c);
                        Decimal dLdOriginalPrice = 0.0; 
                        Decimal totalPurchaseOrginalPrice = 0.0;
                        totalPurchaseOrginalPrice = propList[0].PropStrength__Total_Sales_Consideration__c;
                        Map<String, Decimal> chargeMap = new Map<String, Decimal>();
                        for(PropStrength__Property_Charges__c ppCharge : propList[0].PropStrength__Property_Charges__r) {
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
                                Decimal amt = ppCharge.PropStrength__Rate_per_unit_Area__c * propList[0].PropStrength__Super_Area__c;
                                chargeMap.put(ppCharge.PropStrength__Other_Charges_Code_Name__c, chargeMap.get(ppCharge.PropStrength__Other_Charges_Code_Name__c) + amt);
                            }
                        } 
                        for(String chargeName : chargeMap.keySet()) {
                            totalPurchaseOrginalPrice += chargeMap.get(chargeName);
                        }
                        if(!incomeChargesList.isEmpty()) {
                            for(PropStrength__Income_Charges__c rec : incomeChargesList) {
                                if(rec.PropStrength__Category__c.contains('DLD Fees')) {
                                    dLdOriginalPrice = totalPurchaseOrginalPrice * rec.Charge__c / 100;
                                }
                                else {
                                    Decimal amt =  rec.PropStrength__Amount__c;
                                    Decimal tx =  propList[0].RecordType.Name != 'Commercial - Units' ? 0.0 : rec.PropStrength__Service_Tax__c/100;
                                    if(rec.PropStrength__Type__c == 'Fixed') {
                                        incomeChargeList.add(new incomeChageDetails(rec.Name, amt , tx * amt));
                                    }
                                    if(rec.PropStrength__Type__c == 'Flexible') {
                                        amt *= propList[0].PropStrength__Super_Area__c;
                                        incomeChargeList.add(new incomeChageDetails(rec.Name, amt, tx * amt));
                                    }                                
                                }
                            }
                        }
                        Quote__c q = new Quote__c();
                        q.Property__c = propList[0].Id;
                        q.Quote_for_Multi_Properties__c = false;
                        q.Payment_Plan__c = ppList[0].Id;
                        q.Basic_Sale_Price_Original__c =  propList[0].PropStrength__Total_Sales_Consideration__c > 0 ? propList[0].PropStrength__Total_Sales_Consideration__c : null;
                        q.Basic_Sale_Price_Modified__c = propList[0].PropStrength__Total_Sales_Consideration__c > 0 ? propList[0].PropStrength__Total_Sales_Consideration__c : null;
                        q.DLD_Fees_Original__c = dLdOriginalPrice > 0 ? dLdOriginalPrice : null;
                        q.DLD_Fees_Modified__c = dLdOriginalPrice > 0 ? dLdOriginalPrice : null;
                        q.From_Broker_Portal__c = true;
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
                        q.Customer_Name__c = customerName;
                        q.Customer_Email__c = customerEmail;
                        q.Quote_Validity__c = System.today().addMonths(2);
                        insert q;
                        quoteURL = 'Success++';
                        quoteURL += 'apex/ViewCostsheetMultiUnitClone?qId=' + q.Id;
                    }
                    else {
                        quoteURL = 'Error++';
                        quoteURL += 'Please Maintain Tower On Poperty: '+propList[0].Name;
                        return quoteURL;
                    }
                    
                }
            }
        } catch(Exception e) {
            System.debug('===> Exception ' + e.getMessage());
        }
        return quoteURL;
        /*Quotation__c q = new Quotation__c();
        Unit__c u = [select Id,Tower__c,Project__r.Name,Tower__r.Id,Tower__r.Level_1_Approver__c,Tower__r.Level_2_Approver__c from Unit__c where Id=:unitId];
        Payment_Plan__c pp = [select Id from Payment_Plan__c where Tower__c=:u.Tower__c and Is_Active__c=true limit 1];
        Map<String, Decimal> rateListMap = new Map<String, Decimal>();
        rateListMap = InventoryCostServices.getRateList(unitId);
        Map<String, Decimal> allChargesMap = InventoryCostServices.getAllChargesNew(unitId,0,0,0,rateListMap);
        q.Payment_Plan__c = pp.Id;  
        q.Unit__c = unitId;
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
        
        q.put('Charge'+ (pcSeqMap.size() + 1) +'Name__c' ,'Car Parking Charges');
        q.put('Charge'+ (pcSeqMap.size() + 1) + 'Value__c' ,allChargesMap.get('Car Parking Charges'));
        q.put('Charge'+ (pcSeqMap.size() + 1) +'Bucket__c' ,'Agreement Value');
        if(allChargesMap.containsKey('Car Parking Charges SGST'))
            q.put('Charge'+ (pcSeqMap.size() + 1) +'SGST__c' ,allChargesMap.get('Car Parking Charges SGST'));
        if(allChargesMap.containsKey('Car Parking Charges CGST'))
            q.put('Charge'+ (pcSeqMap.size() + 1) +'CGST__c' ,allChargesMap.get('Car Parking Charges CGST'));
        if(allChargesMap.containsKey('EARMARKED CARPARK CHARGES')){
            q.Earmarked_Total_Amount__c = allChargesMap.get('EARMARKED CARPARK CHARGES');
        }
        if(allChargesMap.containsKey('ADDITIONAL CARPARK CHARGES')){
            q.Additional_CarPark_Amount__c = allChargesMap.get('ADDITIONAL CARPARK CHARGES');
        }
        decimal totalDiscount = 0;
        decimal discountedRateCard = 0;
        q.Approval_Required__c = false; 
        if(u.Tower__r.Level_1_Approver__c != null)
            q.Level_One_Approver__c = u.Tower__r.Level_1_Approver__c;
        if(u.Tower__r.Level_2_Approver__c != null)
            q.Level_Two_Approver__c = u.Tower__r.Level_2_Approver__c; 
        if(q.Approval_Required__c){
            q.Quote_Status__c = 'Approval Pending';
        } else {
            q.Quote_Status__c = 'Valid';
            q.Final_Approved_Date__c = system.today();
        }
        q.Token_Amount__c = allChargesMap.get('TOKEN AMOUNT');
        q.ST_Token_Amount__c = allChargesMap.get('TOKEN AMOUNT TAX');
        q.Allow_booking_without_full_token__c = true;
        insert q;
        List<InventoryCostServices.PlanDetailWrapper> payplanDetails = InventoryCostServices.getPlanDetailsNew(unitId, pp.Id, allChargesMap);
        InventoryCostServices.insertCustomerPaymentPlan(payplanDetails, pp.Id,null,null, null,q,allChargesMap);
        return q.Id;*/
    }
    
    @AuraEnabled
    public static Data_Download_Tracker__c  createExportTracker(String projectid, String userid, string filterStr) {
        Data_Download_Tracker__c ddt = New Data_Download_Tracker__c();
        ddt.Downloaded_By__c = userid;
        ddt.Downloaded_Project__c = projectid;
        ddt.Filter_Criteria__c = filterStr;
        insert ddt;
        return ddt;
    }  
    
    //@AuraEnabled(cacheable=true)
    //public static Map<ID, String> getRelatedFiles(String filename) {
    // Get record file IDs        
    // List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
    //  List<ID> fileIDs = new List<ID>();
    //  for (ContentDocumentLink docLink : files) {
    //     fileIDs.add(docLink.ContentDocumentId);
    //  }
    @AuraEnabled
    public static String getRelatedFiles(String filename, String projectid) {
        System.debug('===> project Name ' + filename);
        System.debug('===> projectid ' + projectid);
        //List<ContentDocument> files = [Select Id, LatestPublishedVersionId from ContentDocument where Title='360 Riverside Crescent'];
        /*if(filename.startsWith('Brochure')) {
            filename = 'Brochure%';
        } else if(filename.startsWith('Collateral')) {
            filename = 'Collateral%';
        }*/
        List<ContentDistribution> docList = new List<ContentDistribution>();
        if(!String.isBlank(projectid) && !String.isBlank(filename)) {
            docList = [SELECT Id, ContentDocumentId, 
                                ContentDownloadUrl 
                                FROM ContentDistribution 
                                WHERE RelatedRecordId != null AND 
                                    RelatedRecordId =: projectid AND 
                                    ContentVersion.Title LIKE: filename 
                                    ORDER BY CreatedDate DESC LIMIT 1];
        }
        System.debug('===> docList ' + docList);
        if(docList.size()>0) {
            //return URL.getOrgDomainURL().toExternalForm()+'/sfc/servlet.shepherd/document/download/'+ docList[0].ContentDocumentId;
            return docList[0].ContentDownloadUrl;
        } else {
            return '';
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