@isTest
public class MilestoneAgeingControllertest {
     @isTest
    static void testControllerInitialization() {
        
        // Create a test Booking record
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
        List<Receipt__c> testReceipts = new List<Receipt__c>();
        for (Integer i = 0; i < 3; i++) {
            testReceipts.add(new Receipt__c(
                Booking__c = testBooking.Id,
                Receipt_Status__c = 'Cleared',
	            Other_Charges_Type__c = 'NOC Charges',
                Cheque_DD_Amount_Rs__c = 20000000,
                Cheque_DD__c = '908888',
                Cheque_DD_Date__c = system.today(),
                Project__c = projectId,
                Project_Unit__c = unitId,
                Opportunity__c = oppId,
                CheckReceipt__c = true,
                Token_Amount_Receipt__c = true,
                Physically_Cheque_Received__c = true,
                Approval_Status__c = 'Approved',
                Receipt_Date__c = system.today(),
                DraweeBank__c = 'Axis Bank',
                Total_Amount__c = 200000000,
                Amount_Rs__c = 200000000,
                Corporate_Collection_Control_Report__c = 200000000,
                Amount_Advanced__c = 0,
                mode__c = 'Cheque',
                Currency__c = 'AED'
            ));
        }
        insert testReceipts;
        Payment_Milestones__c pm = createPaymentMilestone(quote.Id,System.today() -20);
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id,System.today() -40);
        Payment_Milestones__c pm2 = createPaymentMilestone(quote.Id,System.today() -50);
        Payment_Milestones__c pm3 = createPaymentMilestone(quote.Id,System.today() -60);
        Payment_Milestones__c pm4 = createPaymentMilestone(quote.Id,System.today() -90);
        Payment_Milestones__c pm5 = createPaymentMilestone(quote.Id,System.today() -120);
        Payment_Milestones__c pm6 = createPaymentMilestone(quote.Id,System.today() -160);
        Payment_Milestones__c pm7 = createPaymentMilestone(quote.Id,System.today() -180);
        Payment_Milestones__c pm8 = createPaymentMilestone(quote.Id,System.today() -250);
        Payment_Milestones__c pm9 = createPaymentMilestone(quote.Id,System.today() -350);
        System.debug('total on account money : '+ testbooking.Total_On_Account_Money__c);
        Test.startTest();
        MilestoneAgeingBatch m = new MilestoneAgeingBatch();
        Database.executeBatch(m,200);
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, m);
        
        List<booking__C> bookingsList = new List<booking__c>();
        bookingsList.add(testbooking);
        MilestoneAgeingController.calculateAging(bookingsList);
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

    public static Payment_Milestones__c createPaymentMilestone (Id quote,Date dueDate) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Charge1Percentage__c = 1;
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
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
        pm.Milestone_Due_Date__c =  dueDate;
        insert pm;        
        return pm;                  
    }


}