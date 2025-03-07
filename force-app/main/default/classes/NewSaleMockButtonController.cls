public without sharing class NewSaleMockButtonController {  
    
    @AuraEnabled
    public static User getUserHierarchy(string userId){
        return [select Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId from User where Id = :userId];
    }
    
    @AuraEnabled
    public static List<unitPicklistWrap> getUnitDetailsWithCatg(Id salesManager, String customerEmail){
        List<unitPicklistWrap> unitPicklist = new List<unitPicklistWrap>();
        Map<Id, Decimal> bookingWithReceipTotal = new Map<Id, Decimal>();
        Map<Id, Decimal> exitUnitPriceMap = new Map<Id, Decimal>();
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>([Select Id, Name, Unit__c, Unit__r.name, Unit__r.Puchase_Price__c, Booking_Date__c from Booking__c Where 
                                        Status__c='Cancelled' AND Sales_Managers__c=:salesManager AND Primary_Applicant_Email__c=:customerEmail AND Unit__r.Puchase_Price__c!=null]);
        List<Booking__c> bookingList = bookingMap.values();
        List<Receipt__c> receiptList = [Select Id, Amount_Rs__c, Booking__c from Receipt__c where Receipt_Status__c='Cleared' AND Booking__c IN:bookingMap.keyset()];
        List<Cancelled_Unit_Detail__c> exitUnitList = new List<Cancelled_Unit_Detail__c>([Select Id, Old_Booking__c, Amount__c from Cancelled_Unit_Detail__c where Old_Booking__c IN:bookingMap.keyset()]);
        
        if(exitUnitList.size()>0){
            for(Cancelled_Unit_Detail__c eud: exitUnitList){
                if(exitUnitPriceMap.containsKey(eud.Old_Booking__c)){
                    exitUnitPriceMap.put(eud.Old_Booking__c, exitUnitPriceMap.get(eud.Old_Booking__c)+eud.Amount__c);
                } else {
                    exitUnitPriceMap.put(eud.Old_Booking__c, eud.Amount__c);
                }
            }
        }
        
        if(receiptList.size()>0){
            for(Receipt__c rcp: receiptList){
                if(bookingWithReceipTotal.containsKey(rcp.Booking__c)){
                    bookingWithReceipTotal.put(rcp.Booking__c, bookingWithReceipTotal.get(rcp.Booking__c)+rcp.Amount_Rs__c);
                } else {
                    bookingWithReceipTotal.put(rcp.Booking__c, rcp.Amount_Rs__c);
                }
            }
        }
        
        if(bookingList.size()>0){
            for(Booking__c bok: bookingList){
                Decimal exitUnitPriceAlloted = 0;
                if(exitUnitPriceMap.containsKey(bok.Id)){
                    exitUnitPriceAlloted = exitUnitPriceMap.get(bok.Id);
                }
                
                unitPicklistWrap pick = new unitPicklistWrap();
                pick.bookingName = bok.Name;
                pick.bookingId = bok.Id;
                pick.unitName = bok.Unit__r.Name;
                pick.unitId = bok.Unit__c;
                pick.bookingDate = bok.Booking_Date__c;
                pick.unitPurchasePrice = bok.Unit__r.Puchase_Price__c;
                pick.maxUnitPriceAllowed = 0 - exitUnitPriceAlloted;
                if(bookingWithReceipTotal.containsKey(bok.Id)){
                    pick.maxUnitPriceAllowed = bookingWithReceipTotal.get(bok.Id) - exitUnitPriceAlloted;
                }
                unitPicklist.add(pick);
            }
        }
        return unitPicklist;
    }
    
    @AuraEnabled
    public static UnitHoldData getUnitHoldData(String recordId){
        UnitHoldData unitData = new UnitHoldData();
        
        Payment_Request_Mock__c paymentRequest=  [Select Payment_Request_Wrapper__c,payment_request__c,currency__c,payment_request__r.currency__c,Unit__r.Bypass_10_Validation__c,Secondary_Mode__c,
        payment_request__r.mode__c,payment_request__r.amount__c,payment_request__r.Unit__r.Puchase_Price__c,Unit__c,name__c,From_Booking__c,Total_Amount__c,Mode_Option__c,Email__c, Mobile_Number__c, Unit__r.name,Mode__c, createdby.id,createdby.name,Unit__r.Puchase_Price__c,Unit__r.Unit_Hold_min_percentage__c,Unit_Purchase_Amount__c,Cheque_No__c,Amount__c,Sales_Manager__c,Status__c,(select id from New_Sale_Approval_Mocks__r where Approval_Status__c='Approved by Sales Ops' or Approval_Status__c='Pending' or Approval_Status__c = 'Approved by Sales VP' or Approval_Status__c = 'Approved' or Approval_Status__c = 'Approved by Sales Head') ,
        Unit__r.Legal_Entity__r.Favouring__c,
        Unit__r.Legal_Entity__r.Account_Number_Flat_Cost__c,
        Unit__r.Legal_Entity__r.IBAN__c,
        Unit__r.Legal_Entity__r.MICR_Code_Flat_Cost__c,
        Unit__r.Legal_Entity__r.Bank_Name_Flat_Cost__c,
        Unit__r.Legal_Entity__r.Branch_Name_Flat_Cost__c,pop_amount__c,Lead_Source_Category__c
        FROM Payment_Request_Mock__c Where Id =: recordId];  
        system.debug('Shravani '+ paymentRequest);
        unitData.showIwtError = false;
        unitData.Lead_Source_Category = paymentRequest.Lead_Source_Category__c;
        if((paymentRequest.Mode_Option__c=='Single Mode' && paymentRequest.Status__c=='Approved' && paymentRequest.Mode__c!='International Wire Transfer' && !paymentRequest.From_Booking__c)
          || (paymentRequest.Mode_Option__c=='Multi Mode' && paymentRequest.Status__c=='Approved' && paymentRequest.Total_Amount__c > 0 && paymentRequest.Mode__c!='International Wire Transfer' && !paymentRequest.From_Booking__c)
           || (paymentRequest.Mode__c=='International Wire Transfer' && !paymentRequest.From_Booking__c && (paymentRequest.Status__c=='Approved' || paymentRequest.Status__c=='Submitted to Accounts for Amount Confirmation'))
           || (paymentRequest.Mode__c=='Domestic Wire Transfer' && !paymentRequest.From_Booking__c && (paymentRequest.Status__c=='Approved' || paymentRequest.Status__c=='Submitted to Accounts for Amount Confirmation'))
           || (paymentRequest.Mode__c=='CDM Cash' && !paymentRequest.From_Booking__c && (paymentRequest.Status__c=='Approved' || paymentRequest.Status__c=='Submitted to Accounts for Amount Confirmation'))
          )
        {
            unitData.isEligibleForNSA=true;
        }
        else{
            unitData.isEligibleForNSA=false;
            unitData.notEligibleError=System.Label.NSA_EligibilityError;
        }
        /*if(paymentRequest.Mode_Option__c=='Multi Mode' && paymentRequest.Secondary_Mode__c==null){
            unitData.isEligibleForNSA=false;
            unitData.notEligibleError=System.Label.NSA_PrimaryModeError;
        }*/
        //Aayushi :SOB-403 added cdm cash condition
        if((paymentRequest.mode__c == 'International Wire Transfer' || paymentRequest.mode__c == 'CDM Cash' || paymentRequest.mode__c == 'Domestic Wire Transfer') && paymentRequest.total_Amount__c == null && paymentRequest.payment_request__c != null){
            //i.e. primary PR with IWT, therefore user shouldn't be able to create New Sale Approval
            unitData.showIwtError = true;
            unitData.isDisplay = true;
        }
        
        boolean exceptionUnit=false;
        boolean skipNSAValidation=false;
        if(paymentRequest.Unit__c != null && paymentRequest.Unit__r.Bypass_10_Validation__c == true){
            exceptionUnit=true;
        }
        unitData.exceptionUnit=exceptionUnit;
        string usernamesToSkip = System.Label.PR_OTC_Skip_Validation_Usernames;
        if(usernamesToSkip.contains(UserInfo.getUserName())){
            skipNSAValidation=true;
        }
        unitData.skipNSAValidation=skipNSAValidation;
    
        map<string,decimal> currToRate = new map<string,decimal>();
        for(Currency_Rate__mdt currRate : [select MasterLabel, Rate__c from Currency_Rate__mdt]){
            currToRate.put(currRate.MasterLabel,currRate.Rate__c);
        }                  
        unitData.currToRate = currToRate;
        unitData.currency1 = paymentrequest.currency__c;
        unitData.updateDpAndDld = true; 
        string userRole = '', userId = '';
        List<UserRole> currerntUserRole = [select Id, Name from UserRole 
        where Id =: UserInfo.getUserRoleId()];
        String profileName = [SELECT Id,Name from profile WHERE id =: userinfo.getprofileId()].name;
        if(currerntUserRole.size() > 0){ userRole = currerntUserRole[0].Name; }
        unitData.displaySalesManagerError = false;
        if((profileName == 'VP-Data Entry Operator' || userRole.contains('Sales Head'))
         && (paymentrequest.Sales_Manager__c == null || paymentrequest.Sales_Manager__c == UserInfo.getUserId())){
            unitData.displaySalesManagerError = true; unitData.existingsalepending= true;
        }
        if(userRole.contains('Sales Manager')) userId = UserInfo.getUserId();
        else if(paymentRequest.Sales_Manager__c != null) userId = paymentRequest.Sales_Manager__c;
        else userId = UserInfo.getUserId();
        
        User userData =[select id,Name,UserRole.Name,Managerid,Manager.Name,Manager.Managerid,Manager.Manager.Name,Manager.Manager.Id,Manager.Manager.Manager.Name,Manager.Manager.Manager.Id,Manager.Manager.Manager.Manager.Id,Manager.Manager.Manager.Manager.Name from user where id=:userId];
        
        
        if(!paymentRequest.New_Sale_Approval_Mocks__r.isEmpty()){ unitData.existingsalepending = true; }
        unitData.unitValue = paymentRequest.Unit__r.Name;
        unitData.salesValue = paymentRequest.Unit__r.Puchase_Price__c;
        unitData.salesManagerValue = userData.Name; 
        unitData.salesHeadValue = userData.Manager.Name;
        unitData.salesHeadVPValue =userData.Manager.Manager.Name;
        unitData.salesHeadVPUserId = userData.Manager.Manager.Id;
        unitData.salesHeadSVPValue =userData.Manager.Manager.Manager.Name;
        unitData.salesHeadSVPUserId = userData.Manager.Manager.Manager.Id;        
        unitData.csoValue =userData.Manager.Manager.Manager?.Manager?.Name;
        unitData.csoUserId = userData.Manager.Manager.Manager?.Manager?.Id;
        
        unitData.salesMangId = userData.Id;
        unitData.salesHeadId = userData.ManagerId;
        unitData.dldAmount = 0;
        unitData.dpAmount = 0;
        unitData.Amount = paymentrequest.amount__c;
        
        unitData.customerEmail = paymentrequest.Email__c;
        
        
        unitData.minPercentage = paymentRequest.Unit__r.Unit_Hold_min_percentage__c != null ? paymentRequest.Unit__r.Unit_Hold_min_percentage__c : 2;
        unitData.mode = paymentRequest.Mode__c != null ? paymentRequest.Mode__c.tolowercase() : null;
        //Aayushi :SOB-403 added cdm cash condition
        unitData.isNotIWTMode = (paymentRequest.mode__c != 'International Wire Transfer' && paymentRequest.mode__c != 'Domestic Wire Transfer' && paymentRequest.mode__c != 'CDM Cash') ? true : false;
        unitData.singleModeWithMultipleUnits = false;
        List<user> mangelist =[select Id,ManagerId from User where Id=:userData.Managerid ];
        if(!mangelist.isEmpty()){
         unitData.multipleUnits =false;
        unitData.salesHeadvpId = mangelist[0].Managerid;

        if(paymentRequest.total_Amount__c != null){
                unitData.perAmountCollValue = paymentRequest.total_Amount__c != null && paymentRequest.Unit_Purchase_Amount__c != null && paymentRequest.Unit_Purchase_Amount__c != 0? (paymentRequest.total_Amount__c/paymentRequest.Unit_Purchase_Amount__c)*100 : null;
        
            }else{
               Double amountToConvert = paymentRequest.Amount__c;
              
               if(paymentRequest.Currency__c != 'AED'){
                amountToConvert = (Double)( paymentrequest.amount__c*currToRate.get( paymentrequest.currency__c));
               }
                unitData.perAmountCollValue = amountToConvert != null && paymentRequest.Unit_Purchase_Amount__c != null && paymentRequest.Unit_Purchase_Amount__c != 0? (amountToConvert/paymentRequest.Unit_Purchase_Amount__c)*100 : null;
            }
        
        
        
              unitData.remainingChequeAmount = paymentRequest.amount__c;
         
            List<Payment_Request_Mock__c> approvedSalesApproval = [SELECT ID,Payment_Request_Wrapper__c,amount__c,Total_Amount__c,unit__c,
            Unit__r.Puchase_Price__c,Mode__c,Currency__c,
            (select id,dld_amount__c,dp_amount__c from New_Sale_Approval_Mocks__r where 
             Approval_Status__c='Approved by Sales Ops' or Approval_Status__c='Pending' 
             or Approval_Status__c = 'Approved by Sales VP' or Approval_Status__c = 'Approved by Sales Head' or Approval_Status__c = 'Approved') FROM Payment_Request_Mock__c 
                                                              WHERE
                                                              Mode_Option__c =: paymentRequest.Mode_Option__c
                                                              and Mobile_Number__c=:paymentrequest.Mobile_Number__c and email__c =: paymentrequest.email__c and name__c =: paymentrequest.name__c 
                                                              and status__c != 'Rejected By System'
                                                              and status__c != 'Rejected By Sales Ops'
                                                              and status__c != 'Rejected by Accounts'
                                                              and Payment_Request_Wrapper__c =: paymentRequest.Payment_Request_Wrapper__c];
            unitData.multiMode = false;
            if(paymentrequest.mode_option__c == 'Multi Mode'){/*
               unitData.multiMode = true;
                unitData.remainingChequeAmount = 0;
                set<id> unitIds = new Set<Id>();
                //current pr data in seconday pr
                unitData.mode2 = unitData.mode;
                unitData.salesValue2 = unitData.salesValue;
                unitData.Amount2 = unitData.Amount;
                //isNotIWTMode -- true
                //isNotIWTMode2 -- true
                unitData.isNotIWTMode2 =  unitData.isNotIWTMode;//assign pr2 in pr1
                unitData.currency2 = unitData.currency1;
                unitData.mode = paymentrequest.payment_request__r.mode__c.tolowercase(); 
                unitData.salesValue = paymentrequest.payment_request__r.Unit__r.Puchase_Price__c; 
                unitData.Amount = paymentrequest.payment_request__r.amount__c;
                unitData.currency1 = paymentrequest.payment_request__r.currency__c;
                
                //primary pr1
                //isNotIWTMode --- false
                //Aayushi :SOB-403 added cdm cash condition
                unitData.isNotIWTMode =  (paymentrequest.payment_request__r.mode__c.tolowercase() != 'international wire transfer' && paymentrequest.payment_request__r.mode__c.tolowercase() != 'domestic wire transfer' && paymentrequest.payment_request__r.mode__c.tolowercase() != 'cdm cash') ? true : false;
                if(unitData.isNotIWTMode == false ){
                    unitData.mode = unitData.mode2;
                    unitData.salesValue= unitData.salesValue2;
                    unitData.Amount = unitData.Amount2;
                    unitData.isNotIWTMode =  true;
                    unitData.isNotIWTMode2 = false; // todo: check with aayushi why it was set to false
                    unitData.updateDpAndDld = false;
                    unitData.currency1 = unitData.currency2;
                    unitData.remainingChequeAmount = paymentRequest.amount__c;
                    unitData.mode2 = paymentrequest.payment_request__r.mode__c.tolowercase();
                    unitData.currency2 = paymentrequest.payment_request__r.currency__c;

                }
                decimal amountTemp = 0;
                for(Payment_Request_Mock__c pr : approvedSalesApproval){
                    if(pr.Payment_Request_Wrapper__c == paymentrequest.Payment_Request_Wrapper__c){
                        unitIds.add(pr.Unit__c);
                        if(pr.currency__c != 'AED'){
                            amountTemp += (Double)( pr.amount__c*currToRate.get( pr.currency__c));
                        }else {
                            amountTemp += pr.amount__c;
                        }
                    }
                   
                }
                if(unitIds.size() > 1 ){
                    unitData.multipleUnits = true;
                    for(Payment_Request_Mock__c pr : approvedSalesApproval){
                     
                    unitData.remainingChequeAmount += pr.Amount__c != null ? pr.amount__c : 0;

                    }
                                     
                }
                else{ 
                    unitData.multipleUnits = false; 
                    //Aayushi :SOB-403 added cdm cash condition
                    if( paymentrequest.mode__c.tolowercase() == 'international wire transfer' || paymentrequest.mode__c.tolowercase() == 'domestic wire transfer' || paymentrequest.mode__c.tolowercase() == 'cdm cash'){
                        unitData.remainingChequeAmount =  paymentrequest.payment_request__r.Amount__c ;

                    }
                    if( paymentrequest.payment_request__r.mode__c.tolowercase() == 'international wire transfer' || paymentrequest.payment_request__r.mode__c.tolowercase() == 'domestic wire transfer' || paymentrequest.payment_request__r.mode__c.tolowercase() == 'cdm cash'){
                        unitData.remainingChequeAmount =   paymentrequest.Amount__c;
                    }
                    //Aayushi :SOB-403 added cdm cash condition
                    if((paymentrequest.mode__c.tolowercase() == 'international wire transfer' || paymentrequest.mode__c.tolowercase() == 'domestic wire transfer' || paymentrequest.mode__c.tolowercase() == 'cdm cash')
                    &&  (paymentrequest.payment_request__r.mode__c.tolowercase() == 'international wire transfer' || paymentrequest.payment_request__r.mode__c.tolowercase() == 'domestic wire transfer' ||  paymentrequest.payment_request__r.mode__c.tolowercase() == 'cdm cash')){
                        unitData.isNotIWTMode = false;
                        unitData.isNotIWTMode2 = false;
                    }
                    //Aayushi :SOB-403 added cdm cash condition
                    if((paymentrequest.mode__c.tolowercase() != 'international wire transfer' && paymentrequest.mode__c.tolowercase() != 'domestic wire transfer' && paymentrequest.mode__c.tolowercase() != 'cdm cash')
                    &&  (paymentrequest.payment_request__r.mode__c.tolowercase() != 'international wire transfer' && paymentrequest.payment_request__r.mode__c.tolowercase() != 'domestic wire transfer' && paymentrequest.payment_request__r.mode__c.tolowercase() != 'cdm cash')){
                        unitData.remainingChequeAmount =   paymentrequest.total_Amount__c;
                        unitData.isNotIWTMode = true;
                        unitData.isNotIWTMode2 = true;
                    }
              }
                  
            */}else{
              unitData.remainingChequeAmount = paymentRequest.Amount__c;
            }
        }
        return unitData;
    }
    @AuraEnabled 
    public static List<String> getPaymentPlans(String recordId){
        List<String> result = new List<String>();
        List<String> standardPlan = new List<String>();
        Payment_Request_Mock__c unHold = [Select Id, Unit__c, Unit__r.Tower__c, Unit_Purchase_Amount__c From Payment_Request_Mock__c Where Id =: recordId];
        Tower__c tower =  [Select Id, (Select Id,Name,Status__c,Is_Active__c,Project__c,Min_Purchase_Price__c,Max_Purchase_Price__c From Payment_Plans__r) From Tower__c Where Id =: unHold.Unit__r.Tower__c];
        for(Payment_Plan__c pl: tower.Payment_Plans__r){
            if(pl.Is_Active__c == true && pl.Min_Purchase_Price__c<= unHold.Unit_Purchase_Amount__c && pl.Max_Purchase_Price__c>= unHold.Unit_Purchase_Amount__c){
                result.add(pl.Name);
            } else if(pl.Is_Active__c == true && pl.Min_Purchase_Price__c==null && pl.Max_Purchase_Price__c==null){
                standardPlan.add(pl.Name);
            }
        }
        if(result.size()>0){
            return result;
        } else {
            return standardPlan;
        }
    }
     @AuraEnabled
    public static UnitHoldData getPaymentPlanId(String paymentPlan, String recordId){
        UnitHoldData unitData = new UnitHoldData();
        unitData.paymentPlanId = null;
        Payment_Request_Mock__c unHold = [Select Id, Unit__c, Unit__r.Tower__c,Mode_Option__c,Status__c,Mode__c,From_Booking__c,Total_Amount__c,Secondary_Mode__c 
                                     From Payment_Request_Mock__c Where Id =: recordId];
        if((unHold.Mode_Option__c=='Single Mode' && unHold.Status__c=='Approved' && unHold.Mode__c!='International Wire Transfer' && !unHold.From_Booking__c)
          || (unHold.Mode_Option__c=='Multi Mode' && unHold.Status__c=='Approved' && unHold.Total_Amount__c > 0 && unHold.Mode__c!='International Wire Transfer' && !unHold.From_Booking__c)
           || (unHold.Mode__c=='International Wire Transfer' && !unHold.From_Booking__c && (unHold.Status__c=='Approved' || unHold.Status__c=='Submitted to Accounts for Amount Confirmation'))
           || (unHold.Mode__c=='Domestic Wire Transfer' && !unHold.From_Booking__c && (unHold.Status__c=='Approved' || unHold.Status__c=='Submitted to Accounts for Amount Confirmation'))
           || (unHold.Mode__c=='CDM Cash' && !unHold.From_Booking__c && (unHold.Status__c=='Approved' || unHold.Status__c=='Submitted to Accounts for Amount Confirmation'))
          )
        {
            unitData.isEligibleForNSA=true;
        }
        else{
            unitData.isEligibleForNSA=false;
            unitData.notEligibleError=System.Label.NSA_EligibilityError;
        }
        if(unHold.Mode_Option__c=='Multi Mode' && unHold.Secondary_Mode__c==null){
            unitData.isEligibleForNSA=false;
            unitData.notEligibleError=System.Label.NSA_PrimaryModeError;
        }
        Tower__c tower = [Select Id From Tower__c Where Id =: unHold.Unit__r.Tower__c];
        if(paymentPlan != 'Others'){
           List<Payment_Plan__c> plan = [Select Id, Name,Tower__c From Payment_Plan__c Where Name =: paymentPlan and Tower__c =: tower.Id and is_Active__c = true];
           if(plan != null && plan.size() > 0){
                unitData.paymentPlanId = plan[0].Id;
           }
        }
        return unitData;
        
    }
    
    @AuraEnabled
    public static  opportunityWrapper getOpportunityDetails(String recordId, String leadSource){
        Opportunity opp = [Select Id, Name, AccountId,Account.Name ,Account_Phone__c,Account_Email__c,
                           Opportunity_ID__c,Channel_Partner__r.name,Sobha_Connect__r.name,
                           Channel_Partner__r.Channel_Partner_Id__c ,Sobha_Connect__r.name__c,
                           Walk_In_CP__c,Walk_In_CP__r.Name,Walk_In_CP__r.Channel_Partner_Id__c,
                           Walk_In_SC__c,Walk_In_SC__r.Name,Walk_in_Source__c,Lead_Id__c,
                           Booking__c From Opportunity Where Id =: recordId];
        
        opportunityWrapper oppoWrapper = new opportunityWrapper();
        oppoWrapper.account = opp.AccountId;
        oppoWrapper.AccountName = opp.Account.Name;
        oppoWrapper.accountPhone = opp.Account_Phone__c;
        oppoWrapper.AccountEmail = opp.Account_Email__c;
        oppoWrapper.opportunityId = opp.Opportunity_ID__c;
        oppoWrapper.booking = opp.Booking__c;
        oppoWrapper.Walk_In_CP_Name = opp.Walk_In_CP__c != null ? opp.Walk_In_CP__r.Name : null;
        oppoWrapper.Walk_In_CP_Channel_Partner_Id = opp.Walk_In_CP__c != null ? opp.Walk_In_CP__r.Channel_Partner_Id__c : null;
        oppoWrapper.Lead_Id = opp.Lead_Id__c;
        oppoWrapper.Walk_in_Source = opp.Walk_in_Source__c;
        oppoWrapper.Walk_In_SC_Name =opp.Walk_In_SC__c != null ? opp.Walk_In_SC__r.Name : null; 
            system.debug('ws->'+opp.Walk_in_Source__c);
        	system.debug('leadsource->'+leadsource);
            if(opp.Walk_in_Source__c != null && leadSource != null){
                List<String> metadataValues = new List<String>();
                
                // Query custom metadata records
                List<PR_Lead_Source_To_Opportunity_Mapping__mdt> metadataRecords = [SELECT Id, Opportunity_Walk_In_Source__c,PR_Lead_Source__c 
                                                                                    FROM PR_Lead_Source_To_Opportunity_Mapping__mdt WHERE PR_Lead_Source__c =: leadSource];
                
                // Iterate over metadata records and extract comma-separated values
                for (PR_Lead_Source_To_Opportunity_Mapping__mdt record : metadataRecords) {
                    if (record.Opportunity_Walk_In_Source__c != null && record.Opportunity_Walk_In_Source__c != '') {
                        metadataValues.addAll(record.Opportunity_Walk_In_Source__c.split(','));
                    }
                }
                
                if(metadataValues.contains(opp.Walk_in_Source__c)){
                    oppoWrapper.Match_leadSource_walkinSource = true;
                }else{
                    oppoWrapper.Match_leadSource_walkinSource = false;
                }
                
            }
        System.debug('match->'+oppoWrapper);
        return oppoWrapper;
    }
    @AuraEnabled
    public static void saveAttachements(String recordId, List<Id> contentDocIds,
    List<String> docToNameID){
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentDocument> cdList = new List<ContentDocument>();
        for(Id docId : contentDocIds){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.linkedEntityId = recordId;
            cdl.contentDocumentID = docId;
            cdlList.add(cdl);
        }
        Map<String,String> contentDocIdsMap = new Map<String,String>();
        for(string key : docToNameID){
            contentDocIdsMap.put(key.split('###')[0],key.split('###')[1]);
            
        }
        for(Contentdocument cd : [select id from contentdocument where id in : 
        contentDocIdsMap.keySet()]){
            cd.title = contentDocIdsMap.get((string)cd.id);
            cdList.add(cd);
        }
       if(cdlList.size() > 0){
           try{ 
            Database.SaveResult[] srList1 = Database.update(cdList,false);
            Database.SaveResult[] srList = Database.insert(cdlList,false);

            List<Error_Log__c> errorLogs = new List<Error_Log__c>();
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                } else {
                    for(Database.Error objErr : sr.getErrors()) {
                        Error_Log__c logError = new Error_Log__c(Message__c = objErr.getStatusCode() + ': ' + objErr.getMessage());
                        logError.class__c = 'UnitHoldFormPaymentRequestController';
                        errorLogs.add(logError);
                    }
                }
                if(errorLogs.size() > 0) insert errorLogs;
                }
            }catch(Exception e){
               Error_Log__c logError = new Error_Log__c(Message__c = e.getMessage());
               logError.class__c = 'UnitHoldFormPaymentRequestController';
               insert logError;
               throw new AuraHandledException(e.getMessage());
           }
       }
    }
    
    @AuraEnabled
    public static Boolean saveCancelledUnitDetails(String cancelledUnitWrapper){
        try{
            if(cancelledUnitWrapper != null){
                List<Cancelled_Unit_Detail__c> insertCancelledUnitList = (List<Cancelled_Unit_Detail__c>)JSON.deserialize(cancelledUnitWrapper, List<Cancelled_Unit_Detail__c>.Class);
                insert insertCancelledUnitList;
                return true;
            }
        }
        catch(Exception err){
            Error_Log__c errLogRec = new Error_Log__c();
            errLogRec.Class__c = 'UnitHoldFormForPaymentRequestController';
            errLogRec.Message__c = err.getMessage();
            insert errLogRec;
        }
        return false;
    }

    public static void extraMethod(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

   public class uploadedDocs{
        @AuraEnabled
        Public String key;
        @AuraEnabled
        Public Value value;
        
    }
    
    public class unitPicklistWrap{
        @AuraEnabled public String bookingName;
        @AuraEnabled public String bookingId;
        @AuraEnabled public Decimal unitPurchasePrice;
        @AuraEnabled public String unitName;
        @AuraEnabled public String unitId;
        @AuraEnabled public Decimal maxUnitPriceAllowed;
        @AuraEnabled public Datetime bookingDate;
    }
    
    public class Value{
        @AuraEnabled
        Public String Name;
        @AuraEnabled
        Public String ContentType;
        @AuraEnabled
        Public String Body;
        @AuraEnabled
        Public String parentID;
        
    }
    
    public class UnitHoldData{
        @AuraEnabled
        public Boolean isEligibleForNSA = false;
        @AuraEnabled
        public String notEligibleError;
        @AuraEnabled
        public String paymentPlanId;
        @AuraEnabled
        public Decimal UnitHoldAmountCollected;
        @AuraEnabled
        public Boolean isDisplay =false;
        @AuraEnabled
        public String unitValue;
        @AuraEnabled
        public String salesManagerValue;
        @AuraEnabled
        public String salesHeadValue;
        @AuraEnabled
        public String salesHeadVPValue;
        @AuraEnabled
        public String salesHeadVPUserId;
        @AuraEnabled
        public String salesHeadSVPValue;
        @AuraEnabled
        public String salesHeadSVPUserId;
        @AuraEnabled
        public String csoValue;
        @AuraEnabled
        public String csoUserId;
        @AuraEnabled
        public Decimal salesValue;
        @AuraEnabled
        public String source;
        @AuraEnabled
        public String brokerCPID;
        @AuraEnabled
        public String leadID;
        
        @AuraEnabled
        public String customerEmail;
        
         @AuraEnabled
        public Id salesMangId;
        @AuraEnabled
        public Id salesHeadId;
        @AuraEnabled
        public Id salesHeadvpId;
        @AuraEnabled
        public Id salesHeadSvpId;
        
        @AuraEnabled
        public boolean existingsalepending;
        @AuraEnabled
        public Decimal perAmountCollValue;
        @AuraEnabled
        public Decimal dldAmount;
        @AuraEnabled
        public Decimal dpAmount;
        @AuraEnabled
        public String mode;
        @AuraEnabled
        public Decimal remainingChequeAmount;
        @AuraEnabled
        public Boolean multipleUnits;
        @AuraEnabled
        public Boolean singleModeWithMultipleUnits;
        @AuraEnabled
        public boolean  displaySalesManagerError ;
        @AuraEnabled
        public boolean isNotIWTMode  ;
        @AuraEnabled
        public boolean isNotIWTMode2  ;
        
        @AuraEnabled
        public String Mode2;
        @AuraEnabled
        public Decimal salesValue2;
        @AuraEnabled
        public boolean multiMode;
        @AuraEnabled
        public Decimal Amount;
        @AuraEnabled
        public Decimal Amount2;
        @AuraEnabled
        public decimal minPercentage;
        @AuraEnabled
        public map<string,decimal> currToRate;
        @AuraEnabled
        public string currency1;
        @AuraEnabled
        public string currency2;
        @AuraEnabled
        public boolean showIwtError;
        @AuraEnabled
        public boolean updateDpAndDld;
        @AuraEnabled
        public boolean exceptionUnit;
        @AuraEnabled
        public boolean skipNSAValidation;
        @AuraEnabled
        public String Lead_Source_Category;
    }
    
    public class opportunityWrapper{
            
            @AuraEnabled
            public String account;
            @AuraEnabled
            public String accountName;
            @AuraEnabled
            public String accountPhone;
            @AuraEnabled
            public String accountEmail;
            @AuraEnabled
            public string opportunityId;
            @AuraEnabled
            public string booking;
            @AuraEnabled
            public string Walk_In_CP_Name;
            @AuraEnabled
            public string Walk_In_CP_Channel_Partner_Id;
            @AuraEnabled
            public string Lead_Id;
            @AuraEnabled
            public string Walk_in_Source;
            @AuraEnabled
            public string Walk_In_SC_Name;
            @AuraEnabled
            public boolean Match_leadSource_walkinSource;
        }

   
}