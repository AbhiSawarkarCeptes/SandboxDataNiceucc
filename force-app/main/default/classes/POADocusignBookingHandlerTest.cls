@isTest
public class POADocusignBookingHandlerTest {

    @testSetup static void setup() {
        List<Demand__c> demandList = new List<Demand__c>();
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        
        
        
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
        
        Project__c objpr = new Project__c();
        objpr.Project_Code__c = 'T35';
        objpr.Name = 'test P';
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
        
        Tower__c t = new Tower__c();
        t.Name = 'Sobha Hartland II Villas';
        t.Project__c = objpr.Id;
        t.Cluster__c = clus.Id;
        insert t;
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Tower__c = t.Id;
        pp.Plan_Code__c = '001';
        pp.Project__c = objpr.Id;
        pp.No_GST_on_Token__c = true;
        pp.NoofMilestones__c = 6;
        pp.Is_Access_Restricted__c = true;
        pp.Valid_Till__c = System.today().addDays(5);
        
        insert pp;
        
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
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = objac.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Project__c = objpr.Id; 
        insert objOpportunity;
        
        Id unitId = objPU1.Id;
        Id towerId = t.Id;
        Id clusterId = clus.Id;
        Id projectId = objpr.Id;
        
        Tower__c tower = [SELECT Id, Name, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = objOpportunity.Id;
        q.Unit__c = unitId;
        q.Payment_Plan__c = pp.Id;
        q.Quote_Status__c = 'Valid';
        insert q;      
        
        Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = projectId;
        b.Tower__c = towerId;
        b.Opportunity__c = objOpportunity.Id;
        b.Quotation__c = q.Id;
        b.Unit__c = unitId;
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test@test.com';
        b.CRM_Seller_representative__c = UserInfo.getUserId();
        b.CRM_Document_Controller__c = UserInfo.getUserId();
        insert b;
        
        Booking__c b2 = new Booking__c();
        b2.Booking_Date__c = System.today().addDays(-10);
        b2.Project__c = projectId;
        b2.Tower__c = towerId;
        b2.Opportunity__c = objOpportunity.Id;
        b2.Quotation__c = q.Id;
        b2.Unit__c = unitId;
        b2.Agreement_Value__c = 2500000;
        b2.Status__c = 'UnProcessed';
        b2.Stage_of_Booking__c = 'Booked';
        b2.Verification_status__c = 'Not Started';
        b2.Booking_Approver_Audit__c = 'Not Started';
        b2.Call_Disposition__c = 'Not Started';   
        b2.Primary_Applicant_Email__c = 'test2@test.com';
        b2.CRM_Seller_representative__c = UserInfo.getUserId();
        b2.CRM_Document_Controller__c = UserInfo.getUserId();
        insert b2;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Handover Document',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        
        //Hitesh Changes
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Handover Document',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument order by Title];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = b.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        //Hitesh Changes
        ContentDocumentLink cd2 = New ContentDocumentLink();
        cd2.LinkedEntityId = b.id;
        cd2.ContentDocumentId = documents[1].Id;
        cd2.shareType = 'V';
        insert cd2;
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd3 = New ContentDocumentLink();
        cd3.LinkedEntityId = b2.id;
        cd3.ContentDocumentId = documents[0].Id;
        cd3.shareType = 'V';
        insert cd3;
        
        //Hitesh Changes
        ContentDocumentLink cd4 = New ContentDocumentLink();
        cd4.LinkedEntityId = b2.id;
        cd4.ContentDocumentId = documents[1].Id;
        cd4.shareType = 'V';
        insert cd4;

        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = b.Id;
        a1.Applicant_Number__c = 'Primary Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        a1.Address_Proof__c = true;
        a1.Address_Proof_Document__c = 'xyz';
        a1.Address_Proof_Number__c = 'pqr';
        a1.One_Passport_Size_Color_Photograph__c = true;
        
        Applicant_Details__c a2 = new Applicant_Details__c();
        a2.Name = 'First Man1';
        a2.Booking__c = b.Id;
        a2.Applicant_Number__c = 'Second Applicant';
        a2.DOB__c = system.today();
        a2.Permanent_Address__c = 'Pike Street, New World, 45000';
        a2.Country__c = 'India';
        a2.Mobile_Number__c = '909090903';
        a2.Email_Address__c = 'newman@justnow3.com';
        a2.Nationality__c = 'Indian';
        a2.Type_Of_Applicant__c  = 'Individual Buyer';
        a2.Subtype_Of_Applicant__c = 'Indian National';
        a2.Address_Proof__c = true;
        a2.Address_Proof_Document__c = 'xyz';
        a2.Address_Proof_Number__c = 'pqr';
        a2.One_Passport_Size_Color_Photograph__c = true;
        
        Applicant_Details__c a3 = new Applicant_Details__c();
        a3.Name = 'First Man1';
        a3.Booking__c = b.Id;
        a3.Applicant_Number__c = 'Primary Applicant';
        a3.DOB__c = system.today();
        a3.Permanent_Address__c = 'Pike Street, New World, 45000';
        a3.Country__c = 'India';
        a3.Mobile_Number__c = '909090903';
        a3.Email_Address__c = 'newman@justnow2.com';
        a3.Nationality__c = 'Indian';
        a3.Type_Of_Applicant__c  = 'Individual Buyer';
        a3.Subtype_Of_Applicant__c = 'Indian National';
        a3.Address_Proof__c = true;
        a3.Address_Proof_Document__c = 'xyz';
        a3.POA_Email_Id__c = 'test@sobharealty.com';
        a3.Address_Proof_Number__c = 'pqr';
        a3.One_Passport_Size_Color_Photograph__c = true;
        
        insert new List<Applicant_Details__c>{a1,a2,a3};
            
        dfsle__EnvelopeStatus__c des = new dfsle__EnvelopeStatus__c();
        des.Envelope_Type__c='Handover';
        des.dfsle__Status__c='Sent';
        des.Booking__c=b.Id;
        Insert des;
        
            
            
    }
    
    @isTest 
    static void testSPADocusignApplicant() {
       
        List<Booking__c> bookings = [SELECT Id FROM Booking__c ];
        List<ID> bIds = new List<Id>();
        for (Booking__c b:bookings) {
             bIds.add(b.Id);
        }
        try {
        	POADocusignBookingHandler.sendEnvelopeMethod(bIds);
            POADocusignBookingHandler1.sendEnvelopeMethod1(bIds);
        } catch(Exception e) {}
    }
    
    @isTest 
    static void testSPADocusignApplicantWithPOA() {
        List<Booking__c> bookings = [SELECT Id,Primary_Applicant_Email__c FROM Booking__c WHERE Primary_Applicant_Email__c = 'newman@justnow2.com' ];
        System.debug('Booking - '+bookings.size());
        List<ID> bIds = new List<Id>();
        for (Booking__c b:bookings) {
            System.debug('Booking - '+b.Primary_Applicant_Email__c);
             bIds.add(b.Id);
        }
        try {
        	POADocusignBookingHandler.sendEnvelopeMethod(bIds);
        } catch(Exception e) {}
    }
    
    @isTest 
    static void testSPADocusignWithouthApplicant() {
        List<Booking__c> bookings = [SELECT Id,Primary_Applicant_Email__c FROM Booking__c WHERE Primary_Applicant_Email__c = 'test2@test.com' ];
        System.debug('Booking - '+bookings.size());
        List<ID> bIds = new List<Id>();
        for (Booking__c b:bookings) {
            System.debug('Booking - '+b.Primary_Applicant_Email__c);
             bIds.add(b.Id);
        }
        try {
        	POADocusignBookingHandler.sendEnvelopeMethod(bIds);
        } catch(Exception e) {}
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