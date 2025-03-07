@IsTest
public class resaledocusignhandlertest {

    @testSetup static void setup() {
        List<Demand__c> demandList = new List<Demand__c>();
        
        Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = true;
        bypassSettingInstance.Bypass_Booking_Trigger__c = true;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = true;
        bypassSettingInstance.Bypass_Unit_Trigger__c = true;
        bypassSettingInstance.Bypass_Lead_Trigger__c = true;
        bypassSettingInstance.Bypass_Receipt_Trigger__c = true;
        
        upsert bypassSettingInstance;
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
      
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');

        
        Tower__c tower = [SELECT Id, Name, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;  
        
        
        
      //  Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        
         // account creation 
             Account objac = new Account();
             objac.FirstName = 'Shock';
             objac.LastName = 'Wave';
             objac.Correspondence_Address__c = 'Delhi';
             objac.Category__c = 'General';
             objac.Unit__c = unitId;
             objac=RDSCommon.CreateAccount(objac);
        
         Opportunity objOpportunity = new Opportunity();
             objOpportunity.Name = 'Test Hitesh';
             objOpportunity.CloseDate = System.today();
             objOpportunity.AccountId = objac.Id; 
             objOpportunity.Status__c = 'Active'; 
             objOpportunity.StageName = 'Opportunity Identified'; 
             objOpportunity.Project__c = recordIdMap.get('PROJECT'); 
             objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        // Added by Hitesh - Broker Sign
       /* Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;*/
        
        Booking__c b = new Booking__c();
       // b.Channel_Partner__c =chPartner.Id; 
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.VAT_Reduction_From_PPP__c=100;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test@test.com';
        b.Sales_Manager__c = UserInfo.getUserId();
        b.Secondary_Sales_Manager__c = UserInfo.getUserId();
        b.Seller_representative__c = UserInfo.getUserId();
        b.Sales_Head__c = UserInfo.getUserId();
        b.Secondary_Sales_Head__c = UserInfo.getUserId();
        insert b;

        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = b.Id;
        a1.Applicant_Number__c = 'First Applicant';
        a1.Type_Of_Applicant__c = 'Corporate Purchaser';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman3@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        a1.Address_Proof__c = true;
        a1.Address_Proof_Document__c = 'xyz';
        a1.Address_Proof_Number__c = 'pqr';
        a1.One_Passport_Size_Color_Photograph__c = true;
        insert a1;
       
       Resale_Process__c resale = new Resale_Process__c ();
        resale.Resale_Type__c ='Resale with Mortgage';
        resale.Booking__c=b.Id;
        resale.Seller1_Name__c='Hitesh GV';
        resale.Seller1_Email__c='hitesh.gv@shoba.com1.test';
        resale.Seller1_Phone_Number__c='919844978626'; 
        resale.Seller1_Address__c='abcdef';
        resale.Seller1_Passport_Number__c='sjd87246234';
        resale.Buyer1_Name__c='Hitesh GV1';
        resale.Buyer1_Email__c='hitesh1.gv1@shoba.com.test1';
        resale.Buyer1_Phone_Number__c='919844978626'; 
        resale.Buyer1_Passport_Number__c='1sjd87246234';
        resale.Buyer1_Address__c='jhbvjsdc';
        resale.Approval_Status__c='Pending for Collections Approval';
        resale.CRM_Document_Controller__c=UserInfo.getUserId();
        resale.Unit__c = recordIdMap.get('UNIT');
        resale.Type_of_Buyer__c = 'Company';
        insert resale;
        
        Buyer__c  buyer = new Buyer__c ();
            buyer.Salutation__c='Mr';
            buyer.Name='Hitesh Buyer';
            buyer.Email__c='buyer1@buyer1.com';
            buyer.Phone_Number__c ='919844978626';
            buyer.Passport_Number__c='hvjsd632';
            buyer.Address__c='ndtoskfh';
            buyer.Resale_Process__c=resale.Id;
            buyer.Nationality__c ='Indian';
            buyer.Residence_Status__c='Resident ';
            buyer.Buyer_Type__c='Primary Applicant';
        	
        insert buyer;
        
        Buyer__c  buyer1 = new Buyer__c ();
            buyer1.Salutation__c='Mr';
            buyer1.Name='Hitesh Buyer';
            buyer1.Email__c='buyer@buyer.com';
            buyer1.Phone_Number__c ='919844978626';
            buyer1.Passport_Number__c='hvjsd632';
            buyer1.Address__c='ndtoskfh';
            buyer1.Resale_Process__c=resale.Id;
            buyer1.Nationality__c ='Indian';
            buyer1.Residence_Status__c='Resident ';
            buyer1.Buyer_Type__c='Primary Applicant';
            
        insert buyer1;
        
        List<Receipt__c> recelst = new List<Receipt__c>();
        Receipt__c rec = new Receipt__c();
        rec.Booking__c =b.Id;
        rec.Receipt_Status__c ='Cleared';
        rec.Consider_for_Paid_Percentage__c =false;
        rec.Is_Reversed_Receipt__c =false;
        rec.Amount_Rs__c =1000;
        rec.Total_Amount__c = 1000;
        rec.Corporate_Collection_Control_Report__c =100;
        rec.Credit_Card_Charges__c =100;
        rec.Other_Charges_Type__c='Late Payment Charges';
        recelst.add(rec);
        
        Receipt__c rec1 = new Receipt__c();
        rec1.Booking__c =b.Id;
        rec1.Receipt_Status__c ='PDC';
        rec1.Consider_for_Paid_Percentage__c =false;
        rec1.Is_Reversed_Receipt__c =false;
        rec1.Amount_Rs__c =1000;
        rec1.Total_Amount__c = 1000;
        rec1.Corporate_Collection_Control_Report__c =100;
        rec1.Credit_Card_Charges__c =100;
        recelst.add(rec1);
        insert recelst;    

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Resale Agreement TestFive',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('resale Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;   
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'NOC for resale TestFive',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('NOC Test Content TestFive'),
            IsMajorVersion = true
        );
        insert contentVersion1;   
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> cdlst = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        for(ContentDocument cd :documents)
        {
           ContentDocumentLink cdl = New ContentDocumentLink();
           cdl.LinkedEntityId = resale.id;
           cdl.ContentDocumentId = cd.Id;
           cdl.shareType = 'V';
           cdlst.add(cdl); 
        }
          insert  cdlst;      
        
        bypassSettingInstance = Bypass_Setting__c.getInstance();
        bypassSettingInstance.Bypass_Account_Trigger__c = false;
        bypassSettingInstance.Bypass_Booking_Trigger__c = false;
        bypassSettingInstance.Bypass_Opportunity_Trigger__c = false;
        bypassSettingInstance.Bypass_Unit_Trigger__c = false;
        bypassSettingInstance.Bypass_Lead_Trigger__c = false;
        bypassSettingInstance.Bypass_Receipt_Trigger__c = false;
        
        upsert bypassSettingInstance;
        
    }

