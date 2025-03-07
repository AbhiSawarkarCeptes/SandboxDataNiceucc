@isTest
public class X_XSD_UtilTest {
	static Id towerid;
    static Id unitId;
    static List<Applicant_Details__c> applicantDetailsList;
    static Demand__c d;
    static Receipt__c r1;
    
    
    static void createData(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject(('P'+Crypto.getRandomLong()).substring(0,5));
        Id oppId = recordMap.get('OPPORTUNITY'); 
        unitId = recordMap.get('UNIT');
        towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        
        Quotation__c quote = new Quotation__c();        
        quote.Opportunity__c = oppId ;
        quote.Payment_Plan__c = recordMap.get('PLAN') ;
        quote.Unit__c = unitId;
        quote.Basic_Original_PSF__c = 12;
        quote.Charge1Bucket__c = 'Agreement Value';
        quote.Charge1Name__c = 'Basic';
        quote.Charge1Value__c = 1123;
        quote.Charge2Bucket__c = 'Agreement Value';
        quote.Charge2Name__c = 'Floor Rise';
        quote.Charge2Value__c = 1123;
        
        quote.Charge3Bucket__c = 'Agreement Value';
        quote.Charge3Name__c = 'PLC';
        quote.Charge3Value__c = 1123;
        
        quote.Charge4Bucket__c = 'Other Charges';
        quote.Charge4Name__c = 'test';
        quote.Charge4Value__c = 1123;
        quote.Final_Approved_Date__c = System.today();
        insert quote;
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Charge1Percentage__c = 1;
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote.Id;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 10000;  
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 2475;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';
        pm.Milestone_Due_Date__c = System.today() +2 ;
        insert pm;     
        //Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);     
        
        Account acc = new Account();
        acc.LastName = 'testName';
        insert acc;
        
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
        insert b;
        
        quote.Booking__c = b.Id;
        update quote;      
        
        Unit__c unit = [SELECT id,Name,Booking__r.Name FROM Unit__c WHERE id = :unitId];       
		
        delete [SELECT id FROM Unit__c WHERE id != :unit.Id AND Name = :unit.Name];
        
        applicantDetailsList = new List<Applicant_Details__c>();
        Applicant_Details__c ad1 = new Applicant_Details__c();
        ad1.Name = 'A One';
        ad1.Type_Of_Applicant__c = 'Individual Buyer';
        ad1.Subtype_Of_Applicant__c = 'Indian National';
        ad1.One_Passport_Size_Color_Photograph__c = true;
        ad1.Permanent_Address__c = 'Perma Addressia';
        ad1.Email_Address__c = 'a1.one@gmail.com';
        ad1.Mobile_Number__c = '989898989';
        ad1.DOB__c = system.today().addMonths(-12);
        ad1.Booking__c = b.Id;
        applicantDetailsList.add(ad1);
        //insert ad1;
        
        Applicant_Details__c ad2 = new Applicant_Details__c();
        ad2.Name = 'A Four';
        ad2.Type_Of_Applicant__c = 'Individual Buyer';
        ad2.Subtype_Of_Applicant__c = 'Indian National';
        ad2.One_Passport_Size_Color_Photograph__c = true;
        ad2.Permanent_Address__c = 'Perma Addressia';
        ad2.Email_Address__c = 'a2.one@gmail.com';
        ad2.Mobile_Number__c = '8080808080';
        ad2.DOB__c = system.today().addMonths(-12);
        ad2.Booking__c = b.Id;
        applicantDetailsList.add(ad2);
        //insert ad2;
        
        Applicant_Details__c ad3 = new Applicant_Details__c();
        ad3.Name = 'A Three';
        ad3.Type_Of_Applicant__c = 'Individual Buyer';
        ad3.Subtype_Of_Applicant__c = 'Indian National';
        ad3.One_Passport_Size_Color_Photograph__c = true;
        ad3.Permanent_Address__c = 'Perma Addressia';
        ad3.Email_Address__c = 'a3.one@gmail.com';
        ad3.Mobile_Number__c = '9090909090';
        ad3.DOB__c = system.today().addMonths(-12);
        ad3.Booking__c = b.Id;
        applicantDetailsList.add(ad3);
        //insert ad3;
        
        Applicant_Details__c ad4 = new Applicant_Details__c();
        ad4.Name = 'A Four';
        ad4.Type_Of_Applicant__c = 'Individual Buyer';
        ad4.Subtype_Of_Applicant__c = 'Indian National';
        ad4.One_Passport_Size_Color_Photograph__c = true;
        ad4.Permanent_Address__c = 'Perma Addressia';
        ad4.Email_Address__c = 'a3.one@gmail.com';
        ad4.Mobile_Number__c = '9090909090';
        ad4.DOB__c = system.today().addMonths(-12);
        ad4.Booking__c = b.Id;
        applicantDetailsList.add(ad4);
        //insert ad4;
        
        Applicant_Details__c ad5 = new Applicant_Details__c();
        ad5.Name = 'A Five';
        ad5.Type_Of_Applicant__c = 'Individual Buyer';
        ad5.Subtype_Of_Applicant__c = 'Indian National';
        ad5.One_Passport_Size_Color_Photograph__c = true;
        ad5.Permanent_Address__c = 'Perma Addressia';
        ad5.Email_Address__c = 'a3.one@gmail.com';
        ad5.Mobile_Number__c = '9090909090';
        ad5.DOB__c = system.today().addMonths(-12);
        ad5.Applicant_Number__c = 'Primary Applicant';
        ad5.PancardNo__c = 'PA101010';
        ad5.Address_Proof_Document__c = 'Driving License';
        ad5.Address_Proof_Number__c = 'addkdljf';
        ad5.Booking__c = b.Id;
        applicantDetailsList.add(ad5);
        insert applicantDetailsList;
        
        List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
        pmList = [select id,name from Payment_Milestones__c where Quotation__c =: quote.id];
        List<ProjectCharges__c> pc = new list<ProjectCharges__c>();
        pc = [select id,name from ProjectCharges__c where name ='Basic'];
        
        d = new Demand__c();
        d.Payment_Milestones__c = pmList[0].id;
        d.Quotation__c = quote.id;
        d.Booking__c = b.id;
        d.Invoice_Date__c = system.today();
        d.Due_Date__c = system.today()+1; 
        d.Debit_Demanded__c = 1000;
        d.Debit_Paid__c = 20;
        d.Debit_Type__c = 'Cheque Bounce';
        d.Debit_Tax_Demanded__c = 100;
        d.Debit_Tax_Paid__c = 20;
        d.Debit_SGST__c = 50;
        d.Demand_Status__c = '';
        d.Agreement_Value_Paid__c=400;
        d.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d.Debit_CGST__c = 50;
        insert d;
        /*
        r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = false;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Amount_Rs__c = 200000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cash';
        r1.Currency__c = 'Indian Rupee';
        r1.Booking__c = b.Id;
        r1.Receipt_Status__c = 'Cleared';
        insert r1;
		*/
        //System.debug('createData() unitCount - '+[SELECT count() FROM Unit__c]);
        /*
        List<Xpedeon_Data_Dump__c> xdds = new List<Xpedeon_Data_Dump__c>();
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Customer Master',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Customer_Code__c = 'C12345',Xpedeon_Customer_Name__c = 'abc'));
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Project Code',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Project_Code__c = '123456'));
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Unit Type',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Unit_Type__c = 'Plot'));
        insert xdds;
        System.debug('createData() xdds - '+xdds);*/
    }
    
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Project__C proj=TestDataFactory.createProject('TestProject','Lk001');
        List<Tower__c> testTowerList=TestDataFactory.createTowers(1,proj.Id);
        // List<Unit__c> testUnitList=TestDataFactory.createUnits(testTowerList[0].Id,proj.Id);
        Unit__c testUnit = new Unit__c();
        testUnit.name = 'TestUnit';
        testUnit.Carpet_Area__c = 425;
        testUnit.Chargeable_Area__c = 923;
        testUnit.Configuration__c = '2BHK';
        testUnit.Unit_Status__c = 'Available';
        testUnit.Active_Inactive__c = 'Active';
        testUnit.Project__c = proj.id;
        testUnit.Tower__c = testTowerList[0].id;
        testUnit.Floor__c = 10;
        //testUnit.Project_Code__c='pr10';
        insert testUnit;
        
        
        // Create Opportunity
        List<Opportunity> oppList= TestDataFactory.createOpptyForAccount(acc.ID,proj.id,1 );
        Opportunity opp = oppList[0];
        
        
        // Create Applicant Details
        Applicant_Details__c applDetail= new Applicant_Details__c(
            Opportunity__c = opp.Id,
            Name = 'Applicant1',
            Applicant_Number__c = '0098237',
            DOB__c = system.today(),
            Permanent_Address__c = 'Pike Street, New World, 45000',
            Country__c = 'India',
            City__c = 'Nagpur',
            Mailing_Country__c = null,
            Mobile_Number__c = '909090903',
            Email_Address__c = 'newman@justnow.com',
            Nationality__c = 'Indian',
            Type_Of_Applicant__c = 'Individual Buyer',
            Subtype_Of_Applicant__c = 'Indian National'
        );
        insert applDetail;
        Payment_Plan__c testPayPlan = new Payment_Plan__c();
        testPayPlan.Tower__c = testTowerList[0].Id;
        testPayPlan.Plan_Code__c = '001';
        testPayPlan.Project__c = proj.Id;
        testPayPlan.No_GST_on_Token__c = true;
        testPayPlan.NoofMilestones__c = 6;
        testPayPlan.Is_Access_Restricted__c = true;
        testPayPlan.Valid_Till__c = System.today().addDays(5);
        
