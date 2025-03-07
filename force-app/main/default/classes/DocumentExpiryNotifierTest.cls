@isTest
public class DocumentExpiryNotifierTest  {
    @isTest
    public static void frrCreation() {
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project'); 
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);      
        Integer cancellationDays = Integer.valueOf(system.label.Auto_Cancellation_Booking);
        Datetime condieredDate = System.today().addDays((-1)*cancellationDays);
        
        Date consideredDate1 = Date.newInstance(condieredDate.year(), condieredDate.month(), condieredDate.day());
        Booking__c b = new Booking__c();
        b.Booking_Date__c = consideredDate1;
        b.Reason_For_Cancellation_D__c = 'Test';
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'UnProcessed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
        Payment_Request__c pr = new Payment_Request__c();
        pr.name__c = 'vi';
        pr.Booking__c=b.id;
        pr.Email__c = 'test.jakka@test.com';
        pr.Mobile_Number__c='9550987889';
        pr.Emirates_Id_Passport_Number__c='12xgy';
        pr.Mode__c = 'OTC Deposits';
        pr.Status__c='Approved';
        pr.Amount__c = 123;
        pr.Unit__c = unitId;
        pr.Approved_Date_and_Time__c=System.today();
        pr.From_Booking__c = true;
        pr.Sales_Manager__c = userinfo.getUserId();
        insert pr;
        unit_hold_request__c newsale = new unit_hold_request__c();
        newsale.Agent_Name__c = 'yamni';
        newsale.Blocking_Amount_Paid__c = 123;
        newsale.Opportunity__c = oppid;
        newsale.Payment_Request__c = pr.Id;
        newsale.Booking__c = b.id;
        newsale.Approval_Status__c = 'Approved';
        newsale.DLD_Amount__c = 1234;
        newsale.DLD_Amount_2__c = 1342;
        newsale.DP_Amount_2__c = 321;
        newsale.How_Many_Applicants__c = 'One Applicant';
        // newsale.Sales_Head_Value__c = usr.id;
        // newsale.OwnerId = usr.id;
        // newsale.Sales_Head_VP__c = usr.id;
        // newsale.Sales_Manager_Value__c = usr.id;
        newsale.Approved_Date__c = System.today()+5;
        insert newsale;
        
        Test.startTest();
        Applicant_Details__c ad = new Applicant_Details__c();
        ad.Booking__c = b.Id;
        ad.Applicant_Number__c = 'Primary Applicant';
        ad.Visa_Copy_Valid_Upto__c = system.today().addDays(-15);
        ad.Valid_Until_Passport__c = system.today().addDays(-15);
        ad.Valid_Upto_National_ID__c = system.today().addDays(-15);
        ad.Non_residency_Letter_Valid_Upto__c = system.today().addDays(-15);
        ad.Others_Valid_Upto__c = system.today().addDays(-15);
        ad.Valid_Upto_Emirates_Id__c = system.today().addDays(-15);
        ad.unit__c = unitId;
        insert ad;
        //DocumentExpiryNotifierBatch batchJob = new DocumentExpiryNotifierBatch();
        //database.executeBatch(batchJob,5);
        String cronExpression = '0 0 12 * * ?'; // This cron expression is for 12 PM daily
        DocumentExpiryNotifierSch schedulable = new DocumentExpiryNotifierSch();
        String jobID = System.schedule('Test Schedulable', cronExpression, schedulable);
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