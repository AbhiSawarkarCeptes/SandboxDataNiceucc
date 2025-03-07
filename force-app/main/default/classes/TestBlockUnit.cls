@isTest
private  Class TestBlockUnit{

    @isTest
    private static void generateBlockUnitTest()
    {
        Test.startTest();
        PageReference pRef = Page.BlockUnitPage;
        Test.setCurrentPage(pRef);
        //TDS_Calculation__c td = createTDScal ();
        
        Account acc = new Account();
        Id accId = acc.Id;
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp = createPaymentPlan();
       
        Project__c pr = new Project__c();
        pr = createProject();
        
        Opportunity opp = new Opportunity();
        opp = createOpp (accId, pr.id);             
        
        Tower__c tw = new Tower__c ();
        tw = createTower(pr.id);
        
        Unit__c ut = new Unit__c();
        ut = createUnit(pr.id,tw.id);
        
        Unit__c ut1 = new Unit__c();
        ut1 = createUnit(pr.id,tw.id);
        ut1.Unit_Status__c = 'Booked';
        update ut1;
        
        ProjectCharges__c pc = new ProjectCharges__c ();
        pc.Name = 'Basic';
        pc.Charge_Name__c = 'Basic';
        pc.project__c = pr.Id;
        pc.Tower__c = tw.Id;
        pc.Active__c = true;
        pc.ChargeBucket__c = 'Agreement Value';
        insert pc;
        
        ProjectCharges__c pc1 = new ProjectCharges__c ();
        pc1.Name = 'Floor Rise';
        pc1.Charge_Name__c = 'Floor Rise';
        pc1.project__c = pr.Id;
        pc1.Tower__c = tw.Id;
        pc1.Active__c = true;
        pc1.ChargeBucket__c = 'Agreement Value';
        insert pc1;

        ProjectCharges__c pc2 = new ProjectCharges__c ();
        pc2.Name = 'PLC';
        pc2.Charge_Name__c = 'PLC';
        
        pc2.project__c = pr.Id;
        pc2.Tower__c = tw.Id;
        pc2.Active__c = true;
        pc2.ChargeBucket__c = 'Agreement Value';
        insert pc2;        
        
        Quotation__c quote = new Quotation__c();
        quote = createQuotation(opp.id,pp.id,ut.id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10); 
        b.Quotation__c = quote.Id;
        insert b;
                  
        Opportunity opp1 = new Opportunity();                   
        opp1.Name = 'TestOpp1';
        opp1.Accountid = accId;        
        opp1.CloseDate = System.today().addDays(30);
        opp1.StageName = 'Booking Confirmed';
        opp1.Project__c = pr.Id;
        opp1.Booking__c = b.Id;        
        insert opp1;
        
        Payment_Milestones__c pm1 = new Payment_Milestones__c();
        pm1 = createPaymentMilestone1(quote.id);
        
        //ApexPages.currentPage().getParameters().put('qid',quote.id);
        ApexPages.currentPage().getParameters().put('optyid',opp.id);
        ApexPages.currentPage().getParameters().put('unitid',ut.id);
        
        BlockunitController buc = new BlockunitController();
        buc.isError = false;
        //buc.bu.Approver__c = quote.Level_One_Approver__c; 
        buc.Save();
        buc.Cancel();
        buc.selectedQuote = quote.Id;
        List<SelectOption> Listquote = buc.getQuote;
        /*sendQuoteApprovalEmail sqe = new sendQuoteApprovalEmail();
        sqe.qId = quote.Id;
        sqe.getQuotationDetails();*/
        
        ApexPages.currentPage().getParameters().put('optyid', opp1.id); // For "You cannot block unit with this opportunity" error
        ApexPages.currentPage().getParameters().put('unitid', ut1.id); // For "Unit is not Available" error
        
        BlockunitController buc1 = new BlockunitController();  
        buc1.Save();
        buc1.Cancel();
        buc1.selectedQuote = quote.Id;
        List<SelectOption> Listquote1 = buc.getQuote;
        
        Test.stopTest();                
    }         
    
    private static Quotation__c createQuotation (Id opp, Id pp, Id ut1)
    {
       
        Quotation__c objQuote1 = new Quotation__c();
        
        User user  = createUserSysAdmin('One','Galvatron', 'galvatron1@radius.com', 'galvatron1@radius.com');       
        objQuote1.Opportunity__c = opp ;
        objQuote1.Payment_Plan__c =pp ;
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
        objQuote1.Unit__c = ut1;
        objQuote1.Final_Approved_Date__c = System.today();
        objQuote1.Level_One_Approver__c = user.id;
        //objQuote1.Quotation_Valid_Till__c = System.today();
        
        insert objQuote1;
        return objQuote1;
    }
    
    public static User createUserSysAdmin(string fn, string ln, string username, string email) {
    
    Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
    User umanager = [Select Id, Name from User where Username like '%neha%' LIMIT 1];

    User u = new User(firstName = fn, lastName = ln, email=email,Username= username, ProfileId = p.Id, alias= ln.substring(0,7),EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230', ManagerId = umanager.Id);
    insert u;
    return u;
    
  }
        
     private static Opportunity createOpp (Id accId, Id projId) {
             //Account a = createPAAccount();
             //project__c p = createProject();
             User u  = createUserSysAdmin('Test1', 'Test23456789', 'test123@radius.com', 'test123@radius.com'); 
             
                Opportunity objOpp = new Opportunity();
                objopp.Name = 'TestOpp';
                objopp.Accountid = accId;
                objopp.Sales_Manager_lookup__c = u.Id;
                objopp.CloseDate = System.today().addDays(30);
                objopp.StageName = 'Qualification';//'Unit Booked';
                objopp.Project__c = projId;
                
                insert objOpp;
                Opportunity objOppToreturn = [Select id, Project__c, AccountId, StageName 
                                                      from Opportunity where id =:objOpp.id];
                return objOppToreturn ;
         }
         private static Payment_Plan__c createPaymentPlan () {
             //Account a = createPAAccount();
             //project__c p = createProject();
             Payment_Plan__c pp = new Payment_Plan__c();
             pp.NoofMilestones__c = 1;
             insert pp;
             return pp;
         }
         
         private static Unit__c createUnit( Id prId, Id twId) {
         Unit__c objUnit = new Unit__c ();
         objUnit.name = 'testUnit1';
         objUnit.Project_Property_Type__c = 'Residential';
         objUnit.Carpet_Area__c = 1233;
         objUnit.Chargeable_Area__c = 1234; 
         objUnit.Balcony_Area_Sq_Ft__c = 123;
         objUnit.Project__c = prId;
         objUnit.Tower__c = twID;
         objUnit.Utility_Area__c = 123;
         objUnit.Courtyard_Area_Sq_Ft__c = 1212;
         objUnit.RERA_Terrace_Area_Sq_Ft__c = 1223;
         objUnit.Super_Builtup_Area_Sq_Ft__c = 1233;
         objUnit.RERA_Other_Usable_Area_Sq_Ft__c = 345;
         objUnit.Garden_Area_Sq_Ft__c = 7654;
         objUnit.Chargeable_Garden_Area_Sq_Ft__c = 8765;
         objUnit.Chargeable_Courtyard_Area_Sq_Ft__c = 8765;
         objUnit.Chargeable_Terrace_Area_Sq_Ft__c = 7654;
         objUnit.Unit_Status__c = 'Available';
         insert objUnit;
         return objUnit;
     }
     
     
     private static Tower__c createTower( Id projID) {
         Tower__c tw = new Tower__c();
         
         tw.Name = 'Maple B';
         tw.project__c = projID;
         insert tw;
         return tw;
     }
     
     private static Project__c createProject() {
         Project__c proj = new Project__c();
         
         proj.Configuration__c='1.5 BHK';
         proj.Max_Budget__c=10000;
         proj.Min_Budget__c=10000;
         proj.Expiry_Days__c = 10;
         proj.name = 'ParkWest';
         proj.Project_Code__c = 'test';
         insert proj;
         return proj;
     }
     
     private static Payment_Milestones__c createPaymentMilestone1 (Id quote) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Charge1Percentage__c = 1;
        pm.Number_Of_Days__c = 25;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 10000;          
        pm.C1_CGST__c = 41250;
        pm.C1_SGST__c = 2475;
        
        insert pm;
        return pm;
     }
}