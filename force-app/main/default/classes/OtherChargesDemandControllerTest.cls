@isTest
public class OtherChargesDemandControllerTest {
    
    @testSetup
    static void setupTestData() {
        
        Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = true;
        bypassSettingInstance.Bypass_Booking_Trigger__c = true;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = true;
        bypassSettingInstance.Bypass_Unit_Trigger__c = true;
        bypassSettingInstance.Bypass_Lead_Trigger__c = true;

        upsert bypassSettingInstance;

        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);
        
        Booking__c testBooking = new Booking__c();
        testBooking.Booking_Date__c = system.today();
        testBooking.Project__c = projectId;
        testBooking.Opportunity__c = oppId;
        testBooking.Unit__c = unitId;
        testBooking.status__c = 'Processed';
        testBooking.Quotation__c = quote.Id;
        testBooking.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        testBooking.Future_Correspondence_Contact__c = 'First Applicant';
        testBooking.Agreement_Value__c = 6000000;
        testBooking.Stage_of_Booking__c = 'Booked';
        insert testBooking;
        
        Demand__C demand = new Demand__C();
        demand.Booking__c = testBooking.Id;
        demand.Debit_Demanded__c = testBooking.Total_Interest_Till_Date__c;
        demand.Debit_CGST__c =  testBooking.VAT_On_Interest_Amount__c;
        demand.Payment_Towards__c = 'Corporate Account';
        demand.GL_Date__c = System.today();
        demand.Agreement_Value_Paid__c = 0;
        demand.Service_Tax_on_Agreement_Value_Paid__c = 0;
        demand.Debit_Demanded__c = 0;
        demand.Debit_SGST__c = 0;
        demand.Debit_CGST__c = 0;
        demand.Debit_Tax_Demanded__c = 0;
        demand.Debit_Paid__c = 0;
        demand.Debit_Tax_Paid__c = 0;
        demand.Charge_1_Service_Tax__c = 0;
        demand.Milestone_Name__c = 'Admin Charges';
        demand.Debit_Type__c = 'Interest Charges';
        demand.Tax_Rate__c = 'VAT 5%';
        demand.Payment_Term__c = 'Immediate';
        demand.Project__c = projectId;
        demand.Unit__c = unitId;
        Insert demand;
        
        Demand__C demand2 = new Demand__C();
        demand2.Booking__c = testBooking.Id;
        demand2.Debit_Demanded__c = testBooking.Total_Interest_Till_Date__c;
        demand2.Debit_CGST__c =  testBooking.VAT_On_Interest_Amount__c;
        demand2.Payment_Towards__c = 'Corporate Account';
        demand2.GL_Date__c = System.today();
        demand2.Agreement_Value_Paid__c = 0;
        demand2.Service_Tax_on_Agreement_Value_Paid__c = 0;
        demand2.Debit_Demanded__c = 0;
        demand2.Debit_SGST__c = 0;
        demand2.Debit_CGST__c = 0;
        demand2.Debit_Tax_Demanded__c = 0;
        demand2.Debit_Paid__c = 0;
        demand2.Debit_Tax_Paid__c = 0;
        demand2.Charge_1_Service_Tax__c = 0;
        demand2.Milestone_Name__c = 'Cancellation Charges';
        demand2.Debit_Type__c = 'Interest Charges';
        demand2.Tax_Rate__c = 'VAT 5%';
        demand2.Payment_Term__c = 'Immediate';
        demand2.Project__c = projectId;
        demand2.Unit__c = unitId;
        Insert demand2;
        
        // Create test data - Payment Request records
        // 
        List<Payment_Request__c> prList = new List<Payment_Request__c>();
        
        Payment_Request__c pr = new Payment_Request__c();
        pr.name__c = 'yamini';
        pr.Booking__c=testBooking.id;
        pr.Email__c = 'yamini.jakka@ceptes.com';
        pr.Mobile_Number__c='9550987889';
        pr.Emirates_Id_Passport_Number__c='12xgy';
        pr.Mode__c = 'OTC Deposits';
        pr.Status__c='Approved';
        pr.Amount__c = 123;
        pr.Unit__c = unitId;
        pr.Towards_Other_Charges_Amount__c = 200;
        pr.Approved_Date_and_Time__c=System.today();
        pr.From_Booking__c = true;
        pr.Others__c = 'Detailed design NOC';
        prList.add(pr);
        
