public without sharing class BrokerPortalSobhaProjectsController {
    @AuraEnabled
    public static list<Unit__c> getUnits(list<string> projectId, list<string> config, 
    list<string> area, list<string> price, list<string> propertyType, list<string> subProjects, 
    list<string> unitTypes, list<string> floors, list<string> unitNames, list<string> variants, list<string> areas, list<string> prices){
        list<Unit__c> unitList = new list<Unit__c>();
        string query = 'select Id,Name,Project__r.Name,Tower__r.Project__r.Name,Unit_Type__c,Unit_Type_Variant__c,Tower__r.Cluster__r.Name,'+
        'Floor_No_to_print__c,Total_Area__c,Puchase_Price__c from Unit__c where Unit_Status__c=\'Available\' AND Project__r.Hide_From_3rd_Party__c != true AND For_Direct_Sale__c = false AND Tower__r.Cluster__c != null AND Tower__r.Project__c != null';
        if(projectId.size()>0){
            query+=' AND Project__r.Name IN : projectId';
        }
        if(config.size()>0){
            query+=' AND Configuration__c IN : config';
        }

        if(area.size()>0 && areas.size()>0){
            areas.addAll(area);
        }
        else if(area.size()>0){
            areas.addAll(area);
        }
        
        if(price.size()>0 && prices.size()>0){
            prices.addAll(price);
        }
        else if(price.size()>0){
            prices.addAll(price);
        }
        
        if(prices.size()>0){
            string tempPriceStr='';
            for(string pr : prices){
                if(pr.contains('+')){
                    list<string> priceList = pr.split('+');
                    double priceVal = double.valueOf(priceList[0]);
                    priceVal = priceVal*1000000;
                    tempPriceStr+=' (Puchase_Price__c > '+ priceVal + ') OR';
                }
                else{
                    list<string> priceList = pr.split(' ');
                    if(priceList.size()>5){
                        double fromPrice = double.valueOf(priceList[1]);
                        fromPrice = fromPrice*1000000;
                        double toPrice = double.valueOf(priceList[5]);
                        toPrice = toPrice*1000000;
                        tempPriceStr+=' (Puchase_Price__c >= ' + fromPrice + ' AND Puchase_Price__c <= ' + toPrice + ') OR';
                    }
                }
            }
            if(tempPriceStr!=''){
                tempPriceStr = tempPriceStr.removeEnd('OR');
                tempPriceStr = ' AND ('+tempPriceStr+') ';
                query+= tempPriceStr;
            }
        }

        if(areas.size()>0){
            string tempStr='';
            for(string ar : areas){
                if(ar.contains('+')){
                    list<string> areaList = ar.split('+');
                    double areaVal = double.valueOf(areaList[0]);
                    tempStr+=' (Total_Area__c > '+ areaVal + ') OR';
                }
                else{
                    list<string> areaList = ar.split(' ');
                    if(areaList.size()>2){
                        double fromArea = double.valueOf(areaList[0]);
                        double toArea = double.valueOf(areaList[2]);
                        tempStr+=' (Total_Area__c >= '+ fromArea +' AND Total_Area__c <= '+ toArea + ') OR';
                    }
                }
            }
            if(tempStr!=''){
                tempStr = tempStr.removeEnd('OR');
                tempStr = ' AND ('+tempStr+') ';
                query+= tempStr;
            }
        }

        /*if(area!=''){
            if(area.contains('+')){
                list<string> areaList = area.split('+');
                double areaVal = double.valueOf(areaList[0]);
                query+=' AND Total_Area__c >: areaVal';
            }
            else{
                list<string> areaList = area.split(' ');
                if(areaList.size()>2){
                    double fromArea = double.valueOf(areaList[0]);
                    double toArea = double.valueOf(areaList[2]);
                    query+=' AND Total_Area__c >=: fromArea AND Total_Area__c <=: toArea';
                }
            }
        }*/
        
        /*if(price!='' && price!='None'){
            if(price.contains('+')){
                list<string> priceList = price.split('+');
                double priceVal = double.valueOf(priceList[0]);
                priceVal = priceVal*1000000;
                query+=' AND Puchase_Price__c >: priceVal';
            }
            else{
                list<string> priceList = price.split(' ');
                if(priceList.size()>5){
                    double fromPrice = double.valueOf(priceList[1]);
                    fromPrice = fromPrice*1000000;
                    double toPrice = double.valueOf(priceList[5]);
                    toPrice = toPrice*1000000;
                    query+=' AND Puchase_Price__c >=: fromPrice AND Puchase_Price__c <=: toPrice';
                }
            }
        }*/
        
        if(propertyType.size()>0){
            query+=' AND Tower__r.Tower_Type__c IN : propertyType';
            /*if(propertyType=='Apartments' || propertyType=='Villas'){
                query+=' AND Tower__r.Tower_Type__c =: propertyType';
            }
            else{
                query+=' AND Tower__r.Tower_Type__c != \'Apartments\' AND Tower__r.Tower_Type__c != \'Villas\'';
            }*/
        }
        if(subProjects.size()>0){ query+=' AND Tower__r.Cluster__r.Name IN: subProjects';}
        if(unitTypes.size()>0){ query+=' AND Unit_Type__c IN: unitTypes';}
        if(floors.size()>0){ query+=' AND Floor_No_to_print__c IN: floors';}
        if(unitNames.size()>0){ query+=' AND Name IN: unitNames'; }
        if(variants.size()>0){ query+=' AND Unit_Type_Variant__c IN: variants';}
        system.debug('Query: '+query);
        unitList=Database.query(query);
        return unitList;
    }

    @AuraEnabled
    public static list<Project__c> getAllProjects(){
        return [select Id, Name, (select Id,Name,X3D_Tour__c from Clusters__r where Hide_From_3rd_Party__c != true order by Name ASC) from Project__c where Hide_From_3rd_Party__c != true order by Name ASC];
    }
    
    @AuraEnabled
    public static SubProjectDetails getSubProjectDetails(string subProjectId){
        system.debug('subProjectId:::'+subProjectId);
        SubProjectDetails details = new SubProjectDetails();
        Cluster__c subProj = [select Id,MAHA_RERA_No__c,Name,X3D_Tour__c,Description__c,Project__r.Address__c,Project__r.Project_Image__c,IsHighResolutionRequired__c,(select Id,Name,Amenity_Name__c from Aminities__r) from Cluster__c where Id=:subProjectId];
        details.name=subProj.Name;
        details.description=subProj.Description__c;
        details.location=subProj.Project__r.Address__c;
        list<Amenity__c> amenities = new list<Amenity__c>();
        set<string> uniqueAmenities = new set<string>();
        for(Amenity__c am : subProj.Aminities__r){
            if(!uniqueAmenities.contains(am.Amenity_Name__c)){
                uniqueAmenities.add(am.Amenity_Name__c);
            	amenities.add(am);
            }
        }
        details.amenities=amenities;
        details.projectImage = subProj.Project__r.Project_Image__c;
        details.threeDTour = subProj.X3D_Tour__c;
        details.subProjectId = subProj.Id;
        details.reraNumber = subProj.MAHA_RERA_No__c;
        string typology='';
        list<string> topologies = new list<string>();
        for(AggregateResult u : [select count(id),Configuration__c from unit__c where Tower__r.Cluster__c =: subProjectId group by Configuration__c]){
            topologies.add(string.valueOf(u.get('Configuration__c')));
            //typology+= u.get('Configuration__c') + ' | ';
        }
        topologies.sort();
        for(string t : topologies){
            typology+= t + ' | ';
        }
        typology=typology.removeEND('| ');
        details.typology=typology;
        list<Unit__c> units = [select Puchase_Price__c from unit__c where Puchase_Price__c!= null and Tower__r.Cluster__c =: subProjectId order by Puchase_Price__c asc limit 1];
        if(units.size()>0){
            decimal pp = units[0].Puchase_Price__c;
            pp = pp / 1000000;
            pp = pp.setScale(1);
            details.startingPrice = string.valueOf(pp)+'M AED';
        }
        
        List<string> imgURLs = new List<string>();
        List<string> hiImageURLs = new List<string>();
        if(subProj.IsHighResolutionRequired__c){
        // Retrieve Portal_Images__c records for the subproject and their ContentDistributions.
        List<Portal_Images__c> portalImages = [
            SELECT Id, Name, CreatedDate
            FROM Portal_Images__c
            WHERE Sub_Project__c = :subProjectId
            ORDER BY CreatedDate desc
        ];
        
        System.debug('portalImages::::'+portalImages);
        
        // Query the ContentDistributions for the low and high-resolution images, maintaining order.
        Map<Id, String> contentDownloadUrlMap = new Map<Id, String>();
        
        List<ContentDistribution> contentDistributions = [
            SELECT Id, ContentVersion.FileType, ContentDownloadUrl, RelatedRecordId, ContentVersion.Title
            FROM ContentDistribution
            WHERE RelatedRecordId IN :portalImages
            ORDER BY CreatedDate desc
        ];
        System.debug('contentDistributions::::'+contentDistributions);
        
        // Step 3: Iterate through the ContentDistributions and categorize the images.
        Map<Id, String> portalImageToLowResMap = new Map<Id, String>();
        Map<Id, String> portalImageToHighResMap = new Map<Id, String>();
        
        for (ContentDistribution cd : contentDistributions) {
            // Check the title to determine if it's low-res or high-res.
            if (cd.ContentVersion.Title.startsWith('Portal_')) {
                portalImageToLowResMap.put(cd.RelatedRecordId, cd.ContentDownloadUrl);
            } else if (cd.ContentVersion.Title.startsWith('High_')) {
                portalImageToHighResMap.put(cd.RelatedRecordId, cd.ContentDownloadUrl);
            }
        }
        
        // Step 4: Maintain the order of Portal_Images__c records.
        for (Portal_Images__c portalImage : portalImages) {
            if (portalImageToLowResMap.containsKey(portalImage.Id)) {
                imgURLs.add(portalImageToLowResMap.get(portalImage.Id));
            }
            if (portalImageToHighResMap.containsKey(portalImage.Id)) {
                hiImageURLs.add(portalImageToHighResMap.get(portalImage.Id));
            }
        }
        }else{
        for(ContentDistribution cd : [SELECT Id,ContentVersion.FileType,ContentDownloadUrl,RelatedRecord.Name 
                                      from ContentDistribution 
                                      where RelatedRecordId=:subProjectId and ContentVersion.Title like 'Portal_%' order by createddate desc]){
                                          if(cd.ContentVersion.FileType=='JPG' || cd.ContentVersion.FileType=='JPEG' || cd.ContentVersion.FileType=='GIF' || cd.ContentVersion.FileType=='PNG' || cd.ContentVersion.FileType=='SVG'){
                                              imgURLs.add(cd.ContentDownloadUrl);
                                              hiImageURLs.add(cd.ContentDownloadUrl);
                                          }
                                      }
        }
        details.imageURLs = imgURLs;
        System.debug('imageURLs:::'+imgURLs);
        details.hiImageURLs = hiImageURLs;
        System.debug('hiImageURLs::::'+hiImageURLs);
        return details;
    }
    
    public class SubProjectDetails {
        @AuraEnabled public string subProjectId;
        @AuraEnabled public string name;
        @AuraEnabled public string description;
        @AuraEnabled public string threeDTour;
        @AuraEnabled public string typology;
        @AuraEnabled public string startingPrice;
        @AuraEnabled public string location;
        @AuraEnabled public string projectImage;
        @AuraEnabled public list<Amenity__c> amenities;
        @AuraEnabled public list<string> imageURLs;
        @AuraEnabled public list<string> hiImageURLs;
        @AuraEnabled public string reraNumber;
    }
    
    @AuraEnabled
    public static string createQuotation(string unitId, string customerName, string customerEmail){
        try{
            Quotation__c q = new Quotation__c();
            q.Customer_Name__c=customerName;
            q.Customer_Email__c=customerEmail;
            q.From_Broker_Portal__c=true;
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
            Id currentUserId = UserInfo.getUserId();
            Quotation__c quote = [SELECT Id,name From Quotation__c WHERE Id=:q.Id];
            String FilterCriteria = 'Downloaded Quotation:'+quote.Name;
            createDataDownloadTracker('',FilterCriteria);
            List<InventoryCostServices.PlanDetailWrapper> payplanDetails = InventoryCostServices.getPlanDetailsNew(unitId, pp.Id, allChargesMap);
            InventoryCostServices.insertCustomerPaymentPlan(payplanDetails, pp.Id,null,null, null,q,allChargesMap);
            return q.Id;
        }
        catch(Exception e){
            system.debug('Exception: '+e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static Data_Download_Tracker__c  createExportTracker(String projectid, String userid, string filterStr){
        Data_Download_Tracker__c ddt = New Data_Download_Tracker__c();
        ddt.Downloaded_By__c=userid;
        ddt.Downloaded_Project__c=projectid;
        ddt.Filter_Criteria__c=filterStr;
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
    public static string getRelatedFiles(String filename, String projectid) {
        try{
            /*system.debug('project Name:'+filename);
            list<Id> ids = new List<Id>();
            //List<ContentDocument> files = [Select Id, LatestPublishedVersionId from ContentDocument where Title='360 Riverside Crescent'];
            List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId =:projectid and ContentDocument.title = :filename order by ContentDocument.CreatedDate desc limit 1]; 
            if(docList.size()>0)
                return URL.getOrgDomainURL().toExternalForm()+'/sfc/servlet.shepherd/document/download/'+ docList[0].ContentDocumentId;
            else
                return null;*/
            List<ContentDistribution> disList = [select Id,ContentDownloadUrl from ContentDistribution
                            where RelatedRecordId =: projectid AND 
                            ContentVersion.Title =: filename 
                            order by CreatedDate desc limit 1];

            if(disList.size()>0){
                createDataDownloadTracker(projectid,filename);
                return disList[0].ContentDownloadUrl;
                }
            else
                return null;
        }catch(Exception e){
            system.debug('Exception: '+e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static String createDataDownloadTracker(String projectId, String filterCriteria) {
        
        try {
            
            // Create a new Data_Download_Tracker__c record.
            Data_Download_Tracker__c tracker = new Data_Download_Tracker__c();
            tracker.Downloaded_By__c = UserInfo.getUserId();
            System.debug('Inside createDataDownloadTracker');
            If(projectId !=''){
                Cluster__c SP=[SELECT id,Project__c From Cluster__c Where ID=:projectId];
                tracker.Downloaded_Project__c = SP.Project__c;
            }
            tracker.Filter_Criteria__c = filterCriteria;
            INSERT tracker;
            return tracker.Id;
        } catch (Exception e) {
            Error_Log__c logError = new Error_Log__c(Message__c = e.getMessage());
            logError.class__c = 'BrokerPortalSobhaProjectsController';
            insert logError;
            System.debug('Exception:::::'+e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    
    
    @AuraEnabled
    public static void updateDataDownloadTracker(Id downloadTrackerId, String filterCriteria) {
        try {
            // Fetch the existing Data_Download_Tracker__c record by ID
            System.debug('Inside updateDataDownloadTracker');
            Data_Download_Tracker__c tracker = [SELECT Id FROM Data_Download_Tracker__c WHERE Id = :downloadTrackerId LIMIT 1];
            // Update the Filter_Criteria__c field with the new criteria
            tracker.Filter_Criteria__c = filterCriteria;
            // Update the record in the database
            UPDATE tracker;
        } catch (Exception e) {
            Error_Log__c logError = new Error_Log__c(Message__c = e.getMessage());
            logError.class__c = 'BrokerPortalSobhaProjectsController';
            insert logError;
            System.debug('Error updating Data_Download_Tracker__c: ' + e.getMessage());
            throw new AuraHandledException('Unable to update the filter criteria: ' + e.getMessage());
        }
    }

  }