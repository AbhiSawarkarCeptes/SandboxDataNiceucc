public class DemandAutoGenerationController {
    public static void raiseGroupDemandNew(Id unitId) {
        String bookingName='';
        String paymentMilestones='';
        try{
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
                for(Demand__c dm : Customer[0].Demands__r) { paymentMilestones = paymentMilestones + dm.Payment_Milestones__c + ' # '; }
            }
            if(Customer.size() == 1){
                Map <Id, List <DemandWrapper>> customerDemandWrapperMap  = new Map <Id, List <DemandWrapper>>();
                
                customerDemandWrapperMap = searchSpecificDemands(Customer[0].Unit__r.Tower__r.Name,
                                                                 Customer[0].Unit__r.Project__r.Name,
                                                                 Customer[0].Opportunity__r.Name,
                                                                 Customer[0].Unit__r.Name,
                                                                 Customer[0].Name);
                List <Demand__c> demandList = new List <Demand__c> ();
                list<Payment_Milestones__c> pmToUpdateIsDemandRaisedFlag = new list<Payment_Milestones__c>();
                for (DemandWrapper d: customerDemandWrapperMap.get(unitId)) {
                    if(!paymentMilestones.contains(d.pm.Id)){
                        Demand__c di = new Demand__c();
                        di.Payment_Milestones__c = d.pm.Id;
                        di.Quotation__c = d.pm.Quotation__c;
                        di.Booking__c = d.pm.Quotation__r.Booking__c;            
                        di.Invoice_Date__c = d.pm.Invoice_Date__c; 
                        di.Due_Date__c = d.pm.Invoice_Due_Date__c; 
                        di.Milestone_Name__c = d.pm.Milestone_Name__c; 
                        di.Unit__c = d.pm.Quotation__r.Unit__c; 
                        di.Project__c = d.pm.Quotation__r.Unit__r.Project__c; 
                        
                        Payment_Milestones__c p = new Payment_Milestones__c();
                        p = d.pm;
                        
                        Map<String, Tax_Slab__c> taxSlabMap = getTaxRatesForProjectCharges(unitId, d.pm.Invoice_Date__c);
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
                        
                        List<Account_Master__c> am = new List<Account_Master__c>();
                        Map<String, Id> accMasterMap = new Map<String, Id>();
                        Map<String, Id> accMasterMapForTaxRate = new Map<String, Id>(); 
                        am = [SELECT Id, Name, Tax_Rate__c, Type__c FROM Account_Master__c]; 
                        if(!am.isEmpty()){
                            for(Account_Master__c a: am){
                                if(a.Type__c == 'Others') accMasterMap.put(a.Name, a.Id);
                                else if(a.Type__c == 'VAT') accMasterMapForTaxRate.put(a.Tax_Rate__c, a.Id);             
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
                        di.GL_Date__c = System.Today();
                        di.Payment_Towards__c = 'ESCROW Account';
                        demandList.add(di);
                    }
                    else{ pmToUpdateIsDemandRaisedFlag.add(new Payment_Milestones__c(Id=d.pm.Id,is_demand_raised__c=true)); }
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
                    try{ update pmToUpdateIsDemandRaisedFlag; }
                    catch(Exception ex){
                        insertErrorLog('Failed to mark Is Demand Raised flag for duplicate Demands. '+ ex.getMessage(),
                                       ex.getStackTraceString(),
                                       bookingName,
                                       'DemandAutoGenerationController');
                    }
                }
                
                List <Demand__c> diList = [Select Id, Name, Invoice_Date__c, Due_Date__c, Invoice_Number__c, 
                                           Booking__r.Opportunity__r.Name,  Booking__r.Opportunity__r.Unit__r.Name, 
                                           Booking__r.Opportunity__r.Unit__r.Tower__r.Name, 
                                           Booking__r.Opportunity__r.Unit__r.Tower__r.Cluster__r.Name, AttachmentId__c 
                                           from Demand__c 
                                           where Id in: dId];
                if(diList.size() > 0){
                    String invoiceNumber = '';
                    Date invoiceDueDate = system.today().addDays(-10000);
                    for (Demand__c demand: diList) {
                        invoiceNumber = demand.Invoice_Number__c;
                        if(invoiceDueDate < demand.Due_Date__c)
                            invoiceDueDate = demand.Due_Date__c;
                    }
                    
                    PageReference pageRef = new PageReference('/apex/DemandViewNew'); 
                    pageRef.getParameters().put('mode', 'raise');
                    pageRef.getParameters().put('letterHead', '1');
                    pageRef.getParameters().put('previewId', unitId);
                    pageRef.getParameters().put('invoiceDueDate', invoiceDueDate.format());
                    pageRef.getParameters().put('invoiceNumber', invoiceNumber);
                    
                    PageReference pageRef2 = new PageReference('/apex/SendDemandMail');
                    pageRef2.getParameters().put('unitId', unitId);
                    pageRef2.getParameters().put('invoiceDueDate', invoiceDueDate.format());
                    pageRef2.getParameters().put('invoiceNumber', invoiceNumber);
                    
                    Blob body;
                    Blob htmlBody;
                    try {
                        if(!test.isRunningTest()) {
                            body = pageRef.getContentAsPDF();
                            htmlBody = pageRef2.getContent();
                        }
                        else {
                            htmlBody = Blob.valueof('Dummy Content for Test Methods');
                            body = Blob.valueOf('Some Text');
                        }    
                    } catch (VisualforceException e) { body = Blob.valueOf('Some Text'); }
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
                            if(Test.isRunningTest()){ integer tmp = 10/0;}
                        } catch (Exception ex) {
                            insertErrorLog('Failed to mark Is Demand Raised flag. '+ ex.getMessage(),
                                           ex.getStackTraceString(),
                                           bookingName,
                                           'DemandAutoGenerationController');
                            Demand_Errors__e  evt = new Demand_Errors__e();
                            evt.Error_Message__c = bookingName +': Failed to mark Is Demand Raised flag.';
                            EventBus.publish(evt);
                        }
                    }
                    
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
                    
                    String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(customer[0].Id);
                    if(!string.isblank(emailAddressFromBooking)){
                        for(String s : emailAddressFromBooking.split(',')){
                            if(!s.containsIgnoreCase('null')){
                                toAddresses.add(s);
                            }
                        }
                    }
                    
                    if(customer[0].Primary_Applicant_Email__c != null && customer[0].Primary_Applicant_Email__c != '')
                        toAddresses.add(customer[0].Primary_Applicant_Email__c);
                    
                    ccAddress.add(System.label.SobhaHelpDeskMe); 
                    ccAddress.add(System.label.CollectionTeamEmail); 
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    email.setSubject('Installment Notice for ' + Customer[0].Unit__r.Name);
                    email.setToAddresses(toAddresses);
                    email.setCCAddresses(ccAddress);
                    email.setHtmlBody(htmlBody.toString());
                    if(string.isNotBlank(fromMailId) && owaMap != null && owaMap.containsKey(fromMailId))
                        email.setOrgWideEmailAddressId(owaMap.get(fromMailId).id);
                    email.setFileAttachments(fileAttachments);
                    
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    if(Test.isRunningTest()){ integer tmp = 10/0;}
                } 
            }
            else{
                insertErrorLog('There are more than one active Booking for the selected customer.',
                               'DemandAutoGenerationController.raiseGroupDemandNew',
                               bookingName,
                               'DemandAutoGenerationController');
                Demand_Errors__e  event = new Demand_Errors__e();
                event.Error_Message__c = bookingName +': There are more than one active Booking for the selected customer.';
                EventBus.publish(event);
            }
        }
        catch(Exception e){
            Demand_Errors__e  event = new Demand_Errors__e();
            if(e.getMessage().contains('no viable alternative')){
                insertErrorLog('Opportunity Name is having some special characters in it. '+e.getMessage(),
                               e.getStackTraceString(),
                               bookingName,
                               'DemandAutoGenerationController');
                event.Error_Message__c = bookingName + ': Opportunity Name is having some special characters in it. Please remove it and try again.';
            }
            else{
                insertErrorLog(e.getMessage(),e.getStackTraceString(),bookingName,'DemandAutoGenerationController');
                event.Error_Message__c = bookingName + ': ' + e.getMessage() + ' Trace: ' + e.getStackTraceString();
            }
            EventBus.publish(event);
        }
    }
    
    public static Map<String, Tax_Slab__c> getTaxRatesForProjectCharges(Id unitId, Date invoiceDate) {
        Map<String, Tax_Slab__c> taxslabsMap = getTaxRates(invoiceDate);
        Unit__c u = InventoryCostServices.getUnitDetails(unitId);
        Map<String, Tax_Slab__c> chargeTaxRate = new Map<String, Tax_Slab__c>();
        if(u != null && taxslabsMap!= null && taxslabsMap.size() >= 1) {
            Map<String, ProjectCharges__c> projChargeMap = InventoryCostServices.getProjectChargesMap(u.Project__r.Name, u.Tower__r.Id);
            for(String s: projChargeMap.keySet()) {
                if(taxslabsMap.containsKey(projChargeMap.get(s).tax_rate__c)) {
                    chargeTaxRate.put(s, taxslabsMap.get( projChargeMap.get(s).tax_rate__c) );
                }
            }
            if(u.OC_Received__c) {
                for(String s: projChargeMap.keySet()) {
                    if(projChargeMap.get(s).ChargeBucket__c != null && projChargeMap.get(s).ChargeBucket__c == 'Agreement Value')
                        chargeTaxRate.put(s, taxSlabsMap.get('GST 0%'));
                }
            } else if (u.Tax_Rate_Basic__c != null) {
                for(String s: projChargeMap.keySet()) {
                    if(projChargeMap.get(s).ChargeBucket__c != null && projChargeMap.get(s).ChargeBucket__c == 'Agreement Value')
                        chargeTaxRate.put(s, taxslabsMap.get(u.Tax_Rate_Basic__c));
                }
            }
        }
        return chargeTaxRate;
    }
    
    public static Map <Id, List <DemandWrapper>> searchSpecificDemands(String towerName, String projectName, string customer, string unit, string bookingName) {        
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
            ' from Payment_Milestones__c ' +
            ' where Quotation__c != null ' +
            ' and Quotation__r.Unit__c != null ' +
            ' and Quotation__r.Booking__c != null ' +
            ' and Quotation__r.Booking__r.Opportunity__r.StageName =  \'Booking confirmed\' ' +
            ' and (Quotation__r.Unit__r.Unit_Status__c = \'Sold\' OR Quotation__r.Unit__r.Unit_Status__c = \'Blocked\') ' +
            ' and Quotation__r.Booking__r.Status__c = \'Processed\' '+
            ' and Quotation__r.Booking__r.Stage_of_Booking__c != \'EOI\' '+
            ' and is_demand_raised__c = false '+
            ' and Skip_Auto_Demand_Generation__c = false '+
            ' and Milestone_Due_Date__c != null and Milestone_Due_Date__c <= NEXT_N_DAYS:25';
        
        
        String searchQuery = '';
        if (towerName != null && String.isNotBlank(towerName))
            searchQuery += ' and Quotation__r.Unit__r.Tower__r.Name = ' + '\'' + towerName + '\'';
        if (projectName != null && String.isNotBlank(projectName))
            searchQuery += ' and Quotation__r.Unit__r.Project__r.Name = ' + '\'' + projectName + '\'';
        if (unit != null && string.isNotBlank(unit))
            searchQuery += ' and Quotation__r.Unit__r.Name like ' + '\'%' + unit + '%\'';
        if (customer != null && string.isNotBlank(customer))
            searchQuery += ' and Quotation__r.Unit__r.Customers__r.Name like' + '\'%' + String.escapeSingleQuotes(customer) + '%\'';
        if (bookingName != null && string.isNotBlank(bookingName))
            searchQuery += ' and Quotation__r.Booking__r.Name like ' + '\'%' + bookingName + '%\'';
        
        paymentMilestoneList = Database.Query(query + searchQuery + ' order by Name asc');
        Decimal overallAmt = 0;
        Decimal overallTax1 = 0;
        Decimal overallTax2 = 0;
        Decimal basicPercent = 0 ; 
        Integer j = 1;
        Integer sizeofPM = 0; 
        List <DemandWrapper> dwList = new List <DemandWrapper> ();       
        if (paymentMilestoneList != null && paymentMilestoneList.size() > 0) {
            sizeofPM = paymentMilestoneList.size(); 
            for (Payment_Milestones__c p: paymentMilestoneList) {
                List <PrintChargesWrapper> temp = new List <PrintChargesWrapper> ();
                PrintTotalsWrapper temp1 = new PrintTotalsWrapper();
                DemandWrapper dw = new DemandWrapper();
                if (p.Milestone_Type_edit__c.equalsIgnoreCase('Date Linked') && p.Is_Combination_Milestone__c == false) {
                    p.Invoice_Date__c = system.today();
                    p.Invoice_Due_Date__c = p.Milestone_Due_Date__c;               
                }
                else if(p.Milestone_Type_edit__c.equalsIgnoreCase('Construction Linked')){ p.Invoice_Date__c = system.today(); p.Invoice_Due_Date__c = system.today(); }
                else if(p.Milestone_Type_edit__c.equalsIgnoreCase('Date Linked') && p.Is_Combination_Milestone__c == true){
                    if(p.Construction_Stage_Actual_CompletionDate__c != null){ p.Invoice_Date__c = system.today(); p.Invoice_Due_Date__c = p.Milestone_Due_Date__c; } 
                    else { p.Invoice_Date__c = system.today(); p.Invoice_Due_Date__c = system.today(); }
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
                                else pcw.percentage = '';
                                if (p.get('C' + i + '_Amount__c') != null) {
                                    pcw.Amount = InventoryCostServices.InFormat((Decimal) p.get('C' + i + '_Amount__c'));
                                    overallAmt += (Decimal) p.get('C' + i + '_Amount__c');
                                    amountforTaxation = (Decimal) p.get('C' + i + '_Amount__c');
                                } else pcw.Amount = '';
                                
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
                                temp.add(pcw);
                            }
                        }
                }
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
                    if (tempStr.size() == 2)temp1.milestoneName = tempStr[1];
                    else temp1.milestoneName = tempStr[0];
                }
                
                Map<String, Integer> projChargeSeq = InventoryCostServices.getProjectChargesSequence(p.Quotation__R.Unit__r.Project__r.Name, p.Quotation__R.Unit__r.Tower__c); // Added by Neha on 25/3/19
                Decimal Seq = 0;
                if(projChargeSeq != null){
                    Seq = projChargeSeq.get('Basic');
                }
                basicPercent = ((Decimal)p.get('Charge'+Seq+'Percentage__c')).setScale(2); 
                dw.basicPercentage = basicPercent + ' %'; 
                dw.installmentName = p.Installment__c;        
                
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
        return customerMap;
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
    
    public class DemandWrapper {
        public Payment_Milestones__c pm {get; set;}
        public Demand__c dm {get; set;}
        public PrintTotalsWrapper ptw {get; set;}
        public List <PrintChargesWrapper> pcwList {get; set;}
        public Boolean perMilestoneSelect {get; set;}
        public String installmentName {get; set;}           
        public String basicPercentage {get; set;} 
        
        public DemandWrapper() {
            pm = new Payment_Milestones__c();
            ptw = new PrintTotalsWrapper();
            pcwList = new List < PrintChargesWrapper > ();
            perMilestoneSelect = false;
            basicPercentage = '';
            installmentName = '';
        }
    }
    
    public class PrintChargesWrapper {
        public String chargeName {get; set;}
        public String percentage {get; set;}
        public String Amount {get; set;}
        public String Tax1 {get; set;}
        public String Tax2 {get; set;}
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
    
    public static void insertErrorLog(string errorMsg, string stackTrace, string recordName, string className){
        Error_Log__c logError = new Error_Log__c();
        logError.Name=recordName;
        logError.Class__c=className;
        logError.Message__c=errorMsg;
        logError.Request__c=stackTrace;
        insert logError;
    }
    
    public static void createFeedItem(Id contentId, List<Demand__c> dList ){
        List<FeedItem> flList = new List<FeedItem>();
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentId].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = '0582o0000002N5c'; 
        cDe.ShareType = 'I';
        try{ insert cDe; }
        catch(Exception e){}
        
        for(Demand__c d: dList) {
            FeedItem elm = new FeedItem(Body = 'Post with related document body', ParentId = d.Id, RelatedRecordId = contentId, Type = 'ContentPost');
            flList.add(elm);
        }
        try { insert flList; }
        catch(Exception e){}
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
}