        insert testPayPlan;
        
        
        Quotation__c testQuote= new Quotation__C(
            Unit__C = testUnit.Id ,
            Opportunity__c = opp.id,
            Payment_Plan__c=testPayPlan.Id
        );
        insert testQuote;
        Booking__c testBooking = new Booking__c(
            Opportunity__c=opp.Id,
            Unit__C=testUnit.Id,
            Quotation__c = testQuote.Id,
            Primary_Applicant_Email__c='AAbbdd@gmail.com',
            SMT__c=true); 
        Insert testBooking;
        
        Receipt__c testRec = new Receipt__c();
        testRec.Cheque_DD_Amount_Rs__c = 20000000;
        testRec.Cheque_DD__c = '908888';
        testRec.Cheque_DD_Date__c = system.today();
        testRec.Project__c = proj.Id;
        testRec.Project_Unit__c = testUnit.Id;
        testRec.Opportunity__c = opp.Id;
        testRec.CheckReceipt__c = true;
        testRec.Token_Amount_Receipt__c = true;
        testRec.Physically_Cheque_Received__c = true;
        testRec.Approval_Status__c = 'Approved';
        testRec.Receipt_Date__c = system.today();
        testRec.DraweeBank__c = 'Axis Bank';
        testRec.Total_Amount__c = 20000000;
        testRec.Amount_Rs__c = 20000000;
        testRec.Amount_Advanced__c = 0;
        testRec.mode__c = 'Cheque';
        testRec.Currency__c = 'AED';
        testRec.Booking__c = testBooking.Id;
        testRec.Receipt_Status__c = 'UnProcessed';
        insert testRec;
        
