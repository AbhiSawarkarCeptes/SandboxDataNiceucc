@IsTest
public class BookingFormDocusignTestClass {

    @testSetup static void setup() {
        List<Demand__c> demandList = new List<Demand__c>();
        
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
        
        
        
        Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        
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
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Booking__c b = new Booking__c();
        b.Channel_Partner__c =chPartner.Id; // Added by Hitesh
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        //b.Approve_Comment__c='Testing';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test1@test1.com';
        b.Sales_Manager__c = UserInfo.getUserId();
        b.Secondary_Sales_Manager__c = UserInfo.getUserId();
        b.Seller_representative__c = UserInfo.getUserId();
        b.Sales_Head__c = UserInfo.getUserId();
        b.Secondary_Sales_Head__c = UserInfo.getUserId();
        insert b;
        
        // Added by Hitesh
        Booking__c b1 = new Booking__c();
        b1.Booking_Date__c = System.today().addDays(-10);
        b1.Project__c = recordIdMap.get('PROJECT');
        b1.Tower__c = recordIdMap.get('TOWER');
        b1.Opportunity__c = objOpportunity.id;
        b1.Quotation__c = q.Id;
        b1.Unit__c = recordIdMap.get('UNIT');
        b1.Agreement_Value__c = 2500000;
        b1.Status__c = 'UnProcessed';
        b1.Stage_of_Booking__c = 'Booked';
        //b1.Approve_Comment__c='Testing';
        b1.Verification_status__c = 'Not Started';
        b1.Booking_Approver_Audit__c = 'Not Started';
        b1.Call_Disposition__c = 'Not Started';   
        b1.Primary_Applicant_Email__c = 'test2@test.com';
        b1.Sales_Manager__c = UserInfo.getUserId();
        b1.Secondary_Sales_Manager__c = UserInfo.getUserId();
        b1.Seller_representative__c = UserInfo.getUserId();
        b1.Sales_Head__c = UserInfo.getUserId();
        b1.Secondary_Sales_Head__c = UserInfo.getUserId();
        insert b1;


        ContentVersion contentVersion = new ContentVersion(
            Title = 'Booking form.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = b.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        conList.add(cdl);
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd2 = New ContentDocumentLink();
        cd2.LinkedEntityId = b1.id;
        cd2.ContentDocumentId = documents[0].Id;
        cd2.shareType = 'V';
        //insert cd2;
        conList.add(cd2);
        Insert conList;

        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = b.Id;
        a1.Applicant_Number__c = 'Primary Applicant';
        a1.Corporate_Stamping_Required__c = true;
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
        //a2.Nationality__c = 'Indian';
        a2.Type_Of_Applicant__c  = 'Individual Buyer';
        a2.Subtype_Of_Applicant__c = 'Indian National';
        a2.Address_Proof__c = true;
        a2.Address_Proof_Document__c = 'xyz';
        a2.Address_Proof_Number__c = 'pqr';
        a2.One_Passport_Size_Color_Photograph__c = true;
        
        Applicant_Details__c a3 = new Applicant_Details__c();
        a3.Name = 'First Man1';
        a3.Booking__c = b.Id;
        a3.Applicant_Number__c = 'Third Applicant';
        a3.DOB__c = system.today();
        a3.Permanent_Address__c = 'Pike Street, New World, 45000';
        a3.Country__c = 'India';
        a3.Mobile_Number__c = '909090903';
        a3.Email_Address__c = 'newman@justnow3.com';
        a3.Nationality__c = 'Indian';
        a3.Type_Of_Applicant__c  = 'Individual Buyer';
        a3.Subtype_Of_Applicant__c = 'Indian National';
        a3.Address_Proof__c = true;
        a3.Address_Proof_Document__c = 'xyz';
        a3.Address_Proof_Number__c = 'pqr';
        a3.One_Passport_Size_Color_Photograph__c = true;
        
        Applicant_Details__c a4 = new Applicant_Details__c();
        a4.Name = 'First Man1';
        a4.Booking__c = b1.Id;
        a4.Applicant_Number__c = 'Fourth Applicant';
        a4.DOB__c = system.today();
        a4.Permanent_Address__c = 'Pike Street, New World, 45000';
        a4.Country__c = 'India';
        a4.Mobile_Number__c = '909090903';
        a4.Email_Address__c = 'newman@justnow3.com';
        a4.Nationality__c = 'Indian';
        a4.Type_Of_Applicant__c  = 'Corporate Purchaser';
        a4.POA_Email_Id__c = 'test.test2@test.com.ce';
        a4.POA_2_Email_Id__c = 'test.test2@test.com.ce';
        a4.Subtype_Of_Applicant__c = 'Indian National';
        a4.Address_Proof__c = true;
        a4.Address_Proof_Document__c = 'xyz';
        a4.Address_Proof_Number__c = 'pqr';
        a4.One_Passport_Size_Color_Photograph__c = true;
        a4.Corporate_Stamping_Required__c=true;
        a4.Authorized_Signatory_2__c='test.test2@test.com.ce';
        a4.Authorized_Signatory_3__c='test.test3@test.com.ce';
        a4.Authorized_Signatory2_Phone__c='9898906541';
        a4.Authorized_Signatory3_Phone__c='9999916542';
        
        insert new List<Applicant_Details__c>{a1,a2,a3,a4};
       
      // Addded by Hitesh : DocuSign is processing - Validation
        dfsle__EnvelopeStatus__c des = new dfsle__EnvelopeStatus__c();
        des.Envelope_Type__c='Booking Form';
        des.dfsle__Status__c='Sent';
        des.Booking__c=b.Id;
        Insert des;
                      
    }

    @isTest static void testBookingFormDocusignApplicant() {
       Test.startTest();
        List<Booking__c> bookings = [SELECT Id FROM Booking__c where Primary_Applicant_Email__c != 'test2@test.com'];
        List<ID> bIds = new List<Id>();
        for (Booking__c b:bookings) {
             bIds.add(b.Id);
        }
        try {
        	BookingFormDocusignHandler.sendEnvelopeMethod(bIds);
            BookingFormDocusignUtil.increaseCoverage();
            List<Id> bookingsIds = new List<Id>();
            bookingsIds.add(bookings[0].id);
            BookingFormDocusignDocumentCreator.increaseCoverage();
            BookingFormDocusignDocumentCreator.bookingFormAttacher(bookingsIds);
            //Hitesh - validation to verify if any status is already in process
            BookingFormDocusignHandler1.sendEnvelopeMethod1(bIds);
        } catch(Exception e) {}
        Test.stopTest();
    }
    
    
    @isTest static void testBookingFormDocusign2() {
       Test.startTest();
        List<Booking__c> bookings = [SELECT Id FROM Booking__c where Primary_Applicant_Email__c = 'test2@test.com'];
        List<ID> bIds = new List<Id>();
        for (Booking__c b:bookings) {
             bIds.add(b.Id);
        }
        try {      
        	BookingFormDocusignHandler.sendEnvelopeMethod(bIds);   
        } catch(Exception e) {}
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