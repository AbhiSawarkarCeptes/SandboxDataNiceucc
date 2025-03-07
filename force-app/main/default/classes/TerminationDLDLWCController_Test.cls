@isTest
public class TerminationDLDLWCController_Test {
   @isTest
    public static void testDatta(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
      test.startTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.PropStrength__Status__c ='Audit Approved';
        appBook.Termination_Process_Status__c = 'Submitted to DLD';
        insert appBook;
       
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        ppd.PropStrength__Is_Milestone_Completed__c = true;
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        insert pay;
        PropStrength__Transaction_Requests__c trRec = TestDataFactorySobha.createTransactionRequest(null);
        trRec.PropStrength__Status__c = 'SPA/DSPA Sent to New Customer';
        insert trRec;
        test.stopTest();
           PropStrength__Projects__c projectId = [SELECT Id FROM PropStrength__Projects__c];
         system.debug('projectId ++'+projectId);

        PropStrength__Tower__c towerId = [SELECT Id FROM PropStrength__Tower__c];
          system.debug('towerId++'+ towerId);
        List<TerminationDLDLWCController.BookingWrapper> bookings = TerminationDLDLWCController.getBookings('All','All', 'selectedType', Date.today(), Date.today());
                 List<TerminationDLDLWCController.BookingWrapper> bookings1 = TerminationDLDLWCController.getBookings(projectId.id,'All', 'selectedType', Date.today(), Date.today());
                          List<TerminationDLDLWCController.BookingWrapper> bookings2 = TerminationDLDLWCController.getBookings('All',towerId.id, 'selectedType', Date.today(), Date.today());
                          List<TerminationDLDLWCController.BookingWrapper> bookings3 = TerminationDLDLWCController.getBookings('All',towerId.id, 'selectedType', Date.today(), Date.today());
                          List<TerminationDLDLWCController.BookingWrapper> bookings4 = TerminationDLDLWCController.getBookings(projectid.id,towerId.id, 'selectedType', Date.today(), Date.today());


       
    }
@isTest
    static void getProjects_test() {
         PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
       
        PropStrength__Tower__c propTower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1');
        INSERT propTower;

        Test.startTest();
        List<PropStrength__Projects__c> projects = TerminationDLDLWCController.getProjects();
        Test.stopTest();

        System.assertEquals(1, projects.size());
        System.assertEquals('Test Project', projects[0].Name);
       
    }
   
   
     @isTest
    static void getPickListValuesIntoList_test() {

        Test.startTest();
        List<String> pickListValues = TerminationDLDLWCController.getPickListValuesIntoList();
        Test.stopTest();

        System.assertNotEquals(0, pickListValues.size());
    }
   
    Static void testData(){
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
       
        PropStrength__Tower__c propTower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1');
        INSERT propTower;
       
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
       
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Project_Name__c = proj.Id, PropStrength__Tower__c = propTower.Id,Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Active__c = true);
        insert prop;
        