        Demand__c testDemand = new Demand__c(
            Milestone_Name__c='testDemand',
            Project__c = proj.Id,
            Unit__c = testUnit.Id,
            Booking__c = testBooking.Id
        );
        
        
        
    }
    
    @isTest()
    static void testUnit(){
        Test.startTest();
        createData();
        Test.stopTest();
    }
    
    @isTest()
    static void testTower(){
        Test.startTest();
        createData();
        Test.stopTest();
    }
    
    @isTest()
    static void testApplicantDetails(){
        Test.startTest();
        createData();
        Test.stopTest();
    }
    
    @isTest()
    static void testDemand(){
        Test.startTest();
        createData();
        Test.stopTest();
    }
    
    @isTest()
    static void testReceipt(){
        Test.startTest();
        setupTestData();
        Test.stopTest();
    }

    @isTest()
    static void testforceInit(){
        createData();
        Test.startTest();
        X_XSD_Util.forceInit(new List<Id>{[SELECT id FROM Tower__c][0].id});
        X_XSD_Util.forceInit(new List<Id>{[SELECT id FROM Unit__c][0].id});
        X_XSD_Util.forceInit(new List<Id>{[SELECT id FROM Applicant_Details__c][0].id});
        List<Demand__c> demands = [SELECT id FROM Demand__c];
        if(!demands.isEmpty()) X_XSD_Util.forceInit(new List<Id>{demands[0].Id});
        List<Receipt__c> receipts = [SELECT id FROM Receipt__c];
        if(!receipts.isEmpty()) X_XSD_Util.forceInit(new List<Id>{receipts[0].Id});
        Test.stopTest();
    }        
}