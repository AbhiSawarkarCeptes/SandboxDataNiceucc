@isTest
public class TerminationDasboardControllerTest {
    
    @testSetup
    static void setup() {
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        Id projectId = recordIdMap.get('PROJECT');
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Account acc = new Account(Name='test acc');
        insert acc;
        
        Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = true;
        bypassSettingInstance.Bypass_Booking_Trigger__c = true;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = true;
        bypassSettingInstance.Bypass_Unit_Trigger__c = true;
        bypassSettingInstance.Bypass_Lead_Trigger__c = true;
        
        upsert bypassSettingInstance;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = acc.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Other_Applicants_Email__c = 'test1233337new0@gmail.com';
        objOpportunity.Other_Applicants_Name__c =' Test New';
        insert objOpportunity;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.CGST_on_Total_Agreement_Value_Bucket__c = 2324;
        q.Quote_Status__c = 'Valid';
        insert q;
        
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
        insert b;
        
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
        Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        
        Task__c t = new Task__c();
        t.Notes__c = 'Test Note';
        insert t;
        
        bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = false;
        bypassSettingInstance.Bypass_Booking_Trigger__c = false;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
        bypassSettingInstance.Bypass_Unit_Trigger__c = false;
        bypassSettingInstance.Bypass_Lead_Trigger__c = false;

        upsert bypassSettingInstance;
        
    }
    @isTest
    static void bookingListWithOverDueTest() {
        String projectId = [select id from Project__c limit 1][0].Id;
        String towerId = [Select id from tower__c limit 1][0].Id;
        Booking__c book  = [select id,Current_Status__c,Stage_of_Booking__c,Status__c,Under_cancellation__c,X30days_Demand_Raised__c,X15days_Demand_Raised__c from Booking__c limit 1];
        System.debug('book------'+book);
        List<TerminationDashboardController.BookingWrapper> bookWrap = TerminationDashboardController.bookingListWithOverDue(projectId,towerId,new List<String>{'Submitted to Audit'});  
        //System.assertEquals(book.Id,bookWrap[0].bookingIdVal);
    }
    @isTest
    static void bookingListWithOverDueForAllTowersTest() {
        String projectId = [select id from Project__c limit 1][0].Id;
        TerminationDashboardController.bookingListWithOverDue(projectId,'All',new List<String>{'Submitted to Audit'});  
        Booking__c book1 = [select id,Termination_Status__c from booking__c limit 1];
        //System.assertEquals('Submitted to audit', book1.Termination_Status__c);
    }
    @isTest
    static void submittedToAccountTest1() {
        Booking__c book = [select id from booking__c limit 1];
        TerminationDashboardController.submittedToAccount(new List<String>{book.Id}, 'Resubmitted to collections by audit', 'test', 'Audit','Audit'); 
        Booking__c book1 = [select id,Termination_Status__c from booking__c limit 1];
        //System.assertEquals('Resubmitted to collections by audit', book1.Termination_Status__c);
    }
    @isTest
    static void submittedToAccountTest2() {
        Booking__c book = [select id,Termination_Status__c from booking__c limit 1];
        book.Termination_Status__c = 'Resubmitted to collections by audit';
        update book;
        TerminationDashboardController.submittedToAccount(new List<String>{book.Id}, 'Resubmitted to collections by audit', 'test', 'collection','collection');   
        Booking__c book1 = [select id,Termination_Status__c from booking__c limit 1];
        //System.assertEquals('Resubmitted to audit by collections', book1.Termination_Status__c);
    }
    @isTest
    static void submittedToAccountTest3() {
        Booking__c book = [select id,Termination_Remarks__c from booking__c limit 1];
        book.Termination_Remarks__c  = 'test';
        update book;
        TerminationDashboardController.submittedToAccount(new List<String>{book.Id}, 'Resubmitted to collections by audit', 'test', 'DLD','Account');  
        Booking__c book1 = [select id,Termination_Status__c from booking__c limit 1];
        //System.assertEquals('Resubmitted to collections by audit', book1.Termination_Status__c);
        
    }
     @isTest
    static void submittedToAccountTest4() {
        String towerId = [Select id from tower__c limit 1][0].Id;
        Tower__c tower = new Tower__c();
        tower.Under_Construction__c = true;
        tower.Id  = towerId;
        update tower;
        Booking__c book = [select id,Termination_Remarks__c from booking__c limit 1];
        book.Termination_Remarks__c  = 'test';
        book.tower__c = towerId;
        book.Agreement_Value__c  = 0;
        update book;
        TerminationDashboardController.submittedToAccount(new List<String>{book.Id}, 'Submitted to audit', 'test', 'Audit','Audit');  
        Booking__c book1 = [select id,Termination_Status__c from booking__c limit 1];
        //System.assertEquals(null, book1.Termination_Status__c);
        
    }
    
    private static Payment_Milestones__c createPaymentMilestone (Id quote) {        
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
        return pm;
    }
    
}