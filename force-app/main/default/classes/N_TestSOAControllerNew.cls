@isTest
public class N_TestSOAControllerNew{

@isTest
private static void testSOA(){

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
    b.Primary_Applicant_Email__c = 'test123@stetig.in';
    insert b;
     
    quote.Booking__c = b.Id;
    update quote;
     
    Opportunity opp = [SELECT Id, StageName, S_Active__c, Unit__c, Booking__c FROM Opportunity  WHERE Id = :optyId];
    opp.StageName = 'Booking confirmed';
    opp.S_Active__c = true;
    opp.Unit__c = unitId;
    opp.Booking__c = b.Id;
    update opp;
     
    Unit__c u = [SELECT Id FROM Unit__c WHERE Id = :unitId];
    u.Unit_Status__c = 'Sold';
    u.Booking__c = b.Id;
    u.Customers__c = opp.Id;
    update u;
    
    Demand__c d = new Demand__c();
    d.Milestone_Name__c = 'Token';  
    d.Charge_1_Name__c = 'Basic';
    d.Charge_1_Lookup__c =  recordMap.get('BASIC');    
    d.Charge_1_Demanded__c = pm1.C1_Amount__c;
    d.Charge_1_CGST__c = pm1.C1_CGST__c;
    d.Tax_Rate__c = 'VAT 5%';
    d.Invoice_Date__c = System.Today();
    d.GL_Date__c = System.Today();
    d.Due_Date__c = pm1.Milestone_Due_Date__c;
    d.Project__c = recordMap.get('PROJECT');
    d.Booking__c = b.Id;
    d.Unit__c = unitId;
    d.Payment_Milestones__c = pm1.Id;
    d.Corporate_Collection_Control_Report__c = 50000; 
    d.Registration_Collection_Control_Report__c = 20000;
    d.Payment_Towards__c = 'ESCROW Account';
    insert d;
    
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
    
    Transfer_Amount__c ta = new Transfer_Amount__c();
    ta.Booking__c = b.Id;
    ta.Opportunity__c = optyId ;
    ta.Unit__c = unitId;
    ta.Mode_of_Payment__c = 'Cheque';
    ta.Instrument_No__c = '123410';
    ta.Drawee_Bank__c = 'Emirates Islamic';
    ta.Amount__c = 100000;
    ta.GL_Date__c = System.today();
    ta.Transfer_Date__c = System.today();
    insert ta;
   
    Test.startTest();      
    PageReference pRef = Page.N_CustomerSOAPage;
    Test.setcurrentPage(pRef);
    Apexpages.currentPage().getParameters().put('id', opp.Id);
    N_CustomerSOAController c = new N_CustomerSOAController();
    N_CustomerSOAControllerUnProce cls = new N_CustomerSOAControllerUnProce();
    
    PageReference pRef1 = Page.N_OtherSOAPage;
    Test.setcurrentPage(pRef1);
    Apexpages.currentPage().getParameters().put('id', opp.Id);
    N_OtherSOAController o = new N_OtherSOAController();
    
    PageReference pRef2 = Page.N_SendSOAPage;
    Test.setcurrentPage(pRef2);
    Apexpages.currentPage().getParameters().put('id', opp.Id);
    N_SendSOAController s = new N_SendSOAController();
    s.sendAttachedSOA();
    Test.stopTest(); 
}

private static Quotation__c createQuotation (Id opp, Id pp, Id ut1){       
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
    
private static Payment_Milestones__c createPaymentMilestone (Id quote) {        
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