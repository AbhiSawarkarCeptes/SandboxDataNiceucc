@isTest
private class BookingPccNotificationBatchTest {

    @isTest 
    static void testBatchExecution() {

        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Trade Receivable';
        am1.Tax_Rate__c = 'GST 0%';
        am1.Type__c = 'Others';
        amList.add(am1);
        
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Discount/rebate credit note';
        am2.Tax_Rate__c = 'GST 0%';
        am2.Type__c = 'VAT';
        amList.add(am2);
        
        insert amList;
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        Id projectChargesId = recordMap.get('BASIC');
        
        Unit__c unitToUpdate = new Unit__c();
        unitToUpdate.Id = unitId;
        unitToUpdate.OC_Received__c = true;
        update unitToUpdate;
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];

        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = optyId ;
        objQuote1.Payment_Plan__c = recordMap.get('PLAN') ;
        objQuote1.Unit__c = unitId;
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
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Stage_of_Booking__c = 'Booked';
        b.Quotation__c = objQuote1.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
            
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        insert b; 
        
        
        system.debug('B1'+b.Agreement_Value__c);
        system.debug('B2'+b.Paid_Percentage__c);
        system.debug('B3'+b.PCC_Status__c);
        system.debug('B4'+b.Title_Transfer_Completed__c);
        
        Payment_Milestones__c pm = createPaymentMilestone(objQuote1.Id);
        
        Demand__c d = new Demand__c();
        d.Payment_Milestones__c = pm.id;
        d.Quotation__c = objQuote1.id;
        d.Booking__c = b.id;
        d.Invoice_Date__c = system.today();
        d.Due_Date__c = system.today(); 
        d.Debit_Demanded__c = 1000;
        d.Debit_Paid__c = 0;
        d.Debit_Type__c = 'Interest Charges';
        d.Debit_Tax_Demanded__c = 0;
        d.Debit_Tax_Paid__c = 0;
        d.Debit_SGST__c = 0;
        d.Demand_Status__c = 'Raised';
        d.Agreement_Value_Paid__c=0;
        d.Service_Tax_on_Agreement_Value_Paid__c = 0;
        d.Debit_CGST__c = 0;
        insert d;
        
        Demand__c d2 = new Demand__c();
        d2.Payment_Milestones__c = null;
        d2.Milestone_Name__c = 'cheque dishonored charges';
        d2.Quotation__c = objQuote1.id;
        d2.Booking__c = b.id;
        d2.Invoice_Date__c = system.today();
        d2.Due_Date__c = system.today(); 
        d2.Debit_Demanded__c = 1000;
        d2.Debit_Paid__c = 0;
        d2.Debit_Type__c = 'Interest Charges';
        d2.Debit_Tax_Demanded__c = 0;
        d2.Debit_Tax_Paid__c = 0;
        d2.Debit_SGST__c = 0;
        d2.Demand_Status__c = 'Raised';
        d2.Agreement_Value_Paid__c=0;
        d2.Service_Tax_on_Agreement_Value_Paid__c = 0;
        d2.Debit_CGST__c =0;
        insert d2;
        
        Demand__c d3 = new Demand__c();
        d3.Payment_Milestones__c = null;
        d3.Milestone_Name__c = 'Late Payment Charges';
        d3.Quotation__c = objQuote1.id;
        d3.Booking__c = b.id;
        d3.Invoice_Date__c = system.today();
        d3.Due_Date__c = system.today(); 
        d3.Debit_Demanded__c = 1000;
        d3.Debit_Paid__c = 20;
        d3.Debit_Type__c = 'Interest Charges';
        d3.Debit_Tax_Demanded__c = 0;
        d3.Debit_Tax_Paid__c = 0;
        d3.Debit_SGST__c = 0;
        d3.Demand_Status__c = 'Raised';
        d3.Agreement_Value_Paid__c=0;
        d3.Service_Tax_on_Agreement_Value_Paid__c = 0;
        d3.Debit_CGST__c = 0;
        insert d3;
        
        LP_Waiver__c lp = new LP_Waiver__c();
        lp.Booking__c = b.Id;
        lp.Demand__c = d.Id;
        lp.Amount_Towards_Late_Penalty__c = 200;
        lp.LP_Amount_To_Be_Waived__c = 100;
        lp.Approved_Amount__c = 500;
        insert lp;
        
        LP_Waiver__c lp2 = new LP_Waiver__c();
        lp2.Booking__c = b.Id;
        lp2.Demand__c = d.Id;
        lp2.Amount_Towards_Late_Penalty__c = 200;
        lp2.LP_Amount_To_Be_Waived__c = 100;
        lp2.Approved_Amount__c = 500;
        insert lp2;
        
