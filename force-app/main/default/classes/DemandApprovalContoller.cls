public with sharing class DemandApprovalContoller{

public Map<String,List<String>> projectTowerMap {get;set;}
    public String projectName {get;set;}
    public String towername {get;set;}
    public PaginationController.PaginationWrapper pgw;
    public Map<Id,List<DemandWrapper>> customerTowerMap {get;set;}
    public Map<Id, CustomerWrapper> CustomerWrapperMap {get;set;}
    public List<Id> customerList {get;set;}
    public String groupDemandPreviewId {get;set;}
    public String singleDemandPreviewId {get;set;}  
    public Boolean isRaiseDemandDashboard {get;set;}  
    public Id ProfileId;
    public static String ProfileName {get;set;}
    public String customerName {get;set;}
    public String unitName {get;set;}
    
    public DemandApprovalContoller() {   
        customerName = '';
        unitName = '';        
        ProfileId = UserInfo.getProfileId();
        ProfileName = [SELECT Id, Name FROM Profile WHERE Id = :ProfileId].Name;
        getAllDemands();
        pgw = new PaginationController.PaginationWrapper();
        pgw.list_size = 100;
        pgw.counter = 0;
        pgw.total_size = 1000;
        isRaiseDemandDashboard = false;
    }
        
    public void getAllDemands() {
        // this will get the list of all the project and the tower names under which we have pending demands to be raised            
        projectTowerMap = getAllPendingDemands();
    }
    
    public static Map <String, List <String>> getAllPendingDemands() {
        List <Payment_Milestones__c> paymentMilestoneList = new List <Payment_Milestones__c> ();
    
    /// Collection query    
        if(ProfileName == 'Collection'){
            paymentMilestoneList = [Select Id, Name, Milestone_Name__c, Demand_Raised__c, Quotation__r.Unit__r.Project__r.Name, Quotation__r.Unit__r.Tower__R.Name, Construction_Stage_Actual_CompletionDate__c, Invoice_Due_Date__c
                from Payment_Milestones__c
                where Quotation__c != null
                and Quotation__r.Booking__c != null
                and Quotation__r.Unit__c != null
                and Quotation__r.Unit__r.Project__c != null
                and Quotation__r.Unit__r.Tower__c != null
                and Quotation__r.Opportunity__r.S_Active__c = true
                and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'                
                and Quotation__r.Unit__r.Unit_Status__c = 'Sold'
                and Quotation__r.Booking__r.Stage_of_Booking__c = 'Booked'
                and Quotation__r.Booking__r.Status__c = 'Processed' 
                and is_demand_raised__c = false
                and Collection_Status__c != 'Submitted'
                and(
                      (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) 
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                   )
                order by Quotation__r.Opportunity__r.Name, Milestone_Due_Date__c asc];
        } 
   /// Finance query     
        if(ProfileName == 'Finance'){
            paymentMilestoneList = [Select Id, Name, Milestone_Name__c, Demand_Raised__c, Quotation__r.Unit__r.Project__r.Name, Quotation__r.Unit__r.Tower__R.Name, Construction_Stage_Actual_CompletionDate__c, Invoice_Due_Date__c
                from Payment_Milestones__c
                where Quotation__c != null
                and Quotation__r.Booking__c != null
                and Quotation__r.Unit__c != null
                and Quotation__r.Unit__r.Project__c != null
                and Quotation__r.Unit__r.Tower__c != null
                and Quotation__r.Opportunity__r.S_Active__c = true
                and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'
                and Quotation__r.Unit__r.Unit_Status__c = 'Sold'
                and Quotation__r.Booking__r.Stage_of_Booking__c = 'Booked'
                and Quotation__r.Booking__r.Status__c = 'Processed'
                and is_demand_raised__c = false
                and Collection_Status__c = 'Submitted' 
                and Finance_Status__c != 'Accepted'
               /* and(
                      (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) 
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                   )*/
                order by Quotation__r.Opportunity__r.Name, Milestone_Due_Date__c asc];
        }
        
     /// Audit query     
        if(ProfileName == 'Audit'){
            paymentMilestoneList = [Select Id, Name, Milestone_Name__c, Demand_Raised__c, Quotation__r.Unit__r.Project__r.Name, Quotation__r.Unit__r.Tower__R.Name, Construction_Stage_Actual_CompletionDate__c, Invoice_Due_Date__c
                from Payment_Milestones__c
                where Quotation__c != null
                and Quotation__r.Booking__c != null
                and Quotation__r.Unit__c != null
                and Quotation__r.Unit__r.Project__c != null
                and Quotation__r.Unit__r.Tower__c != null
                and Quotation__r.Opportunity__r.S_Active__c = true
                and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'
                and Quotation__r.Unit__r.Unit_Status__c = 'Sold'
                and Quotation__r.Booking__r.Stage_of_Booking__c = 'Booked'
                and Quotation__r.Booking__r.Status__c = 'Processed' 
                and is_demand_raised__c = false
                and Collection_Status__c = 'Submitted'
                and Finance_Status__c = 'Accepted'
                and Audit_Status__c != 'Accepted'
               /* and(
                      (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) 
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                   )*/
                order by Quotation__r.Opportunity__r.Name, Milestone_Due_Date__c asc];
        }
        
     /// CFO query     
        if(ProfileName == 'CFO'){
            paymentMilestoneList = [Select Id, Name, Milestone_Name__c, Demand_Raised__c, Quotation__r.Unit__r.Project__r.Name, Quotation__r.Unit__r.Tower__R.Name, Construction_Stage_Actual_CompletionDate__c, Invoice_Due_Date__c
                from Payment_Milestones__c
                where Quotation__c != null
                and Quotation__r.Booking__c != null
                and Quotation__r.Unit__c != null
                and Quotation__r.Unit__r.Project__c != null
                and Quotation__r.Unit__r.Tower__c != null
                and Quotation__r.Opportunity__r.S_Active__c = true
                and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'
                and Quotation__r.Unit__r.Unit_Status__c = 'Sold'
                and Quotation__r.Booking__r.Stage_of_Booking__c = 'Booked'
                and Quotation__r.Booking__r.Status__c = 'Processed'
                and is_demand_raised__c = false
                and Collection_Status__c = 'Submitted'
                and Finance_Status__c = 'Accepted'
                and Audit_Status__c = 'Accepted'
                and CFO_Status__c != 'Accepted'
              /*  and(
                      (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) 
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                   )*/
                order by Quotation__r.Opportunity__r.Name, Milestone_Due_Date__c asc];
        }        
           
        Map <String, List <String>> projectTowerMap = new Map <String, List <String>> ();
        Boolean exists;
        
        if (paymentMilestoneList != null && !paymentMilestoneList.isEmpty()) {
            for (Payment_Milestones__c pm: paymentMilestoneList) {
                exists = false;
                if (projectTowerMap.containsKey(pm.Quotation__r.Unit__r.Project__r.Name)) {
                    List <String> tempList = projectTowerMap.get(pm.Quotation__r.Unit__r.Project__r.Name);

                    for (String s: tempList) {
                        if (s.equalsIgnoreCase(pm.Quotation__r.Unit__r.Tower__r.Name)) {
                            exists = true;
                            break;
                        }
                    }
                    if (!exists) {
                        tempList.add(pm.Quotation__r.Unit__r.Tower__r.Name);
                        projectTowerMap.put(pm.Quotation__r.Unit__r.Project__r.Name, tempList);
                    }
                } else {
                    List < String > tempList = new List < String > ();
                    tempList.add(pm.Quotation__r.Unit__r.Tower__r.Name);
                    projectTowerMap.put(pm.Quotation__r.Unit__r.Project__r.Name, tempList);
                }
            }
        }

        return projectTowerMap;
    }
    
    public void getCustomersTowerWise() {
       
        ProfileName = [SELECT Id, Name FROM Profile WHERE Id = :ProfileId].Name;
              
        customerTowerMap = new Map<Id, List<DemandWrapper>>();
        customerList = new List<Id>();
        customerWrapperMap = new Map<Id, CustomerWrapper>();
        towerName = Apexpages.currentPage().getParameters().get('towerName');
        projectName = Apexpages.currentPage().getParameters().get('projectName');
        pgw = new PaginationController.PaginationWrapper();
        pgw.list_size = 50; // Displays 2 records
        pgw.counter = 0;
        customerTowerMap = searchAllPendingDemandsWithGrouping(towerName, projectName, pgw.list_size, pgw.counter); 
        customerList.addAll(customerTowerMap.keySet());
        CustomerWrapperMap = getCustomerWrapper(customerTowerMap.keySet());
        pgw.total_size = 1000;        
    }
    
    public static Map < Id, List < DemandWrapper >> searchAllPendingDemandsWithGrouping(String towerName, String projectName, Integer list_size, Integer counter) {
            Id proId = UserInfo.getProfileId();
            ProfileName = [SELECT Id, Name FROM Profile WHERE Id = :proId].Name;
        List < Payment_Milestones__c > paymentMilestoneList = new List < Payment_Milestones__c > ();
        String tempQuery = '';
        for (Integer i = 1; i <= 25; i++) {
            tempQuery += 'Charge' + i + 'Name__c' + ',';
            tempQuery += 'Charge' + i + 'Percentage__c' + ',';
            tempQuery += 'C' + i + '_Amount__c' + ',';
            tempQuery += 'C' + i + '_SGST__c' + ',';
            tempQuery += 'C' + i + '_CGST__c' + ',';

        }
        String tempQuery1 = '';
        for (Integer i = 1; i <= 25; i++) {
            tempQuery1 += 'Charge_' + i + '_Lookup__r.ChargeBucket__c,';
        }
        // remove the last character only if its a comma.
        if (tempQuery1.length() > 0 && tempQuery1.substring(tempQuery1.length() - 1).equals(','))
            tempQuery1 = tempQuery1.substring(0, tempQuery1.length() - 1);
       String query = ''; 
       /// Collection query    
        if(ProfileName == 'Collection'){ 
          query = 'Select Id,Quotation__r.Unit__r.Project__r.Group_Demands_By_Customer__c, Quotation__r.Opportunity__r.Primary_Email__c, Quotation__r.Opportunity__r.Primary_Name__c, Name, Milestone_Name__c, Milestone_Type_Text__c,Milestone_Type_edit__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Number_Of_Days__c, Demand_Raised__c, Quotation__r.Name, Quotation__r.Unit__r.Project__r.Name, Invoice_Due_Date__c,' +
            'Quotation__r.Unit__r.Tower__R.Name, Is_Combination_Milestone__c,' +
            'Quotation__r.Unit__r.Customers__r.Name, Construction_Stage_Actual_CompletionDate__c,' +
            'Quotation__R.Opportunity__r.Name,' +
            'Quotation__R.Opportunity__r.latest_demand_due_date__c,' +
            'Quotation__R.Opportunity__c,' +
            'Quotation__R.Unit__c,' +
            'Quotation__r.Booking__r.Booking_Date__c,' +
            'Quotation__R.Unit__r.Name,' + tempQuery + tempQuery1 +
            ' from Payment_Milestones__c ' +
            ' where ' +
            ' ( ' +
            ' (Milestone_Type_edit__c = \'Construction Linked\' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) OR ' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15) OR' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)' +
            ' ) ' +
            ' and Quotation__c != null ' +
            ' and Quotation__r.Booking__c != null ' +
            ' and Quotation__r.Unit__c != null ' +
            ' and Quotation__r.Unit__r.Project__r.Name = ' + '\'' + projectName + '\'' +
            ' and Quotation__r.Unit__r.Tower__r.Name = ' + '\'' + towerName + '\'' +
            ' and Quotation__r.Opportunity__r.S_Active__c = true ' +
            ' and Quotation__r.Opportunity__r.StageName =  \'Booking confirmed\' ' +
            ' and Quotation__r.Unit__r.Unit_Status__c = \'Sold\' ' +
            ' and Quotation__r.Booking__r.Status__c = \'Processed\' '+
            ' and Quotation__r.Booking__r.Stage_of_Booking__c = \'Booked\' '+
            ' and is_demand_raised__c = false ' + 
            ' and Collection_Status__c != \'Submitted\' '+                   
            ' order by Milestone_Due_Date__c asc ' +
            ' limit :list_size ' +
            ' offset :counter ';
        } 
        
        /// Finance query    
        if(ProfileName == 'Finance'){ 
           query = 'Select Id,Quotation__r.Unit__r.Project__r.Group_Demands_By_Customer__c, Quotation__r.Opportunity__r.Primary_Email__c, Quotation__r.Opportunity__r.Primary_Name__c,  Name, Milestone_Name__c, Milestone_Type_Text__c,Milestone_Type_edit__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Number_Of_Days__c, Demand_Raised__c, Quotation__r.Name, Quotation__r.Unit__r.Project__r.Name, Invoice_Due_Date__c,' +
            'Quotation__r.Unit__r.Tower__R.Name, Is_Combination_Milestone__c,' +
            'Quotation__r.Unit__r.Customers__r.Name, Construction_Stage_Actual_CompletionDate__c,' +
            'Quotation__R.Opportunity__r.Name,' +
            'Quotation__R.Opportunity__r.latest_demand_due_date__c,' +
            'Quotation__R.Opportunity__c,' +
            'Quotation__R.Unit__c,' +
            'Quotation__r.Booking__r.Booking_Date__c,' +
            'Quotation__R.Unit__r.Name,' + tempQuery + tempQuery1 +
            ' from Payment_Milestones__c ' +
            ' where ' +
         /*   ' ( ' +
            ' (Milestone_Type_edit__c = \'Construction Linked\' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) OR ' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15) OR' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)' +
            ' ) ' +*/
            ' Quotation__c != null ' + //and
            ' and Quotation__r.Booking__c != null ' +
            ' and Quotation__r.Unit__c != null ' +
            ' and Quotation__r.Unit__r.Project__r.Name = ' + '\'' + projectName + '\'' +
            ' and Quotation__r.Unit__r.Tower__r.Name = ' + '\'' + towerName + '\'' +
            ' and Quotation__r.Opportunity__r.S_Active__c = true ' +
            ' and Quotation__r.Opportunity__r.StageName =  \'Booking confirmed\' ' +
            ' and Quotation__r.Unit__r.Unit_Status__c = \'Sold\' ' +
            ' and Quotation__r.Booking__r.Status__c = \'Processed\' '+
            ' and Quotation__r.Booking__r.Stage_of_Booking__c = \'Booked\' '+
            ' and is_demand_raised__c = false ' + 
            ' and Collection_Status__c = \'Submitted\' '+  
            ' and Finance_Status__c != \'Accepted\' '+          
            ' order by Milestone_Due_Date__c asc ' +
            ' limit :list_size ' +
            ' offset :counter ';
        }   
        
        /// Audit query    
        if(ProfileName == 'Audit'){ 
           query = 'Select Id,Quotation__r.Unit__r.Project__r.Group_Demands_By_Customer__c, Quotation__r.Opportunity__r.Primary_Email__c, Quotation__r.Opportunity__r.Primary_Name__c,  Name, Milestone_Name__c, Milestone_Type_Text__c,Milestone_Type_edit__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Number_Of_Days__c, Demand_Raised__c, Quotation__r.Name, Quotation__r.Unit__r.Project__r.Name, Invoice_Due_Date__c,' +
            'Quotation__r.Unit__r.Tower__R.Name, Is_Combination_Milestone__c,' +
            'Quotation__r.Unit__r.Customers__r.Name, Construction_Stage_Actual_CompletionDate__c,' +
            'Quotation__R.Opportunity__r.Name,' +
            'Quotation__R.Opportunity__r.latest_demand_due_date__c,' +
            'Quotation__R.Opportunity__c,' +
            'Quotation__R.Unit__c,' +
            'Quotation__r.Booking__r.Booking_Date__c,' +
            'Quotation__R.Unit__r.Name,' + tempQuery + tempQuery1 +
            ' from Payment_Milestones__c ' +
            ' where ' +
         /*   ' ( ' +
            ' (Milestone_Type_edit__c = \'Construction Linked\' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:Today) OR ' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15) OR' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)' +
            ' ) ' */
            ' Quotation__c != null ' + //and 
            ' and Quotation__r.Booking__c != null ' +
            ' and Quotation__r.Unit__c != null ' +
            ' and Quotation__r.Unit__r.Project__r.Name = ' + '\'' + projectName + '\'' +
            ' and Quotation__r.Unit__r.Tower__r.Name = ' + '\'' + towerName + '\'' +
            ' and Quotation__r.Opportunity__r.S_Active__c = true ' +
            ' and Quotation__r.Opportunity__r.StageName =  \'Booking confirmed\' ' +
            ' and Quotation__r.Unit__r.Unit_Status__c = \'Sold\' ' + 
            ' and Quotation__r.Booking__r.Status__c = \'Processed\' '+
            ' and Quotation__r.Booking__r.Stage_of_Booking__c = \'Booked\' '+
            ' and is_demand_raised__c = false ' + 
            ' and Collection_Status__c = \'Submitted\''+   
            ' and Finance_Status__c = \'Accepted\' '+  
            ' and Audit_Status__c != \'Accepted\' ' +      
            ' order by Milestone_Due_Date__c asc ' +
            ' limit :list_size ' +
            ' offset :counter ';
        }   
        
        /// CFO query    
        if(ProfileName == 'CFO'){ 
          query = 'Select Id,Quotation__r.Unit__r.Project__r.Group_Demands_By_Customer__c, Quotation__r.Opportunity__r.Primary_Email__c, Quotation__r.Opportunity__r.Primary_Name__c,  Name, Milestone_Name__c, Milestone_Type_Text__c,Milestone_Type_edit__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Number_Of_Days__c, Demand_Raised__c, Quotation__r.Name, Quotation__r.Unit__r.Project__r.Name, Invoice_Due_Date__c,' +
            'Quotation__r.Unit__r.Tower__R.Name, Is_Combination_Milestone__c, ' +
            'Quotation__r.Unit__r.Customers__r.Name, Construction_Stage_Actual_CompletionDate__c,' +
            'Quotation__R.Opportunity__r.Name,' +
            'Quotation__R.Opportunity__r.latest_demand_due_date__c,' +
            'Quotation__R.Opportunity__c,' +
            'Quotation__R.Unit__c,' +
            'Quotation__r.Booking__r.Booking_Date__c,' +
            'Quotation__R.Unit__r.Name,' + tempQuery + tempQuery1 +
            ' from Payment_Milestones__c ' +
            ' where ' +
         /*   ' ( ' +
            ' (Milestone_Type_edit__c = \'Construction Linked\' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) OR ' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15) OR' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null  and Milestone_Due_Date__c <= NEXT_N_DAYS:15)' +
            ' ) ' + */
            ' Quotation__c != null ' + //and 
            ' and Quotation__r.Booking__c != null ' +
            ' and Quotation__r.Unit__c != null ' +
            ' and Quotation__r.Unit__r.Project__r.Name = ' + '\'' + projectName + '\'' +
            ' and Quotation__r.Unit__r.Tower__r.Name = ' + '\'' + towerName + '\'' +
            ' and Quotation__r.Opportunity__r.S_Active__c = true ' +
            ' and Quotation__r.Opportunity__r.StageName =  \'Booking confirmed\' ' +
            ' and Quotation__r.Unit__r.Unit_Status__c = \'Sold\' ' +
            ' and Quotation__r.Booking__r.Status__c = \'Processed\' '+
            ' and Quotation__r.Booking__r.Stage_of_Booking__c = \'Booked\' '+
            '  and is_demand_raised__c = false ' +  
            ' and Collection_Status__c = \'Submitted\''+
            ' and Finance_Status__c = \'Accepted\' '+  
            ' and Audit_Status__c = \'Accepted\' ' +   
            ' and CFO_Status__c != \'Accepted\' ' +         
            ' order by Milestone_Due_Date__c asc ' +
            ' limit :list_size ' +
            ' offset :counter ';
        }           
        if(query != '')   
        paymentMilestoneList = Database.Query(query);
         
        Decimal overallAmt = 0;
        Decimal overallTax1 = 0;
        Decimal overallTax2 = 0;
        Integer j = 1;
        List < DemandWrapper > dwList = new List < DemandWrapper > ();

        if (paymentMilestoneList != null && paymentMilestoneList.size() > 0) {
            for (Payment_Milestones__c p: paymentMilestoneList) {
                List < PrintChargesWrapper > temp = new List < PrintChargesWrapper > ();
                PrintTotalsWrapper temp1 = new PrintTotalsWrapper();
                DemandWrapper dw = new DemandWrapper();
                // if its date linked demand, the invoice date will be date on which demand is raised and invoice due date will be the actual date
                // generally the invoice is to be raised 15 days prior to the due date
                if (p.Milestone_Type_edit__c.equalsIgnoreCase('Date Linked') && p.Is_Combination_Milestone__c == false) {
                        p.Invoice_Date__c = system.today();
                        p.Invoice_Due_Date__c = p.Milestone_Due_Date__c;               
                }
                /// if its construction linked demand, the invoice date and invoice due date will be the date on which demand is raised
                else if(p.Milestone_Type_edit__c.equalsIgnoreCase('Construction Linked')){
                    p.Invoice_Date__c = system.today();
                    p.Invoice_Due_Date__c = system.today();
                }
                else if(p.Milestone_Type_edit__c.equalsIgnoreCase('Date Linked') && p.Is_Combination_Milestone__c == true){
                    if(p.Construction_Stage_Actual_CompletionDate__c != null){
                        p.Invoice_Date__c = system.today();
                        p.Invoice_Due_Date__c = p.Milestone_Due_Date__c;       
                    } else {
                        p.Invoice_Date__c = system.today();
                        p.Invoice_Due_Date__c = system.today();    
                    }
                }
            /*    if(p.Quotation__r.Opportunity__r.Latest_Demand_Due_Date__c != null && p.Invoice_Due_Date__c < p.Quotation__r.Opportunity__r.Latest_Demand_Due_Date__c) {
                        p.Invoice_Due_Date__c = p.Quotation__r.Opportunity__r.Latest_Demand_Due_Date__c;
                }*/
                system.debug('Invoice due date::: ' + p.Invoice_Due_Date__c);
                for (Integer i = 1; i <= 25; i++) {
                    PrintChargesWrapper pcw = new PrintChargesWrapper();
                    
                    if (
                        p.getSObject('Charge_' + i + '_Lookup__r') != null &&
                        (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
                        String.isNotBlank((String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
                        (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Agreement Value'
                    ) {
                        if ((String) p.get('Charge' + i + 'Name__c') != null && String.isNotBlank((String) p.get('Charge' + i + 'Name__c'))) {
                            pcw.chargeName = (String) p.get('Charge' + i + 'Name__c');
                            if (p.get('Charge' + i + 'Percentage__c') != null)
                                pcw.percentage = String.valueOf((Decimal) p.get('Charge' + i + 'Percentage__c')) + ' %';
                            else
                                pcw.percentage = '';
                            if (p.get('C' + i + '_Amount__c') != null) {
                                pcw.Amount = InventoryCostServices.InFormat((Decimal) p.get('C' + i + '_Amount__c'));
                                overallAmt += (Decimal) p.get('C' + i + '_Amount__c');
                            } else
                                pcw.Amount = '';
                            if (p.get('C' + i + '_SGST__c') != null) {
                                pcw.Tax1 = InventoryCostServices.InFormat((Decimal) p.get('C' + i + '_SGST__c'));
                                overallTax1 += (Decimal) p.get('C' + i + '_SGST__c');
                            } else
                                pcw.Tax1 = '';
                            if (p.get('C' + i + '_CGST__c') != null) {
                                pcw.Tax2 = InventoryCostServices.InFormat((Decimal) p.get('C' + i + '_CGST__c'));
                                system.debug('cgst::: ' + pcw.Tax2);
                                overallTax2 += (Decimal) p.get('C' + i + '_CGST__c');
                                system.debug('cgst::: ' + overallTax2);
                            } else
                                pcw.Tax2 = '';
                            temp.add(pcw); // adding each charge of this milestone to the charge list
                        }
                    }
                }
                // adding the overall value of this milestone to the totals wrapper
                temp1.overallAmt = InventoryCostServices.Informat(overallAmt);
                temp1.overallTax1 = InventoryCostServices.Informat(overallTax1);
                temp1.overallTax2 = InventoryCostServices.Informat(overallTax2);
                if (String.isNotBlank(p.Milestone_Name__c)) {
                    String[] tempStr = p.Milestone_Name__c.split(':');
                    if (tempStr.size() == 2)
                        temp1.milestoneName = tempStr[1];
                    else
                        temp1.milestoneName = tempStr[0];
                }
                // put all of these together into the demands wrapper.
                dw.pm = p;
                dw.pcwList.addAll(temp);
                dw.ptw = temp1;
                dwList.add(dw);
                j++;
                overAllAmt = 0;
                overallTax1 = 0;
                overallTax2 = 0;
            }

        }
        Map < Id, List < DemandWrapper >> CustomerMap = new Map < Id, List < DemandWrapper >> ();
            for (DemandWrapper dw: dwList) {
                if (customerMap.containsKey(dw.pm.Quotation__R.Unit__c))
                    customerMap.get(dw.pm.Quotation__R.Unit__c).add(dw);
                else {
                    List < DemandWrapper > dwListTemp = new List < DemandWrapper > ();
                    dwListTemp.add(dw);
                    customerMap.put(dw.pm.Quotation__R.Unit__c, dwListTemp);
                }

            }            
        return customerMap;
    }
    
     public static Map < Id, CustomerWrapper > getCustomerWrapper(Set < Id > unitIdSet) {
        Map < Id, CustomerWrapper > CustomerWrapperMap = new Map < Id, CustomerWrapper > ();
        List < Opportunity > oppList = [Select id, Name, Account.PersonEmail, Primary_Email__c, Primary_Name__c,Unit__r.Name from Opportunity 
                                        where unit__c in: unitIdSet and stageName = 'Booking confirmed'
                                        and S_Active__c = true order by createdDate asc];
        Integer count = 1;
        for (Opportunity o: oppList) {
            CustomerWrapper cw = new CustomerWrapper();
            cw.o = o;
            if (Math.mod(count, 2) == 1)
                cw.styleName = 'color1';
            else
                cw.styleName = 'color2';
            customerWrapperMap.put(o.unit__c, cw);
            count++;
        }
        return customerWrapperMap;
    }    
    
     public PageReference showPreview() {
             
        PageReference pageRef = new PageReference('/apex/DemandViewNew');
        pageRef.getParameters().put('mode','preview');
        pageRef.getParameters().put('letterHead','1');
        pageRef.getParameters().put('previewId',groupDemandPreviewId);
        pageRef.getParameters().put('invoiceNumber','NOT GENERATED');
        pageRef.getParameters().put('isRaiseDemanddashboard', 'false');
        if(singleDemandPreviewId != null && String.isNotBlank(singleDemandPreviewId)) {
            // user wants to raise demand for a single milestone within a group of milestones which are due
            pageRef.getParameters().put('forMilestone',singleDemandPreviewId);
        } 
        return pageRef;
    }
    
//// Submit method for Collection    
    public void SubmitMultipleDemands(){
        ProfileName = [SELECT Id, Name FROM Profile WHERE Id = :ProfileId].Name;
        Set<Id> groupDemandId = new Set<Id>();
        List <Payment_Milestones__c> collectionPM;
        for(Id unit: CustomerTowerMap.keySet()) {
            if(CustomerWrapperMap.containsKey(unit)) {
                if(CustomerWrapperMap.get(unit).groupSelect) {
                    groupDemandId.add(unit);
               }
            }
         }         
          if(!groupDemandId.isEmpty() && groupDemandId.size() > 0) {
                groupDemandId.add(groupDemandPreviewId);
                if(ProfileName == 'Collection' || ProfileName == 'System Administrator'){
                    collectionPM = getCollectionPM(groupDemandId);
                if(!collectionPM.isEmpty() && collectionPM.size() > 0){
                    for(Payment_Milestones__c p: collectionPM){
                        p.Collection_Status__c = 'Submitted'; 
                        p.Demand_Approval_Current_Status__c = 'Collection Submitted';   
                        p.Collection_Submission_Date__c = System.Now();                                       
                    }
                    try{
                        update collectionPM;  
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Demands have been submitted')); 
                    } catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Error while submitting demands')); 
                        system.debug('Error while submitting demands ' + e);
                    }                 
                  }  
                }
                getNextDemands();
            }           
            if(groupDemandId.isEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No customers were selected. Please select the customers for submitting demands'));
            }   
    }
    
////// Accept method for Finance, Audit, CFO    
     public void AcceptMultipleDemands(){
        ProfileName = [SELECT Id, Name FROM Profile WHERE Id = :ProfileId].Name;
        Set<Id> groupDemandId = new Set<Id>();
        List <Payment_Milestones__c> FinancePM;
        List <Payment_Milestones__c> AuditPM;
        List <Payment_Milestones__c> CFOPM;
        for(Id unit: CustomerTowerMap.keySet()) {
            if(CustomerWrapperMap.containsKey(unit)) {
                if(CustomerWrapperMap.get(unit).groupSelect) {
                    groupDemandId.add(unit);
               }
            }
         }         
          if(!groupDemandId.isEmpty() && groupDemandId.size() > 0) {
                groupDemandId.add(groupDemandPreviewId);
                if(ProfileName == 'Finance'){
                    FinancePM = getFinancePM(groupDemandId);  
                if(!FinancePM.isEmpty() && FinancePM.size() > 0){
                    for(Payment_Milestones__c p: FinancePM){
                        p.Finance_Status__c = 'Accepted'; 
                        p.Finance_Approval_Date__c = System.Now();
                        p.Finance_Reason_For_Rejection__c = CustomerWrapperMap.get(p.Quotation__r.Unit__c).Remarks;
                        p.Demand_Approval_Current_Status__c = 'Finance Accepted';                                       
                    }
                    try{
                        update FinancePM;  
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Demands have been approved')); 
                    } catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Error while approving demands')); 
                        system.debug('Error while approving demands ' + e);
                    }                  
                  }  
                }
                
                if(ProfileName == 'Audit'){
                    AuditPM = getAuditPM(groupDemandId); 
                if(!AuditPM.isEmpty() && AuditPM.size() > 0){
                    for(Payment_Milestones__c p: AuditPM){
                        p.Audit_Status__c = 'Accepted';
                        p.Demand_Approval_Current_Status__c = 'Audit Accepted';
                        p.Audit_Reason_For_Rejection__c = CustomerWrapperMap.get(p.Quotation__r.Unit__c).Remarks; 
                        p.Audit_Approval_Date__c = System.Now();                                          
                    }
                    try{
                        update AuditPM; 
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Demands have been approved')); 
                    } catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Error while approving demands')); 
                        system.debug('Error while approving demands ' + e);
                    }                    
                  }  
                }
                
                if(ProfileName == 'CFO'){
                    CFOPM = getCFOPM(groupDemandId); 
                if(!CFOPM.isEmpty() && CFOPM.size() > 0){
                    for(Payment_Milestones__c p: CFOPM){
                        p.CFO_Status__c = 'Accepted';
                        p.Demand_Approval_Current_Status__c = 'CFO Accepted';
                        p.CFO_Reason_For_Rejection__c = CustomerWrapperMap.get(p.Quotation__r.Unit__c).Remarks;
                        p.CFO_Approval_Date__c = System.Now();                                        
                    }
                    try{
                        update CFOPM;   
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Demands have been approved')); 
                    } catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Error while approving demands')); 
                        system.debug('Error while approving demands ' + e);
                    }                  
                  }  
                }
                getNextDemands();
            }           
            if(groupDemandId.isEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No customers were selected. Please select the customers for accepting demands'));
            }   
    }
    
    ////// Reject method for Finance, Audit, CFO    
     public void RejectMultipleDemands(){
          
        ProfileName = [SELECT Id, Name FROM Profile WHERE Id = :ProfileId].Name;
        Set<Id> groupDemandId = new Set<Id>();
        List <Payment_Milestones__c> FinancePM;
        List <Payment_Milestones__c> AuditPM;
        List <Payment_Milestones__c> CFOPM;
        Boolean error = false;  
        for(Id unit: CustomerTowerMap.keySet()) {
            if(CustomerWrapperMap.containsKey(unit)) {
                if(CustomerWrapperMap.get(unit).groupSelect) {
                    if(String.isBlank(CustomerWrapperMap.get(unit).Remarks)){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Remarks is mandatory if Demand is Rejected'));
                        error = true;
                    } 
                    groupDemandId.add(unit);                 
               }
            }
         }
         if(!error){        
          if(!groupDemandId.isEmpty() && groupDemandId.size() > 0) {
                groupDemandId.add(groupDemandPreviewId);
                if(ProfileName == 'Finance'){
                    FinancePM = getFinancePM(groupDemandId); 
                if(!FinancePM.isEmpty() && FinancePM.size() > 0){
                    for(Payment_Milestones__c p: FinancePM){
                        p.Finance_Status__c = 'Rejected';
                        p.Finance_Reason_For_Rejection__c = CustomerWrapperMap.get(p.Quotation__r.Unit__c).Remarks;
                        p.Finance_Approval_Date__c = System.Now();
                        p.Demand_Approval_Current_Status__c = 'Finance Rejected';                                         
                    }
                    try{
                        update FinancePM;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Demands have been rejected')); 
                    } catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Error while rejecting demands')); 
                        system.debug('Error while approving demands ' + e);
                    }                     
                  }               
                }
                
                if(ProfileName == 'Audit'){
                    AuditPM = getAuditPM(groupDemandId); 
                if(!AuditPM.isEmpty() && AuditPM.size() > 0){
                    for(Payment_Milestones__c p: AuditPM){
                        p.Audit_Status__c = 'Rejected'; 
                        p.Audit_Reason_For_Rejection__c = CustomerWrapperMap.get(p.Quotation__r.Unit__c).Remarks;
                        p.Demand_Approval_Current_Status__c = 'Audit Rejected'; 
                        p.Audit_Approval_Date__c = System.Now();                                            
                    }
                    try{
                        update AuditPM;  
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Demands have been rejected')); 
                    } catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Error while rejecting demands')); 
                        system.debug('Error while approving demands ' + e);
                    }                   
                  }  
                }
                
                if(ProfileName == 'CFO'){
                    CFOPM = getCFOPM(groupDemandId);
                if(!CFOPM.isEmpty() && CFOPM.size() > 0){
                    for(Payment_Milestones__c p: CFOPM){
                        p.CFO_Status__c = 'Rejected'; 
                        p.CFO_Reason_For_Rejection__c = CustomerWrapperMap.get(p.Quotation__r.Unit__c).Remarks;
                        p.Demand_Approval_Current_Status__c = 'CFO Rejected';
                        p.CFO_Approval_Date__c = System.Now();                                                                 
                    }
                    try{
                        update CFOPM;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Demands have been rejected')); 
                    } catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Error while rejecting demands')); 
                        system.debug('Error while approving demands ' + e);
                    }                     
                  }  
                }
                getNextDemands();
            } 
           }           
            if(groupDemandId.isEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No customers were selected. Please select the customers for rejecting demands'));
            }   
    }
        
    public List<Payment_Milestones__c> getCollectionPM(Set<Id> unitId){
        return [SELECT Id, Collection_Status__c, Demand_Approval_Current_Status__c, Collection_Submission_Date__c
                FROM Payment_Milestones__c 
                WHERE Quotation__c != null
                and Quotation__r.Booking__c != null
                and Quotation__r.Unit__c != null
                and Quotation__r.Unit__c IN: unitId
                and Quotation__r.Unit__r.Project__c != null
                and Quotation__r.Unit__r.Tower__c != null
                and Quotation__r.Opportunity__r.S_Active__c = true
                and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'
                and Quotation__r.Unit__r.Unit_Status__c = 'Sold'
                and Quotation__r.Booking__r.Stage_of_Booking__c = 'Booked'
                and Quotation__r.Booking__r.Status__c = 'Processed'
                and is_demand_raised__c = false
                and Collection_Status__c != 'Submitted'
                and(
                      (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) 
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null  and Milestone_Due_Date__c <= NEXT_N_DAYS:15))];
    }
    
    public List<Payment_Milestones__c> getFinancePM(Set<Id> unitId){
        return [SELECT Id, Finance_Status__c, Quotation__r.Unit__c, Finance_Reason_For_Rejection__c, Demand_Approval_Current_Status__c, Finance_Approval_Date__c
                FROM Payment_Milestones__c 
                WHERE Quotation__c != null
                and Quotation__r.Booking__c != null
                and Quotation__r.Unit__c != null
                and Quotation__r.Unit__c IN: unitId
                and Quotation__r.Unit__r.Project__c != null
                and Quotation__r.Unit__r.Tower__c != null
                and Quotation__r.Opportunity__r.S_Active__c = true
                and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'
                and Quotation__r.Unit__r.Unit_Status__c = 'Sold'
                and Quotation__r.Booking__r.Stage_of_Booking__c = 'Booked'
                and Quotation__r.Booking__r.Status__c = 'Processed'
                and is_demand_raised__c = false
                and Collection_Status__c = 'Submitted'
                and Finance_Status__c != 'Accepted' 
                and(
                      (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) 
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null  and Milestone_Due_Date__c <= NEXT_N_DAYS:15))];
    }
    
    public List<Payment_Milestones__c> getAuditPM(Set<Id> unitId){
        return [SELECT Id, Audit_Status__c, Quotation__r.Unit__c, Audit_Reason_For_Rejection__c, Demand_Approval_Current_Status__c, Audit_Approval_Date__c
                FROM Payment_Milestones__c 
                WHERE Quotation__c != null
                and Quotation__r.Booking__c != null
                and Quotation__r.Unit__c != null
                and Quotation__r.Unit__c IN: unitId
                and Quotation__r.Unit__r.Project__c != null
                and Quotation__r.Unit__r.Tower__c != null
                and Quotation__r.Opportunity__r.S_Active__c = true
                and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'
                and Quotation__r.Unit__r.Unit_Status__c = 'Sold'
                and Quotation__r.Booking__r.Stage_of_Booking__c = 'Booked'
                and Quotation__r.Booking__r.Status__c = 'Processed'
                and is_demand_raised__c = false
                and Collection_Status__c = 'Submitted'
                and Finance_Status__c = 'Accepted'
                and Audit_Status__c != 'Accepted'
                and(
                      (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) 
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15))];
    }
    
    public List<Payment_Milestones__c> getCFOPM(Set<Id> unitId){
        return [SELECT Id, CFO_Status__c, Quotation__r.Unit__c, CFO_Reason_For_Rejection__c,Demand_Approval_Current_Status__c, CFO_Approval_Date__c
                FROM Payment_Milestones__c 
                WHERE Quotation__c != null
                and Quotation__r.Booking__c != null
                and Quotation__r.Unit__c != null
                and Quotation__r.Unit__c IN: unitId
                and Quotation__r.Unit__r.Project__c != null
                and Quotation__r.Unit__r.Tower__c != null
                and Quotation__r.Opportunity__r.S_Active__c = true
                and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'
                and Quotation__r.Unit__r.Unit_Status__c = 'Sold'
                and Quotation__r.Booking__r.Stage_of_Booking__c = 'Booked'
                and Quotation__r.Booking__r.Status__c = 'Processed'
                and is_demand_raised__c = false
                and Collection_Status__c = 'Submitted'
                and Finance_Status__c = 'Accepted'
                and Audit_Status__c = 'Accepted'
                and CFO_Status__c != 'Accepted'
                and(
                      (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) 
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)
                    or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15))];
    } 
    
    public void quickSearch() {           
            System.debug('quickSearch:' + customerName + ':' + unitName + ':');
            customerTowerMap = new Map<Id,List<DemandApprovalContoller.DemandWrapper>>();
            customerTowerMap = DemandApprovalContoller.searchSpecificDemands(towerName, projectName, customerName, unitName, null, null, null, null, false, 'search'); 
            customerList = new List<Id>();
            customerList.addAll(customerTowerMap.keySet());
            CustomerWrapperMap = DemandApprovalContoller.getCustomerWrapper(customerTowerMap.keySet());
    }
    
