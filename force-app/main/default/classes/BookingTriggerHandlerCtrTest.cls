@isTest
public class BookingTriggerHandlerCtrTest {
    
    @testSetup static void setup() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert sc;
        // Create test data for Bookng__c records
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        Opportunity op = new Opportunity(Id=oppId);
        op.Channel_Partner__c = chPartner.Id;
        op.Sobha_Connect__c = sc.Id;
        op.Walk_In_CP__c = chPartner.Id;
        op.Walk_In_SC__c = sc.Id;
        update op;
        SBTR__c sbtr1 = new SBTR__c();
        //   sbtr1.Booking__c = testBooking.Id;
        sbtr1.Opportunity__c = OPPID;
        Insert sbtr1;
        
        Unit__c u = new Unit__c(Id=unitId);
        u.Puchase_Price__c = 100000;
        update u;
        
        Quotation__c quote = NewCustomerSOAControllerTest.createQuotation(oppId, recordMap.get('PLAN'), unitId);
        Project_Construction_Stages__c PCS = new Project_Construction_Stages__c();
        PCS.Project__c = recordMap.get('PROJECT');
        PCS.Name = 'Completion of Plinth';
        PCS.Sequence_No__c =1;
        PCS.Planned_date_of_completion__c = System.today().addDays(365);
        PCS.Tower__c = recordMap.get('TOWER');
        insert PCS;
        Payment_Milestones__c pm1 = new Payment_Milestones__c();
        pm1.Milestone_Type_edit__c = 'Date Linked';
        pm1.Time_Period__c = 'Months';
        pm1.Number_Of_Days__c = 30;
        pm1.Quotation__c = quote.Id;
        insert pm1;
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        // a1.Booking__c = b.Id;
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
        Insert a1;
        Test.startTest();
        Booking__c testBooking = new Booking__c();
        testBooking.Booking_Date__c = system.today();
        testBooking.Project__c = projectId;
        testBooking.Opportunity__c = oppId;
        testBooking.Unit__c = unitId;
        testBooking.Applicant_Details__c =a1.Id;
        testBooking.status__c = 'Processed';
        testBooking.Quotation__c = quote.Id;
        testBooking.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        testBooking.Future_Correspondence_Contact__c = 'First Applicant';
        testBooking.Agreement_Value__c = 6000000;
        testBooking.Secondary_Sales_Manager__c =  userinfo.getUserId();
        testBooking.Stage_of_Booking__c = 'Booked';
        testBooking.Channel_Partner__c = chPartner.Id;
        testBooking.Sobha_Connect__c = sc.Id;
        insert testBooking;
        Payment_Request__c pr = new Payment_Request__c();
        pr.name__c = 'yamini';
        pr.Booking__c=testBooking.id;
        pr.Email__c = 'test.jakka@test.com';
        pr.Mobile_Number__c='9550987889';
        pr.Emirates_Id_Passport_Number__c='12xgy';
        pr.Mode__c = 'OTC Deposits';
        pr.Status__c='Approved';
        pr.Amount__c = 123;
        pr.Unit__c = unitId;
        pr.Approved_Date_and_Time__c=System.today();
        pr.From_Booking__c = true;
        pr.Sales_Manager__c = userinfo.getUserId();
        insert pr;
        
