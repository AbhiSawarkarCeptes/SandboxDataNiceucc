@IsTest
public class ScriptBookingToTransRequestBatchTest {
     @isTest static void testmethod1() {

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
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test@test.com';
        b.CRM_Seller_representative__c = UserInfo.getUserId();
        b.CRM_Document_Controller__c = UserInfo.getUserId();
        b.SPA_Addendum_Sent_Date__c=System.today();
        b.SPA_Executed__c='To be Issued';
        insert b;
        

            ContentVersion contentVersion = new ContentVersion(
            Title = 'SPA',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'SPA Addendum',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1; 
        
         ContentVersion contentVersion2 = new ContentVersion(
            Title = 'DSPA Testing',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2; 
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument order by Title];
        
        List<ContentDocumentLink> cdlList= new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = b.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdlList.add(cdl);
        //insert cdl;
        
        ContentDocumentLink cd2 = New ContentDocumentLink();
        cd2.LinkedEntityId = b.id;
        cd2.ContentDocumentId = documents[1].Id;
        cd2.shareType = 'V';
        cdlList.add(cd2);
        //insert cd2;
        
        ContentDocumentLink cd3 = New ContentDocumentLink();
        cd3.LinkedEntityId = b.id;
        cd3.ContentDocumentId = documents[2].Id;
        cd3.shareType = 'V';
        cdlList.add(cd3);
        //insert cd3;
        
        Insert cdlList;

        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = b.Id;
        a1.Applicant_Number__c = 'First Applicant';
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

        insert new List<Applicant_Details__c>{a1,a2,a3};
           
        dfsle__EnvelopeStatus__c des = new dfsle__EnvelopeStatus__c();
        des.Envelope_Type__c='SPA';
        des.dfsle__Status__c='Sent';
        des.Booking__c=b.Id;
        Insert des;
         
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Legacy_Booking_Id__c=b.id,
                                                                                             SPA_Transaction_Exception__c=true,
                                                                                             CRM_Executive__c=UserInfo.getUserId(),
                                                                                             PropStrength__Brokerage_Release_Schedule__c = sche.Id, 
                                                                                             PropStrength__Broker_Account__c = acc.Id, 
                                                                                             PropStrength__Primary_Customer__c = cont.Id, 
                                                                                             PropStrength__Property__c = prop.Id, 
                                                                                             Oqood_Fees_Received__c=FALSE, 
                                                                                             Noqoodi_Wallet_Ref_No_Approved__c = FALSE, 
                                                                                             PropStrength__Offer__c=offer.Id,
                                                                                             PropStrength__Booking_Date__c = System.Today(), 
                                                                                             PropStrength__Booking_Through__c = 'Broker', 
                                                                                             PropStrength__Total_Basic_Sales_Price__c = 10000, 
                                                                                             PropStrength__Project__c = proj.Id);
        insert book;

        PropStrength__Transaction_Requests__c transreq = new PropStrength__Transaction_Requests__c();
            transreq.RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
            transreq.PropStrength__Application_Booking__c=book.Id;
            transreq.PropStrength__Status__c='To be Issued';
            Insert transreq;
         
        database.executeBatch(new ScriptBookingToTransRequestBatch());
        Test.StopTest();
             
    }              
}