public class DemandWrapper {   
    public Payment_Milestones__c pm {get; set;}
    public Demand__c dm {get; set;}
    public PrintTotalsWrapper ptw {get; set;}
    public List <PrintChargesWrapper> pcwList {get; set;}
    public Boolean perMilestoneSelect {get; set;}
    public String installmentName {get; set;} // Added by Neha on 25/3/19
    public String basicPercentage {get; set;} // Added by Neha on 25/3/19  
    public String outstandingDays {get; set;} // Added by neha on 8/11/19 
    public String outstandingAmount {get; set;} // Added by neha on 8/11/19    
    
    public DemandWrapper() {
        pm = new Payment_Milestones__c();
        dm = new Demand__c(); //// Added by neha on 8/11/19 
        ptw = new PrintTotalsWrapper();
        pcwList = new List <PrintChargesWrapper> ();
        perMilestoneSelect = false;
        basicPercentage = ''; // Added by Neha on 25/3/19
        installmentName = '';      
        outstandingDays = '';
        outstandingAmount = '';     
    }
}
    
public class PrintTotalsWrapper {
    public String overallAmt {get; set;}
    public String overallTax1 {get; set;}
    public String overallTax2 {get; set;}
    public String totalTax {get; set;}
    public String overallTDS {get; set;}
    public Decimal overallAmtD {get; set;}
    public Decimal overallTax1D {get; set;}
    public Decimal overallTax2D {get; set;}
    public Decimal overallTDSD {get; set;}
    public String receivedAmt {get; set;}
    public String demandedAmt {get; set;}
    public String receivedTax {get; set;}
    public String demandedTax {get; set;}    
    public String milestoneName {get; set;}
    public String totalOutstandingWithTax {get; set;}
    public String totalDemandedWithTax {get; set;}
    public String totalDueWithInterest {get; set;}
    public String totalDueWithoutGSTInterest {get; set;}
    public String totalInterest {get; set;}
    public String totalGSTOnInterest {get; set;}
    public Decimal grandTotal {get; set;}
    public Decimal grandTotalWithoutGSTOnInterest {get; set;}
}
    
    public class PrintChargesWrapper {
        public String chargeName {get; set;}
        public String percentage {get; set;}
        public String Amount {get; set;}
        public String Tax1 {get; set;}
        public String Tax2 {get; set;}
    }
    
    public class CustomerWrapper {
        public Opportunity o {get; set;}
        public Unit__c u {get; set;}
        public String styleName {get; set;}
        public Boolean groupSelect {get; set;}
        public String Remarks {get; set;} // Added by Neha on 1/4/19
        
        public CustomerWrapper() {
        }
    }
    
    public void getNextDemands(){
        customerTowerMap = new Map<Id, List<DemandWrapper>>();
        customerList = new List<Id>();
        customerWrapperMap = new Map<Id, CustomerWrapper>();
        customerTowerMap = searchAllPendingDemandsWithGrouping(towerName, projectName, pgw.list_size, pgw.counter); 
        customerList.addAll(customerTowerMap.keySet());
        CustomerWrapperMap = getCustomerWrapper(customerTowerMap.keySet());
    }
 //// For demand preview   
    public static Map <Id, List <DemandWrapper>> searchSpecificDemands(String towerName, String projectName, string customer, string unit, Date startDate, Date endDate, Id selectedStage, String forMilestone, Boolean isRaiseDemandDashboard, String mode) {        
        Id ProfileId = UserInfo.getProfileId();
        ProfileName = [SELECT Id, Name FROM Profile WHERE Id = :ProfileId].Name;
        system.debug('Unit no.:: ' + unit + ' mode::: ' + mode);
        //// Query Payment Milestone
        List <Payment_Milestones__c> paymentMilestoneList = new List <Payment_Milestones__c>();
        String tempQuery = '';
        for (Integer i = 1; i <= 15; i++) {
            tempQuery += 'Charge' + i + 'Name__c' + ',';
            tempQuery += 'Charge' + i + 'Percentage__c' + ',';
            tempQuery += 'C' + i + '_Amount__c' + ',';
            tempQuery += 'C' + i + '_SGST__c' + ',';
            tempQuery += 'C' + i + '_CGST__c' + ',';
            tempQuery += 'Charge_' + i + '_Lookup__c' + ',';
        }
        String tempQuery1 = '';
        for (Integer i = 1; i <= 15; i++) {
            tempQuery1 += 'Charge_' + i + '_Lookup__r.ChargeBucket__c,';
        }
        // remove the last character only if its a comma.
        if (tempQuery1.length() > 0 && tempQuery1.substring(tempQuery1.length() - 1).equals(','))
            tempQuery1 = tempQuery1.substring(0, tempQuery1.length() - 1);
        String query =  'Select Id, Name, Milestone_Due_Date__c, Milestone_Name__c, Milestone_Type_Text__c, Milestone_Type_edit__c,Number_Of_Days__c,Milestone_Complete_At_Booking__c,' +
                        'Quotation__r.Opportunity__r.Primary_Email__c, Installment__c, Quotation__r.Opportunity__r.Primary_Name__c, ' +
                        'Demand_Raised__c, Quotation__r.Name, Quotation__r.Unit__r.Project__r.Name, Is_Combination_Milestone__c, Construction_Stage_Actual_CompletionDate__c,' +
                        'Quotation__r.Unit__r.Tower__R.Name,' +
                        'Quotation__r.Booking__c, Quotation__r.Booking__r.Unit__r.Tower__r.RDS_Company_Code__c,' +
                        'Quotation__r.Booking__r.Booking_Date__c,' +
                        'Quotation__R.Opportunity__r.Name,' +
                        'Quotation__r.Unit__r.Customers__r.Name,' +
                        'Quotation__R.Opportunity__r.latest_demand_due_date__c,' +
                        'Quotation__R.Unit__r.Name, Project_Construction_Stages__c,' + tempQuery + tempQuery1 +
                        ' from Payment_Milestones__c ' +
                        ' where Quotation__c != null ' +
                        ' and Quotation__r.Unit__c != null ' +
                        ' and Quotation__r.Booking__c != null ' +
                        ' and Quotation__r.Opportunity__r.S_Active__c = true ' +
                        ' and Quotation__r.Opportunity__r.StageName =  \'Booking confirmed\' ' +
                        ' and Quotation__r.Unit__r.Unit_Status__c = \'Sold\' ' +
                        ' and Quotation__r.Booking__r.Status__c = \'Processed\' '+
                        ' and Quotation__r.Booking__r.Stage_of_Booking__c = \'Booked\' '+
                        ' and is_demand_raised__c = false ';

        String searchQuery = '';
        if (towerName != null && String.isNotBlank(towerName))
            searchQuery += ' and Quotation__r.Unit__r.Tower__r.Name = ' + '\'' + towerName + '\'';
        if (projectName != null && String.isNotBlank(projectName))
            searchQuery += ' and Quotation__r.Unit__r.Project__r.Name = ' + '\'' + projectName + '\'';
        if (unit != null && string.isNotBlank(unit)){
            searchQuery += ' and Quotation__r.Unit__r.Name like ' + '\'%' + unit + '%\'';       
        }
            
        if (customer != null && string.isNotBlank(customer)){
            searchQuery += ' and Quotation__r.Unit__r.Customers__r.Name like' + '\'%' + customer + '%\'';              
        }
        if(ProfileName == 'Collection'){
            system.debug('isRaiseDemandDashboard::: ' + isRaiseDemandDashboard);
            if(!isRaiseDemandDashboard){
                system.debug('inside false if');
                searchQuery += ' and ((Collection_Status__c != \'Submitted\' and Demands_Approved__c = false))'; 
            }
            else {
                system.debug('inside true else');
                searchQuery += ' and (Demands_Approved__c = true)';
            }
        }
        if(ProfileName == 'Finance')
            searchQuery += ' and Collection_Status__c = \'Submitted\' and Finance_Status__c != \'Accepted\'';  
        if(ProfileName == 'Audit') 
            searchQuery += ' and Collection_Status__c = \'Submitted\' and Finance_Status__c = \'Accepted\' and Audit_Status__c != \'Accepted\'';   
        if(ProfileName == 'CFO') 
            searchQuery += ' and Collection_Status__c = \'Submitted\' and Finance_Status__c = \'Accepted\' and Audit_Status__c = \'Accepted\' and CFO_Status__c != \'Accepted\'';       
        // if no parameters are specified neither date range nor stage name then search all date linked demands with in the next 15 days and construction linked demands where milestone is acheived.
        // this is the default value we used for showing all demands in the tower. This is to accommodate when someone clicks search after entering just the customer name or unit name.
        if (startDate == null && endDate == null && selectedStage == null) {
            searchQuery += ' and  ( ' +
                ' (Milestone_Type_edit__c = \'Construction Linked\' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= Today) OR ' +
                ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15) OR' +
                ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:15)' +
                ' ) ';       
         }
        System.debug('before for milestone check in search specific demands:' + formilestone);
        if(forMilestone != null) {            
            searchQuery +=' and Id = :forMilestone';
            System.debug('Inside for milestone check in search specific demands:' + searchQuery);
        }
        System.debug('Query used:' + query + searchQuery);
        paymentMilestoneList = Database.Query(query + SearchQuery + ' order by Milestone_Due_Date__c asc');
        System.debug('paymentMilestoneList:::: ' + paymentMilestoneList.size());
        
        Decimal overallAmt = 0;
        Decimal overallTax1 = 0;
        Decimal overallTax2 = 0;
        Decimal basicPercent = 0 ; // Added by Neha on 25/3/19
        Integer j = 1;
        Integer sizeofPM = 0; // Added by Neha on 25/3/19
        List <DemandWrapper> dwList = new List <DemandWrapper> (); 
        
        if(mode == 'Preview'){
         //// Query Demands to show demand split on Demand Notice
        List<Demand__c> demandList = new List<Demand__c>();
        String tempDemandQuery = '';
       for(Integer i = 1; i <= 15; i++){
            tempDemandQuery += ' Payment_Milestones__r.Charge' + i + 'Name__c,';
            tempDemandQuery += ' Payment_Milestones__r.Charge' + i + 'Percentage__c,';
            tempDemandQuery += ' Payment_Milestones__r.C' + i + '_Amount__c,';
            tempDemandQuery += ' Payment_Milestones__r.C' + i + '_SGST__c,';
            tempDemandQuery += ' Payment_Milestones__r.C' + i + '_CGST__c,';
            tempDemandQuery += ' Payment_Milestones__r.Charge_' + i + '_Lookup__c,';
            tempDemandQuery += ' Payment_Milestones__r.Charge_' + i + '_Lookup__r.ChargeBucket__c,';        
        }     
        
        if (tempDemandQuery.length() > 0 && tempDemandQuery.substring(tempDemandQuery.length() - 1).equals(',')){
            tempDemandQuery = tempDemandQuery.substring(0, tempDemandQuery.length() - 1);
        }   
        String tempDemandQuery1 = '';
        tempDemandQuery1 = 'SELECT Ageing__c, Invoice_Date__c, Due_Date__c, Total_Amount_Demanded__c, Total_Tax_Demanded__c, Milestone_Name__c, Booking__r.Unit__r.Tower__c, ' +
                          ' Installment__c, Agreement_Value_Balance__c, Service_Tax_on_Agreement_Value_Balance__c, Booking__r.Unit__c, Booking__r.Unit__r.Project__r.Name, ' +tempDemandQuery +
                          ' FROM Demand__c WHERE Payment_Milestones__c != null and Debit_Type__c = \'\' and Demand_Status__c != \'Reversed\' ';
        if(towerName != null && String.isNotBlank(towerName))
            tempDemandQuery1 += ' and Booking__r.Unit__r.Tower__r.Name = ' + '\'' + towerName + '\'';
        if(projectName != null && String.isNotBlank(projectName))
            tempDemandQuery1 += ' and Booking__r.Unit__r.Project__r.Name = ' + '\'' + projectName + '\'';
        if(unit != null && string.isNotBlank(unit))
            tempDemandQuery1 += ' and Booking__r.Unit__r.Name like ' + '\'%' + unit + '%\'';
        if(customer != null && string.isNotBlank(customer))
            tempDemandQuery1 += ' and Booking__r.Unit__r.Customers__r.Name like' + '\'%' + customer + '%\'';
        demandList = Database.Query(tempDemandQuery1 + ' order by Due_Date__c asc');     
        System.debug('tempDemandQuery1:::' + tempDemandQuery1 + ' order by Due_Date__c asc');      
        system.debug('demand list::: ' + demandList.size());    
                       
         ///// demand added by Neha on 8/11/19
        if (demandList != null && demandList .size() > 0) {
            for (Demand__c d: demandList) {
                List <PrintChargesWrapper> temp = new List <PrintChargesWrapper > ();
                PrintTotalsWrapper temp1 = new PrintTotalsWrapper();
                DemandWrapper dw = new DemandWrapper();               
                
                // adding the overall value of this milestone to the totals wrapper
                temp1.overallAmt = InventoryCostServices.InformatR(d.Total_Amount_Demanded__c);
                temp1.overallTax1 = InventoryCostServices.InformatR(0);
                temp1.overallTax2 = InventoryCostServices.InformatR(d.Total_Tax_Demanded__c);
                temp1.totalTax = InventoryCostServices.InformatR(d.Total_Tax_Demanded__c);

                temp1.overallAmtD = math.abs(d.Total_Amount_Demanded__c.setscale(0,RoundingMode.HALF_UP));
                temp1.overallTax1D = math.abs(0);
                temp1.overallTax2D = math.abs(d.Total_Tax_Demanded__c.setscale(0,RoundingMode.HALF_UP));

                if (String.isNotBlank(d.Milestone_Name__c)) {                    
                    temp1.milestoneName = d.Milestone_Name__c;
                }                    

                // put all of these together into the demands wrapper.
                Map<String, Integer> projChargeSeq = InventoryCostServices.getProjectChargesSequence(d.Booking__r.Unit__r.Project__r.Name, d.Booking__r.Unit__r.Tower__c); // Added by Neha on 25/3/19
                Decimal Seq = 0;
                if(projChargeSeq != null){
                    Seq = projChargeSeq.get('Basic');
                }
                basicPercent = ((Decimal)d.Payment_Milestones__r.get('Charge'+Seq+'Percentage__c')).setScale(0); // Added by Neha on 25/3/19
                dw.basicPercentage = basicPercent + ' %';
                dw.installmentName = d.Installment__c;
                if(d.Agreement_Value_Balance__c != null && d.Service_Tax_on_Agreement_Value_Balance__c != null){
                    if(d.Agreement_Value_Balance__c > 0 || d.Service_Tax_on_Agreement_Value_Balance__c > 0){
                        dw.outstandingDays += d.Ageing__c; 
                        dw.outstandingAmount = InventoryCostServices.InformatR(d.Agreement_Value_Balance__c + d.Service_Tax_on_Agreement_Value_Balance__c);  
                    } else if(d.Agreement_Value_Balance__c == 0 && d.Service_Tax_on_Agreement_Value_Balance__c == 0){
                        dw.outstandingDays = 'Paid'; 
                        dw.outstandingAmount = InventoryCostServices.InformatR(d.Agreement_Value_Balance__c + d.Service_Tax_on_Agreement_Value_Balance__c);     
                    }                   
                }                        
                dw.dm = d;
                dw.pcwList.addAll(temp);
                dw.ptw = temp1;
                dwList.add(dw);
                overAllAmt = 0;
                overallTax1 = 0;
                overallTax2 = 0;
            }
        }        
        }
        ///// Payment Milestone      
        if (paymentMilestoneList != null && paymentMilestoneList.size() > 0) {
            sizeofPM = paymentMilestoneList.size(); // Added by Neha on 25/3/19
            for (Payment_Milestones__c p: paymentMilestoneList) {
                List <PrintChargesWrapper> temp = new List <PrintChargesWrapper > ();
                PrintTotalsWrapper temp1 = new PrintTotalsWrapper();
                DemandWrapper dw = new DemandWrapper();
                // if its date linked demand, the invoice date will be date on which demand is raised and invoice due date will be the actual date
                // generally the invoice is to be raised 15 days prior to the due date
                if (p.Milestone_Type_edit__c.equalsIgnoreCase('Date Linked') && p.Is_Combination_Milestone__c == false) {
                        p.Invoice_Date__c = system.today();
                        p.Invoice_Due_Date__c = p.Milestone_Due_Date__c;               
                }
                /// if its construction linked demand, the invoice date and invoice due date will be the date on which demand is raised
                else if(p.Milestone_Type_edit__c.equalsIgnoreCase('Construction Linked')){
                    p.Invoice_Date__c = system.today();
                    p.Invoice_Due_Date__c = system.today();
                }
                else if(p.Milestone_Type_edit__c.equalsIgnoreCase('Date Linked') && p.Is_Combination_Milestone__c == true){
                    if(p.Construction_Stage_Actual_CompletionDate__c != null){
                        p.Invoice_Date__c = system.today();
                        p.Invoice_Due_Date__c = p.Milestone_Due_Date__c;       
                    } else {
                        p.Invoice_Date__c = system.today();
                        p.Invoice_Due_Date__c = system.today();    
                    }
                }
           /*     if(p.Quotation__r.Opportunity__r.Latest_Demand_Due_Date__c != null && p.Invoice_Due_Date__c < p.Quotation__r.Opportunity__r.Latest_Demand_Due_Date__c) {
                        p.Invoice_Due_Date__c = p.Quotation__r.Opportunity__r.Latest_Demand_Due_Date__c;
                }*/
                Map<String, Tax_Slab__c> taxSlabMap = DemandManagementServices.getTaxRatesForProjectCharges(p.Quotation__R.Unit__c, p.Invoice_Date__c);                                           
                system.debug('Taxslab map::: ' + taxSlabMap);
                system.debug('unit on quote::: ' + p.Quotation__R.Unit__c);
                for (Integer i = 1; i <= 15; i++) {
                    Decimal amountForTaxation = 0;
                    Decimal sgst = 0;
                    Decimal cgst = 0;                    
                    PrintChargesWrapper pcw = new PrintChargesWrapper();
                    if (
                        p.getSObject('Charge_' + i + '_Lookup__r') != null &&
                        (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
                        String.isNotBlank((String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
                        (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Agreement Value'
                    ) {
                        if ((String) p.get('Charge' + i + 'Name__c') != null && String.isNotBlank((String) p.get('Charge' + i + 'Name__c'))) {
                            pcw.chargeName = (String) p.get('Charge' + i + 'Name__c');
                            if (p.get('Charge' + i + 'Percentage__c') != null)
                                pcw.percentage = String.valueOf((Decimal) p.get('Charge' + i + 'Percentage__c')) + ' %';
                            else
                                pcw.percentage = '';
                            if (p.get('C' + i + '_Amount__c') != null) {
                                pcw.Amount = InventoryCostServices.InFormat((Decimal) p.get('C' + i + '_Amount__c'));
                                overallAmt += (Decimal) p.get('C' + i + '_Amount__c');
                                amountforTaxation = (Decimal) p.get('C' + i + '_Amount__c');
                                system.debug('amt for tax::: ' + amountforTaxation);
                            } else
                                pcw.Amount = '';
                           
                            String chargeName = (String) p.get('Charge' + i + 'Name__c');
                            if(chargeName == 'Parking Charges')
                                chargeName = 'Basic';
                            system.debug('charge::: ' + chargeName);
                            if(taxSlabMap.containsKey(chargeName)) {
                                  sgst = (amountForTaxation * taxSlabMap.get(chargeName).Taxable2_Percentage__c * taxSlabMap.get(chargeName).Tax2_Percentage__c)/10000;
                                  cgst = (amountForTaxation * taxSlabMap.get(chargeName).Taxable1_Percentage__c * taxSlabMap.get(chargeName).Tax1_Percentage__c)/10000;
                                  system.debug('cgst:: ' + cgst.setScale(0));
                                  system.debug('sgst:: ' + sgst.setScale(0));
                                 
                                  pcw.Tax1 = InventoryCostServices.InFormat(sgst);
                                  pcw.Tax2 = InventoryCostServices.InFormat(cgst);
                                  overallTax1 += sgst;
                                  overallTax2 += cgst;
                                  system.debug('overallTax2 ::: ' + overallTax2);
                            } else {
                                    pcw.Tax1 = '';
                                    pcw.Tax2 = '';
                            }
                            temp.add(pcw); // adding each charge of this milestone to the charge list
                        }
                    }
                }
                // adding the overall value of this milestone to the totals wrapper
                temp1.overallAmt = InventoryCostServices.InformatR(overallAmt);
                temp1.overallTax1 = InventoryCostServices.InformatR(overallTax1);
                temp1.overallTax2 = InventoryCostServices.InformatR(overallTax2);
                temp1.totalTax = InventoryCostServices.InformatR(overallTax1 + overallTax2);
                temp1.overallTDS = InventoryCostServices.InformatR(overallAmt * 1 / 100);

                temp1.overallAmtD = math.abs(overallAmt.setscale(0,RoundingMode.HALF_UP));
                temp1.overallTax1D = math.abs(overallTax1.setscale(0,RoundingMode.HALF_UP));
                temp1.overallTax2D = math.abs(overallTax2.setscale(0,RoundingMode.HALF_UP));
                temp1.overallTDSD = math.abs((overallAmt * 1 / 100).setscale(0,RoundingMode.HALF_UP));

                if (String.isNotBlank(p.Milestone_Name__c)) {
                    String[] tempStr = p.Milestone_Name__c.split(':');
                    if (tempStr.size() == 2)
                        temp1.milestoneName = tempStr[1];
                    else
                        temp1.milestoneName = tempStr[0];
                }

                // put all of these together into the demands wrapper.
                // Added by Neha on 25/3/19 to show percentage on viewDemand
                Map<String, Integer> projChargeSeq = InventoryCostServices.getProjectChargesSequence(p.Quotation__R.Unit__r.Project__r.Name, p.Quotation__R.Unit__r.Tower__c); // Added by Neha on 25/3/19
                Decimal Seq = 0;
                if(projChargeSeq != null){
                    Seq = projChargeSeq.get('Basic');
                }
                basicPercent = ((Decimal)p.get('Charge'+Seq+'Percentage__c')).setScale(0); // Added by Neha on 25/3/19
                dw.basicPercentage = basicPercent + ' %'; // Added by Neha on 25/3/19
                dw.installmentName = p.Installment__c; // Added by Neha on 25/3/19           
                dw.outstandingDays = ''; //  Added by Neha on 8/11/19   
                dw.outstandingAmount = ''; //  Added by Neha on 8/11/19 
                dw.pm = p;
                dw.pcwList.addAll(temp);
                dw.ptw = temp1;
                dwList.add(dw);
                j++;
                overAllAmt = 0;
                overallTax1 = 0;
                overallTax2 = 0;
            }
        } 
          
        system.debug('dwlist::: ' + dwList.size());
        //// Added demand and payment milestone in customerMap
        Map <Id, List <DemandWrapper>> CustomerMap = new Map <Id, List <DemandWrapper>> ();
            for (DemandWrapper dw: dwList) {
                if (customerMap.containsKey(dw.pm.Quotation__R.Unit__c))
                    customerMap.get(dw.pm.Quotation__R.Unit__c).add(dw);
                else if (customerMap.containsKey(dw.dm.Booking__r.Unit__c))
                    customerMap.get(dw.dm.Booking__r.Unit__c).add(dw);    
                else {
                    List <DemandWrapper> dwListTemp = new List <DemandWrapper> ();
                    dwListTemp.add(dw);
                    if(dw.pm.Quotation__R.Unit__c != null)
                        customerMap.put(dw.pm.Quotation__r.Unit__c, dwListTemp);
                    else if (dw.dm.Booking__r.Unit__c != null)
                        customerMap.put(dw.dm.Booking__r.Unit__c, dwListTemp);
                }
            }
        System.debug('Customer Map:' + customerMap.size());
        return customerMap;
    }
    
     public PageReference Beginning() { //user clicked beginning
        pgw= PaginationController.Beginning(pgw);
        getNextDemands();
        return null;
    }

    public PageReference Previous() { //user clicked previous button
       pgw = PaginationController.Previous(pgw);
       getNextDemands();
       return null;
    }

    public PageReference Next() { //user clicked next button
        pgw = PaginationController.Next(pgw);
        getNextDemands();
        return null;
    }

    public PageReference End() { //user clicked end
        pgw = PaginationController.End(pgw);
        getNextDemands();
        return null;
    }
    
    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
        return(PaginationController.DisablePrevious(pgw));
    }

    public Boolean getDisableNext() { //this will disable the next and end buttons
       return(PaginationController.DisableNext(pgw));
    }
    
    public Integer getTotal_size() {
        return (PaginationController.getTotal_size(pgw));
    }
    
    public Integer getPageNumber() {
         return (PaginationController.getPageNumber(pgw));
    }

    public Integer getTotalPages() {
        return (PaginationController.getTotalPages(pgw));
    }
    public void dummy(){
        system.debug('inside dummy');
    }
}