    @isTest static void testresaledocusign() {
        Test.startTest();
        List<Resale_Process__c> resalelist = new List<Resale_Process__c>();
        List<Resale_Process__c> resale = [SELECT Id, Approval_Status__c FROM Resale_Process__c];
        //List<Booking__c> booking =[Select Id from Booking__c];
        List<ID> bIds = new List<Id>();
        for (Resale_Process__c r: resale) {
             bIds.add(r.Id);
             r.Approval_Status__c ='Pending for Accounts Approval';
             resalelist.add(r);
        }
        try {
            
        	resaledocusignhandler.sendEnvelopeMethod(bIds);
            ResaleNOCDocusignHandler.sendEnvelopeMethod(bIds);
            resaledocusignhandler1.sendEnvelopeMethod1(bIds);
            ResaleNOCDocusignHandler1.sendEnvelopeMethod1(bIds);
            if(!resalelist.isEmpty())
            {
              //update resalelist;  
            }
        } 
        catch(Exception e) {}
        //"Booking__c":"'+booking[0].Id+'","Resale_Type__c":"Oqood","Type_of_Buyer__c":"Individual","Property_Status__c":"Offplan",,"Last_Name__c":"GV","Buyer1_Address__c":"Bangalore","Buyer1_Passport_Number__c":"hsjd28947","Seller1_Passport_Number__c":"hsdgjf723"
        //String resaleInformation='[{"Buyer1_Name__c":"hitesh GV","Buyer1_Email__c":"test@test.com","Buyer1_Phone_Number__c":"919844978626","Seller1_Name__c":"hiteshSeller","Seller1_Email__c":"hitesh@test.com","Seller1_Phone_Number__c":"919876543210"}]';
        //String filedata='[{"fileName":"resale Signature.docx","fileContent":"UEsDBBQABgAIAAAAIQCSZC2eZQEAAJ0FAAATAAgCW0NvbnRlbnRfVHlwZXNdLnhtbCCiBAIooAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA”}]';
        //String buyers ='[{"Salutation__c":"Mr","Name":"hjsdvjcs","Email__c":"test@test.com","Phone_Number__c":"919844978626","Passport_Number__c":"hsjd28947","Address__c":"hjbvs","Resale_Process__c":"'+bIds[0]+'","Nationality__c":"Indian","Residence_Status__c":"Resident","Buyer_Type__c":"Primary Applicant","New_Sale_Value__c":"500"}]';
      /*  Resale_Process__c resale1 = new Resale_Process__c ();
        resale1.Resale_Type__c ='Resale with Mortgage';
        resale1.Booking__c=booking[0].Id;
        resale1.Seller1_Name__c='Hitesh GV';
        resale1.Seller1_Email__c='hitesh.gv@shoba.com.test';
        resale1.Seller1_Phone_Number__c='919844978626'; 
        resale1.Seller1_Address__c='abcdef';
        resale1.Seller1_Passport_Number__c='sjd87246234';
        resale1.Buyer1_Name__c='Hitesh GV1';
        resale1.Buyer1_Email__c='hitesh1.gv1@shoba.com.test';
        resale1.Buyer1_Phone_Number__c='919844978626'; 
        resale1.Buyer1_Passport_Number__c='1sjd87246234';
        resale1.Buyer1_Address__c='jhbvjsdc';
        
        List<Buyer__c> buyList = new List<Buyer__c>();
        Buyer__c  buyer2 = new Buyer__c ();
            buyer2.Salutation__c='Mr';
            buyer2.Name='Hitesh Buyer';
            buyer2.Email__c='buyer2@buyer.com';
            buyer2.Phone_Number__c ='919844978626';
            buyer2.Passport_Number__c='hvjsd632';
            buyer2.Address__c='ndtoskfh';
            buyer2.Resale_Process__c=bIds[0];
            buyer2.Nationality__c ='Indian';
            buyer2.Residence_Status__c='Resident ';
            buyer2.Buyer_Type__c='Primary Applicant';
        	buyList.add(buyer2);
        
        List<ContentVersion> fileList = new List<ContentVersion>();
        ContentVersion contentVersion1 = new ContentVersion();	
        contentVersion1.Title = 'Resale Agreement TestFive';
        contentVersion1.PathOnClient = 'Penguins.jpg';
        contentVersion1.VersionData = Blob.valueOf('resale Test Content');
        contentVersion1.IsMajorVersion = true;
        fileList.add(contentVersion1);
        
        String jsonresale = Json.serialize(resale1);
        String jsonbuyer = Json.serialize(buyList);
        String jsonfile = Json.serialize(fileList); */
      
        //resaleprocesscontroller.createResale(jsonfile, jsonresale, jsonbuyer); 
        Test.stopTest();    
    }
    
    
    public static Payment_Milestones__c createPaymentMilestone (Id quote) {        
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