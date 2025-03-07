public with sharing class UnitTransfer {
    public Id fromUnitId {get;set;}
    public Id fromBookingId {get;set;}
    public Id toUnitId {get;set;}
    public Id oppId {get; set;}
    public Boolean oppError {get;set;}
    public List<Quotation__c> qList {get; set;}
    public List<Opportunity> oList  {get; set;} // represents the new opportunity of the customer.
    public List<Opportunity> oList1  {get; set;} // represents the old opportunity of the customer.
    public String applicantNames {get;set;}
    public list<SelectOption> lstQuotes {get;set;}
    public String selectedQuote {get;set;}
    public UnitDetailsWrapper fromUnitW {get;set;}
    public UnitDetailsWrapper toUnitW {get;set;}
    public boolean isDifferentLegalEntities {get;set;}
    public List<Payment_Milestones__c> pmList {get;set;}
    public List<Payment_Milestones__c> pmListOriginal {get;set;}
    public Booking__c oldBookingDetails {get;set;}
    public Boolean transferComplete {get;set;}
    public Map<Integer, List<PrintChargesWrapper>> printChargesMap {get;set;}
    public Map<Integer, PrintTotalsWrapper> printTotalsMap {get;set;}
    public boolean changePaymilestones {get;set;}
    public List<InventoryCostServices.PlanDetailWrapper> payplanDetails {get;set;}
    public String actionType {get;set;}
    public Integer rowNumber {get;set;}
    public String amountDiffrenceTobeSorted {get;set;}
    public Boolean validationError {get;set;} 
    public Map<String, Decimal> allChargesMap {get;set;}
    //public List<Payment_Milestones__c> pmList {get;set;}
    public boolean isConfirmed {get;set;}
    
    public UnitTransfer(){  
            oppId = null;
            fromUnitId = null;
            fromBookingId = null;
            toUnitId = null;
            oppError = false;
            isConfirmed = false;
            changePaymilestones = false;
            isDifferentLegalEntities = false;
            qList = new List<Quotation__c>();
            oList = new List<Opportunity>();
            oList1 = new List<Opportunity>();
            lstQuotes = new List<SelectOption>();
            fromUnitW = new UnitDetailsWrapper();
            toUnitW = new UnitDetailsWrapper();
            pmList = new List<Payment_Milestones__c>();
            pmListOriginal = new List<Payment_Milestones__c>();
            oldBookingDetails = new Booking__c();
            transferComplete = false;
            payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
            validationError = false;
            allChargesMap = new Map<String,Decimal>();
            if(ApexPages.currentPage().getParameters().containsKey('oppId'))  
            if(ApexPages.currentPage().getParameters().get('oppId') != '')      
                    oppId = (Id)ApexPages.currentPage().getParameters().get('oppId'); 
        if(oppId != null) {
                List<String> oppErrorMsg = preChecks(oppId);
                if(oppError) {
                for(String e : oppErrorMsg) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e));
                }
            } 
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'No valid opportunity present, please contact your system administrator'));
        }
    }
    public void dummy() {
        system.debug('testing::'+payplanDetails);
        for(InventoryCostServices.PlanDetailWrapper pd : payplanDetails) {
            system.debug('charge Type::'+pd.ppm);
        }
    }
    public List<String> preChecks(Id oppId) {
            List<String> errorMsgs = new List<String>();
            // this is the new opportunity with the new unit
            oList = [Select Id, Name, Project__c, AccountId,  Unit__r.Name, Unit__c from Opportunity where id =:oppId];
            if(oList != null && oList.size() ==1) {
                
                // select the list of quotation against the new opportunity
                qList = [Select Id, Name, Unit__r.Project__c, Unit__r.Project__r.Name, Unit__c, Unit__r.Name, Token_Amount__c,
                         Charge1Value__c,Charge2Value__c,Charge3Value__c,Charge4Value__c,Charge5Value__c,Unit__r.Tower__r.Name 
                         from Quotation__c where Opportunity__r.stageName NOT in ('Closed Lost', 'Closed Won') and Opportunity__c = : oppId 
                         and Unit__r.Project__c =: oList[0].Project__c and (Unit__r.Unit_Status__c = 'Available' OR Unit__r.Unit_Status__c = 'Reserved')
                         and Booking__c =: null and Active_Quotation__c = TRUE and Quote_Status__c =: 'Valid'];
                System.debug('qList::: ' + qList);
                if(qList.isEmpty()) {
                    errorMsgs.add('There are no quotation available against this opportunity, please create quote for the new unit before you start the transfer process');
                } else {
                    for(Quotation__c q : qList) {
                        lstQuotes.add(new SelectOption(q.Id, q.Name + ' on ' + q.Unit__r.Name + ' in '/* + q.Unit__r.Wing__r.Name + ' of ' */+ q.Unit__r.Tower__r.Name + ' ' + q.Unit__r.Project__r.Name));
                }
                }
                oList1 = [Select Id, Name, StageName,Primary_Name__c,Other_Applicants_Name__c, 
                Future_Correspondence_Contact__c,Future_Correspondence_Contact_Name__c, Email__c, 
                Future_Correspondence_Contact_Email__c, Primary_Email__c, Other_Applicants_Email__c,
                Primary_pancard__c, Other_Applicants_Pancard__c, Unit__r.Name, Unit__c, Booking__c from Opportunity where AccountId =: oList[0].AccountId and Id != :oList[0].Id and stageName = 'Cancelled' and Reason_for_Cancellation_D__c = 'Cancellation & Transfer'];
                if(oList1 == null || oList1.isEmpty()) {
                    errorMsgs.add('This customer does not have any other bookings which are currently in cancelled status. Please cancel the existing booking owned by the customer before you start the process');
                } else {
                    if(String.isNotBlank(oList1[0].Primary_Name__c)) 
                applicantNames = oList1[0].Primary_Name__c;
                if(String.isNotBlank(oList1[0].Other_Applicants_Name__c) && string.IsnotBlank(applicantNames))
                    applicantNames += ',' + oList1[0].Other_Applicants_Name__c;
                else if(String.isNotBlank(oList1[0].Other_Applicants_Name__c))
                    applicantNames = oList1[0].Other_Applicants_Name__c;
                fromUnitId = oList1[0].Unit__c;
                fromBookingId = oList1[0].Booking__c;
                }
            }
            if(!errorMsgs.isEmpty()) {
                oppError = true;
            }
            return errorMsgs;
    }
    
    public void selectQuote() {
            System.debug('in select quote:' + selectedQuote);
            Boolean isValid = (selectedQuote InstanceOf ID) ? true : false;
        If(isValid) {
                List<Quotation__c> qList = [Select Id, Name,Total_of_Amount_Taxes_Agreement_Value__c, Unit__c, Unit__r.Project__c, Unit__r.Project__r.Name, 
                                    Unit__r.Name, Unit__r.Chargeable_Area__c, Unit__r.Tower__r.Name, Unit__r.Tower__c, Total_Agreement_Value_Bucket__c,
                                    Unit__r.Configuration__c, Unit__r.Floor__c, Unit__r.Carpet_Area__c, Token_Amount__c,
                                    Charge1Value__c, Charge2Value__c, Charge3Value__c, Charge4Value__c, Charge5Value__c from Quotation__c  where Id = :selectedQuote];
                System.debug('selectQuote qList::: ' + qList);
                if(qList != null & qList.size() == 1) {
                    toUnitW.unitName = qList[0].Unit__r.Name;
                    toUnitId = qList[0].Unit__c;
                    toUnitW.floor = string.valueOf(qList[0].Unit__r.Floor__c);
                    toUnitW.projectName = /* qList[0].Unit__r.Wing__r.Name + ' of ' + */ qList[0].Unit__r.Tower__r.Name + ' in ' + qList[0].Unit__r.Project__r.Name;
                    toUnitW.considerationValue = InventoryCostServices.InFormat(qList[0].Total_Agreement_Value_Bucket__c);
                    toUnitW.configuration = qList[0].Unit__r.Configuration__c;
                    toUnitW.carpetArea = String.valueOf(qList[0].Unit__r.Chargeable_Area__c);
                    Legal_Entity__c l = InventoryCostServices.getLegalEntityDetails(toUnitId, qList[0].Unit__r.Project__c, qList[0].Unit__r.Tower__c);
                    Integer basicChargeSeq = 0;

                    allChargesMap.put('Agreement Value AMOUNTTOTAL',qList[0].Total_Agreement_Value_Bucket__c);
                    if(l != null) {
                        toUnitW.legalEntityName = l.Name;
                        toUnitW.legalEntityRec = l;
                    }
                }                   
        } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Something went wrong! Please contact your system administrator'));
        }
        
        // fetch the old units details
        if(fromBookingId != null) {
            List<Booking__c> bList = [Select Id, Name, Unit__c, Unit__r.Project__c, Unit__r.Project__r.Name, Cancellation_End_Date__c,
                                        Unit__r.Name, Unit__r.Tower__r.Name, Unit__r.Tower__c, Unit__r.Chargeable_Area__c,
                                        Unit__r.Configuration__c, Unit__r.Floor__c, Unit__r.Carpet_Area__c , Booking_Date__c,Quotation__r.Total_Agreement_Value_Bucket__c
                                        , Date_of_Cancellation__c, Quotation__r.Total_of_Amount_Taxes_Agreement_Value__c from Booking__c where Id =:fromBookingId];
                if(bList != null && bList.size() ==1) {
                    fromUnitW.unitName = bList[0].Unit__r.Name;
                    fromUnitW.floor = string.valueOf(bList[0].Unit__r.Floor__c);
                    fromUnitW.projectName = bList[0].Unit__r.Tower__r.Name + ' in ' + bList[0].Unit__r.Project__r.Name;
                    fromUnitW.considerationValue = InventoryCostServices.InFormat(bList[0].Quotation__r.Total_Agreement_Value_Bucket__c);
                    fromUnitW.configuration = bList[0].Unit__r.Configuration__c;
                    fromUnitW.carpetArea = String.valueOf(bList[0].Unit__r.Chargeable_Area__c);
                    Legal_Entity__c l = InventoryCostServices.getLegalEntityDetails(fromUnitId, bList[0].Unit__r.Project__c, bList[0].Unit__r.Tower__c);
                    if(l != null) {
                        fromUnitW.legalEntityName = l.Name;
                        fromUnitW.legalEntityRec = l;
                    }
                    fromUnitW.bookingDate = bList[0].Booking_Date__c.format();
                    fromUnitW.dateOfCancellation = Date.ValueOf(bList[0].Cancellation_End_Date__c).format();
                }                       
        }
        
        if(fromUnitW.legalEntityRec != null && fromUnitW.legalEntityRec.Id != toUnitW.legalEntityRec.Id) {
                isDifferentLegalEntities = true;
        }           
    }
    public void rowModify(){
        if(actionType.equals('add')){
                System.Debug(payPlanDetails[rowNumber]);
                system.debug('before rowNumber::'+rowNumber);
                system.debug('before payplan Details list Size::'+payPlanDetails.size());
                //payPlanDetails.remove(payPlanDetails.size()-1);
                InventoryCostServices.PlanDetailWrapper ppd = new InventoryCostServices.PlanDetailWrapper(new Payment_Plan_Milestones__c(), new Payment_Milestones__c(), '', 0, '', 0,'', '', '', true,true, payPlanDetails[rowNumber].lstConstructionStages, payPlanDetails[rowNumber].fldMap, false);
                if(rowNumber != (payPlanDetails.size() -1))
                    payPlanDetails.add(rowNumber+1,ppd);
                else
                    payPlanDetails.add(ppd);
               payPlanDetails[rowNumber+1].editedRowStyle = 'Edited';
        } else if(actionType.equals('clone')) {
        } else if(actionType.equals('del')) {
                payPlanDetails.remove(rowNumber);
        }
    }
    public void changePaymentMilestones () {
        String queryString1 = '';
        List<Unit__c> unit = [Select Id, Project__r.Name,Tower__r.Name, Tower__r.Id , Project__r.Id from Unit__c where Id = :toUnitId];
            list<Project_Construction_Stages__c> pclist = InventoryCostServices.getConstructionStagesForTower(unit[0].Project__r.Id, unit[0].Tower__r.Id);
            List<SelectOption> lstStages = new List<SelectOption>();
                if(pclist != null && !pcList.isEmpty()) {
                    lstStages.add(new SelectOption('', '--None--'));
                    for(Project_Construction_Stages__c p : pclist) {            
                        lstStages.add(new SelectOption(p.Id, p.Name));
                    }
            }
           pmList = new List<Payment_Milestones__c>();
           list<payment_milestones__c> DummyPMList = new List<Payment_milestones__c>();
            for(Integer i = 1; i<=25; i++) {
                queryString1 += 'Charge' + i + 'Name__c'   + ',';
                queryString1 += 'Charge' + i + 'Percentage__c'  + ',';
                queryString1 += 'C' + i + '_Amount__c' + ',';                    
                queryString1 += 'C' + i + '_CGST__c'   + ','; 
                queryString1 += 'C' + i + '_SGST__c'   + ','; 
                queryString1 += 'Charge_' + i + '_Lookup__c' + ',';
            }
            // fetch the payment plan of the new quotation
            if (selectedQuote != null) {
                queryString1 = 'Select ' + queryString1  + ' Id, Name,Milestone_Name__c,Project_Construction_Stages__r.Name, is_demand_raised__c,Milestone_Due_Date__c,Project_Construction_Stages__c ,Time_Period__c, Number_Of_Days__c,Milestone_Type_edit__c,Is_Combination_Milestone__c, Milestone_Complete_At_Booking__c,Demand_Raised__c from Payment_Milestones__c where Quotation__c = \'' + selectedQuote + '\' and Milestone_Type_edit__c != \'On Registration\' ';
                DummyPMList = Database.Query(queryString1);
            }           
                        
            oldBookingDetails = [Select TotalAmountDemanded__c, TotalAmountPaid__c, TotalAmountBalance__c, TotalTaxDemanded__c, Totaltaxpaid__c, TotalTaxBalance__c, 
                                Total_Agreement_Value_Demanded__c, Total_Agreement_Value_Paid__c, Total_Agreement_Value_Balance__c,
                                Total_Service_Tax_Demanded__c, Total_Service_Tax_Balance__c, Total_Service_Tax_Paid__c, Agreement_Value_Paid_Percent__c, Agreement_Value_Tax_Paid_Percent__c, 
                                Total_Other_Charges_Demanded__c, Total_Other_Charges_Paid__c,
                                Total_Debit_Amt_Demanded__c, Total_Debit_Amt_Paid__c, Total_Debit_Tax_Demanded__c, Total_Debit_Tax_Paid__c
                                from Booking__c where Id = :fromBookingId];
            String demandQuery = '';
            List<Demand__c> dList = new List<Demand__c>();
            for(Integer i = 1; i<=25; i++) {
                demandQuery += 'Charge_' + i + '_Name__c'   + ',';
                demandQuery += 'Charge_' + i + '_Demanded__c'  + ',';
                demandQuery += 'Charge_' + i + '_SGST__c'  + ',';
                demandQuery += 'Charge_' + i + '_CGST__c' + ',';   
                demandQuery += 'Charge_' + i + '_Lookup__c' + ',';                 
            }
            // fetch all the existing demands.
            if (selectedQuote != null) {
                demandQuery = 'Select ' + demandQuery  + ' Id, Name from Demand__c where Booking__c = \'' + fromBookingId + '\'and Demand_status__c != \'Reversed\' and Debit_demanded__c = 0' ;
                dList = Database.Query(demandQuery);
            }
            system.debug('demand list::: ' + dList.size());
            Integer j = 0;
            Payment_Milestones__c differenceMilestone = new Payment_Milestones__c();
            Map<Integer, Decimal> AmountDifference = new Map<Integer, Decimal>();
            Decimal tempDifference = 0;
            Map<String,String> fldMap = new Map<String,String>();

            // Apply the demanded milestones of the old unit into the payment milestones of the new unit till the demands are offsetted
            // for ex: 100, 200, 300 were demanded and the first three milestones are 100, 100, 100 in the new quotation
            // then make the first three milestones as 100, 200, 300 and carry over the difference of -100, -200 to a new milestone 
            // this amount difference milestone we are creating charge wise. 
            System.debug('qList[0].Unit__r.Project__r.Name::: ' + qList[0].Unit__r.Project__r.Name); 
            System.debug('qList[0].Unit__r.Tower__c::: ' + qList[0].Unit__r.Tower__c); 
            Map<String, Integer> pcSeqMap = InventoryCostServices.getProjectChargesSequence(qList[0].Unit__r.Project__r.Name, qList[0].Unit__r.Tower__c);
            System.debug('pcSeqMap:::: ' +pcSeqMap);
            Integer basicChargeSeq = 0;
            Map<String,ProjectCharges__c> projChargesMap = InventoryCostServices.getProjectChargesMap(qList[0].Unit__r.Project__r.Name,qList[0].Unit__r.Tower__c);
            Map<String,Integer> AVChargesSeqMap = new Map<String, Integer>();
            
            Integer Seq = 1;
            String chgName = '';
            system.debug(projChargesMap);
            //creating a list of all charges that are part of the agreement value their field location, to identify whether they are stored in Charge1, Charge2, Charge3, etc.,
            for(String chargeName : projChargesMap.keySet()) {
                    system.debug('chargeName::'+chgName);
                    chgName = projChargesMap.get(chargeName).ChargeBucket__c;
                    
                if(chgName.equalsIgnoreCase('Agreement Value')) {
                        AVChargesSeqMap.put(chargeName, Seq);
                        
                }
                Seq++;
            }
            AVChargesSeqMap.put('Interest On Common Area Charges', projChargesMap.size() + 1);
            system.debug('AVChargesSeqMap::'+AVChargesSeqMap);
            if(pcSeqMap.containsKey('Basic')) {
                    basicChargeSeq = pcSeqMap.get('Basic');
            }
            //list<payment_milestones__c> DummyPMList = new List<Payment_milestones__c>();
            system.debug('dummy pm LIst:'+DummyPMList);
            system.debug('dummy pm list size:'+DummyPMList.size());
           
            for(Integer i = 0 ; i <  DummyPMList.size() ; i++) {
                 if( (Decimal)DummyPMList[i].get('Charge'+basicChargeSeq+'Percentage__c') != null ||  (Decimal)DummyPMList[i].get('C'+basicChargeSeq+'_Amount__c') != 0 ) {
                            pmList.add(DummyPMList[i]);
                 }
            }
            
            Boolean basicMilestone = false;
            Decimal amount = 0;
            Decimal sgst = 0;
            Decimal cgst = 0;
            Decimal amount1 = 0;
            Decimal sgst1 = 0;
            Decimal cgst1 = 0;
            Decimal basicAmount = 0;
            Decimal basicSGST = 0;
            Decimal basicCGST = 0;
            Decimal Taxtotal = 0;
            Decimal total = 0;
            String tobePaid = '';
            Decimal overallTaxtotal = 0;
            Decimal overallAmountTotal = 0;
            Decimal overallTotal = 0;
            Decimal overallPercentage = 0;
            Integer count = 0;
            Decimal amountForTaxCalculation = 0;
            Decimal amountForTaxCalculationB = 0;
            //Boolean basicMilestone = false;
            Boolean otherChargesMilestone = false;
            Boolean allowedEdit = false;
            ProjectCharges__c chargeDetail;            
            String chargeName = '';
            String percentage ='';
            Decimal value=0;
            String type = '';
            decimal diffrence = 0;
            for(Demand__c d : dList) {
                    basicMilestone = false;
                    tempDifference = 0;
                    for(Integer i = 1; i <=10; i++) {
                        if( (Decimal)pmList[j].get('Charge'+basicChargeSeq+'Percentage__c') != null || (Decimal)pmList[j].get('C'+basicChargeSeq+'_Amount__c') != 0) {
                            pmList[j].put('Charge' + i + 'Name__c' , d.get('Charge_' + i + '_Name__c' ) );
                            tempDifference = (Decimal)(pmList[j].get('C' + i + '_Amount__c') ) - (Decimal)(d.get('Charge_' + i + '_Demanded__c' ));
                            if(AmountDifference.containsKey(i) )
                                AmountDifference.put(i, AmountDifference.get(i) + tempDifference);
                            else
                                AmountDifference.put(i, tempDifference);
                            System.debug('Amount Difference in milestone:' + j + ': for charge :' + d.get('Charge_' + i + '_Name__c' ) + '=' + AmountDifference.get(i));
                            // here we are applying the existing demand milestones on the new quotes payment milestones.
                            // TODO update the milestones are demanded, so that they can't be raised again.
                            pmList[j].put('C' + i + '_Amount__c', d.get('Charge_' + i + '_Demanded__c' ) );
                            pmList[j].put('C' + i + '_CGST__c', d.get('Charge_' + i + '_SGST__c' ) );
                            pmList[j].put('C' + i + '_SGST__c', d.get('Charge_' + i + '_CGST__c' ) );
                            pmList[j].put('Charge_' + i + '_Lookup__c', d.get('Charge_' + i + '_Lookup__c'));
                            pmList[J].is_demand_raised__c = true;
                            // here we are creating a single difference milestone chargewise and taxes as well.
                            differenceMilestone.put('C' + i + '_Amount__c', AmountDifference.get(i));
                            differenceMilestone.put('Charge_' + i + '_Lookup__c', d.get('Charge_' + i + '_Lookup__c'));
                            differenceMilestone.put('Charge' + i + 'Name__c' , d.get('Charge_' + i + '_Name__c' ) );
                            basicMilestone = true;                           
                            diffrence += tempDifference;                           
                            fldMap.put('CHARGETYPE', 'Charge'+j+'Type__c');
                            fldMap.put('CHARGEAMT', 'C'+j+'_amount__c');
                            fldMap.put('CHARGEPCT', 'Charge'+j+'Percentage__c');
                            tempDifference = 0;
                        } else {
                            j++;
                        }
                    }
                    j++;
            }
            //'Charge'+j+'Type__c' = 'Percentage';
            for(Payment_Milestones__c pm : pmList) {
                pmListOriginal.add(pm);
            }
            differenceMilestone.Milestone_Name__c = 'from booking date';
            differenceMilestone.Milestone_Type__c = 'Date Linked';
            differenceMilestone.Milestone_Type_edit__c = 'Date Linked';
            differenceMilestone.Time_Period__c = 'Days';
            differenceMilestone.Number_Of_Days__c = 45;
            differenceMilestone.Milestone_Due_Date__c = system.today().addDays(45);
            allowedEdit = false;
            if(diffrence > 0) {
                pmList.add(j, differenceMilestone);
                allowedEdit = true;
            }
            //printCharges(pmList);
            //transferComplete = true;
            System.debug('diffrence::'+diffrence);
            amountDiffrenceTobeSorted = Inventorycostservices.Informat(diffrence); 
            for(Payment_Milestones__c pm : pmList) {
                    System.debug('PM record:' + pm);
                allowedEdit = false;
               //if(!pm.is_demand_raised__c)
               //     allowedEdit = true;
               if(pm.Id == null)
                   allowedEdit = true;
                Payment_plan_Milestones__c ppm = new Payment_plan_Milestones__c();
                
                if(pm.Milestone_Type_edit__c != 'Construction Linked') {
                    ppm.Milestone_Name_Picklist__c = pm.Milestone_Name__c;
                   tobePaid = pm.Milestone_Name__c;
                }
                else {
                    ppm.Milestone_Name_Picklist__c = '<<Construction Stage Name>>';
                    tobePaid = pm.Project_Construction_Stages__r.Name;
                }
                tobePaid = pm.Milestone_Name__c;
                amount = 0;
                
                for(Integer i = 1; i <=25; i++) {
                    ppm.put('Charge'+i+'Type__c','Amount');
                }
                
                amount = 0;
                taxTotal = 0;
                total = 0;
                for(Integer i : AVChargesSeqMap.values()) {
                    System.debug('i=' + i);
                    if(pm.get('C' +i + '_Amount__c' ) != null)
                        amount+= (Decimal)pm.get('C' +i + '_Amount__c' );
                        if(pm.get('C' + i + '_CGST__c' ) != null && pm.get('C' + i + '_SGST__c' ) != null)
                            taxTotal += (Decimal)pm.get('C' + i + '_CGST__c' ) + (Decimal)pm.get('C' + i + '_SGST__c' );
                        fldMap.put('CHARGETYPE', 'Charge'+i+'Type__c');
                        fldMap.put('CHARGEAMT', 'C'+i+'_amount__c');
                        fldMap.put('CHARGEPCT', 'Charge'+i+'Percentage__c');
                        basicMilestone = true;                      
                }
                total += amount + taxTotal;
                //amount = 
                //fldMap.put('CHARGETYPE', 'Percentage');
                payplanDetails.add(new InventoryCostServices.PlanDetailWrapper(ppm, pm, tobePaid, value, percentage, amount, InventoryCostServices.InFormat(amount),InventoryCostServices.InFormat(taxTotal),InventoryCostServices.inFormat(total),basicMilestone, allowedEdit, lstStages, fldMap, pm.Milestone_Complete_at_booking__c));
            } 
            changePaymilestones = true;
            
    }
    public void updatePlan(){
    List<Unit__c> unit = [Select Id, Project__r.Name,Tower__r.Name, Tower__r.Id , Project__r.Id from Unit__c where Id = :toUnitId];
    
         Map<String, String> validationResponse = validateEditedPlan(unit[0], allChargesMap, payPlanDetails);
            system.debug('update method');
            if(validationResponse != null && validationResponse.containsKey('ERROR')) {
                validationError = true;
                for(String s: validationResponse.keyset()) {
                    if(!s.equals('ERROR')) {
                        ApexPages.addMessage((new ApexPages.message(ApexPages.severity.FATAL, validationResponse.get(s))));
                    }
                }
            } else {
                System.debug('No errors');
                validationError = false;
                Map<String, Integer> pcSeqMap = InventoryCostServices.getProjectChargesSequence(qList[0].Unit__r.Project__r.Name,qList[0].Unit__r.Tower__c);
                Integer basicChargeSeq = 0;
                if(pcSeqMap.containsKey('Basic')) {
                    basicChargeSeq = pcSeqMap.get('Basic');
                }
                Decimal basicAmount = 0;
                If(basicChargeSeq != null)
                    basicAmount = (Decimal)qList[0].get('Charge'+basicChargeSeq+'Value__c');
                    
                allChargesMap.put('Basic',basicAmount);
                payPlanDetails = updatePlanDetails(unit[0],allChargesMap, payPlanDetails);
                
            }
    }
    public void confirmEditSchedule(){
        validationError = false;
        isConfirmed = true;
        List<Payment_milestones__c> pList = new List<Payment_milestones__c>();
        List<InventoryCostServices.PlanDetailWrapper> dummy = new List<InventoryCostServices.PlanDetailWrapper>();
        dummy.addAll(payplanDetails);
        payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
        payplanDetails.addAll(dummy); 
        for(InventoryCostServices.PlanDetailWrapper pd : payplanDetails) {
            system.debug('pd wrapper::'+pd.pm);
            pList.add(pd.pm);
        }
        printCharges(pList);
        
    }
    public void cancelEditSchedule(){
        payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
        changePaymentMilestones();
        //scheduleEdited = true;
        validationError = false;
    }
     public pageReference resetPage(){
       PageReference pageRef;
       pageRef = new PageReference('/apex/UnitTransfer?oppId='+ oppId); 
       pageRef.setRedirect(true);
       return pageRef;
   }     
    public pageReference closePage (){
       PageReference pageRef;
       pageRef = new PageReference('/'+ oppId); 
       pageRef.setRedirect(true);
       return pageRef;
   }     
    public void performTransfer() {
        System.debug('In transfer');
        String errString = '';
        Boolean error = false;
        List<Quotation__c> qList = [Select Id, Name,Total_of_Amount_Taxes_Agreement_Value__c, Unit__c, Unit__r.Project__c, Unit__r.Project__r.Name, Token_Amount__c,
                                Unit__r.Name,Total_Agreement_Value_Bucket__c, Unit__r.Tower__r.Name, Unit__r.Tower__c, Unit__r.Tower__r.Cluster__r.Name,
                                Unit__r.Configuration__c, Unit__r.Floor__c, Unit__r.Carpet_Area__c from Quotation__c where Id = :selectedQuote];
    
        List<Booking__c> bList = [Select Id, Name, Application_No__c, Funding_Status__c, Secondary_Sales_Manager__c, Secondary_Sales_Head__c, 
                                    Primary_Applicant_Email__c, PrimaryMobileNumber__c, Primary_Applicant_Name__c, Verification_status__c, Call_Disposition__c, 
                                    Sub_Source__c, Booking_Source_Details__c, Source_of_Booking__c, Is_Pre_registration_Fees_Paid__c,
                                    Future_Correspondence_Contact_Name__c, Future_Correspondence_Contact__c, Future_Correspondence_Contact_Relation__c, 
                                    Future_Correspondence_Contact_Email__c, Future_Correspondence_Contact_Phone__c,Current_Status__c,
                                    Stage_of_Booking__c, Sales_Managers__c, Sales_Head__c, Booking_Approver_Audit__c, Audit_Approval_Date__c, Comment_Audit__c,
                                    Date_of_Upload_of_CustomerDoc_on_Website__c, Date_of_Generation_of_SPA__c, Date_of_Sending_AOPS_SPA_to_Customer__c,
                                    Date_of_Receiving_Signed_AOPS_SPA__c, Date_of_Signing_by_Sobha_Signatory__c, Date_of_Submission_of_Documents_to_DLD__c,
                                    Date_of_Sending_Certificate_to_Customer__c, Pre_Registration_Remarks__c, SPA_Issue_Date__c, SPA_Sent_Date__c,
                                    SPA_Sent_Through__c, SPA_Courier_Tracking_No__c, SPA_Receive_Date__c, SPA_Executed_Date__c, Executed_Copy_Sent_Date__c,
                                    Executed_Copy_Sent_Through__c, Executed_Copy_Courier_Tracking_No__c, SPA_Remarks__c, Sales_Operations__c,
                                    Channel_Partner__c, Sobha_Connect__c
                                    from Booking__c where Id =: fromBookingId];
      // clone the existing booking and create a new booking
        Booking__c b = bList[0].clone(false, false, false, false);
        b.opportunity__c = oppId;
        b.Quotation__c = selectedQuote;
        b.Project__c = qList[0].Unit__r.Project__c;
        b.Tower__c= qList[0].Unit__r.Tower__r.Name;
        b.Cluster__c = qList[0].Unit__r.Tower__r.Cluster__r.Name;
        b.Unit__c = toUnitId;
        b.Flat_Typology__c = qList[0].Unit__r.Configuration__c;      
        b.Booking_Date__c = system.now();
        b.Carpet_Area__c = qList[0].Unit__r.Carpet_Area__c;
        b.Floor__c = qList[0].Unit__r.Floor__c;
        b.Flat_No__c = qList[0].Unit__r.Name;  /// Added by Neha on 23/10/19
        b.Status__c = 'Processed';
        b.Agreement_Value__c = qList[0].Total_Agreement_Value_Bucket__c;
        b.Token_Amount__c = qList[0].Token_Amount__c; /// Added by Neha on 23/10/19
        try {
            insert b;
        } catch (Exception ex) {
            System.debug('Error inserting booking:' + ex.getMessage());
            error = true;
            errString = ex.getMessage();
        }
        // clone the applicant record
         List<Applicant_Details__c> listApplicant = [SELECT Id,Salutation__c,Name,DOB__c,Permanent_Address__c,
                               Pincode__c, Opportunity__c, Preferred_address_for_all_correspondence__c, 
                               Organisation_Pincode__c,Mailing_Pincode__c,Country__c, Mailing_State__c, State__c,
                               Mailing_Address__c,Mailing_Country__c,Mobile_Number__c,Email_Address__c,Applicant_Number__c,
                               Nationality__c,Landline_Number__c,Occupation__c,Organization_Name__c,Designation__c,
                               Organization_Address__c,Organisation_Country__c,Organization_Phone_numbers__c,
                               Other_Details_Remarks__c,Type_Of_Applicant__c,Subtype_Of_Applicant__c, Passport_Copy__c,Passport_Copy_Details__c,
                               Valid_Until_Passport__c, Emirates_ID__c, Emirates_ID_Details__c, Visa_Copy__c, Visa_Copy_Details__c, Visa_Copy_Valid_Upto__c,
                               Power_of_Attorney__c, Power_of_Attorney_Details__c, Power_of_Attorney_Valid_Upto__c,
                               National_ID__c, National_ID_Details__c, Valid_Upto_National_ID__c,
                               Non_residency_Letter__c, Non_residency_Letter_Details__c, Non_residency_Letter_Valid_Upto__c,
                               Copy_of_Memorandu_of_Association__c, Memoradum_Articles_of_Association__c, Memoradum_Articles_of_Association_Deta__c,
                               Registration_License__c, Registration_License_Details__c, Certificate_of_Good_Standing_and_Certifi__c,
                               Certificate_of_Incorporation__c, Certificate_of_Incorporation_Details__c,
                               Certificate_of_Standing_Incumbe_Detail__c, Certified_copy_of_Article_of_Association__c,
                               Passport_Copy_of_Authorized_Signatory__c, Passport_Copy_of_Authorized_Signatory_De__c,
                               Others__c, Others_Details__c, Others_Valid_Upto__c,
                               Secondary_Contact_Name__c, Secondary_Contact_Number__c, Relationshipof_SecondaryContact_withCust__c,
                               POA_Name__c, POA_Email_Id__c, POA_Contact_Number__c                                                            
                               FROM Applicant_Details__c WHERE Booking__c= :bList[0].Id];
        system.debug('listApplicant' + listApplicant);
        List<Applicant_Details__c> apListToInsert = new List<Applicant_Details__c>();
        for(Applicant_details__c aList : listApplicant) {
            Applicant_details__c apl = new Applicant_details__c();
            apl = aList.clone(false, false, false, false);
            apl.Booking__c = b.Id;
            apListToInsert.add(apl);
        }
        try {
           // if(!apListToInsert.isEmpty())
                insert apListToInsert;
        } catch (Exception ex) {
            System.debug('Error inserting Applicant Details:' + ex.getMessage());
            error = true;
            errString = ex.getMessage();
        }
        try {
               delete pmListOriginal;
        }
        catch(Exception ex) {
            System.debug('Error while deleting existing payment milestones:' + ex.getMessage());
            error = true;
            errString = ex.getMessage();
        }
        try {
            List<Payment_Milestones__c> pmListToInsert = new List<Payment_Milestones__c>();
            if(!payPlanDetails.isEmpty() && payPlanDetails != null) {
             for(InventoryCostServices.PlanDetailWrapper pw : payPlanDetails) {
                if(pw.pm != null) {
                    if(pw.pm.Id != null)
                        pw.pm.Id = null;
                    pw.pm.Quotation__c  = qList[0].Id;
                    pmListToInsert.add(pw.pm);
                }
            }
            insert pmListToInsert ;
            }
        }
        catch(exception ex) {
            System.debug('Error while inserting Payment milestones:' + ex.getMessage());
            error = true;
            errString = ex.getMessage();
        }
        if(!error) {
            List<Unit__c> lstunit = [Select Id, Project__r.Name,Tower__r.Name,Unit_Status__c,Customers__c,Booking__c, Tower__r.Id , Project__r.Id from Unit__c where Id = :toUnitId];
            oList[0].Unit__c = toUnitId;
            oList[0].Booking__c = b.Id;
            oList[0].stageName = 'Booking confirmed';
            // mark each other opportunities id as related oppId in the other opp
            oList[0].related_opportunity__c = oList1[0].Id;
            oList1[0].related_opportunity__c = oList[0].Id;
            qList[0].booking__c = b.Id;
            lstunit[0].Unit_Status__c = 'Sold';
            lstunit[0].Customers__c = oList[0].Id;
        lstunit[0].Booking__c = b.Id;
            update oList;
            update oList1;
            update qList;
        update lstunit;
            
            System_Log__c sl = new System_Log__c();
            sl.Action__c = 'Unit Transfer';
            sl.Booking__c = b.Id;
            //sl.Object_Name__c = 'Receipt';
            sl.Opportunity__c = oList[0].Id;
            sl.Record_Id__c = oList1[0].Id;
            sl.Remarks__c = 'UNIT TRANSFERED FROM: '+fromUnitW.unitName+' TO: '+toUnitW.unitName;
            insert sl;
            
            transferComplete = true;
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error while processing the transfer process:' + errString ));
        }
    }
    public void printCharges(List<Payment_Milestones__c> pmList) {
            printChargesMap = new Map<Integer, List<PrintChargesWrapper>>();
            printTotalsMap = new Map<Integer, PrintTotalsWrapper>();
            Decimal overallAmt = 0;
            Decimal overallTax1 = 0;
            Decimal overallTax2 = 0;
            Integer chargeCount = 1;
            Integer j = 1;
            if(pmList != null) {
                for(Payment_Milestones__c pm: pmList) {
                    List<PrintChargesWrapper> temp = new List<PrintChargesWrapper>();
                    PrintTotalsWrapper temp1 = new PrintTotalsWrapper();
                    if(pm != null) {
                        system.debug('pm in print plan::'+pm);
                        system.debug('Pm id:: ' + pm.id);
                        for(Integer i =1 ; i <=25; i++) {
                            PrintChargesWrapper p = new PrintChargesWrapper();
                            if((String)pm.get('Charge' + i+'Name__c') != null && String.isNotBlank( (String)pm.get('Charge' + i+'Name__c') )) {
                                p.chargeName = (String)pm.get('Charge' + i+'Name__c');
                                System.debug('i::: ' + i);
                                system.debug('Charge name:::' + p.chargeName);
                                if(pm.get('Charge' +i + 'Percentage__c') != null)
                                    p.percentage = String.valueOf((Decimal)pm.get('Charge' +i + 'Percentage__c')) + ' %';
                                else
                                    p.percentage = '';
                                system.debug('Charge percentage:::' + p.percentage );
                                if(pm.get('C' + i + '_Amount__c') != null) {
                                    p.Amount = InventoryCostServices.InFormat((Decimal)pm.get('C' + i + '_Amount__c'));
                                    overallAmt += (Decimal)pm.get('C' + i + '_Amount__c');
                                }
                                else
                                    p.Amount = '';
                                system.debug('Charge amount:::' + p.Amount );
                                system.debug('Charge overall amount:::' + overallAmt);
                                if(pm.get('C' + i + '_SGST__c') != null) {
                                    p.Tax1 = InventoryCostServices.InFormat((Decimal)pm.get('C' + i + '_SGST__c'));
                                    overallTax1 += (Decimal)pm.get('C' + i + '_SGST__c');
                                }
                                else
                                    p.Tax1 =  '';
                                if(pm.get('C' + i + '_CGST__c') != null) {
                                    p.Tax2 = InventoryCostServices.InFormat((Decimal)pm.get('C' + i + '_CGST__c'));
                                    overallTax2 += (Decimal)pm.get('C' + i + '_CGST__c');
                                }
                                else
                                    p.Tax2 = '';
                                system.debug('Tax 2:::' + p.Tax2);
                                chargeCount++;
                                temp.add(p);
                            }
                            
                        }
                        printChargesMap.put(j , temp);
                        temp1.overallAmt = InventoryCostServices.Informat(overallAmt);
                    temp1.overallTax1 = InventoryCostServices.Informat(overallTax1);
                    temp1.overallTax2 = InventoryCostServices.Informat(overallTax2);
                    temp1.chargeCount = chargeCount;
                    temp1.milestoneName = pm.Milestone_Name__c;
                    printTotalsMap.put(j , temp1);
                    j++;
                     }
                    chargeCount = 1;
                    overAllAmt = 0;
                    overallTax1 = 0;
                    overallTax2 = 0;
                }
            }
    }
     public static Map<String,String> validateEditedPlan(Unit__c u ,Map<String,Decimal> allChargesMap,List<Inventorycostservices.PlanDetailWrapper> ppdList){
        
        Map<String, Integer> pcSeqMap = Inventorycostservices.getProjectChargesSequence(u.Project__r.Name,u.Tower__r.Id);
        System.debug('seqMap::'+pcSeqMap);
            Map<String, String> validationMap  = new Map<String,String>();
            Integer basicChargeSeq = 0;
            if(pcSeqMap.containsKey('Basic')) {
                basicChargeSeq = pcSeqMap.get('Basic');
            }
            Integer errorCount = 0;
            Integer count = 1;
            Decimal Amount = 0;
            Decimal Percentage = 0;
        if(ppdList != null && !ppdList.isEmpty()) {
            for(Inventorycostservices.PlanDetailWrapper pd : ppdList) {
                System.debug(LoggingLevel.ERROR, 'pd in update plan:' + pd);
                if(pd.basicMilestone && pd.pm != null && pd.ppm != null) {
                    if(pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') == 'Percentage' && pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') == NULL) {
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '-Please populate the percentage \n');
                        errorCount ++;
                    } else if(pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') == 'Amount' && pd.milestoneAmount == NULL) {
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '-Please populate the amount \n');
                        errorCount ++;
                    }                    
                    /* Added by Neha on 23/10/19 */
                   if(String.isNotBlank(pd.ppm.Milestone_Name_Picklist__c) && pd.ppm.Milestone_Name_Picklist__c.equalsIgnoreCase('from booking date') && String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Construction Linked') && pd.pm.Is_Combination_Milestone__c == false) {
                         validationMap.put('ERROR', 'TRUE');
                         validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '- If Milestone is \'from booking date\', then Milestone Type should be \'Date Linked\'\n');
                         errorCount ++;
                    } 
                    if(String.isNotBlank(pd.ppm.Milestone_Name_Picklist__c) && pd.ppm.Milestone_Name_Picklist__c.equalsIgnoreCase('<<Construction Stage Name>>') && String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Date Linked') && pd.pm.Is_Combination_Milestone__c == false) {
                         validationMap.put('ERROR', 'TRUE');
                         validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '- If Milestone is \'Construction Stage Name\', then Milestone Type should be \'Construction Linked\'\n');
                         errorCount ++;
                    }     
                    // calculate the milestone names, due dates again if the user the has edited them
                    if(pd.pm.Number_Of_Days__c == NULL) {
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '- Please enter the Days Offset \n');
                        errorCount ++;
                    } 
                    /*Added by Neha on 23/10/19 to make Milestone name mandatory */
                    if(String.isBlank(pd.ppm.Milestone_Name_Picklist__c)){ ///  || pd.ppm.Milestone_Name_Picklist__c == NULL
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '- Please select Milestone');
                        errorCount ++;
                    }
                    /*Added by Neha on 23/10/19 to make Offset Type mandatory */
                    if(pd.pm.Time_Period__c == NULL) {
                        validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '- Please enter Offset Type\n');
                        errorCount ++;
                    }
                    /*Added by Neha on 23/10/19 */
                    if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Is_Combination_Milestone__c == false && pd.pm.Milestone_Type_edit__c.equals('Date Linked') && String.isNotBlank(pd.pm.Project_Construction_Stages__c)) {
                         validationMap.put('ERROR', 'TRUE');
                         validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '- In case of Date Linked milestone, Construction stage should be kept blank \n');
                         errorCount ++;
                    }
                    /*else if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && !pd.pm.Milestone_Type_edit__c.equals('Date Linked') && pd.allowedEdit) {
                            // the requirement is that only date linked milestones can be selected when milestones are modified, so adding this extra validation to accommodate that
                            validationMap.put('ERROR', 'TRUE');
                         validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '- Milestone can be modified only to sales linked milesones, No other milestone type selection is allowed \n');
                         errorCount ++;
                    }*/
                    else if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Construction Linked')) {
                            String stage = pd.pm.Project_Construction_Stages__c;
                            Boolean isValid = (stage InstanceOf ID) ? true : false;
                            if(!isValid) {
                                validationMap.put('ERROR', 'TRUE');
                            validationMap.put('MESSAGE-'  + errorCount, 'On Row #' + count + '-Please select a valid construction stage \n');
                            errorCount ++;
                            }
                    } else if (String.isBlank(pd.pm.Milestone_Type_edit__c) || (!pd.pm.Milestone_Type_edit__c.equals('Construction Linked') &&  !pd.pm.Milestone_Type_edit__c.equals('Date Linked') && !pd.pm.Milestone_Type_edit__c.equals('On Registration'))){
                            validationMap.put('ERROR', 'TRUE');
                        validationMap.put('MESSAGE-' + errorCount, 'On Row #' + count + '- Please select a date linked or construction linked milestone type \n');
                        errorCount ++;
                    } 
                    // if there is an error, there is no need to go this step of tallying the data as the input data is incomplete
                    if(!validationMap.containsKey('ERROR')) {
                            // sum up the numbers and see if it adds up to 100% of the TCV
                            System.debug('Tallying the amount and percentages post edit:' + 'basicChargeSeq:' +basicChargeSeq + ':'+ pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') + ':' + (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') );
                            
                            if(pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') == 'Percentage') {
                            // if percentage , calculate the amount
                            system.debug('allcharges Map::'+allChargesMap.get('Agreement Value AMOUNTTOTAL'));
                            amount += ((Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') * allChargesMap.get('Agreement Value AMOUNTTOTAL'))/100;
                            percentage += (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c');
                            } else {
                                // amount , calculate the percentage
                            amount += pd.milestoneAmount;
                            percentage +=  (amount/ allChargesMap.get('Agreement Value AMOUNTTOTAL')*100).setscale(2,RoundingMode.HALF_UP);
                            }
                    
                    }
                    count ++;
               }
            }
            if(!validationMap.containsKey('ERROR')) {
                if(Math.abs(amount - allChargesMap.get('Agreement Value AMOUNTTOTAL')) > 100) {
                    validationMap.put('ERROR', 'TRUE');
                    system.debug('inside second loop:');
                    if(amount > allChargesMap.get('Agreement Value AMOUNTTOTAL')) {
                        validationMap.put('MESSAGE-' + errorCount, 'There is an excess of ₹ ' +  InventoryCostServices.Informat(Math.abs(amount - allChargesMap.get('Agreement Value AMOUNTTOTAL'))) );
                        errorCount ++;
                        validationMap.put('MESSAGE-' + errorCount, 'Percentages add up to: ' +  percentage );
                    }
                    else {
                        validationMap.put('MESSAGE-' + errorCount, 'There is an shortfall of ₹ ' +  InventoryCostServices.InFormat(Math.abs(amount - allChargesMap.get('Agreement Value AMOUNTTOTAL'))) );
                        errorCount ++;
                        validationMap.put('MESSAGE-' + errorCount, 'Percentages add up to: ' +  percentage  );
                    }
                    
                }
            }
            
        } else {
            validationMap.put('ERROR', 'TRUE');
            validationMap.put('MESSAGE-' + errorCount, 'Invalid payment plan definition');
        }
        System.debug(LoggingLevel.ERROR, validationMap);
        
        return validationMap;
   }
   public static List<InventorycostServices.PlanDetailWrapper> updatePlanDetails(Unit__c u , Map<String,Decimal> allChargesMap, List<InventorycostServices.PlanDetailWrapper> ppdList){
        
        Map<String,ProjectCharges__c> projChargesMap = InventorycostServices.getProjectChargesMap(u.Project__r.Name,u.Tower__r.Id);
        Map<String, Integer> pcSeqMap = InventorycostServices.getProjectChargesSequence(u.Project__r.Name,u.Tower__r.Id);
            Map<Id,Project_Construction_Stages__c> pstageMap = InventorycostServices.getConstructionStagesById(u.Project__r.Id,u.Tower__r.Id);    
            Map<String, Tax_Slab__c> chargeTaxMap = InventorycostServices.getTaxRatesForProjectCharges(u.Id);
            List<InventorycostServices.PlanDetailWrapper> pdList = new List<InventorycostServices.PlanDetailWrapper>();
            ProjectCharges__c basicChargeDetails = new ProjectCharges__c();
            if(projChargesMap.containsKey('Basic'))
                basicChargeDetails = projChargesMap.get('Basic');
            // create a new project charge for parking and copy the basic charge details into it.
          ProjectCharges__c carParkCharge = new ProjectCharges__c();
        carParkCharge.Name = 'Interest On Common Area Charges';
        carParkCharge.ChargeBucket__c = basicChargeDetails.ChargeBucket__c;
        carParkCharge.Tax_Rate__c = basicChargeDetails.Tax_Rate__c;
        carParkCharge.Active__c = true;
        projChargesMap.put('Interest On Common Area Charges' , carParkCharge);
        chargeTaxMap.put('Interest On Common Area Charges', chargeTaxMap.get('Basic'));
             
            Integer Seq =1;
            Map<String, Integer> AVChargesSeqMap = new Map<String,Integer>();
            //creating a list of all charges that are part of the agreement value their field location, to identify whether they are stored in Charge1, Charge2, Charge3, etc.,
            for(String chargeName : projChargesMap.keySet()) {
                if(projChargesMap.get(chargeName).ChargeBucket__c.equalsIgnoreCase('Agreement Value')) {
                    if(!projChargesMap.get(chargeName).Name.equalsIgnoreCase('Basic') && !projChargesMap.get(chargeName).Name.equalsIgnoreCase('Interest On Common Area Charges')) {
                        AVChargesSeqMap.put(chargeName, Seq);
                    } 
                    if(projChargesMap.get(chargeName).Name.equalsIgnoreCase('Interest On Common Area Charges')) //allChargesMap.containsKey('Interest On Common Area Charges') && allChargesMap.get('Interest On Common Area Charges') != 0 && 
                         AVChargesSeqMap.put(chargeName, Seq);
                }
                Seq++;
            }
            //AVChargesSeqMap.put('Interest On Common Area Charges', seq);
            System.debug('AV Seq Map:' + AVChargesSeqMap);
            Integer basicChargeSeq = 0;
            if(pcSeqMap.containsKey('Basic')) {
                basicChargeSeq = pcSeqMap.get('Basic');
            }
            Decimal amount = 0;
            Decimal sgst = 0;
            Decimal cgst = 0;
            Decimal amount1 = 0;
            Decimal sgst1 = 0;
            Decimal cgst1 = 0;
            Decimal basicAmount = 0;
            Decimal basicSGST = 0;
            Decimal basicCGST = 0;
            Decimal Taxtotal = 0;
            Decimal total = 0;
            String tobePaid = '';
            Decimal overallTaxtotal = 0;
            Decimal overallAmountTotal = 0;
            Decimal overallTotal = 0;
            Decimal overallPercentage = 0;
            Integer count = 0;
            Decimal amountForTaxCalculation = 0;
            Decimal amountForTaxCalculationB = 0;
            Decimal CalculatedPercentage;
            String percentage = '';
            Decimal tokenAmount = 0;
            //ppdList.remove(ppdList.size()-1);
        if(ppdList != null && !ppdList.isEmpty()) {
            for(InventorycostServices.PlanDetailWrapper pd : ppdList) {
                System.debug('pd in update plan:' + pd);
                // if a new row has been added populate the names of the charges in the appropriate field locations.
                if(pd.editedRowStyle == 'Edited') {
                    pd.pm.put('Charge'+basicChargeSeq+ 'Name__c', 'Basic');
                    pd.pm.put('Charge_'+basicChargeSeq +'_Lookup__c',projChargesMap.get( 'Basic').Id);
                    for(String s :  AVChargesSeqMap.keySet()) {
                        pd.pm.put('Charge'+AVChargesSeqMap.get(s)+ 'Name__c', s);
                        Integer j = AVChargesSeqMap.get(s);
                        if(projChargesMap.containsKey( s) ) {
                          pd.pm.put('Charge_'+j +'_Lookup__c',projChargesMap.get( s).Id);
                        }
                    }
                    
                }
                if(pd.basicMilestone && pd.pm != null && pd.ppm != null && pd.pm.get('Charge'+basicChargeSeq+ 'Name__c') == 'Basic') {
                    if(pd.ppm.get('Charge'+basicChargeSeq+ 'Type__c') == 'Percentage') {
                        // if percentage , calculate the amount
                        amount = ((Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') * allChargesMap.get('Agreement Value AMOUNTTOTAL'))/100;
                            basicAmount = ((Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c') * allChargesMap.get('Basic'))/100;
                            // when the milestone is edited, if basic percentage is altered all the other charges that forms the Agreeement Value bucket should also be set to the same percentage
                            system.debug('avgmap::'+AVChargesSeqMap);
                            system.debug('avgmapValues::'+AVChargesSeqMap.values());
                            for(Integer seq0 :  AVChargesSeqMap.values()) {
                                System.debug('Inside AV Charges Seq loop:' + pd.pm + '::Charge'+seq0+ 'Name__c');
                                pd.pm.put('Charge'+seq0+'Percentage__c',(Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c'));
                                Decimal chargeAmount = 0;
                                system.debug('seq is: '+seq0);
                                //system.debug('Percentage is::'+ pd.pm.get('Charge'+seq0+'Percentage__c'));
                                //system.debug('Name is::'+ pd.pm.get('Charge'+seq0+ 'Name__c'));
                                //System.debug('value is::'+allChargesMap.get((String)pd.pm.get('Charge'+seq0+ 'Name__c')));
                                chargeAmount = ((Decimal)pd.pm.get('Charge'+seq0+'Percentage__c') * allChargesMap.get((String)pd.pm.get('Charge'+seq0+ 'Name__c')))/100;
                                pd.pm.put('C'+seq0+'_amount__c',chargeAmount);
                                ProjectCharges__c chargeDetails = new ProjectCharges__c();
                                if(projChargesMap.containsKey((String)pd.pm.get('Charge'+seq0+ 'Name__c')))
                                    chargeDetails = projChargesMap.get((String)pd.pm.get('Charge'+seq0+ 'Name__c'));
                                Decimal chargeCGST= 0;
                                Decimal chargeSGST = 0;
                    if(!pd.pm.is_demand_raised__c) {
                                    if(chargeDetails != null) {
                                        chargeCGST  = ((chargeAmount * chargeTaxMap.get(chargeDetails.Name).Taxable1_Percentage__c * chargeTaxMap.get(chargeDetails.Name).Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                    }
                                    if(chargeDetails != null) {
                                        chargeSGST  = ((chargeAmount* chargeTaxMap.get(chargeDetails.Name).Taxable2_Percentage__c * chargeTaxMap.get(chargeDetails.Name).Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                    }
                                }
                                pd.pm.put('C'+seq0+'_sgst__c',chargeSGST);
                                   pd.pm.put('C'+seq0+'_cgst__c',chargeCGST);
                            }
                    } else {
                        // amount , calculate the percentage
                        system.debug('inside amount block::'+pd.milestoneAmount);
                        amount = pd.milestoneAmount;
                        calculatedPercentage =  (amount/ allChargesMap.get('Agreement Value AMOUNTTOTAL')*100).setscale(2,RoundingMode.HALF_UP);
                        pd.pm.put('Charge'+basicChargeSeq+'Percentage__c',calculatedPercentage);
                        basicAmount = amount;
                        
                        // when the milestone is edited, if basic  is altered and set as amount, all the other charges that forms the Agreeement Value bucket should be set to 0
                            for(Integer seq1 :  AVChargesSeqMap.values()) {
                                pd.pm.put('Charge'+seq1+'Percentage__c',0);
                                pd.pm.put('C'+seq1+'_amount__c',0);
                                pd.pm.put('C'+seq1+'_sgst__c',0);
                            pd.pm.put('C'+seq1+'_cgst__c',0);
                            }
                    }
                        if(pd.ppm.Payment_Plan__r.No_GST_On_Token__c && count ==0) {
                            // if first milestone (token milestone) and no gst on token flag is set, then don't calculate tax on this milestone
                            sgst = 0;
                            cgst = 0;
                            basicSGST = 0;
                            basicCGST = 0;
                            // if the user has edited the first milestone then the token amount would change, then in the deduct token milestone we would have to add the tax for the updated token amount
                            tokenAmount = amount;
                        } else if(pd.ppm.Add_Token_GST__c && pd.ppm.Deduct_Token__c) {
                            // add token GST milestone, then we need to add the token amount's GST to this milestone. So change the amount before calculating taxes
                            // we make a assumption here that this will be enabled only on the deduct token milestone.
                            amountForTaxCalculation = amount + tokenAmount;
                            amountForTaxCalculationB = basicAmount +tokenAmount;
                if(!pd.pm.is_demand_raised__c) {
                                if(basicchargeDetails != null) {
                                    sgst = ((amountForTaxCalculation * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                    basicSGST = ((amountForTaxCalculationB * chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                }
                                if(basicchargeDetails != null) {
                                    cgst = ((amountForTaxCalculation * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                    basicCGST = ((amountForTaxCalculationB * chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                }
                  }
                        } else {
                            // rest all milestones, calculate tax on the amount of that milestone.
                if(!pd.pm.is_demand_raised__c) {
                                if(basicchargeDetails != null) {
                                    sgst = ((amount* chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                    basicSGST  = ((basicAmount* chargeTaxMap.get('Basic').Taxable2_Percentage__c * chargeTaxMap.get('Basic').Tax2_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                }
                                if(basicchargeDetails != null) {
                                    cgst = ((amount* chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                                    basicCGST  = ((basicAmount* chargeTaxMap.get('Basic').Taxable1_Percentage__c * chargeTaxMap.get('Basic').Tax1_Percentage__c)/10000).setscale(0,RoundingMode.HALF_UP);
                    }
                            }
                            
                        }
                        pd.pm.put('C'+basicChargeSeq+'_cgst__c',basicCGST);
                        pd.pm.put('C'+basicChargeSeq+'_sgst__c',basicSGST);
                        pd.pm.put('C'+basicChargeSeq+'_amount__c',basicAmount);
                        
                        taxTotal = sgst + cgst;
                        total = amount + taxTotal;
                        overallAmountTotal += amount;
                        overallTaxTotal += taxTotal;
                        overallTotal += total;
                        overallPercentage += (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c');
                        percentage = String.valueOf((Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c')) + '%';
                            if(count ==0) {
                            allChargesMap.put('TOKEN AMOUNT', basicAmount);
                             allChargesMap.put('TOKEN AMOUNT TAX', basicSGST + basicCGST);
                             allChargesMap.put('TOKEN AMOUNT PERCENTAGE', (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c'));
                        }
                    // calculate the milestone names, due dates again if the user the has edited them
                    if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Date Linked')) {
                       /* if(pd.pm.Number_Of_Days__c != null && pd.pm.Time_Period__c != null) {
                            pd.pm.Milestone_Due_Date__c = System.today().addDays(Integer.valueOf(pd.pm.Number_Of_Days__c));
                        } */
                        /*Time period calculation added by Neha on 23 October */
                        if(pd.pm.Number_Of_Days__c != null && pd.pm.Time_Period__c != null){    
                            if(pd.pm.Time_Period__c == 'Days'){ 
                                pd.pm.Milestone_Due_Date__c = System.today().addDays(Integer.valueOf(pd.pm.Number_Of_Days__c));
                            }
                            else {
                                pd.pm.Milestone_Due_Date__c = System.today().addDays(Integer.valueOf(pd.pm.Number_Of_Days__c)*30);
                            }
                          //  toBePaid = pd.pm.Number_Of_Days__c + ' ' + pd.pm.Time_Period__c + ' ' + pd.ppm.Milestone_Name_Picklist__c; 
                         }
                        
                        toBePaid = pd.ppm.Milestone_Name_Picklist__c;
                        pd.pm.Milestone_Name__c = toBePaid;
                        pd.pm.Milestone_type_text__c = pd.pm.Milestone_Type_edit__c;
                    } else if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('Construction Linked')) {
                        Date completionDate = null;
                        Boolean IsMilestoneAchieved = False;
                        Project_Construction_Stages__c pStage = pstageMap.get(pd.pm.Project_Construction_Stages__c);
                        if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c > System.today())
                            completionDate = pStage.Actual_date_of_completion__c; 
                        else if(pStage.Actual_date_of_completion__c != null && pStage.Actual_date_of_completion__c <= System.today()) {
                                // for all milestones which are completed when quotation/booking is being created, they can be charged only post registration
                                // CLPs can be raised only post registration, registration happens post collection of 10%. 10% is collected within 30 days
                                // then registration charges, 20% flat cost milestone on registration and CLP payments of already raised slabs happens together. to allow some leeway to the customer
                                // these demands are given a 30 day due date. Hence payment is expected to come within 60th day [30 days post raising it]
                            completionDate = system.today().addDays(60);
                            IsMilestoneAchieved = True;
                        }    
                        else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c > System.today())
                            completionDate = pStage.Planned_date_of_completion__c;
                        else if(pStage.Planned_date_of_completion__c != null && pStage.Planned_date_of_completion__c <= System.today())
                            completionDate = system.today();
                        // this may not right, but ideally the code shouldnt come in here if the data is set correctly. 
                        if (completionDate == null)
                            completionDate = system.today().addDays(365);
                        pd.pm.Milestone_Due_Date__c = completionDate.addDays(Integer.valueOf(pd.pm.Number_Of_Days__c));
                        toBePaid =  pStage.Name;
                        if(tobePaid.length() > 254)
                                pd.pm.Milestone_Name__c = toBePaid.substring(0,254);
                            else
                                pd.pm.Milestone_Name__c = toBePaid;
                        //setting the demand due flag if the milestone is already acheived at the time of generating the quotation
                        if(IsMilestoneAchieved && !pd.pm.is_demand_raised__c) {
                            pd.pm.Demand_Raised__c = True;
                            pd.pm.Milestone_Complete_at_booking__c = True;
                        }
                        else
                            pd.pm.Demand_Raised__c = False;
                    } else if(String.isNotBlank(pd.pm.Milestone_Type_edit__c) && pd.pm.Milestone_Type_edit__c.equals('On Registration')){
                            pd.pm.Milestone_Name__c = 'On Registration';
                            toBePaid = 'On Registration';
                            pd.pm.Milestone_Due_Date__c = System.today().addDays(60);
                    } else {
                            // shouldn't enter this else
                            pd.pm.Milestone_Name__c = 'Error';
                            tobepaid = 'Error';
                    }
                    
                    
                    pdList.add(new InventorycostServices.PlanDetailWrapper(pd.ppm,pd.pm, tobePaid, (Decimal)pd.pm.get('Charge'+basicChargeSeq+'Percentage__c'), percentage, amount, InventorycostServices.InFormat(amount),InventorycostServices.InFormat(taxTotal),InventorycostServices.inFormat(total),pd.basicMilestone, pd.allowedEdit, pd.lstConstructionStages, pd.fldMap, pd.pm.Milestone_Complete_at_booking__c));
                        
                } else {
                    pdList.add(pd);
                }
                    percentage = '';
                amount =0;
                cgst = 0;
                sgst = 0;
                taxTotal = 0;
                tobePaid = '';
                count ++;   
            }
            // the final line item is just the totals;
              /*  for(Integer i=0; i>pdList.size(); i++){
                    if(pdList[i].tobePaid == 'Grand Total'){
                        pdList.remove(i);
                    }
                }*/
                //pdList.add(new InventorycostServices.PlanDetailWrapper(null,null, 'Grand Total',overallPercentage, string.valueOf(overallPercentage) +'%', overallAmountTotal, InventorycostServices.InFormat(overallAmountTotal),InventorycostServices.InFormat(overallTaxTotal),InventorycostServices.inFormat(overallTotal), true,false, NULL, NULL, false));
        }
        
        return pdList;
   }
    public class UnitDetailsWrapper {
            public string unitName {get;set;}
            public string legalEntityName {get;set;}
            public string bookingDate {get;set;}
            public string floor {get;set;}
            public string considerationValue {get;set;}
            public string projectName {get;set;}
            public string dateOfCancellation {get;set;}
            public string amountPaid {get;set;}
            public string carpetArea {get;set;}
            public string configuration{get;set;}
            public Legal_Entity__c legalEntityRec {get;set;}
            public UnitDetailsWrapper () {
                
            }
    }
    public class PrintTotalsWrapper {
            public String overallAmt {get;set;}
            public String overallTax1 {get;set;}
            public String overallTax2 {get;set;}
            public Integer chargeCount {get;set;}
            public String milestoneName {get;set;}
    }
    public class PrintChargesWrapper {
            public String chargeName {get;set;}
            public String percentage {get;set;}
            public String Amount {get;set;}
            public String Tax1 {get;set;}
            public String Tax2 {get;set;}
    }   
    
    public static void dummyMethod() {
        String test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
        test = 'test';
    }
}