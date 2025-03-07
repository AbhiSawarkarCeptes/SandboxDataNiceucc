public without sharing class LatePaymentManager {
    public LatePaymentManager() {

    }

    @AuraEnabled(cacheable=false)
    public static List<Demand__c> getDemandList(String bookingId){
        return [ SELECT Id,Name,Date_for_Late_Payment_Calculation__c,Booking__r.Total_On_Account_Money_With_Registration__c,Milestone_Name__c,Due_Date__c,Total_Amount_Demanded__c,Total_Amount_with_Tax_Demanded__c,
                Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__r.Other_Applicants_Name__c,LP_Raised_For__c,Installment__c,Payment_Milestones__r.Charge1Percentage__c,Booking__r.Booking_Date__c,
                Last_LP_Raised_Date__c,Previous_LP_Amount__c,LP_Calculation__c,Previous_LP_Name__c,Booking__r.Tower__c,Booking__r.Unit__r.Name,Booking__r.PCC_Approved_By_Audit__c,Booking__r.Current_Status__c,
                Booking__r.X15days_Demand_Raised__c,Booking__r.Unit__r.Tower__r.LPC_Automation_Exception__c,Booking__r.Unit__r.Tower__r.ByPass_LP_Calculation__c,Booking__r.Unit__r.Tower__r.UnRegister_Project__c,
                Booking__r.VAT_On_Interest_Amount__c,Number_of_Late_Payment_Raised__c,booking__r.Project__c,Booking__r.Unit__c,
                Demand_Age__c,OutStanding_days_calculated__c,No_of_days__c,No_of_Months__c,Interest_Charges__c,Balance_Amount__c FROM Demand__c WHERE Booking__c =: bookingId AND Payment_Milestones__c != null AND OutStanding_days_calculated__c != 'Paid'
                AND Booking__c != null  AND Date_for_Late_Payment_Calculation__c != null AND Date_for_Late_Payment_Calculation__c <: System.today() ORDER BY Date_for_Late_Payment_Calculation__c ASC ];
    }

    @AuraEnabled(cacheable=false)
    public static String generateLP(List<Demand__c> demandList, Boolean isDML){
        try{
            
            Map<Demand__c, String> demandWithBooking = new Map<Demand__c, String>();
            Map<String, String> mortgageWithBooking = new Map<String, String>();
            Map<Id, Decimal> totalUnitAmountOnBooking = new Map<Id, Decimal>();
            Map<Id, Decimal> totalLPAmountOnBooking = new Map<Id, Decimal>();
            Map<Id, Decimal> totalDemandedAmountOnBooking = new Map<Id, Decimal>();
            Map<Id, Decimal> totalLPChargeOnBooking = new Map<Id, Decimal>();
            Map<Id, List<Demand__c>> bookingWiseDemand = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand1 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand2 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand3 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand4 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand5 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand6 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand7 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand8 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand9 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand10 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand11 = new Map<Id, List<Demand__c>>();
            Map<Id, List<Demand__c>> bookingWiseDemand12 = new Map<Id, List<Demand__c>>();

            String calculationToShow = '';

            List<Demand__c> demandListForLP =  new List<Demand__c>();
            List<Demand__c> Previouse_demandList =  new List<Demand__c>();
            List<Demand__c> demandWithPaid_Mark =  new List<Demand__c>();
            System.debug('Demand List ->'+demandListForLP);

            for (Demand__c demand : demandList) {
                System.debug('demand ->'+demand);
                demandWithBooking.put(demand,demand.Booking__c);
            }

            for (Mortgage__c mortgage : [ SELECT Id,Name,Booking__c FROM Mortgage__c WHERE Booking__c != null AND Status__c != null AND  (Status__c = 'Approved by Collection Head' OR Status__c = 'Pending for Accounts Approval' 
                                    OR Status__c != 'Rejected by Accounts'  OR Status__c = 'Pending for Audit Approval' OR Status__c = 'Resubmitted to Accounts' OR Status__c = 'Resubmitted to Audit'  
                                    OR Status__c = 'Rejected by Audit'  OR Status__c = 'Approved by Audit') AND Booking__c IN: demandWithBooking.values()]) {
                System.debug('mortgage ->'+mortgage.Name+' Booking '+mortgage.Booking__c);
                mortgageWithBooking.put(mortgage.Booking__c,mortgage.Id);
                
            }

            for (Demand__c demand : demandWithBooking.keySet()) {
                System.debug(' for demand ->'+demand.Booking__c);
                if(mortgageWithBooking != null && mortgageWithBooking.size() > 0){
                    for (String bookingId : mortgageWithBooking.keySet()) {
                        if(demand.Booking__c != bookingId){
                            System.debug(' if demand ->'+demand.Booking__c);
                            demandListForLP.add(demand);
                            
                        }else{
                            System.debug(' else demand ->'+demand.Booking__c);
                            demandWithBooking.remove(demand);
                        }
                    }
                }else{
                    demandListForLP.add(demand);
                }
            }

            for (Receipt__c receipt : [ SELECT Id,Name,Other_Charges_Type__c,Amount_Rs__c,Mode__c,Description__c,Receipt_Date__c,Demand__c,Total_Amount__c,LP_Waiver__c,LP_Waiver__r.Demand__c,Booking__c,
                                    Registration_Collection_Control_Report__c,CreatedDate,Towards_Other_Charges_Amount__c,RemarksText__c,Credit_Card_Charges__c,LP_Waiver__r.Demand__r.Milestone_Name__c    
                                    FROM Receipt__c  WHERE Receipt_Status__c = 'Cleared' AND Is_Reversed_Receipt__c = false AND Booking__c IN: demandWithBooking.values() ]) {
                
                System.debug('Sreceipt 1 '+receipt.Name+' - Amount - '+receipt.Amount_Rs__c);
                String rd = receipt.Description__c != null ? receipt.Description__c.toLowercase() : '';
                if((receipt.Credit_Card_Charges__c == 0 ||  receipt.Credit_Card_Charges__c == null) && receipt.Other_Charges_Type__c == null && !(rd.contains('late payment') || rd.contains('late payment waiver') || rd.contains('lp waiver') || rd.contains('lpw') || rd.contains('interest waiver')) && (receipt.LP_Waiver__c == null) ){
                    if(totalUnitAmountOnBooking.containsKey(receipt.Booking__c)){
                        if(receipt.Registration_Collection_Control_Report__c > 0){
                            totalUnitAmountOnBooking.put(receipt.Booking__c,(totalUnitAmountOnBooking.get(receipt.Booking__c) + (receipt.Amount_Rs__c - receipt.Registration_Collection_Control_Report__c)));
                        }else{
                            totalUnitAmountOnBooking.put(receipt.Booking__c,(totalUnitAmountOnBooking.get(receipt.Booking__c) + receipt.Amount_Rs__c));
                        }
                    }else{
                        if(receipt.Registration_Collection_Control_Report__c > 0){
                            totalUnitAmountOnBooking.put(receipt.Booking__c,(receipt.Amount_Rs__c - receipt.Registration_Collection_Control_Report__c));
                        }else{
                            totalUnitAmountOnBooking.put(receipt.Booking__c,receipt.Amount_Rs__c);
                        }
                        
                    }
                }
                if(receipt.Other_Charges_Type__c == 'Late Payment Charges' || rd.contains('late payment') || rd.contains('late payment waiver') || rd.contains('lp waiver') || rd.contains('lpw') || rd.contains('interest waiver') || (receipt.LP_Waiver__c != null && receipt.LP_Waiver__r.Demand__c != null && receipt.LP_Waiver__r.Demand__r.Milestone_Name__c.containsIgnoreCase('late payment'))){
                    if(totalLPAmountOnBooking.containsKey(receipt.Booking__c)){
                        totalLPAmountOnBooking.put(receipt.Booking__c,(totalLPAmountOnBooking.get(receipt.Booking__c) + (receipt.Amount_Rs__c != null ? receipt.Amount_Rs__c : 0)));
                    }else{
                        totalLPAmountOnBooking.put(receipt.Booking__c,receipt.Amount_Rs__c != null ? receipt.Amount_Rs__c : 0);
                    }
                }
            }
            
            System.debug(' totalLPAmountOnBooking ->'+totalLPAmountOnBooking.size());
            System.debug(' totalUnitAmountOnBooking ->'+totalUnitAmountOnBooking.size());
            System.debug(' demandListForLP ->'+demandListForLP.size());

            for (Demand__c demand : [ SELECT Id,Name,Booking__r.Total_On_Account_Money_With_Registration__c,GL_Date__c,Milestone_Name__c,Due_Date__c,Total_Amount_Demanded__c,Total_Amount_with_Tax_Demanded__c,
                                    Installment__c,Payment_Milestones__r.Charge1Percentage__c,Booking__r.Booking_Date__c,Date_for_Late_Payment_Calculation__c,Last_LP_Raised_Date__c,
                                    Booking__r.VAT_On_Interest_Amount__c,Number_of_Late_Payment_Raised__c,Previous_LP_Amount__c,Previous_LP_Name__c,
                                    Demand_Age__c,OutStanding_days_calculated__c,No_of_days__c,No_of_Months__c,Interest_Charges__c,Balance_Amount__c  FROM Demand__c WHERE Payment_Milestones__c != null
                                    AND Demand_Status__c !='Reversed' AND Booking__c IN: demandWithBooking.values() AND Date_for_Late_Payment_Calculation__c <: System.today()
                                    ORDER BY Date_for_Late_Payment_Calculation__c DESC ]) {
                System.debug('demand --> '+demand.Booking__c+ ' --- '+demand.Name);                                        
                if(bookingWiseDemand.containsKey(demand.Booking__c)){
                    bookingWiseDemand.get(demand.Booking__c).add(demand);
                }else{
                    bookingWiseDemand.put(demand.Booking__c, new List<Demand__c>{demand});
                }

                if(totalDemandedAmountOnBooking.containsKey(demand.Booking__c)){
                    totalDemandedAmountOnBooking.put(demand.Booking__c,(totalDemandedAmountOnBooking.get(demand.Booking__c) + demand.Total_Amount_with_Tax_Demanded__c));
                }else{
                    totalDemandedAmountOnBooking.put(demand.Booking__c,demand.Total_Amount_with_Tax_Demanded__c);
                }

            }
            System.debug(' totalDemandedAmountOnBooking ->'+totalDemandedAmountOnBooking.size());

            Map<Id, List<Demand__c>> LP_DemandList = new Map<Id, List<Demand__c>>();

            for (Demand__c demand : [ SELECT Id,Name,Booking__r.Total_On_Account_Money_With_Registration__c,GL_Date__c,Milestone_Name__c,Due_Date__c,Total_Amount_Demanded__c,Total_Amount_with_Tax_Demanded__c,
                            Installment__c,Payment_Milestones__r.Charge1Percentage__c,Booking__r.Booking_Date__c,Date_for_Late_Payment_Calculation__c,Last_LP_Raised_Date__c,
                            Booking__r.VAT_On_Interest_Amount__c,Number_of_Late_Payment_Raised__c,Previous_LP_Amount__c,Previous_LP_Name__c,
                            Demand_Age__c,OutStanding_days_calculated__c,No_of_days__c,No_of_Months__c,Interest_Charges__c,Balance_Amount__c FROM Demand__c WHERE Milestone_Name__c = 'Late Payment Charges'
                            AND Demand_Status__c !='Reversed' AND Booking__c IN: demandWithBooking.values() AND GL_Date__c <: System.today() 
                            ORDER BY GL_Date__c DESC ]){

                if(LP_DemandList.containsKey(demand.Booking__c)){
                    LP_DemandList.get(demand.Booking__c).add(demand);
                }else{
                    List<Demand__c> dLi = new List<Demand__c>();
                    dLi.add(demand);
                    LP_DemandList.put(demand.Booking__c, dLi);
                }
                if(totalLPChargeOnBooking.containsKey(demand.Booking__c)){
                    totalLPChargeOnBooking.put(demand.Booking__c,(totalLPChargeOnBooking.get(demand.Booking__c) + demand.Total_Amount_with_Tax_Demanded__c));
                }else{
                    totalLPChargeOnBooking.put(demand.Booking__c,demand.Total_Amount_with_Tax_Demanded__c);
                }

            }
            System.debug(' totalLPChargeOnBooking = '+totalLPChargeOnBooking);
            Date sept13 = Date.newInstance(2022, 9, 13);
            Account_Master__c interestMaster = [SELECT Id, Name FROM Account_Master__c WHERE Name = 'Interest Charges' LIMIT 1];
            Account_Master__c tradeMaster = [SELECT Id, Name FROM Account_Master__c WHERE Name = 'Trade Receivable' LIMIT 1];
            List<Booking__c> bookingToUpdateLPandOutStandingDays = new List<Booking__c>();

            List<Demand__c> LPDemandListToInsert = new List<Demand__c>();
            for (Demand__c demand : demandListForLP) {
                if((demand.Number_of_Late_Payment_Raised__c == 0 || demand.Number_of_Late_Payment_Raised__c == null)){
                    System.debug(' demand = '+demand);
                    demand.Number_of_Late_Payment_Raised__c = 0;
                    System.debug(' totalDemandedAmountOnBooking.get(demand.booking__c) = '+totalDemandedAmountOnBooking.get(demand.booking__c)+' totalUnitAmountOnBooking.get(demand.booking__c) '+totalUnitAmountOnBooking.get(demand.booking__c));
                    if(totalDemandedAmountOnBooking.get(demand.booking__c) != null && totalUnitAmountOnBooking.get(demand.booking__c) != null){
                        Decimal overdueAmount = totalDemandedAmountOnBooking.get(demand.booking__c) - totalUnitAmountOnBooking.get(demand.booking__c);
                        Decimal totalOnAccountMoney = totalUnitAmountOnBooking.get(demand.booking__c);
                        
                        System.debug(' overdueAmount = '+overdueAmount);
                        if(overdueAmount > 10000){
                            Decimal percentageValue;
                            if(demand.booking__r.Booking_Date__c <= sept13){
                                percentageValue = 1.01;
                            }
                            else{
                                percentageValue = 1.02;
                            }
                            Decimal days = 0;
                            Decimal noOfMonths = 0;
                            Decimal chargeOnBalance = 0;
                            Decimal currentChargeOnBalance = 0;
                            Decimal currentChargeOnBalanceVAT = 0;
                            Decimal chargeOnBalanceVAT = 0;
                            Decimal LP_ApplyAmpount = 0;
                            LP_ApplyAmpount = overdueAmount;
                            Integer numberofDemandinList = 0;
                            List<Demand__c> lpDemandList = new List<Demand__c>();
                            lpDemandList = LP_DemandList.get(demand.Booking__c);
                            if(overdueAmount > demand.Total_Amount_with_Tax_Demanded__c){

                                days = demand.Date_for_Late_Payment_Calculation__c.daysBetween(Date.today());
                                System.debug(' days = '+days);
                                noOfMonths = (days/30.0).setscale(5,RoundingMode.FLOOR);
                                System.debug(' noOfMonths = '+noOfMonths);
                                chargeOnBalance = ((Math.exp(noOfMonths * Math.log(percentageValue)) * demand.Total_Amount_with_Tax_Demanded__c).round(System.RoundingMode.HALF_EVEN)) - demand.Total_Amount_with_Tax_Demanded__c;
                                chargeOnBalanceVAT = chargeOnBalance * 0.05;
                                currentChargeOnBalance = chargeOnBalance;
                                currentChargeOnBalanceVAT = chargeOnBalance * 0.05;
                                LP_ApplyAmpount = demand.Total_Amount_with_Tax_Demanded__c;
                                demand.Number_of_Late_Payment_Raised__c += 1;
                                demand.Last_LP_Raised_Date__c = System.today();
                                System.debug(' Number_of_Late_Payment_Raised__c = '+demand.Number_of_Late_Payment_Raised__c);
                                demand.OutStanding_days_calculated__c = String.valueOf(days);
                                System.debug(' OutStanding_days_calculated__c = '+demand.OutStanding_days_calculated__c);

                                Decimal previousDemandsAmount = overdueAmount - demand.Total_Amount_with_Tax_Demanded__c;
                                List<Demand__c> allPreviousDemand = bookingWiseDemand.get(demand.Booking__c);
                                System.debug(' allPreviousDemand -> '+allPreviousDemand.size());
                                
                                Integer indexToRemove = -1;
                                for (Integer i = 0; i < allPreviousDemand.size(); i++) {
                                    if (allPreviousDemand[i].Id == demand.Id) {
                                        indexToRemove = i;
                                        break;
                                    }
                                }
                                if(indexToRemove > -1){
                                    allPreviousDemand.remove(indexToRemove);
                                }
                                System.debug(' allPreviousDemand -> '+allPreviousDemand.size());
                                if(allPreviousDemand.size() > 0 ){
                                    Boolean shouldNotCalculateAllDemand = false;
                                    for (Demand__c pdmnd : allPreviousDemand) {
                                        System.debug(' LP pdmnd = '+pdmnd);
                                        
                                        if(previousDemandsAmount > 10000 && previousDemandsAmount > pdmnd.Total_Amount_with_Tax_Demanded__c && !pdmnd.Milestone_Name__c.contains('balance')){
                                            Decimal PrevioudLPCalculationDate = pdmnd.Date_for_Late_Payment_Calculation__c.daysBetween(Date.today());
                                            Date dateTODisplay = pdmnd.Date_for_Late_Payment_Calculation__c;
                                            if(numberofDemandinList == 0){
                                                if(lpDemandList != null && lpDemandList.size() > 0){
                                                    for (Demand__c preivousLPDemand : lpDemandList) {
                                                        if(preivousLPDemand.GL_Date__c > pdmnd.GL_Date__c && preivousLPDemand.GL_Date__c < demand.Date_for_Late_Payment_Calculation__c){
                                                            PrevioudLPCalculationDate = preivousLPDemand.GL_Date__c.addDays(1).daysBetween(Date.today());
                                                            dateTODisplay = preivousLPDemand.GL_Date__c.addDays(1);
                                                            shouldNotCalculateAllDemand = true;
                                                            break;
                                                        }
                                                    }
                                                }
                                            }
                                            Decimal Previoud_LP_noOfMonths = (PrevioudLPCalculationDate/30.0).setscale(5,RoundingMode.FLOOR);
                                            Decimal Previoud_chargeOnBalance = ((Math.exp(Previoud_LP_noOfMonths * Math.log(percentageValue)) * pdmnd.Total_Amount_with_Tax_Demanded__c).round(System.RoundingMode.HALF_EVEN)) - pdmnd.Total_Amount_with_Tax_Demanded__c;
                                            
                                            Decimal Previoud_LP_Vat = Previoud_chargeOnBalance * 0.05;
                                            chargeOnBalanceVAT += Previoud_LP_Vat;
                                            chargeOnBalance = chargeOnBalance + (Previoud_chargeOnBalance + Previoud_LP_Vat);

                                            pdmnd.OutStanding_days_calculated__c = String.valueOf(PrevioudLPCalculationDate);
                                            
                                            System.debug(' LP new demand chargeOnBalance = '+chargeOnBalance+ ' OutStanding_days_calculated__c = '+pdmnd.OutStanding_days_calculated__c+' Previoud_LP_noOfMonths = '+Previoud_LP_noOfMonths+' Previoud_LP_noOfMonths = '+Previoud_LP_noOfMonths);
                                            pdmnd.Previous_LP_Name__c = pdmnd.Name+' - OutStanding Days : '+PrevioudLPCalculationDate+' no of Month : '+Previoud_LP_noOfMonths+' Charge On Balance '+Previoud_chargeOnBalance+' VAT '+Previoud_LP_Vat;
                                            pdmnd.Previous_LP_Amount__c = Previoud_chargeOnBalance;
                                            calculationToShow += ' (Previous Demand : '+pdmnd.Name+') (Date From LP Calculated : '+dateTODisplay+') (Previous Demand OutStanding Days : '+PrevioudLPCalculationDate+') ';
                                            calculationToShow += '(Previous Demand No Of Month : '+Previoud_LP_noOfMonths+') (Previous Amount For LP Calculation : '+INFormat(pdmnd.Total_Amount_with_Tax_Demanded__c)+') (Previous LP Charge + VAT : '+INFormat(Previoud_chargeOnBalance+Previoud_LP_Vat)+') ';
                                            // (Previous LP Vat : '+INFormat(Previoud_LP_Vat)+')
                                            Previouse_demandList.add(pdmnd);
                                            previousDemandsAmount = previousDemandsAmount - pdmnd.Total_Amount_with_Tax_Demanded__c;
                                            if(shouldNotCalculateAllDemand == true){
                                                break;
                                            }
                                        }else if(previousDemandsAmount > 10000 && !pdmnd.Milestone_Name__c.contains('balance')){
                                            Decimal PrevioudLPCalculationDate = pdmnd.Date_for_Late_Payment_Calculation__c.daysBetween(Date.today());
                                            Date dateTODisplay = pdmnd.Date_for_Late_Payment_Calculation__c;
                                            if(numberofDemandinList == 0){
                                                if(lpDemandList != null && lpDemandList.size() > 0){
                                                    for (Demand__c preivousLPDemand : lpDemandList) {
                                                        if(preivousLPDemand.GL_Date__c > pdmnd.GL_Date__c && preivousLPDemand.GL_Date__c < demand.Date_for_Late_Payment_Calculation__c){
                                                            PrevioudLPCalculationDate = preivousLPDemand.GL_Date__c.addDays(1).daysBetween(Date.today());
                                                            dateTODisplay = preivousLPDemand.GL_Date__c.addDays(1);
                                                            shouldNotCalculateAllDemand = true;
                                                            break;
                                                        }
                                                    }
                                                }
                                            }
                                            Decimal Previoud_LP_noOfMonths = (PrevioudLPCalculationDate/30.0).setscale(5,RoundingMode.FLOOR);
                                            Decimal Previoud_chargeOnBalance = ((Math.exp(Previoud_LP_noOfMonths * Math.log(percentageValue)) * previousDemandsAmount).round(System.RoundingMode.HALF_EVEN)) - previousDemandsAmount;
                                            
                                            Decimal Previoud_LP_Vat = Previoud_chargeOnBalance * 0.05;
                                            chargeOnBalanceVAT += Previoud_LP_Vat;
                                            chargeOnBalance = chargeOnBalance + (Previoud_chargeOnBalance + Previoud_LP_Vat);
                                            pdmnd.OutStanding_days_calculated__c = String.valueOf(PrevioudLPCalculationDate);
                                            
                                            System.debug(' LP new demand chargeOnBalance = '+chargeOnBalance+ ' OutStanding_days_calculated__c = '+pdmnd.OutStanding_days_calculated__c+' Previoud_LP_noOfMonths = '+Previoud_LP_noOfMonths+' Previoud_LP_noOfMonths = '+Previoud_LP_noOfMonths);
                                            pdmnd.Previous_LP_Name__c = pdmnd.Name+' - OutStanding Days : '+PrevioudLPCalculationDate+' no of Month : '+Previoud_LP_noOfMonths+' Charge On Balance '+Previoud_chargeOnBalance+' VAT '+Previoud_LP_Vat;
                                            pdmnd.Previous_LP_Amount__c = Previoud_chargeOnBalance;
                                            
                                            calculationToShow += ' (Previous Demand : '+pdmnd.Name+') (Date From LP Calculated : '+dateTODisplay+') (Previous Demand OutStanding Days : '+PrevioudLPCalculationDate+') ';
                                            calculationToShow += '(Previous Demand No Of Month : '+Previoud_LP_noOfMonths+') (Previous Amount For LP Calculation : '+INFormat(previousDemandsAmount)+') (Previous LP Charge + VAT : '+INFormat(Previoud_chargeOnBalance+Previoud_LP_Vat)+') ';
                                            
                                            Previouse_demandList.add(pdmnd);

                                            previousDemandsAmount = previousDemandsAmount - pdmnd.Total_Amount_with_Tax_Demanded__c;
                                            if(shouldNotCalculateAllDemand == true){
                                                break;
                                            }
                                        }else{
                                            pdmnd.OutStanding_days_calculated__c = 'Paid';
                                            Previouse_demandList.add(pdmnd);
                                            previousDemandsAmount = previousDemandsAmount - pdmnd.Total_Amount_with_Tax_Demanded__c;
                                        }
                                        numberofDemandinList++;
                                    }
                                }
                                System.debug(' overdueAmount = '+overdueAmount+ ' Total_Amount_with_Tax_Demanded__c = '+demand.Total_Amount_with_Tax_Demanded__c);

                                calculationToShow += ' (Current Demand : '+demand.Name+') (Date From LP Calculated : '+demand.Date_for_Late_Payment_Calculation__c+') (Days : '+days+') ';
                                calculationToShow += ' (Month : '+noOfMonths+')  (Late Payment Calculation Amount : '+INFormat(LP_ApplyAmpount)+') (Current LP Charge + VAT : '+(currentChargeOnBalance + currentChargeOnBalanceVAT)+') ';

                                calculationToShow += ' (Percentage Value : '+percentageValue+') (Total Demanded Amount Till Now : '+INFormat(totalDemandedAmountOnBooking.get(demand.booking__c))+') (Total Unit Amount Paid By Customer : '+INFormat(totalUnitAmountOnBooking.get(demand.booking__c))+') (Total Over Due Amount On Unit : '+INFormat(overdueAmount)+')';
                                calculationToShow += ' (Final LP Charges After Calcultion : '+INFormat(chargeOnBalance + currentChargeOnBalanceVAT)+') (Unit Booking Date : '+demand.booking__r.Booking_Date__c+')';

                                
                            }else{
                                days = demand.Date_for_Late_Payment_Calculation__c.daysBetween(Date.today());
                                
                                System.debug(' days = '+days);
                                noOfMonths = (days/30.0).setscale(5,RoundingMode.FLOOR);
                                System.debug(' noOfMonths = '+noOfMonths);
                                chargeOnBalance = ((Math.exp(noOfMonths * Math.log(percentageValue)) * overdueAmount).round(System.RoundingMode.HALF_EVEN)) - overdueAmount;
                                LP_ApplyAmpount = overdueAmount;
                                currentChargeOnBalance = chargeOnBalance;
                                chargeOnBalanceVAT = chargeOnBalance * 0.05;
                                demand.Number_of_Late_Payment_Raised__c += 1;
                                demand.Last_LP_Raised_Date__c = System.today();
                                System.debug(' Number_of_Late_Payment_Raised__c = '+demand.Number_of_Late_Payment_Raised__c);
                                demand.OutStanding_days_calculated__c = String.valueOf(days);
                                System.debug(' OutStanding_days_calculated__c = '+demand.OutStanding_days_calculated__c);
                                calculationToShow = ' (Current Demand : '+demand.Name+') (Date From LP Calculated : '+demand.Date_for_Late_Payment_Calculation__c+') (Days : '+days+')';
                                calculationToShow += ' (Month : '+noOfMonths+') (Late Payment Calculation Amount : '+INFormat(LP_ApplyAmpount)+')  (Total Demanded Amount Till Now : '+INFormat(totalDemandedAmountOnBooking.get(demand.booking__c))+') (Total Unit Amount Paid By Customer : '+INFormat(totalUnitAmountOnBooking.get(demand.booking__c))+') (Total Over Due Amount On Unit : '+INFormat(overdueAmount)+')';
                                calculationToShow += ' (LP Charges After Calcultion + VAT : '+INFormat(chargeOnBalance + chargeOnBalanceVAT)+') (Percentage Value : '+percentageValue+') (Unit Booking Date : '+demand.booking__r.Booking_Date__c+')';

                            }
                            Booking__c bookng = new Booking__c();
                            bookng = demand.Booking__r;
                            bookng.Total_Interest_Till_Date__c = chargeOnBalance;

                            Demand__C LP_demand = new Demand__C();
                            LP_demand.Booking__c = demand.Booking__c;
                            LP_demand.Debit_Demanded__c = chargeOnBalance;
                            LP_demand.LP_Raised_For__c = demand.Name;
                            LP_demand.Debit_CGST__c = chargeOnBalanceVAT;
                            LP_demand.Payment_Towards__c = 'Corporate Account';
                            LP_demand.GL_Date__c = System.today();
                            LP_demand.LP_Calculation__c = ' Days : '+days+' - Month :'+noOfMonths+' - Total OverDue : '+overdueAmount+' - LPApplyAmount '+LP_ApplyAmpount+' - Total Demanded Amount: '+totalDemandedAmountOnBooking.get(demand.booking__c)+' - Total Unit Amount: '+totalUnitAmountOnBooking.get(demand.booking__c);
                            LP_demand.Invoice_Date__c = System.today();
                            LP_demand.Total_Amount_Account__c = interestMaster.id;
                            LP_demand.Total_Amount_with_Tax_Account__c = tradeMaster.id;
                            LP_demand.Milestone_Name__c = 'Late Payment Charges';
                            LP_demand.Debit_Type__c = 'Interest Charges';
                            LP_demand.Tax_Rate__c = 'VAT 5%';
                            LP_demand.Descriptions__c = 'Late Payment Charges';
                            LP_demand.Payment_Term__c = 'Immediate';
                            LP_demand.Project__c = demand.booking__r.Project__c;
                            LP_demand.Unit__c = demand.booking__r.Unit__c;
                            System.debug(' LP new demand = '+LP_demand);
                            
                            bookingToUpdateLPandOutStandingDays.add(bookng);
                            if(LP_demand.Debit_Demanded__c > 0){
                                LPDemandListToInsert.add(LP_demand);
                            }
                        }else if(overdueAmount <= 0){
                            demand.OutStanding_days_calculated__c = 'Paid';
                            calculationToShow += 'Over Due amount on Booking is = '+INFormat(overdueAmount)+' LP Will not be applied ';
                            System.debug(' overdueAmount = '+overdueAmount+' demand '+ demand.Name +' OutStanding_days_calculated__c '+demand.OutStanding_days_calculated__c);
                        }
                        if(totalOnAccountMoney > 0){
                            System.debug('totalOnAccountMoney -> '+totalOnAccountMoney);
                            System.debug('demand.Booking__c -> '+demand.Booking__c);
                            for (Demand__c b_demnd : bookingWiseDemand.get(demand.Booking__c)) {
                                System.debug('b_demnd -> '+b_demnd);
                                System.debug('b_demnd -> '+b_demnd.Id+' = '+demand.Id);
                                if(b_demnd.Id != demand.Id){
                                    System.debug('b_demnd.Total_Amount_with_Tax_Demanded__c -> '+b_demnd.Total_Amount_with_Tax_Demanded__c);
                                    if(b_demnd.Total_Amount_with_Tax_Demanded__c <= totalOnAccountMoney){
                                        b_demnd.OutStanding_days_calculated__c = 'Paid';
                                        totalOnAccountMoney = totalOnAccountMoney - b_demnd.Total_Amount_with_Tax_Demanded__c;
                                        System.debug('b_demnd.OutStanding_days_calculated__c -> '+b_demnd.OutStanding_days_calculated__c);
                                        demandWithPaid_Mark.add(b_demnd);
                                    }
                                }   
                            }
                        }
                    }
                }else if(demand.Number_of_Late_Payment_Raised__c == 1){
                    if(totalDemandedAmountOnBooking.get(demand.booking__c) != null && totalUnitAmountOnBooking.get(demand.booking__c) != null){
                        Decimal overdueAmount = totalDemandedAmountOnBooking.get(demand.booking__c) - totalUnitAmountOnBooking.get(demand.booking__c);
                        Decimal totalOnAccountMoney = totalUnitAmountOnBooking.get(demand.booking__c);
                        System.debug(' overdueAmount = '+overdueAmount);
                        if(overdueAmount > 10000){
                            Decimal percentageValue;
                            if(demand.booking__r.Booking_Date__c <= sept13){
                                percentageValue = 1.01;
                            }
                            else{
                                percentageValue = 1.02;
                            }
                            Decimal daysForCalculation = 0;
                            Decimal days = 0;
                            Decimal noOfMonths = 0;
                            Decimal chargeOnBalance = 0;
                            Decimal LP_ApplyAmpount = 0;
                            LP_ApplyAmpount = overdueAmount;
                            if(overdueAmount > demand.Total_Amount_with_Tax_Demanded__c){

                                days = demand.Date_for_Late_Payment_Calculation__c.daysBetween(Date.today());
                                System.debug(' days = '+days);
                                System.debug(' noOfMonths = '+noOfMonths);
                                daysForCalculation = demand.Last_LP_Raised_Date__c.daysBetween(Date.today());
                                noOfMonths = (daysForCalculation/30.0).setscale(5,RoundingMode.FLOOR);
                                chargeOnBalance = ((Math.exp(noOfMonths * Math.log(percentageValue)) * demand.Total_Amount_with_Tax_Demanded__c).round(System.RoundingMode.HALF_EVEN)) - demand.Total_Amount_with_Tax_Demanded__c;
                                LP_ApplyAmpount = demand.Total_Amount_with_Tax_Demanded__c;
                                demand.Number_of_Late_Payment_Raised__c += 1;
                                demand.Last_LP_Raised_Date__c = System.today();
                                System.debug(' Number_of_Late_Payment_Raised__c = '+demand.Number_of_Late_Payment_Raised__c);
                                demand.OutStanding_days_calculated__c = String.valueOf(days);
                                System.debug(' OutStanding_days_calculated__c = '+demand.OutStanding_days_calculated__c);

                                Decimal previousDemandsAmount = overdueAmount - demand.Total_Amount_with_Tax_Demanded__c;
                                List<Demand__c> allPreviousDemand = bookingWiseDemand.get(demand.Booking__c);
                                System.debug(' allPreviousDemand -> '+allPreviousDemand.size());

                                calculationToShow = ' (Current Demand : '+demand.Name+') (Date From LP Calculated : '+demand.Date_for_Late_Payment_Calculation__c+') (Days : '+days+') (Month : '+noOfMonths+') (Late Payment Calculation Amount : '+INFormat(LP_ApplyAmpount)+')  (Total Demanded Amount Till Now : '+INFormat(totalDemandedAmountOnBooking.get(demand.booking__c))+') (Total Unit Amount Paid By Customer : '+INFormat(totalUnitAmountOnBooking.get(demand.booking__c))+') (Total Over Due Amount On Unit : '+INFormat(overdueAmount)+')';
                                calculationToShow += ' (LP Charges After Calcultion + VAT : '+INFormat(chargeOnBalance + (chargeOnBalance * 0.05))+') (Percentage Value : '+percentageValue+') (Unit Booking Date : '+demand.booking__r.Booking_Date__c+')';

                                
                                System.debug(' overdueAmount = '+overdueAmount+ ' Total_Amount_with_Tax_Demanded__c = '+demand.Total_Amount_with_Tax_Demanded__c);
                                
                            }else{
                                days = demand.Date_for_Late_Payment_Calculation__c.daysBetween(Date.today());
                                System.debug(' days = '+days);
                                daysForCalculation = demand.Last_LP_Raised_Date__c.daysBetween(Date.today());
                                noOfMonths = (daysForCalculation/30.0).setscale(5,RoundingMode.FLOOR);
                                System.debug(' noOfMonths = '+noOfMonths);
                                chargeOnBalance = ((Math.exp(noOfMonths * Math.log(percentageValue)) * overdueAmount).round(System.RoundingMode.HALF_EVEN)) - overdueAmount;
                                LP_ApplyAmpount = overdueAmount;
                                demand.Number_of_Late_Payment_Raised__c += 1;
                                demand.Last_LP_Raised_Date__c = System.today();
                                System.debug(' Number_of_Late_Payment_Raised__c = '+demand.Number_of_Late_Payment_Raised__c);
                                demand.OutStanding_days_calculated__c = String.valueOf(days);
                                System.debug(' OutStanding_days_calculated__c = '+demand.OutStanding_days_calculated__c);

                                calculationToShow = ' (Current Demand : '+demand.Name+') (Date From LP Calculated : '+demand.Date_for_Late_Payment_Calculation__c+') (Days : '+days+') (Month : '+noOfMonths+') (Late Payment Calculation Amount : '+INFormat(LP_ApplyAmpount)+')  (Total Demanded Amount Till Now : '+INFormat(totalDemandedAmountOnBooking.get(demand.booking__c))+') (Total Unit Amount Paid By Customer : '+INFormat(totalUnitAmountOnBooking.get(demand.booking__c))+') (Total Over Due Amount On Unit : '+INFormat(overdueAmount)+')';
                                calculationToShow += ' (LP Charges After Calcultion + VAT: '+INFormat(chargeOnBalance + (chargeOnBalance * 0.05))+') (Percentage Value : '+percentageValue+') (Unit Booking Date : '+demand.booking__r.Booking_Date__c+')';


                            }

                            Booking__c bookng = new Booking__c();
                            bookng = demand.Booking__r;
                            bookng.Total_Interest_Till_Date__c = chargeOnBalance;

                            Demand__C LP_demand = new Demand__C();
                            LP_demand.Booking__c = demand.Booking__c;
                            LP_demand.Debit_Demanded__c = chargeOnBalance;
                            LP_demand.LP_Raised_For__c = demand.Name;
                            LP_demand.Debit_CGST__c = chargeOnBalance * 0.05 ;
                            LP_demand.Payment_Towards__c = 'Corporate Account';
                            LP_demand.LP_Calculation__c = ' Days : '+days+' - DaysForCalculation '+daysForCalculation+' - Month :'+noOfMonths+' - Total OverDue : '+overdueAmount+' - LPApplyAmount '+LP_ApplyAmpount+' - Total Demanded Amount: '+totalDemandedAmountOnBooking.get(demand.booking__c)+' - Total Unit Amount: '+totalUnitAmountOnBooking.get(demand.booking__c);
                            LP_demand.GL_Date__c = System.today();
                            LP_demand.Invoice_Date__c = System.today();
                            LP_demand.Total_Amount_Account__c = interestMaster.id;
                            LP_demand.Total_Amount_with_Tax_Account__c = tradeMaster.id;
                            LP_demand.Milestone_Name__c = 'Late Payment Charges';
                            LP_demand.Debit_Type__c = 'Interest Charges';
                            LP_demand.Descriptions__c = 'Late Payment Charges';
                            LP_demand.Tax_Rate__c = 'VAT 5%';
                            LP_demand.Payment_Term__c = 'Immediate';
                            LP_demand.Project__c = demand.booking__r.Project__c;
                            LP_demand.Unit__c = demand.booking__r.Unit__c;
                            System.debug(' LP new demand = '+LP_demand);
                            bookingToUpdateLPandOutStandingDays.add(bookng);
                            if(LP_demand.Debit_Demanded__c > 0){
                                LPDemandListToInsert.add(LP_demand);
                            }
                        }else if(overdueAmount <= 0){
                            demand.OutStanding_days_calculated__c = 'Paid';
                            System.debug(' overdueAmount = '+overdueAmount+' demand '+ demand.Name +' OutStanding_days_calculated__c '+demand.OutStanding_days_calculated__c);
                        }
                        if(totalOnAccountMoney > 0){
                            System.debug('totalOnAccountMoney -> '+totalOnAccountMoney);
                            System.debug('demand.Booking__c -> '+demand.Booking__c);
                            for (Demand__c b_demnd : bookingWiseDemand.get(demand.Booking__c)) {
                                System.debug('b_demnd -> '+b_demnd);
                                System.debug('b_demnd -> '+b_demnd.Id+' = '+demand.Id);
                                if(b_demnd.Id != demand.Id){
                                    System.debug('b_demnd.Total_Amount_with_Tax_Demanded__c -> '+b_demnd.Total_Amount_with_Tax_Demanded__c);
                                    if(b_demnd.Total_Amount_with_Tax_Demanded__c <= totalOnAccountMoney){
                                        b_demnd.OutStanding_days_calculated__c = 'Paid';
                                        totalOnAccountMoney = totalOnAccountMoney - b_demnd.Total_Amount_with_Tax_Demanded__c;
                                        System.debug('b_demnd.OutStanding_days_calculated__c -> '+b_demnd.OutStanding_days_calculated__c);
                                        demandWithPaid_Mark.add(b_demnd);
                                    }
                                }   
                            }
                        }
                    }
                }
            }
            String returnVariable = 'Dont Email';
            if(isDML){
                System.debug(' LPDemandListToInsert = '+LPDemandListToInsert);
                if(LPDemandListToInsert.size() > 0){
                    insert LPDemandListToInsert; 
                    returnVariable = 'Send Email;'+LPDemandListToInsert[0].Id;
                }
                if(bookingToUpdateLPandOutStandingDays.size() > 0){
                    update bookingToUpdateLPandOutStandingDays;
                }
                List<Demand__c> demandsToUpdate = new List<Demand__c>();
                for (List<Demand__c> dmndList : LP_DemandList.values()) {
                    demandsToUpdate.addAll(dmndList);
                }
                if(Previouse_demandList.size() > 0){
                    demandsToUpdate.addAll(Previouse_demandList);
                }
                System.debug('b_demnd.demandWithPaid_Mark -> '+demandWithPaid_Mark);
                if(demandWithPaid_Mark.size() > 0){
                    demandsToUpdate.addAll(demandWithPaid_Mark);
                }
                if(demandsToUpdate.size() > 0){
                    System.debug(' demandsToUpdate = '+demandsToUpdate);
                    map<id,Demand__c> demandListMAP = new map<id,Demand__c>();
                    for (Demand__c dmnd : demandsToUpdate) {
                        demandListMAP.put(dmnd.Id,dmnd);
                    }
                    if(demandListMAP.size()>0){
                        update demandListMAP.values();
                    }
                }
            }else{
                returnVariable = calculationToShow;
            }

            return returnVariable;

        }catch(Exception e){
            List<Error_Log__c> Error_Log_List = new List<Error_Log__c>();
            for (Demand__c demand : demandList) {
                Error_Log__c Error_Log = new Error_Log__c();
                Error_Log.Demand__c = demand.Id;
                Error_Log.Message__c = 'Late Payment Manager : Time : '+System.Now()+ ' - Error :'+e.getMessage() + ' - Line number :' +e.getLineNumber() + ' Stack Trace :' +e.getStackTraceString();
                Error_Log.Class__c = 'Late Payment Manager';
                Error_Log.Name = 'Late Payment Creation Error';
                Error_Log_List.add(Error_Log);
            }
            insert Error_Log_List;
            return null;
        }
    }

    
    @AuraEnabled(cacheable=false)
    public static void sendEmail(String bookingId,String demandId){
        Boolean canSendEmail = true;
        Booking__c booking = [SELECT Id, Total_Interest_Till_Date__c,VAT_On_Interest_Amount__c,Project__c,Unit__c,Primary_Applicant_Email__c,Opportunity__c,Primary_Applicant_Name__c,CRM_Executive__r.Name,
                    Opportunity__r.Other_Applicants_Name__c, Unit__r.Tower__r.Collection_Executive__c,Unit__r.Tower__r.Collection_Executive__r.Name, Opportunity__r.Other_Applicants_Email__c,Unit__r.Name,
                    LastModifiedDate, Tower__c,Unit__r.Tower__r.Stop_Automatic_Email__c,Project__r.Name FROM Booking__c WHERE Id =: bookingId ];

        canSendEmail = !booking.Unit__r.Tower__r.Stop_Automatic_Email__c;

        Demand__c demand = [SELECT Id, Name, Invoice_Date__c,Unit__r.Name, Due_Date__c, Invoice_Number__c, 
                                    Booking__r.Owner.Name,Booking__r.Owner.Email,Booking__c,Payment_Milestones__c,
                                    Booking__r.Opportunity__r.Name,  Booking__r.Opportunity__r.Unit__r.Name, 
                                    Booking__r.Primary_Applicant_Email__c, Total_Amount_Demanded__c,
                                    Booking__r.Opportunity__r.Unit__r.Tower__r.Name, 
                                    Booking__r.Opportunity__r.Unit__r.Tower__r.Cluster__r.Name, AttachmentId__c 
                                    FROM Demand__c WHERE Id =: demandId ];
        
        Blob PDFbody;
        Blob htmlBody;

        String executiveName='';
        executiveName = booking.Unit__r.Tower__r.Collection_Executive__c != null ? booking.Unit__r.Tower__r.Collection_Executive__r.Name : '';
        List<String> toAddress = new List<String>();
        List<String> otherApplicantEmail = new List<String>();
        List<String> toCCAddress = new List<String>();
        toCCAddress.add(System.label.CollectionTeamEmail);
        toCCAddress.add('sfnotifications@sobharealty.com'); 
        List<ContentVersion> listContentVersion = new List<ContentVersion>();
        PageReference pageRef = Page.Latepaymentcharges;
        pageRef.getParameters().put('bookingId',booking.Id);
        System.debug(' PDFbody = '+PDFbody);
            
        if(!test.isRunningTest()) {
            PDFbody = pageRef.getContentAsPDF();
            // String content = pageRef.getContentAsPDF().toString();
            // if (content.contains('Error in PDF LP')) {
            //     canSendEmail = false;
            // }
        }else {
            htmlBody = Blob.valueof('Dummy Content for Test Methods');
            PDFbody = Blob.valueOf('Some Text');
        }
        Set<String> contId = new Set<String>();
        
        ContentVersion cont = new ContentVersion();
        cont.Title = demand.Invoice_Number__c + '-' + demand.Booking__r.Opportunity__r.Name + '-' + demand.Booking__r.Opportunity__r.Unit__r.Tower__r.Cluster__r.Name + '-' + demand.Booking__r.Opportunity__r.Unit__r.Tower__r.Name + '-' + demand.Booking__r.Opportunity__r.Unit__r.Name + system.now();
        cont.VersionData = PDFbody;
        cont.ExternalDocumentInfo1 = demand.Id;
        cont.PathOnClient = demand.Invoice_Number__c +'.pdf';
        cont.ContentLocation = 'S';
        cont.Description = 'LPC for :' + demand.Booking__r.Opportunity__r.Name;
        cont.TagCSV = 'LPC for :' + demand.Booking__r.Opportunity__r.Name;
        listContentVersion.add(cont);
        System.debug(' listContentVersion '+listContentVersion);

        insert listContentVersion;
        System.debug(' listContentVersion '+listContentVersion);
        for (ContentVersion cv : listContentVersion) {
            contId.add(cv.Id);
        }
        System.debug(' contId '+contId);            
        List<ContentDocumentLink> cDeList = new List<ContentDocumentLink>();
        for (ContentVersion CV : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN:contId ]) {
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = CV.ContentDocumentId;
            cDe.LinkedEntityId = '0582o0000002N5c'; 
            cDe.ShareType = 'I';
            cDe.Visibility  = 'AllUsers';
            cDeList.add(cDe);
        } 
        System.debug(' cDeList '+cDeList); 
        try {
            insert cDeList; 
        } catch (Exception e) {}
        
        List<FeedItem> flList = new List<FeedItem>();
        for (ContentVersion CV : listContentVersion) {
            if(CV.ExternalDocumentInfo1 == demand.Id){
                FeedItem elm = new FeedItem(Body = 'Post with related document body', ParentId = demand.Id, RelatedRecordId = CV.Id, Type = 'ContentPost');
                flList.add(elm);
            }
        }
        System.debug(' demand '+demand); 
        insert flList;
        
        List<Demand__c> dmandListForUpdate = new List<Demand__c>();
        for (ContentVersion CV : listContentVersion) {
            if(CV.ExternalDocumentInfo1 == demand.Id){
                demand.AttachmentId__c = CV.id;
                dmandListForUpdate.add(demand); 
            }
        }
        System.debug(' dmandListForUpdate '+dmandListForUpdate); 
        update dmandListForUpdate; 
        
        // Take the PDF content
        Blob b;
        if(!Test.isRunningTest()){
            b = pageRef.getContent();   
        } else {
            b = Blob.valueOf('Test123');
        }

        Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
        System.debug(' owaMap '+owaMap); 
        for(OrgWideEmailAddress owa : [SELECT id,DisplayName, Address FROM OrgWideEmailAddress]){
            owaMap.put(owa.Address,owa);
        }
        
        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('LatePaymentCharge.pdf');
        efa.setBody(b);
        
        if(booking.Primary_Applicant_Email__c != null){
            toAddress.add(booking.Primary_Applicant_Email__c);
        }
        if(booking.Opportunity__r.Other_Applicants_Email__c != null){
            otherApplicantEmail = booking.Opportunity__r.Other_Applicants_Email__c.split('\\,');
        }
        for(String s : otherApplicantEmail){
            if(!s.containsIgnoreCase('null')){
                toAddress.add(s);
            }
        }
        
        //Creating the email to be sent
        String body = '<br>Dear '+booking.Primary_Applicant_Name__c;
        if(booking.Opportunity__r.Other_Applicants_Name__c != null){
            body += booking.Opportunity__r.Other_Applicants_Name__c;
        }
        body += ',</br>';
        body += '<p>Hope you are doing well.</p>';
        if(booking.Project__r.Name.contains('Siniya')){
            body += '<p>Thank you for your purchase in our prestigious project Sobha Realty.</p>';
        }else{
            body += '<p>Thank you for your purchase in our prestigious project Sobha Al Siniya FZC.</p>';
        }
        body += '<p>With reference to the Unit '+booking.Unit__r.Name +' you have purchased, please find attached the late payment notice for your quick reference.</p>';
        body += '<span>Should you require any further assistance in this regard, feel free to contact us on the email address <a href="mailto:"'+System.Label.collection_email+'">'+System.Label.collection_email+'</a> or the mailing address mentioned in the letter.</span></br></br>';
        body += '<span>Please log on to our website <a href="https://www.sobharealty.com/">www.sobharealty.com</a> for further information about our current and upcoming projects.</span></br>';
        body += '<p>Have a nice day!</p>';
        body += '<p>Thanks & Regards, </p>';
        body +=  '<p>'+executiveName+'</p>';
        body += '<p>Collection Team.</p>';
        body += '<a href="https://www.facebook.com/SobhaRealty/" style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPN&oid=00D1t000000G1gX"></img></a>&nbsp;';
        body += '<a href="https://www.instagram.com/sobharealty/"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPO&oid=00D1t000000G1gX"></img></a>&nbsp;';
        body += '<a href="https://www.youtube.com/channel/UCKIR9isiNyYq1T0GSnIUyHQ"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPS&oid=00D1t000000G1gX" ></img></a>&nbsp;';
        body += '<a href="https://www.linkedin.com/company/sobharealty/"  style="margin-top:10px; display:block; float:left;width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPX&oid=00D1t000000G1gX"></img></a>&nbsp;';
        body += '<a href="https://www.sobharealty.com/" style="float:left; margin-top: 5px;height:1%;overflow-y:hidden">sobharealty.com</a>';
        body += '<br/><br/>';
        body += '<p><a href="https://www.sobharealty.com/"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPc&oid=00D1t000000G1gX" style="float:left; width:25%;"></img></a></p>';
        System.debug(' body = '+body);
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setSubject('Late Payment Charge Notice - Unit '+booking.Unit__r.Name+', Project-'+booking.Tower__c+' ');
        email.setHtmlBody(body);
        email.setToAddresses(toAddress);
        email.setCcAddresses(toCCAddress);
        email.setWhatId(booking.Id);
        if(booking.Project__r.Name.contains('Siniya')){
            email.setOrgWideEmailAddressId(owaMap.get(System.Label.Collection_Siniya_Email).id);
        }else{
            email.setOrgWideEmailAddressId(owaMap.get(System.Label.collection_email).id);
        }
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        System.debug(' email = '+email);
        if(System.label.isAllowToSendLatePaneltyEmail == 'Sent Email' && canSendEmail == true){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }


    @InvocableMethod(label='Send Demand Notification' description='Demand Id and Booking Id To be send')
    public static void resendNotification(List<Demand__c> demandList){
        LatePaymentManager.sendEmail(demandList[0].Booking__c,demandList[0].Id);
    }

    public static String INFormat(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
           negative = true;
        }
        if(money == null) {
            return 'NIL';
        }
        Decimal tempMoney = money;
        String m0 = tempMoney.setscale(0,RoundingMode.HALF_EVEN).toPlainString();
        String decimalPart;
        List<String> tempStr = new List<String>();
        if(String.isNotBlank(m0)) {
            tempStr = m0.split('\\.');
            if(tempStr != null && tempStr.size() == 2) {
                decimalPart = tempStr[1];
            }
        }
        String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_EVEN))).reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);         
            if(i==2 || i==5 || i==8 || i==11 || i==14) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        if(String.isNotBlank(decimalPart)){
            mf = mf + '.'  + decimalPart;
        }
        if(!negative){
            mf = mF;
        }else{
           mf = '- ' + mf /* + '/-'*/;
        }
        return mf;
    }  
}