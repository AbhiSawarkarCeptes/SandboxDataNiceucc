/* Class Name - RaiseDemandControllerTest
 * PurPose - To Cover the Test Coverage for RaiseDemandController
 * Created By - Ashwin Kushwah
 * Used - as a controller for RaiseDemand Visualforce Page
 * Modified By - 
 * Modification Reason - 
*/
@IsTest
public class RaiseDemandControllerTest {
	
    //inserting the test data 
    @testSetup
    public static void setup(){
        List<Account_Master__c> masterList = new List<Account_Master__c>();
        Account_Master__c  interestMaster = new Account_Master__c(); 
        interestMaster.Name = 'Interest Charges';
        masterList.add(interestMaster);
        Account_Master__c tradeMaster = new Account_Master__c();
        tradeMaster.Name = 'Trade Receivable';
        masterList.add(tradeMaster);
        insert masterList;
        
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
        
/*        Id oppId = recordIdMap.get('OPPORTUNITY');
        Opportunity opp = [Select Id,Other_Applicants_Email__c From Opportunity Where Id=: oppId];
        opp.Other_Applicants_Email__c = 'test1233337new000@@@gmail.com';
        update opp;  */
        Account acc = new Account(Name='test acc');
        insert acc;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = acc.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Other_Applicants_Email__c = 'test1233337new0@gmail.com';
        objOpportunity.Other_Applicants_Name__c =' Test New';
        insert objOpportunity;
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = objOpportunity.id;
       // b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';  
        b.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        insert b;
        
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
        Test.startTest();
        insert objRec; 
        Test.stopTest();
        /*    
        Team__c t = new Team__c();
        t.Team_Type__c = 'CRM Team';
        t.Project__c =  recordIdMap.get('PROJECT');
        t.Sub_Project__c = recordIdMap.get('CLUSTER');
        insert t;
        List<Team_Members__c> teamMemberList = new List<Team_Members__c>();
        Team_Members__c tm = new Team_Members__c();
        tm.Team__c = t.Id;
        tm.User_Active__c = true;
        tm.User__c = UserInfo.getUserId();
        teamMemberList.add(tm);
         
        
        Team_Members__c tm1 = new Team_Members__c();
        tm1.Team__c = t.Id;
        tm1.User_Active__c = true;
        tm1.User__c = UserInfo.getUserId();
        teamMemberList.add(tm1);
        insert teamMemberList;
        */
        
        //insert demand record
        Demand__c d = new Demand__c();
        d.Milestone_Name__c = 'Debit note for DLD Charges';       
        d.Debit_Demanded__c = 100000;
        d.Debit_CGST__c = 0;
        d.Tax_Rate__c = 'OUT OF SCOPE';
        d.Debit_Type__c = 'Interest Charges';
        d.Invoice_Date__c = System.Today();
        d.GL_Date__c = System.Today();
        //d.Due_Date__c = pm.Milestone_Due_Date__c;
        d.Due_Date__c = System.Today();
        d.Project__c = recordIdMap.get('PROJECT');
        d.Booking__c = b.Id;
        d.Unit__c = unitId;
        d.Corporate_Collection_Control_Report__c = 50000; 
        d.Registration_Collection_Control_Report__c = 20000;
        d.Payment_Towards__c = 'Corporate Account';
        d.Payment_Milestones__c = pm.id;
        d.OutStanding_days_calculated__c = '32';
        
        insert d;
        List<Booking__c> bookList = new List<Booking__c>();
        
        Booking__c b1= new Booking__c();
        b1.Booking_Date__c = System.today().addDays(-10);
        b1.Project__c = recordIdMap.get('PROJECT');
        b1.Tower__c = recordIdMap.get('TOWER');
        b1.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b1.Quotation__c = q.Id;
        b1.Unit__c = recordIdMap.get('UNIT');
        b1.Agreement_Value__c = 2500000;
        b1.Status__c = 'Processed';
        b1.Stage_of_Booking__c = 'Booked';
        b1.Verification_status__c = 'Not Started';
        b1.Booking_Approver_Audit__c = 'Not Started';
        b1.Call_Disposition__c = 'Not Started';  
        b1.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        bookList.add(b1);
        //insert b1; 
        
        
        //Quotation__c quote = [Select Id From Quotation__c Where Quote_Status__c = 'Valid' LIMIT 1];
        String bookingJSON = '{"Agreement_Value__c": "900000", "Status__c":"Processed", "Stage_of_Booking__c":"Booked","LastModifiedDate":"2020-10-04T17:54:26.000+0000",';
        bookingJSON += '"Quotation__c":' +'"' +q.id+'"}';
        Booking__c booking = (Booking__c)JSON.deserialize(bookingJSON, Booking__c.class);
        bookList.add(booking);
        //insert booking;
        insert bookList;
    }
    @isTest
    public static void raiseDemandTest(){
        Test.startTest();
        Booking__c booking = [Select Id From Booking__c Where Status__c ='UnProcessed' LIMIT 1];
       
        PageReference testPage = Page.RaiseDemand;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('bookingId',String.valueOf(booking.Id));
        RaiseDemandController raiseDemandObj = new RaiseDemandController();
        raiseDemandObj.raiseDemand();
        Test.stopTest();
    }
    
