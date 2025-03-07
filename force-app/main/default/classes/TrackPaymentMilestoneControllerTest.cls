@isTest
public class TrackPaymentMilestoneControllerTest {

    @isTest
    static void testGenerateTPM() {


        // Populate receiptList, demandList, and tpmList with test data
        // Insert the test data
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = NewCustomerSOAControllerTest.createQuotation(oppId, recordMap.get('PLAN'), unitId);
        
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
        
        // Create test data for Demand__c, Receipt__c, and Track_PaymentMilestone__c

        
        Demand__c d = new Demand__c();
        //d.Payment_Milestones__c = pmList[0].id;
        d.Quotation__c = quote.id;
        d.Booking__c = testBooking.id;
        d.Invoice_Date__c = system.today();
        d.Due_Date__c = system.today()+1; 
        d.Debit_Demanded__c = 1000;
        d.Debit_Paid__c = 20;
        d.Debit_Type__c = 'Cheque Bounce';
        d.Debit_Tax_Demanded__c = 100;
        d.Debit_Tax_Paid__c = 20;
        d.Debit_SGST__c = 50;
        d.Other_Charges_Type__c = null;
        d.Demand_Status__c = 'Reversed';
        d.Agreement_Value_Paid__c=400;
        d.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d.Debit_CGST__c = 50;
        
        insert d;
        
        List<Receipt__c> testReceipts = new List<Receipt__c>();
        for (Integer i = 0; i < 3; i++) {
            testReceipts.add(new Receipt__c(
                Booking__c = testBooking.Id,
                Receipt_Status__c = 'Cleared',
                Other_Charges_Type__c = null,
                Cheque_DD_Amount_Rs__c = 20000000,
                Demand__c = d.Id,
                Cheque_DD__c = '908888',
                Cheque_DD_Date__c = system.today(),
                Project__c = projectId,
                Project_Unit__c = unitId,
                Registration_Collection_Control_Report__c = 0,
                Opportunity__c = oppId,
                CheckReceipt__c = true,
                Token_Amount_Receipt__c = true,
                Physically_Cheque_Received__c = true,
                Approval_Status__c = 'Approved',
                Receipt_Date__c = system.today(),
                DraweeBank__c = 'Axis Bank',
                Total_Amount__c = 20000000,
                Amount_Rs__c = 20000000,
                Amount_Advanced__c = 0,
                mode__c = 'Cheque',
                Currency__c = 'AED'
                //r1.Mode__c='Credit Note';
                // Populate other required fields here
            ));
        } 
        insert testReceipts;
        testReceipts.remove(0);
        testReceipts.remove(0);
        
     
            Track_PaymentMilestone__c tp = new Track_PaymentMilestone__c();
       // tp.Demand_Amount__c = 12345;
        tp.Booking__c = testBooking.Id;
        tp.Amount_Utilized_In_PaymentMilestone__c = 123;
        tp.Utilized_in_Payment_Milestone__c = true;
        tp.Partially_Utilized_In_Payment_Milestone__c = true;
        tp.receipt__c = testReceipts[0].Id;
        tp.Demand__c = d.Id;
        tp.Remaining_Receipt_Amount__c = 234;
        insert tp;
        Test.startTest();
        TrackPaymentMilestoneController.generateTPM(testReceipts);
        Test.stopTest();

        // Perform assertions to verify the expected outcomes
        // Query and assert the objects affected by the generateTPM method
        // Add more assertions as needed to validate the logic
    }

