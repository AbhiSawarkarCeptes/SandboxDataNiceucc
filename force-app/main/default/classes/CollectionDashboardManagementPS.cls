public class CollectionDashboardManagementPS {
    @AuraEnabled
    public static list<string> getYearList(){
        set<string> yearList = new set<string>();
        List<PropStrength__Payment_Plan_Details__c> pmList = [SELECT Id, PropStrength__Total_Amount_Due__c,PropStrength__Payment_Due_Date__c, PropStrength__Application_Booking__c, 
                                             PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c, 
                                             PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c 
                                             FROM PropStrength__Payment_Plan_Details__c 
                                             WHERE PropStrength__Application_Booking__c != null 
                                             AND PropStrength__Application_Booking__r.PropStrength__Status__c = 'Application Form Filled' 
                                             AND PropStrength__Payment_Due_Date__c != null 
                                             AND PropStrength__Payment_Due_Date__c >= TODAY
                                             AND PropStrength__Application_Booking__r.PropStrength__Property__c != null 
                                             ORDER BY PropStrength__Payment_Due_Date__c ASC];
        for(PropStrength__Payment_Plan_Details__c p : pmList){
            Date dueDate = p.PropStrength__Payment_Due_Date__c;
            string dueDateYear = string.valueOf(dueDate.year());
            yearList.add(dueDateYear);
        }
        return new List<String>(yearList);
    }

    @AuraEnabled
    public static list<AllWrapper> getAllTabData(string type, string recordId){
        map<string,AllWrapper> dataMap = new map<string,AllWrapper>();
        map<string,AllWrapper> tempDataMap = new map<string,AllWrapper>();
        if(type == 'Project'){
            set<string> yearList = new set<string>();
            AllWrapper wrapAll = new AllWrapper();
            List<PropStrength__Payment_Plan_Details__c> pmList = [SELECT Id, PropStrength__Total_Amount_Due__c,PropStrength__Payment_Due_Date__c, PropStrength__Application_Booking__c, 
                                             PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c, 
                                             PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c 
                                             FROM PropStrength__Payment_Plan_Details__c 
                                             WHERE PropStrength__Application_Booking__c != null 
                                             AND PropStrength__Application_Booking__r.PropStrength__Status__c = 'Application Form Filled' 
                                             AND PropStrength__Payment_Due_Date__c != null 
                                             AND PropStrength__Payment_Due_Date__c >= TODAY
                                             AND PropStrength__Application_Booking__r.PropStrength__Property__c != null 
                                             ORDER BY PropStrength__Payment_Due_Date__c ASC];

            map<string,long> projectToFutureDues = new map<string,long>();
            map<string,list<long>> projectToFutureDueList = new map<string,list<long>>();
            for(PropStrength__Payment_Plan_Details__c p : pmList){
                Date dueDate = p.PropStrength__Payment_Due_Date__c;
                string dueDateYear = string.valueOf(dueDate.year());
                yearList.add(dueDateYear);
                string pId = p.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c + '##' + dueDateYear;
                string allPId = 'All##' + dueDateYear;
                if(projectToFutureDues.containsKey(pId)){
                    long dueAmt = projectToFutureDues.get(pId);
                    dueAmt = (p.PropStrength__Total_Amount_Due__c != null)?(dueAmt +(long)p.PropStrength__Total_Amount_Due__c):dueAmt; 
                    projectToFutureDues.put(pId, dueAmt);
                }
                else{
                    long dueAmt = (p.PropStrength__Total_Amount_Due__c != null)?(long)p.PropStrength__Total_Amount_Due__c:0;
                    projectToFutureDues.put(pId, dueAmt);
                }
                if(projectToFutureDues.containsKey(allPId)){
                    long dueAmt = projectToFutureDues.get(allPId);
                    dueAmt = (p.PropStrength__Total_Amount_Due__c != null)?(dueAmt + (long)p.PropStrength__Total_Amount_Due__c):dueAmt; 
                    projectToFutureDues.put(allPId, dueAmt);
                }
                else{
                    long dueAmt = (p.PropStrength__Total_Amount_Due__c != null)?(long)p.PropStrength__Total_Amount_Due__c:0;
                    projectToFutureDues.put(allPId, dueAmt);
                }
            }

            map<string,long> projectToFutureDuesNew = new map<string,long>();
            set<string> keyList = projectToFutureDues.keySet();
            for(string pId : projectToFutureDues.keySet()){
                string actualPId = pId.split('##')[0];
                integer yr = Integer.valueOf(pId.split('##')[1]); 
                for(string str : yearList){
                    string key = actualPId+'##'+str;
                    integer yrr = Integer.valueOf(str);
                    if((yrr <= yr)){
                        if(!keyList.contains(key)){
                            if(!projectToFutureDuesNew.containsKey(key))
                                projectToFutureDuesNew.put(key, 0);
                        }
                        if(yrr == yr) break;
                    }
                }
                projectToFutureDuesNew.put(pId,projectToFutureDues.get(pId));
            }

            for(string pId : projectToFutureDuesNew.keySet()){
                string actualPId = pId.split('##')[0];
                if(projectToFutureDueList.containsKey(actualPId)){
                    list<long> dueList = projectToFutureDueList.get(actualPId);
                    dueList.add(projectToFutureDuesNew.get(pId));
                    projectToFutureDueList.put(actualPId,dueList);
                }
                else{
                    projectToFutureDueList.put(actualPId, new list<long>{projectToFutureDuesNew.get(pId)});
                }
            }
            List<PropStrength__Application_Booking__c> applicationList = new List<PropStrength__Application_Booking__c>();
            applicationList = [SELECT Id, PropStrength__Revised_Total_Sales_Consideration__c,PropStrength__Revised_Agreement_Amount__c, 
                                PropStrength__Total_Payment_Due__c,PropStrength__Total_Payment_Received__c,PropStrength__Outstanding_Balance__c, PropStrength__Property__c,
                                PropStrength__Property__r.Investor_Unit__c,PropStrength__Status__c,  PropStrength__Property__r.PropStrength__Project_Name__c, 
                                PropStrength__Property__r.PropStrength__Project_Name__r.Name 
                                FROM PropStrength__Application_Booking__c 
                                WHERE PropStrength__Property__r.PropStrength__Project_Name__c != null];
            
            for(PropStrength__Application_Booking__c b : applicationList){
                if(tempDataMap.containsKey(b.PropStrength__Property__r.PropStrength__Project_Name__c)){
                    AllWrapper wrap = tempDataMap.get(b.PropStrength__Property__r.PropStrength__Project_Name__c);
                    if(b.PropStrength__Status__c == 'Audit Approved' && b.PropStrength__Property__c != null) {
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(wrap.totalPurchasePrice + (Long)b.PropStrength__Revised_Agreement_Amount__c):wrap.totalPurchasePrice;
                        wrap.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(wrap.totalMilestoneDueTillDate + (Long)b.PropStrength__Total_Payment_Due__c):wrap.totalMilestoneDueTillDate;
                        wrap.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(wrap.totalCollectedAmount + (Long)b.PropStrength__Total_Payment_Received__c):wrap.totalCollectedAmount;
                        if(((Long)b.PropStrength__Total_Payment_Due__c  >  (Long)b.PropStrength__Total_Payment_Received__c)) {
                            wrap.dueAmount = wrap.dueAmount + (Long)b.PropStrength__Total_Payment_Due__c  -  (Long)b.PropStrength__Total_Payment_Received__c;
                        }
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Project_Name__c, wrap);
                    }
                    else if(b.PropStrength__Property__c != null && b.PropStrength__Property__r.Investor_Unit__c == true){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(wrap.totalPurchasePrice + (Long)b.PropStrength__Revised_Total_Sales_Consideration__c):wrap.totalPurchasePrice;
                        wrap.totalInvestorUnitValue = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(wrap.totalInvestorUnitValue + (Long)b.PropStrength__Revised_Total_Sales_Consideration__c):wrap.totalInvestorUnitValue;
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Project_Name__c, wrap);
                    }
                }
                else{
                    AllWrapper wrap = new AllWrapper();
                    wrap.projectId = b.PropStrength__Property__r.PropStrength__Project_Name__c;
                    wrap.projectName = b.PropStrength__Property__r.PropStrength__Project_Name__r.Name;
                    if(b.PropStrength__Status__c == 'Audit Approved' && b.PropStrength__Property__c != null){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(Long)b.PropStrength__Revised_Agreement_Amount__c:0;
                        wrap.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(Long)b.PropStrength__Total_Payment_Due__c:0;
                        wrap.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(Long)b.PropStrength__Total_Payment_Received__c:0;
                        if(((Long)b.PropStrength__Total_Payment_Due__c  >  (Long)b.PropStrength__Total_Payment_Received__c)) {
                            wrap.dueAmount = wrap.dueAmount + (Long)b.PropStrength__Total_Payment_Due__c  - (Long)b.PropStrength__Total_Payment_Received__c;
                        }
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Project_Name__c, wrap);
                    }
                    else if(b.PropStrength__Property__c != null && b.PropStrength__Property__r.Investor_Unit__c == true){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(Long)b.PropStrength__Revised_Total_Sales_Consideration__c:0;
                        wrap.totalInvestorUnitValue = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(Long)b.PropStrength__Revised_Total_Sales_Consideration__c:0;
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Project_Name__c, wrap);
                    }
                }
                if(b.PropStrength__Status__c == 'Audit Approved' && b.PropStrength__Property__c != null){
                    wrapAll.totalUnit = wrapAll.totalUnit + 1;
                    wrapAll.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(wrapAll.totalPurchasePrice + (Long)b.PropStrength__Revised_Agreement_Amount__c):wrapAll.totalPurchasePrice;
                    wrapAll.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(wrapAll.totalMilestoneDueTillDate + (Long)b.PropStrength__Total_Payment_Due__c):wrapAll.totalMilestoneDueTillDate;
                    wrapAll.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(wrapAll.totalCollectedAmount + (Long)b.PropStrength__Total_Payment_Received__c):wrapAll.totalCollectedAmount;
                    if(((Long)b.PropStrength__Total_Payment_Due__c  >  (Long)b.PropStrength__Total_Payment_Received__c)) {
                        wrapAll.dueAmount = wrapAll.dueAmount + (Long)b.PropStrength__Total_Payment_Due__c  -  (Long)b.PropStrength__Total_Payment_Received__c;
                    }
                }
                else if(b.PropStrength__Property__c != null && b.PropStrength__Property__r.Investor_Unit__c == true){
                    wrapAll.totalUnit = wrapAll.totalUnit + 1;
                    wrapAll.totalPurchasePrice = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(wrapAll.totalPurchasePrice + (Long)b.PropStrength__Revised_Total_Sales_Consideration__c):wrapAll.totalPurchasePrice;
                    wrapAll.totalInvestorUnitValue = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(wrapAll.totalInvestorUnitValue + (Long)b.PropStrength__Revised_Total_Sales_Consideration__c):wrapAll.totalInvestorUnitValue;
                }
            }
            wrapAll.projectId = 'All';
            wrapAll.projectName = 'All';
            // wrapAll.totalDueAmount = (wrapAll.totalMilestoneDueTillDate > wrapAll.totalCollectedAmount)?(wrapAll.totalMilestoneDueTillDate - wrapAll.totalCollectedAmount):0;
            wrapAll.totalDueAmount = wrapAll.dueAmount;
            wrapAll.futureMilestoneDues = projectToFutureDueList.get('All');
            long allFutureCollections = 0;
            for(long allF : projectToFutureDueList.get('All')){
                allFutureCollections += allF;
            }
            wrapAll.futureCollections = allFutureCollections;
            dataMap.put('All', wrapAll);
            for(string projectId : tempDataMap.keySet()){
                AllWrapper w = tempDataMap.get(projectId);
                // w.totalDueAmount = (w.totalMilestoneDueTillDate > w.totalCollectedAmount)?(w.totalMilestoneDueTillDate - w.totalCollectedAmount):0;
                w.totalDueAmount = w.dueAmount;
                if(projectToFutureDueList.containsKey(projectId)){
                    w.futureMilestoneDues = projectToFutureDueList.get(projectId);
                    long projectFutureCollections = 0;
                    for(long projectF : projectToFutureDueList.get(projectId)){
                        projectFutureCollections += projectF;
                    }
                    w.futureCollections = projectFutureCollections;
                }
                else{
                    list<long> tmpFutureDues = new list<long>();
                    for(string str : yearList){
                        tmpFutureDues.add(0);
                    }
                    w.futureMilestoneDues = tmpFutureDues;
                }
                integer s = w.futureMilestoneDues.size();
                for(integer i=s; i<yearList.size(); i++){
                    w.futureMilestoneDues.add(0);
                }
                dataMap.put(projectId,w);
            }
        }
        else if(type == 'SubProject'){
            set<string> yearList = new set<string>();
            List<PropStrength__Payment_Plan_Details__c> pmList = [SELECT Id, PropStrength__Total_Amount_Due__c,PropStrength__Payment_Due_Date__c, PropStrength__Application_Booking__c, 
                                             PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c, 
                                             PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c 
                                             FROM PropStrength__Payment_Plan_Details__c 
                                             WHERE PropStrength__Application_Booking__c != null 
                                             AND PropStrength__Application_Booking__r.PropStrength__Status__c = 'Application Form Filled' 
                                             AND PropStrength__Payment_Due_Date__c != null 
                                             AND PropStrength__Payment_Due_Date__c >= TODAY
                                             AND PropStrength__Application_Booking__r.PropStrength__Property__c != null 
                                             ORDER BY PropStrength__Payment_Due_Date__c ASC];

            map<string,long> projectToFutureDues = new map<string,long>();
            map<string,list<long>> projectToFutureDueList = new map<string,list<long>>();

            for(PropStrength__Payment_Plan_Details__c p : pmList){
                Date dueDate = p.PropStrength__Payment_Due_Date__c;
                string dueDateYear = string.valueOf(dueDate.year());
                yearList.add(dueDateYear);
                string pId = p.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c + '##' + dueDateYear;
                if(projectToFutureDues.containsKey(pId)){
                    long dueAmt = projectToFutureDues.get(pId);
                    dueAmt = (p.PropStrength__Total_Amount_Due__c != null)?(dueAmt + (long)p.PropStrength__Total_Amount_Due__c):dueAmt; 
                    projectToFutureDues.put(pId, dueAmt);
                }
                else{
                    long dueAmt = (p.PropStrength__Total_Amount_Due__c != null)?(long)p.PropStrength__Total_Amount_Due__c:0;
                    projectToFutureDues.put(pId, dueAmt);
                }
            }
            map<string,long> projectToFutureDuesNew = new map<string,long>();
            set<string> keyList = projectToFutureDues.keySet();
            for(string pId : projectToFutureDues.keySet()){
                string actualPId = pId.split('##')[0];
                integer yr = Integer.valueOf(pId.split('##')[1]); //22
                for(string str : yearList){
                    string key = actualPId+'##'+str;
                    integer yrr = Integer.valueOf(str);
                    if((yrr <= yr)){
                        if(!keyList.contains(key)){
                            if(!projectToFutureDuesNew.containsKey(key))
                                projectToFutureDuesNew.put(key, 0);
                        }
                        if(yrr == yr) break;
                    }
                }
                projectToFutureDuesNew.put(pId,projectToFutureDues.get(pId));
            }
            for(string pId : projectToFutureDuesNew.keySet()){
                string actualPId = pId.split('##')[0];
                if(projectToFutureDueList.containsKey(actualPId)){
                    list<long> dueList = projectToFutureDueList.get(actualPId);
                    dueList.add(projectToFutureDuesNew.get(pId));
                    projectToFutureDueList.put(actualPId,dueList);
                }
                else{
                    projectToFutureDueList.put(actualPId, new list<long>{projectToFutureDuesNew.get(pId)});
                }
            }
            List<PropStrength__Application_Booking__c> applicationList = new List<PropStrength__Application_Booking__c>();
            if(recordId == 'All'){
                applicationList = [SELECT Id, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c, 
                                    PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Name, PropStrength__Revised_Total_Sales_Consideration__c, 
                                    PropStrength__Property__r.PropStrength__Project_Name__c, PropStrength__Property__r.PropStrength__Project_Name__r.Name, 
                                    PropStrength__Revised_Agreement_Amount__c, PropStrength__Total_Payment_Due__c, PropStrength__Total_Payment_Received__c,
                                    PropStrength__Outstanding_Balance__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Sequence__c, 
                                    PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Section__c, 
                                    PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Ongoing_Project__c,
                                    PropStrength__Property__r.Investor_Unit__c, PropStrength__Status__c 
                                    FROM PropStrength__Application_Booking__c  
                                    WHERE PropStrength__Property__r.PropStrength__Project_Name__c  != null 
                                    AND PropStrength__Property__r.PropStrength__Tower__c  != null 
                                    AND PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c  != null 
                                    ORDER BY PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.sequence__c ASC];
            }
            else {
                applicationList = [SELECT Id, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c, 
                                    PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Name, PropStrength__Revised_Total_Sales_Consideration__c, 
                                    PropStrength__Property__r.PropStrength__Project_Name__c, PropStrength__Property__r.PropStrength__Project_Name__r.Name, 
                                    PropStrength__Revised_Agreement_Amount__c, PropStrength__Total_Payment_Due__c, PropStrength__Total_Payment_Received__c,
                                    PropStrength__Outstanding_Balance__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Sequence__c, 
                                    PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Section__c, 
                                    PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Ongoing_Project__c,
                                    PropStrength__Property__r.Investor_Unit__c, PropStrength__Status__c 
                                    FROM PropStrength__Application_Booking__c  
                                    WHERE PropStrength__Property__r.PropStrength__Project_Name__c  != null
                                    AND  PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c =: recordId
                                    AND PropStrength__Property__r.PropStrength__Tower__c  != null 
                                    AND PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c  != null 
                                    ORDER BY PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.sequence__c ASC];
            }
            for(PropStrength__Application_Booking__c b : applicationList){
                if(tempDataMap.containsKey(b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c)){
                    AllWrapper wrap = tempDataMap.get(b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c);
                    if(b.PropStrength__Status__c == 'Audit Approved' && b.PropStrength__Property__c != null){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(wrap.totalPurchasePrice + (Long)b.PropStrength__Revised_Agreement_Amount__c):wrap.totalPurchasePrice;
                        wrap.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(wrap.totalMilestoneDueTillDate + (Long)b.PropStrength__Total_Payment_Due__c):wrap.totalMilestoneDueTillDate;
                        wrap.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(wrap.totalCollectedAmount + (Long)b.PropStrength__Total_Payment_Received__c):wrap.totalCollectedAmount;
                        if(b.PropStrength__Total_Payment_Due__c !=null && b.PropStrength__Total_Payment_Received__c!=null && ((Long)b.PropStrength__Total_Payment_Due__c  >  (Long)b.PropStrength__Total_Payment_Received__c)) {
                            wrap.dueAmount = wrap.dueAmount + (Long)b.PropStrength__Total_Payment_Due__c  -  (Long)b.PropStrength__Total_Payment_Received__c;
                        }
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c, wrap);
                    }
                    else if(b.PropStrength__Property__c != null && b.PropStrength__Property__r.Investor_Unit__c == true){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(wrap.totalPurchasePrice + (Long)b.PropStrength__Revised_Total_Sales_Consideration__c):wrap.totalPurchasePrice;
                        wrap.totalInvestorUnitValue = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(wrap.totalInvestorUnitValue + (Long)b.PropStrength__Revised_Total_Sales_Consideration__c):wrap.totalInvestorUnitValue;
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c, wrap);
                    }
                }
                else{
                    AllWrapper wrap = new AllWrapper();
                    wrap.subProjectId = b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c;
                    wrap.subProjectName = b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Name;
                    wrap.isOngoing = b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Ongoing_Project__c;
                    wrap.section = b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Section__c;
                    if(b.PropStrength__Status__c == 'Audit Approved' && b.PropStrength__Property__c != null){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(Long)b.PropStrength__Revised_Agreement_Amount__c:0;
                        wrap.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(Long)b.PropStrength__Total_Payment_Due__c:0;
                        wrap.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(Long)b.PropStrength__Total_Payment_Received__c:0;
                        if(b.PropStrength__Total_Payment_Due__c !=null && b.PropStrength__Total_Payment_Received__c!=null && ((Long)b.PropStrength__Total_Payment_Due__c  >  (Long)b.PropStrength__Total_Payment_Received__c)) {
                            wrap.dueAmount = wrap.dueAmount + (Long)b.PropStrength__Total_Payment_Due__c  -  (Long)b.PropStrength__Total_Payment_Received__c;
                        }
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c, wrap);
                    }
                    else if(b.PropStrength__Property__c != null && b.PropStrength__Property__r.Investor_Unit__c == true){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(Long)b.PropStrength__Revised_Total_Sales_Consideration__c:0;
                        wrap.totalInvestorUnitValue = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(Long)b.PropStrength__Revised_Total_Sales_Consideration__c:0;
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c, wrap);
                    }
                }
            }
            for(string subProjectId : tempDataMap.keySet()){
                AllWrapper w = tempDataMap.get(subProjectId);
             //   w.totalDueAmount = (w.totalMilestoneDueTillDate > w.totalCollectedAmount)?(w.totalMilestoneDueTillDate - w.totalCollectedAmount):0;
                w.totalDueAmount = w.dueAmount;
                if(projectToFutureDueList.containsKey(subProjectId)){
                    w.futureMilestoneDues = projectToFutureDueList.get(subProjectId);
                    long projectFutureCollections = 0;
                    for(long projectF : projectToFutureDueList.get(subProjectId)){
                        projectFutureCollections += projectF;
                    }
                    w.futureCollections = projectFutureCollections;
                }
                else{
                    list<long> tmpFutureDues = new list<long>();
                    for(string str : yearList){
                        tmpFutureDues.add(0);
                    }
                    w.futureMilestoneDues = tmpFutureDues;
                }
                integer s = w.futureMilestoneDues.size();
                for(integer i=s; i<yearList.size(); i++){
                    w.futureMilestoneDues.add(0);
                }
                dataMap.put(subProjectId,w);
            }
        }
        else if(type == 'Tower'){
            set<string> yearList = new set<string>();
            List<PropStrength__Payment_Plan_Details__c> pmList = [SELECT Id, PropStrength__Total_Amount_Due__c,PropStrength__Payment_Due_Date__c, PropStrength__Application_Booking__c, 
                                                                PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c, 
                                                                PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c,
                                                                PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c 
                                                                FROM PropStrength__Payment_Plan_Details__c 
                                                                WHERE PropStrength__Application_Booking__c != null 
                                                                AND PropStrength__Application_Booking__r.PropStrength__Status__c = 'Application Form Filled' 
                                                                AND PropStrength__Payment_Due_Date__c != null 
                                                                AND PropStrength__Payment_Due_Date__c >= TODAY
                                                                AND PropStrength__Application_Booking__r.PropStrength__Property__c != null 
                                                                ORDER BY PropStrength__Payment_Due_Date__c ASC];


            map<string,long> projectToFutureDues = new map<string,long>();
            map<string,list<long>> projectToFutureDueList = new map<string,list<long>>();

            for(PropStrength__Payment_Plan_Details__c p : pmList){
                Date dueDate = p.PropStrength__Payment_Due_Date__c;
                string dueDateYear = string.valueOf(dueDate.year());
                yearList.add(dueDateYear);
                string pId = p.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c + '##' + dueDateYear;
                if(projectToFutureDues.containsKey(pId)){
                    long dueAmt = projectToFutureDues.get(pId);
                    dueAmt = (p.PropStrength__Total_Amount_Due__c != null)?(dueAmt + (long)p.PropStrength__Total_Amount_Due__c):dueAmt; 
                    projectToFutureDues.put(pId, dueAmt);
                }
                else{
                    long dueAmt = (p.PropStrength__Total_Amount_Due__c != null)?(long)p.PropStrength__Total_Amount_Due__c:0;
                    projectToFutureDues.put(pId, dueAmt);
                }
            }
            map<string,long> projectToFutureDuesNew = new map<string,long>();
            set<string> keyList = projectToFutureDues.keySet();
            for(string pId : projectToFutureDues.keySet()){
                string actualPId = pId.split('##')[0];
                integer yr = Integer.valueOf(pId.split('##')[1]);
                for(string str : yearList){
                    string key = actualPId+'##'+str;
                    integer yrr = Integer.valueOf(str);
                    if((yrr <= yr)){
                        if(!keyList.contains(key)){
                            if(!projectToFutureDuesNew.containsKey(key))
                                projectToFutureDuesNew.put(key, 0);
                        }
                        if(yrr == yr) break;
                    }
                }
                projectToFutureDuesNew.put(pId,projectToFutureDues.get(pId));
            }
            for(string pId : projectToFutureDuesNew.keySet()){
                string actualPId = pId.split('##')[0];
                if(projectToFutureDueList.containsKey(actualPId)){
                    list<long> dueList = projectToFutureDueList.get(actualPId);
                    dueList.add(projectToFutureDuesNew.get(pId));
                    projectToFutureDueList.put(actualPId,dueList);
                }
                else{
                    projectToFutureDueList.put(actualPId, new list<long>{projectToFutureDuesNew.get(pId)});
                }
            }
            List<PropStrength__Application_Booking__c> applicationList = new List<PropStrength__Application_Booking__c>();
            applicationList = [SELECT Id, PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, 
                                PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Name, 
                                PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Revised_Agreement_Amount__c, PropStrength__Total_Payment_Due__c, PropStrength__Total_Payment_Received__c,
                                PropStrength__Outstanding_Balance__c, PropStrength__Property__r.Investor_Unit__c, PropStrength__Status__c, PropStrength__Property__r.PropStrength__Tower__r.sequence__c  
                                FROM PropStrength__Application_Booking__c 
                                WHERE PropStrength__Property__r.PropStrength__Project_Name__c != null 
                                AND PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c =: recordId
                                AND PropStrength__Property__r.PropStrength__Tower__c  != null 
                                AND PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c != null 
                                ORDER BY PropStrength__Property__r.PropStrength__Tower__r.sequence__c ASC];

            for(PropStrength__Application_Booking__c b : applicationList){
                if(tempDataMap.containsKey(b.PropStrength__Property__r.PropStrength__Tower__c)){
                    AllWrapper wrap = tempDataMap.get(b.PropStrength__Property__r.PropStrength__Tower__c);
                    if(b.PropStrength__Status__c == 'Audit Approved' && b.PropStrength__Property__c != null){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(wrap.totalPurchasePrice + (Long)b.PropStrength__Revised_Agreement_Amount__c):wrap.totalPurchasePrice;
                        wrap.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(wrap.totalMilestoneDueTillDate + (Long)b.PropStrength__Total_Payment_Due__c):wrap.totalMilestoneDueTillDate;
                        wrap.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(wrap.totalCollectedAmount + (Long)b.PropStrength__Total_Payment_Received__c):wrap.totalCollectedAmount;
                        if(b.PropStrength__Total_Payment_Due__c !=null && b.PropStrength__Total_Payment_Received__c!=null && ((Long)b.PropStrength__Total_Payment_Due__c  >  (Long)b.PropStrength__Total_Payment_Received__c)) {
                            wrap.dueAmount = wrap.dueAmount + (Long)b.PropStrength__Total_Payment_Due__c  -  (Long)b.PropStrength__Total_Payment_Received__c;
                        }
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__c, wrap);
                    }
                    else if(b.PropStrength__Property__c != null && b.PropStrength__Property__r.Investor_Unit__c == true){
                        wrap.totalUnit = wrap.totalUnit + 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(wrap.totalPurchasePrice + (Long)b.PropStrength__Revised_Total_Sales_Consideration__c):wrap.totalPurchasePrice;
                        wrap.totalInvestorUnitValue = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(wrap.totalInvestorUnitValue + (Long)b.PropStrength__Revised_Total_Sales_Consideration__c):wrap.totalInvestorUnitValue;
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__c, wrap);
                    }
                }
                else{
                    AllWrapper wrap = new AllWrapper();
                    wrap.towerId = b.PropStrength__Property__r.PropStrength__Tower__c;
                    wrap.towerName = b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c;
                    if(b.PropStrength__Status__c == 'Audit Approved' && b.PropStrength__Property__c != null){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(Long)b.PropStrength__Revised_Agreement_Amount__c:0;
                        wrap.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(Long)b.PropStrength__Total_Payment_Due__c:0;
                        wrap.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(Long)b.PropStrength__Total_Payment_Received__c:0;
                        if(b.PropStrength__Total_Payment_Due__c !=null && b.PropStrength__Total_Payment_Received__c!=null && ((Long)b.PropStrength__Total_Payment_Due__c  >  (Long)b.PropStrength__Total_Payment_Received__c)) {
                            wrap.dueAmount = wrap.dueAmount + (Long)b.PropStrength__Total_Payment_Due__c  -  (Long)b.PropStrength__Total_Payment_Received__c;
                        }
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__c, wrap);
                    }
                    else if(b.PropStrength__Property__c != null && b.PropStrength__Property__r.Investor_Unit__c == true){
                        wrap.totalUnit = 1;
                        wrap.totalPurchasePrice = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(Long)b.PropStrength__Revised_Total_Sales_Consideration__c:0;
                        wrap.totalInvestorUnitValue = (b.PropStrength__Revised_Total_Sales_Consideration__c!=null)?(Long)b.PropStrength__Revised_Total_Sales_Consideration__c:0;
                        tempDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__c, wrap);
                    }
                }
            }
            for(string subProjectId : tempDataMap.keySet()){
                AllWrapper w = tempDataMap.get(subProjectId);
                Long collectedInvestorVal = w.totalCollectedAmount + w.totalInvestorUnitValue;
                // w.totalDueAmount = (w.totalMilestoneDueTillDate > w.totalCollectedAmount)?(w.totalMilestoneDueTillDate - w.totalCollectedAmount):0;
                w.totalDueAmount = w.dueAmount;
                if(projectToFutureDueList.containsKey(subProjectId)){
                    w.futureMilestoneDues = projectToFutureDueList.get(subProjectId);
                    long projectFutureCollections = 0;
                    for(long projectF : projectToFutureDueList.get(subProjectId)){
                        projectFutureCollections += projectF;
                    }
                    w.futureCollections = projectFutureCollections;
                }
                else{
                    list<long> tmpFutureDues = new list<long>();
                    for(string str : yearList){
                        tmpFutureDues.add(0);
                    }
                    w.futureMilestoneDues = tmpFutureDues;
                }
                integer s = w.futureMilestoneDues.size();
                for(integer i=s; i<yearList.size(); i++){
                    w.futureMilestoneDues.add(0);
                }
                dataMap.put(subProjectId,w);
            }
        }
        else if(type == 'Unit'){
            map<string, list<PropStrength__Payment_Plan_Details__c>> bookingToPM = new map<string, list<PropStrength__Payment_Plan_Details__c>>();
            List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>();
            bookingList = [SELECT Id,PropStrength__Property__r.PropStrength__Tower__r.Due_Payments__c, PropStrength__Property__r.PropStrength__Tower__r.Advance_Payments__c, PropStrength__Property__c, 
                            PropStrength__Property__r.PropStrength__Property_Name__c, PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,
                            PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Name, 
                            PropStrength__Property__r.PropStrength__Project_Name__c, PropStrength__Property__r.PropStrength__Project_Name__r.Name, PropStrength__Revised_Agreement_Amount__c, PropStrength__Total_Payment_Due__c, 
                            PropStrength__Total_Payment_Received__c, PropStrength__Outstanding_Balance__c
                            FROM PropStrength__Application_Booking__c 
                            WHERE PropStrength__Status__c = 'Audit Approved' 
                            AND PropStrength__Property__r.PropStrength__Tower__c =: recordId 
                            AND PropStrength__Property__r.PropStrength__Tower__c != null];

            List<PropStrength__Payment_Plan_Details__c> pmList = [SELECT Id, PropStrength__Total_Amount_Due__c,PropStrength__Payment_Due_Date__c, PropStrength__Application_Booking__c, 
                                                                PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c, 
                                                                PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c,
                                                                PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c 
                                                                FROM PropStrength__Payment_Plan_Details__c 
                                                                WHERE PropStrength__Application_Booking__c != null 
                                                                AND PropStrength__Application_Booking__r.PropStrength__Status__c = 'Application Form Filled' 
                                                                AND PropStrength__Payment_Due_Date__c != null 
                                                                AND PropStrength__Payment_Due_Date__c >= TODAY
                                                                AND PropStrength__Application_Booking__r.PropStrength__Property__c != null 
                                                                ORDER BY PropStrength__Payment_Due_Date__c ASC];
            
            for(PropStrength__Payment_Plan_Details__c pm : pmList){
                if(bookingToPM.containsKey(pm.PropStrength__Application_Booking__c)){
                    list<PropStrength__Payment_Plan_Details__c> pms = bookingToPM.get(pm.PropStrength__Application_Booking__c);
                    pms.add(pm);
                    bookingToPM.put(pm.PropStrength__Application_Booking__c,pms);
                }
                else{
                    list<PropStrength__Payment_Plan_Details__c> pms = new list<PropStrength__Payment_Plan_Details__c>();
                    pms.add(pm);
                    bookingToPM.put(pm.PropStrength__Application_Booking__c,pms);
                }
            }
            
            for(PropStrength__Application_Booking__c b : bookingList){
                long duePayment = (Long) b.PropStrength__Property__r.PropStrength__Tower__r.Due_Payments__c;
                long advPayment = (Long) b.PropStrength__Property__r.PropStrength__Tower__r.Advance_Payments__c;
                long sum = 0;
                Integer diffDays = 0;
                Boolean milestoneHit = false;
                if(bookingToPM.containsKey(b.Id)){
                    for(PropStrength__Payment_Plan_Details__c pm : bookingToPM.get(b.Id)){
                        sum = sum + (long)pm.PropStrength__Total_Amount_Due__c;
                        if (sum > (long)b.PropStrength__Total_Payment_Received__c && !milestoneHit) {
                            Date milestoneDate = pm.PropStrength__Payment_Due_Date__c;
                            Date startDate = Date.today();
                            Date endDate = milestoneDate;
                            diffDays = endDate.daysBetween(startDate);
                            milestoneHit = true;
                        }
                    }
                }
                
                AllWrapper wrap = new AllWrapper();
                if(sum > (long) b.PropStrength__Total_Payment_Received__c){
                    if((sum - (long) b.PropStrength__Total_Payment_Received__c) >= duePayment){
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
                    if((sum - (long) b.PropStrength__Total_Payment_Received__c) <= advPayment){
                        wrap.bucketColor = 'background-color:#ADD8E6';
                    }
                }
                if((long) b.PropStrength__Total_Payment_Received__c >= sum ){
                    wrap.bucketColor = 'background-color:#ADD8E6';
                }
                wrap.towerId = '/'+b.PropStrength__Property__c;
                wrap.towerName = b.PropStrength__Property__r.PropStrength__Property_Name__c;
                wrap.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(Long)b.PropStrength__Revised_Agreement_Amount__c:0;
                wrap.totalDemandTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(Long)b.PropStrength__Total_Payment_Due__c:0;
                wrap.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(Long)b.PropStrength__Total_Payment_Due__c:0;
                wrap.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(Long)b.PropStrength__Total_Payment_Received__c:0;
                wrap.totalDueAmount = b.PropStrength__Total_Payment_Due__c > b.PropStrength__Total_Payment_Received__c ? (Long)b.PropStrength__Total_Payment_Due__c -  (Long)b.PropStrength__Total_Payment_Received__c : 0;
                wrap.totalAdvanceAmount = (b.PropStrength__Outstanding_Balance__c!=null)?(Long)b.PropStrength__Outstanding_Balance__c:0;
                dataMap.put(b.PropStrength__Property__c, wrap);
            }
        }
        return dataMap.values();
    }
    
    @AuraEnabled
    public static list<AllWrapper> getAgeingData(string towerId){
        map<string,AllWrapper> dataMap = new map<string,AllWrapper>();
        list<AllWrapper> sortedList = new list<AllWrapper>();
        map<string, list<PropStrength__Payment_Plan_Details__c>> bookingToPM = new map<string, list<PropStrength__Payment_Plan_Details__c>>();
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>();
        bookingList = [SELECT Id, PropStrength__Property__r.PropStrength__Tower__r.Due_Payments__c, PropStrength__Property__r.PropStrength__Tower__r.Advance_Payments__c, 
                        PropStrength__Property__c, PropStrength__Property__r.PropStrength__Property_Name__c, PropStrength__Property__r.PropStrength__Tower__c, 
                        PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c, 
                        PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__r.Name, PropStrength__Property__r.PropStrength__Project_Name__c, 
                        PropStrength__Property__r.PropStrength__Project_Name__r.Name, PropStrength__Revised_Agreement_Amount__c, PropStrength__Total_Payment_Received__c, 
                        PropStrength__Total_Payment_Due__c, PropStrength__Outstanding_Balance__c 
                        FROM PropStrength__Application_Booking__c 
                        WHERE PropStrength__Status__c  = 'Audit Approved' 
                        AND PropStrength__Property__r.PropStrength__Tower__c =: towerId 
                        AND PropStrength__Property__r.PropStrength__Tower__c != null
        ];
        List<PropStrength__Payment_Plan_Details__c> pmList = [SELECT Id, PropStrength__Total_Amount_Due__c,PropStrength__Payment_Due_Date__c, PropStrength__Application_Booking__c, 
                                                                PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c, 
                                                                PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c,
                                                                PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Project_Name__c 
                                                                FROM PropStrength__Payment_Plan_Details__c 
                                                                WHERE PropStrength__Application_Booking__c != null 
                                                                AND PropStrength__Application_Booking__r.PropStrength__Status__c = 'Application Form Filled' 
                                                                AND PropStrength__Payment_Due_Date__c != null 
                                                                AND PropStrength__Payment_Due_Date__c >= TODAY
                                                                AND PropStrength__Application_Booking__r.PropStrength__Property__c != null 
                                                                ORDER BY PropStrength__Payment_Due_Date__c ASC];
        
        for(PropStrength__Payment_Plan_Details__c pm : pmList){
            if(bookingToPM.containsKey(pm.PropStrength__Application_Booking__c)){
                list<PropStrength__Payment_Plan_Details__c> pms = bookingToPM.get(pm.PropStrength__Application_Booking__c);
                pms.add(pm);
                bookingToPM.put(pm.PropStrength__Application_Booking__c,pms);
            }
            else{
                list<PropStrength__Payment_Plan_Details__c> pms = new list<PropStrength__Payment_Plan_Details__c>();
                pms.add(pm);
                bookingToPM.put(pm.PropStrength__Application_Booking__c,pms);
            }
        }
        for(PropStrength__Application_Booking__c b : bookingList){
            long duePayment = (Long) b.PropStrength__Property__r.PropStrength__Tower__r.Due_Payments__c;
            long advPayment = (Long) b.PropStrength__Property__r.PropStrength__Tower__r.Advance_Payments__c;
            long sum = 0;
            Integer diffDays = 0;
            Boolean milestoneHit = false;
            if(bookingToPM.containsKey(b.Id)){
                for(PropStrength__Payment_Plan_Details__c pm : bookingToPM.get(b.Id)){
                    sum = sum + (long)pm.PropStrength__Total_Amount_Due__c;
                    if (sum > (long)b.PropStrength__Total_Payment_Received__c && !milestoneHit) {
                        Date milestoneDate = pm.PropStrength__Payment_Due_Date__c;
                        Date startDate = Date.today();
                        Date endDate = milestoneDate;
                        diffDays = endDate.daysBetween(startDate);
                        milestoneHit = true;
                    }
                }
            }
            string bucketColor = '';
            string bucketColorLabel = '';
            if(sum > (long) b.PropStrength__Total_Payment_Received__c){
                if((sum - (long) b.PropStrength__Total_Payment_Received__c) >= duePayment){
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
                if((sum - (long) b.PropStrength__Total_Payment_Received__c) <= advPayment){
                    bucketColor = 'Blue';
                    bucketColorLabel = 'Blue (No Due Amount)';
                }
            }
            if((long) b.PropStrength__Total_Payment_Received__c >= sum ){
                bucketColor = 'Blue';
                bucketColorLabel = 'Blue (No Due Amount)';
            }
            if(dataMap.containsKey(bucketColor)){
                AllWrapper wrap = dataMap.get(bucketColor);
                wrap.totalUnit = wrap.totalUnit + 1;
                wrap.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(wrap.totalPurchasePrice + (Long)b.PropStrength__Revised_Agreement_Amount__c):wrap.totalPurchasePrice;
                wrap.totalDemandTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(wrap.totalDemandTillDate + (Long)b.PropStrength__Total_Payment_Due__c):wrap.totalDemandTillDate;
                wrap.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(wrap.totalMilestoneDueTillDate + (Long)b.PropStrength__Total_Payment_Due__c):wrap.totalMilestoneDueTillDate;
                wrap.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(wrap.totalCollectedAmount + (Long)b.PropStrength__Total_Payment_Received__c):wrap.totalCollectedAmount;
               wrap.totalDueAmount = (b.PropStrength__Outstanding_Balance__c!=null)?b.PropStrength__Outstanding_Balance__c > 0 ? wrap.totalDueAmount + (Long)b.PropStrength__Outstanding_Balance__c: 0 : wrap.totalDueAmount;
               wrap.totalAdvanceAmount = (b.PropStrength__Outstanding_Balance__c!=null)?(wrap.totalAdvanceAmount + (Long)b.PropStrength__Outstanding_Balance__c):wrap.totalAdvanceAmount;
                dataMap.put(bucketColor, wrap);
            }
            else{
                AllWrapper wrap = new AllWrapper();
                wrap.towerId = bucketColor;
                wrap.towerName = bucketColorLabel;
                wrap.totalUnit = 1;
                wrap.totalPurchasePrice = (b.PropStrength__Revised_Agreement_Amount__c!=null)?(Long)b.PropStrength__Revised_Agreement_Amount__c:0;
                wrap.totalDemandTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(Long)b.PropStrength__Total_Payment_Due__c:0;
                wrap.totalMilestoneDueTillDate = (b.PropStrength__Total_Payment_Due__c!=null)?(Long)b.PropStrength__Total_Payment_Due__c:0;
                wrap.totalCollectedAmount = (b.PropStrength__Total_Payment_Received__c!=null)?(Long)b.PropStrength__Total_Payment_Received__c:0;
                wrap.totalDueAmount = (b.PropStrength__Outstanding_Balance__c!=null)?b.PropStrength__Outstanding_Balance__c > 0 ?(Long)b.PropStrength__Outstanding_Balance__c: 0 : 0;
                wrap.totalAdvanceAmount = (b.PropStrength__Outstanding_Balance__c!=null)?(Long)b.PropStrength__Outstanding_Balance__c:0;
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
        @AuraEnabled public long dueAmount;
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
            dueAmount=0;
            totalAdvanceAmount=0;
            totalInvestorUnitValue=0;
            futureCollections=0;
            futureMilestoneDues = new list<long>();
            bucketColor='';
            section='';
            isOngoing=false;
        }
    }
}