        User testUserRec = TestDataFactorySobha.createUser(null);
        insert testUserRec;
       
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c ='Standard';
        acc.Broker_Category__c = 'Individual';
        acc.Name_as_per_passport__c = 'passportName';
        acc.Registration_Passport_Number__c = '123'+String.valueOf(Math.random()).substring(0,5);
        acc.TRN_Number__c ='456'+Math.random();
        acc.Channel_Relationship_Manager__c = testUserRec.id;
        acc.Sales_Manager_User__c = testUserRec.id;
        acc.PropStrength__Broker_Approval_Status__c = 'All Missing Documents Uploaded';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
       
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
       
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
       
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
       
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, Additional_Discount_Given__c = true,
                                                                    Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true,
                                                                    PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id,
                                                                    PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
       
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Applicant_Email__c = 'test@123.com', PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1),Termination_Process_Status__c = 'Raised to DLD Team', PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__Property__c = prop.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,Final_Notice_Approved__c = true);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
       
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
        
        PropStrength__Received_Payment__c pay6 = new PropStrength__Received_Payment__c(PropStrength__Demand_Generated__c = true,PropStrength__Payment_Plan_Detail__c = ppd1.Id, PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Reversal payment due', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId(), PropStrength__Amount__c = 1000);
        payList.add(pay6);
        insert payList;
       
    }
   
   @isTest
    static void getBookings_Test1(){
        testData();
        PropStrength__Projects__c projectId = [SELECT Id FROM PropStrength__Projects__c];
        PropStrength__Tower__c towerId = [SELECT Id FROM PropStrength__Tower__c];
        Test.startTest();
        List<TerminationDLDLWCController.BookingWrapper> bookings = TerminationDLDLWCController.getBookings(projectId.Id, towerId.Id, 'selectedType', Date.today(), Date.today());
        Test.stopTest();
    }
   
     @isTest
    static void getBookings_Test2(){
        testData();
        PropStrength__Projects__c projectId = [SELECT Id FROM PropStrength__Projects__c];

        String towerId = 'ALL';
        Test.startTest();
        List<TerminationDLDLWCController.BookingWrapper> bookings = TerminationDLDLWCController.getBookings(projectId.Id, towerId, 'selectedType',Date.today(), Date.today());
        Test.stopTest();
    }
   
     @isTest
    static void getBookings_Test3(){
        testData();
        PropStrength__Projects__c projectId = [SELECT Id FROM PropStrength__Projects__c];

        String towerId = 'All';
        String selectedType1 = 'Dashboard1';
        String selectedType2 = 'Dashboard2';
        String selectedType3 = 'Dashboard3';
       
        Test.startTest();
        if(selectedType1=='Dashboard1'){
             List<TerminationDLDLWCController.BookingWrapper> bookings = TerminationDLDLWCController.getBookings(projectId.Id, towerId, selectedType1, Date.today(), Date.today());
        }
        if(selectedType2=='Dashboard2'){
             List<TerminationDLDLWCController.BookingWrapper> bookings = TerminationDLDLWCController.getBookings(projectId.Id, towerId, selectedType2, Date.today(), Date.today());
        }
        if(selectedType3=='Dashboard3'){
             List<TerminationDLDLWCController.BookingWrapper> bookings = TerminationDLDLWCController.getBookings(projectId.Id, towerId, selectedType3, Date.today(), Date.today());
        }
        Test.stopTest();
    }
    @isTest
    static void approveEslamFinalNotice_Test4(){
        testData();
        BookingLineItemParser wrap = new BookingLineItemParser();
        wrap.bookingId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id;
        String jsonWrap = JSON.serialize(wrap);

        Test.startTest();
        String result = TerminationDLDLWCController.approveEslamFinalNotice(jsonWrap);
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Id=wrap.bookingId, Final_Notice_Approved__c = false);
        update book;
        wrap = new BookingLineItemParser();
        wrap.bookingId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id;
        jsonWrap = JSON.serialize(wrap);
        String result2 = TerminationDLDLWCController.approveEslamFinalNotice(jsonWrap);
        Test.stopTest();
    }
    @isTest
    static void cancelTheProcess_Test5(){
        testData();
        BookingLineItemParser wrap = new BookingLineItemParser();
        wrap.bookingId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id;
        String jsonWrap = JSON.serialize(wrap);

        Test.startTest();
        String result = TerminationDLDLWCController.cancelTheProcess(jsonWrap);
        Test.stopTest();
    }
    @isTest
    static void validateEslamFinalNotice_Test6(){
        testData();
        BookingLineItemParser wrap = new BookingLineItemParser();
        wrap.bookingId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id;
        String jsonWrap = JSON.serialize(wrap);
        Test.startTest();
        String result = TerminationDLDLWCController.validateEslamFinalNotice(jsonWrap);
        Test.stopTest();
    }
    @isTest
    static void validateEslamDLDNotice_Test7(){
        testData();
        BookingLineItemParser wrap = new BookingLineItemParser();
        wrap.bookingId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id;
        String jsonWrap = JSON.serialize(wrap);

        Test.startTest();
        String result = TerminationDLDLWCController.validateEslamDLDNotice(jsonWrap);
        Test.stopTest();
     }

    @isTest
    public static void testCompareTo() {
        Test.startTest();
        TerminationDLDLWCController.BookingWrapper bw1 = new TerminationDLDLWCController.BookingWrapper();
        bw1.fullDue = 800;
        bw1.due = 500;
        bw1.category = 'Advance Payments';

        TerminationDLDLWCController.BookingWrapper bw2 = new TerminationDLDLWCController.BookingWrapper();
        bw2.fullDue = 1000;
        bw2.due = 300;
        bw2.category = 'Advance Payments';
       
        System.assertEquals(200, bw1.compareTo(bw2), 'Expected bw1 to be greater than bw2');

        TerminationDLDLWCController.BookingWrapper bw4 = new TerminationDLDLWCController.BookingWrapper();
        bw4.fullDue = 1000;
        bw4.due = 600;
        bw4.category = 'Other Category';

        TerminationDLDLWCController.BookingWrapper bw5 = new TerminationDLDLWCController.BookingWrapper();
        bw5.fullDue = 1000;
        bw5.due = 400;
        bw5.category = 'Other Category';
        Test.stopTest();
        System.assertEquals(200, bw1.compareTo(bw2), 'Expected bw1 to be greater than bw2');
    }  

    @isTest
    static void isDLDProfileTest() {
        Test.startTest();
        User currentUser = [SELECT Id, Profile.name FROM User Where Id =: UserInfo.getUserId()];
        Boolean result = TerminationDLDLWCController.isDLDProfile();

        System.assertEquals(currentUser.Profile.Name == 'DLD Team', result, 'Check User');
        Test.stopTest();
    }

    @isTest
    static void returnToCollectionsTest() {
        testData();

        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];

        Test.startTest();
        Boolean result = TerminationDLDLWCController.returnToCollections('/'+booking.Id);
        Test.stopTest();
    }

    @isTest
    static void updateBookingTerminationStatusMultipleTest() {
        testData();

        List<PropStrength__Application_Booking__c> booking = [SELECT Id FROM PropStrength__Application_Booking__c];
        List<String> bookingIds = new List<String>();
        bookingIds.add(booking[0].Id);
   
        Test.startTest();

        TerminationDLDLWCController.updateBookingTerminationStatusMultiple(bookingIds, 'Approve');
        PropStrength__Application_Booking__c bookingResult1 = [SELECT Id, Termination_Process_Status__c FROM PropStrength__Application_Booking__c];
        System.assertEquals('Approved for Termination', bookingResult1.Termination_Process_Status__c, 'Termination_Process_Status');

       
        TerminationDLDLWCController.updateBookingTerminationStatusMultiple(bookingIds, 'Resubmit');
        PropStrength__Application_Booking__c bookingResult2 = [SELECT Id, Termination_Process_Status__c FROM PropStrength__Application_Booking__c];
        System.assertEquals('Resubmitted to Audit', bookingResult2.Termination_Process_Status__c, 'Termination_Process_Status');
       
        Test.stopTest();
    }
    @isTest
    public static void testUpdateAllocation() {
        testData();
        PropStrength__Application_Booking__c insertedBooking = [SELECT Id, Cancellation_Allocation__c FROM PropStrength__Application_Booking__c];
        Test.startTest();
        TerminationDLDLWCController.updateAllocation(insertedBooking.Id, 'Updated Allocation');
        Test.stopTest();
    }
    
    
    @isTest
    public static void testsendEslamDLDNotice() {
        testData();
        PropStrength__Application_Booking__c insertedBooking = [SELECT Id, Cancellation_Allocation__c FROM PropStrength__Application_Booking__c];
        String raw = '{"amountPaidByCustomer":"1000","auditapproveddate":"2024-07-31","bookingDate":"2024-07-15","bookingId":"' 
             + insertedBooking.Id 
            + '","bookingIdVal":"12345","bookingName":"Booking 12345","bucketColor":"Red","cancellationAllocation":"500","category":"Category A","collected":"800","collectedpercentage":80.0,"commentsHistory":"No issues reported","customerName":"John Doe","demands":"Demand details","due":"200","duepercentage":20.0,"finalNoticeReceivedDate":"2024-07-20","finalNoticeReviewLink":"http://example.com/review","finalNoticeSentDate":"2024-07-18","finalNoticeSentDateCourier":"2024-07-18","finalNoticeStatus":"Pending","forfeitedAmount":100,"forfeitureNoticeSentDateCourier":"2024-07-25","forfeitureNoticeSentDate":"2024-07-25","fullDue":"1200","lastCallAttemptStatus":"Success","milestoneDue":"2024-08-01","primaryMobileNumber":"+1234567890","saleValue":"1500","soaLink":"http://example.com/soa","spaexecuted":"Yes","unitId":"U123","unitName":"Unit 123","commentsremarks":"Additional remarks","customerNameArabic":"جون دو","customerAddressArabic":"العنوان هنا","projectCompletionPercentageArabic":"80%","developerFinalNoticeSentDateCourier":"2024-07-28","developerFinalNoticeStatus":"Approved","terminationProcessStatus":"In Progress","terminationCompletionDate":"2024-08-10","label":"Label 1","value":"Value 1","dldNoticeStatus":"Sent","dldNoticeStatusCategory":"Category 1"}';

        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Final Notice',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = insertedBooking.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
         ContentVersion contentVersion2 = new ContentVersion(
            Title = 'DLD Notice',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;    
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion2.Id];
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = insertedBooking.id;
        cdl2.ContentDocumentId = documents2[0].Id;
        cdl2.shareType = 'V';
        insert cdl2;
        
        Test.startTest();
        TerminationDLDLWCController.sendEslamDLDNotice(raw,'test@123.com,test@456.com');
        TerminationDLDLWCController.sendEslamFinalNotice(raw,'test@123.com,test@456.com');
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateBookingTerminationStatus() {
        testData();
        PropStrength__Application_Booking__c insertedBooking = [SELECT Id, Cancellation_Allocation__c FROM PropStrength__Application_Booking__c];
        String raw = '{"amountPaidByCustomer":"1000","auditapproveddate":"2024-07-31","bookingDate":"2024-07-15","bookingId":"' 
             + insertedBooking.Id 
            + '","bookingIdVal":"12345","bookingName":"Booking 12345","bucketColor":"Red","cancellationAllocation":"500","category":"Category A","collected":"800","collectedpercentage":80.0,"commentsHistory":"No issues reported","customerName":"John Doe","demands":"Demand details","due":"200","duepercentage":20.0,"finalNoticeReceivedDate":"2024-07-20","finalNoticeReviewLink":"http://example.com/review","finalNoticeSentDate":"2024-07-18","finalNoticeSentDateCourier":"2024-07-18","finalNoticeStatus":"Pending","forfeitedAmount":100,"forfeitureNoticeSentDateCourier":"2024-07-25","forfeitureNoticeSentDate":"2024-07-25","fullDue":"1200","lastCallAttemptStatus":"Success","milestoneDue":"2024-08-01","primaryMobileNumber":"+1234567890","saleValue":"1500","soaLink":"http://example.com/soa","spaexecuted":"Yes","unitId":"U123","unitName":"Unit 123","commentsremarks":"Additional remarks","customerNameArabic":"جون دو","customerAddressArabic":"العنوان هنا","projectCompletionPercentageArabic":"80%","developerFinalNoticeSentDateCourier":"2024-07-28","developerFinalNoticeStatus":"Approved","terminationProcessStatus":"In Progress","terminationCompletionDate":"2024-08-10","label":"Label 1","value":"Value 1","dldNoticeStatus":"Sent","dldNoticeStatusCategory":"Category 1"}';
        
        String raw1 = '[{"amountPaidByCustomer":"1000","auditapproveddate":"2024-07-31","bookingDate":"2024-07-15","bookingId":"' 
             + insertedBooking.Id 
            + '","bookingIdVal":"12345","bookingName":"Booking 12345","bucketColor":"Red","cancellationAllocation":"500","category":"Category A","collected":"800","collectedpercentage":80.0,"commentsHistory":"No issues reported","customerName":"John Doe","demands":"Demand details","due":"200","duepercentage":20.0,"finalNoticeReceivedDate":"2024-07-20","finalNoticeReviewLink":"http://example.com/review","finalNoticeSentDate":"2024-07-18","finalNoticeSentDateCourier":"2024-07-18","finalNoticeStatus":"Pending","forfeitedAmount":100,"forfeitureNoticeSentDateCourier":"2024-07-25","forfeitureNoticeSentDate":"2024-07-25","fullDue":"1200","lastCallAttemptStatus":"Success","milestoneDue":"2024-08-01","primaryMobileNumber":"+1234567890","saleValue":"1500","soaLink":"http://example.com/soa","spaexecuted":"Yes","unitId":"U123","unitName":"Unit 123","commentsremarks":"Additional remarks","customerNameArabic":"جون دو","customerAddressArabic":"العنوان هنا","projectCompletionPercentageArabic":"80%","developerFinalNoticeSentDateCourier":"2024-07-28","developerFinalNoticeStatus":"Approved","terminationProcessStatus":"In Progress","terminationCompletionDate":"2024-08-10","label":"Label 1","value":"Value 1","dldNoticeStatus":"Sent","dldNoticeStatusCategory":"Category 1"}]';

        Test.startTest();
        TerminationDLDLWCController.updateBookingTerminationStatus(raw,'Approve');
        TerminationDLDLWCController.updateBookingTerminationStatus(raw,'Resubmit');
        TerminationDLDLWCController.updateBookingRow(raw, true, true, 'test', true, true, true, true);
        TerminationDLDLWCController.updateBookingRow(raw1, false, true, 'test', true, true, true, true);
        Test.stopTest();
    }
    @isTest
    public static void updateBookingRowTest() {
        testData();
        Test.startTest();
        List<PropStrength__Application_Booking__c> booking = [SELECT Id FROM PropStrength__Application_Booking__c];
        String raw = '[{"amountPaidByCustomer":"1000","auditapproveddate":"2024-07-31","bookingDate":"2024-07-15","bookingId":'+ booking[0].Id +',"bookingIdVal":"12345","bookingName":"Booking 12345","bucketColor":"Red","cancellationAllocation":"500","category":"Category A","collected":"800","collectedpercentage":80.0,"commentsHistory":"No issues reported","customerName":"John Doe","demands":"Demand details","due":"200","duepercentage":20.0,"finalNoticeReceivedDate":"2024-07-20","finalNoticeReviewLink":"http://example.com/review","finalNoticeSentDate":"2024-07-18","finalNoticeSentDateCourier":"2024-07-18","finalNoticeStatus":"Pending","forfeitedAmount":100,"forfeitureNoticeSentDateCourier":"2024-07-25","forfeitureNoticeSentDate":"2024-07-25","fullDue":"1200","lastCallAttemptStatus":"Success","milestoneDue":"2024-08-01","primaryMobileNumber":"+1234567890","saleValue":"1500","soaLink":"http://example.com/soa","spaexecuted":"Yes","unitId":"U123","unitName":"Unit 123","commentsremarks":"Additional remarks","customerNameArabic":"جون دو","customerAddressArabic":"العنوان هنا","projectCompletionPercentageArabic":"80%","developerFinalNoticeSentDateCourier":"2024-07-28","developerFinalNoticeStatus":"Approved","terminationProcessStatus":"In Progress","terminationCompletionDate":"2024-08-10","label":"Label 1","value":"Value 1","dldNoticeStatus":"Sent","dldNoticeStatusCategory":"Category 1"},{"amountPaidByCustomer":"2000","auditapproveddate":"2024-06-30","bookingDate":"2024-06-10","bookingId":"B67890","bookingIdVal":"67890","bookingName":"Booking 67890","bucketColor":"Green","cancellationAllocation":"300","category":"Category B","collected":"1600","collectedpercentage":80.0,"commentsHistory":"Minor issues resolved","customerName":"Jane Smith","demands":"Another demand detail","due":"400","duepercentage":20.0,"finalNoticeReceivedDate":"2024-07-10","finalNoticeReviewLink":"http://example.com/review2","finalNoticeSentDate":"2024-07-08","finalNoticeSentDateCourier":"2024-07-08","finalNoticeStatus":"Completed","forfeitedAmount":50,"forfeitureNoticeSentDateCourier":"2024-07-15","forfeitureNoticeSentDate":"2024-07-15","fullDue":"2000","lastCallAttemptStatus":"Failed","milestoneDue":"2024-08-15","primaryMobileNumber":"+0987654321","saleValue":"2500","soaLink":"http://example.com/soa2","spaexecuted":"No","unitId":"U456","unitName":"Unit 456","commentsremarks":"Some remarks","customerNameArabic":"جين سميث","customerAddressArabic":"عنوان آخر","projectCompletionPercentageArabic":"70%","developerFinalNoticeSentDateCourier":"2024-07-18","developerFinalNoticeStatus":"Pending","terminationProcessStatus":"Completed","terminationCompletionDate":"2024-07-20","label":"Label 2","value":"Value 2","dldNoticeStatus":"Pending","dldNoticeStatusCategory":"Category 2"}]';
       // Boolean data = TerminationDLDLWCController.updateBookingRow(raw, true, true, 'Test', true, true, true, true );
       // Boolean data1 = TerminationDLDLWCController.updateBookingRow(raw, false, true, 'Test', true, true, true, true );
        Test.stopTest();
    }
}