        List<Receipt__c> rlist = new List<Receipt__c>();
        
        Receipt__c rrq = new Receipt__c();
        rrq.Cheque_DD_Amount_Rs__c = 500;
        rrq.Cheque_DD__c = '908888';
        rrq.Cheque_DD_Date__c = system.today();
        rrq.Project__c = projectId;
        rrq.Project_Unit__c = unitId;
        rrq.Opportunity__c = optyId;
        rrq.CheckReceipt__c = true;
        rrq.Token_Amount_Receipt__c = true;
        rrq.Physically_Cheque_Received__c = true;
        rrq.Approval_Status__c = 'Approved';
        rrq.Receipt_Date__c = system.today();
        rrq.DraweeBank__c = 'Axis Bank';
        rrq.Total_Amount__c = 6000000;
        rrq.Amount_Rs__c = 6000000;
        rrq.Amount_Advanced__c = 0;
        rrq.mode__c = 'Cheque';
        rrq.Currency__c = 'AED';
        rrq.Booking__c = b.Id;
        rrq.Receipt_Status__c = 'Cleared';
        rlist.add(rrq);
        
        Receipt__c rrq2 = new Receipt__c();
        rrq2.Cheque_DD_Amount_Rs__c = 500;
        rrq2.Cheque_DD__c = '908888';
        rrq2.Cheque_DD_Date__c = system.today();
        rrq2.Project__c = projectId;
        rrq2.Project_Unit__c = unitId;
        rrq2.Opportunity__c = optyId;
        rrq2.CheckReceipt__c = true;
        rrq2.Token_Amount_Receipt__c = true;
        rrq2.Physically_Cheque_Received__c = true;
        rrq2.Approval_Status__c = 'Approved';
        rrq2.Receipt_Date__c = system.today();
        rrq2.DraweeBank__c = 'Axis Bank';
        rrq2.Booking__c = b.Id;
        rrq2.Total_Amount__c = 500;
        rrq2.Amount_Rs__c = 500;
        rrq2.Amount_Advanced__c = 0;
        rrq2.mode__c = 'Cheque';
        rrq2.Receipt_Status__c = 'Cleared';
        rlist.add(rrq2);
        
        Receipt__c rrq3 = new Receipt__c();
        rrq3.Cheque_DD_Amount_Rs__c = 500;
        rrq3.Cheque_DD__c = '908888';
        rrq3.Cheque_DD_Date__c = system.today();
        rrq3.Project__c = projectId;
        rrq3.Project_Unit__c = unitId;
        rrq3.Opportunity__c = optyId;
        rrq3.CheckReceipt__c = true;
        rrq3.Token_Amount_Receipt__c = true;
        rrq3.Physically_Cheque_Received__c = true;
        rrq3.Approval_Status__c = 'Approved';
        rrq3.Receipt_Date__c = system.today();
        rrq3.DraweeBank__c = 'Axis Bank';
        rrq3.Booking__c = b.Id;
        rrq3.Total_Amount__c = 500;
        rrq3.Amount_Rs__c = 500;
        rrq3.Amount_Advanced__c = 0;
        rrq3.Description__c = 'late payment';
        rrq3.Receipt_Status__c = 'Cleared';
        rrq3.LP_Waiver__c = lp.Id;
        rrq3.Amount_Advanced__c = 0;
        rlist.add(rrq3);

        Receipt__c rrq4 = new Receipt__c();
        rrq4.Cheque_DD_Amount_Rs__c = 500;
        rrq4.Cheque_DD__c = '908888';
        rrq4.Cheque_DD_Date__c = system.today();
        rrq4.Project__c = projectId;
        rrq4.Project_Unit__c = unitId;
        rrq4.Opportunity__c = optyId;
        rrq4.CheckReceipt__c = true;
        rrq4.Token_Amount_Receipt__c = true;
        rrq4.Physically_Cheque_Received__c = true;
        rrq4.Approval_Status__c = 'Approved';
        rrq4.Receipt_Date__c = system.today();
        rrq4.DraweeBank__c = 'Axis Bank';
        rrq4.Booking__c = b.Id;
        rrq4.Total_Amount__c = 500;
        rrq4.Other_Charges_Type__c = 'Cheque Dishonoured Charges';
        rrq4.Amount_Rs__c = 500;
        rrq4.Amount_Advanced__c = 0;
        rrq4.Description__c = 'late payment';
        rrq4.Receipt_Status__c = 'Cleared';
        rrq4.Amount_Advanced__c = 0;
        rrq4.LP_Waiver__c = lp.Id;
        rlist.add(rrq4);
        