	@isTest
    public static void raiseDemandEmptyListTest(){
        Booking__c booking = [Select Id From Booking__c Where Status__c = 'Processed' LIMIT 1];
        Test.startTest();
        PageReference testPage = Page.RaiseDemand;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('bookingId',String.valueOf(booking.Id));
        RaiseDemandController raiseDemandObj = new RaiseDemandController();
        RaiseDemandController.dummyCOde();
        raiseDemandObj.raiseDemand();
        Test.stopTest();
    }  
    
    @isTest
    public static void raiseDemandLPCNeededTest(){
         Test.startTest();
        Booking__c booking = [Select Id From Booking__c Where Status__c = 'UnProcessed' LIMIT 1];
        List<Demand__c> demand = [Select Id,OutStanding_days_calculated__c,Due_Date__c,Invoice_Date__c From Demand__c Where Booking__c =: booking.id];
        demand[0].OutStanding_days_calculated__c = '0';
        update demand[0];
       
        PageReference testPage = Page.RaiseDemand;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('bookingId',String.valueOf(booking.Id));
        RaiseDemandController raiseDemandObj = new RaiseDemandController();
        raiseDemandObj.raiseDemand();
        Test.stopTest();
    } 
    
    @isTest
    public static void raiseDemandElseTest(){
        Test.startTest();
        Booking__c booking = [Select Id From Booking__c Where Status__c = 'UnProcessed' LIMIT 1];
        List<Demand__c> demand = [Select Id,OutStanding_days_calculated__c,Due_Date__c,Invoice_Date__c From Demand__c Where Booking__c =: booking.id];
        demand[0].OutStanding_days_calculated__c = '40';
        demand[0].Due_Date__c = demand[0].Due_Date__c.addDays(-40);
        demand[0].Invoice_Date__c = demand[0].Invoice_Date__c.addDays(-40);
        update demand[0]; 
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
       
        
        
        PageReference testPage = Page.RaiseDemand;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('bookingId',String.valueOf(booking.Id));
        RaiseDemandController raiseDemandObj = new RaiseDemandController();
        raiseDemandObj.raiseDemand();
        Test.stopTest();
        
    } 
    
    @isTest
    public static void raiseDemandAllPaidTest(){
        Test.startTest();
        Booking__c booking = [Select Id From Booking__c Where Status__c = 'UnProcessed' LIMIT 1];
        List<Demand__c> demand = [Select Id,OutStanding_days_calculated__c,Due_Date__c,Invoice_Date__c From Demand__c Where Booking__c =: booking.id];
        demand[0].OutStanding_days_calculated__c = 'Paid';
       // demand[0].Due_Date__c = demand[0].Due_Date__c.addDays(-40);
        //demand[0].Invoice_Date__c = demand[0].Invoice_Date__c.addDays(-40);
        update demand[0];         
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
       
        
        
        PageReference testPage = Page.RaiseDemand;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('bookingId',String.valueOf(booking.Id));
        RaiseDemandController raiseDemandObj = new RaiseDemandController();
        raiseDemandObj.raiseDemand();
        Test.stopTest();
        
    } 

    @isTest
    public static void raiseDemandHourBeforeTest(){
       Booking__c booking = [Select Id,LastModifiedDate From Booking__c Where Agreement_Value__c = 900000 LIMIT 1];
        //Booking__c booking = new Booking__c();
        //booking.Id = book.id;
        System.debug('Inside test class, booking Last Modified date= '+ booking.LastModifiedDate);
        
        Test.startTest();
        PageReference testPage = Page.RaiseDemand;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('bookingId',String.valueOf(booking.Id));
        RaiseDemandController raiseDemandObj = new RaiseDemandController();
        raiseDemandObj.raiseDemand();
        Test.stopTest();
        
    } 
    
    
    @isTest
    public static void raiseDemandNamesTest(){
        Test.startTest();
        Booking__c booking = [Select Id,Opportunity__c,Opportunity__r.Other_Applicants_Email__c,Opportunity__r.Other_Applicants_Name__c From Booking__c Where Status__c = 'UnProcessed' LIMIT 1];
        
        /*List<Demand__c> demand = [Select Id,OutStanding_days_calculated__c,Due_Date__c,Invoice_Date__c From Demand__c Where Booking__c =: booking.id];
        demand[0].OutStanding_days_calculated__c = '40';
        demand[0].Due_Date__c = demand[0].Due_Date__c.addDays(-40);
        demand[0].Invoice_Date__c = demand[0].Invoice_Date__c.addDays(-40);
        update demand[0]; */
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', FirstName='TestFirst',Email='standarduser@testorg.com',
        				 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
       					 LocaleSidKey='en_US', ProfileId = p.Id,
       					 TimeZoneSidKey='America/Los_Angeles',
        				 UserName=uniqueUserName);
        System.runAs(u) {
        
        
        PageReference testPage = Page.RaiseDemand;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('bookingId',String.valueOf(booking.Id));
        RaiseDemandController raiseDemandObj = new RaiseDemandController();
        raiseDemandObj.raiseDemand();
        Test.stopTest();
        }
    } 
    
     private static Payment_Milestones__c createPaymentMilestone (Id quote) {        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Due_Date__c = System.today().addDays(10);
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