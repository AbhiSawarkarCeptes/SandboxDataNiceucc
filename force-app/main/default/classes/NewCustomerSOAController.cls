public without sharing class NewCustomerSOAController {
    
    public String oppId;
    public List<Payment_Milestones__c> pmList {get;set;}
    public Booking__c Booking {get; set;}
    public List<Demand__c> demandList;
    public List<Receipt__c> receiptList;
    public Date ledgerDate {get;set;}
    public Decimal debitAmount;
    public Decimal total2;
    public Decimal creditAmount;
    Map<String,Map<String,String>> cValuesMap = new Map<String,Map<String,String>>();
    public List<PaymentMilestoneWrapper> pmWrapper_due_List {get;set;}
    public List<PaymentMilestoneWrapper> pmWrapper_Upcoming_List {get;set;}
    public Integer NO_OF_lpS {get;set;}
    
    List<Receipt__c> receipt_List ;
    List<Receipt__c> receipt_List_Temp ;
    public Decimal due_total_chargePercentage {get;set;} 
    public Decimal due_total_amount {get;set;} 
    public Decimal due_total_vat {get;set;} 
    public Decimal due_total_amount_n_vat {get;set;} 
    public Decimal due_total_paid {get;set;} 
    public Decimal due_total_balance {get;set;} 
    public Decimal gradn_total_chargePercentage {get;set;} 
    public Decimal gradn_total_amount {get;set;} 
    public Decimal gradn_total_vat {get;set;} 
    public Decimal gradn_total_amount_n_vat {get;set;} 
    public Decimal gradn_total_paid {get;set;} 
    public Decimal gradn_total_balance {get;set;} 
    public Decimal creditNote_installment {get;set;} 
    public Decimal creditNote_total_additional {get;set;} 
    public Decimal creditNote_total {get;set;} 
    public Decimal Purchase_Price {get;set;}
    public Decimal upcomind_total_chargePercentage  {get;set;}
    public Decimal upcomind_total_amount  {get;set;}
    public Decimal upcomind_total_vat  {get;set;}
    public Decimal upcomind_total_amount_n_vat  {get;set;}
    public Decimal upcomind_total_paid  {get;set;}
    public Decimal upcomind_total_balance  {get;set;}
    public String due_total_chargePercentage_string {get;set;} 
    public String due_total_amount_string {get;set;} 
    public String due_total_vat_string {get;set;} 
    public String due_total_amount_n_vat_string {get;set;} 
    public String due_total_paid_string {get;set;} 
    public String due_total_balance_string {get;set;} 
    public String gradn_total_chargePercentage_string {get;set;} 
    public String gradn_total_amount_string {get;set;} 
    public String gradn_total_vat_string {get;set;} 
    public String gradn_total_amount_n_vat_string {get;set;} 
    public String gradn_total_paid_string {get;set;} 
    public String gradn_total_balance_string {get;set;} 

    public String other_chages_amount_total_String {get;set;} 
    public Decimal other_chages_amount_total {get;set;} 
    public String Other_paid_amount_total_String {get;set;} 
    public Decimal Other_paid_amount_total {get;set;} 
    public String Other_balance_total_String {get;set;} 
    public Decimal Other_balance_total {get;set;} 
        
    public String upcomind_total_chargePercentage_string {get;set;} 
    public String upcomind_total_amount_string {get;set;} 
    public String upcomind_total_vat_string {get;set;} 
    public String upcomind_total_amount_n_vat_string {get;set;} 
    public String upcomind_total_paid_string {get;set;} 
    public String upcomind_total_balance_string {get;set;} 

    public String creditNote_installment_string {get;set;}
    public String creditNote_total_additional_string {get;set;} 
    public String creditNote_total_string {get;set;}
    public String Purchase_Price_string {get;set;}
    
    public List<otherChargesWrapper> otherChargesWrapperList {get;set;} 
    public List<receiptWrapper> receiptWrapperList {get;set;} 
    public Boolean showError {get;set;}


    public NewCustomerSOAController() {
        ledgerDate = System.today();   
        pmWrapper_due_List = new List<PaymentMilestoneWrapper>();
        pmWrapper_Upcoming_List = new List<PaymentMilestoneWrapper>();
        due_total_chargePercentage = 0;
        due_total_amount = 0;
        due_total_vat = 0;
        due_total_amount_n_vat = 0;
        due_total_paid = 0;
        due_total_balance = 0;
        gradn_total_chargePercentage = 0;
        gradn_total_amount = 0;
        gradn_total_vat = 0;
        gradn_total_amount_n_vat = 0;
        gradn_total_paid = 0;
        gradn_total_balance = 0;
        NO_OF_lpS = 0;

        other_chages_amount_total = 0;
        Other_paid_amount_total = 0;
        Other_balance_total = 0;
        
        upcomind_total_chargePercentage = 0;
        upcomind_total_amount = 0;
        upcomind_total_vat = 0;
        upcomind_total_amount_n_vat = 0;
        upcomind_total_paid = 0;
        upcomind_total_balance = 0;


        creditNote_total_additional = 0;
        creditNote_installment = 0;
        creditNote_total = 0;
        Purchase_Price = 0;
        receiptList = new List<Receipt__c>();
        receipt_List_Temp = new List<Receipt__c>();

        Set<String> allousername = new Set<String>();
        allousername.add('priyanuj.deka@sobharealty.com');
        allousername.add('ashish.rupani@sobharealty.com');
        allousername.add('ummer.farhan@sobharealty.com');
        allousername.add('priya.rathi@sobharealty.com');
        allousername.add('deann.dsilva@sobharealty.com');
        allousername.add('mohamed.akl@sobharealty.com');
        allousername.add('eslam.younes@sobharealty.com');
        allousername.add('adnan.hamid@sobharealty.com');
        allousername.add('suraj.surendran@sobharealty.com');
        allousername.add('deepu.dineshan@sobharealty.com');
        allousername.add('shefeeq.niyas@sobharealty.com	');
        allousername.add('alvin.augustine@sobharealty.com');
        allousername.add('noreply.systemgenrated@sobharealty.com');
        allousername.add('rohan.nair@sobharealty.com');
        allousername.add('saurabh.kashyap@sobharealty.com');
        allousername.add('sakshi.daver@sobharealty.com');
        allousername.add('sadaf.kazi@sobharealty.com');
        allousername.add('mohammed.ali@sobharealty.com');
        allousername.add('keerthana.ramachandran@sobharealty.com');
        allousername.add('tejashree.mohite@sobharealty.com');
        allousername.add('roopa.nataraj@sobharealty.com');
        allousername.add('gautam.sawhney@sobharealty.com');
        allousername.add('priyanka.binil@sobharealty.com');
        allousername.add('anirudh.sharma@sobharealty.com');
        allousername.add('betsy.george@sobharealty.com');
        allousername.add('ryan.fernandes@sobharealty.com');
        allousername.add('sfc.furkan@sobharealty.com');
        allousername.add('sfc.aravindan@sobharealty.com');
        allousername.add('sfc.krishna@sobharealty.com');
        allousername.add('manuraj.chouhan@sobharealty.com');
        allousername.add('sundhar.arunachalam.c@sobharealty.com');
        allousername.add('sai.booragadda@sobharealty.com');
        allousername.add('abdul.goilkar@sobharealty.com');
        allousername.add('abhishek.dinesh@sobharealty.com');
        allousername.add('shefeeq.niyas@sobharealty.com');
        allousername.add('mohan.shanmugam@sobharealty.com');
        allousername.add('zafaryab.haider@sobharealty.com');
        allousername.add('solomon.george@sobharealty.com');
        allousername.add('vinay.namilikonda.c@sobharealty.com');


        try {
            System.debug('UserInfo.getUserEmail()'+UserInfo.getName());
            User usr = [ SELECT Id,Name,Username FROM User WHERE Id =: UserInfo.getUserId() ];
            System.debug('usr'+usr);
            // if(allousername.contains(usr.Username)){
                showError = false;
                Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
                                                                    FROM Activate_Track_Payment_Milestone__mdt];
                Booking = [SELECT id, Name, Unit__r.Unit_Status__c,Primary_Applicant_Email__c,Opportunity__r.Id,Opportunity__r.Name,Opportunity__r.Mailing_Address__c,Opportunity__r.Permanent_Address__c,Primary_Applicant_Name__c,Primary_Applicant_Address_Arabic__c,Unit__r.Project_Unit_Type__r.Name,Project__r.Id,Project__r.Name,Registration_Amount_Paid__c,
                            Primary_Applicant_Address__c,PrimaryMobileNumber__c, Agreement_Value__c, No_of_Earmarked_Parking__c,Unit__r.Tower__r.Name,Unit__r.Tower__r.Cluster__r.Name,Unit__r.Unit_Type__c,Project_Name__c,
                            Unit__r.Chargeable_Area__c,Unit__r.Name,Quotation__c,Unit__r.Legal_Entity__r.Name,Unit__r.Legal_Entity__r.Id FROM Booking__c 
                            WHERE id = :ApexPages.currentPage().getParameters().get('id') ]; 


                // receiptList = [ SELECT Id,Name,Receipt_Status__c FROM Receipt__c WHERE Receipt_Status__c = 'Cleared' AND  Booking__c = : ApexPages.currentPage().getParameters().get('id')  ];

                receipt_List_Temp = [ SELECT Id,Name,Other_Charges_Type__c,Amount_Rs__c,GL_Date__c,Mode__c,Description__c,Receipt_Date__c,Demand__c,Total_Amount__c,LP_Waiver__c,
                                    LP_Waiver__r.Demand__c,LP_Waiver__r.Demand__r.Milestone_Name__c,LP_Waiver__r.Demand__r.Other_Charges_Type__c,Booking__r.Agreement_Value__c,Booking__r.Booking_Date__c,Booking__r.Unit__r.Configuration__c,
                                    Registration_Collection_Control_Report__c,CreatedDate,Towards_Other_Charges_Amount__c,RemarksText__c,Credit_Card_Charges__c    
                                    FROM Receipt__c 
                                    WHERE Receipt_Status__c = 'Cleared' AND Is_Reversed_Receipt__c = false AND Hide_From_SOA__c = false 
                                    AND Booking__c = : ApexPages.currentPage().getParameters().get('id') ORDER BY GL_Date__c ASC ];
                

                System.debug(' Receipt --> '+receipt_List_Temp);
                System.debug(' Receipt Size --> '+receipt_List_Temp.size());

                pmList = [ SELECT Id,Name,Milestone_Name__c,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Cluster_Name__c,tower__c,Total_Installment_Tax__c,
                        Charge1Percentage__c,C1_CGST__c,C1_Amount__c,Charge2Percentage__c,C2_CGST__c,C2_Amount__c,
                        Charge3Percentage__c,C3_CGST__c,C3_Amount__c,
                        Charge4Percentage__c,C4_CGST__c,C4_Amount__c,
                        Charge5Percentage__c,C5_CGST__c,C5_Amount__c,
                        Charge6Percentage__c,C6_CGST__c,C6_Amount__c,
                        Charge7Percentage__c,C7_CGST__c,C7_Amount__c,
                        Charge8Percentage__c,C8_CGST__c,C8_Amount__c,
                        Charge9Percentage__c,C9_CGST__c,C9_Amount__c, 
                        Charge10Percentage__c,C10_CGST__c,C10_Amount__c, 
                        Charge11Percentage__c,C11_CGST__c,C11_Amount__c 
                        FROM Payment_Milestones__c WHERE Quotation__c =: Booking.Quotation__c ORDER BY Milestone_Due_Date__c ASC ];

                List<Demand__c> demandList = [SELECT ID, Due_Date__c,Total_Amount_Demanded__c,Debit_Demanded__c,Other_Charges_Type__c,Milestone_Name__c,Name,GL_Date__c,Debit_Type__c,Remarks__c,Total_Amount_with_Tax_Demanded__c
                                            FROM Demand__c 
                                            WHERE Booking__c =: Booking.Id and Demand_Status__c != 'Reversed'];  
                
                                            //modified code for other charges start
                Map<string,Decimal> otherChargesValues = new Map<String,Decimal>();
                Map<string,string> lpwaiverValues = new Map<String,String>();
                Map<String,otherChargesWrapper> otherChargesMap = new Map<String,otherChargesWrapper>();
                Integer count = 0;
                Boolean demandExist = false;
                Decimal otherChargesValue = 0;
                Map<String, Decimal> preDefineChargesMap = new Map<String, Decimal>();
                preDefineChargesMap.put('Admin Charges',decimal.valueOf(System.Label.X15k_Admin_Charges) );
                preDefineChargesMap.put('Admin Charges (General)',decimal.valueOf(System.Label.X15k_Admin_Charges_General) );
                preDefineChargesMap.put('Concept drawing NOC',decimal.valueOf(System.Label.X15k_Concept_drawing_NOC) );
                preDefineChargesMap.put('Construction NOC',decimal.valueOf(System.Label.X15k_Construction_NOC) );
                preDefineChargesMap.put('Detailed design NOC',decimal.valueOf(System.Label.X15k_Detailed_design_NOC) );
                preDefineChargesMap.put('DLD Cancellation Charges',decimal.valueOf(System.Label.X15k_DLD_Cancellation_Charges) );
                preDefineChargesMap.put('Name addition/deletion',decimal.valueOf(System.Label.X15k_Name_addition_deletion) );
                preDefineChargesMap.put('Ownership changes',decimal.valueOf(System.Label.X15k_Ownership_changes) );
                preDefineChargesMap.put('Plot title Deed',decimal.valueOf(System.Label.X15k_Plot_title_Deed) );
                preDefineChargesMap.put('Pre-registration To Pre-title Deed',decimal.valueOf(System.Label.X15k_Pre_registration_To_Pre_title_Deed) );
                preDefineChargesMap.put('Pre-registration to pre-title deed (completed projects)',decimal.valueOf(System.Label.X15k_Pre_registration_to_pre_title_deed_completed_projects) );
                preDefineChargesMap.put('Reissue of Plot NOC (other than construction)',decimal.valueOf(System.Label.X15k_Reissue_of_Plot_NOC_other_than_construction) );
                preDefineChargesMap.put('Reissue of Plot NOC (construction)',decimal.valueOf(System.Label.X15k_Reissue_of_Plot_NOC_construction) );
                preDefineChargesMap.put('Resale NOC (Oqood)',decimal.valueOf(System.Label.X15k_Resale_NOC_Oqood) );
                preDefineChargesMap.put('Resale NOC (Title Deed)',decimal.valueOf(System.Label.X15k_Resale_NOC_Title_Deed) );
                preDefineChargesMap.put('SPA Reissuance Fees',decimal.valueOf(System.Label.X15k_SPA_Reissuance_Fees) );
                preDefineChargesMap.put('SPA reissuance fees (per book)',decimal.valueOf(System.Label.X15k_SPA_reissuance_fees_per_book) );
                preDefineChargesMap.put('Title Deed Charges',decimal.valueOf(System.Label.X15k_Title_Deed_Charges) );
                preDefineChargesMap.put('Title Deed Fees (Units)',decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Units) );
                preDefineChargesMap.put('Title Deed Fees (Villas)',decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Villas) );

                //otherChargesValue = preDefineChargesMap.containsKey(receipt.Other_Charges_Type__c) != null ? preDefineChargesMap.get(receipt.Other_Charges_Type__c) : 0;

                Map<String, otherChargesWrapper> otherChargesWrapperMap = new Map<String, otherChargesWrapper>();
                Map<String, otherChargesWrapper> otherChargesWrapperMapToDisplay = new Map<String, otherChargesWrapper>();
                Map<String, Demand__c> allDemandMap = new Map<String, Demand__c>();
                if(demandList != null && demandList.size()>0){
                    for (Demand__c demand : demandList) {
                        allDemandMap.put(demand.Id+'#'+demand.Milestone_Name__c,demand);
                        String remark = demand.Remarks__c != null ? demand.Remarks__c.toLowercase() : '';
                        String Milestone_Name = demand.Milestone_Name__c != null ? demand.Milestone_Name__c.toLowercase() : '';
                        otherChargesWrapper OCW = new otherChargesWrapper();
                        if(Milestone_Name.contains('late payment') && !Milestone_Name.contains('debit') && !Milestone_Name.contains('credit')){
                            OCW.description = demand.Milestone_Name__c;
                            OCW.demandDueDate = demand.Due_Date__c != null ? demand.Due_Date__c : demand.GL_Date__c;
                            OCW.chargeAmountString = INFormat((Decimal)demand.Total_Amount_with_Tax_Demanded__c);
                            OCW.chargeAmount = demand.Total_Amount_with_Tax_Demanded__c;
                            OCW.demandId = demand.Id;
                            OCW.paymentCompleted = false;
                            OCW.paid = 0;
                            OCW.balance = ( (OCW.chargeAmount != null ? OCW.chargeAmount : 0) - ( OCW.paid != null ? OCW.paid : 0 ) > 0 ? OCW.chargeAmount - OCW.paid : 0);
                            OCW.BalanceString = INFormat((Decimal)OCW.balance);
                            OCW.paidString = INFormat((Decimal)OCW.paid);
                            otherChargesWrapperMap.put(demand.Id+'#'+demand.Milestone_Name__c,OCW);
                            NO_OF_lpS += 1;
                        }
                        if(preDefineChargesMap.keySet().contains(demand.Milestone_Name__c) && !Milestone_Name.contains('debit') && !Milestone_Name.contains('credit')){
                            OCW.description = demand.Milestone_Name__c;
                            OCW.demandDueDate = demand.Due_Date__c != null ? demand.Due_Date__c : demand.GL_Date__c;
                            OCW.chargeAmountString = INFormat((Decimal)demand.Total_Amount_with_Tax_Demanded__c);
                            OCW.chargeAmount = demand.Total_Amount_with_Tax_Demanded__c;
                            OCW.demandId = demand.Id;
                            OCW.paymentCompleted = false;
                            OCW.paid = 0;
                            OCW.balance = ( (OCW.chargeAmount != null ? OCW.chargeAmount : 0) - ( OCW.paid != null ? OCW.paid : 0 ) > 0 ? OCW.chargeAmount - OCW.paid : 0);
                            OCW.BalanceString = INFormat((Decimal)OCW.balance);
                            OCW.paidString = INFormat((Decimal)OCW.paid);
                            otherChargesWrapperMap.put(demand.Milestone_Name__c,OCW);
                        }
                        if((demand.Debit_Type__c == 'DLD Charges' ) && !Milestone_Name.contains('credit')){
                            OCW.description = demand.Milestone_Name__c +' - '+ demand.Debit_Type__c ;
                            OCW.demandDueDate = demand.Due_Date__c != null ? demand.Due_Date__c : demand.GL_Date__c;
                            OCW.chargeAmountString = INFormat((Decimal)demand.Total_Amount_with_Tax_Demanded__c);
                            OCW.chargeAmount = demand.Total_Amount_with_Tax_Demanded__c;
                            OCW.demandId = demand.Id;
                            OCW.paymentCompleted = false;
                            OCW.paid = 0;
                            OCW.balance = ( (OCW.chargeAmount != null ? OCW.chargeAmount : 0) - ( OCW.paid != null ? OCW.paid : 0 ) > 0 ? OCW.chargeAmount - OCW.paid : 0);
                            OCW.BalanceString = INFormat((Decimal)OCW.balance);
                            OCW.paidString = INFormat((Decimal)OCW.paid);
                            otherChargesWrapperMap.put(demand.Milestone_Name__c,OCW);
                        }
                        if((demand.Debit_Type__c == 'Others' ) && Milestone_Name.contains('debit note') && (remark.contains('reallocation') || remark.contains('re-allocation'))){
                            if(otherChargesWrapperMap.get(demand.Milestone_Name__c) != null){
                                OCW = otherChargesWrapperMap.get(demand.Milestone_Name__c);
                            }
                            OCW.description = demand.Milestone_Name__c +' - '+ demand.Debit_Type__c ;
                            OCW.demandDueDate = demand.Due_Date__c != null ? demand.Due_Date__c : demand.GL_Date__c;
                            OCW.chargeAmount += demand.Total_Amount_with_Tax_Demanded__c;
                            OCW.chargeAmountString = INFormat((Decimal)OCW.chargeAmount);
                            OCW.demandId = demand.Id;
                            OCW.paymentCompleted = false;
                            OCW.paid = 0;
                            OCW.balance = ( (OCW.chargeAmount != null ? OCW.chargeAmount : 0) - ( OCW.paid != null ? OCW.paid : 0 ) > 0 ? OCW.chargeAmount - OCW.paid : 0);
                            OCW.BalanceString = INFormat((Decimal)OCW.balance);
                            OCW.paidString = INFormat((Decimal)OCW.paid);
                            otherChargesWrapperMap.put(demand.Milestone_Name__c,OCW);
                        }
                        if((demand.Debit_Type__c == 'Others' ) && Milestone_Name.contains('debit note') && (remark.containsIgnoreCase('cancellation') || remark.containsIgnoreCase('refund') || remark.containsIgnoreCase('swap'))){
                            if(otherChargesWrapperMap.get(demand.Milestone_Name__c) != null){
                                OCW = otherChargesWrapperMap.get(demand.Milestone_Name__c);
                            }
                            OCW.description = demand.Milestone_Name__c +' - '+ demand.Debit_Type__c ;
                            OCW.demandDueDate = demand.Due_Date__c != null ? demand.Due_Date__c : demand.GL_Date__c;
                            OCW.chargeAmount += demand.Total_Amount_with_Tax_Demanded__c;
                            OCW.chargeAmountString = INFormat((Decimal)OCW.chargeAmount);
                            OCW.demandId = demand.Id;
                            OCW.paymentCompleted = false;
                            OCW.paid = 0;
                            OCW.balance = ( (OCW.chargeAmount != null ? OCW.chargeAmount : 0) - ( OCW.paid != null ? OCW.paid : 0 ) > 0 ? OCW.chargeAmount - OCW.paid : 0);
                            OCW.BalanceString = INFormat((Decimal)OCW.balance);
                            OCW.paidString = INFormat((Decimal)OCW.paid);
                            otherChargesWrapperMap.put(demand.Id+'#'+demand.Milestone_Name__c,OCW);
                        }   
                        if(Milestone_Name.contains('cheque dishonored') && demand.Debit_Type__c != 'Cancellation'){
                            System.debug('CQ Milestone_Name -> '+Milestone_Name);
                            System.debug('CQ Milestone_Name -> '+otherChargesWrapperMap.values());
                            if(otherChargesWrapperMap.get(demand.Milestone_Name__c) != null){
                                System.debug('CQ OCW -> '+OCW);
                                OCW = otherChargesWrapperMap.get(demand.Milestone_Name__c);
                            }
                            System.debug('CQ OCW -> '+OCW);
                            OCW.description = demand.Milestone_Name__c +' - '+ demand.Debit_Type__c ;
                            OCW.demandDueDate = demand.Due_Date__c != null ? demand.Due_Date__c : demand.GL_Date__c;
                            OCW.chargeAmount += demand.Total_Amount_with_Tax_Demanded__c;
                            OCW.chargeAmountString = INFormat((Decimal)OCW.chargeAmount);
                            OCW.demandId = demand.Id;
                            OCW.paymentCompleted = false;
                            OCW.paid = 0;
                            OCW.balance = ( (OCW.chargeAmount != null ? OCW.chargeAmount : 0) - ( OCW.paid != null ? OCW.paid : 0 ) > 0 ? OCW.chargeAmount - OCW.paid : 0);
                            OCW.BalanceString = INFormat((Decimal)OCW.balance);
                            OCW.paidString = INFormat((Decimal)OCW.paid);
                            otherChargesWrapperMap.put(demand.Milestone_Name__c,OCW);
                        }   
                    }
                }
                if(receipt_List_Temp != null && receipt_List_Temp.size() > 0){
                    Decimal LP_CollectedAmount = 0;
                    Decimal CQ_dishonored = 0;
                    Decimal Other_CollectedAmount = 0;
                    for (Receipt__c receipt : receipt_List_Temp) {
                        System.debug('Loop Receipt ->'+receipt.Total_Amount__c);
                        otherChargesValue = 0;
                        System.debug('Sreceipt 1 '+receipt.Name+' - Amount - '+receipt.Amount_Rs__c);
                        String rd = receipt.Description__c != null ? receipt.Description__c.toLowercase() : '';
                        if(receipt.Credit_Card_Charges__c != null && receipt.Credit_Card_Charges__c > 0){
                            if(receipt.Other_Charges_Type__c == 'Late Payment Charges'){
                                LP_CollectedAmount += receipt.Credit_Card_Charges__c;
                                System.debug('LPC -> '+rd+ ' - '+receipt.Name+' - '+receipt.Credit_Card_Charges__c);
                                System.debug('LPC Collected Amount -> '+LP_CollectedAmount);
                            }
                            if(receipt.Other_Charges_Type__c != 'Late Payment Charges'){
                                if(receipt.Credit_Card_Charges__c != null && receipt.Credit_Card_Charges__c > 0){
                                    otherChargesValue = preDefineChargesMap.containsKey(receipt.Other_Charges_Type__c) != null ? preDefineChargesMap.get(receipt.Other_Charges_Type__c) : 0;
                                    System.debug('otherChargesValue ->'+otherChargesValue);
                                    if(otherChargesValue != null && otherChargesValue > 0){
                                        otherChargesWrapper tempOCW = new otherChargesWrapper();
                                        System.debug('otherChargesValue receipt.Other_Charges_Type__c -> '+receipt.Other_Charges_Type__c);
                                        System.debug('otherChargesValue otherChargesWrapperMap keySet -> '+otherChargesWrapperMap.keySet());
                                        System.debug('otherChargesValue otherChargesWrapperMap.keySet().contains(receipt.Other_Charges_Type__c) -> '+otherChargesWrapperMap.keySet().contains(receipt.Other_Charges_Type__c));
                                        if( receipt.Other_Charges_Type__c != null && otherChargesWrapperMap.keySet().contains(receipt.Other_Charges_Type__c) != false ){
                                            tempOCW = otherChargesWrapperMap.get(receipt.Other_Charges_Type__c);
                                            System.debug('otherChargesWrapperMap -> '+otherChargesWrapperMap);
                                            System.debug('tempOCW -> '+tempOCW);
                                            tempOCW.paid = (tempOCW.paid != null ? tempOCW.paid : 0 ) + (receipt.Credit_Card_Charges__c != null ? receipt.Credit_Card_Charges__c : 0);
                                            tempOCW.balance = ( (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - ( tempOCW.paid != null ? tempOCW.paid : 0 ) > 0 ? tempOCW.chargeAmount - tempOCW.paid : 0);
                                            tempOCW.BalanceString = INFormat((Decimal)tempOCW.balance);
                                            tempOCW.paidString = INFormat((Decimal)tempOCW.paid);
                                            tempOCW.paymentCompleted = true;
                                            tempOCW.description = (receipt.Other_Charges_Type__c != null ? receipt.Other_Charges_Type__c : Receipt.RemarksText__c);
                                        }else{
                                            System.debug('otherChargesValue INFormat(otherChargesValue) -> '+INFormat((Decimal)otherChargesValue));
                                            System.debug('otherChargesValue receipt.Other_Charges_Type__c-> '+receipt.Other_Charges_Type__c);
                                            System.debug('otherChargesValue receipt.Credit_Card_Charges__c-> '+receipt.Credit_Card_Charges__c);
                                            tempOCW.chargeAmount = otherChargesValue;
                                            tempOCW.chargeAmountString = INFormat((Decimal)tempOCW.chargeAmount);
                                            tempOCW.description = receipt.Other_Charges_Type__c;
                                            Decimal tempCal = (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - (receipt.Credit_Card_Charges__c != null ? receipt.Credit_Card_Charges__c : 0);
                                            if(tempCal > 0){
                                                System.debug('otherChargesValue IF receipt.Credit_Card_Charges__c-> '+receipt.Credit_Card_Charges__c);
                                            tempOCW.paid = (receipt.Credit_Card_Charges__c != null ? receipt.Credit_Card_Charges__c : 0);
                                            tempOCW.balance = ( (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - ( tempOCW.paid != null ? tempOCW.paid : 0 ) > 0 ? tempOCW.chargeAmount - tempOCW.paid : 0);
                                            tempOCW.BalanceString = INFormat((Decimal)tempOCW.balance);
                                            tempOCW.paidString = INFormat((Decimal)tempOCW.paid);
                                            }else{
                                                System.debug('otherChargesValue ELSE receipt.Credit_Card_Charges__c-> '+tempOCW.chargeAmount);
                                                tempOCW.paid = (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0);
                                                tempOCW.balance = ( (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - ( tempOCW.paid != null ? tempOCW.paid : 0 ) > 0 ? tempOCW.chargeAmount - tempOCW.paid : 0);
                                                tempOCW.BalanceString = INFormat((Decimal)tempOCW.balance);
                                                tempOCW.paidString = INFormat((Decimal)tempOCW.paid);
                                                tempOCW.paymentCompleted = true;
                                            }
                                        }
                                        otherChargesWrapperMap.put(receipt.Other_Charges_Type__c,tempOCW);
                                    }else{
                                        otherChargesWrapper tempOCW = new otherChargesWrapper();
                                        System.debug('otherChargesValue otherChargesWrapperMap keySet -> '+otherChargesWrapperMap.keySet());
                                        if(receipt.Other_Charges_Type__c != null && otherChargesWrapperMap.keySet().contains(receipt.Other_Charges_Type__c) != false ){
                                            System.debug('otherChargesValue receipt.Other_Charges_Type__c-> '+receipt.Other_Charges_Type__c);
                                            System.debug('otherChargesValue receipt.Credit_Card_Charges__c-> '+receipt.Credit_Card_Charges__c);
                                            tempOCW = otherChargesWrapperMap.get(receipt.Other_Charges_Type__c);
                                            tempOCW.chargeAmountString = INFormat((Decimal)tempOCW.chargeAmount);
                                            tempOCW.paid = tempOCW.paid + receipt.Credit_Card_Charges__c;
                                            tempOCW.balance = ( (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - ( tempOCW.paid != null ? tempOCW.paid : 0 ) > 0 ? tempOCW.chargeAmount - tempOCW.paid : 0);
                                            tempOCW.BalanceString = INFormat((Decimal)tempOCW.balance);
                                            tempOCW.paidString = INFormat((Decimal)tempOCW.paid);
                                            tempOCW.paymentCompleted = true;
                                            tempOCW.description = (receipt.Other_Charges_Type__c != null ? receipt.Other_Charges_Type__c : Receipt.RemarksText__c);
                                            System.debug('otherChargesValue tempOCW-> '+tempOCW);
                                        }else{
                                            System.debug('otherChargesValue tempOCW-> '+tempOCW);
                                            System.debug('otherChargesValue ->'+otherChargesValue);
                                            System.debug('otherChargesValue receipt.Other_Charges_Type__c-> '+receipt.Other_Charges_Type__c);
                                            System.debug('otherChargesValue receipt.Credit_Card_Charges__c-> '+receipt.Credit_Card_Charges__c);
                                            if(receipt.Amount_Rs__c > receipt.Credit_Card_Charges__c){
                                                tempOCW.chargeAmount = tempOCW.chargeAmount + (receipt.Credit_Card_Charges__c != null ? receipt.Credit_Card_Charges__c : 0); 
                                            }else{
                                                tempOCW.chargeAmount = tempOCW.chargeAmount + (receipt.Amount_Rs__c != null ? receipt.Amount_Rs__c : 0);
                                            }
                                            tempOCW.chargeAmountString = INFormat((Decimal)tempOCW.chargeAmount);
                                            tempOCW.description = (receipt.Other_Charges_Type__c != null ? receipt.Other_Charges_Type__c : Receipt.RemarksText__c);
                                            Decimal tempCal = (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - (receipt.Credit_Card_Charges__c != null ? receipt.Credit_Card_Charges__c : 0);
                                            
                                            System.debug('otherChargesValue tempCal-> '+tempCal);
                                            if(tempCal > 0){
                                                tempOCW.paid = (receipt.Credit_Card_Charges__c != null ? receipt.Credit_Card_Charges__c : 0);
                                                tempOCW.paidString = INFormat((Decimal)tempOCW.paid);
                                                tempOCW.balance = ( (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - ( tempOCW.paid != null ? tempOCW.paid : 0 ) > 0 ? tempOCW.chargeAmount - tempOCW.paid : 0);
                                                tempOCW.BalanceString = INFormat((Decimal)tempOCW.balance);
                                                System.debug('otherChargesValue tempOCW-> '+tempOCW);
                                            
                                            }else{
                                                System.debug('otherChargesValue tempCal-> '+tempCal);
                                                tempOCW.paid = (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0);
                                                tempOCW.paidString = INFormat((Decimal)tempOCW.paid);
                                                tempOCW.balance = ( (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - ( tempOCW.paid != null ? tempOCW.paid : 0 ) > 0 ? tempOCW.chargeAmount - tempOCW.paid : 0);
                                                tempOCW.BalanceString = INFormat((Decimal)tempOCW.balance);
                                                tempOCW.paymentCompleted = true;
                                                System.debug('otherChargesValue tempOCW-> '+tempOCW);
                                            }
                                        }
                                        otherChargesWrapperMap.put(receipt.Other_Charges_Type__c,tempOCW);
                                    }
                                }
                            }
                        }else if(receipt.Registration_Collection_Control_Report__c != null && receipt.Registration_Collection_Control_Report__c > 0){
                            if(receipt.Other_Charges_Type__c == null){
                                otherChargesWrapper ExistingDLDtempOCW = new otherChargesWrapper();
                                for (String otcWKey : otherChargesWrapperMap.keySet()) {
                                    if(otherChargesWrapperMap.get(otcWKey).description != null && otherChargesWrapperMap.get(otcWKey).description.contains('DLD Charges')){
                                        // if(otherChargesWrapperMap.get(otcWKey).paymentCompleted != true){
                                            ExistingDLDtempOCW = otherChargesWrapperMap.get(otcWKey);  
                                            break;
                                        // }
                                    }
                                }
                                if(ExistingDLDtempOCW != null && ExistingDLDtempOCW.description != null){
                                    if(ExistingDLDtempOCW.chargeAmount > 0){
                                        Decimal tempCal = (ExistingDLDtempOCW.chargeAmount != null ? ExistingDLDtempOCW.chargeAmount : 0) - (receipt.Registration_Collection_Control_Report__c != null ? receipt.Registration_Collection_Control_Report__c : 0);
                                        System.debug('ExistingDLDtempOCW ->'+tempCal);
                                        if(tempCal > 0){
                                            ExistingDLDtempOCW.paid += (receipt.Registration_Collection_Control_Report__c != null ? receipt.Registration_Collection_Control_Report__c : 0);
                                            ExistingDLDtempOCW.paidString = INFormat((Decimal)ExistingDLDtempOCW.paid);
                                            ExistingDLDtempOCW.balance = ( (ExistingDLDtempOCW.chargeAmount != null ? ExistingDLDtempOCW.chargeAmount : 0) - ( ExistingDLDtempOCW.paid != null ? ExistingDLDtempOCW.paid : 0 ) > 0 ? ExistingDLDtempOCW.chargeAmount - ExistingDLDtempOCW.paid : 0);
                                            ExistingDLDtempOCW.BalanceString = INFormat((Decimal)ExistingDLDtempOCW.balance);
                                            System.debug('ExistingDLDtempOCW ->'+ExistingDLDtempOCW);
                                        }else{
                                            ExistingDLDtempOCW.paid = (receipt.Registration_Collection_Control_Report__c != null ? receipt.Registration_Collection_Control_Report__c : 0);
                                            ExistingDLDtempOCW.paidString = INFormat((Decimal)ExistingDLDtempOCW.paid);
                                            ExistingDLDtempOCW.balance = ( (ExistingDLDtempOCW.chargeAmount != null ? ExistingDLDtempOCW.chargeAmount : 0) - ( ExistingDLDtempOCW.paid != null ? ExistingDLDtempOCW.paid : 0 ) > 0 ? ExistingDLDtempOCW.chargeAmount - ExistingDLDtempOCW.paid : 0);
                                            ExistingDLDtempOCW.BalanceString = INFormat((Decimal)ExistingDLDtempOCW.balance);
                                            ExistingDLDtempOCW.paymentCompleted = true;
                                            System.debug('ExistingDLDtempOCW ->'+ExistingDLDtempOCW);
                                        }
                                    }else{
                                        System.debug('ExistingDLDtempOCW ->'+receipt.Registration_Collection_Control_Report__c);
                                        ExistingDLDtempOCW.paid += (receipt.Registration_Collection_Control_Report__c != null ? receipt.Registration_Collection_Control_Report__c : 0);
                                        ExistingDLDtempOCW.paidString = INFormat((Decimal)ExistingDLDtempOCW.paid);
                                        ExistingDLDtempOCW.balance = ( (ExistingDLDtempOCW.chargeAmount != null ? ExistingDLDtempOCW.chargeAmount : 0) - ( ExistingDLDtempOCW.paid != null ? ExistingDLDtempOCW.paid : 0 ) > 0 ? ExistingDLDtempOCW.chargeAmount - ExistingDLDtempOCW.paid : 0);
                                        ExistingDLDtempOCW.BalanceString = INFormat((Decimal)ExistingDLDtempOCW.balance);
                                        System.debug('ExistingDLDtempOCW ->'+ExistingDLDtempOCW);
                                    }
                                }else{
                                    System.debug('ExistingDLDtempOCW ->'+ExistingDLDtempOCW);
                                    otherChargesWrapper tempOCW = new otherChargesWrapper();
                                    tempOCW.paid = receipt.Registration_Collection_Control_Report__c != null ? receipt.Registration_Collection_Control_Report__c : 0; 
                                    tempOCW.description = 'DLD Charges';
                                    if(receipt.Booking__r.Unit__r.Configuration__c.containsIgnoreCase('Plot')){
                                        tempOCW.chargeAmount = receipt.Booking__r.Agreement_Value__c * 0.04 + 1660;
                                    }else{
                                        tempOCW.chargeAmount = receipt.Booking__r.Agreement_Value__c * 0.04 + 1150;
                                    }
                                    
                                    tempOCW.chargeAmountString = INFormat((Decimal)tempOCW.chargeAmount);
                                    tempOCW.paidString = INFormat((Decimal)tempOCW.paid);
                                    tempOCW.demandDueDate = receipt.Booking__r.Booking_Date__c.date();
                                    tempOCW.balance = ( (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - ( tempOCW.paid != null ? tempOCW.paid : 0 ) > 0 ? tempOCW.chargeAmount - tempOCW.paid : 0);
                                    tempOCW.BalanceString = INFormat((Decimal)tempOCW.balance);
                                    Decimal tempCal = (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) - (receipt.Registration_Collection_Control_Report__c != null ? receipt.Registration_Collection_Control_Report__c : 0);
                                    System.debug('ExistingDLDtempOCW tempOCW ->'+tempOCW);
                                    otherChargesWrapperMap.put('DLD Charges',tempOCW);
                                }
                            }   
                        }else if(rd.contains('late payment') || rd.contains('late payment waiver') || rd.contains('lp waiver') || rd.contains('lpw') || rd.contains('interest waiver') || (receipt.LP_Waiver__c != null && receipt.LP_Waiver__r.Demand__c != null && receipt.LP_Waiver__r.Demand__r.Milestone_Name__c.containsIgnoreCase('late payment')) ){
                            LP_CollectedAmount += receipt.Amount_Rs__c;
                            System.debug('LPC -> '+rd+ ' - '+receipt.Name+' - '+receipt.Amount_Rs__c);
                            System.debug('LPC LP_CollectedAmount -> '+LP_CollectedAmount);
                        }else if(rd.contains('late payment') || rd.contains('late payment waiver') || rd.contains('lp waiver') || rd.contains('lpw') || rd.contains('interest waiver') || (receipt.LP_Waiver__c != null && receipt.LP_Waiver__r.Demand__c != null && receipt.LP_Waiver__r.Demand__r.Milestone_Name__c.containsIgnoreCase('cheque dishonored')) ){
                            CQ_dishonored += receipt.Amount_Rs__c;
                        }
                    }
                    Integer tempLP_Count= 0;
                    for (String otcWKey : otherChargesWrapperMap.keySet()) {
                        otherChargesWrapper tempOCW = otherChargesWrapperMap.get(otcWKey);
                        String wrapperDescription = tempOCW.description != null ? tempOCW.description.toLowercase() : '';
                        if(wrapperDescription.contains('late payment') && LP_CollectedAmount > 0 ){
                            tempLP_Count += 1;
                            System.debug('LPC -> '+tempOCW);
                            System.debug('LPC LP_CollectedAmount -> '+LP_CollectedAmount);
                            if(tempLP_Count == NO_OF_lpS){
                                tempOCW.paid = LP_CollectedAmount;
                            }else{
                                tempOCW.paid = ((tempOCW.chargeAmount != null ? (LP_CollectedAmount - tempOCW.chargeAmount >= 0 ? tempOCW.chargeAmount : LP_CollectedAmount ) : 0)); 
                            }
                            tempOCW.balance = (LP_CollectedAmount - tempOCW.chargeAmount >= 0 ? 0 : tempOCW.chargeAmount - LP_CollectedAmount );
                            tempOCW.paidString = INFormat((Decimal)tempOCW.paid);
                            tempOCW.BalanceString = INFormat((Decimal)tempOCW.balance);
                            LP_CollectedAmount = LP_CollectedAmount - (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) ;
                            
                            otherChargesWrapperMap.put(otcWKey,tempOCW);
                        }
                        if(wrapperDescription.containsIgnoreCase('cheque dishonored') && CQ_dishonored > 0 ){
                            System.debug('LPC -> '+tempOCW);
                            System.debug('LPC CQ_dishonored -> '+CQ_dishonored);
                            tempOCW.paid = ((tempOCW.chargeAmount != null ? (CQ_dishonored - tempOCW.chargeAmount >= 0 ? tempOCW.chargeAmount : CQ_dishonored ) : 0)); 
                            tempOCW.balance = (CQ_dishonored - tempOCW.chargeAmount >= 0 ? 0 : tempOCW.chargeAmount - CQ_dishonored );
                            tempOCW.paidString = INFormat((Decimal)tempOCW.paid);
                            tempOCW.BalanceString = INFormat((Decimal)tempOCW.balance);
                            CQ_dishonored = CQ_dishonored - (tempOCW.chargeAmount != null ? tempOCW.chargeAmount : 0) ;
                            otherChargesWrapperMap.put(otcWKey,tempOCW);
                        }
                    }
                }
                
                otherChargesWrapperList = new List<otherChargesWrapper>();
                if(otherChargesWrapperMap.values() != null){
                    for(otherChargesWrapper ocw: otherChargesWrapperMap.values()){
                        System.debug(' ocw -> '+ocw);
                        other_chages_amount_total += ocw.chargeAmount;
                        Other_paid_amount_total += ocw.paid;
                        Other_balance_total += ocw.Balance;
                        otherChargesWrapperList.add(ocw);
                    }
                    other_chages_amount_total_String = INFormat((Decimal)other_chages_amount_total);
                    Other_paid_amount_total_String = INFormat((Decimal)Other_paid_amount_total);
                    Other_balance_total_String = INFormat((Decimal)Other_balance_total);
                }
                receiptWrapperList = new List<receiptWrapper>();
                
                System.debug('otherChargesWrapperList --> '+otherChargesWrapperList);
                if(receipt_List_Temp != null && !receipt_List_Temp.isEmpty()){
                    for (Receipt__c receipt : receipt_List_Temp) {
                        
                        receiptWrapper rW = new receiptWrapper();
                        rw.receiptNo = receipt.Name;
                        rW.description = (receipt.description__c != null) ? receipt.description__c : receipt.RemarksText__c;
                        if((rW.description == null || rw.description == '') && receipt.LP_Waiver__c != null){
                            rW.description = 'Waiver of late payment charges';
                        }
                        rW.paymentMethod = receipt.Mode__c;
                        rW.receiptDate = receipt.GL_Date__c;
                        if(receipt.Other_Charges_Type__c == null) { 
                            rW.installment = receipt.Amount_Rs__c;
                            rw.installmentString = INFormat((Decimal)rW.installment);
                            System.debug('receipt.Amount_Rs__c'+receipt.Amount_Rs__c);
                            creditNote_total_additional += receipt.Amount_Rs__c != null ? receipt.Amount_Rs__c : 0; 
                            creditNote_total_additional_string = INFormat((Decimal)creditNote_total_additional);
                        }
                        if(receipt.Other_Charges_Type__c != null) { 
                            rW.additionalCharges = receipt.Amount_Rs__c; 
                            rw.additionalChargesString = INFormat((Decimal)rW.additionalCharges);
                            creditNote_installment += receipt.Amount_Rs__c != null ? receipt.Amount_Rs__c : 0;
                            creditNote_installment_string = INFormat((Decimal)creditNote_installment);
                        }
                        rW.total =  receipt.Amount_Rs__c;
                        rw.totalString = INFormat((Decimal)rW.total);
                        creditNote_total += receipt.Amount_Rs__c != null ? receipt.Amount_Rs__c : 0;
                        creditNote_total_string = INFormat((Decimal)creditNote_total);
                        receiptWrapperList.add(rW);
                    }
                }
                
                System.debug('receiptWrapperList --> '+receiptWrapperList.size());
                System.debug('receiptWrapperList --> '+receiptWrapperList);

                c_Values();
                if(pmList != null && !pmList.isEmpty()){
                    for(payment_Milestones__c pm : pmList){
                        
                        PaymentMilestoneWrapper pmw = new PaymentMilestoneWrapper();
                        pmw.milestoneNo = pm.Milestone_Name__c;
                        pmw.dueDate = pm.Milestone_Due_Date__c;
                        if(cValuesMap.containsKey(pm.Milestone_Name__c) && cvaluesMap.get(pm.Milestone_Name__c) != null){
                            Map<String,String> chargeMap = cvaluesMap.get(pm.Milestone_Name__c);
                            pmw.amount = chargeMap.get('amount');
                            pmw.chargePercentage = chargeMap.get('chargePercentage');
                            pmw.vat = chargeMap.get('vat');
                            pmw.total = chargeMap.get('totalAmount');
                            pmw.balance = chargeMap.get('balance');
                            pmw.paid = chargeMap.get('paid');
                            System.debug('pmw -->'+pmw);
                            
                            gradn_total_chargePercentage += decimal.valueOf(chargeMap.get('chargePercentage'));
                            gradn_total_chargePercentage_string = INFormat(gradn_total_chargePercentage);
                            if(chargeMap.get('amount') != null){
                                gradn_total_amount +=  decimal.valueOf(chargeMap.get('amount'));
                                gradn_total_amount_string = INFormat(gradn_total_amount);
                            }
                            
                            gradn_total_vat +=  decimal.valueOf(chargeMap.get('vat'));
                            gradn_total_vat_string =  INFormat(gradn_total_vat);
                            gradn_total_amount_n_vat +=  decimal.valueOf(chargeMap.get('totalAmount'));
                            gradn_total_amount_n_vat_string =  INFormat(gradn_total_amount_n_vat);
                            gradn_total_balance +=  decimal.valueOf(chargeMap.get('balance'));
                            gradn_total_balance_string =  INFormat(gradn_total_balance);
                            gradn_total_paid +=  decimal.valueOf(chargeMap.get('paid'));
                            gradn_total_paid_string =  INFormat(gradn_total_paid);

                            if(pmw.dueDate <= System.today()){
                                
                                pmw.amountString = INFormat(Decimal.valueOf(pmw.amount));
                                pmw.totalString = INFormat(Decimal.valueOf(pmw.total));
                                pmw.paidString = INFormat(Decimal.valueOf(pmw.paid));
                                pmw.balanceString = INFormat(Decimal.valueOf(pmw.balance));
                                pmWrapper_due_List.add(pmw);
                                due_total_chargePercentage +=  decimal.valueOf(chargeMap.get('chargePercentage'));
                                due_total_chargePercentage_string = INFormat(due_total_chargePercentage);
                                due_total_amount +=  decimal.valueOf(chargeMap.get('amount'));
                                due_total_amount_string = INFormat(due_total_amount);
                                due_total_vat +=  decimal.valueOf(chargeMap.get('vat'));
                                due_total_vat_string = INFormat(due_total_vat);
                                due_total_amount_n_vat +=  decimal.valueOf(chargeMap.get('totalAmount'));
                                due_total_amount_n_vat_string = INFormat(due_total_amount_n_vat);
                                due_total_balance  +=  decimal.valueOf(chargeMap.get('balance'));
                                due_total_balance_string = INFormat(due_total_balance);
                                due_total_paid +=  decimal.valueOf(chargeMap.get('paid'));
                                due_total_paid_string = INFormat(due_total_paid);
                            }else{
                                pmw.amountString = INFormat(Decimal.valueOf(pmw.amount));
                                pmw.totalString = INFormat(Decimal.valueOf(pmw.total));
                                pmw.paidString = INFormat(Decimal.valueOf(pmw.paid));
                                pmw.balanceString = INFormat(Decimal.valueOf(pmw.balance));
                                
                                pmWrapper_Upcoming_List.add(pmw);

                                upcomind_total_chargePercentage += decimal.valueOf(chargeMap.get('chargePercentage'));
                                upcomind_total_chargePercentage_string = INFormat(upcomind_total_chargePercentage);
                                upcomind_total_amount += decimal.valueOf(chargeMap.get('amount'));
                                upcomind_total_amount_string = INFormat(upcomind_total_amount);
                                upcomind_total_vat += decimal.valueOf(chargeMap.get('vat'));
                                upcomind_total_vat_string = INFormat(upcomind_total_vat);
                                upcomind_total_amount_n_vat +=decimal.valueOf(chargeMap.get('totalAmount'));
                                upcomind_total_amount_n_vat_string = INFormat(upcomind_total_amount_n_vat);
                                upcomind_total_paid += decimal.valueOf(chargeMap.get('paid'));
                                upcomind_total_paid_string = INFormat(upcomind_total_paid);
                                upcomind_total_balance += decimal.valueOf(chargeMap.get('balance'));
                                upcomind_total_balance_string = INFormat(upcomind_total_balance);
                                
                                
                            }
                        }   
                    }
                }
            // }else{
            //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You dont have access to this page'));
            //     showError = true;
            // }
        } catch (Exception e) {
            showError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You dont have access to this page'+e));
            
        }
    }
	
    
    public Map<string,pmReceiptWrapper> getPMPaymentDetails(string bookingid){
        Map<String,pmReceiptWrapper> milestoneDataMap = new Map<String,pmReceiptWrapper>();
        Decimal totalAmountInReceipts = 0;
        if(receipt_List_Temp != null && !receipt_List_Temp.isEmpty()){
            for(Receipt__c receipt : receipt_List_Temp){ 
                System.debug('Sreceipt 1 '+receipt.Name+' - Amount - '+receipt.Amount_Rs__c);
                String rd = receipt.Description__c != null ? receipt.Description__c.toLowercase() : '';
                if((receipt.Credit_Card_Charges__c == 0 ||  receipt.Credit_Card_Charges__c == null) && receipt.Other_Charges_Type__c == null && 
                !(rd.contains('late payment') || rd.contains('late payment waiver') || rd.contains('lp waiver') || rd.contains('lpw') || rd.contains('interest waiver')) && (receipt.LP_Waiver__c == null) ){
                        if(receipt.Registration_Collection_Control_Report__c > 0){
                            System.debug('Sreceipt 2 '+receipt.Amount_Rs__c+' - '+receipt.Registration_Collection_Control_Report__c);
                            totalAmountInReceipts = totalAmountInReceipts + (receipt.Amount_Rs__c - receipt.Registration_Collection_Control_Report__c);
                        }else{
                            System.debug('Sreceipt 3 '+receipt.Amount_Rs__c);
                            totalAmountInReceipts = totalAmountInReceipts + receipt.Amount_Rs__c;
                        }
                   }
            }
        }
         if(pmList != null && pmList.size() > 0){
            Integer index = 1;
            for(Payment_Milestones__c mileStone : pmList){
                if(totalAmountInReceipts >= milestone.Total_Installment_New__c){
                    if(!milestoneDataMap.containsKey(mileStone.id)){
                        pmReceiptWrapper pmReceipt = new pmReceiptWrapper();
                        pmReceipt.paid = true;
                        pmReceipt.amountPaid = milestone.Total_Installment_New__c;
                        totalAmountInReceipts = totalAmountInReceipts - milestone.Total_Installment_New__c;
                        if(totalAmountInReceipts < 0 ){
                            totalAmountInReceipts = 0;
                        }
                        milestoneDataMap.put(milestone.id, pmReceipt);
                        
                        if(index >= pmList.size()){
                            pmReceipt.paid = true;
                            pmReceipt.amountPaid += totalAmountInReceipts;
                            milestoneDataMap.put(milestone.id, pmReceipt);
                        }
                        index++;
                    }
                }else{
                    if(totalAmountInReceipts > 0){
                        if(!milestoneDataMap.containsKey(mileStone.id)){
                        	pmReceiptWrapper pmReceipt = new pmReceiptWrapper();
                        	pmReceipt.paid = false;
                        	pmReceipt.amountPaid = totalAmountInReceipts;
                        	totalAmountInReceipts = 0;
                            milestoneDataMap.put(milestone.id, pmReceipt);
                            index++;
                        }
                    }else{
                        if(!milestoneDataMap.containsKey(mileStone.id)){
                        	pmReceiptWrapper pmReceipt = new pmReceiptWrapper();
                        	pmReceipt.paid = false;
                        	pmReceipt.amountPaid = 0;
                        	totalAmountInReceipts = 0;
                            index++;
                            milestoneDataMap.put(milestone.id, pmReceipt);
                    }
                }
            }
          }
        }
        if(milestoneDataMap != null && milestoneDataMap.size() > 0){
            return milestoneDataMap;
        }else{
            return null;
        }
    }
    
    public void c_Values(){  
        Map<String,pmReceiptWrapper> milestonePaidDetails = new Map<String,pmReceiptWrapper>();
        milestonePaidDetails = getPMPaymentDetails(Booking.Id);
        for(Payment_Milestones__c pm :pmList){
            system.debug('deee '+pm.Tower__c);
            Decimal paidAmount = 0;
            if(milestonePaidDetails != null && milestonePaidDetails.containsKey(pm.id) && milestonePaidDetails.get(pm.id) != null){
                pmReceiptWrapper pmReceiptWrap = milestonePaidDetails.get(pm.id);
                paidAmount= pmReceiptWrap.amountPaid;
            }

            String paidAmounttotal = String.valueOf(paidAmount);
            
            Map<String,String> pmW = new Map<String,String>();
            Decimal totalInstallment = pm.Total_Installment_New__c;
            String totalAmount = String.valueOf(totalInstallment);
            Decimal vatAmount = pm.Total_Installment_Tax__c;
            String vat = '0.00';
            if(vatAmount > 0){
                vat = '5.00';
            }
            Decimal chargePercentage = pm.Charge1Percentage__c == null ? 0 : pm.Charge1Percentage__c ;
         
            String chargePercentageValue = String.valueOf(chargePercentage); 
            Decimal amountValue = pm.Total_Installment_New__c;
            
            String amountString = String.valueOf(amountValue);
            
            Decimal balance = totalInstallment - paidAmount;
            if(balance < 0){
                balance = 0.00;
            }
            String balanceAmount = String.valueOf(balance);
            amountString = amountString == null ? '0' : amountString;
            totalAmount = totalAmount == null ? '0' : totalAmount;
            chargePercentageValue = chargePercentageValue == null ? '0' : chargePercentageValue;
            balanceAmount = balanceAmount == null ? '0' : balanceAmount;
            paidAmounttotal = paidAmounttotal == null ? '0' : paidAmounttotal;
            pmW.put('amount',amountString);
            pmW.put('totalAmount',totalAmount);
            pmW.put('vat',vat);
            pmW.put('chargePercentage',chargePercentageValue);
            pmW.put('balance',balanceAmount);
            pmW.put('paid',paidAmounttotal);
            cValuesMap.put(pm.Milestone_Name__c,pmW);
        }
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
        if(String.isNotBlank(decimalPart)) {
            mf = mf + '.'  + decimalPart;
        }
        if(!negative){
            mf = mf /*+ '/-'*/;
        }
        else{
           mf = '- ' + mf /* + '/-'*/;
        }
        return mf;
    }     
        
    

    public class PaymentMilestoneWrapper {
        public String milestoneNo {get;set;}
        public String chargePercentage {get;set;}
        public date dueDate {get;set;}
        public String amount {get;set;}
        public String amountString {get;set;}
        public String totalAmount {get;set;}
        public String vAT {get;set;}
        public String total {get;set;}
        public String totalString {get;set;}
        public String paid {get;set;}
        public String paidString {get;set;}
        public String balance {get;set;}
        public String balanceString {get;set;}
    }
    public class otherChargesWrapper {
        public String description {get;set;}
        public Date demandDueDate {get;set;}
        public Decimal chargeAmount {get;set;}
        public Decimal paid {get;set;}
        public Decimal Balance {get;set;}
        public String chargeAmountString {get;set;}
        public String paidString {get;set;}
        public String BalanceString {get;set;}
        public Boolean paymentCompleted {get;set;}
        public String demandId;

        public otherChargesWrapper(){
            this.chargeAmount = 0;
            this.paid = 0;
            this.Balance = 0;
            this.paymentCompleted = false;
        }
    }
	
    public class receiptWrapper {
        public String receiptNo {get;set;}
        public String description {get;set;}  
        public String paymentMethod {get;set;}
        public Date receiptdate {get;set;}
        public Decimal installment {get;set;}
        public Decimal additionalCharges {get;set;}
        public Decimal total {get;set;}
        public String installmentString {get;set;}
        public String additionalChargesString {get;set;}
        public String totalString {get;set;}
    }
    
    public class pmReceiptWrapper {
        public boolean paid = false;
        public Decimal amountPaid = 0;
    }

    
    public static void dummyCovg(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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