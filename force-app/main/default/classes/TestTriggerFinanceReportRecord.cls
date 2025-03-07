@isTest
public class TestTriggerFinanceReportRecord {
    @isTest
    public static void frrCreation() {
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        //Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        //pm1.Charge_1_Lookup__c = projCharges;
        //update pm1;     
        
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
        insert rq;
        rq.Status_New__c = 'Approved';
		update rq;
		
		/* Receipt__c rrq = new Receipt__c();
        rrq.Cheque_DD_Amount_Rs__c = 20000000;
        rrq.Cheque_DD__c = '908888';
        rrq.Cheque_DD_Date__c = system.today();
        rrq.Project__c = projectId;
        rrq.Project_Unit__c = unitId;
        rrq.Opportunity__c = oppId;
        rrq.CheckReceipt__c = true;
        rrq.Token_Amount_Receipt__c = true;
        rrq.Physically_Cheque_Received__c = true;
        rrq.Approval_Status__c = 'Approved';
        rrq.Receipt_Date__c = system.today();
        rrq.DraweeBank__c = 'Axis Bank';
        rrq.Total_Amount__c = 20000000;
        rrq.Amount_Rs__c = 20000000;
        rrq.Amount_Advanced__c = 0;
        rrq.mode__c = 'Cheque';
        rrq.Currency__c = 'AED';
        rrq.Booking__c = b.Id;
        //r1.Mode__c='Credit Note';
        rrq.Receipt_Status__c = 'UnProcessed';
        rrq.Requester__c = rq.Id;
        insert rrq;
        
        PageReference pref = Page.PrintReceiptSobhaDubai;       
		pref.getParameters().put('id',rrq.id);
		Test.setCurrentPage(pref);
		
		ApexPages.StandardController con = new ApexPages.StandardController(rrq);
		PrintReceipt mycon = new PrintReceipt();*/
		
		
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
        //r1.Mode__c='Credit Note';
        r1.Receipt_Status__c = 'Cleared';
        insert r1;
        
        Test.startTest();
        Account_Master__c a = new Account_Master__c();
        a.Name = 'test123';
        insert a;
        
        Demand__c d = new Demand__c();
        d.Booking__c = b.id;
        //d.Debit_Type__c = 'Cheque Bounce';
        d.Total_Amount_Demanded__c = 500;
        d.Total_Amount_Paid__c=500;
        d.Debit_Demanded__c =500;
        d.Debit_Paid__c =500;
        d.Total_Amount_Account__c = a.Id;
        insert d;
       
        List<Demand__c> drec = [select id,Debit_Type__c,Total_Amount_Demanded__c,Total_Amount_Account__c FROM Demand__c limit 1];
       
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=r1.id;       
        insert fr1;
        
        Finance_Report_Records__c fr2 = new Finance_Report_Records__c();
        fr2.Demand__c =drec[0].id;
        insert fr2;
        system.debug('i am fr1'+fr1.Document_Category_New__c);
        system.debug('i am fr2'+fr2);

        d.Debit_Type__c = 'Cheque Bounce';
        update d;
        
        r1.Receipt_Status__c = 'Cleared';
        update r1;
        
        List<Finance_Report_Records__c> frrList = [SELECT ID FROM Finance_Report_Records__c LIMIT 2];
        List<Id> frrIdsList = new List<Id>();
        for(Finance_Report_Records__c f : frrList){
            frrIdsList.add(f.id);
        }
        TriggerFinanceReportRecordHandler.UpdateFRR(frrIdsList);
       Test.stopTest();
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
    
    @isTest public static void test_sendreceiptcontroller(){
        
        Profile prof = [select id from profile where name LIKE '%System Administrator%' LIMIT 1];
        User usr = new User();
        usr.firstName = 'test1';
        usr.lastName = 'test2';
        usr.profileId = prof.id;
        usr.Alias = 'sdffer';
        usr.username = 'testsdncbjdsc@test.com';
        usr.email = 'testcdscdvcdv@test.com';
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
        
        PageReference myVfPage = Page.Sendreceipt;
        Test.setCurrentPage(myVfPage);
        
        ApexPages.currentPage().getParameters().put('id',r1.Id);
        sendreceiptcontroller ac = new sendreceiptcontroller();
        ac.sendAttachedReceipt();
        Receipt__c receiptdetails = [select name,id,Currency__c,Booking__r.Tower__c,Booking__r.Name,Requester__r.Requested_User__r.email,Requester__r.Requester_Manager_Email__c,Requester__r.Owner.email,Requester__r.name,Requester__r.Owner.Name,Project_Unit__r.Name,Total_Amount__c,Receipt_No__c from Receipt__c where Id=:r1.Id];
        sendreceiptcontroller.sendAttachedReceipt1(r1);
    }
    
    @isTest public static void test_printReceiptcontroller(){
        
        Profile prof = [select id from profile where name LIKE '%System Administrator%' LIMIT 1];
        User usr = new User();
        usr.firstName = 'test1';
        usr.lastName = 'test2';
        usr.profileId = prof.id;
        usr.Alias = 'sdffer';
        usr.username = 'testsdncbjdsc@test.com';
        usr.email = 'testcdscdvcdv@test.com';
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
        Test.startTest();
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
        
        PageReference pref = Page.PrintReceiptSobhaDubai;       
		pref.getParameters().put('id',r1.id);
		Test.setCurrentPage(pref);
		
		ApexPages.StandardController con = new ApexPages.StandardController(r1);
		PrintReceipt mycon = new PrintReceipt();
        Test.stopTest();
    }
}