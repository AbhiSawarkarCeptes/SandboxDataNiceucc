public class CollectionDashboardManagementController {
    @AuraEnabled
    public static list<string> getYearList(){
        set<string> yearList = new set<string>();
        
        Integer nextYear = system.today().year() + 1;

        Date maxDate = Date.newInstance(nextYear, 12, 31);

        List<Payment_Milestones__c> pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c, Quotation__c, Quotation__r.Booking__c, 
                                        Quotation__r.Unit__r.Project__c,Quotation__r.Unit__r.Tower__r.Cluster__c from Payment_Milestones__c WHERE 
                                        Quotation__c != null AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Status__c = 'Processed' AND Milestone_Due_Date__c != null AND 
                                        (Milestone_Due_Date__c > TODAY AND Milestone_Due_Date__c <= :maxDate)
                                        AND Quotation__r.Booking__r.Unit__r.Project__r.Name != 'Underwriting' AND Quotation__r.Unit__c != null ORDER BY Milestone_Due_Date__c ASC];
        for(Payment_Milestones__c p : pmList){
            Date dueDate = p.Milestone_Due_Date__c;
            string dueDateYear = string.valueOf(dueDate.year());
            yearList.add(dueDateYear);
        }
        return new List<String>(yearList);
    }

    @AuraEnabled
    public static list<AllWrapper> getAllTabData(string type, string recordId){
        map<string,AllWrapper> dataMap = new map<string,AllWrapper>();
        map<string,AllWrapper> tempDataMap = new map<string,AllWrapper>();
        
        Integer nextYear = system.today().year() + 1;

        Date maxDate = Date.newInstance(nextYear, 12, 31);
        if(type == 'Project'){
            set<string> yearList = new set<string>();
            AllWrapper wrapAll = new AllWrapper();

            map<string,long> projectToFutureDuesNew = new map<string,long>();

            list<Unit__c> unitList = new list<Unit__c>();

            unitList = [SELECT Id, Puchase_Price__c, Project__c, Project__r.Name, Booking__c, Booking__r.Agreement_Value__c, 
                        Booking__r.Total_Agreement_Value_Demanded__c, Booking__r.Total_On_Account_Money_With_Registration__c, 
                        Booking__r.Milestone_Due_Till_Date__c, Booking__r.Due_Payments__c, Booking__r.Advance_Payments__c, 
                        Investor_Unit__c, Booking__r.Status__c, Booking__r.Current_Status__c FROM Unit__c 
                        WHERE Project__c != null AND Project__r.Name != 'Underwriting' AND ((Booking__c != null AND Booking__r.Status__c != 'Cancelled') OR (Investor_Unit__c = true)) ];

            System.debug('unitList -> '+unitList.size());

            for(Unit__c b : unitList){
                if(tempDataMap.containsKey(b.Project__c)){
                    AllWrapper wrap = tempDataMap.get(b.Project__c);
                    if(b.Booking__c != null && b.Booking__r.Status__c != 'Cancelled' ){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.Booking__r.Agreement_Value__c!=null)?(wrap.totalPurchasePrice + (Long)b.Booking__r.Agreement_Value__c):wrap.totalPurchasePrice;
                        wrap.totalMilestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c!=null)?(wrap.totalMilestoneDueTillDate + (Long)b.Booking__r.Milestone_Due_Till_Date__c):wrap.totalMilestoneDueTillDate;
                        wrap.totalCollectedAmount = (b.Booking__r.Total_On_Account_Money_With_Registration__c!=null)?(wrap.totalCollectedAmount + (Long)b.Booking__r.Total_On_Account_Money_With_Registration__c):wrap.totalCollectedAmount;
                        Long totalonaacmony = ((b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? ((Long)b.Booking__r.Total_On_Account_Money_With_Registration__c) : 0);
                        Long mduetilldate = b.Booking__r.Milestone_Due_Till_Date__c != null ? (Long)b.Booking__r.Milestone_Due_Till_Date__c : 0;
                        wrap.DueAmount = (mduetilldate >= totalonaacmony)? (wrap.DueAmount + (mduetilldate - totalonaacmony)) : wrap.DueAmount;
                        wrap.advanceAmount = ((totalonaacmony - mduetilldate) >= 0 ? (wrap.advanceAmount + (totalonaacmony - mduetilldate)) : (wrap.advanceAmount));
                        
                        long milestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c != null) ? (long)b.Booking__r.Milestone_Due_Till_Date__c : 0; 
                        long collectedAmountTillDate = (b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? (long)b.Booking__r.Total_On_Account_Money_With_Registration__c : 0;
                        long remainingAmountToPay = milestoneDueTillDate > collectedAmountTillDate ? milestoneDueTillDate : collectedAmountTillDate;
                        long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null) ? b.Booking__r.Agreement_Value__c : 0 ) - remainingAmountToPay);
                        wrap.futureCollections = wrap.futureCollections + (tempfutureAmount > 0 ? tempfutureAmount : 0);
                        tempDataMap.put(b.Project__c, wrap);
                    }
                    else if(b.Investor_Unit__c == true){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.Puchase_Price__c!=null)?(wrap.totalPurchasePrice + (Long)b.Puchase_Price__c):wrap.totalPurchasePrice;
                        wrap.totalInvestorUnitValue = (b.Puchase_Price__c!=null)?(wrap.totalInvestorUnitValue + (Long)b.Puchase_Price__c):wrap.totalInvestorUnitValue;
                        tempDataMap.put(b.Project__c, wrap);
                    }
                }
                else{
                    AllWrapper wrap = new AllWrapper();
                    wrap.projectId = b.Project__c;
                    wrap.projectName = b.Project__r.Name;
                    if(b.Booking__c != null && b.Booking__r.Status__c != 'Cancelled' ){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.Booking__r.Agreement_Value__c!=null)?(Long)b.Booking__r.Agreement_Value__c:0;
                        wrap.totalMilestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c!=null)?(Long)b.Booking__r.Milestone_Due_Till_Date__c:0;
                        wrap.totalCollectedAmount = (b.Booking__r.Total_On_Account_Money_With_Registration__c!=null)?(Long)b.Booking__r.Total_On_Account_Money_With_Registration__c:0;

                        Long totalonaacmony = ((b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? ((Long)b.Booking__r.Total_On_Account_Money_With_Registration__c) : 0);
                        Long mduetilldate = b.Booking__r.Milestone_Due_Till_Date__c != null ? (Long)b.Booking__r.Milestone_Due_Till_Date__c : 0;
                        wrap.DueAmount = (mduetilldate >= totalonaacmony)? (wrap.DueAmount + (mduetilldate - totalonaacmony)) : wrap.DueAmount;
                        wrap.advanceAmount = ((totalonaacmony - mduetilldate) >= 0 ? (wrap.advanceAmount + (totalonaacmony - mduetilldate)) : wrap.advanceAmount);                        
                        tempDataMap.put(b.Project__c, wrap);
                        long milestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c != null) ? (long)b.Booking__r.Milestone_Due_Till_Date__c : 0; 
                        long collectedAmountTillDate = (b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? (long)b.Booking__r.Total_On_Account_Money_With_Registration__c : 0;
                        long remainingAmountToPay = milestoneDueTillDate > collectedAmountTillDate ? milestoneDueTillDate : collectedAmountTillDate;
                        long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null) ? b.Booking__r.Agreement_Value__c : 0 ) - remainingAmountToPay);
                        //long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null) ? b.Booking__r.Agreement_Value__c : 0 ) - ((b.Booking__r.Milestone_Due_Till_Date__c != null) ? b.Booking__r.Milestone_Due_Till_Date__c : 0 ));
                        wrap.futureCollections = wrap.futureCollections + (tempfutureAmount > 0 ? tempfutureAmount : 0);
                    }
                    else if(b.Investor_Unit__c == true){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.Puchase_Price__c!=null)?(Long)b.Puchase_Price__c:0;
                        wrap.totalInvestorUnitValue = (b.Puchase_Price__c!=null)?(Long)b.Puchase_Price__c:0;
                        tempDataMap.put(b.Project__c, wrap);
                    }
                }

                if(b.Booking__c != null && b.Booking__r.Status__c != 'Cancelled' ){
                    wrapAll.totalUnit = wrapAll.totalUnit + 1;
                    wrapAll.totalPurchasePrice = (b.Booking__r.Agreement_Value__c!=null)?(wrapAll.totalPurchasePrice + (Long)b.Booking__r.Agreement_Value__c):wrapAll.totalPurchasePrice;
                    wrapAll.totalMilestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c!=null)?(wrapAll.totalMilestoneDueTillDate + (Long)b.Booking__r.Milestone_Due_Till_Date__c):wrapAll.totalMilestoneDueTillDate;
                    wrapAll.totalCollectedAmount = (b.Booking__r.Total_On_Account_Money_With_Registration__c!=null)?(wrapAll.totalCollectedAmount + (Long)b.Booking__r.Total_On_Account_Money_With_Registration__c):wrapAll.totalCollectedAmount;
                    Long totalonaacmony = ((b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? ((Long)b.Booking__r.Total_On_Account_Money_With_Registration__c) : 0);
                    Long mduetilldate = b.Booking__r.Milestone_Due_Till_Date__c != null ? (Long)b.Booking__r.Milestone_Due_Till_Date__c : 0;
                    long milestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c != null) ? (long)b.Booking__r.Milestone_Due_Till_Date__c : 0; 
                    long collectedAmountTillDate = (b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? (long)b.Booking__r.Total_On_Account_Money_With_Registration__c : 0;
                    long remainingAmountToPay = milestoneDueTillDate > collectedAmountTillDate ? milestoneDueTillDate : collectedAmountTillDate;
                    long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null) ? b.Booking__r.Agreement_Value__c : 0 ) - remainingAmountToPay);
                    //long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null) ? b.Booking__r.Agreement_Value__c : 0 ) - ((b.Booking__r.Milestone_Due_Till_Date__c != null) ? b.Booking__r.Milestone_Due_Till_Date__c : 0 ));
                    wrapAll.futureCollections = wrapAll.futureCollections + (tempfutureAmount > 0 ? tempfutureAmount : 0);

                }
                else if(b.Investor_Unit__c == true){
                    wrapAll.totalUnit = wrapAll.totalUnit + 1;
                    wrapAll.totalPurchasePrice = (b.Puchase_Price__c!=null)?(wrapAll.totalPurchasePrice + (Long)b.Puchase_Price__c):wrapAll.totalPurchasePrice;
                    wrapAll.totalInvestorUnitValue = (b.Puchase_Price__c!=null)?(wrapAll.totalInvestorUnitValue + (Long)b.Puchase_Price__c):wrapAll.totalInvestorUnitValue;
                }
            }

            wrapAll.projectId = 'All';
            wrapAll.projectName = 'All';

            long allFutureCollections = 0;
            long allDueAMOUNT = 0;
            long allAdvaceAMOUNT = 0;
            long allFutureAMOUNT = 0;
            
            wrapAll.futureCollections = allFutureCollections;
            dataMap.put('All', wrapAll);
            for(string projectId : tempDataMap.keySet()){
                AllWrapper w = tempDataMap.get(projectId);
                w.totalDueAmount = w.DueAmount;
                allDueAMOUNT += w.totalDueAmount;
                allAdvaceAMOUNT += w.advanceAmount;
                allFutureAMOUNT += w.futureCollections;
                w.totalAdvanceAmount = w.advanceAmount;
                //w.futureCollections = allFutureAMOUNT;
                dataMap.put(projectId,w);
            }
            wrapAll.futureCollections = allFutureAMOUNT;
            wrapAll.totalDueAmount = allDueAMOUNT;
            wrapAll.totalAdvanceAmount = allAdvaceAMOUNT;
        }
        else if(type == 'SubProject'){
            set<string> yearList = new set<string>();
            map<string,long> projectToFutureDuesNew = new map<string,long>();

            list<Unit__c> unitList = new list<Unit__c>();
            if(recordId == 'All'){
                unitList = [SELECT Id, Tower__r.Cluster__c, Tower__r.Cluster__r.Name, Puchase_Price__c, Project__c, Project__r.Name, Booking__c, Booking__r.Agreement_Value__c, 
                        Booking__r.Total_Agreement_Value_Demanded__c, Booking__r.Total_On_Account_Money_With_Registration__c,Booking__r.Name,
                        Booking__r.Milestone_Due_Till_Date__c, Booking__r.Due_Payments__c, Booking__r.Advance_Payments__c, 
                        Tower__r.Cluster__r.sequence__c,Tower__r.Cluster__r.Section__c,Tower__r.Cluster__r.Ongoing_Project__c,
                        Investor_Unit__c, Booking__r.Status__c, Booking__r.Current_Status__c FROM Unit__c 
                        WHERE Project__c != null AND Project__r.Name != 'Underwriting' AND Tower__c != null AND Tower__r.Cluster__c != null 
                        ORDER BY Tower__r.Cluster__r.sequence__c ASC ];
            }
            else{
                unitList = [SELECT Id, Tower__r.Cluster__c, Tower__r.Cluster__r.Name, Puchase_Price__c, Project__c, Project__r.Name, Booking__c, Booking__r.Agreement_Value__c, 
                        Booking__r.Total_Agreement_Value_Demanded__c, Booking__r.Total_On_Account_Money_With_Registration__c,Booking__r.Name,
                        Booking__r.Milestone_Due_Till_Date__c, Booking__r.Due_Payments__c, Booking__r.Advance_Payments__c, 
                        Tower__r.Cluster__r.sequence__c,Tower__r.Cluster__r.Section__c,Tower__r.Cluster__r.Ongoing_Project__c,
                        Investor_Unit__c, Booking__r.Status__c, Booking__r.Current_Status__c from Unit__c 
                        WHERE Project__c =: recordId AND Project__r.Name != 'Underwriting' AND Project__c != null AND Tower__c != null AND Tower__r.Cluster__c != null 
                        ORDER BY Tower__r.Cluster__r.sequence__c ASC ];
            }

            for(Unit__c b : unitList){
                if(tempDataMap.containsKey(b.Tower__r.Cluster__c)){
                    AllWrapper wrap = tempDataMap.get(b.Tower__r.Cluster__c);
                    if(b.Booking__c != null && b.Booking__r.Status__c != 'Cancelled' ){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.Booking__r.Agreement_Value__c!=null)?(wrap.totalPurchasePrice + (Long)b.Booking__r.Agreement_Value__c):wrap.totalPurchasePrice;
                        wrap.totalMilestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c!=null)?(wrap.totalMilestoneDueTillDate + (Long)b.Booking__r.Milestone_Due_Till_Date__c):wrap.totalMilestoneDueTillDate;
                        wrap.totalCollectedAmount = (b.Booking__r.Total_On_Account_Money_With_Registration__c!=null)?(wrap.totalCollectedAmount + (Long)b.Booking__r.Total_On_Account_Money_With_Registration__c):wrap.totalCollectedAmount;
                        
                        Long totalonaacmony = ((b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? ((Long)b.Booking__r.Total_On_Account_Money_With_Registration__c) : 0);
                        Long mduetilldate = b.Booking__r.Milestone_Due_Till_Date__c != null ? (Long)b.Booking__r.Milestone_Due_Till_Date__c : 0;
                        long milestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c != null) ? (long)b.Booking__r.Milestone_Due_Till_Date__c : 0; 
                        long collectedAmountTillDate = (b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? (long)b.Booking__r.Total_On_Account_Money_With_Registration__c : 0;
                        long remainingAmountToPay = milestoneDueTillDate > collectedAmountTillDate ? milestoneDueTillDate : collectedAmountTillDate;
                        long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null) ? b.Booking__r.Agreement_Value__c : 0 ) - remainingAmountToPay);
                        //long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null && b.Booking__r.Agreement_Value__c > 0) ? b.Booking__r.Agreement_Value__c : 0 ) - ((b.Booking__r.Milestone_Due_Till_Date__c != null && b.Booking__r.Milestone_Due_Till_Date__c > 0) ? b.Booking__r.Milestone_Due_Till_Date__c : 0 ));
                        wrap.futureCollections = wrap.futureCollections + (tempfutureAmount > 0 ? tempfutureAmount : 0);

                        wrap.DueAmount = (mduetilldate >= totalonaacmony)? (wrap.DueAmount + (mduetilldate - totalonaacmony)) : wrap.DueAmount;
                        wrap.advanceAmount = ((totalonaacmony - mduetilldate) >= 0 ? (wrap.advanceAmount + (totalonaacmony - mduetilldate)) : (wrap.advanceAmount));
                        tempDataMap.put(b.Tower__r.Cluster__c, wrap);
                    }
                    else if(b.Investor_Unit__c == true){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.Puchase_Price__c!=null)?(wrap.totalPurchasePrice + (Long)b.Puchase_Price__c):wrap.totalPurchasePrice;
                        wrap.totalInvestorUnitValue = (b.Puchase_Price__c!=null)?(wrap.totalInvestorUnitValue + (Long)b.Puchase_Price__c):wrap.totalInvestorUnitValue;
                        tempDataMap.put(b.Tower__r.Cluster__c, wrap);
                    }
                }
                else{
                    AllWrapper wrap = new AllWrapper();
                    wrap.subProjectId = b.Tower__r.Cluster__c;
                    wrap.subProjectName = b.Tower__r.Cluster__r.Name;
                    wrap.isOngoing = b.Tower__r.Cluster__r.Ongoing_Project__c;
                    wrap.section = b.Tower__r.Cluster__r.Section__c;
                    if(b.Booking__c != null && b.Booking__r.Status__c != 'Cancelled' ){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.Booking__r.Agreement_Value__c!=null)?(Long)b.Booking__r.Agreement_Value__c:0;
                        wrap.totalMilestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c!=null)?(Long)b.Booking__r.Milestone_Due_Till_Date__c:0;
                        wrap.totalCollectedAmount = (b.Booking__r.Total_On_Account_Money_With_Registration__c!=null)?(Long)b.Booking__r.Total_On_Account_Money_With_Registration__c:0;
                        
                        Long totalonaacmony = ((b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? ((Long)b.Booking__r.Total_On_Account_Money_With_Registration__c) : 0);
                        Long mduetilldate = b.Booking__r.Milestone_Due_Till_Date__c != null ? (Long)b.Booking__r.Milestone_Due_Till_Date__c : 0;
                        long milestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c != null) ? (long)b.Booking__r.Milestone_Due_Till_Date__c : 0; 
                        long collectedAmountTillDate = (b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? (long)b.Booking__r.Total_On_Account_Money_With_Registration__c : 0;
                        long remainingAmountToPay = milestoneDueTillDate > collectedAmountTillDate ? milestoneDueTillDate : collectedAmountTillDate;
                        long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null) ? b.Booking__r.Agreement_Value__c : 0 ) - remainingAmountToPay);
                        //long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null && b.Booking__r.Agreement_Value__c > 0) ? b.Booking__r.Agreement_Value__c : 0 ) - ((b.Booking__r.Milestone_Due_Till_Date__c != null && b.Booking__r.Milestone_Due_Till_Date__c > 0) ? b.Booking__r.Milestone_Due_Till_Date__c : 0 ));
                        wrap.futureCollections = wrap.futureCollections + (tempfutureAmount > 0 ? tempfutureAmount : 0);

                        wrap.DueAmount = (mduetilldate >= totalonaacmony)? (wrap.DueAmount + (mduetilldate - totalonaacmony)) : wrap.DueAmount;
                        wrap.advanceAmount = ((totalonaacmony - mduetilldate) >= 0 ? (totalonaacmony - mduetilldate) : wrap.advanceAmount);     
                        tempDataMap.put(b.Tower__r.Cluster__c, wrap);
                    }
                    else if(b.Investor_Unit__c == true){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.Puchase_Price__c!=null)?(Long)b.Puchase_Price__c:0;
                        wrap.totalInvestorUnitValue = (b.Puchase_Price__c!=null)?(Long)b.Puchase_Price__c:0;
                        tempDataMap.put(b.Tower__r.Cluster__c, wrap);
                    }
                }
            }
            
            for(string subProjectId : tempDataMap.keySet()){
                AllWrapper w = tempDataMap.get(subProjectId);
                w.totalDueAmount = w.DueAmount;
                w.totalAdvanceAmount = w.advanceAmount;
                w.futureCollections = w.futureCollections;
                dataMap.put(subProjectId,w);
            }
        }
        else if(type == 'Tower'){
            set<string> yearList = new set<string>();

            list<Unit__c> unitList = new list<Unit__c>();
            unitList = [SELECT Id, Tower__c, Tower__r.Name, Tower__r.Cluster__c, Tower__r.Cluster__r.Name, Puchase_Price__c, Project__c, Project__r.Name, Booking__c, Booking__r.Agreement_Value__c, 
                        Booking__r.Total_Agreement_Value_Demanded__c, Booking__r.Total_On_Account_Money_With_Registration__c, Booking__r.Name,
                        Booking__r.Milestone_Due_Till_Date__c, Booking__r.Due_Payments__c, Booking__r.Advance_Payments__c, 
                        Investor_Unit__c, Booking__r.Status__c, Booking__r.Current_Status__c FROM Unit__c 
                        WHERE Tower__r.Cluster__c =: recordId AND  Project__c != null AND Project__r.Name != 'Underwriting' AND Tower__c != null 
                        AND Tower__r.Cluster__c != null ORDER BY Tower__r.sequence__c asc ];

            for(Unit__c b : unitList){
                if(tempDataMap.containsKey(b.Tower__c)){
                    AllWrapper wrap = tempDataMap.get(b.Tower__c);
                    if(b.Booking__c != null && b.Booking__r.Status__c != 'Cancelled' ){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.Booking__r.Agreement_Value__c!=null)?(wrap.totalPurchasePrice + (Long)b.Booking__r.Agreement_Value__c):wrap.totalPurchasePrice;
                        wrap.totalMilestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c!=null)?(wrap.totalMilestoneDueTillDate + (Long)b.Booking__r.Milestone_Due_Till_Date__c):wrap.totalMilestoneDueTillDate;
                        wrap.totalCollectedAmount = (b.Booking__r.Total_On_Account_Money_With_Registration__c!=null)?(wrap.totalCollectedAmount + (Long)b.Booking__r.Total_On_Account_Money_With_Registration__c):wrap.totalCollectedAmount;
                        
                        Long totalonaacmony = ((b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? ((Long)b.Booking__r.Total_On_Account_Money_With_Registration__c) : 0);
                        Long mduetilldate = b.Booking__r.Milestone_Due_Till_Date__c != null ? (Long)b.Booking__r.Milestone_Due_Till_Date__c : 0;
                        long milestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c != null) ? (Long)b.Booking__r.Milestone_Due_Till_Date__c : 0; 
                        long collectedAmountTillDate = (b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? (Long)b.Booking__r.Total_On_Account_Money_With_Registration__c : 0;
                        long remainingAmountToPay = milestoneDueTillDate > collectedAmountTillDate ? milestoneDueTillDate : collectedAmountTillDate;
                        long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null) ? b.Booking__r.Agreement_Value__c : 0 ) - remainingAmountToPay);
                        //long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null && b.Booking__r.Agreement_Value__c > 0) ? b.Booking__r.Agreement_Value__c : 0 ) - ((b.Booking__r.Milestone_Due_Till_Date__c != null && b.Booking__r.Milestone_Due_Till_Date__c > 0) ? b.Booking__r.Milestone_Due_Till_Date__c : 0 ));
                        wrap.futureCollections = wrap.futureCollections + (tempfutureAmount > 0 ? tempfutureAmount : 0);

                        wrap.DueAmount = (mduetilldate >= totalonaacmony)? (wrap.DueAmount + (mduetilldate - totalonaacmony)) : wrap.DueAmount;
                        
                        wrap.advanceAmount = ((totalonaacmony - mduetilldate) >= 0 ? (wrap.advanceAmount + (totalonaacmony - mduetilldate)) : (wrap.advanceAmount));
                        wrap.totalAdvanceAmount = ((wrap.totalCollectedAmount - wrap.totalMilestoneDueTillDate) >= 0 ? (wrap.totalCollectedAmount - wrap.totalMilestoneDueTillDate) : 0);
                        tempDataMap.put(b.Tower__c, wrap);
                    }
                    else if(b.Investor_Unit__c == true){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.Puchase_Price__c!=null)?(wrap.totalPurchasePrice + (Long)b.Puchase_Price__c):wrap.totalPurchasePrice;
                        wrap.totalInvestorUnitValue = (b.Puchase_Price__c!=null)?(wrap.totalInvestorUnitValue + (Long)b.Puchase_Price__c):wrap.totalInvestorUnitValue;
                        tempDataMap.put(b.Tower__c, wrap);
                    }
                }
                else{
                    AllWrapper wrap = new AllWrapper();
                    wrap.towerId = b.Tower__c;
                    wrap.towerName = b.Tower__r.Name;
                    if(b.Booking__c != null && b.Booking__r.Status__c != 'Cancelled' ){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.Booking__r.Agreement_Value__c!=null)?(Long)b.Booking__r.Agreement_Value__c:0;
                        wrap.totalMilestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c!=null)?(Long)b.Booking__r.Milestone_Due_Till_Date__c:0;
                        wrap.totalCollectedAmount = (b.Booking__r.Total_On_Account_Money_With_Registration__c!=null)?(Long)b.Booking__r.Total_On_Account_Money_With_Registration__c:0;
                        
                        Long totalonaacmony = ((b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? ((Long)b.Booking__r.Total_On_Account_Money_With_Registration__c) : 0);
                        Long mduetilldate = b.Booking__r.Milestone_Due_Till_Date__c != null ? (Long)b.Booking__r.Milestone_Due_Till_Date__c : 0;
                        
                        wrap.DueAmount = (mduetilldate >= totalonaacmony)? (wrap.DueAmount + (mduetilldate - totalonaacmony)) : wrap.DueAmount;
                        long milestoneDueTillDate = (b.Booking__r.Milestone_Due_Till_Date__c != null) ? (long)b.Booking__r.Milestone_Due_Till_Date__c : 0; 
                        long collectedAmountTillDate = (b.Booking__r.Total_On_Account_Money_With_Registration__c != null) ? (long)b.Booking__r.Total_On_Account_Money_With_Registration__c : 0;
                        long remainingAmountToPay = milestoneDueTillDate > collectedAmountTillDate ? milestoneDueTillDate : collectedAmountTillDate;
                        long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null) ? b.Booking__r.Agreement_Value__c : 0 ) - remainingAmountToPay);
                        //long tempfutureAmount = (long)(((b.Booking__r.Agreement_Value__c != null && b.Booking__r.Agreement_Value__c > 0) ? b.Booking__r.Agreement_Value__c : 0 ) - ((b.Booking__r.Milestone_Due_Till_Date__c != null && b.Booking__r.Milestone_Due_Till_Date__c > 0) ? b.Booking__r.Milestone_Due_Till_Date__c : 0 ));
                        wrap.futureCollections = wrap.futureCollections + (tempfutureAmount > 0 ? tempfutureAmount : 0);

                        wrap.advanceAmount = ((totalonaacmony - mduetilldate) >= 0 ? (wrap.advanceAmount + (totalonaacmony - mduetilldate)) : wrap.advanceAmount);

                        wrap.totalAdvanceAmount = ((wrap.totalCollectedAmount - wrap.totalMilestoneDueTillDate) >= 0 ? (wrap.totalCollectedAmount - wrap.totalMilestoneDueTillDate) : 0);

                        tempDataMap.put(b.Tower__c, wrap);
                    }
                    else if(b.Investor_Unit__c == true){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.Puchase_Price__c!=null)?(Long)b.Puchase_Price__c:0;
                        wrap.totalInvestorUnitValue = (b.Puchase_Price__c!=null)?(Long)b.Puchase_Price__c:0;
                        tempDataMap.put(b.Tower__c, wrap);
                    }
                }
            }
            for(string subProjectId : tempDataMap.keySet()){
                AllWrapper w = tempDataMap.get(subProjectId);
                
                w.totalDueAmount = w.DueAmount;
                w.totalAdvanceAmount = w.advanceAmount;
                w.futureCollections = w.futureCollections;

                Long collectedInvestorVal = w.totalCollectedAmount + w.totalInvestorUnitValue;

                dataMap.put(subProjectId,w);
            }
        }else if(type == 'Unit'){
            map<string, list<Payment_Milestones__c>> bookingToPM = new map<string, list<Payment_Milestones__c>>();
            List<Booking__c> bookingList = [SELECT Id,Unit__r.Tower__r.Due_Payments__c,Unit__r.Tower__r.Advance_Payments__c,Unit__c,Unit__r.Name,Unit__r.Tower__c, 
                                            Unit__r.Tower__r.Name, Unit__r.Tower__r.Cluster__c,Unit__r.Tower__r.Cluster__r.Name,Unit__r.Project__c,Unit__r.Project__r.Name,Agreement_Value__c, Total_Agreement_Value_Demanded__c, 
                                            Total_On_Account_Money_With_Registration__c, Milestone_Due_Till_Date__c, Due_Payments__c, Advance_Payments__c FROM Booking__c 
                                            WHERE Status__c != 'Cancelled' AND Unit__r.Project__r.Name != 'Underwriting' AND Unit__r.Tower__c =: recordId AND Unit__r.Tower__c != null  ];

            List<Payment_Milestones__c> pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c, Quotation__c, Quotation__r.Booking__c 
                                                  from Payment_Milestones__c WHERE 
                                                  Quotation__c != null AND Milestone_Due_Date__c != null AND 
                                                  (Milestone_Due_Date__c > TODAY AND Milestone_Due_Date__c <= :maxDate)
                                                  AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Status__c = 'Processed' AND Quotation__r.Booking__c IN: bookingList 
                                                  AND Quotation__r.Booking__r.Unit__r.Project__r.Name != 'Underwriting' ORDER BY Milestone_Due_Date__c ASC ];
            
            for(Payment_Milestones__c pm : pmList){
                if(bookingToPM.containsKey(pm.Quotation__r.Booking__c)){
                    list<Payment_Milestones__c> pms = bookingToPM.get(pm.Quotation__r.Booking__c);
                    pms.add(pm);
                    bookingToPM.put(pm.Quotation__r.Booking__c,pms);
                }
                else{
                    list<Payment_Milestones__c> pms = new list<Payment_Milestones__c>();
                    pms.add(pm);
                    bookingToPM.put(pm.Quotation__r.Booking__c,pms);
                }
            }
            
            for(Booking__c b : bookingList){
                long duePayment = (Long) b.Unit__r.Tower__r.Due_Payments__c;
                long advPayment = (Long) b.Unit__r.Tower__r.Advance_Payments__c;
                long sum = 0;
                Integer diffDays = 0;
                Boolean milestoneHit = false;
                if(bookingToPM.containsKey(b.Id)){
                    for(Payment_Milestones__c pm : bookingToPM.get(b.Id)){
                        sum = sum + (long)pm.Total_Installment_New__c;
                        if (sum > (long)b.Total_On_Account_Money_With_Registration__c && !milestoneHit) {
                            Date milestoneDate = pm.Milestone_Due_Date__c;
                            Date startDate = Date.today();
                            Date endDate = milestoneDate;
                            diffDays = endDate.daysBetween(startDate);
                            milestoneHit = true;
                        }
                    }
                }
                
                AllWrapper wrap = new AllWrapper();
                if(sum > (long) b.Total_On_Account_Money_With_Registration__c){
                    if((sum - (long) b.Total_On_Account_Money_With_Registration__c) >= duePayment){
                        if(bookingToPM.containsKey(b.Id)){
                            if (diffDays <= 30) {
                                wrap.bucketColor = 'background-color:#B1ffB1';                        
                            } else if (diffDays > 30 && diffDays <= 60) {
                                wrap.bucketColor = 'background-color:#FCFF6F';
                            } else if (diffDays > 60 && diffDays <= 90) {
                                wrap.bucketColor = 'background-color:#FFBF00';
                            } else if(diffDays > 90){
                                wrap.bucketColor = 'background-color:#FF6F59';
                            }
                        }
                    }
                    if((sum - (long) b.Total_On_Account_Money_With_Registration__c) <= advPayment){
                        wrap.bucketColor = 'background-color:#ADD8E6';
                    }
                }
                if((long) b.Total_On_Account_Money_With_Registration__c >= sum ){
                    wrap.bucketColor = 'background-color:#ADD8E6';
                }
                wrap.towerId = '/'+b.Unit__c;
                wrap.towerName = b.Unit__r.Name;
                wrap.totalPurchasePrice = (b.Agreement_Value__c!=null)?(Long)b.Agreement_Value__c:0;
                wrap.totalDemandTillDate = (b.Total_Agreement_Value_Demanded__c!=null)?(Long)b.Total_Agreement_Value_Demanded__c:0;
                wrap.totalMilestoneDueTillDate = (b.Milestone_Due_Till_Date__c!=null)?(Long)b.Milestone_Due_Till_Date__c:0;
                wrap.totalCollectedAmount = (b.Total_On_Account_Money_With_Registration__c!=null)?(Long)b.Total_On_Account_Money_With_Registration__c:0;
                wrap.totalDueAmount = (b.Due_Payments__c!=null)?(Long)b.Due_Payments__c:0;
                long milestoneDueTillDate = (b.Milestone_Due_Till_Date__c != null) ? (long)b.Milestone_Due_Till_Date__c : 0; 
                long collectedAmountTillDate = (b.Total_On_Account_Money_With_Registration__c != null) ? (long)b.Total_On_Account_Money_With_Registration__c : 0;
                long remainingAmountToPay = milestoneDueTillDate > collectedAmountTillDate ? milestoneDueTillDate : collectedAmountTillDate;
                long tempfutureAmount = (long)(((b.Agreement_Value__c != null) ? b.Agreement_Value__c : 0 ) - remainingAmountToPay);
                //long tempfutureAmount = (long)(((b.Agreement_Value__c != null && b.Agreement_Value__c > 0) ? b.Agreement_Value__c : 0 ) - ((b.Milestone_Due_Till_Date__c != null && b.Milestone_Due_Till_Date__c > 0) ? b.Milestone_Due_Till_Date__c : 0 ));
                wrap.futureCollections = wrap.futureCollections + (tempfutureAmount > 0 ? tempfutureAmount : 0);

                dataMap.put(b.Unit__c, wrap);
            }
        }

        return dataMap.values();
    }
    
    @AuraEnabled
    public static list<AllWrapper> getAgeingData(string towerId){
        map<string,AllWrapper> dataMap = new map<string,AllWrapper>();
        list<AllWrapper> sortedList = new list<AllWrapper>();
        map<string, list<Payment_Milestones__c>> bookingToPM = new map<string, list<Payment_Milestones__c>>();
        List<Booking__c> bookingList = [Select Id,Unit__r.Tower__r.Due_Payments__c,Unit__r.Tower__r.Advance_Payments__c,Unit__c,Unit__r.Name,Unit__r.Tower__c, Unit__r.Tower__r.Name, Unit__r.Tower__r.Cluster__c,Unit__r.Tower__r.Cluster__r.Name,Unit__r.Project__c,Unit__r.Project__r.Name,Agreement_Value__c, Total_Agreement_Value_Demanded__c, Total_On_Account_Money_With_Registration__c, Milestone_Due_Till_Date__c, Due_Payments__c, Advance_Payments__c from Booking__c where Status__c != 'Cancelled' and Unit__r.Tower__c =: towerId and Unit__r.Tower__c != null ];
        List<Payment_Milestones__c> pmList = [select id,Milestone_Due_Date__c,Total_Installment_New__c, Quotation__c, Quotation__r.Booking__c 
                                                from Payment_Milestones__c WHERE 
                                                Quotation__c != null AND Milestone_Due_Date__c != null AND 
                                                Milestone_Due_Date__c <= TODAY
                                                AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Status__c = 'Processed' AND Quotation__r.Booking__c IN: bookingList 
                                                ORDER BY Milestone_Due_Date__c ASC ];
        
        for(Payment_Milestones__c pm : pmList){
            if(bookingToPM.containsKey(pm.Quotation__r.Booking__c)){
                list<Payment_Milestones__c> pms = bookingToPM.get(pm.Quotation__r.Booking__c);
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
            else{
                list<Payment_Milestones__c> pms = new list<Payment_Milestones__c>();
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
        }
        
        for(Booking__c b : bookingList){
            long duePayment = (Long) b.Unit__r.Tower__r.Due_Payments__c;
            long advPayment = (Long) b.Unit__r.Tower__r.Advance_Payments__c;
            long sum = 0;
            Integer diffDays = 0;
            Boolean milestoneHit = false;
            if(bookingToPM.containsKey(b.Id)){
                for(Payment_Milestones__c pm : bookingToPM.get(b.Id)){
                    sum = sum + (long)pm.Total_Installment_New__c;
                    if (sum > (long)b.Total_On_Account_Money_With_Registration__c && !milestoneHit) {
                        Date milestoneDate = pm.Milestone_Due_Date__c;
                        Date startDate = Date.today();
                        Date endDate = milestoneDate;
                        diffDays = endDate.daysBetween(startDate);
                        milestoneHit = true;
                    }
                }
            }
            string bucketColor = '';
            string bucketColorLabel = '';
            if(sum > (long) b.Total_On_Account_Money_With_Registration__c){
                if((sum - (long) b.Total_On_Account_Money_With_Registration__c) >= duePayment){
                    if(bookingToPM.containsKey(b.Id)){
                        if (diffDays <= 30) {
                            bucketColor = 'Green';  
                            bucketColorLabel = 'Green (< 30 Days)';                    
                        } else if (diffDays > 30 && diffDays <= 60) {
                            bucketColor = 'Yellow';
                            bucketColorLabel = 'Yellow (31-60 Days)';
                        } else if (diffDays > 60 && diffDays <= 90) {
                            bucketColor = 'Amber';
                            bucketColorLabel = 'Amber (61-90 Days)';
                        } else if(diffDays > 90){
                            bucketColor = 'Red';
                            bucketColorLabel = 'Red (> 91 Days)';
                        }
                    }
                }
                if((sum - (long) b.Total_On_Account_Money_With_Registration__c) <= advPayment){
                    bucketColor = 'Blue';
                    bucketColorLabel = 'Blue (No Due Amount)';
                }
            }
            if((long) b.Total_On_Account_Money_With_Registration__c >= sum ){
                bucketColor = 'Blue';
                bucketColorLabel = 'Blue (No Due Amount)';
            }
            if(dataMap.containsKey(bucketColor)){
                AllWrapper wrap = dataMap.get(bucketColor);
                wrap.totalUnit = wrap.totalUnit + 1;
                wrap.totalPurchasePrice = (b.Agreement_Value__c!=null)?(wrap.totalPurchasePrice + (Long)b.Agreement_Value__c):wrap.totalPurchasePrice;
                wrap.totalDemandTillDate = (b.Total_Agreement_Value_Demanded__c!=null)?(wrap.totalDemandTillDate + (Long)b.Total_Agreement_Value_Demanded__c):wrap.totalDemandTillDate;
                wrap.totalMilestoneDueTillDate = (b.Milestone_Due_Till_Date__c!=null)?(wrap.totalMilestoneDueTillDate + (Long)b.Milestone_Due_Till_Date__c):wrap.totalMilestoneDueTillDate;
                wrap.totalCollectedAmount = (b.Total_On_Account_Money_With_Registration__c!=null)?(wrap.totalCollectedAmount + (Long)b.Total_On_Account_Money_With_Registration__c):wrap.totalCollectedAmount;
                wrap.totalDueAmount = (b.Due_Payments__c!=null)?(wrap.totalDueAmount + (Long)b.Due_Payments__c):wrap.totalDueAmount;
                // wrap.totalAdvanceAmount = (b.Advance_Payments__c!=null)?(wrap.totalAdvanceAmount + (Long)b.Advance_Payments__c):wrap.totalAdvanceAmount;
                dataMap.put(bucketColor, wrap);
            }
            else{
                AllWrapper wrap = new AllWrapper();
                wrap.towerId = bucketColor;
                wrap.towerName = bucketColorLabel;
                wrap.totalUnit = 1;
                wrap.totalPurchasePrice = (b.Agreement_Value__c!=null)?(Long)b.Agreement_Value__c:0;
                wrap.totalDemandTillDate = (b.Total_Agreement_Value_Demanded__c!=null)?(Long)b.Total_Agreement_Value_Demanded__c:0;
                wrap.totalMilestoneDueTillDate = (b.Milestone_Due_Till_Date__c!=null)?(Long)b.Milestone_Due_Till_Date__c:0;
                wrap.totalCollectedAmount = (b.Total_On_Account_Money_With_Registration__c!=null)?(Long)b.Total_On_Account_Money_With_Registration__c:0;
                wrap.totalDueAmount = (b.Due_Payments__c!=null)?(Long)b.Due_Payments__c:0;
                // wrap.totalAdvanceAmount = (b.Advance_Payments__c!=null)?(Long)b.Advance_Payments__c:0;
                dataMap.put(bucketColor, wrap);
            }
        }
        if(dataMap.containsKey('Green'))
            sortedList.add(dataMap.get('Green'));
        if(dataMap.containsKey('Yellow'))
            sortedList.add(dataMap.get('Yellow'));
        if(dataMap.containsKey('Amber'))
            sortedList.add(dataMap.get('Amber'));
        if(dataMap.containsKey('Red'))
            sortedList.add(dataMap.get('Red'));
        if(dataMap.containsKey('Blue'))
            sortedList.add(dataMap.get('Blue'));
        return sortedList;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,AgingWrapper> getMilestoneAllData(){
        Map<String,AgingWrapper> agingWrapperMap = new Map<String,AgingWrapper>();
        List<Milestone_Ageing__c> agingList = new List<Milestone_Ageing__C>();

        agingList = [SELECT Id,Name,B1_0_30_Days__c,B1_Net__c,B2_31_60_Days__c,B2_Net__c,B3_61_90_Days__c,B3_Net__c,B4_91_120_Days__c,B4_Net__c,B5_121_180_Days__c,B5_Net__c,B6_181_360_Days__c,
                    Unit__r.Tower__r.Id,Unit__r.Tower__r.Cluster__r.Id,Unit__r.project__r.Id,unit__r.Id,
                    B6_Net__c,B7_361_Days__c,B7_Net__c,Booking__c,OwnerId,Project__c,Quotation__c,Sub_Project__c,SystemModstamp,Total_Milestone_Amount__c,Total_On_Account_Money__c,Total_Pre_Registration_Amount__c,
                    Unit__c FROM Milestone_Ageing__c WHERE Booking__r.Current_Status__c = 'Audit Accepted' AND Booking__r.Status__c != 'Cancelled'];
                    
        String typeName = '';
        AgingWrapper wrapRec = new AgingWrapper();
        if(agingList != null && agingList.size() > 0){
            for(Milestone_Ageing__c ageingRec : agingList){
                wrapRec.B1Net = wrapRec.B1Net + ageingRec.B1_Net__c;
                wrapRec.B2Net = wrapRec.B2Net + ageingRec.B2_Net__c;
                wrapRec.B3Net = wrapRec.B3Net + ageingRec.B3_Net__c;
                wrapRec.B4Net = wrapRec.B4Net + ageingRec.B4_Net__c;
                wrapRec.B5Net = wrapRec.B5Net + ageingRec.B5_Net__c;
                wrapRec.B6Net = wrapRec.B6Net + ageingRec.B6_Net__c;
                wrapRec.B7Net = wrapRec.B7Net + ageingRec.B7_Net__c;
                wrapRec.B1_0_30_Days = wrapRec.B1_0_30_Days + ageingRec.B1_0_30_Days__c;
                wrapRec.B2_31_60_Days = wrapRec.B2_31_60_Days + ageingRec.B2_31_60_Days__c;
                wrapRec.B3_61_90_Days = wrapRec.B3_61_90_Days + ageingRec.B3_61_90_Days__c;
                wrapRec.B4_91_120_Days = wrapRec.B4_91_120_Days + ageingRec.B4_91_120_Days__c;
                wrapRec.B5_121_180_Days = wrapRec.B5_121_180_Days + ageingRec.B5_121_180_Days__c;
                wrapRec.B6_181_360_Days = wrapRec.B6_181_360_Days + ageingRec.B6_181_360_Days__c;
                wrapRec.B7_361_Days = wrapRec.B7_361_Days + ageingRec.B7_361_Days__c;
                wrapRec.overallDueAmount = wrapRec.overallDueAmount + ageingRec.B1_0_30_Days__c + ageingRec.B2_31_60_Days__c + ageingRec.B3_61_90_Days__c + ageingRec.B4_91_120_Days__c + ageingRec.B5_121_180_Days__c + ageingRec.B6_181_360_Days__c + ageingRec.B7_361_Days__c;
            }
            agingWrapperMap.put('All' , wrapRec);
        }
        return agingWrapperMap;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,AgingWrapper> getMilestoneCollectiveData(string type,String recordId){
        System.debug('type - >'+type);
        Map<String,AgingWrapper> agingWrapperMap = new Map<String,AgingWrapper>();
        List<Milestone_Ageing__c> agingList = new List<Milestone_Ageing__C>();
        if(type == 'project' &&  recordId == 'All'){
            agingList = [SELECT Id,Name,B1_0_30_Days__c,B1_Net__c,B2_31_60_Days__c,B2_Net__c,B3_61_90_Days__c,B3_Net__c,B4_91_120_Days__c,B4_Net__c,B5_121_180_Days__c,B5_Net__c,B6_181_360_Days__c,
            Unit__r.Tower__r.Id,Unit__r.Tower__r.Cluster__r.Id,Unit__r.project__r.Id,unit__r.Id,Unit__r.Tower__r.Cluster__r.Section__c,Unit__r.Tower__r.Cluster__r.Ongoing_Project__c,
            B6_Net__c,B7_361_Days__c,B7_Net__c,Booking__c,OwnerId,Project__c,Quotation__c,Sub_Project__c,SystemModstamp,Total_Milestone_Amount__c,Total_On_Account_Money__c,Total_Pre_Registration_Amount__c,
            Unit__c FROM Milestone_Ageing__c 
            WHERE Booking__r.Status__c != 'Cancelled' AND Booking__r.Current_Status__c = 'Audit Accepted'];
        }else if(type == 'allProject'){

            agingList = [SELECT Id,Name,B1_0_30_Days__c,B1_Net__c,B2_31_60_Days__c,B2_Net__c,B3_61_90_Days__c,B3_Net__c,B4_91_120_Days__c,B4_Net__c,B5_121_180_Days__c,B5_Net__c,B6_181_360_Days__c,
                        Unit__r.Tower__r.Id,Unit__r.Tower__r.Cluster__r.Id,Unit__r.project__r.Id,unit__r.Id,Unit__r.Tower__r.Cluster__r.Ongoing_Project__c,Unit__r.Tower__r.Cluster__r.Section__c,
                        B6_Net__c,B7_361_Days__c,B7_Net__c,Booking__c,OwnerId,Project__c,Quotation__c,Sub_Project__c,SystemModstamp,Total_Milestone_Amount__c,Total_On_Account_Money__c,Total_Pre_Registration_Amount__c,
                        Unit__c FROM Milestone_Ageing__c WHERE Booking__r.Current_Status__c = 'Audit Accepted' AND Booking__r.Status__c != 'Cancelled'];

        }else if(type == 'project'){

            agingList = [SELECT Id,Name,B1_0_30_Days__c,B1_Net__c,B2_31_60_Days__c,B2_Net__c,B3_61_90_Days__c,B3_Net__c,B4_91_120_Days__c,B4_Net__c,B5_121_180_Days__c,B5_Net__c,B6_181_360_Days__c,
                        Unit__r.Tower__r.Id,Unit__r.Tower__r.Cluster__r.Id,Unit__r.project__r.Id,unit__r.Id,Unit__r.Tower__r.Cluster__r.Section__c,Unit__r.Tower__r.Cluster__r.Ongoing_Project__c,
                        B6_Net__c,B7_361_Days__c,B7_Net__c,Booking__c,OwnerId,Project__c,Quotation__c,Sub_Project__c,SystemModstamp,Total_Milestone_Amount__c,Total_On_Account_Money__c,Total_Pre_Registration_Amount__c,
                        Unit__c FROM Milestone_Ageing__c 
                        WHERE Booking__r.Status__c != 'Cancelled' AND Booking__r.Current_Status__c = 'Audit Accepted' AND Unit__r.Project__c =: recordID];

        } else if(type == 'SubProject'){

            agingList = [SELECT Id,Name,B1_0_30_Days__c,B1_Net__c,B2_31_60_Days__c,B2_Net__c,B3_61_90_Days__c,B3_Net__c,B4_91_120_Days__c,B4_Net__c,B5_121_180_Days__c,B5_Net__c,B6_181_360_Days__c,
                        Unit__r.Tower__r.Id,Unit__r.Tower__r.Cluster__r.Id,Unit__r.project__r.Id,unit__r.Id,Unit__r.Tower__r.Cluster__r.Ongoing_Project__c,Unit__r.Tower__r.Cluster__r.Section__c,
                        B6_Net__c,B7_361_Days__c,B7_Net__c,Booking__c,OwnerId,Project__c,Quotation__c,Sub_Project__c,SystemModstamp,Total_Milestone_Amount__c,Total_On_Account_Money__c,Total_Pre_Registration_Amount__c,
                        Unit__c FROM Milestone_Ageing__c 
                        WHERE Booking__r.Status__c != 'Cancelled' AND Booking__r.Current_Status__c = 'Audit Accepted' AND Unit__r.Tower__r.Cluster__r.Id =: recordID];

        }else if(type == 'Tower'){

            agingList = [SELECT Id,Name,B1_0_30_Days__c,B1_Net__c,B2_31_60_Days__c,B2_Net__c,B3_61_90_Days__c,B3_Net__c,B4_91_120_Days__c,B4_Net__c,B5_121_180_Days__c,B5_Net__c,B6_181_360_Days__c,
                        Unit__r.Tower__r.Id,Unit__r.Tower__r.Cluster__r.Id,Unit__r.project__r.Id,unit__r.Id,Unit__r.Tower__r.Cluster__r.Ongoing_Project__c,Unit__r.Tower__r.Cluster__r.Section__c,
                        B6_Net__c,B7_361_Days__c,B7_Net__c,Booking__c,OwnerId,Project__c,Quotation__c,Sub_Project__c,SystemModstamp,Total_Milestone_Amount__c,Total_On_Account_Money__c,Total_Pre_Registration_Amount__c,
                        Unit__c FROM Milestone_Ageing__c 
                        WHERE Booking__r.Status__c != 'Cancelled' AND Booking__r.Current_Status__c = 'Audit Accepted' AND Unit__r.tower__c =: recordId ];

        }
        System.debug('recordId  : '+recordId +'aging' + aginglist);
        String typeName = '';
        
        if(agingList != null && agingList.size() > 0){
            for(Milestone_Ageing__c ageingRec : agingList){
                if(type == 'project' && recordId == 'All'){
                    typeName = ageingRec.Unit__r.Tower__r.Cluster__r.Id;
                }else if(type == 'allProject'){
                    typeName = ageingRec.Unit__r.project__r.Id;
                }else if(type == 'project'){
                    typeName = ageingRec.Unit__r.Tower__r.Cluster__r.Id;

                }else if(type == 'subproject'){
                    typeName = ageingRec.Unit__r.Tower__r.Id;
                }else if(type == 'Tower'){
                    typeName = ageingRec.unit__r.Id;   
                }
                if(typeName != null && agingWrapperMap.containsKey(typeName) && agingWrapperMap.get(typeName) != null) {
                    AgingWrapper wrapRec = agingWrapperMap.get(typeName);
                    wrapRec.B1Net = wrapRec.B1Net + ageingRec.B1_Net__c;
                    wrapRec.B2Net = wrapRec.B2Net + ageingRec.B2_Net__c;
                    wrapRec.B3Net = wrapRec.B3Net + ageingRec.B3_Net__c;
                    wrapRec.B4Net = wrapRec.B4Net + ageingRec.B4_Net__c;
                    wrapRec.B5Net = wrapRec.B5Net + ageingRec.B5_Net__c;
                    wrapRec.B6Net = wrapRec.B6Net + ageingRec.B6_Net__c;
                    wrapRec.B7Net = wrapRec.B7Net + ageingRec.B7_Net__c;
                    wrapRec.B1_0_30_Days = wrapRec.B1_0_30_Days + ageingRec.B1_0_30_Days__c;
                    wrapRec.B2_31_60_Days = wrapRec.B2_31_60_Days + ageingRec.B2_31_60_Days__c;
                    wrapRec.B3_61_90_Days = wrapRec.B3_61_90_Days + ageingRec.B3_61_90_Days__c;
                    wrapRec.B4_91_120_Days = wrapRec.B4_91_120_Days + ageingRec.B4_91_120_Days__c;
                    wrapRec.B5_121_180_Days = wrapRec.B5_121_180_Days + ageingRec.B5_121_180_Days__c;
                    wrapRec.B6_181_360_Days = wrapRec.B6_181_360_Days + ageingRec.B6_181_360_Days__c;
                    wrapRec.B7_361_Days = wrapRec.B7_361_Days + ageingRec.B7_361_Days__c;
                    wrapRec.overallDueAmount = wrapRec.overallDueAmount + (ageingRec.B1_0_30_Days__c + ageingRec.B2_31_60_Days__c + ageingRec.B3_61_90_Days__c + ageingRec.B4_91_120_Days__c + ageingRec.B5_121_180_Days__c + ageingRec.B6_181_360_Days__c + ageingRec.B7_361_Days__c);
                    wrapRec.isOngoing = ageingRec.Unit__r.Tower__r.Cluster__r.Ongoing_Project__c;
                    wrapRec.section = ageingRec.Unit__r.Tower__r.Cluster__r.Section__c;
                    agingWrapperMap.put(typeName , wrapRec);
                }else if(typeName != null){
                    AgingWrapper wrapRec = new AgingWrapper();
                    wrapRec.B1Net = ageingRec.B1_Net__c;
                    wrapRec.B2Net = ageingRec.B2_Net__c;
                    wrapRec.B3Net = ageingRec.B3_Net__c;
                    wrapRec.B4Net = ageingRec.B4_Net__c;
                    wrapRec.B5Net = ageingRec.B5_Net__c;
                    wrapRec.B6Net = ageingRec.B6_Net__c;
                    wrapRec.B7Net = ageingRec.B7_Net__c;
                    wrapRec.B1_0_30_Days = ageingRec.B1_0_30_Days__c;
                    wrapRec.B2_31_60_Days = ageingRec.B2_31_60_Days__c;
                    wrapRec.B3_61_90_Days = ageingRec.B3_61_90_Days__c;
                    wrapRec.B4_91_120_Days = ageingRec.B4_91_120_Days__c;
                    wrapRec.B5_121_180_Days = ageingRec.B5_121_180_Days__c;
                    wrapRec.B6_181_360_Days = ageingRec.B6_181_360_Days__c;
                    wrapRec.B7_361_Days = ageingRec.B7_361_Days__c;
                    wrapRec.overallDueAmount = (ageingRec.B1_0_30_Days__c + ageingRec.B2_31_60_Days__c + ageingRec.B3_61_90_Days__c + ageingRec.B4_91_120_Days__c + ageingRec.B5_121_180_Days__c + ageingRec.B6_181_360_Days__c + ageingRec.B7_361_Days__c);
                    wrapRec.isOngoing = ageingRec.Unit__r.Tower__r.Cluster__r.Ongoing_Project__c;
                    wrapRec.section = ageingRec.Unit__r.Tower__r.Cluster__r.Section__c;
                    agingWrapperMap.put(typeName , wrapRec);    
                }
            }
        }
        return agingWrapperMap;
    }
    
    public class AgingWrapper {
        @AuraEnabled public string unitId;
        @AuraEnabled public string unitName;
        @AuraEnabled public decimal B1Net;
        @AuraEnabled public decimal B2Net;
        @AuraEnabled public decimal B3Net;
        @AuraEnabled public decimal B4Net;
        @AuraEnabled public decimal B5Net;
        @AuraEnabled public decimal B6Net;
        @AuraEnabled public decimal B7Net;
        @AuraEnabled public decimal B1_0_30_Days;
        @AuraEnabled public decimal B2_31_60_Days;
        @AuraEnabled public decimal B3_61_90_Days;
        @AuraEnabled public decimal B4_91_120_Days;
        @AuraEnabled public decimal B5_121_180_Days;
        @AuraEnabled public decimal B6_181_360_Days;
        @AuraEnabled public decimal B7_361_Days;
        @AuraEnabled public decimal overallDueAmount;
        @AuraEnabled public Boolean isOngoing;
        @AuraEnabled public String section;
        AgingWrapper(){
            B1Net = 0;
            B2Net = 0;
            B3Net = 0;
            B4Net = 0;
            B5Net = 0;
            B6Net = 0;
            B7Net = 0;
            B1_0_30_Days = 0;
            B2_31_60_Days = 0;
            B3_61_90_Days = 0;
            B4_91_120_Days = 0;
            B5_121_180_Days = 0;
            B6_181_360_Days = 0;
            B7_361_Days = 0;
            overallDueAmount = 0;
            isOngoing = false;
            section = '';
        }
        
    }

    public class AllWrapper {
        @AuraEnabled public string projectId;
        @AuraEnabled public string projectName;
        @AuraEnabled public string subProjectId;
        @AuraEnabled public string subProjectName;
        @AuraEnabled public string towerId;
        @AuraEnabled public string towerName;
        @AuraEnabled public Integer totalUnit;
        @AuraEnabled public long totalPurchasePrice;
        @AuraEnabled public long totalDemandTillDate;
        @AuraEnabled public long totalMilestoneDueTillDate;
        @AuraEnabled public long totalCollectedAmount;
        @AuraEnabled public long totalDueAmount;
        @AuraEnabled public long DueAmount;
        @AuraEnabled public long advanceAmount;
        @AuraEnabled public long totalAdvanceAmount;
        @AuraEnabled public long totalInvestorUnitValue;
        @AuraEnabled public long futureCollections;
        @AuraEnabled public list<long> futureMilestoneDues;
        @AuraEnabled public string bucketColor;
        @AuraEnabled public string section;
        @AuraEnabled public boolean isOngoing;
        AllWrapper(){
            projectId='';
            projectName='';
            subProjectId='';
            subProjectName='';
            towerId='';
            towerName='';
            totalUnit=0;
            totalPurchasePrice=0;
            totalDemandTillDate=0;
            totalMilestoneDueTillDate=0;
            totalCollectedAmount=0;
            totalDueAmount=0;
            DueAmount=0;
            advanceAmount=0;
            totalAdvanceAmount=0;
            totalInvestorUnitValue=0;
            futureCollections=0;
            futureMilestoneDues = new list<long>();
            bucketColor='';
            section='';
            isOngoing=false;
        }
    }

    public static void getColorCode(){
        integer i = 0;
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

}