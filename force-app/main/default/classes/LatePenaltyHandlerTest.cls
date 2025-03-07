@isTest 
public class LatePenaltyHandlerTest {
    
    @testSetup
    public static void setup(){
        List<Demand__c> demandList = new List<Demand__c>();
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');
        
        Tower__c tower = [SELECT Id, Name, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;      
        
        Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Total_Interest_Till_Date__c = 15000;
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test@test.com';
        insert b;
        
        Booking__c b2 = new Booking__c();
        b2.Booking_Date__c = System.today().addDays(-10);
        b2.Project__c = recordIdMap.get('PROJECT');
        b2.Tower__c = recordIdMap.get('TOWER');
        b2.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b2.Quotation__c = q.Id;
        b2.Unit__c = recordIdMap.get('UNIT');
        b2.Agreement_Value__c = 2500000;
        b2.Status__c = 'UnProcessed';
        b2.Total_Interest_Till_Date__c = 5000;
        b2.Stage_of_Booking__c = 'Booked';
        b2.Verification_status__c = 'Not Started';
        b2.Booking_Approver_Audit__c = 'Not Started';
        b2.Call_Disposition__c = 'Not Started';   
        b2.Primary_Applicant_Email__c = 'test@test.com';
        insert b2;
        
        Quotation__c q1 = new Quotation__c();
        q1.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q1.Unit__c = recordIdMap.get('UNIT');
        q1.Payment_Plan__c = recordIdMap.get('PLAN');
        q1.Quote_Status__c = 'Valid';
        insert q1;
        
        Payment_Milestones__c pm1 = createPaymentMilestone(q1.Id);
        
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c =recordIdMap.get('PROJECT');
        objRec.Opportunity__c =recordIdMap.get('OPPORTUNITY');
        objRec.Project_Unit__c = recordIdMap.get('UNIT');
        objRec.Booking__c = b.Id; 
        objRec.Receipt_Status__c = 'Cleared';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Amount_Rs__c = 500;
        objRec.Total_Amount__c = 500;
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        insert objRec;
        
        Team__c t = new Team__c();
        t.Team_Type__c = 'CRM Team';
        t.Project__c =  recordIdMap.get('PROJECT');
        t.Sub_Project__c = recordIdMap.get('CLUSTER');
        insert t;
        
        Team_Members__c tm = new Team_Members__c();
        tm.Team__c = t.Id;
        tm.User_Active__c = true;
        tm.User__c = UserInfo.getUserId();
        insert tm; 
        
        Team_Members__c tm1 = new Team_Members__c();
        tm1.Team__c = t.Id;
        tm1.User_Active__c = true;
        tm1.User__c = UserInfo.getUserId();
        insert tm1;
        
        list<Demand__c> dList = new list<Demand__c>();
        Demand__c d = new Demand__c();
        d.Milestone_Name__c = 'Debit note for DLD Charges';       
        d.Debit_Demanded__c = 100;
        d.Debit_CGST__c = 0;
        d.Tax_Rate__c = 'OUT OF SCOPE';
        d.Debit_Type__c = 'Interest Charges';
        d.Invoice_Date__c = System.Today();
        d.GL_Date__c = System.Today();
        d.Due_Date__c = pm.Milestone_Due_Date__c;
        d.Project__c = recordIdMap.get('PROJECT');
        d.Booking__c = b.Id;
        d.Unit__c = unitId;
        d.Corporate_Collection_Control_Report__c = 20; 
        d.Registration_Collection_Control_Report__c = 20;
        d.Payment_Towards__c = 'Corporate Account';
        d.Payment_Milestones__c = pm.id;
        d.OutStanding_days_calculated__c = '100';
        dList.add(d);
        
        Demand__c d1 = new Demand__c();
        d1.Milestone_Name__c = 'Debit note for DLD Charges';       
        d1.Debit_Demanded__c = 100;        d1.Debit_CGST__c = 0;
        d1.Tax_Rate__c = 'OUT OF SCOPE';
        d1.Debit_Type__c = 'Interest Charges';
        d1.GL_Date__c = System.Today();
        d1.Due_Date__c = pm.Milestone_Due_Date__c;
        d1.Project__c = recordIdMap.get('PROJECT');
        d1.Booking__c = b.Id;
        d1.Unit__c = unitId;
        d1.Corporate_Collection_Control_Report__c = 50; 
        d1.Registration_Collection_Control_Report__c = 20;
        d1.Payment_Towards__c = 'Corporate Account';
        d1.Payment_Milestones__c = pm1.id;
        d1.Due_Date__c = System.today().addDays(-50);
        d1.Invoice_Date__c = System.today().addDays(-50);
        d1.OutStanding_days_calculated__c = '100';
        dList.add(d1);
        
        Demand__c d2 = new Demand__c();
        d2.Milestone_Name__c = 'Debit note for DLD Charges';       
        d2.Debit_Demanded__c = 100000;
        d2.Debit_CGST__c = 0;
        d2.Tax_Rate__c = 'OUT OF SCOPE';
        d2.Debit_Type__c = 'Interest Charges';
        d2.Invoice_Date__c = System.Today();
        d2.GL_Date__c = System.Today();
        d2.Due_Date__c = pm.Milestone_Due_Date__c;
        d2.Project__c = recordIdMap.get('PROJECT');
        d2.Booking__c = b.Id;
        d2.Unit__c = unitId;
        d2.Corporate_Collection_Control_Report__c = 50000; 
        d2.Registration_Collection_Control_Report__c = 20000;
        d2.Payment_Towards__c = 'Corporate Account';
        d2.Payment_Milestones__c = pm.id;
        d2.OutStanding_days_calculated__c = '100';
        dList.add(d2);
        insert dList;
    }
    
    @isTest public static void testCalculateLatePaymentPositive() {
        Demand__c demand = [Select Id, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        Booking__c booking =[Select Id,Total_On_Account_Money_With_Registration__c From Booking__c Where Id =:demand.Booking__c LIMIT 1];
        Test.startTest();
        LatePenaltyHandler.calculateLatePayment(booking.id);
        Test.stopTest();
    }
    
    @isTest public static void test15days() {
        Test.startTest();
        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Interest Charges';
        amList.add(am1);
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Trade Receivable';
        amList.add(am2);
        insert amList;
        Demand__c demand = [Select Id, Demand_Status__c, OutStanding_days_calculated__c, Date_for_Late_Payment_Calculation__c, Booking__r.Unit__r.Tower__r.UnRegister_Project__c, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        demand.Due_Date__c = system.today() - 15;
        demand.Invoice_Date__c = system.today() - 15;
        update demand;
        demand = [Select Id, Demand_Status__c, OutStanding_days_calculated__c, Date_for_Late_Payment_Calculation__c, Booking__r.Unit__r.Tower__r.UnRegister_Project__c, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        System.enqueueJob(new RaiseLatePenaltyBatch15Days());
        Test.stopTest();
    }
    
    @isTest public static void test15days_2() {
        Test.startTest();
        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Interest Charges';
        amList.add(am1);
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Trade Receivable';
        amList.add(am2);
        insert amList;
        Demand__c demand = [Select Id, Demand_Status__c, OutStanding_days_calculated__c, Date_for_Late_Payment_Calculation__c, Booking__r.Unit__r.Tower__r.UnRegister_Project__c, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        demand.OutStanding_days_calculated__c = null;
        demand.Due_Date__c = system.today() - 15;
        demand.Invoice_Date__c = system.today() - 15;
        update demand;
        demand = [Select Id, Demand_Status__c, OutStanding_days_calculated__c, Date_for_Late_Payment_Calculation__c, Booking__r.Unit__r.Tower__r.UnRegister_Project__c, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        List<Booking__c> bList = [ SELECT Id,Name From Booking__c ];
        for(Booking__c booking : bList){
            booking.Opportunity__c = null;
        }
        update bList;
        RaiseLatePenaltyBatch30Days.dummyCovrage();
        RaiseLatePenaltyBatch15Days.dummyCovrage();
        System.enqueueJob(new RaiseLatePenaltyBatch15Days());
        Test.stopTest();
    }
    
    @isTest public static void test30days() {
        Test.startTest();
        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Interest Charges';
        amList.add(am1);
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Trade Receivable';
        amList.add(am2);
        insert amList;
        Demand__c demand = [Select Id, Demand_Status__c, OutStanding_days_calculated__c, Date_for_Late_Payment_Calculation__c, Booking__r.Unit__r.Tower__r.UnRegister_Project__c, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        demand.Due_Date__c = system.today() - 30;
        demand.Invoice_Date__c = system.today() - 30;
        update demand;
        demand = [Select Id, Demand_Status__c, OutStanding_days_calculated__c, Date_for_Late_Payment_Calculation__c, Booking__r.Unit__r.Tower__r.UnRegister_Project__c, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        System.enqueueJob(new RaiseLatePenaltyBatch30Days());
        
        Test.stopTest();
    }
    
    @isTest public static void test30days_2() {
        Test.startTest();
        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Interest Charges';
        amList.add(am1);
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Trade Receivable';
        amList.add(am2);
        insert amList;
        Demand__c demand = [Select Id, Demand_Status__c, OutStanding_days_calculated__c, Date_for_Late_Payment_Calculation__c, Booking__r.Unit__r.Tower__r.UnRegister_Project__c, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        demand.OutStanding_days_calculated__c = null;
        demand.Due_Date__c = system.today() - 30;
        demand.Invoice_Date__c = system.today() - 30;
        update demand;
        demand = [Select Id, Demand_Status__c, OutStanding_days_calculated__c, Date_for_Late_Payment_Calculation__c, Booking__r.Unit__r.Tower__r.UnRegister_Project__c, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        List<Booking__c> bList = [ SELECT Id,Name From Booking__c ];
        for(Booking__c booking : bList){
            booking.Opportunity__c = null;
        }
        update bList;
        System.enqueueJob(new RaiseLatePenaltyBatch30Days());
        Test.stopTest();
    }
    
    @isTest public static void testUnchecking() {
        Booking__c b = [select Id from Booking__c LIMIT 1];
        b.X15days_Demand_Raised__c = true;
        b.Milestone_Due_Till_Date__c = 100;
        test.startTest();
        update b;
        
        System.enqueueJob(new UncheckDemandRaisedOnBooking());
        test.stopTest();
    }
    
    @isTest public static void test15daysScheduler() {
        Test.startTest();
        RaiseLatePenaltyBatch15DaysScheduler days15 = new RaiseLatePenaltyBatch15DaysScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test 15Days', sch, days15); 
        Test.stopTest();
    }
    
    @isTest public static void test30daysScheduler() {
        Test.startTest();
        RaiseLatePenaltyBatch30DaysScheduler days30 = new RaiseLatePenaltyBatch30DaysScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test 30Days', sch, days30); 
        Test.stopTest();
    }
    
    @isTest public static void testUncheckingScheduler() {
        Test.startTest();
        UncheckDemandRaisedOnBookingScheduler uncheck = new UncheckDemandRaisedOnBookingScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test 15Days', sch, uncheck); 
        Test.stopTest();
    }
    
    @isTest public static void testCalculateLatePaymentNegative() {
        List<Demand__c> demandList = [Select Id, Booking__c From Demand__c Where Booking__c != Null];
        for(Demand__c demand : demandList){
            demand.Debit_Demanded__c = 100;
            demand.Corporate_Collection_Control_Report__c = 20; 
            demand.Registration_Collection_Control_Report__c = 20;   
        }
        Booking__c booking =[Select Id,Total_On_Account_Money_With_Registration__c From Booking__c LIMIT 1];
        Test.startTest();
        update demandList; 
        LatePenaltyHandler.calculateLatePayment(booking.id);
        Test.stopTest(); 
    }
    
    @isTest public static void raiseDemand() {
        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Interest Charges';
        amList.add(am1);
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Trade Receivable';
        amList.add(am2);
        insert amList;
        
        Demand__c demand = [Select Id, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        Booking__c booking =[Select Id,Total_On_Account_Money_With_Registration__c From Booking__c Where Id =:demand.Booking__c LIMIT 1];
        Test.startTest();
        LatePenaltyHandler.raiseDemand(booking.id);
        LatePenaltyHandler.sendLPEmailToCustomer(new List<Id>{booking.id});
        Test.stopTest();
    }
    
    private static Payment_Milestones__c createPaymentMilestone (Id quote) {        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Due_Date__c = System.today().addDays(100);
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