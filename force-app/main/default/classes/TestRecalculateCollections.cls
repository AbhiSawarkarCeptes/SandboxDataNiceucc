@isTest
public with sharing class TestRecalculateCollections {
    static Booking__c b;
    
    @testSetup
    public static void setupData() {
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        b = new Booking__c();
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
        r1.Receipt_Status__c = 'Cleared';
        //r1.Mode__c='Credit Note';
        r1.Receipt_Status__c = 'Cleared';
        insert r1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 20000000;
        r2.Cheque_DD__c = '908888';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = oppId;
        r2.CheckReceipt__c = true;
        r2.Token_Amount_Receipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 2000;
        r2.Amount_Rs__c = 2000;
        r2.Amount_Advanced__c = 0;
        r2.mode__c = 'Cheque';
        r2.Currency__c = 'AED';
        r2.Booking__c = b.Id;
        r2.Receipt_Status__c = 'Cleared';
        //r1.Mode__c='Credit Note';
        r2.Registration_Collection_Control_Report__c = 2000;
        r2.GL_Date__c = System.today();
        insert r2;
    }
    
    @isTest
    public static void frrCreation() {
        
        Test.startTest();
        Account_Master__c a = new Account_Master__c();
        a.Name = 'test123';
        insert a;
        
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=[select id from Receipt__c limit 1][0].id;      
        fr1.Document_Category__c = 'Receipt';
        fr1.Process_CR__c = true;
        insert fr1;
        Finance_Report_Records__c fr2 = new Finance_Report_Records__c();
        fr2.Receipt__c=[select id from Receipt__c limit 1][0].id;        
        fr2.Document_Category__c = 'Debit Note';
        fr2.Process_CR__c = true;
        insert fr2;
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void frrCreationNew() {
        
        Test.startTest();
        Account_Master__c a = new Account_Master__c();
        a.Name = 'test123';
        insert a;
        
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=[select id from Receipt__c limit 1][0].id;       
        fr1.Document_Category__c = 'Receipt';
        fr1.Process_CR__c = true;
        insert fr1;
        Test.stopTest();
    }
    
    @isTest
    public static void frrCreation1() {
        
        Test.startTest();
        Account_Master__c a = new Account_Master__c();
        a.Name = 'test123';
        insert a;
        
        
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=[select id from Receipt__c limit 1][0].id;        
        fr1.Document_Category__c = 'Debit Note';
        fr1.Process_CR__c = true;
        insert fr1;
        
        Finance_Report_Records__c fr2 = new Finance_Report_Records__c();
        fr2.Receipt__c=[select id from Receipt__c limit 1][0].id;         
        fr2.Document_Category__c = 'Debit Note';
        fr2.Process_CR__c = true;
        insert fr2;
        List<String> bookingNames = new List<String>();
        List<Booking__c> bookings = [SELECT Name FROM Booking__c];
        for(Booking__c booking : bookings){bookingNames.add(booking.Name);}
        CollectionReportControllerV2.dateCalculation(new List<String>(bookingNames));
        delete fr2;
        delete fr1;
        CollectionReportControllerV2.logError('asdasdasd');
        CollectionReportControllerV2.dateCalculation(new List<String>(bookingNames));
        new CollectionReportControllerV2(1);
        System.schedule('CollectionReportControllerV2 '+DateTime.now(),'0 0 0 * * ?',new CollectionReportControllerV2());
        Test.stopTest();
    }
    
    @isTest
    public static void frrCreation2() {
        
        Test.startTest();
        Account_Master__c a = new Account_Master__c();
        a.Name = 'test123';
        insert a;
        
        
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=[select id from Receipt__c limit 1][0].id;        
        fr1.Document_Category__c = 'Debit Note';
        fr1.Process_CR__c = true;
        insert fr1;
        
        Finance_Report_Records__c fr2 = new Finance_Report_Records__c();
        fr2.Receipt__c=[select id from Receipt__c limit 1][0].id;      
        fr2.Document_Category__c = 'Debit Note';
        fr2.Process_CR__c = true;
        insert fr2;
        
        EventBus.publish(new Recalculate_Collections__e(Receipt_Id__c = fr2.Receipt__c));
        EventBus.publish(new Recalculate_Collections__e(Demand_Id__c = fr2.Receipt__c));
        
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
    
}