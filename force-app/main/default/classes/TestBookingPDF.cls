@isTest
private  Class TestBookingPDF {

@isTest
    private static void generateBookingPdfTest(){
                
        Project__c pr = new Project__c();
        pr = createProject();   
        
        Tower__c tw = new Tower__c ();
        tw = createTower(pr.id);
        
        List<Unit__c> unitsList = new List<Unit__c>();
        Unit__c ut = new Unit__c();
        ut = createUnit(pr.id,tw.id);  
        unitsList.add(ut);
        
        Unit__c ut1 = new Unit__c();
        ut1 = createUnit(pr.id,tw.id);  
        unitsList.add(ut1);
        insert unitsList;
            
        Account acc = new Account();
        Id accId = acc.Id;
        
        Opportunity opp = new Opportunity();
        opp = createOpp ( accId, pr.id); 
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp = createPaymentPlan();
            
        Quotation__c quote = new Quotation__c();
        quote = createQuotation(opp.id,pp.id,ut.id);
        
        Discounts_Applied__c da1 = new Discounts_Applied__c();
        da1 = createDiscount(quote.id);

        List<User> User = [Select Id, Name, IsActive from User where isActive = True];

        Channel_Partner__c cp = new  Channel_Partner__c();
        cp.Contact_Person__c = 'Test CP';
        cp.Sales_Manager__c = User[0].Id;
        cp.Channel_Relationship_Manager__c = User[0].Id;
        cp.Sales_Manager_s_Line_Manager__c = User[0].Id;
        cp.Channel_Relationship_Head__c = User[0].Id;
        insert cp;
        
        List<Booking__c> bookingsList = new List<Booking__c>();
        Booking__c b = new Booking__c();
        b = createBooking(ut.id, pr.id, quote.id, opp.Id, cp); 
        bookingsList.add(b);
///// Defining Sobha Connect 
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Name__c = 'Sobha Connect';
        sc.Mobile_No__c = '1741854512';
        sc.Contact_Person__c = 'Test1 Test2'; 
        insert sc;        
        
        Booking__c b1 = new Booking__c();
        b1 = createBooking(ut1.id, pr.id, quote.id, opp.Id, cp);
        bookingsList.add(b1);
        insert bookingsList;

        b1.Source_of_Booking__c = 'Sobha Connect';
        b1.Sobha_Connect__c = sc.Id;
        update b1;

        Test.startTest();
        
        //List<Applicant_Details__c> applicationList = new List<Applicant_Details__c>();
        Applicant_Details__c a = new Applicant_Details__c ();
        a = createApplicantDetails(b.id);  
        //applicationList.add(a);
        
        Applicant_Details__c a1 = new Applicant_Details__c ();
        a1 = createApplicantDetails(b1.id);  
        //applicationList.add(a1); 
        //insert applicationList;        

// Defining Project Charges 
        List<ProjectCharges__c> pjList = new List<ProjectCharges__c>();          
        ProjectCharges__c pc = new ProjectCharges__c ();
        pc.Name = 'Basic';
        pc.Charge_Name__c = 'Basic';
        pc.project__c = pr.Id;
        pc.Tower__c = tw.Id;
        pc.Active__c = true;
        pc.Calculatedas__c = 'Rate list at Unit level';
        pc.ChargeBucket__c = 'Agreement Value';
        pjList.add(pc);
        
        ProjectCharges__c pc1 = new ProjectCharges__c ();
        pc1.Name = 'Floor Rise';
        pc1.Charge_Name__c = 'Floor Rise';
        pc1.project__c = pr.Id;
        pc1.Tower__c = tw.Id;
        pc1.Active__c = true;
        pc1.Calculatedas__c = 'Rate list at Unit level';
        pc1.ChargeBucket__c = 'Agreement Value';
        //insert pc1;
        pjList.add(pc1);

        ProjectCharges__c pc2 = new ProjectCharges__c ();
        pc2.Name = 'PLC';
        pc2.Charge_Name__c = 'PLC';       
        pc2.project__c = pr.Id;
        pc2.Tower__c = tw.Id;
        pc2.Active__c = true;
        pc2.Calculatedas__c = 'Rate list at Unit level';
        pc2.ChargeBucket__c = 'Agreement Value';
        //insert pc2;
        pjList.add(pc2);
        
        ProjectCharges__c pc3 = new ProjectCharges__c ();
        pc3.Name = 'DLD Admin Fees';
        pc3.Charge_Name__c = 'Stamp Duty';
        pc3.project__c = pr.Id;
        pc3.Tower__c = tw.Id;
        pc3.Active__c = true;
        pc3.Calculatedas__c = 'Rate list at Unit level';
        pc3.ChargeBucket__c = 'Stamp Duty and Registration';
        //insert pc3; 
        pjList.add(pc3); 
        
        insert pjList;
 
/// Defining Rate List  
        List<Rate_List__c> rlList = new List<Rate_List__c>();

        Rate_List__c rl = new Rate_List__c();
        rl.Unit__c = ut.Id;
        rl.Type__c = 'Lumpsum';
        rl.Lumpsum_Amount__c = 100000;
        rl.ProjectCharges__c = pc.Id;
        rlList.add(rl);
        //insert rl; 
        
        Rate_List__c r2 = new Rate_List__c();
        r2.Unit__c = ut.Id;
        r2.Type__c = 'Lumpsum';
        r2.Lumpsum_Amount__c = 100000;
        r2.ProjectCharges__c = pc1.Id;
        //insert r2;
        rlList.add(r2); 
        
        Rate_List__c r3 = new Rate_List__c();
        r3.Unit__c = ut.Id;
        r3.Type__c = 'Lumpsum';
        r3.Lumpsum_Amount__c = 100000;
        r3.ProjectCharges__c = pc2.Id;
        //insert r3; 
        rlList.add(r3); 
        
        Rate_List__c r4 = new Rate_List__c();
        r4.Unit__c = ut.Id;
        r4.Type__c = 'Lumpsum';
        r4.Lumpsum_Amount__c = 100000;
        r4.ProjectCharges__c = pc3.Id;
        //insert r4;    
        rlList.add(r4); 

        insert rlList;

//// Defining Project Construction Stages        
        Project_Construction_Stages__c pgs = new Project_Construction_Stages__c();
        pgs.Planned_date_of_completion__c = System.today().addDays(30);
        pgs.project__c = pr.id;
        pgs.Tower__c = tw.id;
        pgs.Name = 'On Completion';
        insert pgs;        
                               
        Payment_Plan_Milestones__c pm = new Payment_Plan_Milestones__c();
        pm = createPaymentPlanMilestone(pp.id, pgs.id); 
 
        Payment_Milestones__c pm1 = new Payment_Milestones__c();
        pm1 = createPaymentMilestone1(quote.id, pgs, pc.Id, pc1.Id, pc2.Id, pc3.Id);
        
        Payment_Milestones__c pm2 = new Payment_Milestones__c();
        pm2 = createPaymentMilestone1(quote.id, pgs, pc.Id, pc1.Id, pc2.Id, pc3.Id);
        
        //Test.startTest();
        PageReference pRef = Page.BookingPDFDubai;
        Test.setCurrentPage(pRef);   
        
        ApexPages.currentPage().getParameters().put('id', b.id);
        BookingPDFDubaiController bkp = new BookingPDFDubaiController();
        
        ApexPages.currentPage().getParameters().put('id', b1.id);
        BookingPDFDubaiController bkp1 = new BookingPDFDubaiController();
        
        /*ApexPages.currentPage().getParameters().put('id', b.id);
        filenoteController fnc = new filenoteController();
        
        ApexPages.currentPage().getParameters().put('id', b1.id);
        filenoteController fnc1 = new filenoteController();*/
   
  ////// For SPA Particular      
        PageReference pRef1 = Page.N_SPAPDFPage;
        Test.setCurrentPage(pRef1);          
        ApexPages.currentPage().getParameters().put('id', b.id);
        N_SPAPDFController spa = new N_SPAPDFController();  
        
        pm2.Milestone_Due_Date__c = System.today().addDays(20);
        pm2.Demand_Raised__c  = true;
        update pm2;
        ApexPages.currentPage().getParameters().put('id', b.id);
        N_SPAPDFController spa2 = new N_SPAPDFController();

        pm2.Milestone_Due_Date__c = System.today().addDays(20);
        pm2.Demand_Raised__c  = false;
        pm2.Is_Combination_Milestone__c = true;
        pm2.Milestone_Type_edit__c = 'Date Linked';
        update pm2;
        ApexPages.currentPage().getParameters().put('id', b.id);
        N_SPAPDFController spa3 = new N_SPAPDFController();
        
        
        
        
        Test.stopTest();
    }
    
    private static Quotation__c createQuotation (Id opp, Id pp, Id ut1) {                
        Quotation__c objQuote1 = new Quotation__c();
        
        objQuote1.Opportunity__c = opp;
        objQuote1.Payment_Plan__c = pp;
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
        
        objQuote1.Car_Park_Type_1__c = 'Open';
        objQuote1.Car_Park_Count_1__c = 1;
        objQuote1.Earmarked_Type_1__c = 'Open';
        objQuote1.Earmarked_Count_1__c = 1;
             
        objQuote1.Unit__c = ut1;              
        insert objQuote1;
        return objQuote1;
    }        
     
     private static Opportunity createOpp (Id accId, Id projId) {                         
                Opportunity objOpp = new Opportunity();
                objopp.Name = 'TestOpp';
                objopp.Accountid = accId;
                objopp.CloseDate = System.today().addDays(30);
                objopp.StageName = 'Qualification';//'Unit Booked';
                objopp.Project__c = projId;               
                insert objOpp;
                Opportunity objOppToreturn = [Select id,Project__c,AccountId ,StageName from Opportunity where id =:objOpp.id];                                                     
                return objOppToreturn ;
         }
         
    private static Payment_Plan__c createPaymentPlan () {          
             Payment_Plan__c pp = new Payment_Plan__c();
             pp.NoofMilestones__c = 1;
             insert pp;
             return pp;
         }
    
    private static Booking__c createBooking(Id ut, Id pr, Id q, Id opty, Channel_Partner__c cp) {

        Booking__c bk = new Booking__c();          
        bk.Quotation__c = q;
        bk.Booking_Date__c = system.now();
        bk.Unit__c = ut;
        bk.Project__c = pr;
        bk.Source_of_Booking__c = 'Channel Partner';
        bk.Channel_Partner__c = cp.Id;   
        bk.Opportunity__c = opty;
        bk.Agreement_Value__c = 3000000;     
        //insert bk;
        return bk;
    }
    
    private static Applicant_Details__c createApplicantDetails(Id book) {  
        Applicant_Details__c applicant = new Applicant_Details__c ();
        applicant.Name = 'New Man1';
        applicant.Salutation__c = 'Mr.';       
        applicant.DOB__c = system.today();
        applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        applicant.Pincode__c = 444444;
        applicant.Country__c = 'India';
        applicant.City__c = 'Nagpur'; 
        applicant.Applicant_Number__c = 'Primary Applicant';
        applicant.Mailing_Address__c = '101 Kumar Vastu';        
        applicant.Mailing_Country__c= 'India';
        applicant.Mailing_State__c = 'Gujarat';
        applicant.Mailing_City__c = 'Ahmedabad';
        applicant.State__c = 'Gujarat';   
        applicant.Mailing_Pincode__c = 123456;    
        applicant.Mobile_Number__c = '909090901';
        applicant.Email_Address__c = 'newman@justnow1.com'; 
        applicant.Booking__c = book;  
        applicant.Valid_Until_Passport__c = System.today().addDays(200);      
        insert applicant;
        return applicant;
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
         //insert objUnit;
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
     
    private static Discounts_Applied__c createDiscount(Id q1) {
        Discounts_Applied__c da = new Discounts_Applied__c();
        da.Quotation__c = q1;       
        insert da;
        return da;
    }
    
    private static ProjectCharges__c createProjectCharges (string p, Id t){
        ProjectCharges__c pc = new ProjectCharges__c();
        pc.Name = 'Basic';
        pc.project__r.Name = p;
        pc.Tower__c = t;
        insert pc;
        return pc;
     }
     
     private static Payment_Plan_Milestones__c createPaymentPlanMilestone (Id pp, Id pgs) {               
         Payment_Plan_Milestones__c pm = new Payment_Plan_Milestones__c();
         pm.Plan_Milestone_Type__c = 'Construction Linked';
         pm.Number_Of_Days_Plan__c = 0;       
         pm.Milestone_Name_Picklist__c = '<<Construction Stage Name>>';
         pm.Project_Construction_Stages__c = pgs;
         pm.Payment_Plan__c = pp;
         insert pm;
         return pm;
     }
     
     private static Payment_Milestones__c createPaymentMilestone1 (Id quote, Project_Construction_Stages__c pgs, Id basic, Id floorrise, Id plc, Id dldadmin) {
        Payment_Milestones__c pm = new Payment_Milestones__c();     
        pm.Milestone_Type_edit__c = 'Construction Linked';
        pm.Milestone_Name__c = 'On Completion';
        pm.Project_Construction_Stages__c = pgs.Id;
        pm.Number_Of_Days__c = 0;
        pm.Milestone_Due_Date__c = System.Today().addDays(10);
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge_1_Lookup__c = basic;
        pm.Charge1Percentage__c = 100;
        
        pm.Charge2Name__c = 'Floor Rise';
        pm.Charge_2_Lookup__c = floorrise;
        pm.Charge2Percentage__c = 100;
        
        pm.Charge3Name__c = 'PLC';
        pm.Charge_3_Lookup__c = plc;
        pm.Charge3Percentage__c = 100;
        
        pm.Charge4Name__c = 'DLD Admin Fees';
        pm.Charge_4_Lookup__c = dldadmin;
        pm.Charge4Percentage__c = 100;
        
        insert pm;
        return pm;
     }  
}