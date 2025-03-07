@isTest
public class PaymentMilestoneControllerTest {
    
    static testMethod void testUpdateAdvanceAmountInPM() {
        // Create test data
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
        
        Date dat = system.today() + 50 ;
        Payment_Milestones__c pm = NewCustomerSOAControllerTest.createPaymentMilestone(quote.Id,dat);
        
        
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
        
        // Call the method to test
        Test.startTest();
        PaymentMilestoneController.updateAdvanceAmountInPM(new List<String>{testBooking.Id});
        Test.stopTest();
        PaymentMilestoneController.cancelAdvancePM(new List<String>{pm.Id});
        
    }
    
    
}