        unit_hold_request__c newsale = new unit_hold_request__c();
        newsale.Agent_Name__c = 'yamni';
        newsale.Blocking_Amount_Paid__c = 123;
        newsale.Opportunity__c = oppid;
        newsale.Payment_Request__c = pr.Id;
        newsale.Booking__c = testBooking.id;
        //newsale.Approval_Status__c = 'Approved';
        newsale.DLD_Amount__c = 1234;
        newsale.DLD_Amount_2__c = 1342;
        newsale.DP_Amount_2__c = 321;
        newsale.How_Many_Applicants__c = 'One Applicant';
        newsale.Sales_Head_Value__c = userinfo.getUserId();
        newsale.OwnerId = userinfo.getUserId();
        newsale.Sales_Head_VP__c = userinfo.getUserId();
        newsale.Sales_Manager_Value__c = userinfo.getUserId();
        newsale.Approved_Date__c = System.today()+5;
        newsale.Approval_Status__c = 'Approved';
        //newsale.Booked_Date__c = system.today();
        insert newsale;
        newsale.Approved_Date__c = System.today()+6;
        newsale.Approval_Status__c =null;
        update newsale;
        newsale.Approval_Status__c ='Approved';
        newsale.Declared_Date__c = system.today();
        newsale.Booked_Date__c = system.today();
        Test.stopTest();  
        update newsale; 
        
    }
    @isTest static void testMethod1() {
        Test.startTest();
        Booking__c  testBooking = [select Id,Unit__c,Status__c,Project__c,Secondary_Sales_Manager_VP__c, Name,(SELECT Id, Blocking_Amount_Paid__c,Booked_Date__c,Declared_Date__c,Approval_Status__c FROM New_Sale_Approvals__r WHERE Approval_Status__c = 'Approved')
                                   FROM Booking__c];
        
        List<Applicant_Details__c> applicantDetailsList = new List<Applicant_Details__c>();
        Applicant_Details__c ad1 = new Applicant_Details__c();
        ad1.Name = 'A Two';
        ad1.Type_Of_Applicant__c = 'Individual Purchaser';
        ad1.Subtype_Of_Applicant__c = 'Indian National';
        ad1.One_Passport_Size_Color_Photograph__c = true;
        ad1.Permanent_Address__c = 'Perma Addressia';
        ad1.Email_Address__c = 'a2.one@gmail.com';
        ad1.Mobile_Number__c = '989498989';
        ad1.DOB__c = system.today().addMonths(-12);
        ad1.Booking__c = testBooking.Id;
        ad1.Applicant_Number__c = 'Primary Applicant';
        Applicant_Details__c ad2 = new Applicant_Details__c();
        
        applicantDetailsList.add(ad1);
        
        insert applicantDetailsList;
        system.debug('testbooking'+testbooking);
        testBooking.Agreement_Value__c = 60000;
        testBooking.Sales_Head__c = userinfo.getUserId();
        testBooking.Sales_Managers__c = userinfo.getUserId();
        testBooking.Secondary_Sales_Head__c = userinfo.getUserId();
        testBooking.Secondary_Sales_Manager__c = userinfo.getUserId();
        testBooking.Secondary_Sales_Manager_VP__c = userinfo.getUserId();
        update testBooking; 
        SBTR__c sbtr1 =[select id from SBTR__c limit 1];
        SBTR_Approval__c SBTRApproval = new SBTR_Approval__c();
        SBTRApproval.Booked_Date__c = system.today();
        SBTRApproval.SBTR__c =sbtr1.Id;
        insert SBTRApproval;
        list<string> listofIds = new list<string>();
        listofIds.add(SBTRApproval.Id);
        HandlerNewSaleApprovalTrigger.updateSBTR(listofIds);
        list<SBTR__c> listofSBTR = new list<SBTR__c>();
        listofSBTR.add(sbtr1);
        BookingTriggerHandlerCtr.updateSBTRBulk(listofSBTR);
        Booking__c testBooking2 = new Booking__c();
        testBooking2.Status__c = 'Cancelled';
        testBooking2.Reason_For_Cancellation_D__c = '15 days - 0%';
        testBooking.Status__c = 'Cancelled';
        testBooking.Reason_For_Cancellation_D__c = '15 days - 0%';
        update testBooking;
        BookingTriggerHandlerCtr.sendEmailOnBookingCancellation(new List<Booking__c>{testBooking});
        testBooking.SPA_Executed__c='SPA Sent through Docusign';
        update testBooking;
        testBooking.SPA_Executed__c='SPA Executed';
        testBooking.SBTR_Declared__c=system.today();
        testBooking.Agreement_Value__c = 50000;
        update testBooking;
        //BookingTriggerHandlerCtr.sendEmailOnBookingCancellation(new List<Booking__c>{testBooking});
        BookingTriggerHandlerCtr.updateDeclaredDateOnSBTR(new Set<Id>{testBooking.Id});
        BookingTriggerHandlerCtr.updateSaleValueOnSBTR(new map<Id,Decimal>{testBooking.Id => 10000});
        Test.stopTest();   
    }
}