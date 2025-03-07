public with sharing class DemandManagementServices {
    public static Map < String, List < String >> getAllPendingDemands() {
        Raise_Demands_for_Unregistered_Projects__mdt unregisteredProjects = [Select MasterLabel,
                                                                             Make_Unregistered_Projects_Available__c from Raise_Demands_for_Unregistered_Projects__mdt 
                                                                             where MasterLabel = 'Raise Demands' LIMIT 1];
        
        List <Payment_Milestones__c> paymentMilestoneList = new List <Payment_Milestones__c> ();
        if(unregisteredProjects != null && unregisteredProjects.Make_Unregistered_Projects_Available__c == false){
            paymentMilestoneList 	= [Select Id, Name, Milestone_Name__c, Demand_Raised__c, Quotation__r.Unit__r.Project__r.Name, Quotation__r.Unit__r.Tower__R.Name
                                       from Payment_Milestones__c
                                       where Quotation__c != null
                                       and Quotation__r.Booking__c != null
                                       and Quotation__r.Unit__c != null
                                       and Quotation__r.Unit__r.Project__c != null
                                       and Quotation__r.Unit__r.Tower__r.UnRegister_Project__c =false
                                       and Quotation__r.Unit__r.Tower__c != null
                                       //and Quotation__r.Opportunity__r.S_Active__c = true
                                       and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'
                                       and (Quotation__r.Unit__r.Unit_Status__c = 'Sold' OR Quotation__r.Unit__r.Unit_Status__c = 'Blocked')
                                       and Quotation__r.Booking__r.Stage_of_Booking__c != 'EOI'
                                       and Quotation__r.Booking__r.Status__c = 'Processed' 
                                       //and Quotation__r.Booking__r.Termination_Status__c != 'Raised to DLD Team' 
                                       //and Quotation__r.Booking__r.Termination_Status__c != 'Submitted to Raise the Internal DLD team'
                                       and is_demand_raised__c = false
                                       and(
                                           (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:30) 
                                           or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:30)
                                           or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:30)
                                       )
                                       order by Name asc];
        }else{
            paymentMilestoneList = [Select Id, Name, Milestone_Name__c, Demand_Raised__c, Quotation__r.Unit__r.Project__r.Name, Quotation__r.Unit__r.Tower__R.Name
                                    from Payment_Milestones__c
                                    where Quotation__c != null
                                    and Quotation__r.Booking__c != null
                                    and Quotation__r.Unit__c != null
                                    and Quotation__r.Unit__r.Project__c != null
                                    and Quotation__r.Unit__r.Tower__c != null
                                    //and Quotation__r.Opportunity__r.S_Active__c = true
                                    and Quotation__r.Opportunity__r.StageName = 'Booking confirmed'
                                    and (Quotation__r.Unit__r.Unit_Status__c = 'Sold' OR Quotation__r.Unit__r.Unit_Status__c = 'Blocked')
                                    and Quotation__r.Booking__r.Stage_of_Booking__c != 'EOI'
                                    and Quotation__r.Booking__r.Status__c = 'Processed' 
                                    //and Quotation__r.Booking__r.Termination_Status__c != 'Raised to DLD Team' 
                                    //and Quotation__r.Booking__r.Termination_Status__c != 'Submitted to Raise the Internal DLD team'
                                    and is_demand_raised__c = false
                                    and(
                                        (Milestone_Type_edit__c = 'Construction Linked' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:30) 
                                        or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:30)
                                        or(Milestone_Type_edit__c = 'Date Linked' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:30)
                                    )
                                    order by Name asc];
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
                    if (!exists){
                        tempList.add(pm.Quotation__r.Unit__r.Tower__r.Name);
                        projectTowerMap.put(pm.Quotation__r.Unit__r.Project__r.Name, tempList);
                    }
                } else {
                    List <String> tempList = new List < String > ();
                    tempList.add(pm.Quotation__r.Unit__r.Tower__r.Name);
                    projectTowerMap.put(pm.Quotation__r.Unit__r.Project__r.Name, tempList);
                }
            }
        }
        System.debug('project tower map:' + projecttowerMap);
        return projectTowerMap;
    }
    
    public static Map <Id, List <DemandWrapper>> searchAllPendingDemandsWithGrouping(String towerName, String projectName, Integer list_size, Integer counter) {
        List <Payment_Milestones__c> paymentMilestoneList = new List <Payment_Milestones__c> ();
        System.debug('In searchAllPendingDemands: ' + towerName + ':' + projectName + ';' + counter);
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
        String query = 'Select Id, Demands_Approved__c, Quotation__r.Unit__r.Project__r.Group_Demands_By_Customer__c, Quotation__r.Opportunity__r.Primary_Email__c, Quotation__r.Opportunity__r.Primary_Name__c,  Name, Milestone_Name__c, Milestone_Type_Text__c,Milestone_Type_edit__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Number_Of_Days__c, Demand_Raised__c, Quotation__r.Name, Quotation__r.Unit__r.Project__r.Name,' +
            'Quotation__r.Unit__r.Tower__R.Name, Is_Combination_Milestone__c, Construction_Stage_Actual_CompletionDate__c, Quotation__r.Unit__c, Quotation__r.Unit__r.Project__c, ' +
            'Quotation__r.Unit__r.Customers__r.Name, Quotation__r.Booking__r.Unit__r.Tower__r.RDS_Company_Code__c, Quotation__r.Booking__r.Booking_Date__c,' +
            'Quotation__R.Opportunity__r.Name, Quotation__R.Opportunity__r.latest_demand_due_date__c, Quotation__R.Opportunity__c,' +                                       
            'Quotation__R.Unit__r.Name,' + tempQuery + tempQuery1 +
            ' from Payment_Milestones__c ' +
            ' where ' +
            ' ( ' +
            ' (Milestone_Type_edit__c = \'Construction Linked\' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <=NEXT_N_DAYS:25) OR ' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:25) OR' +
            ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:25)' +
            ' ) ' +
            ' and Quotation__c != null ' +
            ' and Quotation__r.Booking__c != null ' +
            ' and Quotation__r.Unit__c != null ' +
            ' and Quotation__r.Unit__r.Project__r.Name = ' + '\'' + projectName + '\'' +
            ' and Quotation__r.Unit__r.Tower__r.Name = ' + '\'' + towerName + '\'' +
            //' and Quotation__r.Opportunity__r.S_Active__c = true ' +
            //' and Quotation__r.Booking__r.Termination_Status__c != \'Raised to DLD Team\''  +
            //' and Quotation__r.Booking__r.Termination_Status__c != \'Submitted to Raise the Internal DLD team\'' +
            ' and Quotation__r.Opportunity__r.StageName =  \'Booking confirmed\' ' +
            ' and (Quotation__r.Unit__r.Unit_Status__c = \'Sold\' OR Quotation__r.Unit__r.Unit_Status__c = \'Blocked\' ) ' +
            ' and Quotation__r.Booking__r.Status__c = \'Processed\' '+
            ' and Quotation__r.Booking__r.Stage_of_Booking__c != \'EOI\' '+
            ' and is_demand_raised__c = false ' +
            ' order by Milestone_Due_Date__c asc ' +
            ' limit :list_size ' +
            ' offset :counter ';
        paymentMilestoneList = Database.Query(query);
        System.debug('Query:' + query);
        Decimal overallAmt = 0;
        Decimal overallTax1 = 0;
        Decimal overallTax2 = 0;
        Integer j = 1;
        List <DemandWrapper> dwList = new List <DemandWrapper> ();
        if (paymentMilestoneList != null && paymentMilestoneList.size() > 0) {
            for (Payment_Milestones__c p: paymentMilestoneList) {
                List <PrintChargesWrapper> temp = new List <PrintChargesWrapper> ();
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
                System.debug('Milestone Details:' + p.Name);
                for (Integer i = 1; i <= 25; i++) {
                    PrintChargesWrapper pcw = new PrintChargesWrapper();
                    
                    if (
                        p.getSObject('Charge_' + i + '_Lookup__r') != null &&
                        (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
                        String.isNotBlank((String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
                        (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Agreement Value'){
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
                                    overallTax2 += (Decimal) p.get('C' + i + '_CGST__c');
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
        Map <Id, List <DemandWrapper>> CustomerMap = new Map <Id, List <DemandWrapper>> ();
        for (DemandWrapper dw: dwList) {
            if (customerMap.containsKey(dw.pm.Quotation__R.Unit__c))
                customerMap.get(dw.pm.Quotation__R.Unit__c).add(dw);
            else {
                List < DemandWrapper > dwListTemp = new List < DemandWrapper > ();
                dwListTemp.add(dw);
                customerMap.put(dw.pm.Quotation__R.Unit__c, dwListTemp);
            }            
        }
        System.debug('Customer Map:' + customerMap);
        return customerMap;
    }
    
    public static Map <Id, CustomerWrapper> getCustomerWrapper(Set <Id> unitIdSet) {
        Map <Id, CustomerWrapper> CustomerWrapperMap = new Map <Id, CustomerWrapper > ();
        /*List <Opportunity> oppList = [Select id, Name, Account.PersonEmail, Primary_Email__c, Primary_Name__c,Unit__r.BookingName__c,Unit__r.Name,Pre_Registration_Status__c from Opportunity 
        where unit__c in: unitIdSet and stageName = 'Booking confirmed'
        and S_Active__c = true order by createdDate asc];*/
        List<Booking__c> bList = [Select Id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Unit__r.Name, Unit__r.Tower__r.Name  
                                  From Booking__c 
                                  WHERE 
                                  Unit__c IN : unitIdSet AND 
                                  Status__c = 'Processed' AND 
                                  Stage_of_Booking__c != 'EOI'];
        Integer count = 1;
        /*for (Opportunity o: oppList) {
        CustomerWrapper cw = new CustomerWrapper();
        cw.o = o;
        if (Math.mod(count, 2) == 1)
        cw.styleName = 'color1';
        else
        cw.styleName = 'color2';
        customerWrapperMap.put(o.unit__c, cw);
        count++;
        }*/
        for(Booking__c b : bList){
            CustomerWrapper cw = new CustomerWrapper();
            cw.booking = b;
            if (Math.mod(count, 2) == 1)
                cw.styleName = 'color1';
            else
                cw.styleName = 'color2';
            customerWrapperMap.put(b.Unit__c, cw);
            count++;
        }
        return customerWrapperMap;
    }
    
    public static Map <Id, List <DemandWrapper>> searchSpecificDemands(String towerName, String projectName, string customer, string unit, string bookingName, Date startDate, Date endDate, Id selectedStage, String forMilestone) {        
        
        system.debug('towerName::: ' + towerName);
        system.debug('projectName::: ' + projectName);
        system.debug('customer::: ' + customer);
        system.debug('unit::: ' + unit);
        system.debug('bookingName :::' + bookingName);
        system.debug('forMilestone::: ' + forMilestone);
        
        List <Payment_Milestones__c> paymentMilestoneList = new List <Payment_Milestones__c> ();
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
        String query = 'Select Id, Name, Milestone_Due_Date__c, Milestone_Name__c, Milestone_Type_Text__c, Milestone_Type_edit__c,Number_Of_Days__c,Milestone_Complete_At_Booking__c,Total_Installment_USD__c, ' + 
            'Quotation__r.Opportunity__r.Primary_Email__c, Installment__c, Quotation__r.Opportunity__r.Primary_Name__c, Quotation__r.Unit__c, Quotation__r.Unit__r.Project__c,  ' +
            'Demand_Raised__c, Quotation__r.Name, Quotation__r.Unit__r.Project__r.Name, Is_Combination_Milestone__c, Construction_Stage_Actual_CompletionDate__c,' +
            'Quotation__r.Unit__r.Tower__R.Name,' +
            'Quotation__r.Booking__c, Quotation__r.Booking__r.Unit__r.Tower__r.RDS_Company_Code__c,' +
            'Quotation__r.Booking__r.Booking_Date__c,' +
            'Quotation__R.Opportunity__r.Name,' +
            'Quotation__r.Unit__r.Customers__r.Name,' +
            'Quotation__R.Opportunity__r.latest_demand_due_date__c,' +
            'Quotation__R.Unit__r.Name, Project_Construction_Stages__c,' + tempQuery + tempQuery1 +
            ' from Payment_Milestones__c ';
        
        
        System.debug('before for milestone check in search specific demands:' + formilestone);
        
        String searchQuery = ' where ';
        
        if(forMilestone != null){
            searchQuery +=' Id = :forMilestone ';
            System.debug('Inside for milestone check in search specific demands:' + searchQuery);
        }else{
            searchQuery += ' Quotation__c != null ' +
                ' and Quotation__r.Unit__c != null ' +
                ' and Quotation__r.Booking__c != null ' +
                ' and Quotation__r.Opportunity__r.StageName =  \'Booking confirmed\' ' +
                ' and (Quotation__r.Unit__r.Unit_Status__c = \'Sold\' OR Quotation__r.Unit__r.Unit_Status__c = \'Blocked\') ' +
                ' and Quotation__r.Booking__r.Status__c = \'Processed\' '+
                ' and Quotation__r.Booking__r.Stage_of_Booking__c != \'EOI\' '+
                ' and is_demand_raised__c = false ';
        }

        if (towerName != null && String.isNotBlank(towerName) && forMilestone == null){
            searchQuery += ' and Quotation__r.Unit__r.Tower__r.Name = ' + '\'' + towerName + '\'';
        }
        if (projectName != null && String.isNotBlank(projectName) && forMilestone == null){
            searchQuery += ' and Quotation__r.Unit__r.Project__r.Name = ' + '\'' + projectName + '\'';
        }
        if (unit != null && string.isNotBlank(unit) && forMilestone == null){
            searchQuery += ' and Quotation__r.Unit__r.Name like ' + '\'%' + unit + '%\'';
        }
        if (customer != null && string.isNotBlank(customer) && forMilestone == null){
            searchQuery += ' and Quotation__r.Unit__r.Customers__r.Name like' + '\'%' + String.escapeSingleQuotes(customer) + '%\'';
        }
        if (bookingName != null && string.isNotBlank(bookingName) && forMilestone == null){
            searchQuery += ' and Quotation__r.Booking__r.Name like ' + '\'%' + bookingName + '%\'';
        }
        
        if (startDate == null && endDate == null && selectedStage == null) {
            searchQuery += ' and  ( ' +
                ' (Milestone_Type_edit__c = \'Construction Linked\' and Demand_Raised__c = true and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:25) OR ' +
                ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = false and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:25) OR' +
                ' (Milestone_Type_edit__c = \'Date Linked\' and Is_Combination_Milestone__c = true and Demand_Raised__c = true and Construction_Stage_Actual_CompletionDate__c != null and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:25)' +
                ' ) ';
        }
        
        System.debug('Query used:' + query + searchQuery);
        
        paymentMilestoneList = Database.Query(query + SearchQuery + ' order by Name asc');

        System.debug('paymentMilestoneList:::: ' + paymentMilestoneList);
        
        Decimal overallAmt = 0;
        Decimal overallTax1 = 0;
        Decimal overallTax2 = 0;
        Decimal basicPercent = 0 ; // Added by Neha on 25/3/19
        Integer j = 1;
        Integer sizeofPM = 0; // Added by Neha on 25/3/19
        List <DemandWrapper> dwList = new List <DemandWrapper> ();       
        if (paymentMilestoneList != null && paymentMilestoneList.size() > 0) {
            sizeofPM = paymentMilestoneList.size(); // Added by Neha on 25/3/19
            for (Payment_Milestones__c p: paymentMilestoneList) {
                List <PrintChargesWrapper> temp = new List <PrintChargesWrapper> ();
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
                
                Map<String, Tax_Slab__c> taxSlabMap = getTaxRatesForProjectCharges(p.Quotation__R.Unit__c, p.Invoice_Date__c);                                           
                
                for (Integer i = 1; i <= 15; i++) {
                    Decimal amountForTaxation = 0;
                    Decimal sgst = 0;
                    Decimal cgst = 0;                    
                    PrintChargesWrapper pcw = new PrintChargesWrapper();
                    if (
                        p.getSObject('Charge_' + i + '_Lookup__r') != null &&
                        (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
                        String.isNotBlank((String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
                        (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Agreement Value') {
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
                                } else
                                    pcw.Amount = '';
                                
                                String chargeName = (String) p.get('Charge' + i + 'Name__c');
                                if(chargeName == 'Parking Charges')
                                    chargeName = 'Basic';
                                if(taxSlabMap.containsKey(chargeName)) {
                                    sgst = ( amountForTaxation * taxSlabMap.get(chargeName).Taxable2_Percentage__c * taxSlabMap.get(chargeName).Tax2_Percentage__c)/10000;
                                    cgst = ( amountForTaxation * taxSlabMap.get(chargeName).Taxable1_Percentage__c * taxSlabMap.get(chargeName).Tax1_Percentage__c)/10000;
                                    pcw.Tax1 = InventoryCostServices.InFormat(sgst);
                                    pcw.Tax2 = InventoryCostServices.InFormat(cgst);
                                    overallTax1 += sgst;
                                    overallTax2 += cgst;
                                } else {
                                    pcw.Tax1 = '';
                                    pcw.Tax2 = '';
                                }
                                temp.add(pcw); // adding each charge of this milestone to the charge list
                            }
                        }
                }
                // adding the overall value of this milestone to the totals wrapper
                temp1.overallAmtUSD = InventoryCostServices.InformatR(overallAmt/3.6725);
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
                system.debug('Name of the Milestone'+p);
                system.debug('Basic Percentage'+('Charge')+Seq+('Percentage__c'));
                basicPercent = ((Decimal)p.get('Charge'+Seq+'Percentage__c')).setScale(2); // Added by Neha on 25/3/19
                dw.basicPercentage = basicPercent + ' %'; // Added by Neha on 25/3/19
                dw.installmentName = p.Installment__c; // Added by Neha on 25/3/19           
                
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
        Map <Id, List <DemandWrapper>> CustomerMap = new Map <Id, List <DemandWrapper>> ();
        for (DemandWrapper dw: dwList) {
            if (customerMap.containsKey(dw.pm.Quotation__R.Unit__c))
                customerMap.get(dw.pm.Quotation__R.Unit__c).add(dw);
            else {
                List <DemandWrapper> dwListTemp = new List <DemandWrapper> ();
                dwListTemp.add(dw);
                customerMap.put(dw.pm.Quotation__R.Unit__c, dwListTemp);
            }
        }
        System.debug('Customer Map:' + customerMap);
        return customerMap;
    }
    
    public static Map <String, Decimal> getCurrentOutStanding(Id customerId, Id unitId) {
        Map <String, Decimal> currentOutstandingMap = new Map < String, Decimal > ();
        Booking__c b = [Select Id, Name, Total_Agreement_Value_Demanded__c, Total_Agreement_Value_Paid__c, Total_Agreement_Value_Balance__c,
                        Total_Service_Tax_Demanded__c, Total_Service_Tax_Paid__c, Total_Service_Tax_Balance__c,
                        Total_Other_Charges_Demanded__c, Total_Other_Charges_Paid__c, Total_Other_Charges_Balance__c                        
                        from Booking__c where Opportunity__c =: CustomerId and unit__c =: unitId];
        if (b != null) {
            currentOutstandingMap.put('CV Demanded', math.abs(b.Total_Agreement_Value_Demanded__c.setscale(0,RoundingMode.HALF_UP)));
            currentOutstandingMap.put('CV Paid', math.abs(b.Total_Agreement_Value_Paid__c.setscale(0,RoundingMode.HALF_UP)));
            currentOutstandingMap.put('CV Balance', math.abs(b.Total_Agreement_Value_Balance__c.setscale(0,RoundingMode.HALF_UP)));
            currentOutstandingMap.put('CV Tax Demanded', math.abs(b.Total_Service_Tax_Demanded__c.setscale(0,RoundingMode.HALF_UP)));
            currentOutstandingMap.put('CV Tax Paid', math.abs(b.Total_Service_Tax_Paid__c.setscale(0,RoundingMode.HALF_UP)));
            currentOutstandingMap.put('CV Tax Balance', math.abs(b.Total_Service_Tax_Balance__c.setscale(0,RoundingMode.HALF_UP)));
            
            currentOutstandingMap.put('OC Demanded', b.Total_Other_Charges_Demanded__c);
            currentOutstandingMap.put('OC Paid', b.Total_Other_Charges_Paid__c);
            currentOutstandingMap.put('OC Balance', b.Total_Other_Charges_Balance__c); 
        }
        return currentOutstandingMap;
    }
    
    public static Id raiseGroupDemandKickoffBatch(Set < Id > groupDemandIds) {
        DemandsBatch db = new DemandsBatch(groupDemandIds);
        Id batchId = database.executeBatch(db, 1);
        return batchId;
    }
    
    public static Id raisePerMilestoneDemandKickoffBatch(Map<Id,List<Id>> unitMilestoneMap) {
        DemandsBatchPerMilestone db = new DemandsBatchPerMilestone(unitMilestoneMap);
        Id batchId = database.executeBatch(db, 1);
        return batchId;
    }    
    
    public static void raiseGroupDemandNew(Id unitId, Id milestoneId) {
        // if its a group demand, i.e. more than one demand to be raised for a customer at a time, then the unit is passed as a parameter
        // search specific demands gives the list of demands to be raised for that specific unit.      
        String bookingName='';
        String paymentMilestones='';
        try{
            //List<Opportunity> Customer = [Select Id, Unit__c, Unit__r.Name, Unit__r.Tower__r.Name, Unit__r.Tower__r.Cluster__r.Name,
            //Unit__r.Project__r.Name,/* Unit__r.Project__r.Project_Image__c,*/ Unit__r.Configuration__c,Pre_Registration_Status__c, Name, 
            //Relationship_Manager__c, Primary_Email__c, Primary_Name__c, Unit__r.Booking__r.owner.Email, Registration_Date__c,
            //Project__r.Construction_Milestone_Days__c,Project__r.Registration_Milestone_to_be_Add__c, Unit__r.Booking__r.Primary_Applicant_Email__c,Unit__r.Booking__r.Name,Booking__c
            //from Opportunity where Unit__c = :unitId
            //and StageName = 'Booking Confirmed' 
            //and S_Active__c = true 
            //and (Unit__r.Unit_Status__c = 'Sold' OR Unit__r.Unit_Status__c = 'Blocked')];
            List<Booking__c> Customer = [Select Id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Unit__r.Name, Unit__r.Tower__r.Name,
                                         Unit__r.Project__r.Name,Opportunity__r.Name,OwnerId,Owner.Email,
                                         (select Id, Payment_Milestones__c from Demands__r) 
                                         From Booking__c 
                                         WHERE 
                                         Unit__c =: unitId AND 
                                         Status__c = 'Processed' AND 
                                         Stage_of_Booking__c != 'EOI' AND 
                                         (Unit__r.Unit_Status__c = 'Sold' OR Unit__r.Unit_Status__c = 'Blocked')];
            
            if(Customer.size() > 0){
                bookingName = Customer[0].Name;
                for(Demand__c dm : Customer[0].Demands__r){
                    paymentMilestones = paymentMilestones + dm.Payment_Milestones__c + ' # ';
                }
                system.debug('VVK paymentMilestones: '+paymentMilestones);
            }
            
            if(Customer.size() == 1){
                system.debug('Customer::: '+Customer[0] ); 
                Map <Id, List <DemandWrapper>> customerDemandWrapperMap  = new Map <Id, List <DemandWrapper>>();
                
                customerDemandWrapperMap = searchSpecificDemands(Customer[0].Unit__r.Tower__r.Name,
                                                                 Customer[0].Unit__r.Project__r.Name,
                                                                 Customer[0].Opportunity__r.Name,
                                                                 Customer[0].Unit__r.Name,
                                                                 Customer[0].Name,
                                                                 null, null, null, milestoneId);
                List <Demand__c> demandList = new List <Demand__c> ();
                system.debug('customermap::: ' + customerDemandWrapperMap);
                system.debug('unitId:::: ' + unitId);
                list<Payment_Milestones__c> pmToUpdateIsDemandRaisedFlag = new list<Payment_Milestones__c>();
                for (DemandWrapper d: customerDemandWrapperMap.get(unitId)) {
                    // create Demands
                    if(!paymentMilestones.contains(d.pm.Id)){
                        Demand__c di = new Demand__c();
                        di.Payment_Milestones__c = d.pm.Id;
                        di.Quotation__c = d.pm.Quotation__c;
                        di.Booking__c = d.pm.Quotation__r.Booking__c;            
                        di.Invoice_Date__c = d.pm.Invoice_Date__c; 
                        di.Due_Date__c = d.pm.Invoice_Due_Date__c; 
                        di.Milestone_Name__c = d.pm.Milestone_Name__c; // Added by Neha on 29/5/19
                        di.Unit__c = d.pm.Quotation__r.Unit__c; //// Added by Neha on 28/6/19 
                        di.Project__c = d.pm.Quotation__r.Unit__r.Project__c;  //// Added by Neha on 28/6/19 
                        
                        if(milestoneId == null || String.isBlank(milestoneId))
                            di.is_group_demand__c  = true;
                        Payment_Milestones__c p = new Payment_Milestones__c();
                        p = d.pm;
                        
                        Map<String, Tax_Slab__c> taxSlabMap = getTaxRatesForProjectCharges(unitId, d.pm.Invoice_Date__c);
                        system.debug('tax slab map::: ' + taxSlabMap);
                        for (Integer i = 1; i <= 15; i++) {
                            Decimal amountForTaxation = 0;
                            Decimal sgst = 0;
                            Decimal cgst = 0;
                            if (p.getSObject('Charge_' + i + '_Lookup__r') != null &&
                                (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') != null &&
                                String.isNotBlank((String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c')) &&
                                (String) p.getSObject('Charge_' + i + '_Lookup__r').get('ChargeBucket__c') == 'Agreement Value') {
                                    if ((String) p.get('Charge' + i + 'Name__c') != null && String.isNotBlank((String) p.get('Charge' + i + 'Name__c'))) {
                                        di.put('Charge_' + i + '_Name__c', p.get('Charge' + i + 'Name__c'));
                                        if (p.get('C' + i + '_Amount__c') != null) {
                                            di.put('Charge_' + i + '_Demanded__c', math.abs(((Decimal) p.get('C' + i + '_Amount__c')).setscale(0,RoundingMode.HALF_UP)));
                                            amountForTaxation = math.abs(((Decimal) p.get('C' + i + '_Amount__c')).setscale(0,RoundingMode.HALF_UP));
                                        } 
                                        
                                        di.put('Charge_' + i + '_Lookup__c', p.get('Charge_' + i + '_Lookup__c'));
                                        String chargeName = (String) p.get('Charge' + i + 'Name__c');
                                        if(chargeName == 'Parking Charges')
                                            chargeName = 'Basic';
                                        if(taxSlabMap.containsKey(chargeName)) {
                                            sgst = math.abs(((amountForTaxation * taxSlabMap.get(chargeName).Taxable2_Percentage__c * taxSlabMap.get(chargeName).Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP));
                                            cgst = math.abs(((amountForTaxation * taxSlabMap.get(chargeName).Taxable1_Percentage__c * taxSlabMap.get(chargeName).Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP));
                                        }
                                        di.put('Charge_' + i + '_SGST__c', sgst);
                                        di.put('Charge_' + i + '_CGST__c', cgst);
                                    }
                                }
                        }
                        
                        //// Added by Neha on 11/6/19 Starts Here to tag natural accounts in demand record        
                        List<Account_Master__c> am = new List<Account_Master__c>();
                        Map<String, Id> accMasterMap = new Map<String, Id>();
                        Map<String, Id> accMasterMapForTaxRate = new Map<String, Id>(); 
                        am = [SELECT Id, Name, Tax_Rate__c, Type__c FROM Account_Master__c]; 
                        if(!am.isEmpty()){
                            for(Account_Master__c a: am){
                                if(a.Type__c == 'Others')
                                    accMasterMap.put(a.Name, a.Id);
                                else if(a.Type__c == 'VAT')   
                                    accMasterMapForTaxRate.put(a.Tax_Rate__c, a.Id);             
                            }
                            if(!accMasterMap.isEmpty()){            
                                for(String s: accMasterMap.keySet()){
                                    if(s.equalsIgnoreCase('Trade Receivable'))
                                        di.Total_Amount_with_Tax_Account__c = accMasterMap.get(s);
                                    if(s.equalsIgnoreCase('Unearned Revenue'))  
                                        di.Total_Amount_Account__c = accMasterMap.get(s);
                                }
                            }              
                            if(taxSlabMap != null){
                                if(taxSlabMap.containsKey('Basic')){
                                    if(!accMasterMapForTaxRate.isEmpty()){
                                        for(String s: accMasterMapForTaxRate.keySet()){
                                            if(s.equalsIgnoreCase(taxSlabMap.get('Basic').Tax_Rate__c))
                                                di.Total_Tax_Account__c = accMasterMapForTaxRate.get(taxSlabMap.get('Basic').Tax_Rate__c);                                    
                                        } 
                                    }               
                                }
                                di.Tax_Rate__c = taxSlabMap.get('Basic').Tax_Rate__c;
                            } 
                        }
                        if(unitId != null){
                            Unit__c u = [SELECT Tower__c FROM Unit__c where Id = :unitId];
                            if(u.Tower__c != null){
                                Tower__c t = [SELECT Business_Unit__c, Business_Unit_Code__c FROM Tower__c WHERE Id = :u.Tower__c];
                                di.Business_Unit__c = t.Business_Unit__c;
                                di.Business_Unit_Code__c = t.Business_Unit_Code__c;
                            }
                        }
                        di.GL_Date__c = System.Today(); // date demand is raised
                        di.Payment_Towards__c = 'ESCROW Account';
                        //// Added by Neha on 11/6/19 Ends Here to tag natural accounts in demand record                    
                        demandList.add(di);
                        System.debug('Demand to be raised:' + di);
                    }
                    else{
                        pmToUpdateIsDemandRaisedFlag.add(new Payment_Milestones__c(Id=d.pm.Id,is_demand_raised__c=true));
                    }
                }
                
                List <Id> dId = new List <Id> ();
                if (demandList != null & !demandList.isEmpty()) {
                    Database.SaveResult[] resultLst = Database.insert(demandList);
                    for (Database.SaveResult r: resultLst) {
                        if (r.isSuccess()) {
                            dId.add(r.getId());
                        } 
                    }
                }
                if(pmToUpdateIsDemandRaisedFlag.size()>0){
                    try{
                        update pmToUpdateIsDemandRaisedFlag;
                    }
                    catch(Exception ex){
                        DemandManagementServices.insertErrorLog('Failed to mark Is Demand Raised flag for duplicate Demands. '+ ex.getMessage(),ex.getStackTraceString(),bookingName,'DemandManagementServices');
                    }
                }
                
                List <Demand__c> diList = [Select Id, Name, Invoice_Date__c, Due_Date__c, Invoice_Number__c, Booking__r.Opportunity__r.Name,  Booking__r.Opportunity__r.Unit__r.Name, Booking__r.Opportunity__r.Unit__r.Tower__r.Name, Booking__r.Opportunity__r.Unit__r.Tower__r.Cluster__r.Name, AttachmentId__c from Demand__c where Id in: dId];
                if(diList.size() > 0){
                    String invoiceNumber = '';
                    Date invoiceDueDate = system.today().addDays(-10000);
                    for (Demand__c demand: diList) {
                        invoiceNumber = demand.Invoice_Number__c;
                        if(invoiceDueDate < demand.Due_Date__c)
                            invoiceDueDate = demand.Due_Date__c;
                    }
                    
                    PageReference pageRef = new PageReference('/apex/DemandViewNew'); // Changed by Neha on 2/4/19
                    pageRef.getParameters().put('mode', 'raise');
                    pageRef.getParameters().put('letterHead', '1');
                    pageRef.getParameters().put('previewId', unitId);
                    pageRef.getParameters().put('invoiceDueDate', invoiceDueDate.format());
                    pageRef.getParameters().put('invoiceNumber', invoiceNumber);
                    ///   pageRef.getParameters().put('isRaiseDemanddashboard','true');
                    if(milestoneId != null)
                        pageRef.getParameters().put('forMilestone', milestoneId);
                    
                    PageReference pageRef2 = new PageReference('/apex/SendDemandMail');
                    pageRef2.getParameters().put('unitId', unitId);
                    pageRef2.getParameters().put('invoiceDueDate', invoiceDueDate.format());
                    pageRef2.getParameters().put('invoiceNumber', invoiceNumber);
                    if(milestoneId != null)
                        pageRef2.getParameters().put('milestoneId', milestoneId);       
                    
                    // create the new attachment
                    // List < Attachment > aList = new List < Attachment > ();
                    // the contents of the attachment from the pdf
                    Blob body;
                    Blob htmlBody;
                    try {
                        // returns the output of the page as a PDF
                        if(!test.isRunningTest()) {
                            body = pageRef.getContentAsPDF();
                            htmlBody = pageRef2.getContent();
                        }
                        else {
                            htmlBody = Blob.valueof('Dummy Content for Test Methods');
                            body = Blob.valueOf('Some Text');
                        }    
                    } catch (VisualforceException e) {
                        system.debug('in the catch block');
                        body = Blob.valueOf('Some Text');
                    }
                    ContentVersion cont = generateNewContentVersion(body, diList[0]);
                    createFeedItem(cont.Id, diList);
                    List<Demand__c> dmandListForUpdate = new List<Demand__c>();
                    for(Demand__c d : diList){
                        d.AttachmentId__c = cont.id;
                        dmandListForUpdate.add(d); 
                    }
                    update dmandListForUpdate; 
                    
                    List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
                    for (DemandWrapper d: customerDemandWrapperMap.get(unitId)) {
                        d.pm.Is_Demand_Raised__c = true;
                        pmList.add(d.pm);
                    }
                    if(!pmList.isEmpty()){
                        try {
                            update pmList;
                        } catch (Exception ex) {
                            DemandManagementServices.insertErrorLog('Failed to mark Is Demand Raised flag. '+ ex.getMessage(),ex.getStackTraceString(),bookingName,'DemandManagementServices');
                            Demand_Errors__e  evt = new Demand_Errors__e();
                            evt.Error_Message__c = bookingName +': Failed to mark Is Demand Raised flag.';
                            EventBus.publish(evt);
                            System.debug('Exception while updating payment milestones:' + ex);
                        }
                    }
                    
                    /*  if(customer != null) {
                    customer.Latest_Demand_Due_Date__c = invoiceDueDate;
                    update customer;
                    }*/
                    
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    for (ContentVersion c : [SELECT id,VersionData,Title FROM ContentVersion WHERE Id =: cont.Id]){
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(c.Title+'.pdf');
                        efa.setBody(c.VersionData);
                        fileAttachments.add(efa);
                    }
                    List<String> toAddresses = new List<String>();
                    List<String> ccAddress = new List<String>();
                    
                    Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
                    string fromMailId ;
                    if(Customer[0].OwnerId != null){
                        fromMailId = Customer[0].Owner.Email ;
                    }    
                    for(OrgWideEmailAddress owa : [select id,DisplayName, Address from OrgWideEmailAddress]){
                        owaMap.put(owa.Address,owa);
                    }
                    //SOB-336 start
                    String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(customer[0].Id);
                    if(!string.isblank(emailAddressFromBooking)){
                        for(String s : emailAddressFromBooking.split(',')){
                            if(!s.containsIgnoreCase('null')){
                                toAddresses.add(s);
                            }
                        }
                    }
                    
                    //SOB-336 end
                    /*To stop direct notification to customer commented by Neha on 23 Oct 2019*/
                    if(customer[0].Primary_Applicant_Email__c != null && customer[0].Primary_Applicant_Email__c != '')
                        toAddresses.add(customer[0].Primary_Applicant_Email__c);
                    
                    ccAddress.add(System.label.SobhaHelpDeskMe); 
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    // Sets the paramaters of the email
                    email.setSubject('Installment Notice for ' + Customer[0].Unit__r.Name);
                    //email.setToAddresses(toAddresses);
                    email.setToAddresses(toAddresses);
                    email.setCCAddresses(ccAddress);
                    system.debug('Body:: ' + htmlBody);
                    email.setHtmlBody(htmlBody.toString());
                    if(string.isNotBlank(fromMailId) && owaMap != null && owaMap.containsKey(fromMailId))
                        email.setOrgWideEmailAddressId(owaMap.get(fromMailId).id);
                    email.setFileAttachments(fileAttachments);
                    
                    // Sends the email
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                } 
            }
            else{
                DemandManagementServices.insertErrorLog('There are more than one active Booking for the selected customer.','DemandManagementServices.raiseGroupDemandNew',bookingName,'DemandManagementServices');
                Demand_Errors__e  event = new Demand_Errors__e();
                event.Error_Message__c = bookingName +': There are more than one active Booking for the selected customer.';
                EventBus.publish(event);
            }
        }
        catch(Exception e){
            Demand_Errors__e  event = new Demand_Errors__e();
            if(e.getMessage().contains('no viable alternative')){
                DemandManagementServices.insertErrorLog('Opportunity Name is having some special characters in it. '+e.getMessage(),e.getStackTraceString(),bookingName,'DemandManagementServices');
                event.Error_Message__c = bookingName + ': Opportunity Name is having some special characters in it. Please remove it and try again.';
            }
            else{
                DemandManagementServices.insertErrorLog(e.getMessage(),e.getStackTraceString(),bookingName,'DemandManagementServices');
                event.Error_Message__c = bookingName + ': ' + e.getMessage() + ' Trace: ' + e.getStackTraceString();
            }
            EventBus.publish(event);
        }
    }
    
    public static ContentVersion generateNewContentVersion(Blob fileContent, Demand__c d) {
        ContentVersion cont = new ContentVersion();
        cont.Title = d.Invoice_Number__c + '-' + d.Booking__r.Opportunity__r.Name + '-' + d.Booking__r.Opportunity__r.Unit__r.Tower__r.Cluster__r.Name + '-' + d.Booking__r.Opportunity__r.Unit__r.Tower__r.Name + '-' + d.Booking__r.Opportunity__r.Unit__r.Name + system.now();
        cont.VersionData = fileContent;
        cont.PathOnClient = d.Invoice_Number__c +'.pdf';
        cont.ContentLocation = 'S';
        cont.Description = 'Demand for :' + d.Booking__r.Opportunity__r.Name;
        cont.TagCSV = 'Demand for :' + d.Booking__r.Opportunity__r.Name;
        insert cont;
        return cont;
    }
    
    public static void createFeedItem(Id contentId, List<Demand__c> dList ){
        List<FeedItem> flList = new List<FeedItem>();
        if(!Test.isRunningTest()){
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentId].ContentDocumentId;
            
            //Create ContentDocumentLink for putting the doc in the Folder.
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            //// Libraryid for SB: 0581j00000002yo
            //// Libraryid for Production: 0582o0000002N5c
            cDe.LinkedEntityId = '0582o0000002N5c'; // you can use libraryId, objectId,GroupId etc 
            cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
            insert cDe;
            
            for(Demand__c d: dList) {
                FeedItem elm = new FeedItem(Body = 'Post with related document body', ParentId = d.Id, RelatedRecordId = contentId, Type = 'ContentPost');
                flList.add(elm);
            }
            insert flList;
        }
    }
    
    public static Map<String, Tax_Slab__c> getTaxRates(Date invoiceDate) {
        Map<String, Tax_Slab__c> taxslabsMap = new Map<String, Tax_Slab__c>();
        List<Tax_Slab__c> tsList = new List<Tax_Slab__c>();
        tsList = [Select Id, Name, Tax_Name__c, Tax1_Name__c, Tax1_Percentage_on_100__c, Tax1_Percentage__c, Taxable1_Percentage__c,
                  Tax2_Name__c, Tax2_Percentage_on_100__c, Tax2_Percentage__c, Taxable2_Percentage__c,
                  From_Date__c, To_Date__c, Tax_Rate__c from Tax_Slab__c 
                  where 
                  From_Date__c <= TODAY and (To_Date__c >= TODAY OR To_Date__c = null)];
        if(!tsList.isEmpty()) {
            for(Tax_Slab__c ts: tsList) {
                taxslabsMap.put(ts.Tax_Rate__c, ts);
            }
        }                                       
        return taxslabsMap;
    }
    public static Map<String, Tax_Slab__c> getTaxRatesForProjectCharges(Id unitId, Date invoiceDate) {
        Map<String, Tax_Slab__c> taxslabsMap = getTaxRates(invoiceDate);
        System.debug('Tax Rates:' + taxSlabsMap);
        Unit__c u = InventoryCostServices.getUnitDetails(unitId);
        Map<String, Tax_Slab__c> chargeTaxRate = new Map<String, Tax_Slab__c>();
        if(u != null && taxslabsMap!= null && taxslabsMap.size() >= 1) {
            Map<String, ProjectCharges__c> projChargeMap = InventoryCostServices.getProjectChargesMap(u.Project__r.Name, u.Tower__r.Id);
            for(String s: projChargeMap.keySet()) {
                if(taxslabsMap.containsKey(projChargeMap.get(s).tax_rate__c)) {
                    chargeTaxRate.put(s, taxslabsMap.get( projChargeMap.get(s).tax_rate__c) );
                }
            }
            // check if OC received.
            if(u.OC_Received__c) {
                // no tax on basic
                for(String s: projChargeMap.keySet()) {
                    if(projChargeMap.get(s).ChargeBucket__c != null && projChargeMap.get(s).ChargeBucket__c == 'Agreement Value')
                        chargeTaxRate.put(s, taxSlabsMap.get('GST 0%'));
                }
            } else if (u.Tax_Rate_Basic__c != null) {
                // this must be a below 50 sq.mt unit and hence has special tax rate, override the tax at unit level.
                for(String s: projChargeMap.keySet()) {
                    if(projChargeMap.get(s).ChargeBucket__c != null && projChargeMap.get(s).ChargeBucket__c == 'Agreement Value')
                        chargeTaxRate.put(s, taxslabsMap.get(u.Tax_Rate_Basic__c));
                }
            }
        }
        System.debug('Project Charges Tax Rate Map:' + chargeTaxRate);
        return chargeTaxRate;
    }
    
    ////////////// Added By Vikas For getting previous Dues /////////////
    
    Public static List<DemandManagementServices.DemandWrapper> getAllPreviousDemand(Id unitId){
        List<DemandManagementServices.DemandWrapper> dIList = new List<DemandManagementServices.DemandWrapper>();
        if(unitId != null){
            String tempQuery = '';
            for (Integer i = 1; i <= 15; i++) {
                tempQuery += 'Charge_' + i + '_Name__c' + ',';
                tempQuery += 'Charge_' + i + '_Demanded__c' + ',';
                tempQuery += 'Charge_' + i + '_Paid__c' + ',';
                tempQuery += 'Charge_' + i + '_Tax_Demanded__c' + ',';
                tempQuery += 'Charge_' + i + '_Tax_Paid__c' + ',';
                tempQuery += 'Charge_' + i + '_SGST__c' + ',';
                tempQuery += 'Charge_' + i + '_CGST__c' + ',';
                tempQuery += 'Charge_' + i + '_Lookup__r.ChargeBucket__c,';
                tempQuery += 'Charge_' + i + '_Lookup__r.Name,';
                tempQuery += 'Charge_' + i + '_Balance__c,';
                tempQuery += 'Charge_' + i + '_Tax_Balance__c,';
                
            }
            if (tempQuery.length() > 0 && tempQuery.substring(tempQuery.length() - 1).equals(','))
                tempQuery = tempQuery.substring(0, tempQuery.length() - 1);
            String DemandQuery = 'Select Id, Name, Due_Date__c, Invoice_Number__c, Agreement_Value_Demanded_New__c, Service_Tax_on_Agreement_Value_Demanded__c, '+
                ' Agreement_Value_Paid__c,Service_Tax_on_Agreement_Value_Paid__c,Agreement_Value_Balance__c,Service_Tax_on_Agreement_Value_Balance__c, '+
                ' Debit_Type__c,Debit_Paid__c,Debit_Demanded__c,Debit_Balance__c,Total_Amount_Demanded__c,Total_Amount_Paid__c,Total_Amount_Balance__c,'  +
                ' Debit_Tax_Paid__c, Debit_Tax_Balance__c, Debit_Tax_Demanded__c,Total_Tax_Demanded__c,Total_tax_paid__c,Total_Tax_Balance__c,'+ 
                ' Payment_Milestones__r.Milestone_Name__c, No_of_Delay__c,Invoice_Date__c,Overall_Interest_Due__c,Total_Interest_Amount_Due__c,' + 
                ' Tax_on_Total_Interest_Amount_Due__c,' + tempQuery + 
                ' from Demand__c where Booking__r.Unit__c = :unitId and ' +
                ' (Total_Amount_Balance__c != 0 or Total_Tax_Balance__c != 0)' +
                //' and Booking__r.Opportunity__r.S_Active__c = true ' +
                ' and Booking__r.Opportunity__r.StageName =  \'Booking confirmed\' ' +
                ' and Booking__r.Unit__r.Unit_Status__c = \'Sold\' order by Due_Date__c asc' ;
            List<Demand__c> dList = Database.Query(DemandQuery);
            
            if(dList != null && dList.size() > 0) {
                for(Demand__c d: dList) {
                    System.debug('demand oustanding:' +d);
                    DemandWrapper dmw = new DemandWrapper();
                    dmw.dm = d;
                    dmw.ptw.milestoneName = d.Payment_Milestones__r.Milestone_Name__c;
                    dmw.ptw.demandedAmt = InventoryCostServices.InFormatR(d.Total_Amount_Demanded__c); 
                    dmw.ptw.receivedAmt = InventoryCostServices.InFormatR(d.Total_Amount_Paid__c);
                    dmw.ptw.overallAmt = InventoryCostServices.InFormatR(d.Total_Amount_Balance__c);
                    
                    dmw.ptw.demandedTax = InventoryCostServices.InFormatR(d.Total_Tax_Demanded__c); 
                    dmw.ptw.receivedTax = InventoryCostServices.InFormatR(d.Total_tax_paid__c);
                    dmw.ptw.totalTax = InventoryCostServices.InFormatR(d.Total_Tax_Balance__c);
                    dmw.ptw.totalOutstandingWithTax = InventoryCostServices.InFormatR(d.Total_Amount_Balance__c + d.Total_Tax_Balance__c);
                    dmw.ptw.totalDemandedWithTax = InventoryCostServices.InFormatR(d.Total_Amount_Demanded__c + d.Total_Tax_Demanded__c);
                    dmw.ptw.totalInterest = InventoryCostServices.InFormatR(d.Total_Interest_Amount_Due__c);
                    dmw.ptw.totalGSTOnInterest = InventoryCostServices.InFormatR(d.Tax_on_Total_Interest_Amount_Due__c);
                    dmw.ptw.totalDueWithInterest = InventoryCostServices.InFormatR(d.Total_Amount_Balance__c + d.Total_Tax_Balance__c + d.Overall_Interest_Due__c);
                    dmw.ptw.grandTotal = d.Total_Amount_Balance__c + d.Total_Tax_Balance__c + d.Overall_Interest_Due__c;
                    dmw.ptw.totalDueWithoutGSTInterest = InventoryCostServices.InFormatR(d.Total_Amount_Balance__c + d.Total_Tax_Balance__c + d.Total_Interest_Amount_Due__c);
                    dmw.ptw.grandTotalWithoutGSTOnInterest = d.Total_Amount_Balance__c + d.Total_Tax_Balance__c + d.Total_Interest_Amount_Due__c;
                    dIList.add(dmw);
                }                   
            }              
        }        
        return dIList;
    }
    
    public class PrintTotalsWrapper {
        public String overallAmt {get; set;}
        public String overallAmtUSD {get; set;}
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
    
    public class DemandWrapper {
        public Payment_Milestones__c pm {get; set;}
        public Demand__c dm {get; set;}
        public PrintTotalsWrapper ptw {get; set;}
        public List <PrintChargesWrapper> pcwList {get; set;}
        public Boolean perMilestoneSelect {get; set;}
        public String installmentName {get; set;} // Added by Neha on 25/3/19             
        public String basicPercentage {get; set;}  // Added by Neha on 25/3/19
        
        public DemandWrapper() {
            pm = new Payment_Milestones__c();
            ptw = new PrintTotalsWrapper();
            pcwList = new List < PrintChargesWrapper > ();
            perMilestoneSelect = false;
            basicPercentage = ''; // Added by Neha on 25/3/19
            installmentName = '';
        }
    }
    
    public class CustomerWrapper {
        public Opportunity o {get; set;}
        public Unit__c u {get; set;}
        public String styleName {get; set;}
        public Boolean groupSelect {get; set;}  
        public Booking__c booking {get; set;} 
        public CustomerWrapper() {
            groupSelect=false;
        }
    }  
    
    public static void insertErrorLog(string errorMsg, string stackTrace, string recordName, string className){
        Error_Log__c logError = new Error_Log__c();
        logError.Name=recordName;
        logError.Class__c=className;
        logError.Message__c=errorMsg;
        logError.Request__c=stackTrace;
        insert logError;
    }
    
}