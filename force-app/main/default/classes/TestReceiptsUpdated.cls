@isTest
public  Class TestReceiptsUpdated{
    
    @isTest
    public static void testReceiptAmountUpdate() {
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges;    
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Current_Status__c = 'Audit Accepted';
        insert b;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 20000000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 20000000;
        r1.Amount_Rs__c = 20000000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Currency__c = 'AED';
        r1.Booking__c = b.Id;
        insert r1;
        
        pm1.Milestone_Due_Date__c = Date.today()-30;
        update pm1; 
        
        r1.Receipt_Status__c = 'Cleared';
        update r1;
    }
    
    @isTest
    private static void receiptApportion() {
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges;
        update pm1;     
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
        
        List<Receipt__c> receiptsList = new List<Receipt__c>();
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 20000000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 20000000;
        r1.Amount_Rs__c = 20000000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Currency__c = 'AED';
        r1.Booking__c = b.Id;
        //insert r1;
        receiptsList.add(r1);
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = oppId;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 8400;
        r2.Amount_Rs__c = 8400;
        r2.Amount_Advanced__c = 0;
        r2.mode__c = 'TDS';
        r2.Currency__c = 'AED';
        r2.Booking__c = b.Id;
        //insert r2;
        receiptsList.add(r2);
        
        Receipt__c r3 = new Receipt__c();
        r3.Cheque_DD_Amount_Rs__c = 8400;
        r3.Cheque_DD__c = '9088881';
        r3.Cheque_DD_Date__c = system.today();
        r3.Project__c = projectId;
        r3.Project_Unit__c = unitId;
        r3.Opportunity__c = oppId;
        r3.CheckReceipt__c = true;
        r3.Physically_Cheque_Received__c = true;
        r3.Approval_Status__c = 'Approved';
        r3.Receipt_Date__c = system.today();
        r3.DraweeBank__c = 'Axis Bank';
        r3.Total_Amount__c = 8400;
        r3.Amount_Rs__c = 8400;
        r3.Amount_Advanced__c = 0;
        r3.mode__c = 'Credit Note';
        r3.Currency__c = 'AED';
        r3.Booking__c = b.Id;
        //insert r3;
        receiptsList.add(r3);
        
        insert receiptsList;
        
        b.Receipts__c = r1.Id;
        update b;
        
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'Third Man1';
        a1.Applicant_Number__c = 'Third Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.City__c = 'Nagpur';
        a1.Mailing_Country__c= null;
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        insert a1;
        
        quote.Booking__c = b.Id;
        update quote;
        
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = oppId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:oppId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.Unit__c = unitId;
        o.Primary_Name__c = 'test';
        o.Booking__c = b.Id;
        update o;
        
        pm1.Collection_Status__c = 'Submitted';
        pm1.Finance_Status__c = 'Accepted';
        pm1.Audit_Status__c = 'Accepted';
        pm1.CFO_Status__c = 'Accepted';
        update pm1;
        
        List<Payment_Milestones__c> pmList = [Select Id from Payment_Milestones__c where Quotation__c = :quote.Id 
                                              and Milestone_Type__c = 'Construction Linked' order by createdDate desc];
        List<Payment_Milestones__c> updatePmList  = new List<Payment_Milestones__c> ();
        if(pmList != null && pmList.size() > 0){
            for(Payment_Milestones__c pm : pmList){
                pm.Demand_Raised__c = true;
                pm.Milestone_Due_Date__c = Date.today();
                updatePmList.add(pm);
            }
            update updatePmList;
        } 
        
        Test.startTest();     
        PageReference SendDemand = Page.SendDemand;
        Test.setCurrentPage(SendDemand);
        Demands d = new Demands();                   
        
        ApexPages.currentPage().getParameters().put('towerName','Tower X');
        ApexPages.currentPage().getParameters().put('projectName','Test Project');
        d.getCustomersTowerWise();
        DemandManagementServices.raiseGroupDemandNew(unitId, null);
        List<Demand__c> dList = [Select Id, Debit_Tax_Demanded__c, Debit_Tax_Paid__c, Total_Amount_Demanded__c, 
                                 Total_Amount_Balance__c, Agreement_Value_Demanded_New__c, Charge_1_Demanded__c, Charge_1_Balance__c, 
                                 Charge_1_Lookup__c, Charge_1_Lookup__r.ChargeBucket__c, Debit_Type__c from demand__c];
        dList[0].Debit_Tax_Demanded__c = 4000;
        dList[0].Debit_Tax_Paid__c = 3000;
        dList[0].Total_Amount_Demanded__c = 100000;
        dList[0].Agreement_Value_Demanded_New__c = 100000;
        dList[0].Charge_1_Demanded__c = 100000;
        dList[0].Debit_Type__c = 'DLD Charges';
        
        update dList;   
        PageReference recMod = Page.ReceiptModule;
        Test.setCurrentPage(recMod);
        ApexPages.currentPage().getParameters().put('id',r1.id);
        ReceiptModule recM = new ReceiptModule(); 
        for(String og : recM.outstandingChargesMap.keySet()) {
            for(PaymentManagementServices.DemandFieldLocationWrapper dl : recM.outstandingChargesMap.get(og)) {                    
                dl.rd.put(dl.fieldNametoBePaid, (Decimal) dl.d.get(dl.fieldNameO) );
                dl.rd.put(dl.fieldNametoBePaidT, (Decimal) dl.d.get(dl.fieldNameOT) );
            }
        } 
        
        Receipt_Details__c rd = new Receipt_Details__c();
        rd.Status__c = 'Valid';
        rd.Transaction_Date__c = system.today();
        rd.Demand__c = dList[0].Id;
        rd.Total_Amount_Apportined__c = 100000; 
        rd.Total_Tax_Apportioned__c = 10000;
        rd.Charges_Apportioned__c = 10000;
        rd.Taxes_Apportioned__c = 10000;
        rd.Receipts__c = r1.Id;
        rd.Interest_Amount_Paid__c = 1000;
        rd.Tax_on_Interest_Paid__c = 1000;
        rd.Interest_Amount_Waived__c = 500;
        rd.Tax_On_Interest_Waived__c = 500;
        rd.Debit_Tax_Apportioned__c = 10000;
        rd.Charge_1_Amount_Apportioned__c = 10000;
        rd.Charge_1_Tax_Apportioned__c = 1000;
        rd.Charge_2_Amount_Apportioned__c = 10000;
        rd.Charge_2_Tax_Apportioned__c = 1000;
        
        recM.applyReceipt();     
        recM.saveReceipt(); 
        insert rd;
        
        List<Receipt_Details__c> rdList1 = [select id from Receipt_Details__c];
        recM.advanceReceipt();        
        
        /*PageReference lPage = Page.S_PrintLedger;
Test.setCurrentPage(lPage);
ApexPages.currentPage().getParameters().put('id', oppId);
S_PrintLedgerController lprint = new S_PrintLedgerController();
//paymentmanagement has a get on account money with oppId List
List<Id> oppIdList = new list<Id>();
oppIdList.add(oppId);
PaymentManagementServices.getOnAccountMoney(oppIdList);
List<Receipt_Details__c> rdList = [select id from Receipt_Details__c];
rdList[0].Debit_Amount_Apportioned__c = 1000;
update rdList[0];
delete rdList[0];
undelete rdList[0];*/
        Test.stopTest();   
    }
    
    @isTest
    private static void receiptApprtionment2 () {
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');  
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);           
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;           
        
        list<Receipt__c> rList = new list<Receipt__c>();
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 20000000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 20000000;
        r1.Amount_Rs__c = 20000000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Booking__c= b.Id;
        r1.Currency__c = 'AED';
        rList.add(r1);
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 0;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = oppId;
        r2.Physically_Cheque_Received__c = true;
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 0;
        r2.Amount_Rs__c = 0;
        r2.Amount_Advanced__c = 0;
        r2.Booking__c= b.Id;
        r2.mode__c = 'TDS';
        r2.Currency__c = 'AED';
        r2.Receipt_Status__c = 'Physical Verification Rejected';
        rList.add(r2);
        
        Receipt__c r3 = new Receipt__c();
        r3.Cheque_DD_Amount_Rs__c = 8400;
        r3.Cheque_DD__c = '9088881';
        r3.Cheque_DD_Date__c = system.today();
        r3.Project__c = projectId;
        r3.Project_Unit__c = unitId;
        r3.Opportunity__c = oppId;
        r3.CheckReceipt__c = true;
        r3.Physically_Cheque_Received__c = true;
        r3.Approval_Status__c = 'Approved';
        r3.Receipt_Date__c = system.today();
        r3.DraweeBank__c = 'Axis Bank';
        r3.Total_Amount__c = 8400;
        r3.Amount_Rs__c = 8400;
        r3.Amount_Advanced__c = 0;
        r3.mode__c = 'Credit Note';
        r3.Booking__c= b.Id;
        r3.Currency__c = 'AED';
        rList.add(r3);
        insert rList;
        
        b.Receipts__c = r1.Id;
        update b;
        
        Test.startTest();
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'Third Man1';
        a1.Applicant_Number__c = 'Third Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.City__c = 'Nagpur';
        a1.Mailing_Country__c= null;
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';       
        insert a1;
        
        quote.Booking__c = b.Id;
        update quote;
        
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = oppId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:oppId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.Unit__c = unitId;
        o.Primary_Name__c = 'test';
        o.Other_Applicants_Name__c = 'test';
        update o;
        
        pm1.Collection_Status__c = 'Submitted';
        pm1.Finance_Status__c = 'Accepted';
        pm1.Audit_Status__c = 'Accepted';
        pm1.CFO_Status__c = 'Accepted';
        update pm1;
        
        
        PageReference recMod = Page.ReceiptModule;
        Test.setCurrentPage(recMod);
        ApexPages.currentPage().getParameters().put('id',r2.id);
        ReceiptModule recM = new ReceiptModule();                
        recM.applyReceipt();     
        recM.advanceReceipt();           
        Test.stopTest();   
    }
    
    @isTest
    private static void receiptApportion3() {
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId = recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);           
        
        Payment_Milestones__c pm1 = createPaymentMilestone (quote.Id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
        
        list<Receipt__c> rList = new list<Receipt__c>();
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 20000000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 20000000;
        r1.Amount_Rs__c = 20000000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Currency__c = 'AED';
        r1.Booking__c = b.Id;
        rList.add(r1);
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = oppId;
        r2.Physically_Cheque_Received__c = true;
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 8400;
        r2.Amount_Rs__c = 8400;
        r2.Amount_Advanced__c = 0;
        r2.mode__c = 'Cheque';
        r2.Currency__c = 'AED';
        r2.Booking__c = b.Id;
        rList.add(r2);  
        insert rList;
        
        b.Receipts__c = r1.Id;
        update b;
        
        Test.startTest();
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'Third Man1';
        a1.Applicant_Number__c = 'Third Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.City__c = 'Nagpur';
        a1.Mailing_Country__c= null;
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';       
        insert a1;
        
        quote.Booking__c = b.Id;
        update quote;
        
        Unit__c u = [Select Id, Name, Unit_Status__c, Customers__c, Booking__c   from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = oppId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName, unit__c, Booking__c from Opportunity where id =:oppId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.unit__c = unitId;
        o.Booking__c = b.Id;
        update o;  
        
        pm1.Collection_Status__c = 'Submitted';
        pm1.Finance_Status__c = 'Accepted';
        pm1.Audit_Status__c = 'Accepted';
        pm1.CFO_Status__c = 'Accepted';
        update pm1;      
        
        PageReference SendDemand = Page.SendDemand;
        Test.setCurrentPage(SendDemand);
        Demands d = new Demands();
        
        ApexPages.currentPage().getParameters().put('towerName','Tower X');
        ApexPages.currentPage().getParameters().put('projectName','Test Project');
        d.getCustomersTowerWise();
        DemandManagementServices.raiseGroupDemandNew(unitId, null);
        List<Demand__c> dList = [Select Id from demand__c];
        
        PageReference recMod = Page.ReceiptModule;
        Test.setCurrentPage(recMod);
        ApexPages.currentPage().getParameters().put('id',r1.id);
        ReceiptModule recM = new ReceiptModule(); 
        for(String og : recM.outstandingChargesMap.keySet()) {
            for(PaymentManagementServices.DemandFieldLocationWrapper dl : recM.outstandingChargesMap.get(og)) {
                dl.rd.put(dl.fieldNametoBePaid, (Decimal) dl.d.get(dl.fieldNameO) );
                dl.rd.put(dl.fieldNametoBePaidT, (Decimal) dl.d.get(dl.fieldNameOT) );
            }
        } 
        
        recM.saveReceipt(); 
        recM.advanceReceipt();
        PageReference lPage = Page.S_PrintLedger;
        Test.setCurrentPage(lPage);
        ApexPages.currentPage().getParameters().put('id', oppId);
        S_PrintLedgerController lprint = new S_PrintLedgerController();
        //paymentmanagement has a get on account money with oppId List
        List<Id> oppIdList = new list<Id>();
        oppIdList.add(oppId);
        PaymentManagementServices.getOnAccountMoney(oppIdList);
        List<Receipt_Details__c> rdList = [select id from Receipt_Details__c];
        Test.stopTest();   
    }
    
    @isTest
    private static void createReceipt() {
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Quotation__c qController = new Quotation__c();
        
        qController.Opportunity__c = oppId;
        qController.Unit__c = unitId;
        qController.Payment_Plan__c = recordMap.get('PLAN');
        qController.Quote_Status__c = 'Valid';
        insert qController;
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Quotation__c = qController.id;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Invoice_Date__c = system.today().addDays(5);
        pm.Invoice_Due_Date__c = system.today().addDays(5);
        insert pm;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = qController.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        insert b;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Amount_Rs__c = 200000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Currency__c = 'Indian Rupee';
        r1.On_Account_Money__c = 200000;
        r1.Booking__c = b.Id;
        insert r1;
        
        b.Receipts__c = r1.Id;
        update b;              
        
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'Third Man1';
        a1.Applicant_Number__c = 'Third Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.City__c = 'Nagpur';
        a1.Mailing_Country__c= null;
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Purchaser';
        a1.Subtype_Of_Applicant__c = 'UAE Resident';    
        insert a1;
        
        qController.Booking__c = b.Id;
        update qController;
        
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = oppId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:oppId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.Unit__c = unitId;
        o.Primary_Name__c = 'newman';
        o.Other_Applicants_Name__c = 'newman2';
        update o;
        
        /*  Tax_Slab__c ts = new Tax_Slab__c();
ts.Tax_Name__c = 'Purchase Price - VAT 5%';
ts.Tax1_Name__c = 'CGST';
ts.Tax1_Percentage__c = 5;
ts.Taxable1_Percentage__c = 100;
ts.Tax2_Name__c = 'SGST';
ts.Tax2_Percentage__c = 0;
ts.Taxable2_Percentage__c = 100;
ts.Tax_Rate__c = 'VAT 5%';
ts.From_Date__c = System.today().addDays(100);
insert ts;*/
        
        Account_Master__c a = new Account_Master__c();
        a.Name = 'Cash';
        a.Account_Number__c = '123456';
        a.Type__c = 'Others';
        insert a;
        
        Account_Master__c a12 = new Account_Master__c();
        a12.Name = 'Trade Receivable';
        a12.Account_Number__c = '213456';
        a12.Type__c = 'Others';
        insert a12;
        
        Account_Master__c a11 = new Account_Master__c();
        a11.Name = 'Vat 5% Payable';
        a11.Account_Number__c = '123456';
        a11.Type__c = 'VAT';
        a11.Tax_Rate__c = 'VAT 5%';
        insert a11;
        
        PageReference cNewReceipt = Page.CreateNewReceipt;
        Test.setCurrentPage(cNewReceipt);
        ApexPages.currentPage().getParameters().put('id',r1.id);
        
        Test.startTest();
        PageReference cNewReceipt2 = Page.CreateNewReceipt;
        Test.setCurrentPage(cNewReceipt2);
        ApexPages.currentPage().getParameters().put('OptyId',oppId);
        
        CreateNewReceiptController recNew2 = new CreateNewReceiptController();   
        
        recNew2.rmw.r.Project__c = projectId;
        recNew2.rmw.r.Project_Unit__c = unitId;
        recNew2.unitSelectionValidation();
        recNew2.rmw.r.Mode__c = 'Cheque';
        recNew2.selectInstrument();
        recNew2.rmw.r.Receipt_Date__c = system.today();
        recNew2.rmw.r.Cheque_DD_Date__c = system.today();
        recNew2.rmw.r.DraweeBank__c = 'Axis Bank';
        recNew2.rmw.r.Cheque_DD__c = '908888';
        recNew2.rmw.r.Currency__c = 'Indian Rupee';
        recNew2.rmw.r.Amount_Rs__c = 10000;
        recNew2.rmw.r.RemarksText__c = 'test';
        recNew2.checkDupeList();
        recNew2.rmw.r.DraweeBank__c = 'Other';
        recNew2.rmw.r.Cheque_DD__c = '90888';
        recNew2.rmw.r.Receipt_Date__c = system.today().addDays(10);
        recNew2.rmw.r.Cheque_DD_Date__c = system.today().addDays(10);
        recNew2.applyReceipt();
        
        CreateNewReceiptController recNew3 = new CreateNewReceiptController();  
        recNew3.rmw.r.Project__c = projectId;
        recNew3.rmw.r.Project_Unit__c = unitId;
        recNew3.unitSelectionValidation();
        recNew3.rmw.r.Mode__c = 'Credit Note';
        recNew3.rmw.r.Amount_Rs__c = 10000;
        //  recNew3.accName = 'Cash';
        recnew3.rmw.r.Tax_Rate__c = 'VAT 5%';
        recnew3.rmw.r.Credit_Note_Amount__c = 100000;
        recNew3.rmw.r.Currency__c = 'Indian Rupee';
        recNew3.applyReceipt();
        
        recNew3.rmw.r.mode__c = 'Credit Card';
        recNew3.selectInstrument();   
        recNew2.rmw.r.mode__c = 'Credit Note';
        recNew2.selectInstrument();    
        recNew2.rmw.r.Mode__c = 'Cheque';
        recNew2.rmw.r.Currency__c = 'US Dollar';
        recNew2.applyReceipt();
        recNew2.rmw.r.Receipt_Date__c = system.today();
        recNew2.rmw.r.Cheque_DD_Date__c = system.today();
        recNew2.rmw.r.Mode__c = 'Cheque';
        recNew2.applyReceipt();   
        
        PageReference debitNote = Page.CreateDebitNote;
        Test.setCurrentPage(debitNote);
    	ApexPages.currentPage().getParameters().put('OptyId',o.id);
        CreateDebitNote db = new CreateDebitNote();
        db.d.Unit__c = unitId;
        db.d.Project__c = projectId;
        db.d.Booking__c = b.id;
        db.d.Quotation__c = qController.Id;
        db.unitSelectionValidation();
        db.d.Debit_Type__c = 'Cheque Bounce';
        db.d.Tax_Rate__c = 'VAT 5%';
        db.accName = 'Cash';
        db.d.Payment_Term__c = '10';
        db.d.Debit_Demanded__c = 100000;
        db.saveDebitNote();
        
        Test.stopTest();
        PageReference printReceipt = Page.S_PrintReceiptV2;
        Test.setCurrentPage(printReceipt);
        ApexPages.currentPage().getParameters().put('id',r1.id);
        PrintReceipt pr = new PrintReceipt();          
    }
    
    public static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
        
        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp ;
        objQuote1.Payment_Plan__c = pp ;
        objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        
        objQuote1.Charge3Bucket__c = 'Agreement Value';
        objQuote1.Charge3Name__c = 'PLC';
        objQuote1.Charge3Value__c = 1123;
        
        objQuote1.Charge4Bucket__c = 'Other Charges';
        objQuote1.Charge4Name__c = 'test';
        objQuote1.Charge4Value__c = 1123;
        objQuote1.Final_Approved_Date__c = System.today();
        insert objQuote1;
        return objQuote1;
    } 
    
    private static Payment_Milestones__c createPaymentMilestone(Id quote) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 100000;          
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 2475;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm;        
        return pm;                  
    }             
}