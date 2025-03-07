@isTest
public class N_TestDemandReversal{
@TestSetup
static void makeData(){
    Map<String, Id> recordMap = new Map<String,Id>();
    recordMap  = TestDataFactory.createMasterProject('Sobha'); 
    Id optyId = recordMap.get('OPPORTUNITY'); 
    Id unitId = recordMap.get('UNIT');
    Id towerId = recordMap.get('TOWER');
    
    Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
    
    Quotation__c quote = createQuotation(recordMap.get('OPPORTUNITY'), recordMap.get('PLAN'), recordMap.get('UNIT'));
    
    Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
    
    Booking__c b = new Booking__c();
    b.Booking_Date__c = system.now().addDays(-10);
    b.Project__c = recordMap.get('PROJECT');
    b.Opportunity__c = optyId;
    b.Unit__c = unitId;
    b.status__c = 'Processed';
    b.Quotation__c = quote.Id;
    b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
    b.Future_Correspondence_Contact__c = 'First Applicant';
    b.Agreement_Value__c = 6000000;
    b.Stage_of_Booking__c = 'Booked';
    insert b;
     
    quote.Booking__c = b.Id;
    update quote;
    
    Receipt__c r = new Receipt__c();
    r.Booking__c = b.Id;
    r.Opportunity__c = optyId ;
    r.Project__c = recordMap.get('PROJECT');
    r.Project_Unit__c = unitId;
    r.Amount_Rs__c = 100000;
    r.Total_Amount__c = 100000;  
    r.Mode__c = 'Cheque';
    r.Cheque_DD__c = '123456';
    r.DraweeBank__c = 'Habib Bank AG Zurich';
    r.Cheque_DD_Date__c = system.today();
    r.Receipt_Status__c = 'Cleared';   
    r.Physically_Cheque_Received__c = true;
    r.Banking__c = 'Payment Successful';
    r.Reason_for_rejection_new__c = 'Accepted';
    r.Payment_Towards__c = 'ESCROW Account';
    r.GL_Date__c = System.Today(); //// credit note creation date
    r.Receipt_Date__c = System.Today(); //// receipt creation date
    r.Cheque_DD_Date__c = System.Today();    
    r.Registration_Collection_Control_Report__c = 20000;
    r.Corporate_Collection_Control_Report__c = 30000;                          
    insert r;
}
@isTest
private static void testDemandReversal(){

    
    Payment_Milestones__c pm1 = [select id,Milestone_Due_Date__c from Payment_Milestones__c limit 1];
    Booking__c b = [SELECT ID FROM Booking__c limit 1];
    String unitId = [SELECT ID FROM Unit__c limit 1].Id;
    Receipt__c r = [SELECT ID FROM Receipt__c limit 1];
    Test.startTest(); 
   
    Demand__c d = new Demand__c();
    d.Milestone_Name__c = 'Debit note for DLD Charges';       
    d.Debit_Demanded__c = 100000;
    d.Debit_CGST__c = 0;
    d.Tax_Rate__c = 'OUT OF SCOPE';
    d.Debit_Type__c = 'Interest Charges';
    d.Invoice_Date__c = System.Today();
    d.GL_Date__c = System.Today();
    d.Due_Date__c = pm1.Milestone_Due_Date__c;
    //d.Project__c = recordMap.get('PROJECT');
    d.Booking__c = b.Id;
    d.Unit__c = unitId;
    d.Corporate_Collection_Control_Report__c = 50000; 
    d.Registration_Collection_Control_Report__c = 20000;
    d.Payment_Towards__c = 'Corporate Account';
    insert d;
    
    /*Receipt_Details__c rd = new Receipt_Details__c();
    rd.Demand__c = d.Id; 
    rd.Receipts__c = r.Id;
    rd.Transaction_Date__c = System.Today();
    rd.Status__c = 'Valid';
    rd.Total_Amount_Apportined__c = 100000;
    rd.Charges_Apportioned__c = 100000;
    rd.Debit_Charge_Name__c = 'DLD Charges';
    rd.Debit_Amount_Apportioned__c = 100000;
    insert rd;
       */
     
    PageReference pRef = Page.N_DemandReversalPage;
    Test.setcurrentPage(pRef);
    Apexpages.Currentpage().getParameters().put('id', d.Id);
    N_DemandReversalController de = new N_DemandReversalController();
    checkRecursion.resetFirstRun();
    de.createCreditNote();
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
    
public static Payment_Milestones__c createPaymentMilestone (Id quote) {        
    Payment_Milestones__c pm = new Payment_Milestones__c();
    pm.Time_Period__c = 'Days';
    pm.Number_Of_Days__c = 10;
    pm.Milestone_Due_Date__c = System.today().addDays(10);
    pm.Milestone_Type_edit__c = 'Date Linked';
    pm.Is_Combination_Milestone__c = false;
    pm.Quotation__c = quote;
    pm.Charge1Name__c = 'Basic';
    pm.Charge1Percentage__c = 5;
    pm.C1_Amount__c = 100000;          
    pm.C1_CGST__c = 12369;
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