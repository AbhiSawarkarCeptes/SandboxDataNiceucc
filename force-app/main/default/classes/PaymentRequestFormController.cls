public without sharing class PaymentRequestFormController {
    
    public static boolean PaymentRequestTriggerFirstRunFlag = true;
    
    @InvocableMethod (label='Update Unit')
    public static void updateUnit (List<Id> prList){
        Payment_Request__c pr = [select Id, Unit__c from Payment_Request__c where Id =: prList[0]];
        list<Unit__c> uList = [select Id from Unit__c where Id =: pr.Unit__c and Unit_Status__c = 'Available'];
        if(uList.size() > 0){
            Unit__c u = new Unit__c();
            u.Id = pr.Unit__c;
            u.Unit_Status__c = 'Hold';
            update u;   
        }
    }
    
    @AuraEnabled
    public static UnitDetailsWrapper unitDetails(string unitId){
        UnitDetailsWrapper wrapObj = new UnitDetailsWrapper();
        Unit__c u = [select Id, Sub_Project_Tower__c,Project__c,Project__r.Name,Tower__c,Tower__r.ESCROW_Account__c,Tower__r.ESCROW_Account__r.Name,For_Direct_Sale__c from Unit__c where Id =: unitId];
        if(u.Tower__c!=null && u.Tower__r.ESCROW_Account__c != null){
            wrapObj.unitkey = u.Project__r.Name+'-'+u.Sub_Project_Tower__c+'@@'+u.Tower__r.ESCROW_Account__r.Name;
        }
        else{
            wrapObj.unitkey = u.Project__r.Name+'-'+u.Sub_Project_Tower__c+'@@ESCROW Account not mapped, Please select Corporate Account.';
        }
        wrapObj.onDirectSale = u.For_Direct_Sale__c;
        List<Payment_Request__c> approvedPr = [SELECT ID,Lead_Source_Category__c,Lead_Source_Sub_Category__c FROM Payment_Request__c where status__c = 'Approved' and unit__c =: unitId  order by createddate desc limit 1];
        if(approvedPr.size() > 0)
        wrapObj.approvedPR = approvedPr[0];
        return wrapObj;
    }
    
    @AuraEnabled
    public static Booking__c getUnitId(string bookingId){
        //sob-1140
        Booking__c b = [select Id, Unit__c,Unit__r.For_Direct_Sale__c, Unit__r.Tower__c,Unit__r.Tower__r.ESCROW_Account__c,Unit__r.Tower__r.ESCROW_Account__r.Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, PrimaryMobileNumber__c  from Booking__c where Id =: bookingId];
        list<Applicant_Details__c> adList = [select id, Applicant_Number__c, Passport_Copy_Details__c, Emirates_ID_Details__c from Applicant_Details__c where Applicant_Number__c = 'Primary Applicant' and Booking__c =: bookingId];
        if(adList.size()>0)
            b.Applicant_2_Name__c = (adList[0].Passport_Copy_Details__c != null)?adList[0].Passport_Copy_Details__c:(adList[0].Emirates_ID_Details__c != null)?adList[0].Emirates_ID_Details__c:'';
        else
            b.Applicant_2_Name__c = '';
        return b;
    }

    
    @AuraEnabled
    public static void updateUploadedFileName(string fileName, string docId){
        ContentDocument cd = [select id,title from ContentDocument where Id=:docId];
        cd.Title = fileName;
        update cd;
    }
    
    @AuraEnabled
    public static Payment_Request__c getPaymentRequestDetails(string prId){
        List<Payment_Request__c> prs = [select Id,Payment_Request__c,Payment_Request__r.Status__c,Unit__r.Tower__c,Unit__r.Tower__r.ESCROW_Account__c,Unit__r.Tower__r.ESCROW_Account__r.Name,Account_Type__c,Account_Master__c,Lead_Source_Category__c, Lead_Source_Sub_Category__c, Mode__c, Name__c, Unit__c, Email__c, Emirates_Id_Passport_Number__c, Mobile_Number__c,Unit__r.For_Direct_Sale__c from Payment_Request__c where Id =: prId];
        
        if(prs.isEmpty()) throw new AuraHandledException('Primary PR not found. Please contact admin.');
        
        if(Feature_Flag__mdt.getAll().containsKey('AddSecondaryModePreventionMessage') && Feature_Flag__mdt.getInstance('AddSecondaryModePreventionMessage').Active__c){
            for(Payment_Request__c pr : prs){
                if(pr.Payment_Request__c != NULL && String.isNotBlank(pr.Payment_Request__r.Status__c) && !pr.Payment_Request__r.Status__c.containsIgnoreCase('reject')){
                    //throw new AuraHandledException('This isn\'t the primary PR and the primary PR is accepted, can\'t create another secondary PR.');
                    throw new AuraHandledException(Label.get(null, 'AddSecondaryModePreventionMessage'));
                }
            }
        }
        
        return prs[0];
    }
    
    @AuraEnabled
    public static map<string,decimal> getCurrencyRate(){
        map<string,decimal> currToRate = new map<string,decimal>();
        for(Currency_Rate__mdt currRate : [select MasterLabel, Rate__c from Currency_Rate__mdt]){
            currToRate.put(currRate.MasterLabel,currRate.Rate__c);
        }
        return currToRate;
    }
    
    @AuraEnabled
    public static string createPaymentRequest(string name,string email,string mobile,string passportNumber,
    string mode,string curr,string instrumentNumber,string chequeNo,string chequeDate,
    string accountNo,string amount,string dateOfInitiation,string countryOfInitiation,integer uploadedFileLength,
    list<string> units,string bookingId,string modeOption,string secondaryMode,string instrumentDate, 
    string referenceNo,String is3rdParty, string amountTowards, string amountTowardsUnit, 
    string amountTowardsPreReg, string amountTowardsOther, string others, string prId, String popComments, 
    boolean isCorporate,boolean isThirdParty, string category,
    string mortageValue){ 
        
        Savepoint sp = Database.setSavepoint();
        
       /* boolean is3rdPartyCheque = Boolean.ValueOf(is3rdParty.split('###')[0]);
        boolean is3rdpartyIWT = Boolean.valueOf(is3rdParty.split('###')[2]);
        boolean is3rdpartyCDMCheque = Boolean.valueOf(is3rdParty.split('###')[1]);*/

        boolean isFromBooking = (bookingId == 'undefined' || bookingId == null || bookingId == '') ? false:true;
        User currentUser = [select Id, ManagerId, Manager.ManagerId from User where Id =: UserInfo.getUserId()];
        
        map<string,decimal> currToRate = new map<string,decimal>();
        for(Currency_Rate__mdt currRate : [select MasterLabel, Rate__c from Currency_Rate__mdt]){
            currToRate.put(currRate.MasterLabel,currRate.Rate__c);
        }
        
        list<string> unitIdsTemp = new list<string>();                                          
        
        
        for(string uId : units){
            string untId = uId.split('##')[0];
            unitIdsTemp.add(untId);
        }
        
        try{
            list<string> blacklistedAccount=new list<string>();
            if(passportNumber!=null && passportNumber!=''){
                for(Applicant_Details__c ad : [select Id,Account__c from Applicant_Details__c where 
                                               (Passport_Copy_Details__c =: passportNumber OR Emirates_ID_Details__c =: passportNumber) AND 
                                               Account__c != null])
                {
                    blacklistedAccount.add(ad.Account__c);
                }
                for(Opportunity op : [select Id,AccountId from Opportunity where 
                                      AccountId!=null AND Passport_No__c =: passportNumber])
                {
                    blacklistedAccount.add(op.AccountId);
                }
            }
            
            list<Blacklisted_Customer__c> blacklistedCustomer = [select Id,Unit__r.Name,Unit__c,From_Date__c,To_Date__c from Blacklisted_Customer__c where
                                                                 (Name =: name 
                                                                  OR Account__r.Name =: name OR 
                                                                  Account__r.PersonEmail =: email OR
                                                                  Account__r.PersonMobilePhone =: mobile OR
                                                                  Account__r.Phone =: mobile OR 
                                                                  (Account__c != null AND Account__c IN: blacklistedAccount)) 
                                                                 AND Blacklisted__c = true ORDER BY CreatedDate Desc];
            if(blacklistedCustomer.size()>0 && !isFromBooking){
                string blacklistedCustomerUnitId='';
                if(blacklistedCustomer[0].Unit__c!=null)
                    blacklistedCustomerUnitId = blacklistedCustomer[0].Unit__c;
                if(blacklistedCustomerUnitId=='' || unitIdsTemp.contains(blacklistedCustomerUnitId)){
                    if(blacklistedCustomer[0].From_Date__c != null && blacklistedCustomer[0].To_Date__c != null && blacklistedCustomer[0].From_Date__c <= system.today() && blacklistedCustomer[0].To_Date__c >= system.today())
                        return 'Due to System restriction please contact SalesOps SPOC to assist.';
                    else if(blacklistedCustomer[0].From_Date__c != null && blacklistedCustomer[0].To_Date__c == null && blacklistedCustomer[0].From_Date__c <= system.today())
                        return 'Due to System restriction please contact SalesOps SPOC to assist.';
                    else if(blacklistedCustomer[0].From_Date__c == null && blacklistedCustomer[0].To_Date__c == null)
                        return 'Due to System restriction please contact SalesOps SPOC to assist.';
                }
            }
        }
        catch(Exception e){
            insertErrorLog(e.getMessage(),e.getStackTraceString(),name,'PaymentRequestFormController','createPaymentRequest');
        }

        map<string,string> accountNameToAccountId = new map<string,string>();
        map<string,Unit__c> unitIdToUnitObj = new map<string,Unit__c>();
        for(Unit__c u : [select Id, Name, Puchase_Price__c, Tower__c, Tower__r.ESCROW_Account__c, Tower__r.ESCROW_Account__r.Name from Unit__c where Id IN: unitIdsTemp]){
            unitIdToUnitObj.put(u.Id, u);
            if(u.Tower__c!=null && u.Tower__r.ESCROW_Account__c != null){
                accountNameToAccountId.put(u.Tower__r.ESCROW_Account__r.Name,u.Tower__r.ESCROW_Account__c);
            }
        }
        
        if((others == 'Resale NOC (Title Deed)' || others == 'Resale – NOC (Title Deed)')&& Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Resale_NOC_Title_Deed)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Resale_NOC_Title_Deed+' for Resale NOC (Title Deed)';
        }else if(others == 'Title Deed Charges' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.Towards_Deed_Charges)){
            return 'Amount towards other charges cannot be greater then '+System.Label.Towards_Deed_Charges+' for Title Deed Charges';
        }else if(others == 'Reissue of Plot NOC (construction)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Reissue_of_Plot_NOC_construction)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Reissue_of_Plot_NOC_construction+' for Reissue of Plot NOC (construction)';
        }else if(others == 'Reissue of Plot NOC (other than construction)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Reissue_of_Plot_NOC_other_than_construction)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Reissue_of_Plot_NOC_other_than_construction+' for Reissue of Plot NOC (other than construction)';
        }else if(others == 'Construction NOC' && Decimal.valueOf(amountTowardsOther) > 	Decimal.valueOf(System.Label.X15k_Construction_NOC)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Construction_NOC+' for Construction NOC';
        }else if(others == 'Detailed design NOC' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Detailed_design_NOC)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Detailed_design_NOC+' for Detailed design NOC';
        }else if(others == 'Concept drawing NOC' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Concept_drawing_NOC)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Concept_drawing_NOC+' for Concept drawing NOC';
        }else if(others == 'Pre-registration to pre-title deed (completed projects)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Pre_registration_to_pre_title_deed_completed_projects)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Pre_registration_to_pre_title_deed_completed_projects+' for Pre-registration to pre-title deed (completed projects)';
        }else if(others == 'Pre-registration To Pre-title Deed' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Pre_registration_To_Pre_title_Deed)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Pre_registration_To_Pre_title_Deed+' for Pre-registration To Pre-title Deed';
        }else if(others == 'Admin Charges (General)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Admin_Charges_General)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Admin_Charges_General+' for Admin Charges (General)';
        }else if(others == 'Admin Charges' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Admin_Charges)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Admin_Charges+' for Admin Charges';
        }else if(others == 'DLD Cancellation Charges' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_DLD_Cancellation_Charges)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_DLD_Cancellation_Charges+' for DLD Cancellation Charges';
        }else if(others == 'Ownership change' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Ownership_changes)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Ownership_changes+' for Ownership changes';
        }else if(others == 'Name addition/deletion' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Name_addition_deletion)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Name_addition_deletion+' for Name addition/deletion';
        }else if(others == 'SPA reissuance fees (per book)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_SPA_reissuance_fees_per_book)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_SPA_reissuance_fees_per_book+' for SPA reissuance fees (per book)';
        }else if(others == 'SPA Reissuance Fees' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_SPA_Reissuance_Fees)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_SPA_Reissuance_Fees+' for SPA Reissuance Fees';
        }else if(others == 'Title Deed Fees (Plots)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Plots)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Title_Deed_Fees_Plots+' for Title Deed Fees (Plots)';
        }else if(others == 'Plot title Deed' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Plot_title_Deed)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Plot_title_Deed+' for Plot title Deed';
        }else if(others == 'Title Deed Fees (Villas)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Villas)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Title_Deed_Fees_Villas+' for Title Deed Fees (Villas)';
        }else if(others == 'Title Deed Fees (Units)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Units)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Title_Deed_Fees_Units+' for Title Deed Fees (Units)';
        }else if(others == 'Resale NOC (Oqood)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Resale_NOC_Oqood)){
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Resale_NOC_Oqood+' for Resale NOC (Oqood)';
        } 
        
        if(isFromBooking && unitIdsTemp.size()>0){
            double allocatedDP = 0;
            double allocatedDLD = 0;
            double allocatedTitleAmount = 0;
            list<string> checkedNSA = new list<string>();
            for(Payment_Request__c pr : [select Id, From_Booking__c, New_Sale_Approval__c, Towards_Pre_Registration_Amount__c, 
                                        Towards_Unit_Price_Amount__c, New_Sale_Approval__r.DP_Amount__c, New_Sale_Approval__r.DP_Amount_2__c, 
                                        New_Sale_Approval__r.DLD_Amount__c, New_Sale_Approval__r.DLD_Amount_2__c ,
                                        Towards_Other_Charges_Amount__c,others__c
                                        from Payment_Request__c where Unit__c =: unitIdsTemp[0] and Status__c = 'Approved' and  
                                        ((From_Booking__c = true and Booking__c != null and Booking__r.Status__c != 'Cancelled') or 
                                        (New_Sale_Approval__c != null and New_Sale_Approval__r.Approval_Status__c = 'Approved' and New_Sale_Approval__r.Booking__r.Status__c != 'Cancelled'))]){
                if(pr.From_Booking__c){
                    allocatedDP = (pr.Towards_Unit_Price_Amount__c!=null)?allocatedDP+(double)pr.Towards_Unit_Price_Amount__c:allocatedDP;
                    allocatedDLD = (pr.Towards_Pre_Registration_Amount__c!=null)?allocatedDLD+(double)pr.Towards_Pre_Registration_Amount__c:allocatedDLD;
                    if(pr.others__c == 'Title Deed Charges'){
                        allocatedTitleAmount = (pr.Towards_Other_Charges_Amount__c!=null)?allocatedTitleAmount+(double)pr.Towards_Other_Charges_Amount__c:allocatedTitleAmount;
             
                    }
                      }
                if((pr.New_Sale_Approval__c!=null && !checkedNSA.contains(pr.New_Sale_Approval__c)) || Test.isRunningTest()){
                    checkedNSA.add(pr.New_Sale_Approval__c);
                    allocatedDP = (pr.New_Sale_Approval__r.DP_Amount__c!=null)?allocatedDP+(double)pr.New_Sale_Approval__r.DP_Amount__c:allocatedDP;
                    allocatedDP = (pr.New_Sale_Approval__r.DP_Amount_2__c!=null)?allocatedDP+(double)pr.New_Sale_Approval__r.DP_Amount_2__c:allocatedDP;
                    allocatedDLD = (pr.New_Sale_Approval__r.DLD_Amount__c!=null)?allocatedDLD+(double)pr.New_Sale_Approval__r.DLD_Amount__c:allocatedDLD;
                    allocatedDLD = (pr.New_Sale_Approval__r.DLD_Amount_2__c!=null)?allocatedDLD+(double)pr.New_Sale_Approval__r.DLD_Amount_2__c:allocatedDLD;
                }                            
            }

            allocatedDP = (amountTowardsUnit!=null && amountTowardsUnit!='null' && amountTowardsUnit!='' && amountTowardsUnit!='undefined')?Double.valueOf(amountTowardsUnit)+allocatedDP:allocatedDP;
            allocatedDLD = (amountTowardsPreReg!=null && amountTowardsPreReg!='null' && amountTowardsPreReg!='' && amountTowardsPreReg!='undefined')?Double.valueOf(amountTowardsPreReg)+allocatedDLD:allocatedDLD;
            double tenPercent = (unitIdToUnitObj.containsKey(unitIdsTemp[0]) && unitIdToUnitObj.get(unitIdsTemp[0])!=null && unitIdToUnitObj.get(unitIdsTemp[0]).Puchase_Price__c!=null)?(double)(unitIdToUnitObj.get(unitIdsTemp[0]).Puchase_Price__c*0.1):0;
            double fourPercent = (unitIdToUnitObj.containsKey(unitIdsTemp[0]) && unitIdToUnitObj.get(unitIdsTemp[0])!=null && unitIdToUnitObj.get(unitIdsTemp[0]).Puchase_Price__c!=null)?(double)(unitIdToUnitObj.get(unitIdsTemp[0]).Puchase_Price__c*0.04):0;
            boolean skipPregistrationValidation = false;
            if(mortageValue != null && mortageValue != 'null'
            && mortageValue != '' && mortageValue != 'undefined'
            && mortageValue != '0'){
                skipPregistrationValidation = true;
            }
            if(amountTowardsOther != null && amountTowardsOther!= ''
            && others == 'Title Deed Charges'){
                allocatedDLD += Decimal.valueOf(amountTowardsOther);
                
            }
            if(mode == 'OTC Deposits' ){
                if(amountTowardsUnit!=null && amountTowardsUnit!='null' 
                && amountTowardsUnit!='' && amountTowardsUnit!='undefined' 
                && allocatedDP > tenPercent+10 && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName()))
                    return 'A maximum of 10% of the unit purchase price has already been allocated towards unit price.';
                decimal dldAmountToCompare = fourPercent+Decimal.valueOf(System.Label.DLD_Charge); 
                if(others == 'Title Deed Charges'){
                    dldAmountToCompare += Decimal.valueOf(System.label.Towards_Deed_Charges);
                
                }
                
                if( (amountTowardsOther!=null && 
                amountTowardsOther!='null' && amountTowardsOther!='' 
                && amountTowardsOther!='undefined') 
                && others == 'Title Deed Charges'
                && (allocatedDLD + allocatedTitleAmount)> 
                dldAmountToCompare && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName()))
                {
                    if(amountTowardsOther != null && amountTowardsOther!= ''
                    && others == 'Title Deed Charges'){    
                        return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150 and Title Deed fee of AED '+System.label.Towards_Deed_Charges+' has already been allocated towards pre-registration.';
                    }else{
                        return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150'+' has already been allocated towards pre-registration.';
                    }
                }
                if(!skipPregistrationValidation &&( (amountTowardsPreReg!=null && 
                amountTowardsPreReg!='null' && amountTowardsPreReg!='' 
                && amountTowardsPreReg!='undefined') )
                && allocatedDLD > 
                (dldAmountToCompare ) && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName()))
                {
                   return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150'+' has already been allocated towards pre-registration.';
                    
                }
                  
            }
            else{
                decimal dldAmountToCompare = fourPercent+Decimal.valueOf(System.Label.DLD_Charge); 
                if(amountTowardsOther != null && amountTowardsOther!= ''
                && others == 'Title Deed Charges'){    
                   dldAmountToCompare += Decimal.valueOf(System.label.Towards_Deed_Charges);
                }
                
                if(!skipPregistrationValidation && amountTowardsPreReg!=null && amountTowardsPreReg!='null' && amountTowardsPreReg!='' && amountTowardsPreReg!='undefined' 
                && allocatedDLD > dldAmountToCompare 
                && 
                !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName())){
                    if(amountTowardsOther != null && amountTowardsOther!= ''
                    && others == 'Title Deed Charges'){    
                        return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150 and Title Deed fee of AED '+System.label.Towards_Deed_Charges+' has already been allocated towards pre-registration.';
                   
                    }else{
                        return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150 '+' has already been allocated towards pre-registration.';
                   
                    }
                }
                    
            
            }
        }
        map<string,decimal> unitIdToMinHoldAmount = new map<string,decimal>();      
        if(modeOption == 'Single Mode') {                                         
            Double sumOfUnitSaleValue=0;
            for(Unit__c u : [select Id, Unit_Hold_min_percentage__c, Puchase_Price__c from Unit__c where Id IN: unitIdsTemp]){
                Double eachUnitHoldValue = 0;
                if(u.Unit_Hold_min_percentage__c != null){
                    eachUnitHoldValue = (Double)((u.Puchase_Price__c * u.Unit_Hold_min_percentage__c)/100);
                }
                else{
                    eachUnitHoldValue = (Double)((u.Puchase_Price__c * 2)/100);
                }
                sumOfUnitSaleValue = sumOfUnitSaleValue + eachUnitHoldValue;
                unitIdToMinHoldAmount.put(u.Id,eachUnitHoldValue);
            }
            
                Double givenAmount=0;
                String unitIdWithMinimumAmountError = '';
                for(string uId : units){
                    string unitId = uId.split('##')[0];
                    Double perUnitAmt = Double.valueOf(uId.split('##')[2]);
                    if(uId.split('##')[1] != 'AED'){
                        perUnitAmt = (Double)(perUnitAmt*currToRate.get(uId.split('##')[1]));
                        
                    }
                    if(perUnitAmt < unitIdToMinHoldAmount.get(unitId)){
                        unitIdWithMinimumAmountError += unitIdToUnitObj.get(unitId).Name+',';
                    }
                }
                if(unitIdWithMinimumAmountError != ''){
                    unitIdWithMinimumAmountError = unitIdWithMinimumAmountError.substring(0,unitIdWithMinimumAmountError.length()-1);
                    return unitIdWithMinimumAmountError+' : Amount should be greater or equal to Unit Hold Min Percentage of Unit purchase price.';
                
                }
                                                  
        } 
        Boolean isSecondaryMode = false;
        if(modeOption == 'Multi Mode'){
            if(secondaryMode != null && secondaryMode != 'undefined' && secondaryMode != ''){ 
                list<Payment_Request__c> prList = [select Id,Amount__c from Payment_Request__c where Id =: prId];
                if(prList.size()>0){
                    isSecondaryMode = true;
                    //String unitIdWithMinimumAmountError ='';
                    Double amt = (Double)prList[0].Amount__c;
                    Double perUnitAmt = (Double)(amt/prList.size());
                    Boolean isPrimaryOTC = false;
                    Payment_Request__c parentPR = [select Id,Mode__c,Currency__c,Amount_Confirmed_By_Accounts__c from Payment_Request__c where Id =: prId];
                    if(parentPR.Mode__c == 'OTC Deposits')
                        isPrimaryOTC = true;
                    if(parentPR.Currency__c != 'AED' && !parentPR.Amount_Confirmed_By_Accounts__c)
                        perUnitAmt = (Double)(perUnitAmt*currToRate.get(parentPR.Currency__c));
                    Unit__c u = [select Id, Unit_Hold_min_percentage__c, Puchase_Price__c from Unit__c where Id IN: unitIdsTemp LIMIT 1][0];
                    Double unitPp = (Double)u.Puchase_Price__c;
                    Double twoPercent = (u.Unit_Hold_min_percentage__c != null)? (Double)((unitPp*u.Unit_Hold_min_percentage__c)/100) : (Double)((unitPp*2)/100); 
                    //if(mode == 'OTC Deposits'){
                        Double givenAmount=0;
                        for(string uId : units){
                            if(isSecondaryMode == false){
                                if(uId.split('##')[1] != 'AED'){
                                    Double perUnitAmtTmp = Double.valueOf(uId.split('##')[2]);
                                    perUnitAmtTmp = (Double)(perUnitAmtTmp*currToRate.get(uId.split('##')[1]));
                                    givenAmount+= perUnitAmtTmp;
                                }
                                else{
                                    givenAmount+= Double.valueOf(uId.split('##')[2]);
                                }
                            }else{
                                if(mode == 'International Wire Transfer' && curr != 'AED'){
                                    givenAmount = Double.valueOf(amount);
                                    givenAmount = (Double)(givenAmount*currToRate.get(curr));
                                   
                                }
                                else{
                                    givenAmount = Double.valueOf(amount);
                                } 
                            }
                            
                        }
                        givenAmount = givenAmount + perUnitAmt;
                        if(givenAmount<twoPercent){
                            return 'Amount should be greater or equal to Unit Hold Min Percentage of Unit purchase price.';
                        }
                        if(mode == 'OTC Deposits'){
                   
                            decimal dldAmountToCompare = 0; 
                            dldAmountToCompare += Decimal.valueOf(System.label.Towards_Deed_Charges);
                            
                            if(isPrimaryOTC && givenAmount > (Double)(((unitPp*Integer.valueOf(System.Label.PR_OTC_MAX_Amount_Percentage))/100)+Decimal.valueOf(System.Label.DLD_Charge)+dldAmountToCompare+10) && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName())){
                                System.debug('293');
                                if(showValidationErrorForOtherCharge(others)){
                                	return System.Label.PR_OTC_14_Percent_Validation_Msg;
                                }
                            }
                           if(!isPrimaryOTC && (givenAmount) > (Double)(((unitPp*14)/100)+Decimal.valueOf(System.Label.DLD_Charge)+dldAmountToCompare+10) && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName())){
                                if(amountTowardsOther != null && amountTowardsOther!= ''
                                && others == 'Title Deed Charges'){    
                                    return 'A maximum of 14% of the unit purchase price plus the DLD Admin fee of AED 1150 and Title Deed fee of AED '+System.label.Towards_Deed_Charges+' can be created for OTC Deposits.';
                                }else{
                                    return 'A maximum of 14% of the unit purchase price plus the DLD Admin fee of AED 1150'+' can be created for OTC Deposits.';
                                }
                                
                            }
                        }
                    
                }
            }
        }
        
        list<Payment_Request__c> prList = new list<Payment_Request__c>();
        Payment_Request_Wrapper__c prw = new Payment_Request_Wrapper__c();
        if(units.size()>0){
            Integer minutes = 30;
            try{
                minutes = Integer.valueOf(System.Label.Payment_Expiration_Time);
            } catch(Exception e){
                minutes = 30;
            }
            DateTime dt = System.now().addMinutes(minutes);
            prw.Payment_Link_Expiry__c = dt;
            prw.Customer_Name__c  = name;
            if(mode != 'International Wire Transfer' && mode != 'OTC Deposits')
                prw.Currency__c = 'AED';
            else if(curr != null && curr != 'undefined')
				prw.Currency__c = curr; 
            if(email != null && email != 'undefined')
                prw.Email__c = email;
            if(mobile != null && mobile != 'undefined')
                prw.Mobile_Number__c = mobile;
            if(mode != null && mode != 'undefined')
                prw.Mode__c = mode;
            if(amount != null && amount != 'undefined')
                prw.Amount__c = Double.valueOf(amount);
            
            list<string> unitIds = new list<string>();
            
            for(string uId : units){
                string untId = uId.split('##')[0];
                unitIds.add(untId);
            }
            
            string unitNames='';
            for(Unit__c u : [select Id, Name from Unit__c where Id IN : unitIds]){
                unitNames += u.Name+',';
            }
            unitNames = unitNames.removeEnd(',');
            prw.Units__c = unitNames;
            
            insert prw;
        }
        Shoba_Default_Settings__mdt  sobhaDefaultSettings = Shoba_Default_Settings__mdt.getInstance('Org_Defaults');
        prw.Payment_Public_Page_Link__c = sobhaDefaultSettings.Payment_Community_Url__c +prw.id;
        update prw;
        //Aayushi : SOB-341 SOB-403 added ESCROW details for CDM Cash
        if(!isCorporate && (mode == 'International Wire Transfer' || mode == 'Domestic Wire Transfer'
        || mode== 'CDM Cash' )){
            list<string> listOfUnitIds = new list<string>();
            for(string uId : units){
                String accountType;
                if(isFromBooking == false && isSecondaryMode == false && 
                (mode == 'International Wire Transfer' 
                || mode == 'Domestic Wire Transfer'
                || mode== 'CDM Cash')){
                    accountType = uId.split('##')[3];
                    
                }
                if(accountType == 'ESCROW' || accountType == null)
                listOfUnitIds.add(uId.split('##')[0]);
            }
            String msg = '';
            for(Unit__c u : [select Id, Name, Tower__c, Tower__r.ESCROW_Account__c, Tower__r.Name from Unit__c where Id IN: listOfUnitIds and Tower__c != null]){
                if(u.Tower__r.ESCROW_Account__c == null){
                    msg = msg+u.Name+', ';
                }
            }
            msg = msg.removeEnd(',');
            if(msg != ''){
                return msg+' : ESCROW Account not mapped, Please select Corporate Account.';
            }
        }

        string cate='';
        string subcate='';
        if(category!=null && category!='' && category.contains('#')){
            list<string> categoryList = category.split('#');
            if(categoryList.size() == 2){
                cate = (categoryList[0]!='null' && categoryList[0]!='')?categoryList[0]:'';
                subcate = (categoryList[1]!='null' && categoryList[1]!='')?categoryList[1]:'';
            }else if(categoryList.size() == 1){
                cate = (categoryList[0]!='null' && categoryList[0]!='')?categoryList[0]:'';
            }
        }
        
        if(mode == 'OTC Deposits'){
            for(string uId : units){
                string untId = uId.split('##')[0];
                //SOB-278 get amount and currency for each unit and assign -- SOB-397
                if(!isFromBooking && (String.isBlank(secondaryMode) || secondaryMode == '')){
                    curr = uId.split('##')[1];
                    amount = uId.split('##')[2];
                }
                decimal dldAmountToCompare = 0; 
                dldAmountToCompare += Decimal.valueOf(System.label.Towards_Deed_Charges);
                
                curr = 'AED';//SOB-397
                if(!System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName()) && curr != 'AED' 
                && unitIdToUnitObj.get(untId).Puchase_Price__c != null 
                && showValidationErrorForOtherCharge(others)
                && ((Double.valueOf(amount) * currToRate.get(curr))) > (Double)(((unitIdToUnitObj.get(untId).Puchase_Price__c * Integer.valueOf(System.Label.PR_OTC_MAX_Amount_Percentage))/100) + Decimal.valueOf(System.Label.DLD_Charge) + dldAmountToCompare + 10)){
                    System.debug('404');
                    string errorMsg = System.Label.PR_OTC_14_Percent_Validation_Msg;
                    errorMsg = errorMsg.replace('#UNIT#', unitIdToUnitObj.get(untId).Name);
                    return errorMsg;
                }
                if(!System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName()) && curr == 'AED' && unitIdToUnitObj.get(untId).Puchase_Price__c != null && (Double.valueOf(amount)) > (Double)(((unitIdToUnitObj.get(untId).Puchase_Price__c * Integer.valueOf(System.Label.PR_OTC_MAX_Amount_Percentage))/100) + Decimal.valueOf(System.Label.DLD_Charge) + dldAmountToCompare + 10)){
                    System.debug('411');
                    if(showValidationErrorForOtherCharge(others))
                    {
                    	string errorMsg = System.Label.PR_OTC_14_Percent_Validation_Msg;
                    	errorMsg = errorMsg.replace('#UNIT#', unitIdToUnitObj.get(untId).Name);
                    	return errorMsg;
                    }
                }
                System.debug('amountTowardsOther -->'+amountTowardsOther);
                if(amountTowardsOther != null && amountTowardsOther != '' && amountTowardsOther != 'null'){
                    List<Payment_Request__c> paymentRequests = [SELECT id,Amount__c,Booking__c,Status__c FROM Payment_Request__c WHERE Booking__r.Id =: bookingId AND Mode__c = 'OTC Deposits' AND Towards_Other_Charges_Amount__c != null AND CreatedDate >= :DateTime.now().addHours(-24)];
                    Decimal sum = 0;
                    if(paymentRequests != NULL){
                        sum = Decimal.valueOf(amountTowardsOther); 
                        for(Payment_Request__c pr : paymentRequests){
                            if(!pr.status__c.containsIgnoreCase('reject')) sum += pr.Amount__c != NULL ? pr.Amount__c : sum;
                        }
                    }
                    if(sum > Decimal.valueOf(System.Label.X15k_Limit_for_per_day_transactions) && showValidationErrorForOtherCharge(others)){
                        return 'Sum of all OTC Mode Payment Requests created in a day cannot be greater then '+System.Label.X15k_Limit_for_per_day_transactions;
                    } 
                }
                Payment_Request__c pr = new Payment_Request__c();
                //populate pop comments and pop amount SOB-357
                if(popComments != ''){
                    List<String> popList = popComments.split('######');
                    system.debug('popList-->'+popList);
                    pr.POP_Comments__c = popList[0];
                    if(popList.size() > 1){
                        pr.POP_Amount__c = Decimal.valueOf(popList[1]);
                    
                    }
                    if(popList.size() > 2){
                        pr.X3rd_Party_payment__c = popList[2];
                    
                    }
                
                }
                pr.Lead_Source_Category__c = cate;
                pr.Lead_Source_Sub_Category__c = subcate;
                if(name != null && name != 'undefined')
                    pr.Name__c = name;
                if(email != null && email != 'undefined')
                    pr.Email__c = email;
                if(mobile != null && mobile != 'undefined')
                    pr.Mobile_Number__c = mobile;
                if(passportNumber != null && passportNumber != 'undefined')
                    pr.Emirates_Id_Passport_Number__c = passportNumber;
                pr.Mode__c = mode;
                pr.Unit__c = untId;
                pr.Payment_Request_Wrapper__c = prw.Id;
                if(curr != null && curr != 'undefined' && curr != '')
                    pr.Currency__c = curr;
                pr.Currency__c = 'AED';
                if(instrumentNumber != null && instrumentNumber != 'undefined')
                    pr.Instrument_Number__c = instrumentNumber;
                if(instrumentDate != null && instrumentDate != 'undefined')
                    pr.Instrument_Date__c = Date.valueOf(instrumentDate);
                if(chequeNo != null && chequeNo != 'undefined')
                    pr.Cheque_No__c = chequeNo;
                if(chequeDate != null && chequeDate != 'undefined')
                    pr.Cheque_Date__c = Date.valueOf(chequeDate);
                if(accountNo != null && accountNo != 'undefined')
                    pr.Account_Master__c = accountNo;
                if(amount != null && amount != 'undefined' && amount != '')
                    pr.Amount__c = Double.valueOf(amount);
                if(dateOfInitiation != null && dateOfInitiation != 'undefined')
                    pr.Date_of_Initiation__c = Date.valueOf(dateOfInitiation);
                if(referenceNo != null && referenceNo != 'undefined')
                    pr.Reference_Number__c  = referenceNo;
                if(countryOfInitiation != null && countryOfInitiation != 'undefined')
                    pr.Country_of_Initiation__c = countryOfInitiation;
                if(modeOption != null && modeOption != 'undefined' && modeOption != '')
                    pr.Mode_Option__c = modeOption;
                if(secondaryMode != null && secondaryMode != 'undefined' && secondaryMode != ''){ 
                    pr.Secondary_Mode__c = secondaryMode;
                    list<Payment_Request__c> prToUpdate = [select Id,Currency__c,Amount__c,Status__c,Amount_Confirmed_By_Accounts__c from Payment_Request__c where Id =: prId];
                    if(prToUpdate.size()>0){
                        if(prToupdate[0].Currency__c != 'AED' && prToupdate[0].Amount_Confirmed_By_Accounts__c == false && (prToupdate[0].Status__c == 'Partially Approved' || prToupdate[0].Status__c == 'Submitted to Accounts for Amount Confirmation')){
                            if(curr != 'AED'){
                            	pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(curr)) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                            else{
                                pr.Total_Amount__c = Double.valueOf(amount) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                        }else{
                            if(curr != 'AED'){
                                pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(curr)) + prToUpdate[0].Amount__c;
                            }
                            else{
                            	pr.Total_Amount__c = Double.valueOf(amount) + prToUpdate[0].Amount__c;
                            }
                        }
                    }
                }
                if(isFromBooking){
                    pr.From_Booking__c = true;
                    pr.Booking__c = bookingId;
                    if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null')
                    	pr.Towards_Unit_Price_Amount__c = Double.valueOf(amountTowardsUnit);
                    if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null')
                    	pr.Towards_Pre_Registration_Amount__c = Double.valueOf(amountTowardsPreReg);
                    if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null')
                    	pr.Towards_Other_Charges_Amount__c = Double.valueOf(amountTowardsOther);
                    if(amountTowards != null && amountTowards != 'undefined' && amountTowards != '' && amountTowards != 'null')
                        pr.Amount_Towards__c = amountTowards;
                    if(others != null && others != 'undefined' && others != '' && others != 'null')
                        pr.Others__c  = others;
                    if(mortageValue != null && mortageValue != 'undefined'
                    && mortageValue != '' && mortageValue != 'null')
                    pr.Mortgage_Value__c = Double.valueOf(mortageValue);
                       
                }
                if(currentUser.ManagerId != null){
                    pr.Submitter_Manager__c = currentUser.ManagerId;
                    pr.Submitter_Manager_s_Manager__c = currentUser.Manager.ManagerId;
                }
                if(prId != '')
                    pr.Payment_Request__c = prId;
                if(Test.IsRunningTest()){
                    pr.Others__c = 'Cancellation Charges';
                }
                prList.add(pr);
            }
        }
        else{
            for(string uId : units){
                //aayushi added below four lines to get currency amount
                 //SOB-278 get amount and currency for each unit and assign	
                string untId = uId.split('##')[0];		
                if(!isFromBooking && secondaryMode == ''){		
                    curr = uId.split('##')[1];		
                    amount = uId.split('##')[2];		
                }
                Payment_Request__c pr = new Payment_Request__c();
                //populate pop comment and pop Amount SOB-357
                if(popComments != ''){
                    List<String> popList = popComments.split('######');
                    pr.POP_Comments__c = popList[0];
                    if(popList.size() > 1){
                        pr.POP_Amount__c = Decimal.valueOf(popList[1]);
                    
                    }
                    if(popList.size() > 2){
                        pr.X3rd_Party_payment__c = popList[2];
                    
                    }
                
                }
                pr.Lead_Source_Category__c = cate;
                pr.Lead_Source_Sub_Category__c = subcate;
                pr.Third_Party__c = isThirdParty;
                if(name != null && name != 'undefined')
                    pr.Name__c = name;
                if(email != null && email != 'undefined')
                    pr.Email__c = email;
                if(mobile != null && mobile != 'undefined')
                    pr.Mobile_Number__c = mobile;
                if(passportNumber != null && passportNumber != 'undefined')
                    pr.Emirates_Id_Passport_Number__c = passportNumber;
                pr.Mode__c = mode;
                pr.Unit__c = untId;
                pr.Payment_Request_Wrapper__c = prw.Id;
                if (mode == 'Website')
                    //pr.Payment_GateWay__c = System.Label.Payment_GateWay;
                    //pr.Payment_Link_Status__c = 'Active';
                    pr.Payment_public_link__c = sobhaDefaultSettings.Payment_Community_Url__c +prw.id;
                if(curr != null && curr != 'undefined' && mode == 'International Wire Transfer')
                    pr.Currency__c = curr;
                if(mode != 'International Wire Transfer')
                    pr.Currency__c = 'AED';
                if(instrumentNumber != null && instrumentNumber != 'undefined')
                    pr.Instrument_Number__c = instrumentNumber;
                if(instrumentDate != null && instrumentDate != 'undefined')
                    pr.Instrument_Date__c = Date.valueOf(instrumentDate);
                if(chequeNo != null && chequeNo != 'undefined')
                    pr.Cheque_No__c = chequeNo;
                if(chequeDate != null && chequeDate != 'undefined')
                    pr.Cheque_Date__c = Date.valueOf(chequeDate);
                /*if(modeOption == 'Multi Mode'){
                    if(accountNo != null && accountNo != 'undefined')
                        pr.Account_Master__c = accountNo;
                }*/
                if(isCorporate && accountNo != null && accountNo != 'undefined' && (mode == 'International Wire Transfer' || mode == 'Domestic Wire Transfer'
                || mode == 'CDM Cash')){
                    pr.Account_Master__c = accountNo;
                    pr.Account_Type__c = 'Corporate';
                }
                //Aayushi : SOB-341 SOB-403 added ESCROW details for CDM Cash
                if(!isCorporate && (mode == 'International Wire Transfer' || mode == 'Domestic Wire Transfer'
                || mode== 'CDM Cash')){
                    pr.Account_Type__c = 'ESCROW';
                    List<Unit__c> u = [select Id, Tower__c, Tower__r.ESCROW_Account__c from Unit__c where Id =: untId LIMIT 1];
                    if(u.size() > 0 && u[0].Tower__c != null && u[0].Tower__r.ESCROW_Account__c != null){
                        pr.Account_Master__c = u[0].Tower__r.ESCROW_Account__c;
                    }
                }
                //Aayushi : SOB-341 added ESCROW details for CDM Cash
                 //Aayushi : SOB-341 SOB-403 added ESCROW details for CDM Cash
               
                if(isFromBooking == false && isSecondaryMode == false && (mode == 'International Wire Transfer' || mode == 'Domestic Wire Transfer'
                || mode== 'CDM Cash')){
                    string accountType = uId.split('##')[3];
                    string accountId = uId.split('##')[4];
                    if(accountType == 'Corporate'){
                        pr.Account_Type__c = 'Corporate';
                        pr.Account_Master__c = accountId;
                    }
                    if(accountType == 'ESCROW'){
                        pr.Account_Type__c = 'ESCROW';
                        pr.Account_Master__c = (accountNameToAccountId.containsKey(accountId))?accountNameToAccountId.get(accountId):null;
                    }
                }
                if(amount != null && amount != 'undefined')
                    pr.Amount__c = Double.valueOf(amount);
                if(dateOfInitiation != null && dateOfInitiation != 'undefined')
                    pr.Date_of_Initiation__c = Date.valueOf(dateOfInitiation);
                if(referenceNo != null && referenceNo != 'undefined')
                    pr.Reference_Number__c  = referenceNo;
                if(countryOfInitiation != null && countryOfInitiation != 'undefined')
                    pr.Country_of_Initiation__c = countryOfInitiation;
                if(modeOption != null && modeOption != 'undefined' && modeOption != '')
                    pr.Mode_Option__c = modeOption;
                if(secondaryMode != null && secondaryMode != 'undefined' && secondaryMode != ''){
                    pr.Secondary_Mode__c = secondaryMode;
                    list<Payment_Request__c> prToUpdate = [select Id,Currency__c,Amount__c,Status__c,Amount_Confirmed_By_Accounts__c from Payment_Request__c where Id =: prId];
                    if(prToUpdate.size()>0){
                        if(prToupdate[0].Currency__c != 'AED' && prToupdate[0].Amount_Confirmed_By_Accounts__c == false && (prToupdate[0].Status__c == 'Partially Approved' || prToupdate[0].Status__c == 'Submitted to Accounts for Amount Confirmation')){
                            if(pr.Currency__c != 'AED'){
                            	pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(pr.Currency__c)) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                            else{
                                pr.Total_Amount__c = Double.valueOf(amount) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                        }else{
                            if(pr.Currency__c != 'AED'){
                                pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(pr.Currency__c)) + prToUpdate[0].Amount__c;
                            }
                            else{
                            	pr.Total_Amount__c = Double.valueOf(amount) + prToUpdate[0].Amount__c;
                            }
                        }
                    }
                }
                if(isFromBooking){
                    pr.From_Booking__c = true;
                    pr.Booking__c = bookingId;
                    if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null')
                    	pr.Towards_Unit_Price_Amount__c = Double.valueOf(amountTowardsUnit);
                    if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null')
                    	pr.Towards_Pre_Registration_Amount__c = Double.valueOf(amountTowardsPreReg);
                    if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null')
                    	pr.Towards_Other_Charges_Amount__c = Double.valueOf(amountTowardsOther);
                    if(amountTowards != null && amountTowards != 'undefined' && amountTowards != '' && amountTowards != 'null')
                        pr.Amount_Towards__c = amountTowards;
                    if(others != null && others != 'undefined' && others != '' && others != 'null')
                        pr.Others__c  = others;
                        if(mortageValue != null && mortageValue != 'undefined'
                        && mortageValue != '' && mortageValue != 'null')
                       pr.Mortgage_Value__c = Double.valueOf(mortageValue);
                        
                }
                if(currentUser.ManagerId != null){
                    pr.Submitter_Manager__c = currentUser.ManagerId;
                    pr.Submitter_Manager_s_Manager__c = currentUser.Manager.ManagerId;
                }
                
                boolean is3rdPartyCheque = Boolean.ValueOf(is3rdParty.split('###')[0]);
        		boolean is3rdpartyIWT = Boolean.valueOf(is3rdParty.split('###')[2]);
        		boolean is3rdpartyCDMCheque = Boolean.valueOf(is3rdParty.split('###')[1]);
                boolean is3rdpartyDWT = Boolean.valueOf(is3rdParty.split('###')[3]);
                
                if(is3rdPartyCheque==true) pr.X3rd_Party_Cheque__c = true;
                if(is3rdpartyIWT == true) pr.X3rd_Party_IWT__c = true;
                if(is3rdpartyDWT == true) pr.X3rd_Party_DWT__c = true;
                if(is3rdpartyCDMCheque == true) pr.X3rd_Party_CDM_Cheque__c = true;
                if(prId != '')
                    pr.Payment_Request__c = prId;
                if(Test.IsRunningTest()){
                    pr.Others__c = 'Cancellation Charges';
                }
                prList.add(pr);
            }
        }
        if(prList.size()>0) {
            try {
                insert prList;
                // for(Payment_Request__c paymentInst :prList){
                //     if(paymentInst.Mode__c == 'Website'){
                //         MagnatiPaymentController.generateMagnatiPaymentLink(paymentInst.Payment_Request_Wrapper__c);
                //     }
                // }
            } catch(Exception e) {
                //system.assert(false,'VVK : '+e.getMessage() + ' Stack : '+e.getStackTraceString());
                Database.rollBack(sp);
                if(e.getMessage().contains('Payment Request can be created by Allocated SM only')) {
                    return 'Payment Request can be created by Allocated SM only';
                }
                if(e.getMessage().contains(System.label.Payment_Request_Unit_Restriction_Message)){
                    return System.label.Payment_Request_Unit_Restriction_Message;
                }
               // if(e.getMessage().contains(System.label.Resale_NOC_Amount_Error)){ 
                 //   return System.label.Resale_NOC_Amount_Error;
                //}
                
            }
           
        }
            
        
        if(uploadedFileLength > 0){
            List<ContentDocument> docList = [select Id from ContentDocument where CreatedById =: Userinfo.getUserId() order by CreatedDate desc limit: uploadedFileLength];
            List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
            for(ContentDocument cd : docList){
                for(Payment_Request__c pr : prList){
                    ContentDocumentLink cdLink = new ContentDocumentLink();
                    cdLink.ContentDocumentId = cd.Id;
                    cdLink.LinkedEntityId = pr.Id;
                    cdLinkList.add(cdLink);
                }
            }
            if(cdLinkList.size()>0){
                insert cdLinkList;
            }
        }        
        return 'success';
    }
    
    public static void rejectWebsiteRequests(list<string> wrapperIds){
        list<Payment_Request__c> prToUpdate = new list<Payment_Request__c>();
        list<Payment_Request__c> prToReject = [select Id from Payment_Request__c where Payment_Request_Wrapper__c IN: wrapperIds];
        for(Payment_Request__c pr : prToReject){
            pr.Status__c = 'Rejected by System';
            prToUpdate.add(pr);
        }
        update prToUpdate;
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Payment_Request_Wrapper__c pr : [select Id, CreatedBy.Email, CreatedBy.Name, (select Id, Unit__r.Unit_Status__c, Unit__r.Name from Payment_Requests__r) from Payment_Request_Wrapper__c where Id IN: wrapperIds]){
            string holdUnits = '';
            string allUnits = '';
            for(Payment_Request__c p : pr.Payment_Requests__r){
                if(p.Unit__r.Unit_Status__c == 'Hold') holdUnits += p.Unit__r.Name + '<br/>';
                allUnits += p.Unit__r.Name + ',';
            }
            allUnits = allUnits.removeEnd(',');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new list<string>{pr.CreatedBy.Email});
            mail.setSubject('Payment Request Rejection Notification');
            String body = 'Dear ' + pr.CreatedBy.Name + ', <br/><br/>';
            body += 'Your payment request for the unit(s) <b>'+ allUnits +'</b> has been rejected, as the following unit(s) is on hold by another request. <br/><br/>' + holdUnits + '<br/>';
            body += 'Please contact your sales manager for any clarifications.<br/><br/>';
            body += 'Regards,<br/>';
            body += 'Sobha Hartland';
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
    @AuraEnabled
    public static String checkifUnitIsBlocked(string unitid){
        try {
            String message = null;
            String managerId = [SELECT managerId fROM User WHERE ID =: userinfo.getuserId()].managerId;
            List<Unit_hold__c> uhList = [SELECT ID FROM Unit_Hold__C 
            WHERE status__c = 'active' 
            and sales_manager__c !=: userinfo.getuserId()
            and request_time__c != null
            and unit__r.allocated_sm__c !=: userinfo.getuserId()
            and unit__r.unit_status__c = 'Hold' ];
            if(uhList.size() > 0){ message = 'Unit has been put on hold by other Sales Manager'; }
            uhList = [SELECT ID FROM Unit_Hold__C 
            WHERE status__c = 'active' 
            and unit__c =: unitId 
            and (sales_director__c =: managerId Or sales_director__c =: userinfo.getuserId())
            and request_time__c = null];
            if(uhList.size() > 0){  message = 'Unit has been blocked due to non submission of New Sale Approval, please wait for 24 hours to select same unit'; }
            return message;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class UnitDetailsWrapper{
        @AuraEnabled 
        public  String unitkey;
        @AuraEnabled 
        public Boolean onDirectSale;
        @AuraEnabled
        public Payment_Request__c approvedPR;
	}
    private static boolean showValidationErrorForOtherCharge(String others){
        if(others != 'Maintenance Charges' && others != '1% Delayed Handover Charges'){ return true;}          
        return false;                 
	}
    public static void insertErrorLog(string errorMsg, string stackTrace, string recordName, string className, string methodName){
        Error_Log__c logError = new Error_Log__c();
        try{
            logError.Name=recordName;
            logError.Class__c=className;
            logError.Message__c=errorMsg;
            logError.Request__c=stackTrace;
            logError.Api_Type__c=methodName; 
            insert logError;
        }
        catch(Exception e){
            system.debug('insertErrorLog Error Msg: '+e.getMessage());
            system.debug('insertErrorLog StackTrace: '+e.getStackTraceString());
        }
    }
}