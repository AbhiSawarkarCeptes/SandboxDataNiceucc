@isTest
public class DemandAutoGenerationBatchTest {
    @isTest
    private static void demands() {
        
        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Trade Receivable';
        amList.add(am1);
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Discount/rebate credit note';
        amList.add(am2);
        insert amList;
        
        Map<String, Id> recordMap = new Map<String,Id>();

        Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = true;
        bypassSettingInstance.Bypass_Booking_Trigger__c = true;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = true;
        bypassSettingInstance.Bypass_Unit_Trigger__c = true;
        bypassSettingInstance.Bypass_All__c = true;
        bypassSettingInstance.Bypass_All_Triggers__c = true;
        bypassSettingInstance.Bypass_All_Validations_Rules__c = true;
        bypassSettingInstance.ByPass_Auto_Cancellation__c = true;
        bypassSettingInstance.Bypass_Booking_Welcome_Email__c = true;
        bypassSettingInstance.Bypass_Demand_Trigger__c = true;
        bypassSettingInstance.Bypass_Lead_Trigger__c = true;
        bypassSettingInstance.Bypass_OldBrokerAutoDeletion__c = true;
        bypassSettingInstance.Bypass_Receipt_Trigger__c = true;

        upsert bypassSettingInstance;
        
        Legal_Entity__c objlglentity = new Legal_Entity__c();
        objlglentity.Name ='RS';
        objlglentity.RDS_Company_Code__c='rs';
        objlglentity.RDS_Service_Tax_No__c= '123456789012345';
        objlglentity.RDS_Company_Name__c='111';
        objlglentity.RDS_Address1__c='123';
        objlglentity.RDS_Address2__c='234';
        objlglentity.RDS_City__c='delhi';
        objlglentity.RDS_Pin_Code__c='201301';
        objlglentity.RDS_Phone__c='9953528045';           
        insert objlglentity;
        
        // Project Creation
        Project__c objpr = new Project__c();
        objpr.Project_Code__c = 'T35';
        objpr.Name = 'pName';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Company_Code__c = objlglentity.Id;
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Stage__c='Launch';
        objpr.Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
        objpr.Project_Property_Type__c = 'Residential';
        objpr.Sales_Manager_Discount__c = 400;
        objpr.Site_Head_Discount__c  = 50;
        objpr.Sales_Head_Discount__c = 1000;
        objpr.Service_Tax_Required_On_Token_Amount__c = true;
        objpr.Car_Park_Type_1__c = 'Stack';
        objpr.Charge_Value_1__c = 200000;
        objpr.Car_Park_Type_2__c = 'Open';
        objpr.Charge_Value_2__c = 300000;
        objpr.NPV__c = 12;
        insert objpr;
        
        Cluster__c clus = new Cluster__c();
        clus.Name = 'Cluster 1';
        clus.Project__c  = objpr.Id;
        insert clus; 
        
        Discount__c ds = new Discount__c();
        ds.Type__c = 'PSF';
        ds.Reason__c = 'Armed Forces';
        ds.PSF_Amount__c = 100;
        ds.Project__c = objpr.Id;
        ds.Cluster__c = clus.Id; // Added by Neha on 09/01/19
        ds.applied__c = true;
        ds.Special_Discount__c = true; 
        ds.Start_Date__c = system.today().addDays(-10);
        insert ds;
        
        
        
        Tower__c t = new Tower__c();
        t.Name = 'Phase III - Building 5';
        t.Project__c = objpr.Id;
        t.Cluster__c = clus.Id; 
        insert t;
        
        Unit__c objPU1 = new Unit__c();    
        objPU1.Name = 'TestFive';      
        objPU1.Project__c = objpr.Id;            
        objPU1.Unit_status__c='Available';
        objPU1.Chargeable_Area__c = 936;
        objPU1.Carpet_Area__c = 452;
        objPU1.Tower__c = t.Id;
        objPU1.Active_Inactive__c = 'Active';
        objPU1.Carpet_Area_in_Sq_Mts__c = 45.02;
        objPU1.Cupboard_Area_in_Sq_Mtrs__c = 3.95;
        objPU1.Enclosed_Balcony_in_Sq_Mtrs__c = 2.66;
        objPU1.Floor__c = 2;
        objPU1.Not_Available_for_Sales__c = False;
        insert objPU1;
        
        Account objac = new Account();
        objac.FirstName = 'Shock';
        objac.LastName = 'Wave';
        objac.Correspondence_Address__c = 'Delhi';
        objac.Category__c = 'General';
        objac.Unit__c = objPU1.Id;
        insert objac;
        
        // opportunity creation              
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = objac.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Project__c = objpr.Id; 
        insert objOpportunity;
        
        Payment_Plan__c pp1 = new Payment_Plan__c();
        pp1.Tower__c = t.Id;
        pp1.Plan_Code__c = '002';
        pp1.Project__c = objpr.Id;
        pp1.No_GST_on_Token__c = true;
        pp1.NoofMilestones__c = 6;
        pp1.Subvention_Payment_Plan__c = true;
        pp1.Is_Access_Restricted__c = true;
        pp1.Valid_Till__c = System.today().addDays(5); 
        insert pp1;
        
        
        Id optyId = objOpportunity.Id;
        Id unitId = objPU1.Id;
        Id towerid = t.Id;
        Id projectid = objpr.Id;
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Quotation__c quote = createQuotation(optyId, pp1.Id, unitId);     
        
        Payment_Milestones__c pm = createPaymentMilestone(quote.Id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.Current_Status__c = 'Audit Accepted';
        b.status__c = 'Processed';
        b.Stage_of_Booking__c = 'Booked';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;  
        b.PCC_Status__c = 'Pending for Audit Approval';
        insert b; 
        
        quote.Booking__c = b.Id;
        update quote;      
        
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c = projectId ;
        objRec.Opportunity__c = optyId;
        objRec.Project_Unit__c = unitId;
        objRec.Booking__c = b.Id;
        objRec.Receipt_No_Manual__c = '12';
        objRec.Receipt_Status__c = 'Processed';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Total_Amount__c = 100;
        objRec.Manual_Receipt_Date__c = System.today();
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        insert objRec; 
        
        b.Receipts__c = objRec.id;
        update b;
        
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId ;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = optyId;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Token_Amount_ST__c = true;
        r2.Total_Amount__c = 8400;
        r2.Booking__c = b.Id; 
        insert r2;    
        
        List<Applicant_Details__c> applicantDetailsList = new List<Applicant_Details__c>();
        Applicant_Details__c ad1 = new Applicant_Details__c();
        ad1.Name = 'A One';
        ad1.Type_Of_Applicant__c = 'Individual Buyer';
        ad1.Subtype_Of_Applicant__c = 'Indian National';
        ad1.One_Passport_Size_Color_Photograph__c = true;
        ad1.Permanent_Address__c = 'Perma Addressia';
        ad1.Email_Address__c = 'a1.one@gmail.com';
        ad1.Mobile_Number__c = '989898989';
        ad1.DOB__c = system.today().addMonths(-12);
        ad1.Booking__c = b.Id;
        applicantDetailsList.add(ad1);
        
        Applicant_Details__c ad2 = new Applicant_Details__c();
        ad2.Name = 'A Four';
        ad2.Type_Of_Applicant__c = 'Individual Buyer';
        ad2.Subtype_Of_Applicant__c = 'Indian National';
        ad2.One_Passport_Size_Color_Photograph__c = true;
        ad2.Permanent_Address__c = 'Perma Addressia';
        ad2.Email_Address__c = 'a2.one@gmail.com';
        ad2.Mobile_Number__c = '8080808080';
        ad2.DOB__c = system.today().addMonths(-12);
        ad2.Booking__c = b.Id;
        applicantDetailsList.add(ad2);
        
        Applicant_Details__c ad3 = new Applicant_Details__c();
        ad3.Name = 'A Three';
        ad3.Type_Of_Applicant__c = 'Individual Buyer';
        ad3.Subtype_Of_Applicant__c = 'Indian National';
        ad3.One_Passport_Size_Color_Photograph__c = true;
        ad3.Permanent_Address__c = 'Perma Addressia';
        ad3.Email_Address__c = 'a3.one@gmail.com';
        ad3.Mobile_Number__c = '9090909090';
        ad3.DOB__c = system.today().addMonths(-12);
        ad3.Booking__c = b.Id;
        applicantDetailsList.add(ad3);
        
        Applicant_Details__c ad4 = new Applicant_Details__c();
        ad4.Name = 'A Four';
        ad4.Type_Of_Applicant__c = 'Individual Buyer';
        ad4.Subtype_Of_Applicant__c = 'Indian National';
        ad4.One_Passport_Size_Color_Photograph__c = true;
        ad4.Permanent_Address__c = 'Perma Addressia';
        ad4.Email_Address__c = 'a3.one@gmail.com';
        ad4.Mobile_Number__c = '9090909090';
        ad4.DOB__c = system.today().addMonths(-12);
        ad4.Booking__c = b.Id;
        applicantDetailsList.add(ad4);
        
        Applicant_Details__c ad5 = new Applicant_Details__c();
        ad5.Name = 'A Five';
        ad5.Type_Of_Applicant__c = 'Individual Buyer';
        ad5.Subtype_Of_Applicant__c = 'Indian National';
        ad5.One_Passport_Size_Color_Photograph__c = true;
        ad5.Permanent_Address__c = 'Perma Addressia';
        ad5.Email_Address__c = 'a3.one@gmail.com';
        ad5.Mobile_Number__c = '9090909090';
        ad5.DOB__c = system.today().addMonths(-12);
        ad5.Applicant_Number__c = 'Primary Applicant';
        ad5.PancardNo__c = 'PA101010';
        ad5.Address_Proof_Document__c = 'Driving License';
        ad5.Address_Proof_Number__c = 'addkdljf';
        ad5.Booking__c = b.Id;
        applicantDetailsList.add(ad5);
        insert applicantDetailsList;
        
        quote.Booking__c = b.Id;
        
        update quote;
        
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = optyId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:optyId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.Unit__c = unitId;
        
        update o;
        
        List<Demand__c> demandList = DemandGeneratorManager.createMultipleDemand(new Set<String>{pm.Id});
        
        Raise_Demand_Tracker__c rdt = new Raise_Demand_Tracker__c();
        rdt.Demand__c = demandList[0].Id;
        rdt.Booking__c = b.Id;
        
        insert rdt;
        
        Test.startTest();
        RaiseDemandTrackerSchedular ob = new RaiseDemandTrackerSchedular();
        ob.execute(null);
        DemandAutoGenerationBatch obj = new DemandAutoGenerationBatch();
        Database.executeBatch(obj);
        DemandAutoGenerationController.insertErrorLog('test','test','test','test');
        
        List<Raise_Demand_Tracker__c> RDTList = new List<Raise_Demand_Tracker__c>();
        
        DemandAutoGenerationBatch.retryAutoRaisedDemand(new List<Raise_Demand_Tracker__c>{rdt});
        
        DemandAutoGenerationController.PrintChargesWrapper obClass = new DemandAutoGenerationController.PrintChargesWrapper();
        
        obClass.Amount = '1000';
        obClass.chargeName = '1000';
        obClass.percentage = '1000';
        obClass.Tax1 = '1000';
        obClass.Tax2 = '1000';
        Test.stopTest();
        DemandAutoGenerationController.PrintTotalsWrapper objClass = new DemandAutoGenerationController.PrintTotalsWrapper();
        objClass.receivedAmt = '1000';
        objClass.demandedAmt = '1000';
        objClass.receivedTax = '1000';
        objClass.demandedTax = '1000';
        objClass.milestoneName = '1000';
        objClass.totalOutstandingWithTax = '1000';
        objClass.totalDemandedWithTax = '1000';
        objClass.totalDueWithInterest = '1000';
        objClass.totalDueWithoutGSTInterest = '1000';
        objClass.totalInterest = '1000';
        objClass.totalGSTOnInterest = '1000';
        objClass.grandTotal = 1000;
        objClass.grandTotalWithoutGSTOnInterest = 1000;
        
        
        Raise_Demand_Tracker__c rdt2 = new Raise_Demand_Tracker__c();
        rdt2.Demand__c = null;
        rdt2.Booking__c = b.Id;
        rdt2.Payment_Milestones__c = pm.Id;
        
        insert rdt2;
        
        DemandAutoGenerationBatch.retryAutoRaisedDemand(new List<Raise_Demand_Tracker__c>{rdt2});

        bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = false;
        bypassSettingInstance.Bypass_Booking_Trigger__c = false;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
        bypassSettingInstance.Bypass_Unit_Trigger__c = false;
        bypassSettingInstance.Bypass_All__c = false;
        bypassSettingInstance.Bypass_All_Triggers__c = false;
        bypassSettingInstance.Bypass_All_Validations_Rules__c = false;
        bypassSettingInstance.ByPass_Auto_Cancellation__c = false;
        bypassSettingInstance.Bypass_Booking_Welcome_Email__c = false;
        bypassSettingInstance.Bypass_Demand_Trigger__c = false;
        bypassSettingInstance.Bypass_Lead_Trigger__c = false;
        bypassSettingInstance.Bypass_OldBrokerAutoDeletion__c = false;
        bypassSettingInstance.Bypass_Receipt_Trigger__c = false;

        upsert bypassSettingInstance;
        
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
        pm.Charge1Percentage__c = 1;
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 10000;  
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 2475;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';
        pm.Milestone_Due_Date__c = System.today() +2 ;
        insert pm;        
        return pm;                  
    } 
}