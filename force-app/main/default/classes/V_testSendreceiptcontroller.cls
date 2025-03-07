@isTest
public class V_testSendreceiptcontroller {

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
    
    User u1 =new User();
    u1.LastName ='Test';
   // u1.ManagerId ='0051j000000Gcg8AAC';
    u1.Email='test@sobharealty.com';
    u1.Username='test1@sobharealty.com';
    u1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    u1.Alias ='test';
    u1.TimeZoneSidKey ='Asia/Dubai';
    u1.LocaleSidKey ='en_IN';
    u1.EmailEncodingKey ='UTF-8';
    u1.LanguageLocaleKey='en_US';
    insert u1;
    
    
    Requester__c rq = new Requester__c();
    rq.Mode_Of__c ='Cash';
    rq.Currency__c ='AED';
    rq.Total_Amount__c =200000.00;
    rq.OwnerId =u1.Id;
    insert rq;
    
    Receipt__c r = new Receipt__c();
    r.Booking__c = b.Id;
    r.Opportunity__c = optyId ;
    r.Project__c = recordMap.get('PROJECT');
    r.Project_Unit__c = unitId;
    r.Amount_Rs__c = 100000;
    r.Total_Amount__c = 100000;  
    r.Mode__c = 'Others';
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
    r.Requester__c =rq.Id;
    
    insert r;
    

    Test.startTest();      
    PageReference pRef3 = Page.PrintReceiptSobhaDubai;
    Test.setcurrentPage(pRef3);
    Apexpages.currentPage().getParameters().put('id', r.Id);
    sendreceiptcontroller sr = new sendreceiptcontroller();
    sr.sendAttachedReceipt(); 
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