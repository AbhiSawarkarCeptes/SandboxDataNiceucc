public with sharing class Mobile_TestUtil {
    public Mobile_TestUtil() {

    }
    
    public static void createUnits() {
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
    }

    public static void createBooking() {
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
    }

    public static Opportunity createOpp (Id accId, Id projId) {                         
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
 
    public static Payment_Plan__c createPaymentPlan () {          
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.NoofMilestones__c = 1;
        insert pp;
        return pp;
    }

    public static Booking__c createBooking(Id ut, Id pr, Id q, Id opty, Channel_Partner__c cp) {

    Booking__c bk = new Booking__c();          
    bk.Quotation__c = q;
    bk.Booking_Date__c = system.now();
    bk.Unit__c = ut;
    bk.Project__c = pr;
    bk.Source_of_Booking__c = 'Channel Partner';
    bk.Channel_Partner__c = cp.Id;   
    bk.Opportunity__c = opty;
    bk.Agreement_Value__c = 3000000;  
    bk.Primary_Applicant_Email__c = 'test@example.com'; 
    //insert bk;
    return bk;
    }

    public static Applicant_Details__c createApplicantDetails(Id book) {  
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
    applicant.Email_Address__c = 'test@example.com'; 
    applicant.Booking__c = book;  
    applicant.Valid_Until_Passport__c = System.today().addDays(200);      
    insert applicant;
    return applicant;
    }

    public static Unit__c createUnit( Id prId, Id twId) {
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
 
    public static Tower__c createTower( Id projID) {
    Tower__c tw = new Tower__c();        
    tw.Name = 'Maple B';
    tw.project__c = projID;
    insert tw;
    return tw;
    }

    public static Project__c createProject() {
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

    public static Discounts_Applied__c createDiscount(Id q1) {
    Discounts_Applied__c da = new Discounts_Applied__c();
    da.Quotation__c = q1;       
    insert da;
    return da;
    }

    public static ProjectCharges__c createProjectCharges (string p, Id t){
    ProjectCharges__c pc = new ProjectCharges__c();
    pc.Name = 'Basic';
    pc.project__r.Name = p;
    pc.Tower__c = t;
    insert pc;
    return pc;
    }

    public static Payment_Plan_Milestones__c createPaymentPlanMilestone (Id pp, Id pgs) {               
    Payment_Plan_Milestones__c pm = new Payment_Plan_Milestones__c();
    pm.Plan_Milestone_Type__c = 'Construction Linked';
    pm.Number_Of_Days_Plan__c = 0;       
    pm.Milestone_Name_Picklist__c = '<<Construction Stage Name>>';
    pm.Project_Construction_Stages__c = pgs;
    pm.Payment_Plan__c = pp;
    insert pm;
    return pm;
    }

    public static Payment_Milestones__c createPaymentMilestone1 (Id quote, Project_Construction_Stages__c pgs, Id basic, Id floorrise, Id plc, Id dldadmin) {
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

    public static Quotation__c createQuotation (Id opp, Id pp, Id ut1) {                
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
}