        Payment_Request__c pr2 = new Payment_Request__c();
        pr2.name__c = 'yamini';
        pr2.Booking__c=testBooking.id;
        pr2.Email__c = 'yamini.jakka@ceptes.com';
        pr2.Mobile_Number__c='9550987889';
        pr2.Emirates_Id_Passport_Number__c='12xgy';
        pr2.Mode__c = 'OTC Deposits';
        pr2.Status__c='Approved';
        pr2.Amount__c = 123;
        pr.Towards_Pre_Registration_Amount__c = 200;
        pr2.Unit__c = unitId;
        pr2.Approved_Date_and_Time__c=System.today();
        pr2.From_Booking__c = true;
        pr2.Others__c = 'Admin Charges (General)';
        prList.add(pr2);
        
        Payment_Request__c pr3 = new Payment_Request__c();
        pr3.name__c = 'yamini';
        pr3.Booking__c=testBooking.id;
        pr3.Email__c = 'yamini.jakka@ceptes.com';
        pr3.Mobile_Number__c='9550987889';
        pr3.Emirates_Id_Passport_Number__c='12xgy';
        pr3.Mode__c = 'OTC Deposits';
        pr3.Status__c='Approved';
        pr3.Amount__c = 123;
        pr3.Unit__c = unitId;
        pr3.Approved_Date_and_Time__c=System.today();
        pr3.From_Booking__c = true;
        pr3.Others__c = 'Admin Charges (General)';
        prList.add(pr3);
        
        Payment_Request__c pr4 = new Payment_Request__c();
        pr4.name__c = 'yamini';
        pr4.Booking__c=testBooking.id;
        pr4.Email__c = 'yamini.jakka@ceptes.com';
        pr4.Mobile_Number__c='9550987889';
        pr4.Emirates_Id_Passport_Number__c='12xgy';
        pr4.Mode__c = 'OTC Deposits';
        pr4.Status__c='Approved';
        pr4.Amount__c = 123;
        pr4.Unit__c = unitId;
        pr4.Approved_Date_and_Time__c=System.today();
        pr4.From_Booking__c = true;
        pr4.Others__c = 'Concept drawing NOC';
        prList.add(pr4);
        
        Payment_Request__c pr5 = new Payment_Request__c();
        pr5.name__c = 'yamini';
        pr5.Booking__c=testBooking.id;
        pr5.Email__c = 'yamini.jakka@ceptes.com';
        pr5.Mobile_Number__c='9550987889';
        pr5.Emirates_Id_Passport_Number__c='12xgy';
        pr5.Mode__c = 'OTC Deposits';
        pr5.Status__c='Approved';
        pr5.Amount__c = 123;
        pr5.Unit__c = unitId;
        pr5.Approved_Date_and_Time__c=System.today();
        pr5.From_Booking__c = true;
        pr5.Others__c = 'Plot title Deed';
        prList.add(pr5);
        
        Payment_Request__c pr6 = new Payment_Request__c();
        pr6.name__c = 'yamini';
        pr6.Booking__c=testBooking.id;
        pr6.Email__c = 'yamini.jakka@ceptes.com';
        pr6.Mobile_Number__c='9550987889';
        pr6.Emirates_Id_Passport_Number__c='12xgy';
        pr6.Mode__c = 'OTC Deposits';
        pr6.Status__c='Approved';
        pr6.Amount__c = 123;
        pr6.Unit__c = unitId;
        pr6.Approved_Date_and_Time__c=System.today();
        pr6.From_Booking__c = true;
        pr6.Others__c = 'Pre-registration To Pre-title Deed';
        prList.add(pr6);
        
        Payment_Request__c pr7 = new Payment_Request__c();
        pr7.name__c = 'yamini';
        pr7.Booking__c=testBooking.id;
        pr7.Email__c = 'yamini.jakka@ceptes.com';
        pr7.Mobile_Number__c='9550987889';
        pr7.Emirates_Id_Passport_Number__c='12xgy';
        pr7.Mode__c = 'OTC Deposits';
        pr7.Status__c='Approved';
        pr7.Amount__c = 123;
        pr7.Unit__c = unitId;
        pr7.Approved_Date_and_Time__c=System.today();
        pr7.From_Booking__c = true;
        pr7.Others__c = 'Pre-registration to pre-title deed (completed projects)';
		prList.add(pr7);        
        
