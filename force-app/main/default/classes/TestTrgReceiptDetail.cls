@isTest
public class TestTrgReceiptDetail {
    @isTest
public static void receiptCreation() {
    
   Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
    Id oppId  =   recordMap.get('OPPORTUNITY');
    Id unitId = recordMap.get('UNIT');
    Id projectId = recordMap.get('PROJECT');
    Id projCharges = recordMap.get('BASIC');
     
    Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
      
    //Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
    //pm1.Charge_1_Lookup__c = projCharges;
    //update pm1;     
    
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
    //insert r1;
    receiptsList.add(r1);
    

    insert receiptsList;

    b.Receipts__c = r1.Id;
    update b;
           
   
            
    quote.Booking__c = b.Id;
    update quote;

    Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
    u.Unit_Status__c = 'Sold';
    u.Customers__c = oppId;
    u.Booking__c = b.Id;
    update u;
    
    Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:oppId];
    o.StageName = 'Booking confirmed';
    o.S_Active__c = true;
    o.Unit__c = unitId;
    o.Primary_Name__c = 'test';
    o.Booking__c = b.Id;
    update o;
    
    //pm1.Collection_Status__c = 'Submitted';
    //pm1.Finance_Status__c = 'Accepted';
    //pm1.Audit_Status__c = 'Accepted';
    //pm1.CFO_Status__c = 'Accepted';
    //update pm1;
  
    //List<Payment_Milestones__c> pmList = [Select Id from Payment_Milestones__c where Quotation__c = :quote.Id 
                                          //and Milestone_Type__c = 'Construction Linked' order by createdDate desc];
    /**List<Payment_Milestones__c> updatePmList  = new List<Payment_Milestones__c> ();
    if(pmList != null && pmList.size() > 0){
        for(Payment_Milestones__c pm : pmList){
           pm.Demand_Raised__c = true;
           pm.Milestone_Due_Date__c = Date.today();
           updatePmList.add(pm);
        }
        update updatePmList;
    }**/
    Test.startTest();
    Demand__c d = new Demand__c();
    d.Booking__c = b.id;
    insert d;
    Receipt_Details__c rd = new Receipt_Details__c();
    rd.Status__c = 'Valid';
    rd.Transaction_Date__c = system.today();
    rd.Demand__c = d.Id;
    rd.Total_Amount_Apportined__c = 100000; 
    rd.Total_Tax_Apportioned__c = 10000;
    rd.Charges_Apportioned__c = 10000;
    rd.Taxes_Apportioned__c = 10000;
    rd.Receipts__c = r1.Id;
    rd.Interest_Amount_Paid__c = 1000;
    rd.Tax_on_Interest_Paid__c = 1000;
    rd.Interest_Amount_Waived__c = 500;
    rd.Tax_On_Interest_Waived__c = 500;
    rd.Debit_Tax_Apportioned__c = 10000;
    rd.Charge_1_Amount_Apportioned__c = 10000;
    rd.Charge_1_Tax_Apportioned__c = 1000;
    rd.Charge_2_Amount_Apportioned__c = 10000;
    rd.Charge_2_Tax_Apportioned__c = 1000;
    insert rd;
    
    List<Receipt_Details__c> rdrecord = [SELECT ID FROM Receipt_Details__c];
   	System.debug('i am rdrecord'+rdrecord[0]);
   	rdrecord[0].Status__c = 'Cancelled';
    update rdrecord[0];
    
    rdrecord[0].Status__c = 'Valid';
    update rdrecord[0];
    
    delete rdrecord[0];
    undelete rdrecord[0];
    Test.stoptest();
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
    pm.C1_Amount__c = 100000;          
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