    @isTest
    static void testCancelTPM() {


        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = NewCustomerSOAControllerTest.createQuotation(oppId, recordMap.get('PLAN'), unitId);
        
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
        
        // Create test data for Demand__c, Receipt__c, and Track_PaymentMilestone__c

        
        Demand__c d = new Demand__c();
        //d.Payment_Milestones__c = pmList[0].id;
        d.Quotation__c = quote.id;
        d.Booking__c = testBooking.id;
        d.Invoice_Date__c = system.today();
        d.Due_Date__c = system.today()+1; 
        d.Debit_Demanded__c = 1000;
        d.Debit_Paid__c = 20;
        d.Debit_Type__c = 'Cheque Bounce';
        d.Debit_Tax_Demanded__c = 100;
        d.Debit_Tax_Paid__c = 20;
        d.Debit_SGST__c = 50;
        d.Other_Charges_Type__c = null;
        d.Demand_Status__c = 'Reversed';
        d.Agreement_Value_Paid__c=400;
        d.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d.Debit_CGST__c = 50;
        
        insert d;
        
        List<Receipt__c> testReceipts = new List<Receipt__c>();
        for (Integer i = 0; i < 3; i++) {
            testReceipts.add(new Receipt__c(
                Booking__c = testBooking.Id,
                Receipt_Status__c = 'Cleared',
                Other_Charges_Type__c = null,
                Cheque_DD_Amount_Rs__c = 20000000,
                Demand__c = d.Id,
                Cheque_DD__c = '908888',
                Cheque_DD_Date__c = system.today(),
                Project__c = projectId,
                Project_Unit__c = unitId,
                Registration_Collection_Control_Report__c = 0,
                Opportunity__c = oppId,
                CheckReceipt__c = true,
                Token_Amount_Receipt__c = true,
                Physically_Cheque_Received__c = true,
                Approval_Status__c = 'Approved',
                Receipt_Date__c = system.today(),
                DraweeBank__c = 'Axis Bank',
                Total_Amount__c = 20000000,
                Amount_Rs__c = 20000000,
                Amount_Advanced__c = 0,
                mode__c = 'Cheque',
                Currency__c = 'AED'
                //r1.Mode__c='Credit Note';
                // Populate other required fields here
            ));
        } 
        insert testReceipts;
        
     
            Track_PaymentMilestone__c tp = new Track_PaymentMilestone__c();
       // tp.Demand_Amount__c = 12345;
        tp.Booking__c = testBooking.Id;
        tp.Amount_Utilized_In_PaymentMilestone__c = 123;
        tp.Utilized_in_Payment_Milestone__c = true;
        tp.Partially_Utilized_In_Payment_Milestone__c = true;
        tp.receipt__c = testReceipts[0].Id;
        tp.Demand__c = d.Id;
        tp.Remaining_Receipt_Amount__c = 234;
        insert tp;
        // Populate receiptList, demandList, and tpmList with test data
        // Insert the test data
        
        Test.startTest();
        TrackPaymentMilestoneController.cancelTPM(new List<String>{testReceipts[0].Id});
        Test.stopTest();

        // Perform assertions to verify the expected outcomes
        // Query and assert the objects affected by the cancelTPM method
        // Add more assertions as needed to validate the logic
    }

    @isTest
    static void testMarkAdvancePaymentOnPaymentRequest() {
        // Create test data for Payment_Request__c and Booking__c objects
        List<Payment_Request__c> paymentRequestList = new List<Payment_Request__c>();
        List<Booking__c> bookingList = new List<Booking__c>();

        // Populate paymentRequestList and bookingList with test data
        // Insert the test data
        
        Test.startTest();
        Map<String, String> bookingToPaymentRequestId = new Map<String, String>();
        TrackPaymentMilestoneController.markAdvancePaymentOnPaymentRequest(bookingToPaymentRequestId);
        Test.stopTest();

        // Perform assertions to verify the expected outcomes
        // Query and assert the objects affected by the markAdvancePaymentOnPaymentRequest method
        // Add more assertions as needed to validate the logic
    }
    
    @isTest
    static void testPreregistrationTPM() {


        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = NewCustomerSOAControllerTest.createQuotation(oppId, recordMap.get('PLAN'), unitId);
        
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
         
        Demand__c d = new Demand__c();
        //d.Payment_Milestones__c = pmList[0].id;
        d.Quotation__c = quote.id;
        d.Booking__c = testBooking.id;
        d.Invoice_Date__c = system.today();
        d.Due_Date__c = system.today()+1; 
        d.Debit_Demanded__c = 1000;
        d.Debit_Paid__c = 20;
        d.Debit_Type__c = 'Cheque Bounce';
        d.Debit_Tax_Demanded__c = 100;
        d.Debit_Tax_Paid__c = 20;
        d.Debit_SGST__c = 50;
        d.Other_Charges_Type__c = null;
        d.Demand_Status__c = 'Reversed';
        d.Agreement_Value_Paid__c=400;
        d.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d.Debit_CGST__c = 50;
        d.Milestone_Name__c = 'Debit note for DLD Charges';
        
        insert d;
        
        List<Receipt__c> testReceipts = new List<Receipt__c>();
        for (Integer i = 0; i < 3; i++) {
            testReceipts.add(new Receipt__c(
                Booking__c = testBooking.Id,
                Receipt_Status__c = 'Cleared',
                Cheque_DD_Amount_Rs__c = 20000000,
                Demand__c = d.Id,
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
                Total_Amount__c = 20000000,
                Amount_Rs__c = 20000000,
                Amount_Advanced__c = 0,
                mode__c = 'Cheque',
                Currency__c = 'AED',
                Registration_Collection_Control_Report__c = 20000000
                //r1.Mode__c='Credit Note';
                // Populate other required fields here
            ));
        } 
        insert testReceipts;
        
        Test.startTest();
        TrackPaymentMilestoneController.preRegistrationTPM(new List<Receipt__c>{testReceipts[0]});
        Test.stopTest();
    }
}