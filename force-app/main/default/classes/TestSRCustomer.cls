@IsTest public class TestSRCustomer {

    private static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
        
        
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
    
    @isTest public static void TestSRCustomerClass(){
        
        Profile prof = [select id from profile where name LIKE '%System Administrator%' LIMIT 1];
        User usr = new User();
        usr.firstName = 'test1';
        usr.lastName = 'test2';
        usr.profileId = prof.id;
        usr.Alias = 'sdffer';
        usr.username = 'testsdncbjdsc@test.com';
        usr.email = 'testcdscdvcdv@test.com';
        usr.Department__C = 'Finance';
        usr.TimeZoneSidKey = 'America/New_York';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId); 
        
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
        
        Requester__c rq = new Requester__c();
        rq.Booking__c =b.id;
        rq.Mode_Of__c = 'Cash';
        rq.Currency__c = 'AED';
        rq.Towards_Unit_Price_Amount__c = 1000.00;
        rq.Instrument_Number__c = 'abg566';
        rq.Total_Amount__c=1000;
        rq.OwnerId = usr.Id;
        insert rq;
        
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
        r1.Receipt_Status__c = 'Cleared';
        r1.Requester__c = rq.Id;
        insert r1;
        
        ExternalReferenceRegisterUtil.ERRCreationResult errCR = ExternalReferenceRegisterUtil.createExternalReference('Receipt',r1?.Id);
        ExternalReferenceRegisterUtil.createERR(errCR.err);
        
        PageReference myVfPage = Page.SRCustomer;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('erId',errCR.err.External_Reference__c);

        Test.startTest();
        SRCustomer src = new SRCustomer();
        src.captchaSucceeded();
        src.sendOtp();
        errCR.err = [SELECT Id,Internal_Reference__c,External_Reference__c,Entry_Creation_DateTime__c,Entry_Expiration_DateTime__c,Encryption_Key__c,Encryption_Key_Size__c,Verification_Code__c FROM External_Reference_Register__c WHERE id = :errCR.err.Id];
        src.enteredOtp = errCR.err.Verification_Code__c;
        src.verifyOtp();
        errCR.err.Entry_Expiration_DateTime__c = System.now().addDays(-1);
        update errCR.err;
        SchedulableContext sc;
        new ScheduledBatchERR_Deletion().execute(sc);
        Database.executeBatch(new ScheduledBatchERR_Deletion());
        Test.stopTest();
        
    }
    
    @isTest public static void TestQRUtility(){
        
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
        list<Receipt__c> rList = new list<Receipt__c>();    
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
        rList.add(r1);
        
        Receipt__c r6 = new Receipt__c();
        r6.Cheque_DD_Amount_Rs__c = 8400;
        r6.Cheque_DD__c = '9088881';
        r6.Cheque_DD_Date__c = system.today()+100;
        r6.Project__c = projectId;
        r6.Project_Unit__c = unitId;
        r6.Opportunity__c = oppId;
        r6.CheckReceipt__c = true;
        r6.Physically_Cheque_Received__c = true;
        r6.Approval_Status__c = 'Approved';
        r6.Receipt_Date__c = system.today()+200;
        r6.DraweeBank__c = 'Other';
        r6.Total_Amount__c = 8400;
        r6.Amount_Rs__c = 8400;
        r6.Amount_Advanced__c = 0;
        r6.mode__c = 'Cheque';
        r6.Currency__c = 'AED';
        r6.Booking__c = b.Id;
        rList.add(r6);
        insert rList;
        
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=r1.id;       
        insert fr1;
        
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
        ApexPages.currentPage().getParameters().put('OptyId',oppId);
        //ApexPages.currentPage().getParameters().put('OptyId',o.id);
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
        PrintReceiptV2 pr = new PrintReceiptV2();          
    }
    
    @isTest public static void TestPrintReceipt(){
        
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
        list<Receipt__c> rList = new list<Receipt__c>();    
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
        rList.add(r1);
        
        Receipt__c r6 = new Receipt__c();
        r6.Cheque_DD_Amount_Rs__c = 8400;
        r6.Cheque_DD__c = '9088881';
        r6.Cheque_DD_Date__c = system.today()+100;
        r6.Project__c = projectId;
        r6.Project_Unit__c = unitId;
        r6.Opportunity__c = oppId;
        r6.CheckReceipt__c = true;
        r6.Physically_Cheque_Received__c = true;
        r6.Approval_Status__c = 'Approved';
        r6.Receipt_Date__c = system.today()+200;
        r6.DraweeBank__c = 'Other';
        r6.Total_Amount__c = 8400;
        r6.Amount_Rs__c = 8400;
        r6.Amount_Advanced__c = 0;
        r6.mode__c = 'Cheque';
        r6.Currency__c = 'AED';
        r6.Booking__c = b.Id;
        rList.add(r6);
        insert rList;
        
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=r1.id;       
        insert fr1;
        
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
        ApexPages.currentPage().getParameters().put('OptyId',oppId);
        //ApexPages.currentPage().getParameters().put('OptyId',o.id);
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
}