        Receipt__c rrq5 = new Receipt__c();
        rrq5.Cheque_DD_Amount_Rs__c = 500;
        rrq5.Cheque_DD__c = '908888';
        rrq5.Cheque_DD_Date__c = system.today();
        rrq5.Project__c = projectId;
        rrq5.Project_Unit__c = unitId;
        rrq5.Opportunity__c = optyId;
        rrq5.CheckReceipt__c = true;
        rrq5.Token_Amount_Receipt__c = true;
        rrq5.Physically_Cheque_Received__c = true;
        rrq5.Approval_Status__c = 'Approved';
        rrq5.Receipt_Date__c = system.today();
        rrq5.DraweeBank__c = 'Axis Bank';
        rrq5.Booking__c = b.Id;
        rrq5.Total_Amount__c = 500;
        rrq5.Amount_Rs__c = 500;
        rrq5.Amount_Advanced__c = 0;
        rrq5.Description__c = 'late payment';
        rrq5.Receipt_Status__c = 'Cleared';
        rrq5.Registration_Collection_Control_Report__c = 400;
        rrq5.LP_Waiver__c = lp.Id;
        rrq5.Amount_Advanced__c = 0;
        rlist.add(rrq5);
        
        Receipt__c rrq6 = new Receipt__c();
        rrq6.Cheque_DD_Amount_Rs__c = 500;
        rrq6.Cheque_DD__c = '908888';
        rrq6.Cheque_DD_Date__c = system.today();
        rrq6.Project__c = projectId;
        rrq6.Project_Unit__c = unitId;
        rrq6.Opportunity__c = optyId;
        rrq6.CheckReceipt__c = true;
        rrq6.Token_Amount_Receipt__c = true;
        rrq6.Physically_Cheque_Received__c = true;
        rrq6.Approval_Status__c = 'Approved';
        rrq6.Receipt_Date__c = system.today();
        rrq6.DraweeBank__c = 'Axis Bank';
        rrq6.Booking__c = b.Id;
        rrq6.Total_Amount__c = 500;
        rrq6.Amount_Rs__c = 500;
        rrq6.Amount_Advanced__c = 0;
        rrq6.Description__c = 'late payment';
        rrq6.Receipt_Status__c = 'Cleared';
        rrq6.Registration_Collection_Control_Report__c = 0;
        rrq6.Amount_Advanced__c = 0;
        rlist.add(rrq6);
        
        Receipt__c rrq7 = new Receipt__c();
        rrq7.Cheque_DD_Amount_Rs__c = 500;
        rrq7.Cheque_DD__c = '908888';
        rrq7.Cheque_DD_Date__c = system.today();
        rrq7.Project__c = projectId;
        rrq7.Project_Unit__c = unitId;
        rrq7.Opportunity__c = optyId;
        rrq7.CheckReceipt__c = true;
        rrq7.Token_Amount_Receipt__c = true;
        rrq7.Physically_Cheque_Received__c = true;
        rrq7.Approval_Status__c = 'Approved';
        rrq7.Receipt_Date__c = system.today();
        rrq7.DraweeBank__c = 'Axis Bank';
        rrq7.Booking__c = b.Id;
        rrq7.Total_Amount__c = 500;
        rrq7.Amount_Rs__c = 500;
        rrq7.Amount_Advanced__c = 0;
        rrq7.Description__c = 'late payment';
        rrq7.Receipt_Status__c = 'Cleared';
        rrq7.Registration_Collection_Control_Report__c = 200;
        rrq7.Amount_Advanced__c = 0;
        rlist.add(rrq7);
        
        insert rlist;
        
        List<Mortgage__c> MortgagesList = new List<Mortgage__c>();

        Mortgage__c Mortgages = new Mortgage__c();
        Mortgages.Status__c = null;
        Mortgages.Booking__c = b.id;

        MortgagesList.add(Mortgages);
        insert MortgagesList;
        
        
        
        Test.startTest();
        Booking__c bb = [ SELECT Id,Agreement_Value__c,Paid_Percentage__c,PCC_Status__c,Title_Transfer_Completed__c FROM Booking__c WHERE Id =: b.id ];
        system.debug('B1'+bb.Agreement_Value__c);
        system.debug('B2'+bb.Paid_Percentage__c);
        system.debug('B3'+bb.PCC_Status__c);
        system.debug('B4'+bb.Title_Transfer_Completed__c);
        
        BookingPccNotificationBatch batch = new BookingPccNotificationBatch();
        Id batchJobId = Database.executeBatch(batch);
        BookingPccNotificationBatch bpEntry = new BookingPccNotificationBatch();
        String newExeTime = '0 0 3 * * ?';
        String jobId = System.schedule('Scheduler Test', newExeTime, bpEntry);
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
        pm.C1_Amount__c = 1000;          
        pm.C1_CGST__c = 0;
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