@isTest
public with sharing class ResaleProcessAppBookingLWCControllerTest {
    @isTest
    public static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
    
        User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');
        User user2 = TestDataFactory.createUserSysAdmin('On22e','Galvatro22n', 'galvat33ron14566@radius.com', 'g22alvatron12345@radius.com');
    
        user1.PropStrength__Assignment_Group_Active__c = true;
        user1.IsActive = true;
        update user1;
    
        user2.PropStrength__Assignment_Group_Active__c = true;
        user2.IsActive = true;
        update user2;
        
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'SBF Assignment';
        insert groupName;
        
        PropStrength__Group_Member__c assignmentGroup = new PropStrength__Group_Member__c();
        assignmentGroup.PropStrength__User__c = user1.Id;
        assignmentGroup.Rank__c = 1;
        assignmentGroup.PropStrength__Order__c = 1;
        assignmentGroup.PropStrength__Active__c = 'True';
        assignmentGroup.Name = 'TestQueue';
        assignmentGroup.PropStrength__Assignment_Group__c = groupName.Id;
        assignmentGroup.PropStrength__Last_Assigned__c = true;
        insert assignmentGroup;
    
        PropStrength__Group_Member__c assignmentGroup1 = new PropStrength__Group_Member__c();
        assignmentGroup1.PropStrength__User__c = user2.Id;
        assignmentGroup1.Rank__c = 2;
        assignmentGroup1.PropStrength__Order__c = 2;
        assignmentGroup1.PropStrength__Active__c = 'True';
        assignmentGroup1.Name = 'Presales Agent';
        assignmentGroup1.PropStrength__Assignment_Group__c = groupName.Id;
        insert assignmentGroup1;
    
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
    
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
    
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
    
        // PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id, Send_for_Docusign__c = true);
        // insert appDetail;
    
        // PropStrength__Applicant_Detail__c appDetailName = [SELECT Id, Name FROM PropStrength__Applicant_Detail__c WHERE Id = :appDetail.Id];
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
        Termination_Refund_Status__c ='');
        trList.add(tr);
        //insert tr;
    
        PropStrength__Transaction_Requests__c tr1 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
        Termination_Refund_Status__c ='Resubmit to Audit Review');
        trList.add(tr1);
    
        PropStrength__Transaction_Requests__c tr2 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
        Termination_Refund_Status__c ='Resubmit to Account Manager review');
        trList.add(tr2);
    
        PropStrength__Transaction_Requests__c tr3 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
        Termination_Refund_Status__c ='Resubmit to Treasury review');
        trList.add(tr3);
    
        PropStrength__Transaction_Requests__c tr4 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
        Termination_Refund_Status__c ='Resubmit to Respective department team member');
        trList.add(tr4);
       
        insert trList;
    
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
        cdl.LinkedEntityId = tr1.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        conList.add(cdl);
    
        Insert conList;    	
        Test.startTest();
        ResaleProcessAppBookingLWCController.getIntrimPaymentCounts(tr1.id);
        ResaleProcessAppBookingLWCController.getactiveresale(book.id);
        ResaleProcessAppBookingLWCController.updateTransactionRec( JSON.serialize(tr), tr1.id);
        String str = '[{"Salutation":"Mr.","First_Name":"First_Name","New_Sale_Value":"12","Email":"test@test.com","Address":"Address","City":"City","Last_Name":"Last_Name","Country":"Country","Phone_Number":"1244","Passport_Number":"1234","Company":"Company","PostalCode":"","Residence_Status":"","Nationality":"UAE","Buyer_Type":"","Emirates_Id":"","Buyer1_Unit_Share_Transfer":"1"}]';
        tr.Id = null;
        ResaleProcessAppBookingLWCController.createResale( JSON.serialize(tr), str);
        str = '[{"Salutation":"Mr.","First_Name":"First_Name","New_Sale_Value":"12","Email":"test11@test.com","Address":"Address","City":"City","Last_Name":"Last_Name","Country":"Country","Phone_Number":"1244","Passport_Number":"1234","Company":"Company","PostalCode":"","Residence_Status":"","Nationality":"UAE","Buyer_Type":"","Emirates_Id":"","Buyer1_Unit_Share_Transfer":"1"}]';
        tr.Id = null;
        ResaleProcessAppBookingLWCController.createResale( JSON.serialize(tr), str);
        ResaleProcessAppBookingLWCController.createAttachment( 'test', tr1.id);
        
        Test.stopTest();
    }

    @isTest static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
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
        //resale.CRM_Document_Controller__c=UserInfo.getUserId();
        resale.Unit__c = recordIdMap.get('UNIT');   
        insert resale;
        Test.startTest();
        //ResaleProcessAppBookingLWCController.updateResaleproRecords(new Set<Id>{resale.id});
        Test.stopTest();
    }
    
    	@isTest static void testMethod3(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true,T_link_Demand_Days__c = 1,Grace_Days_Time_Linked__c = 5,Grace_Days__c =5);
        insert proj;
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
            acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        List<Incentive_Slab__c> iss = new List<Incentive_Slab__c>();
        iss.add(new Incentive_Slab__c(Indirect_Sales__c=10, Direct_Sales__c=10, Approved_Discount_Sales__c=10, Loyalty_Sales__c = 10, Intl_Broker_New_Customer_Inc__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 10, VP_Channel_Relations_Split__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Sales_Director_Split__c = 10, Loyalty_Sales_Executive_Split__c = 10, Telesales_Agent_Split__c = 10, Mall_Team_Lead_Split__c = 10, Promoter_Split__c = 10, Marketing_Head_Split__c = 10, TeleSales_Head_Split__c = 10, Team_Lead_Split__c = 10, Digital_Marketing_Head_Split__c = 10, Campaign_Manager_Split__c = 10, Days_To__c = 365, Days_From__c = 1, CSO_Split__c = 10, VP_Split__c = 10, Sales_Head_Split__c = 10, RecordTypeId = salesManagerIncentiveId));
        iss.add(new Incentive_Slab__c(Indirect_Sales__c=10, Direct_Sales__c=10, Approved_Discount_Sales__c=10, Loyalty_Sales__c = 10, Intl_Broker_New_Customer_Inc__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 10, VP_Channel_Relations_Split__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Sales_Director_Split__c = 10, Loyalty_Sales_Executive_Split__c = 10, Telesales_Agent_Split__c = 10, Mall_Team_Lead_Split__c = 10, Promoter_Split__c = 10, Marketing_Head_Split__c = 10, TeleSales_Head_Split__c = 10, Team_Lead_Split__c = 10, Digital_Marketing_Head_Split__c = 10, Campaign_Manager_Split__c = 10, Days_To__c = 365, Days_From__c = 1, CSO_Split__c = 10, VP_Split__c = 10, Sales_Head_Split__c = 10, RecordTypeId = marketingIncentiveId));
        iss.add(new Incentive_Slab__c(Indirect_Sales__c=10, Direct_Sales__c=10, Approved_Discount_Sales__c=10, Loyalty_Sales__c = 10, Intl_Broker_New_Customer_Inc__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 10, VP_Channel_Relations_Split__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Sales_Director_Split__c = 10, Loyalty_Sales_Executive_Split__c = 10, Telesales_Agent_Split__c = 10, Mall_Team_Lead_Split__c = 10, Promoter_Split__c = 10, Marketing_Head_Split__c = 10, TeleSales_Head_Split__c = 10, Team_Lead_Split__c = 10, Digital_Marketing_Head_Split__c = 10, Campaign_Manager_Split__c = 10, Days_To__c = 365, Days_From__c = 1, CSO_Split__c = 10, VP_Split__c = 10, Sales_Head_Split__c = 10, RecordTypeId = channelPartnerIncentiveId));
        insert iss; 
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, Additional_Discount_Given__c = true, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        PropStrength__Brokerage_Scheme__c scheme = new PropStrength__Brokerage_Scheme__c(PropStrength__Scheme_Name__c = 'Test Brokerage Scheme' , PropStrength__Standard_Brokerage_BSP__c = 2,PropStrength__Active__c = true ,Approval_Status__c = 'Approved');
        insert scheme;
        PropStrength__Additional_Brokerage_Slab__c borkSlab = new PropStrength__Additional_Brokerage_Slab__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Name = 'Additional Brokerage',PropStrength__Active__c = true,PropStrength__Effective_end_Date__c =System.today()-2,PropStrength__Effective_Start_Date__c =System.today()-5,PropStrength__Range_To__c =200,PropStrength__Range_From__c = 2,PropStrength__Type__c ='Amount');
        insert borkSlab;
        PropStrength__Additional_Brokerage_Slab__c borkSlab2 = new PropStrength__Additional_Brokerage_Slab__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Name = 'Additional Brokerage',PropStrength__Active__c = true,PropStrength__Effective_end_Date__c =System.today()-2,PropStrength__Effective_Start_Date__c =System.today()-5,PropStrength__Range_To__c =200,PropStrength__Range_From__c = 2,PropStrength__Type__c ='Unit Count');
        insert borkSlab2;
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Mortgage_Case__c = false,PCC_Document_Approved__c = false,Title_Deed_Transfer_Executed__c = false,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-3), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 100, PropStrength__Project__c = proj.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com' , PropStrength__Broker_Account__c = acc.Id);
        insert book;
        System.debug('book --> '+book.PropStrength__Total_Basic_Sales_Price__c);
        System.debug('book --> '+book.PropStrength__Revised_Total_Sales_Consideration__c);
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
            Test.startTest();
            ResaleProcessAppBookingLWCController.getallapplicants(book.id);
            ResaleProcessAppBookingLWCController.getBookingDetails(book.id,'resale');
            String str = '{ "first_Name": "test", "last_Name": "test", "Salutation": "test", "Email": "test@test.com", "Phone_Number": "test", "Passport_Number": "test", "Address": "test", "Resale_Process": "test", "Nationality": "test" }';
            ResaleProcessAppBookingLWCController.getBookingDetails(book.id, '');
            ResaleProcessAppBookingLWCController.createResale(book.id,str);
            ResaleProcessAppBookingLWCController.getallapplicants(book.id);
            ResaleProcessAppBookingLWCController.getallapplicants(book.id);
            ResaleProcessAppBookingLWCController.getallapplicants(book.id);
            Test.stopTest();
            
        }
}