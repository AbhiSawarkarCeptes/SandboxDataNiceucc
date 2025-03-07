@isTest
private class N_TestFileNote{

@isTest
private static void testFileNote(){

    Map<String, Id> recordMap = new Map<String,Id>();
    recordMap  = TestDataFactory.createMasterProject('Sobha'); 
    Id optyId = recordMap.get('OPPORTUNITY'); 
    Id unitId = recordMap.get('UNIT');
    Id towerId = recordMap.get('TOWER');
    Id subProjectId = recordMap.get('CLUSTER');
    
    Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];   
    //User u1 = [SELECT Id, Name FROM User WHERE Username LIKE '%ankur.pd@stetig.in%'];
    User u = new User(firstName = 'Test1', lastName = 'Test2', email='test12@stetig.in', Username= 'testfn@stetig.in', ProfileId = p.Id, alias= 'fn',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    insert u;
    
    User uNew = new User(firstName = 'Test3', lastName = 'Test4', email='test34@stetig.in', Username= 'testff@stetig.in', ProfileId = p.Id, alias= 'ff',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561233');
    insert uNew;   
        
    Quotation__c quote = createQuotation(recordMap.get('OPPORTUNITY'), recordMap.get('PLAN'), recordMap.get('UNIT'));
        
    Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
    
    Booking__c b = new Booking__c();
    b.Booking_Date__c = system.now().addDays(-10);
    b.Project__c = recordMap.get('PROJECT');
    b.Opportunity__c = optyId;
    b.Unit__c = unitId;
    b.status__c = 'Unprocessed';
    b.Quotation__c = quote.Id;
    b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
    b.Future_Correspondence_Contact__c = 'First Applicant';
    b.Agreement_Value__c = 6000000;
    b.Stage_of_Booking__c = 'EOI';
    insert b;
     
    quote.Booking__c = b.Id;
    update quote;     
    
    Opportunity opp = [SELECT Id, StageName, S_Active__c, Unit__c, Secondary_Sales_Manager__c,OwnerId FROM Opportunity  WHERE Id = :optyId];
    opp.StageName = 'Booking confirmed';
    opp.S_Active__c = true;
    opp.Unit__c = unitId;
    opp.Secondary_Sales_Manager__c = u.Id;   
    update opp;  
    
    Opportunity opp1 = [SELECT Id, Secondary_Sales_Manager__c FROM Opportunity  WHERE Id = :optyId];
    opp1.Secondary_Sales_Manager__c = uNew.id;
    update opp1;
    
    Team__c objTeam = new Team__c();
    objTeam.Name = 'File Note Approver Team';
    objTeam.Project__c = recordMap.get('PROJECT');
    objTeam.Team_Type__c = 'File Note Approver Team';
    objTeam.TowerLookup__c = towerId;
    objTeam.Sub_Project__c = subProjectId;
    objTeam.CRM__c = u.Id;
    objTeam.Audit__c = u.Id;
    objTeam.Finance__c = u.Id; 
    objTeam.CFO__c = u.Id;  
    insert objTeam;
    
    File_Note__c fn = new File_Note__c();            
    fn.Booking__c = b.Id;
    fn.Approval_Status__c = 'CFO Approved';
    fn.Quotation__c = quote.Id;
    fn.Opportunity__c = optyId;
    fn.Unit__c = unitId;
    fn.CRM__c = objTeam.CRM__c;
    fn.Finance__c = objTeam.Finance__c;
    fn.Audit__c = objTeam.Audit__c;            
    fn.CFO__c = objTeam.CFO__c;
    insert fn;
       
    Test.startTest();      
    PageReference pRef = Page.N_FileNotePage;
    Test.setcurrentPage(pRef);
    ApexPages.currentpage().getParameters().put('id', b.Id);
    N_FileNoteController f = new N_FileNoteController();
    f.createFileNote();    
    
    PageReference pRef1 = Page.N_FileNotePDF;
    Test.setcurrentPage(pRef1);
    ApexPages.currentpage().getParameters().put('id', fn.Id);
    N_FileNotePDFController f1 = new N_FileNotePDFController();
    
    fn.Approval_Status__c  = 'Audit Approved - Submitted to CFO';
    update fn;
    N_FileNotePDFController f2 = new N_FileNotePDFController();
    
    fn.Approval_Status__c  = 'Finance Approved - Submitted to Audit';
    update fn;
    N_FileNotePDFController f3 = new N_FileNotePDFController();
    
    fn.Approval_Status__c  = 'CRM Approved - Submitted to Finance';
    update fn;
    N_FileNotePDFController f4 = new N_FileNotePDFController();
    
    fn.Approval_Status__c  = 'CFO Rejected';
    update fn;
    N_FileNotePDFController f5 = new N_FileNotePDFController();
    
    fn.Approval_Status__c  = 'Audit Rejected';
    update fn;
    N_FileNotePDFController f6 = new N_FileNotePDFController();
    
    fn.Approval_Status__c  = 'Finance Rejected';
    update fn;
    N_FileNotePDFController f7 = new N_FileNotePDFController();
    
    fn.Approval_Status__c  = 'CRM Rejected';
    update fn;
    N_FileNotePDFController f8 = new N_FileNotePDFController();
      
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