        Payment_Request__c pr8 = new Payment_Request__c();
        pr8.name__c = 'yamini';
        pr8.Booking__c=testBooking.id;
        pr8.Email__c = 'yamini.jakka@ceptes.com';
        pr8.Mobile_Number__c='9550987889';
        pr8.Emirates_Id_Passport_Number__c='12xgy';
        pr8.Mode__c = 'OTC Deposits';
        pr8.Status__c='Approved';
        pr8.Amount__c = 123;
        pr8.Unit__c = unitId;
        pr8.Approved_Date_and_Time__c=System.today();
        pr8.From_Booking__c = true;
        pr8.Others__c = 'Resale NOC (Title Deed)';
        prList.add(pr8);
        
        Payment_Request__c pr9 = new Payment_Request__c();
        pr9.name__c = 'yamini';
        pr9.Booking__c=testBooking.id;
        pr9.Email__c = 'yamini.jakka@ceptes.com';
        pr9.Mobile_Number__c='9550987889';
        pr9.Emirates_Id_Passport_Number__c='12xgy';
        pr9.Mode__c = 'OTC Deposits';
        pr9.Status__c='Approved';
        pr9.Amount__c = 123;
        pr9.Unit__c = unitId;
        pr9.Approved_Date_and_Time__c=System.today();
        pr9.From_Booking__c = true;
        pr9.Others__c = 'Title Deed Fees (Villas)';
        prList.add(pr9);
        
        Payment_Request__c pr16 = new Payment_Request__c();
        pr16.name__c = 'yamini';
        pr16.Booking__c=testBooking.id;
        pr16.Email__c = 'yamini.jakka@ceptes.com';
        pr16.Mobile_Number__c='9550987889';
        pr16.Emirates_Id_Passport_Number__c='12xgy';
        pr16.Mode__c = 'OTC Deposits';
        pr16.Status__c='Approved';
        pr16.Amount__c = 123;
        pr16.Unit__c = unitId;
        pr16.Approved_Date_and_Time__c=System.today();
        pr16.From_Booking__c = true;
        pr16.Others__c = 'Title Deed Fees (Units)';
        prList.add(pr16);
        
        Payment_Request__c pr10 = new Payment_Request__c();
        pr10.name__c = 'yamini';
        pr10.Booking__c=testBooking.id;
        pr10.Email__c = 'yamini.jakka@ceptes.com';
        pr10.Mobile_Number__c='9550987889';
        pr10.Emirates_Id_Passport_Number__c='12xgy';
        pr10.Mode__c = 'OTC Deposits';
        pr10.Status__c='Approved';
        pr10.Amount__c = 123;
        pr10.Unit__c = unitId;
        pr10.Approved_Date_and_Time__c=System.today();
        pr10.From_Booking__c = true;
        pr10.Others__c = null;
        
        prList.add(pr10);
        
        insert prList;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 20000000;
        r1.Receipt_Status__c = 'Cleared';
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Other_Charges_Type__c = 'Cancellation Charges';
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        //r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 20000000;
        r1.Amount_Rs__c = 20000000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Currency__c = 'AED';
        r1.Booking__c = testBooking.Id;
        insert r1;

        
        bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = false;
        bypassSettingInstance.Bypass_Booking_Trigger__c = false;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
        bypassSettingInstance.Bypass_Unit_Trigger__c = false;
        bypassSettingInstance.Bypass_Lead_Trigger__c = false;

        upsert bypassSettingInstance;
    }
    
    @isTest
    static void testCreateDemand() {
        Test.startTest();
        OtherChargesDemandController.createDemand([SELECT Id,Booking__c,Booking__r.Project__c,Others__c,Unit__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c FROM Payment_Request__c]);
        OtherChargesDemandController.insertErrorLog('Test','Test','Test','Test');
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateOtherChargesReceipt() {
        // Call the updateOtherChargesReceipt method
        Test.startTest();
        OtherChargesDemandController.updateOtherChargesReceipt([SELECT Id,Booking__c,Other_Charges_Type__c FROM Receipt__c]);
        Test.stopTest();
         
        // Verify that Receipt records were updated with demand references
        List<Receipt__c> updatedReceipts = [SELECT Id, Demand__c,Other_Charges_Type__c,Booking__c FROM Receipt__c];
        //System.assertEquals(3, updatedReceipts.size());
        
        // Verify that the Demand__c field in Receipt records points to the correct Demand record
        for (Receipt__c receipt : updatedReceipts) {
            String milestoneName = receipt.Other_Charges_Type__c;
            String bookingName = receipt.Booking__c;
            

        }
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