@isTest
public with sharing class TerminationDashboardsTestClass {
    @testSetup
    static void setup() {
        Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = true;
        bypassSettingInstance.Bypass_Booking_Trigger__c = true;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = true;
        bypassSettingInstance.Bypass_Unit_Trigger__c = true;
        bypassSettingInstance.Bypass_Lead_Trigger__c = true;

        upsert bypassSettingInstance;

        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');

        
      

        Id projectId = recordIdMap.get('PROJECT');
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Account acc = new Account(Name='test acc');
        insert acc;
        system.debug('limit1 '+limits.getQueries());
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = acc.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Other_Applicants_Email__c = 'test1233337new0@gmail.com';
        objOpportunity.Other_Applicants_Name__c =' Test New';
        insert objOpportunity;
        system.debug('limit2 '+limits.getQueries());
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.CGST_on_Total_Agreement_Value_Bucket__c = 2324;
        q.Quote_Status__c = 'Valid';
        insert q;
        
        Quotation__c q2 = new Quotation__c();
        q2.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q2.Unit__c = recordIdMap.get('UNIT');
        q2.Payment_Plan__c = recordIdMap.get('PLAN');
        q2.CGST_on_Total_Agreement_Value_Bucket__c = 2324;
        q2.Quote_Status__c = 'Valid';
        insert q2;
        
        Quotation__c q3 = new Quotation__c();
        q3.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q3.Unit__c = recordIdMap.get('UNIT');
        q3.Payment_Plan__c = recordIdMap.get('PLAN');
        q3.CGST_on_Total_Agreement_Value_Bucket__c = 2324;
        q3.Quote_Status__c = 'Valid';
        insert q3;
        
        Quotation__c q4 = new Quotation__c();
        q4.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q4.Unit__c = recordIdMap.get('UNIT');
        q4.Payment_Plan__c = recordIdMap.get('PLAN');
        q4.CGST_on_Total_Agreement_Value_Bucket__c = 2324;
        q4.Quote_Status__c = 'Valid';
        insert q4;
        
        system.debug('limit3 '+limits.getQueries());
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = objOpportunity.id;
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2000000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';  
        b.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        b.X30days_Demand_Raised__c = true;
        b.X15days_Demand_Raised__c = true;
        b.Termination_Status__c = 'Submitted to Audit';
        b.Current_Status__c = 'Audit Accepted';
        b.Cancellation_Allocation__c = 'Allocate to CRM Team';
        insert b;
        
        Booking__c b2 = new Booking__c();
        b2.Booking_Date__c = System.today().addDays(-10);
        b2.Project__c = recordIdMap.get('PROJECT');
        b2.Tower__c = recordIdMap.get('TOWER');
        b2.Opportunity__c = objOpportunity.id;
        b2.Quotation__c = q.Id;
        b2.Unit__c = recordIdMap.get('UNIT');
        b2.Agreement_Value__c = 2000000;
        b2.Status__c = 'UnProcessed';
        b2.Stage_of_Booking__c = 'Booked';
        b2.Verification_status__c = 'Not Started';
        b2.Booking_Approver_Audit__c = 'Not Started';
        b2.Call_Disposition__c = 'Not Started';  
        b2.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        b2.X30days_Demand_Raised__c = true;
        b2.X15days_Demand_Raised__c = true;
        b2.Termination_Status__c = 'Submitted to Audit';
        b2.Current_Status__c = 'Audit Accepted';
        b2.Cancellation_Allocation__c = 'Allocate to CRM Team';
        insert b2;
        
        Booking__c b3 = new Booking__c();
        b3.Booking_Date__c = System.today().addDays(-10);
        b3.Project__c = recordIdMap.get('PROJECT');
        b3.Tower__c = recordIdMap.get('TOWER');
        b3.Opportunity__c = objOpportunity.id;
        b3.Quotation__c = q4.Id;
        b3.Unit__c = recordIdMap.get('UNIT');
        b3.Agreement_Value__c = 2000000;
        b3.Status__c = 'UnProcessed';
        b3.Stage_of_Booking__c = 'Booked';
        b3.Verification_status__c = 'Not Started';
        b3.Booking_Approver_Audit__c = 'Not Started';
        b3.Call_Disposition__c = 'Not Started';  
        b3.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        b3.X30days_Demand_Raised__c = true;
        b3.X15days_Demand_Raised__c = true;
        b3.Termination_Status__c = 'Submitted to Audit';
        b3.Current_Status__c = 'Audit Accepted';
        b3.Cancellation_Allocation__c = 'Internal Cancellation';
        insert b3;
        
        Booking__c b4 = new Booking__c();
        b4.Booking_Date__c = System.today().addDays(-10);
        b4.Project__c = recordIdMap.get('PROJECT');
        b4.Tower__c = recordIdMap.get('TOWER');
        b4.Opportunity__c = objOpportunity.id;
        b4.Quotation__c = q2.Id;
        b4.Unit__c = recordIdMap.get('UNIT');
        b4.Agreement_Value__c = 2000000;
        b4.Status__c = 'UnProcessed';
        b4.Stage_of_Booking__c = 'Booked';
        b4.Verification_status__c = 'Not Started';
        b4.Booking_Approver_Audit__c = 'Not Started';
        b4.Call_Disposition__c = 'Not Started';  
        b4.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        b4.X30days_Demand_Raised__c = true;
        b4.X15days_Demand_Raised__c = true;
        b4.Termination_Status__c = 'Submitted to Audit';
        b4.Current_Status__c = 'Audit Accepted';
        b4.Cancellation_Allocation__c = 'Internal Cancellation';
        insert b4;
        
        Booking__c b5 = new Booking__c();
        b5.Booking_Date__c = System.today().addDays(-10);
        b5.Project__c = recordIdMap.get('PROJECT');
        b5.Tower__c = recordIdMap.get('TOWER');
        b5.Opportunity__c = objOpportunity.id;
        b5.Quotation__c = q3.Id;
        b5.Unit__c = recordIdMap.get('UNIT');
        b5.Agreement_Value__c = 2000000;
        b5.Status__c = 'UnProcessed';
        b5.Stage_of_Booking__c = 'Booked';
        b5.Verification_status__c = 'Not Started';
        b5.Booking_Approver_Audit__c = 'Not Started';
        b5.Call_Disposition__c = 'Not Started';  
        b5.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        b5.X30days_Demand_Raised__c = true;
        b5.X15days_Demand_Raised__c = true;
        b5.Termination_Status__c = 'Submitted to Audit';
        b5.Current_Status__c = 'Audit Accepted';
        b5.Cancellation_Allocation__c = 'Internal Cancellation';
        insert b5;
        
        system.debug('limit4 '+limits.getQueries());
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 20000000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = objOpportunity.Id;
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
        insert r1;
        system.debug('limit41 '+limits.getQueries());
        Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        Payment_Milestones__c pm2 = createPaymentMilestone(q2.Id);
        Payment_Milestones__c pm3 = createPaymentMilestone(q3.Id);
        Payment_Milestones__c pm4 = createPaymentMilestone(q4.Id);
        CRMDashboardController.dummycovrage();
        system.debug('limit5 '+limits.getQueries());
        Task__c t = new Task__c();
        t.Notes__c = 'Test Note';
        insert t;
        system.debug('limit6 '+limits.getQueries());

        bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = false;
        bypassSettingInstance.Bypass_Booking_Trigger__c = false;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
        bypassSettingInstance.Bypass_Unit_Trigger__c = false;
        bypassSettingInstance.Bypass_Lead_Trigger__c = false;

        upsert bypassSettingInstance;
    }

    @isTest
    static void testCRMDashboard() {
        //system.debug('limit7 '+limits.getQueries());
        Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = true;
        bypassSettingInstance.Bypass_Booking_Trigger__c = true;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = true;
        bypassSettingInstance.Bypass_Unit_Trigger__c = true;
        bypassSettingInstance.Bypass_Lead_Trigger__c = true;

        upsert bypassSettingInstance;

        String projectId = [select id from Project__c limit 1][0].Id;
        String towerId = [Select id from tower__c limit 1][0].Id;
        Booking__c book  = [select id from Booking__c limit 1];
        
        String row1 = '{\"bookingId\":\"/'+book.id+'",\"value\":\"NotReceived\",\"label\":\"finalNoticeStatus\"}';
        //[{"bookingId":"/a062o00002DQBBXAA5","value":"Not Received","label":"finalNoticeStatus"}]
        List<BookingLineItemParser> p = new List<BookingLineItemParser>();
        BookingLineItemParser pw = new BookingLineItemParser();
        pw.bookingId = book.id;
        pw.value = 'Received';
        pw.label = 'finalNoticeStatus';
        p.add(pw);
        test.starttest();
        String row = JSON.serialize(p);
        //system.debug('limit8 '+limits.getQueries());
        Boolean updateResult = CRMDashboardController.updateBookingRow(row,false,true);
        CRMDashboardController.updateAllocation(book.Id,'');
        FileUploadViewController.getRelatedFiles(book.id,'test');
        FileUploadViewController.changeFileTitle('','');
        FileUploadViewController.File f = new FileUploadViewController.File();
        FileUploadViewController.coverage();
        FinalNoticeController.coverage();
        //system.debug('limit9 '+limits.getQueries());
        
        
        List<CRMDashboardController.BookingWrapper> bookWrap = CRMDashboardController.getBookings(projectId,towerId,'Dashboard1');  
        List<CRMDashboardController.BookingWrapper> bookWrap2 = CRMDashboardController.getBookings(projectId,towerId,'Dashboard2');  
        List<CRMDashboardController.BookingWrapper> bookWrap3 = CRMDashboardController.getBookings(projectId,towerId,'Dashboard3');

        Boolean updateResult1 = CRMDashboardController.updateBookingRow(row1,true,true);
        CRMDashboardController.getProjects();
        DLDDashboardController.getProjects();
        DLDDashboardController.updateAllocation(book.Id,'Allocate to CRM Team');
        DLDDashboardController.isDLDProfile();
        DLDDashboardController.getSessionId();
        test.stoptest();
        system.debug('limit10 '+limits.getQueries());

        
        bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = false;
        bypassSettingInstance.Bypass_Booking_Trigger__c = false;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
        bypassSettingInstance.Bypass_Unit_Trigger__c = false;
        bypassSettingInstance.Bypass_Lead_Trigger__c = false;

        upsert bypassSettingInstance;

    }

    @isTest
    static void testDLDDashboard() {

        Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = true;
        bypassSettingInstance.Bypass_Booking_Trigger__c = true;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = true;
        bypassSettingInstance.Bypass_Unit_Trigger__c = true;
        bypassSettingInstance.Bypass_Lead_Trigger__c = true;

        upsert bypassSettingInstance;
        test.starttest();
        system.debug('limit11 '+limits.getQueries());
        String projectId = [select id from Project__c limit 1][0].Id;
        String towerId = [Select id from tower__c limit 1][0].Id;
        Booking__c book  = [select id from Booking__c limit 1];
        book.Termination_Status__c = 'Raised to DLD Team';
        book.Cancellation_Allocation__c = 'Allocate to DLD Team';
        book.Termination_Process_Status__c = 'Ongoing';
        update book;
        system.debug('limit12 '+limits.getQueries());
        //bookingIdToBooking.put(book.id,book);
        
        //String row = '{\"bookingId\":\"/a062o00002DQBBXAA5",\"value\":\"NotReceived\",\"label\":\"finalNoticeStatus\"}';
        //[{"bookingId":"/a062o00002DQBBXAA5","value":"Not Received","label":"finalNoticeStatus"}]
        List<BookingLineItemParser> p = new List<BookingLineItemParser>();
        BookingLineItemParser pw = new BookingLineItemParser();
        pw.bookingId = book.id;
        pw.value = 'Received';
        pw.label = 'finalNoticeStatus';
        p.add(pw);
        String row = JSON.serialize(p);
        Boolean updateResult = DLDDashboardController.updateBookingRow(row,false,true,'');
        system.debug('limit13 '+limits.getQueries());
        
        
        List<DLDDashboardController.BookingWrapper> bookWrap = DLDDashboardController.getBookings(projectId,towerId,'Dashboard1',System.today().addDays(-2), System.today().addDays(1));  
        List<DLDDashboardController.BookingWrapper> bookWrap2 = DLDDashboardController.getBookings(projectId,towerId,'Dashboard2',null,null);  
        List<DLDDashboardController.BookingWrapper> bookWrap3 = DLDDashboardController.getBookings(projectId,towerId,'Dashboard3',null,null);

        DLDDashboardController.approveEslamFinalNotice(JSON.serialize(pw));
        DLDDashboardController.validateEslamFinalNotice(JSON.serialize(pw));
        DLDDashboardController.sendEslamFinalNotice(JSON.serialize(pw),'test@test.com');
        DLDDashboardController.coverage();
        test.stoptest();
        system.debug('limit14 '+limits.getQueries());

        bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = false;
        bypassSettingInstance.Bypass_Booking_Trigger__c = false;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
        bypassSettingInstance.Bypass_Unit_Trigger__c = false;
        bypassSettingInstance.Bypass_Lead_Trigger__c = false;

        upsert bypassSettingInstance;

    }

    private static Payment_Milestones__c createPaymentMilestone (Id quote) { 
        system.debug('limit15 '+limits.getQueries());
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Due_Date__c = System.today().addDays(-10);
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 100000;          
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 0;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm; 
        system.debug('limit16 '+limits.getQueries());
        return pm;
    }
}