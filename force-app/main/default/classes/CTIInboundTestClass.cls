@isTest
public class CTIInboundTestClass {

	public static void createTestData() {
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        Id towerId = recordMap.get('TOWER');

        Tower__c tower = new Tower__c(Id = towerId, Service_Agent__c = UserInfo.getUserId());
        upsert tower;
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges;
        pm1.Milestone_Due_Date__c = Date.today();
        
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
        b.Current_Status__c = 'Audit Accepted';
        b.Last_Call_Attempt_Status__c = 'No Contact / Unable to Reach';
        b.Primary_Applicant_Name__c = 'Test';
        b.PrimaryMobileNumber__c = '00919900000001';
        insert b;
        
        
        Task__c t = new Task__c();
        t.Notes__c = 'Test Note';
        t.Booking__c = b.id;
        insert t;
    }    
    
    static testMethod void testCTICalloutNegative() {
        //SobhaTokenUserAPI.coverageMethod();
        createTestData();
        Test.setMock(HttpCalloutMock.class, new CTICDRAPITest());  
        CTIInboudAPI.CTIInboundWrapper strResp = CTIInboudAPI.doPost();
    }
    
    static testMethod void testCTICalloutPositive() {
        //SobhaTokenUserAPI.coverageMethod();
        createTestData();
        User testUser = [Select id,Extension From User where id=:UserInfo.getUserId()];
        testUser.Extension = '2002';

        update testUser;
        Test.setMock(HttpCalloutMock.class, new CTIInboundMock());  
        CTIInboudAPI.CTIInboundWrapper strResp = CTIInboudAPI.doPost();
    }
    
    static testMethod void testCTICalloutNoUserWithExt() {
        //SobhaTokenUserAPI.coverageMethod();
        createTestData();
        User testUser = [Select id,Extension From User where id=:UserInfo.getUserId()];
        testUser.Extension = '2003';
        update testUser;
        Test.setMock(HttpCalloutMock.class, new CTIInboundMock());  
        CTIInboudAPI.CTIInboundWrapper strResp = CTIInboudAPI.doPost();
        CTIInboudAPI.coverageMethod();
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
        pm.C1_Amount__c = 300000000;          
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